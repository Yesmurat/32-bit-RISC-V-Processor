`timescale 1ns/1ps

module riscv (
    
    input logic clk,
    input logic reset,

    // inputs from Instruction and Data memories
    input logic [31:0] RD_instr, RD_data,

    // outputs to Instruction and Data memories
    output logic [31:0] PCF,
    output logic [31:0] ALUResultM, WriteDataM,
    output logic MemWriteM,
    output logic [3:0] byteEnable

    );

    // control signals
    logic RegWriteD;
    logic [2:0] ResultSrcD;
    logic MemWriteD;
    logic JumpD;
    logic BranchD;
    logic [3:0] ALUControlD;
    logic ALUSrcD;
    logic [2:0] ImmSrcD;
    logic SrcAsrcD;

    logic ResultSrcE_zero;

    // Hazard unit wires
    logic StallD, StallF;
    logic FlushD, FlushE;
    logic [1:0] ForwardAE, ForwardBE;
    logic PCSrcE;

    logic [4:0] Rs1D, Rs2D;
    logic [2:0] funct3D;
    logic [4:0] Rs1E, Rs2E, RdE;
    logic [4:0] RdM, RdW;
    logic RegWriteM, RegWriteW;
    logic MulBusy;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic jumpRegD;

    // ----------------------------

    controller controller (
        .op(opcode),
        .funct3(funct3),
        .funct7(funct7),
        
        .ResultSrcD(ResultSrcD),
        .RegWriteD(RegWriteD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUSrcD(ALUSrcD),
        .ImmSrcD(ImmSrcD),
        .SrcAsrcD(SrcAsrcD),
        .funct3D(funct3D),
        .jumpRegD(jumpRegD),

        .ALUControlD(ALUControlD)
    );

    datapath datapath (
        
                .clk(clk),
                .reset(reset),

                // Control signals
                .RegWriteD(RegWriteD),
                .ResultSrcD(ResultSrcD),
                .MemWriteD(MemWriteD),
                .JumpD(JumpD),
                .BranchD(BranchD),
                .ALUControlD(ALUControlD),
                .ALUSrcD(ALUSrcD),
                .ImmSrcD(ImmSrcD),
                .SrcAsrcD(SrcAsrcD),
                .funct3D(funct3D),
                .jumpRegD(jumpRegD),

                // inputs from Hazard unit
                .StallF(StallF),
                .StallD(StallD),
                .FlushD(FlushD),
                .FlushE(FlushE),
                .ForwardAE(ForwardAE),
                .ForwardBE(ForwardBE),

                // Memory inputs
                .RD_instr(RD_instr),
                .RD_data(RD_data),

                // outputs to Instruction and Data memories
                .PCF(PCF),
                .ALUResultM(ALUResultM),
                .WriteDataM(WriteDataM),
				.MemWriteM(MemWriteM),

                .opcode(opcode),
                .funct3(funct3),
                .funct7(funct7),

                .byteEnable(byteEnable),

                // outputs to Hazard unit
                .Rs1D(Rs1D),
                .Rs2D(Rs2D),
                .Rs1E(Rs1E),
                .Rs2E(Rs2E),
                .RdE(RdE),
                .PCSrcE(PCSrcE),
                .ResultSrcE_zero(ResultSrcE_zero),
                .RegWriteM(RegWriteM),
                .RegWriteW(RegWriteW),
                .RdM(RdM),
                .RdW(RdW),
                .MulBusy(MulBusy)
    );

    hazard hazard_unit (
        .Rs1D(Rs1D), .Rs2D(Rs2D),
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
        .PCSrcE(PCSrcE),
        .ResultSrcE_zero(ResultSrcE_zero),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .MulBusy(MulBusy),

        .StallF(StallF),
        .StallD(StallD), 
        .FlushD(FlushD),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );
    
endmodule