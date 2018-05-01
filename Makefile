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
	hdl/can/sim/can_phy_testbench.vhd                  \
	hdl/can/sim/can_clk_testbench.vhd                  \
	hdl/can/sim/can_crc_testbench.vhd                  \
	hdl/can/sim/can_tx_testbench.vhd                   \
	hdl/can/sim/can_rx_testbench.vhd                   \
	hdl/can/sim/can_testbench.vhd                      \
	hdl/can/sim/can_two_devices_testbench.vhd          \
	hdl/can/sim/can_two_devices_clk_sync_testbench.vhd \
	hdl/can/sim/can_wb_testbench.vhd                   \
	hdl/can/sim/can_wb_register_testbench.vhd 


VHDL_MODULES = $(patsubst hdl/can/syn/%.vhd,%,$(VHDL_SRC))
VHDL_TESTS = $(patsubst hdl/can/sim/%.vhd,%,$(VHDL_TEST_SRC))

tests:
	cp -r hdl/can/sim/test_data .
	ghdl  -r --ieee=synopsys --std=08 can_phy_testbench
	ghdl  -r --ieee=synopsys --std=08 can_clk_testbench
	ghdl  -r --ieee=synopsys --std=08 can_crc_testbench
	ghdl  -r --ieee=synopsys --std=08 can_tx_testbench
	ghdl  -r --ieee=synopsys --std=08 can_rx_testbench
	ghdl  -r --ieee=synopsys --std=08 can_testbench
	ghdl  -r --ieee=synopsys --std=08 can_two_devices_testbench
	ghdl  -r --ieee=synopsys --std=08 can_two_devices_clk_sync_testbench
	ghdl  -r --ieee=synopsys --std=08 can_wb_testbench
	ghdl  -r --ieee=synopsys --std=08 can_wb_register_testbench

work-obj08.cf: $(VHDL_SRC) $(VHDL_TEST_SRC)
	ghdl -a --ieee=synopsys --std=08 $?

