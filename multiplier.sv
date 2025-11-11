`timescale 1ns/1ps

module multiplier(

    input logic             clk,
    input logic             reset,
    input logic             ce,
    input logic  [2:0]      funct3,
    input logic  [31:0]     a, b,

    output logic [31:0]     result,
    output logic            stall
    
);

    logic [63:0] signed_multiplication_result;
    logic [31:0] unsigned_multiplication_result;
    logic [31:0] mixed_result;
    logic busy;

    typedef enum logic [1:0] { IDLE, S0, S1, S2} state_t;
    state_t state, next_state;

    // state transition
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end

    // next state logic
    always_comb begin

        next_state = state;
        stall = 0;

        unique case (state)

            IDLE: if (ce) begin
                next_state = S0;
                stall = 1;
            end

            S0: begin
                next_state = S1;
                stall = 1;
            end

            S1: begin
                next_state = S2;
                stall = 1;
            end

            S2: begin
                next_state = IDLE;
                stall = 0;
            end

            default: begin
                next_state = IDLE;
                stall = 0;
            end
        endcase

    end

    assign busy = (state == S0) || (state == S1) || (state == S2);

    unsigned_multiplier unsigned_multiplication (
        .CLK(clk),
        .CE(ce || busy),
        .A(a),
        .B(b),
        .P(unsigned_multiplication_result)
    );

    signed_multiplier signed_multiplication (
        .CLK(clk),
        .CE(ce || busy),
        .A(a),
        .B(b),
        .P(signed_multiplication_result)
    );

    mixed_multiplier mixed_multiplication (
        .CLK(clk),
        .CE(ce || busy),
        .A(a),
        .B(b),
        .P(mixed_result)
    );

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