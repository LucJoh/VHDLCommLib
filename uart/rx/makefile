#####################################################################
# User configuration
#####################################################################

# Name of directories
SRC_DIR=src
TB_DIR=testbench
DO_DIR=do-files

# Name of testbench entity
TB_ENTITY=tb

# Name of do file
DO_FILE=$(DO_DIR)/do.do

# Name of all source files in compile order
SRC:=$(SRC_DIR)/uart_pkg.vhdl \
     $(SRC_DIR)/uart_rx.vhdl 

TB=$(TB_DIR)/tb.vhdl

# Specify the simulation time for GHDL and NVC
SIM_TIME=120ms

#####################################################################
# End of user configuration
#####################################################################

#####################################################################
#####################################################################

# Tools
VCOM=vcom -2008
VSIM=vsim
GHDL=ghdl
NVC=nvc
FLAGS="--std=08"

#####################################################################
#####################################################################

# Tabs are not expanded as spaces
vim:noet

.PHONY: all vcom vsim vsimb ghdl clean help init

all: clean init vcom vsim

vcom: $(SRC)
		$(VCOM) $(SRC) $(TB)

vsim: $(TB_DIR)/$(TB_ENTITY).vhd*
		$(VSIM) $(TB_ENTITY) -do $(DO_FILE)

vsimb: $(TB_DIR)/$(TB_ENTITY).vhd*
		$(VSIM) -c $(TB_ENTITY) -do $(DO_FILE)

ghdl:
	@$(GHDL) -a $(FLAGS) --ieee=synopsys -fexplicit -fsynopsys -frelaxed $(SRC) $(TB)
	@$(GHDL) -e $(FLAGS) -frelaxed $(TB_ENTITY)
	@$(GHDL) -r $(FLAGS) -frelaxed $(TB_ENTITY) --wave=wave.ghw --stop-time=$(SIM_TIME)

nvc:
	@$(NVC) -a $(SRC) $(TB)
	@$(NVC) -e $(TB_ENTITY)
	@$(NVC) -r $(TB_ENTITY) --wave=wave.ghw --stop-time=$(SIM_TIME)

init:
	vlib work
	vmap -c

clean:
	rm -f transcript *.wlf *.ghw *.o *.cf $(TB_ENTITY) modelsim.ini work -rf

help:
	@echo "$$HEADER"
	@echo "Usage: make [help|init|all|vcom|vsim|vsimb|ghdl|nvc|clean]"
	@echo ""
	@echo "  init:   Create a design library, and generate a copy of modelsim.ini"
	@echo "  vcom:   Compile the design using Modelsim"
	@echo "  vsim:   Simulate the design using Modelsim" 
	@echo "  vsimb:  Simulate the design using Modelsim in batch-mode"   
	@echo "  all:    Compile and simulate the design using Modelsim"
	@echo "  ghdl:   Compile and simulate the design using GHDL"
	@echo "          To view the waveforms, run 'gtkwave wave.ghw'"
	@echo "          Save wave configuration, inside gtkwave, go to File -> Write Save File"
	@echo "          To load the wave configuration, run 'gtkwave wave.ghw config.gtkw'"
	@echo "  nvc:    Compile and simulate the design using NVC"
	@echo "          To view the waveforms, run 'gtkwave wave.ghw'"
	@echo "          Save wave configuration, inside gtkwave, go to File -> Write Save File"
	@echo "          To load the wave configuration, run 'gtkwave wave.ghw config.gtkw'"
	@echo "  clean:  Remove all generated files"
	@echo ""

define HEADER
                    _         __ _ _        
    _ __ ___   __ _| | _____ / _(_) | ___   
   | '_ ` _ \ / _` | |/ / _ \ |_| | |/ _ \ 
   | | | | | | (_| |   <  __/  _| | |  __/ 
   |_| |_| |_|\__,_|_|\_\___|_| |_|_|\___| 
     __                    _         _ _
    / _| ___  _ __  __   _| |__   __| | |
   | |_ / _ \| '__| \ \ / / '_ \ / _` | |
   |  _| (_) | |     \ V /| | | | (_| | |
   |_|  \___/|_|      \_/ |_| |_|\__,_|_|

endef

export HEADER

