# Asynchronous-FIFO
Asynchronous FIFO for CDC using gray code pointers. Handles metastability , verified in verilog
# Asynchronous FIFO

Parameterizable dual-clock FIFO for Clock Domain Crossing (CDC).

## Overview
Functional simulation of async FIFO using Gray-coded pointers and 2-stage synchronizers to safely transfer data between independent clock domains.

## Features
- **Dual Clock Domains**: Separate `wr_clk` and `rd_clk`
- **Gray Code Pointers**: Prevents multi-bit CDC errors
- **2-FF Synchronizers**: For `wptr` and `rptr` domain crossing
- **Status Flags**: `full`, `empty`, `almost_full`, `almost_empty`
- **Parameterizable**: `DATA_WIDTH`, `FIFO_DEPTH`
- **Self-Checking Testbench**: Verifies simultaneous read/write

## Tools & Verification
- **Language**: Verilog HDL
- **Simulator**: Vivado 2023.1 xsim
- **Verification**: Functional simulation only

## File Structure
asynchronous-fifo/
├── README.md
├── async_fifo.v
├── tb_async_fifo.v
└── waveforms/
    ├── fifo_dual_clock_cdc.png
    └── fifo_flags_full_empty.png
