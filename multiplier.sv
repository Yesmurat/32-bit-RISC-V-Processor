`timescale 1ns/1ps

module multiplier(

    input logic         clk,
    input logic         reset,
    input logic         ce,
    input logic [2:0]   funct3,
    input logic [31:0]  a, b,
    output logic [31:0] result,
    output logic        busy
    
);

    logic [1:0] count; // 3-cycle counter
    logic [63:0] signed_multiplication_result;
    logic [31:0] unsigned_multiplication_result, mixed_result;

    localparam S0, S1, S2, S3;

    unsigned_multiplier unsigned_multiplication (
        .CLK(clk),
        .CE(ce || busy),
        .A(a),
        .B(b),
        .P(unsigned_multiplication_result)
    );

    signed_multiplier signed_multiplication (
        .CLK(clk),
        .CE(ce | busy),
        .A(a),
        .B(b),
        .P(signed_multiplication_result)
    );

    mixed_multiplier mixed_multiplication (
        .CLK(clk),
        .CE(ce | busy),
        .A(a),
        .B(b),
        .P(mixed_result)
    );

    always_ff @( posedge clk ) begin : counter
        
        if (reset) begin
            count <= 2'b0;
            result <= 32'b0;
            busy <= 1'b0;
        end

        else if (ce) begin

            busy <= 1'b1;
            count <= count + 1;

        end

    end

    always_comb begin
        
        unique case (funct3)

            3'b000: result = signed_multiplication_result[31:0];
            3'b001: result = signed_multiplication_result[63:32];
            3'b010: result = mixed_result;
            3'b011: result = unsigned_multiplication_result;
            default: result = 32'b0;

        endcase

    end

endmodule