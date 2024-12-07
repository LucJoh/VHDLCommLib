vim:noet

export VUNIT_SIMULATOR=ghdl

sim:
	$(eval VUNIT_SIMULATOR = $(word 2, $(MAKECMDGOALS)))
	python3 run.py -v

sim_multhread:
	$(eval VUNIT_SIMULATOR = $(word 2, $(MAKECMDGOALS)))
	python3 run.py -v -p 2

sim_write:
	$(eval VUNIT_SIMULATOR = $(word 2, $(MAKECMDGOALS)))
	python3 run.py i2c.tb.write -v

sim_write_gui:
	$(eval VUNIT_SIMULATOR = $(word 2, $(MAKECMDGOALS)))
	python3 run.py i2c.tb.write --gui 

sim_read:
	$(eval VUNIT_SIMULATOR = $(word 2, $(MAKECMDGOALS)))
	python3 run.py i2c.tb.read -v

sim_read_gui:
	$(eval VUNIT_SIMULATOR = $(word 2, $(MAKECMDGOALS)))
	python3 run.py i2c.tb.read --gui

clean:
	rm -rf vunit_out

help:
	@echo "$$HEADER"
	@echo "Usage: make [help|sim|sim_write|sim_write_gui|sim_read|sim_read_gui|clean]"
	@echo ""
	@echo "You need to set the simulator to modelsim|ghdl|nvc|rivierapro|activehdl|incisive"
	@echo ""
	@echo "For example: make sim_multread ghdl"
	@echo ""
	@echo "  sim:             Compile and simulate all test cases"
	@echo "  sim_multhread:   Compile and simulate all test cases (using 2 cpu cores)"
	@echo "  sim_write:       Compile and simulate the write operation"
	@echo "  sim_write_gui:   Compile and simulate the write operation with GUI waveforms"
	@echo "  sim_read:        Compile and simulate the read operation"
	@echo "  sim_read_gui:    Compile and simulate the read operation with GUI waveforms"
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

