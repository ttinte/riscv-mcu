# RISC-V MCU

An educational softcore RISC-V microcontroller for FPGA, written in SystemVerilog.

## Current features

- Multi-cycle RV32I subset core with memory handshake, byte/halfword/word
  load/store support, and halt-on-error handling for illegal instructions,
  misaligned accesses and bus errors.
- 32 KiB synchronous RAM with byte write enables and optional firmware
  initialization, intended for FPGA block RAM inference.
- APB master bridge and configurable interconnect with address decoding,
  slave response multiplexing and errors for unmapped accesses.
- APB UART with 8N1 TX/RX, independent FIFOs and a polling C driver.
  SoC defaults: 70 MHz clock, 115200 baud and FIFO depth of 32 bytes per direction.

## Memory map

| Region | Address range (inclusive) | Size |
| --- | --- | --- |
| RAM | `0x00000000`–`0x00007FFF` | 32 KiB |
| APB window | `0x80000000`–`0x8000FFFF` | 64 KiB |
| UART slot | `0x80000000`–`0x80000FFF` | 4 KiB |

UART register offsets: TX `0x00`, RX `0x04`, STATUS `0x08`.
STATUS bit 0 is TX-full; bit 1 is RX-empty.
The APB window reserves address space, not physical RAM.

## Simulation

Simulation is set up for Questa/ModelSim.

## Firmware status

The repository currently includes the UART driver, SoC definitions, build rules
and binary-to-memory-image converter. Startup code, the linker script,
application sources and SoC/core simulation filelists are not included yet.

## Acknowledgments

* The UART RX hierarchy was inspired by the Xilinx XUP "FPGA Design Flow using Vivado" teaching material.
* No Xilinx source files are redistributed in this repository. The RTL implementation was rewritten independently in SystemVerilog for educational use.
