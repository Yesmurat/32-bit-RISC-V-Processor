`timescale 1ns/1ps

// memory depth = 64

module dmem (

        // input logic clk,
        input logic we,
        input logic [3:0] byteEnable,
        input logic [31:0] a,
        input logic [31:0] wd,
        output logic [31:0] rd

    );

    logic [31:0] RAM[63:0];

    initial $readmemh("dmem.mem", RAM);
    assign rd = RAM[a[31:2]];

    always_comb begin
        
        if (we) begin
            if (byteEnable[0]) RAM[a[31:2]][7:0] <= wd[7:0];
            if (byteEnable[1]) RAM[a[31:2]][15:8] <= wd[15:8];
            if (byteEnable[2]) RAM[a[31:2]][23:16] <= wd[23:16];
            if (byteEnable[3]) RAM[a[31:2]][31:24] <= wd[31:24];
        end

    end

    // data_memory data_mem(
    //     .clk(clk)
    //     .a(a[5:0]), // 6-bit
    //     .d(wd), // 32-bit
    //     .we(we),
    //     .spo(rd) // 32-bit
    // );
    
endmodule // Data memory