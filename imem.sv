`timescale 1ns/1ps

// memory depth = 64

module imem (

        // input logic clk,
        // input logic reset,
        input logic [31:0] a,
        
        output logic [31:0] rd

    );

    logic [31:0] ROM[63:0];

    initial $readmemh("imem.mem", ROM);

    assign rd = ROM[a[31:2]];

    // instruction_memory instr_mem(
    //     .clk(clk),
    //     .a(a[5:0]), // 6-bit
    //     .d(32'b0), // 32-bit
    //     .we(1'b0),
    //     .qspo_rst(reset),
    //     .qspo(rd) // 32-bit
    // );

endmodule // Instruction memory