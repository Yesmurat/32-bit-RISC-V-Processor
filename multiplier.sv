`timescale 1ns/1ps

module multiplier(

    input logic         clk,
    input logic         reset,
    input logic         start,
    input logic [2:0]   funct3,
    input logic [31:0]  a, b,
    output logic [31:0] result,
    output logic        busy
    
);

    logic [1:0] count; // counts 0..2 for 3-cycle latency
    logic [63:0] signed_multiplication_result;
    logic [31:0] unsigned_multiplication_result, mixed_result;

    unsigned_multiplier unsigned_multiplication (
        .CLK(clk),
        .CE(start),
        .A(a),
        .B(b),
        .P(unsigned_multiplication_result)
    );

    signed_multiplier signed_multiplication (
        .CLK(clk),
        .CE(start),
        .A(a),
        .B(b),
        .P(signed_multiplication_result)
    );

    mixed_multiplier mixed_multiplication (
        .CLK(clk),
        .CE(start),
        .A(a),
        .B(b),
        .P(mixed_result)
    );

        always_ff @(posedge clk) begin

        if (reset) begin

            count <= 2'b0;
            busy <= 1'b0;

        end

        else begin

            if (start && !busy) begin
                // Start new multiplication
                busy <= 1'b1;
                count <= 2'd2; // run for 3 cycles total
            end

            else if (busy) begin

                if (count == 0) begin
                    busy <= 1'b0; // multiplication done
                end

                else
                    count <= count - 2'd1;
            end

        end

        // Select the final result
        if (!busy && (count == 0)) begin // when multiplication is done

            unique case (funct3)

                3'b000: result <= signed_multiplication_result[31:0]; // mul

                3'b001: result <= signed_multiplication_result[63:32]; // mulh

                3'b010: result <= mixed_result; // mulhsu
                
                3'b011: result <= unsigned_multiplication_result; // mulhu

                default: result <= 32'b0;
                
            endcase

        end

    end

endmodule