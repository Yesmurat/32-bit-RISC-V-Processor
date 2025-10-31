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
022081b3 = mul x3, x1, x2 -> x3 = -6
02209233 = mulh x4, x1, x2 -> x4 = -1
0220a2b3 = mulhsu x5, x1, x2 -> x5 = 1
0220b333 = mulhu x6, x1, x2 -> x6 = 1

*/