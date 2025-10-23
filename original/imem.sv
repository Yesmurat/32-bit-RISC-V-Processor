// memory depth 32 => only 32 instructions can be loaded

module imem (
            input logic clk,
            input logic enable,
            input logic [31:0] a,
            output logic [31:0] rd
    );

    instruction_memory instr_mem (
        .clka(clk),
        .ena(enable),
        .addra(a[4:0]),
        .douta(rd)
    );

endmodule // Instruction memory