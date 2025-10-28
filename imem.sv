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

/*

00200093 = addi x1, x0, 2 -> x1 = 2
ffd00113 = addi x2, x0, -3 -> x2 = -3
022091b3 = mulh x3, x1, x2 -> upper 32 bits = 0xFFFFFFFF

*/