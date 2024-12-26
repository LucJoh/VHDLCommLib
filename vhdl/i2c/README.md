# I2C VHDL Compilation and Simulation with VUnit

This directory contains the necessary files and a Makefile, to manage VHDL simulation and compilation tasks for the I2C project.

## Prerequisites

Ensure you have the following tools installed on your system:

* One of the following simulators:
  - ModelSim
  - GHDL
  - NVC
  - Riviera-PRO
  - Active-HDL
  - Incisive
* GTKWave (required for waveform viewing when using GHDL or NVC)
* Python 3.0 (or newer)
* VUnit (installed using pip)

```sh
  pip install vunit_hdl 
```

## Usage

The Makefile supports various targets to help you manage your simulation and compilation workflow.

When compiling and simulating, it is required to specify the simulator tool.
For example:

```sh
  make sim_multhread ghdl 
```

Below are the available targets and their descriptions:

# help
- Display a list of available targets and their descriptions:

```sh
  make help 
```

# sim
- Compile and simulate all test cases:

```sh
  make sim 
```

# sim_multhread
- Compile and simulate all test cases (using 2 cpu cores):

```sh
  make sim_multhread 
```

# sim_write
- Simulate the write operation:

```sh
  make sim_write 
```

# sim_write_gui
- Simulate the write operation with the waveform GUI:

```sh
  make sim_write_gui 
```

# sim_read
- Simulate the read operation:

```sh
  make sim_read 
```

# sim_read_gui
- Simulate the read operation with the waveform GUI:

```sh
  make sim_read_gui 
```

# clean
- Remove all generated files:

```sh
  make clean 
```
