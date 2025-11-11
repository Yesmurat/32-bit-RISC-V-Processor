`timescale 1ns/1ps

// Instruction Memory 64 words x 32

module imem (
        input logic [31:0] a,
        output logic [31:0] rd
    );

    logic [31:0] ROM[255:0];

    initial $readmemh("imem.mem", ROM);

    assign rd = ROM[a[31:2]];

endmodule // Instruction memory

/*

01400093 = addi x1, x0, 20 -> x1 = 20
00500113 = addi x2, x0, 5 -> x2 = 5
0220d1b3 = divu x3, x1, x2 -> x3 = 4
ffc00213 = addi x4, x0, -4 -> x4 = -4
0240c2b3 = div x5, x1, x4 -> x5 = -5

*/