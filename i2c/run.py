from vunit import VUnit
from os.path import join, dirname

VU = VUnit.from_argv()
VU.add_vhdl_builtins()  # Add the VHDL builtins explicitly!

ROOT = dirname(__file__)

i2c = VU.add_library("i2c")
i2c.add_source_files(join(ROOT, "src", "*.vhdl"))
i2c.add_source_files(join(ROOT, "testbench", "*.vhdl"))

# Add waveform automatically when running in GUI mode.
i2c.set_sim_option("modelsim.init_file.gui","waves/wave.do")
i2c.set_sim_option("ghdl.viewer_script.gui","waves/wave.tcl")
i2c.set_sim_option("nvc.viewer_script.gui","waves/wave.tcl")

VU.main()
