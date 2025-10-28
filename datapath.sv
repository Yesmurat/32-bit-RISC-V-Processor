`timescale 1ns/1ps

module datapath (

    input logic clk,
    input logic reset,

    // Control signals
    input logic RegWriteD,
    input logic [2:0] ResultSrcD,
    input logic MemWriteD,
    input logic JumpD,
    input logic BranchD,
    input logic [3:0] ALUControlD,
    input logic ALUSrcD,
    input logic [2:0] ImmSrcD,
    input logic SrcAsrcD,
    input logic [2:0] funct3D,
    input logic jumpRegD,
                
    // inputs from Hazard Unit
    input logic StallF, StallD,
    input logic FlushD, FlushE,
    input logic [1:0] ForwardAE, ForwardBE,

    // inputs from memories
    input logic [31:0] RD_instr,
    input logic [31:0] RD_data,

    // outputs to instruction and data memories
    output logic [31:0] PCF, // input to Instruction Memory
    output logic [31:0] ALUResultM, WriteDataM, // inputs to Data Memory
    output logic MemWriteM, // we signal to data memory

    // inputs to Control Unit
    output logic [6:0] opcode,
    output logic [2:0] funct3,
    output logic [6:0] funct7,

    output logic [3:0] byteEnable, // input to data memory

    // outputs to Hazard Unit
    output logic [4:0] Rs1D, Rs2D, // outputs from ID stage
    output logic [4:0] Rs1E, Rs2E,
    output logic [4:0] RdE, // outputs from EX stage
    output logic PCSrcE, ResultSrcE_zero, RegWriteM, RegWriteW,
    output logic [4:0] RdM, // output from MEM stage
    output logic [4:0] RdW, // output from WB stage
    output logic MulBusy

);

    // PC mux
    logic [31:0] PCPlus4F;
    logic [31:0] PCTargetE, PCF_new;

    mux2 pcmux(
        .d0(PCPlus4F),
        .d1(PCTargetE),
        .s(PCSrcE),
        .y(PCF_new)
    );

    // Instruction Fetch (IF) stage
    IFregister ifreg(
        .clk(clk),
        .en(~StallF),
        .reset(reset),
        .d(PCF_new),
        .q(PCF)
    );

    // Instruction Decode (ID) stage
    logic [31:0] PCD, PCPlus4D;
    logic [31:0] RD1, RD2;
    logic [31:0] ResultW;
    logic [31:0] ImmExtD;
    logic [4:0] RdD;
    logic [31:0] InstrD;

    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD = InstrD[11:7];

    assign opcode = InstrD[6:0];
    assign funct3 = InstrD[14:12];
    assign funct7 = InstrD[31:25];

    assign PCPlus4F = PCF + 32'd4;

    IFIDregister ifidreg(
        .clk(clk),
        .reset(FlushD | reset),
        .en(~StallD),
        .RD_instr(RD_instr),
        .PCF(PCF),
        .PCPlus4F(PCPlus4F),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

    regfile rf(
        .clk(clk),
        .we3(RegWriteW),
        .reset(reset),
        .a1(Rs1D),
        .a2(Rs2D),
        .a3(RdW),
        .wd3(ResultW),
        .rd1(RD1),
        .rd2(RD2)
    );

    extend ext(
        .instr_31_7(InstrD[31:7]),
        .immsrc(ImmSrcD),
        .immext(ImmExtD)
    );

    // Execute (EX) stage
    logic [31:0] RD1E, RD2E, PCE;
    logic [31:0] ImmExtE;
    logic [31:0] PCPlus4E;

    logic [31:0] SrcAE, SrcBE;
    logic [31:0] WriteDataE;
    logic [31:0] ALUResultE;
    logic SrcAsrcE, ALUSrcE;

    logic RegWriteE;
    logic [2:0] ResultSrcE;
    logic MemWriteE, JumpE, BranchE;
    logic [3:0] ALUControlE;
    logic [2:0] funct3E;
    logic branchTakenE;
    logic jumpRegE;

    logic en_idex, en_exmem;

    IDEXregister idexreg(
        .clk(clk),
        .en(en_idex),
        .reset(FlushE | reset),
        // ID stage control signals
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .SrcAsrcD(SrcAsrcD),
        .funct3D(funct3D),
        .jumpRegD(jumpRegD),

        // EX stage control signals
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .SrcAsrcE(SrcAsrcE),
        .funct3E(funct3E),
        .jumpRegE(jumpRegE),

        // datapath inputs & outputs
        .RD1(RD1), .RD2(RD2), .PCD(PCD),
        .Rs1D(Rs1D), .Rs2D(Rs2D), .RdD(RdD),
        .ImmExtD(ImmExtD),
        .PCPlus4D(PCPlus4D),

        .RD1E(RD1E), .RD2E(RD2E), .PCE(PCE),
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E)
    );

    assign PCSrcE = (BranchE & branchTakenE) | JumpE;
    assign ResultSrcE_zero = ResultSrcE[0];
    logic [31:0] SrcAE_input1;

    // SrcA muxes
    
    mux3 SrcAE_input1mux(
        .d0(RD1E),
        .d1(ResultW),
        .d2(ALUResultM),
        .s(ForwardAE),
        .y(SrcAE_input1)
    );

    mux2 SrcAEmux(
        .d0(SrcAE_input1),
        .d1(PCE),
        .s(SrcAsrcE),
        .y(SrcAE)
    );

    // SrcB muxes
    
    mux3 WriteDataEmux(
        .d0(RD2E),
        .d1(ResultW),
        .d2(ALUResultM),
        .s(ForwardBE),
        .y(WriteDataE)
    );

    mux2 SrcBEmux(
        .d0(WriteDataE),
        .d1(ImmExtE),
        .s(ALUSrcE),
        .y(SrcBE)
    );

    branch_unit bu(
        .SrcAE(SrcAE), .SrcBE(SrcBE),
        .funct3E(funct3E),
        .branchTakenE(branchTakenE)
    );

    logic [31:0] adder_base;
    assign adder_base = jumpRegE ? SrcAE_input1 : PCE;

    assign PCTargetE = adder_base + ImmExtE;

    ALU alu(
        .d0(SrcAE),
        .d1(SrcBE),
        .s(ALUControlE),
        .y(ALUResultE)
    );

    // Multiplier Interface
    logic [31:0] multiplier_resultE;
    logic        mul_busy;
    logic        ex_is_mul;
    logic        mul_issue;
    logic        mul_issue_d;

    // Detect and issue multiplication
    assign ex_is_mul = ResultSrcE[2];

    // Generate a one-cycle pulse on rising edge of mul_issue
    always_ff @(posedge clk or posedge reset) begin
        if (reset) mul_issue_d <= 1'b0;
        else mul_issue_d <= ex_is_mul & ~mul_busy;
    end

    assign mul_issue = (ex_is_mul & ~mul_busy) & ~mul_issue_d; 

    multiplier multiplier(
       .clk(clk),
       .start(mul_issue),
       .reset(reset),
       .funct3(funct3E),
       .a(SrcAE),
       .b(SrcBE),
       .result(multiplier_resultE),
       .busy(mul_busy)
   );

   assign MulBusy = mul_busy;

   assign en_idex = ~mul_busy && ~mul_issue;
   assign en_exmem = ~mul_busy && ~mul_issue;

    // Memory write (MEM) stage
    logic [31:0] PCPlus4M;
    logic [2:0] funct3M;
    logic [2:0] ResultSrcM;
    logic [1:0] byteAddrM;
    logic [31:0] load_data;
    logic [31:0] ImmExtM;
    logic [31:0] multiplier_resultM;

    assign byteAddrM = ALUResultM[1:0];

    EXMEMregister exmemreg(
        .clk(clk),
        .en(en_exmem),
        .reset(reset),
        // EX stage control signals
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .funct3E(funct3E),

        // MEM stage control signals
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .funct3M(funct3M),

        // datapath inputs & outputs
        .ALUResultE(ALUResultE),
        .WriteDataE(WriteDataE),
        .RdE(RdE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E),
        .multiplier_resultE(multiplier_resultE),

        .ALUResultM(ALUResultM), // output to Data Memory
        .WriteDataM(WriteDataM),
        .RdM(RdM),
        .ImmExtM(ImmExtM),
        .PCPlus4M(PCPlus4M),
        .multiplier_resultM(multiplier_resultM)
    );

    // byte loads
    always_comb begin

        unique case (funct3M) // funct3 determines store type

            3'b000: unique case (byteAddrM)

                2'b00: byteEnable = 4'b0001; // enable byte 0
                2'b01: byteEnable = 4'b0010; // enable byte 1
                2'b10: byteEnable = 4'b0100; // enable byte 2
                2'b11: byteEnable = 4'b1000; // enable byte 3

            endcase

            3'b001: byteEnable = (byteAddrM[1] == 0) // sh
                                    ? 4'b0011 // low half
                                    : 4'b1100; // high half

            3'b010: byteEnable = 4'b1111;

            default: byteEnable = 4'b0;
            
        endcase
    end

    loadext loadext(
        .LoadTypeM(funct3M),
        .RD_data(RD_data),
        .byteAddrM(byteAddrM),
        .load_data(load_data)
    );

    // Register file writeback (WB) stage
    logic [31:0] ALUResultW;
    logic [31:0] ReadDataW;
    logic [31:0] PCPlus4W;
    logic [31:0] ImmExtW;
    logic [2:0] ResultSrcW;
    logic [31:0] multiplier_resultW;

    MEMWBregister wbreg(
        .clk(clk),
        .reset(reset),
        
        // MEM stage control signals
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),

        // WB stage control signals
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),

        // datapath inputs & outputs
        .ALUResultM(ALUResultM),
        .load_data(load_data),
        .RdM(RdM),
        .ImmExtM(ImmExtM),
        .PCPlus4M(PCPlus4M),
        .multiplier_resultM(multiplier_resultM),

        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .RdW(RdW),
        .ImmExtW(ImmExtW),
        .PCPlus4W(PCPlus4W),
        .multiplier_resultW(multiplier_resultW)
    );

    mux5 ResultWmux(
        .d0(ALUResultW),
        .d1(ReadDataW),
        .d2(PCPlus4W),
        .d3(ImmExtW),
        .d4(multiplier_resultW),
        .s(ResultSrcW),
        .y(ResultW)
    );

endmodule