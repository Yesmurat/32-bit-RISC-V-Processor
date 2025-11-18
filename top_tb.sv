`timescale 1ns/1ps

module top_tb;

    localparam CLK_PERIOD = 10;

    logic clk;
    logic reset;

    top dut(
        .clk(clk),
        .reset(reset)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        reset = 1;
        #7;
        reset = 0;
        #1000;
        $stop;
    end

endmodule