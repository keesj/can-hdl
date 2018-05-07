GHDL=ghdl
GHDLFLAGS=-r --ieee=synopsys --std=08

CFLAGS=-Wc,-fprofile-instr-generate -Wc,-fcoverage-mapping
#LDFLAGS=-Wl,-lgcov
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

VHDL_MODULE_OBJ = $(patsubst hdl/can/syn/%.vhd,%.o,$(VHDL_SRC))
#VHDL_TEST_OBJ += $(patsubst hdl/can/sim/%.vhd,%.o,$(VHDL_TEST_SRC))

%.o:hdl/can/sim/%.vhd
	ghdl -a --ieee=synopsys --std=08 $<

%.o:hdl/can/syn/%.vhd
	ghdl -a --ieee=synopsys --std=08 $<

%:%.o
	ghdl -e --ieee=synopsys --std=08  $@

demo:$(VHDL_MODULE_OBJ) $(VHDL_TESTS)
	#ghdl -e --ieee=synopsys --std=08  $?

%_report.txt:%
	ghdl -r $<  --vcd=$<.vcd | tee $@

copy_data:
	cp -r hdl/can/sim/test_data .

tests:$(VHDL_TESTS) copy_data can_two_devices_clk_sync_tb_report.txt

#work-obj08.cf: $(VHDL_SRC) $(VHDL_TEST_SRC)#
#	#ghdl -a  $(CFLAGS) --ieee=synopsys --std=08 $(VHDL_SRC)
#	ghdl -a --ieee=synopsys --std=08 $(VHDL_TEST_SRC)

clean:
	rm -rf *.txt work-obj08.cf *.hex vunit_out test_data build *.o $(VHDL_TESTS)
