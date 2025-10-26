`timescale 1ns/1ps

// memory depth = 64

module imem (
        input logic [31:0] a,
        output logic [31:0] rd
    );

    logic [31:0] ROM[255:0];

    initial $readmemh("imem.mem", ROM);

    assign rd = ROM[a[31:2]];

endmodule // Instruction memory