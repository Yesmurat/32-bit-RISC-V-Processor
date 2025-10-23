`timescale 1ns/1ps

module top_tb;

    localparam CLK_PERIOD = 10;

    logic clk;
    logic reset;
    logic [31:0] pc_out;
    logic [31:0] rd_instr;
    logic memwritem;
    logic [31:0] writedatam;

    top dut(
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .rd_instr(rd_instr),
        .memwritem(memwritem),
        .writedatam(writedatam)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        reset = 1;
        #15;
        reset = 0;
    end

    initial begin
        #300;
        $stop;
    end

endmodule