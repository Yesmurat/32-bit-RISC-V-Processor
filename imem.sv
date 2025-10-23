`timescale 1ns/1ps

// memory depth = 1024

module imem (
            input logic clk,
            input logic enable,
            input logic [9:0] a,
            output logic [31:0] rd
    );

    instruction_memory instr_mem (
        .clka(clk),
        .ena(enable),
        .addra(a),
        .douta(rd)
    );

endmodule // Instruction memory