Building
========

There are different components developed for this project. The lower level "real" can controller code and the more high level code running on the FPGA.

Low level code
''''''''''''''
 

The low level code is edited using a "normal" editor and validated using ghdl. After a clone of the git repository and installing ghdl one can type make run to build and test the code

targets:

 * make run compiles and run all the tests
 * make vcd compiles and runs all the tests while creating a value change dump file (that can be viewed using gtkwave)
 * make -f Makefile.ise builds an ise based project (using the xilinx tools). This is mostly usefull to find errors that ghdl does not find or validate that the code will compile using the ISE tools
 * ./gen_deps.sh parses the vhdl files to create a list of dependencies


High level code
'''''''''''''''

High level code is a bit harder to build as it requires an UI. 

 * Install DesignLab
 * Install the examples like described here https://github.com/GadgetFactory/DesignLab_Examples/blob/master/README.md
 * Symlink DesignLab_Examples/libraries/can_wb to this project DesignLab_Examples/libraries/can_wb
 * Test flashing (ZPUINO/and softcore (examples->can_wb->cantact)
 * Do file open DesignLab_Examples/libraries/can_wb/edit_library.ino
 * Click on the sketchdir://circuit/PSL_Papilio_Pro_LX9.xise icon to start ise
 * Add the files found in hdl/can/syn/ as described here http://forum.gadgetfactory.net/topic/2835-new-vhdl-library/
 * Click generate bit file
 * before commiting code make sure to run DesignLab_Examples/libraries/can_wb/clean.sh to remove intermediate crap




