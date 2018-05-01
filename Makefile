GHDL=ghdl
GHDLFLAGS=-r --ieee=synopsys --std=08

#
# Source files
#
VHDL_SRC=          \
	hdl/can/syn/can_phy.vhd    \
	hdl/can/syn/can_clk.vhd    \
	hdl/can/syn/can_crc.vhd    \
	hdl/can/syn/can_tx.vhd     \
	hdl/can/syn/can_rx.vhd     \
	hdl/can/syn/can_tx_mux.vhd \
	hdl/can/syn/can.vhd        \
	hdl/can/syn/can_wb.vhd

#
# Test benched
#
VHDL_TEST_SRC=                             \
	hdl/can/sim/can_phy_tb.vhd                  \
	hdl/can/sim/can_clk_tb.vhd                  \
	hdl/can/sim/can_crc_tb.vhd                  \
	hdl/can/sim/can_tx_tb.vhd                   \
	hdl/can/sim/can_rx_tb.vhd                   \
	hdl/can/sim/can_tb.vhd                      \
	hdl/can/sim/can_two_devices_tb.vhd          \
	hdl/can/sim/can_two_devices_clk_sync_tb.vhd \
	hdl/can/sim/can_wb_tb.vhd                   \
	hdl/can/sim/can_wb_register_tb.vhd 


VHDL_MODULES = $(patsubst hdl/can/syn/%.vhd,%,$(VHDL_SRC))
VHDL_TESTS = $(patsubst hdl/can/sim/%.vhd,%,$(VHDL_TEST_SRC))

tests:work-obj08.cf
	cp -r hdl/can/sim/test_data .
	ghdl  -r --ieee=synopsys --std=08 can_phy_tb
	ghdl  -r --ieee=synopsys --std=08 can_clk_tb
	ghdl  -r --ieee=synopsys --std=08 can_crc_tb
	ghdl  -r --ieee=synopsys --std=08 can_tx_tb
	ghdl  -r --ieee=synopsys --std=08 can_rx_tb
	ghdl  -r --ieee=synopsys --std=08 can_tb
	ghdl  -r --ieee=synopsys --std=08 can_two_devices_tb
	ghdl  -r --ieee=synopsys --std=08 can_two_devices_clk_sync_tb
	ghdl  -r --ieee=synopsys --std=08 can_wb_tb
	ghdl  -r --ieee=synopsys --std=08 can_wb_register_tb

work-obj08.cf: $(VHDL_SRC) $(VHDL_TEST_SRC)
	ghdl -a --ieee=synopsys --std=08 $?

clean:
	rm -rf work-obj08.cf *.hex vunit_out test_data
