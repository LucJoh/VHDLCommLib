# Variables
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
SRC_DIR = src
TB_DIR = testbench
OUTPUT = simulation
VCD_FILE = waveform.vcd
GTKW_FILE = waves/waveform.gtkw
FILES = files.txt

# Default target
all: compile simulate wave

# Compile Verilog files
compile:
	$(IVERILOG) -g2012 -o $(OUTPUT) -c $(FILES)

# Run simulation
simulate: compile
	$(VVP) $(OUTPUT)

# View waveform
wave: simulate
	$(GTKWAVE) $(VCD_FILE) $(GTKW_FILE)

# Clean generated files
clean:
	rm -f $(OUTPUT) $(VCD_FILE)

# Display help
help:
	@echo "                _ _"
	@echo "__   _____ _ __(_) | ___   __ _"
	@echo "\ \ / / _ \ '__| | |/ _ \ / _\` |"
	@echo " \ V /  __/ |  | | | (_) | (_| |"
	@echo "  \_/ \___|_|  |_|_|\___/ \__, |"
	@echo "                          |___/"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Compile, simulate, and view waveform"
	@echo "  compile   - Compile the Verilog files"
	@echo "  simulate  - Run the simulation"
	@echo "  wave      - View the waveform using GTKWave"
	@echo "  clean     - Clean the generated files"
	@echo "  help      - Display this help message"
	@echo ""

# Phony targets
.PHONY: all compile simulate wave clean help

