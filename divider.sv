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

    // signed/unsigned division signals

    logic dividend_tvalid_s, dividend_tvalid_u;
    logic dividend_tready_s, dividend_tready_u;
    logic [31:0] dividend_tdata_s, dividend_tdata_u;

    logic divisor_tvalid_s, divisor_tvalid_u;
    logic divisor_tready_s, divisor_tready_u;
    logic [31:0] divisor_tdata_s, divisor_tdata_u;

    logic dout_tvalid_s, dout_tvalid_u;
    logic [63:0] div_result_s, div_result_u;

    logic div_req_inflight;
    logic div_is_signed;

    logic post_stall;

    // current problem is that stall logic doesn't work because ex_is_div is always high during division
    // When div_req_inflight goes to 0 after dout_tvalid_u is asserted, ex_is_div is still asserted
    // resulting new division

    // I need to create a signal (ex_is_div_int) which would behave exactly like ex_is_div and become 0 
    // at the time when post_stall is 1 and div_req_inflight is 0.

    logic ex_is_div_int;
    assign ex_is_div_int = (!reset && !post_stall) ? ex_is_div : 1'b0;

    // stall logic
    always_comb begin

        // on reset
        if (reset) begin
            stall = 0;
        end

        else if (post_stall) begin
            // one cycle after result: no stall, but also no new division because ex_is_div_int = 0
            stall = 0;
        end

        else if ( (ex_is_div_int && !div_req_inflight) || div_req_inflight ) begin
            stall = 1;
        end

        else begin
            stall = 0;
        end
        
    end

    always_ff @(posedge clk or posedge reset) begin // request control

        if (reset) begin
            div_req_inflight <= 1'b0;
            div_is_signed <= 1'b0;
        end

        else begin
            
            if (ex_is_div_int && !div_req_inflight) begin // on new division
            
                div_req_inflight <= 1'b1;
                div_is_signed <= (funct3 == 3'b100 || funct3 == 3'b110);

            end

            if ( (div_is_signed && dout_tvalid_s) // when signed division result is available
                || (!div_is_signed && dout_tvalid_u) ) begin // when unsigned division result is available

                    div_req_inflight <= 1'b0;

                end

        end
        
    end

    always_ff @(posedge clk or posedge reset) begin // signed divider handshake + tvalid/tdata

        if (reset) begin
            dividend_tvalid_s <= 1'b0;
            divisor_tvalid_s <= 1'b0;
            dividend_tdata_s <= 0;
            divisor_tdata_s <= 0;
        end

        else begin
            if (ex_is_div_int && !div_req_inflight) begin // on new division
                dividend_tvalid_s <= 1'b1;
                divisor_tvalid_s <= 1'b1;
                dividend_tdata_s <= a;
                divisor_tdata_s <= b;
            end

            else if (dividend_tvalid_s && dividend_tready_s &&
                    divisor_tvalid_s && divisor_tready_s) begin
                        dividend_tvalid_s <= 1'b0;
                        divisor_tvalid_s <= 1'b0;
                    end
        end
        
    end

    always_ff @(posedge clk or posedge reset) begin // unsigned divider handshake + tvalid/tdata

        if (reset) begin
            dividend_tvalid_u <= 1'b0;
            divisor_tvalid_u <= 1'b0;
            dividend_tdata_u <= 0;
            divisor_tdata_u <= 0;
        end

        else begin
            if (ex_is_div_int && !div_req_inflight) begin
                dividend_tvalid_u <= 1'b1;
                divisor_tvalid_u <= 1'b1;
                dividend_tdata_u <= a;
                divisor_tdata_u <= b;
            end

            else if (dividend_tvalid_u && dividend_tready_u &&
                    divisor_tvalid_u && divisor_tready_u) begin
                        dividend_tvalid_u <= 1'b0;
                        divisor_tvalid_u <= 1'b0;
                    end
        end

    end

    always_ff @(posedge clk or posedge reset) begin // result collection
        
        if (reset) result <= 0;

        else begin

            if (div_req_inflight) begin

                if (div_is_signed && dout_tvalid_s) begin
                    case (funct3)
                        3'b100: result <= div_result_s[63:32];
                        3'b110: result <= div_result_s[31:0];
                        default: result <= 0;
                    endcase
                end

                if (!div_is_signed && dout_tvalid_u) begin
                    case (funct3)
                        3'b101: result <= div_result_u[63:32];
                        3'b111: result <= div_result_u[31:0];
                        default: result <= 0;
                    endcase
                end

            end

        end

    end

    always_ff @(posedge clk or posedge reset) begin // post_stall logic

        if (reset) post_stall <= 1'b0;

        else if ( (div_is_signed && dout_tvalid_s)
                || (!div_is_signed && dout_tvalid_u) ) post_stall <= 1'b1;
        
        else post_stall <= 1'b0;

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
        .m_axis_dout_tdata      (div_result_s) // {quotient, remainder}
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
        .m_axis_dout_tdata      (div_result_u) // {quotient, remainder}
    );
    
endmodule