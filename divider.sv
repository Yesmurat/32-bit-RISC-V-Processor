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

    logic post_stall;
    logic ex_is_div_reg;
    // current problem is that stall logic doesn't work because ex_is_div is always high during division
    // When div_req_inflight goes to 0 after dout_tvalid_u is asserted, ex_is_div is asserted
    // resulting in new division

    // stall logic
    always_comb begin

        // on reset
        if (reset) stall = 0;

        else if (post_stall) stall = 0;

        else if ( (ex_is_div && !div_req_inflight) // on new division
                  || div_req_inflight ) // during division
                stall = 1;

        else stall = 0;
        
    end

    logic ex_is_div_int;

    always_comb begin

        ex_is_div_int = 0;

        else if ( (div_is_signed && dout_tvalid_s)
                || (!div_is_signed && dout_tvalid_u) ) ex_is_div_int = 0;

        else ex_is_div_int = ex_is_div;
        
    end


    always_ff @(posedge clk or posedge reset) begin // request control

        if (reset) begin
            div_req_inflight <= 1'b0;
            div_is_signed <= 1'b0;
        end

        else begin
            
            if (ex_is_div && !div_req_inflight) begin
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
            if (ex_is_div && !div_req_inflight) begin // on new division
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
            if (ex_is_div && !div_req_inflight) begin
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