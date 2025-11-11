`timescale 1ns/1ps

module divider (
    input logic clk,
    input logic reset,
    input logic [2:0] funct3,
    input logic ex_is_div,
    input logic [31:0] a,
    input logic [31:0] b,
    
    output logic stall,
    output logic [31:0] result
);

    // Signals for signed division

    logic dividend_tvalid_s;
    logic dividend_tready_s;
    logic [31:0] dividend_tdata_s;

    logic divisor_tvalid_s;
    logic divisor_tready_s;
    logic [31:0] divisor_tdata_s;

    logic dout_tvalid_s;
    logic [63:0] div_result_s;

    // Signals for unsigned division

    logic dividend_tvalid_u;
    logic dividend_tready_u;
    logic [31:0] dividend_tdata_u;

    logic divisor_tvalid_u;
    logic divisor_tready_u;
    logic [31:0] divisor_tdata_u;

    logic dout_tvalid_u;
    logic [63:0] div_result_u;

    logic div_req_inflight;
    logic div_is_signed;

    always_ff @( posedge clk or posedge reset ) begin

        if (reset) begin

            div_req_inflight <= 1'b0;
            div_is_signed <= 1'b0;

            dividend_tvalid_s <= 1'b0;
            divisor_tvalid_s <= 1'b0;
            dividend_tdata_s <= 32'b0;
            divisor_tdata_s <= 32'b0;

            dividend_tvalid_u <= 1'b0;
            divisor_tvalid_u <= 1'b0;
            dividend_tdata_u <= 32'b0;
            divisor_tdata_u <= 32'b0;

            result <= 32'b0;

        end // on reset

        else begin

            // Start a new divide when ex_is_div goes high and no request is active
            if (ex_is_div && !div_req_inflight) begin
                
                div_req_inflight <= 1'b1;
                div_is_signed <= (funct3 == 3'b100 || funct3 == 3'b110);

                // assert tvalid for both signed and unsigned (maybe optimize to drive only one for power efficiency)
                dividend_tvalid_s <= 1'b1;
                divisor_tvalid_s <= 1'b1;

                dividend_tvalid_u <= 1'b1;
                divisor_tvalid_u <= 1'b1;

                dividend_tdata_s <= a;
                divisor_tdata_s <= b;
                dividend_tdata_u <= a;
                divisor_tdata_u <= b;

                // At this stage, stall other pipeline stages

            end

            // Handshake completion for signed
            if ( (dividend_tvalid_s && dividend_tready_s) &&
                (divisor_tvalid_s && divisor_tready_s) ) begin

                dividend_tvalid_s <= 1'b0;
                divisor_tvalid_s <= 1'b0;

            end

            // Handshake completion for unsigned
            if ( (dividend_tvalid_u && dividend_tready_u) &&
                (divisor_tvalid_u && divisor_tready_u) ) begin

                dividend_tvalid_u <= 1'b0;
                divisor_tvalid_u <= 1'b0;

            end

            // during division
            if (div_req_inflight) begin

                // latch the final result and unstall the pipeline stages

                // Collect result
                if (div_is_signed && dout_tvalid_s) begin
                    
                    unique case (funct3)
                        3'b100: result <= div_result_s[31:0]; // div
                        3'b110: result <= div_result_s[63:32]; // rem
                        default: result <= 32'b0;
                    endcase

                    div_req_inflight <= 1'b0;

                    // unstall the pipeline stages

                end

                else if (!div_is_signed && dout_tvalid_u) begin
                    
                    unique case (funct3)
                        3'b101: result <= div_result_u[31:0]; // divu
                        3'b111: result <= div_result_u[63:32]; // remu
                        default: result <= 32'b0;
                    endcase

                    div_req_inflight <= 1'b0;

                    // unstall the pipeline stages

                end

            end

        end
            
    end

    // stall logic
    always_comb begin

        stall = 0;

        if (ex_is_div && !div_req_inflight) stall = 1;
        else if (div_req_inflight) stall = 1;
        else if (dout_tvalid_s || dout_tvalid_u || reset) stall = 0;

    end

    signed_divider signed_div (
        .aclk                   (clk),
        .aclken                 (ex_is_div),
        .aresetn                (~reset),

        .s_axis_dividend_tvalid (dividend_tvalid_s),
        .s_axis_divisor_tvalid  (divisor_tvalid_s),

        .s_axis_dividend_tdata  (dividend_tdata_s),
        .s_axis_divisor_tdata   (divisor_tdata_s),

        .s_axis_dividend_tready (dividend_tready_s),
        .s_axis_divisor_tready  (divisor_tready_s),

        .m_axis_dout_tvalid     (dout_tvalid_s),
        .m_axis_dout_tdata      (div_result_s) // {remainder, quotient}
    );

    unsigned_divider unsigned_div (
        .aclk                   (clk),
        .aclken                 (ex_is_div),
        .aresetn                (~reset),

        .s_axis_dividend_tvalid (dividend_tvalid_u),
        .s_axis_divisor_tvalid  (divisor_tvalid_u),

        .s_axis_dividend_tdata  (dividend_tdata_u),
        .s_axis_divisor_tdata   (divisor_tdata_u),

        .s_axis_dividend_tready (dividend_tready_u),
        .s_axis_divisor_tready  (divisor_tready_u),

        .m_axis_dout_tvalid     (dout_tvalid_u),
        .m_axis_dout_tdata      (div_result_u) // {remainder, quotient}
    );
    
endmodule