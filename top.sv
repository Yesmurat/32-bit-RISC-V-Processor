// Top module of RV32IM RISC-V processor in SystemVerilog
// Author: Yesmurat Sagyndyk
// Date: 10/10/2025

`timescale 1ns/1ps

module top (

        input logic clk,
        input logic reset,
        output logic [3:0] pc_out
        // output logic [31:0] rd_instr,
        // output logic memwritem,
        // output logic [31:0] writedatam

);

    logic [31:0] ALUResultM, PCF, RD_instr, RD_data, WriteDataM;
    logic [3:0]  byteEnable;
    logic        MemWriteM;

    assign pc_out =     PCF[3:0];
    // assign rd_instr =   RD_instr;
    // assign memwritem =  MemWriteM;
    // assign writedatam = WriteDataM;

    riscv core (
        .clk(clk),
        .reset(reset),
        .RD_instr(RD_instr),
        .RD_data(RD_data),
        .PCF(PCF),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .MemWriteM(MemWriteM),
        .byteEnable(byteEnable)
    );

    imem instr_mem (
        .a(PCF),
        .rd(RD_instr)
    );

    dmem data_mem (
        .clk(clk),
        .we(MemWriteM),
        .byteEnable(byteEnable),
        .a(ALUResultM),
        .wd(WriteDataM),
        .rd(RD_data)
    );
    
endmodule