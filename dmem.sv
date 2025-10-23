`timescale 1ns/1ps

module dmem (
            input logic clk, we,
            input logic [3:0] byteEnable,
            input logic [9:0] a,
            input logic [31:0] wd,
            output logic [31:0] rd
    );

    data_memory data_mem (
        .clka(clk), // 1 bit
        .addra(a), // 10 bits
        .dina(wd), // 32 bits
        .douta(rd), // 32 bits
        .ena(1'b1), // 1 bit
        .wea(we ? byteEnable : 4'b0000) // 4 bits
    );
    
endmodule // Data memory