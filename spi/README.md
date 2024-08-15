SPI VHDL Simulation and Compilation with Makefile

This directory contains the necessary files and a Makefile to manage VHDL simulation and compilation tasks for the SPI project using ModelSim, GHDL, and NVC.

Prerequisites

Ensure you have the following tools installed on your system:

- ModelSim (for vcom, vsim, vsimb, and all targets)
- GHDL (for ghdl target)
- NVC (for nvc target)
- GTKWave (for waveform viewing when using GHDL or NVC)

Usage

The Makefile supports various targets to help you manage your simulation and compilation workflow. Below are the available targets and their descriptions:

1. make init
- Purpose: Initialize the design library and generate a copy of modelsim.ini.
- Usage: 
  make init
- Effect: This command sets up the necessary environment for ModelSim by creating a design library and copying modelsim.ini.

2. make vcom
- Purpose: Compile the design using ModelSim.
- Usage:
  make vcom
- Effect: This command compiles your VHDL code using ModelSim.

3. make vsim
- Purpose: Simulate the design using ModelSim (GUI mode).
- Usage:
  make vsim
- Effect: This command launches the ModelSim GUI and runs the simulation.

4. make vsimb
- Purpose: Simulate the design using ModelSim in batch mode.
- Usage:
  make vsimb
- Effect: This command runs the simulation in batch mode without opening the ModelSim GUI.

5. make all
- Purpose: Compile and simulate the design using ModelSim.
- Usage:
  make all
- Effect: This command performs both compilation and simulation in one step, opening the ModelSim GUI for simulation.

6. make ghdl
- Purpose: Compile and simulate the design using GHDL.
- Usage:
  make ghdl
- Effect: This command compiles and simulates the design using GHDL. After simulation, you can view the waveform using GTKWave.

- To view waveforms:
  gtkwave wave.ghw
- To save waveform configuration:
  Inside GTKWave, go to File -> Write Save File.
- To load waveform configuration:
  gtkwave wave.ghw config.gtkw

7. make nvc
- Purpose: Compile and simulate the design using NVC.
- Usage:
  make nvc
- Effect: This command compiles and simulates the design using NVC. Similar to GHDL, you can view the waveforms using GTKWave.

- To view waveforms:
  gtkwave wave.ghw
- To save waveform configuration:
  Inside GTKWave, go to File -> Write Save File.
- To load waveform configuration:
  gtkwave wave.ghw config.gtkw

8. make clean
- Purpose: Remove all generated files.
- Usage:
  make clean
- Effect: This command cleans up all generated files from the compilation and simulation process.

Example Workflow with ModelSim

1. Initialize the project:
   make init

2. Compile and open the simulation in the GUI:
   make all
