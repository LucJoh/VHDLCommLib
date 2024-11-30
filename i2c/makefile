vim:noet

.PHONY: all vcom vsim vsimb ghdl clean help init

sim: clean
	python3 run.py -v

sim_multhread: clean
	python3 run.py -v -p 2

sim_write: clean
	python3 run.py i2c.tb.write

sim_write_gui: clean
	python3 run.py i2c.tb.write --gui

sim_read: clean
	python3 run.py i2c.tb.read

sim_read_gui: clean
	python3 run.py i2c.tb.read --gui

clean:
	rm -rf vunit_out

help:
	@echo "$$HEADER"
	@echo "Usage: make [help|sim|sim_write|sim_write_gui|sim_read|sim_read_gui|clean]"
	@echo ""
	@echo "  sim:             Compile and simulate all test cases using Modelsim"
	@echo "  sim_multhread:   Compile and simulate all test cases using Modelsim (using 2 cpu cores)"
	@echo "  sim_write:       Compile and simulate the write operation using Modelsim"
	@echo "  sim_write_gui:   Compile and simulate the write operation using Modelsim gui"
	@echo "  sim_read:        Compile and simulate the read operation using Modelsim"
	@echo "  sim_read_gui:    Compile and simulate the read operation using Modelsim gui"
	@echo "  clean:           Remove all generated files"
	@echo ""

define HEADER                               
     _     ___   _       _ _   
    \ \   / / | | |_ __ (_) |_ 
     \ \ / /| | | | '_ \| | __|
      \ V / | |_| | | | | | |_ 
       \_/   \___/|_| |_|_|\__|
     
endef

export HEADER

