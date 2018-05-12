GHDL=ghdl
GHDLFLAGS=-r --ieee=synopsys --std=08

CFLAGS=-Wc,-fprofile-instr-generate -Wc,-fcoverage-mapping

#
#
VHDL_SRC= $(shell find hdl/ -name "*vhd")


# just for "finding the test bench sources 
VHDL_TEST_SRC= $(shell find hdl -name "*_tb.vhd")
VHDL_TESTS = $(patsubst hdl/can/sim/%.vhd,%,$(VHDL_TEST_SRC))
VHDL_TESTS_RUN = $(patsubst hdl/can/sim/%.vhd,%.run,$(VHDL_TEST_SRC))
VHDL_TESTS_VCD = $(patsubst hdl/can/sim/%.vhd,%.vcd,$(VHDL_TEST_SRC))

all:$(VHDL_TESTS)

run:$(VHDL_TESTS_RUN)

vcd:$(VHDL_TESTS_VCD)

# Generated using gen_deps.sh....
include deps.mk

%.o:hdl/can/sim/%.vhd
	ghdl -a --ieee=synopsys --std=08 $<

%.o:hdl/can/syn/%.vhd
	ghdl -a --ieee=synopsys --std=08 $<

#
# creating the binary
%:%.o
	ghdl -e --ieee=synopsys --std=08  $@ 

#
%.run:%
	ghdl -r --ieee=synopsys --std=08 $< 
#
#
%.vcd:%
	ghdl -r --ieee=synopsys --std=08 $<  --vcd=$<.vcd

clean:
	rm -rf *.txt work-obj08.cf *.hex vunit_out test_data build *.o $(VHDL_TESTS) *.vcd
