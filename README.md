# RV32IM Pipelined RISC-V Processor

## Overview

This repository contains a **custom RV32IM RISC-V processor** implemented in **SystemVerilog**.  
The design follows a **5-stage, in-order, single-issue pipeline** and is intended for **FPGA-based implementation and experimentation**.

The project emphasizes:
- clean RTL structure
- correct pipeline control
- hazard detection and forwarding
- timing-aware design choices suitable for FPGA synthesis

---

## Features

- **ISA**: RISC-V RV32I + M extension (integer multiplication & division)
- **Pipeline**: 5 stages (IF / ID / EX / MEM / WB)
- **Execution model**: In-order, single-issue
- **Language**: SystemVerilog (fully synthesizable)
- **Target**: FPGA (Vivado-compatible)
- **Separate instruction and data memories (Harvard Architecture)**
- **Forwarding and stall logic**
- **Multiply and divide support**

---

## Supported Instructions

### RV32I
- Arithmetic / logic: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT`, `SLTU`
- Immediate: `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`, `SLTIU`
- Shifts: `SLL`, `SRL`, `SRA`, `SLLI`, `SRLI`, `SRAI`
- Loads: `LB`, `LH`, `LW`, `LBU`, `LHU`
- Stores: `SB`, `SH`, `SW`
- Branches: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- Jumps: `JAL`, `JALR`
- Upper immediates: `LUI`, `AUIPC`

### M Extension
- Multiply: `MUL`, `MULH`, `MULHSU`, `MULHU`
- Divide: `DIV`, `DIVU`
- Remainder: `REM`, `REMU`

---

## Microarchitecture

### Pipeline Stages

1. **IF – Instruction Fetch**
   - Program counter (PC) logic
   - Instruction memory access
   - PC + 4 calculation

2. **ID – Instruction Decode**
   - Instruction decoding
   - Register file read
   - Immediate generation
   - Hazard detection and stall control

3. **EX – Execute**
   - ALU operations
   - Branch comparisons
   - Multiply/divide unit
   - Forwarding paths

4. **MEM – Memory Access**
   - Data memory reads/writes
   - Load/store handling

5. **WB – Write Back**
   - Write-back to register file
   - Result selection (ALU, memory, PC+4)

---

## Hazard Handling

- **Data hazards**
  - Forwarding from EX/MEM and MEM/WB
  - Stall insertion for load-use hazards
- **Control hazards**
  - Branch resolution in EX stage
  - Pipeline flush on taken branches and jumps
- **Structural hazards**
  - Avoided via separate instruction and data memories

---

## Memory System

- **Instruction Memory**
  - Read-only
  - Supports combinational or 1-cycle synchronous access
- **Data Memory**
  - Read/write
  - Byte-enable support for load/store instructions
- **Initialization**
  - Program loaded via `.mem` files for simulation and FPGA deployment

---

## Register File

- 32 × 32-bit registers
- Register `x0` hardwired to zero
- Two read ports, one write port
- Combinational read, synchronous write

---

## Directory Structure
```
.
├── main
│   ├── core/
│   │   ├── aludec.sv
│   │   ├── blocks.sv
│   │   ├── controller.sv
│   │   ├── datapath.sv
│   │   ├── extend.sv
│   │   ├── hazard.sv
│   │   └── loadext.sv
│   │   ├── maindec.sv
│   │   ├── multiplier.sv
│   │   ├── registers.sv
│   │   ├── riscv.sv
│   ├── memory/
│   │   ├── imem.sv
│   │   └── dmem.sv
│   └── top.sv
|
├── sim/
│   ├── top_tb.sv
|
├── constraints/
│   └── constraints.xdc
|
└── README.md
```

---

## Simulation

- Tested using **Vivado Simulator**
- Cycle-accurate simulation of:
  - pipeline flow
  - stalls and forwarding
  - branch and jump behavior
  - multiply/divide operations


---

## FPGA Implementation

- Tested on:
  - Xilinx Arty S7-25
  - Xilinx Zybo Z7-10
- Clock frequency configurable via XDC constraints
- Fully synthesizable using Vivado

---

## Verification

- Hand-written RISC-V assembly programs
- Validation of:
  - arithmetic correctness
  - hazard resolution
  - control flow instructions
  - M-extension corner cases

---

## Limitations

- No caches
- No virtual memory or MMU
- No exceptions or interrupts
- No branch prediction
- No out-of-order execution

---

## Future Work

- Instruction and data caches
- Branch prediction
- CSR support
- Exception and interrupt handling
- Performance counters
- Microarchitectural optimizations

---

## References

- *The RISC-V Instruction Set Manual, Volume I*
- *Digital Design and Computer Architecture*

---

## Author

**Yesmurat Sagyndyk**  
Electrical Engineering — FPGA / RTL / Computer Architecture  
GitHub: https://github.com/yesmurat

