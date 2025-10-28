// Multiplier with 3-cycle latency and single-start handshake

/*
Clock Enable signal allows the flip-flop in the multiplier to be registered. So, as long as clock enable is high, multiplier works.
Our multiplier is 3 cycles long. On cycle 3, it outputs the product.

How multiplier works: on cycle 0 multipication start; on cycle 1 multiplication still works;
on cycle 2 product is product is produced

How it should it work between EX and MEM stages:
    Cycle 0: multiplication is issued; start = 1; count = 0
    Cycle 1: start = 0; count = 2
    Cycle 2: count = 1; multiplication result is available and is chosen based on funct3
    Cycle 3: count = 0; multiplication result goes to MEM stage
*/

`timescale 1ns/1ps

module multiplier(

    input logic         clk,
    input logic         reset,
    input logic         start, // 1-cycle pulse
    input logic [2:0]   funct3,
    input logic [31:0]  a, b,
    output logic [31:0] result,
    output logic        busy
    
);

    logic [1:0] count; // 3-cycle counter
    logic [63:0] signed_multiplication_result;
    logic [31:0] unsigned_multiplication_result, mixed_result;

    unsigned_multiplier unsigned_multiplication (
        .CLK(clk),
        .CE(start || busy),
        .A(a),
        .B(b),
        .P(unsigned_multiplication_result)
    );

    signed_multiplier signed_multiplication (
        .CLK(clk),
        .CE(start || busy),
        .A(a),
        .B(b),
        .P(signed_multiplication_result)
    );

    mixed_multiplier mixed_multiplication (
        .CLK(clk),
        .CE(start || busy),
        .A(a),
        .B(b),
        .P(mixed_result)
    );

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            busy <= 1'b0;
            count <= 2'b0;
            result <= 32'b0;
        end

        else begin

            if (start && !busy) begin

                // Launch new multiplication
                busy <= 1'b1;
                count <= 2'd2;

            end

            else if (busy) begin

                unique case (count)

                    2'd2: count <= count -1;

                    2'd1: begin
                        // unique case (funct3)
                        //     3'b000: result <= signed_multiplication_result[31:0];
                        //     3'b001: result <= signed_multiplication_result[63:32];
                        //     3'b010: result <= mixed_result;
                        //     3'b011: result <= unsigned_multiplication_result;
                        //     default: result <= 32'b0;
                        // endcase

                        count <= count - 1;
                    end
                    
                endcase

            end

        end

    end

    always_comb begin
        if (count == 2'b0) begin
            unique case (funct3)
                3'b000: result = signed_multiplication_result[31:0];
                3'b001: result = signed_multiplication_result[63:32];
                3'b010: result = mixed_result;
                3'b011: result = unsigned_multiplication_result;
                default: result = 32'b0;
            endcase

        busy = 1'b0;
        end
    end

endmodule