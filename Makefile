GHDL=ghdl
GHDLFLAGS=-r --ieee=synopsys --std=08

CFLAGS=-Wc,-fprofile-instr-generate -Wc,-fcoverage-mapping

#
#
VHDL_SRC= $(shell find hdl/ -name "*vhd")


# just for "finding the test bench sources 
VHDL_TEST_SRC= $(shell find hdl -name "*_tb.vhd")
VHDL_TESTS = $(patsubst hdl/can/sim/%.vhd,%,$(VHDL_TEST_SRC))
VHDL_TESTS_VCD = $(patsubst hdl/can/sim/%.vhd,%.vcd,$(VHDL_TEST_SRC))

all:$(VHDL_TESTS) copy_data

vcd:$(VHDL_TESTS_VCD) copy_data

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
#
%.vcd:% copy_data
	ghdl -r $<  --vcd=$<.vcd

copy_data:
	cp -r hdl/can/sim/test_data .

clean:
	rm -rf *.txt work-obj08.cf *.hex vunit_out test_data build *.o $(VHDL_TESTS) *.vcd
