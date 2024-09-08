# VHDLCommLib

Welcome to VHDLCommLib, a library of communication protocols implemented in VHDL. This repository aims to provide high-quality, reusable VHDL modules for a wide range of communication standards, making it easier for developers and engineers to integrate robust communication capabilities into their FPGA and hardware designs.

## Design Methodology

The VHDL modules in this repository are designed using the [two-process method](https://www.gaisler.com/doc/vhdl2proc.pdf). This method involves separating the combinational logic and the sequential logic into two distinct processes. The first process handles the combinational logic and is sensitive to input signals, while the second process handles the sequential logic and is driven by the clock signal. This separation simplifies the design, improves readability, and ensures that the design adheres to good coding practices, reducing the risk of errors and making the design more maintainable.

## Features
- **SPI (Serial Peripheral Interface)**
- **I2C (Inter-Integrated Circuit)**
- **UART (Universal Asynchronous Receiver/Transmitter)**
- **CAN (Controller Area Network)**
- **TDM (Time-Division Multiplexing)**
- **Ethernet**
