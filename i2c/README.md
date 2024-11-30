# I2C VHDL Compilation and Simulation with VUnit

This directory contains the necessary files and a Makefile, to manage VHDL simulation and compilation tasks for the I2C project, using VUnit and ModelSim.

## Prerequisites

Ensure you have the following tools installed on your system:

- ModelSim
- Python 3.0 (or newer)
- VUnit (installed using pip)

  *pip install vunit_hdl*

## Usage

The Makefile supports various targets to help you manage your simulation and compilation workflow. Below are the available targets and their descriptions:

# help
- Purpose: Display a list of available targets and their descriptions.
- Usage:

```sh
  make help 
```

# sim
- Purpose: Compile and simulate all test cases using ModelSim.
- Usage:  

```sh
  make sim 
```

# sim_multhread
- Purpose: Compile and simulate all test cases using ModelSim (using 2 cpu cores).
- Usage:  

```sh
  make sim_multhread 
```

# sim_write
- Purpose: Simulate the write operation.
- Usage:  

```sh
  make sim_write 
```

# sim_write_gui
- Purpose: Simulate the write operation with the ModelSim GUI. Add waves manually and type vunit_run in the console.
- Usage:  

```sh
  make sim_write_gui 
```

# sim_read
- Purpose: Simulate the read operation.
- Usage:  

```sh
  make sim_read 
```

# sim_read_gui
- Purpose: Simulate the read operation with the ModelSim GUI. Add waves manually and type vunit_run in the console.
- Usage:  

```sh
  make sim_read_gui 
```

# clean
- Purpose: Remove all generated files.
- Usage:  

```sh
  make clean 
```
