// Top module of RV32IM RISC-V processor in SystemVerilog
//

module top (

    input logic clk,
    input logic reset,
    output logic [31:0] pc_out,
    output logic [31:0] rd_instr,
    output logic memwritem,
    output logic [31:0] writedatam

    );

    logic [31:0] ALUResultM
    logic [31:0] PCF;
    logic [31:0] RD_instr;
    logic [31:0] RD_data;
    logic WriteDataM;
    logic MemWriteM;
    logic [3:0]  byteEnable;
    logic        StallF;

    assign pc_out =     PCF;
    assign rd_instr =   RD_instr;
    assign memwritem =  MemWriteM;
    assign writedatam = WriteDataM;

    riscv core (
        .clk(clk),
        .reset(reset),
        .RD_instr(RD_instr),
        .RD_data(RD_data),
        .PCF(PCF),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .MemWriteM(MemWriteM),
        .byteEnable(byteEnable),
        .StallF(StallF)
    );

    imem instr_mem (
        .clk(clk),
        .enable(~StallF),
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