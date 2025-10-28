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
00200093 -> addi x1, x0, 2
ffd00113 -> addi x2, x0, -3
0220b233 -> mulh x3, x1, x2 -> upper 32 bits = 0xFFFFFFFF`x
ffd00213 -> addi x4, x0, -3
00200293 -> addi x5, x0, 2
02523333 -> mulhsu x6, x4, x5 -> upper 32 bits = 0xFFFFFFFF
fff00393 -> addi x7, x0, -1
00200413 -> addi x8, x0, 2
0283b433 -> mulhu x9, x7, x8 -> upper 32 bits = 0x00000001

*/