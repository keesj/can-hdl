from vunit import VUnit


ui = VUnit.from_argv()
lib = ui.add_library("lib")
lib.add_source_files("hdl/can/syn/*.vhd")
lib.add_source_files("hdl/can/sim/*.vhd")
ui.main()
