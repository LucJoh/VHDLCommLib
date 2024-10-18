from vunit import VUnit
from os.path import join, dirname

VU = VUnit.from_argv(compile_builtins=False)
ROOT = dirname(__file__)

spi = VU.add_library("spi")
spi.add_source_files(join(ROOT, "spi", "src", "*.vhdl"))
spi.add_source_files(join(ROOT, "spi", "testbench", "*.vhdl"))

uart_tx = VU.add_library("tx")
uart_tx.add_source_files(join(ROOT, "uart", "tx", "src", "*.vhdl"))
uart_tx.add_source_files(join(ROOT, "uart", "tx", "testbench", "*.vhdl"))

uart_rx = VU.add_library("rx")
uart_rx.add_source_files(join(ROOT, "uart", "rx", "src", "*.vhdl"))
uart_rx.add_source_files(join(ROOT, "uart", "rx", "testbench", "*.vhdl"))

VU.main()
