// Multiplier with 3-cycle latency and single-start handshake

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

    /*
    Clock Enable signal allows the flip-flop in the multiplier to be registered.
    So, as long as clock enable is high, multiplier works?
    */

    unsigned_multiplier unsigned_multiplication (
        .CLK(clk),
        .CE(start || busy), // trying using signal "busy" instead of "start"
        .A(a),
        .B(b),
        .P(unsigned_multiplication_result)
    );

    signed_multiplier signed_multiplication (
        .CLK(clk),
        .CE(start || busy), // same as above
        .A(a),
        .B(b),
        .P(signed_multiplication_result)
    );

    mixed_multiplier mixed_multiplication (
        .CLK(clk),
        .CE(start || busy), // same as above
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
                count <= 2'd2; // wait for 3 cycles total
            end

            else if (busy) begin

                if (count != 0) begin
                    count <= count - 1;
                end

                else begin // count == 0

                    // Done this cycle
                    busy <= 1'b0;
                    count <= 2'b0;

                    // result <= signed_multiplication_result[31:0];

                    unique case (funct3)
                        3'b000: result <= signed_multiplication_result[31:0]; // mul
                        3'b001: result <= signed_multiplication_result[63:32]; // mulh
                        3'b010: result <= mixed_result;                       // mulhsu
                        3'b011: result <= unsigned_multiplication_result;     // mulhu
                        default: result <= 32'b0;
                    endcase

                end

            end

        end

    end

endmodule