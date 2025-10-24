`timescale 1ns/1ps

// memory depth = 64

module imem (

        input logic [31:0] a,
        output logic [31:0] rd

    );

    (* rom_style="block", ram_init_file="imem.mem" *) logic [31:0] ROM[63:0];

    assign rd = ROM[a[31:2]];

endmodule // Instruction memory