from vunit import VUnit
from os.path import join, dirname

VU = VUnit.from_argv(compile_builtins=False)
VU.add_vhdl_builtins()  # Add the VHDL builtins explicitly!

ROOT = dirname(__file__)

i2c = VU.add_library("i2c")
i2c.add_source_files(join(ROOT, "src", "*.vhdl"))
i2c.add_source_files(join(ROOT, "testbench", "*.vhdl"))

VU.main()
