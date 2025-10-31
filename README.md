# RV32IM Processor on Arty S7-25 FPGA board.

The processor uses Vivado Multiplier IP for multiplication.\n
The design currently supports 3-cycle multiplication.\n
The following multiplication instrcutions are supported:
  1. `mul rd, rs1, rs2`
  2. `mulh rd, rs1, rs2`
  3. `mulhsu rd, rs1, rs2`
  4. `mulhu rd, rs1, rs2`

Note: this is a work in progress...
