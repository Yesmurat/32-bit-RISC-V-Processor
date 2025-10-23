`timescale 1ns/1ps

module mux2 (
        input logic [31:0] d0, d1,
        input logic s,
        output logic [31:0] y
    );
    
    assign y = s ? d1: d0;
endmodule // 2-to-1 multiplexer

module mux3 (
        input logic [31:0] d0, d1, d2,
        input logic [1:0] s,
        output logic [31:0] y
    );
    
    assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule // 3-to-1 mux

//module mux4 (
//        input logic [31:0] d0, d1, d2, d3,
//        input logic [1:0] s,
//        output logic [31:0] y
//    );
    
//    always_comb begin
//        case (s)
//            2'b00: y = d0;
//            2'b01: y = d1;
//            2'b10: y = d2;
//            2'b11: y = d3;
//            default: y = 32'b0;
//        endcase
//    end
//endmodule // 4-to-1 mux

module mux5 (
    input logic [31:0] d0, d1, d2, d3, d4,
    input logic [2:0] s,
    output logic [31:0] y
    );

    always_comb begin
        case (s)
            3'b000: y = d0;
            3'b001: y = d1;
            3'b010: y = d2;
            3'b011: y = d3;
            3'b100: y = d4;
            default: y = 32'b0;
        endcase
    end
    
endmodule

module regfile (input logic clk, we3, reset,
                input logic [4:0] a1, a2, a3,
                input logic [31:0] wd3,

                output logic [31:0] rd1, rd2);

    (* preserve *) logic [31:0] rf[31:0];

    always_ff @(posedge clk) begin
        if (reset) begin
            integer i;
            for (i = 0; i < 32; i=i+1)
                rf[i] <= 32'b0;
        end else if (we3 && (a3 != 5'b0)) rf[a3] <= wd3;

    end

    // The register file is write-first and read occurs after write

    always_comb begin
        // port 1
        if (we3 && (a3 == a1)) rd1 = wd3; // just-written data
        else if (a1 == 0) rd1 = 32'b0; // x0 is hardwired to zero
        else rd1 = rf[a1]; // stored data

        // port 2
        if (we3 && (a3 == a2)) rd2 = wd3;
        else if (a2 == 0) rd2 = 32'b0;
        else rd2 = rf[a2];
    end
endmodule // Register file

module ALU (input logic [31:0] d0, d1,
            input logic [3:0] s,
            output logic [31:0] y);

    always_comb begin
        case (s)
            4'b0000: y = d0 + d1; // add/addi
            4'b0001: y = d0 - d1; // sub
            4'b0111: y = d0 << d1[4:0]; // sll/slli
            4'b0101: y = ($signed(d0) < $signed(d1)) ? 32'b1 : 32'b0; // slt/slti (signed)
            4'b0110: y = (d0 < d1) ? 32'b1 : 32'b0; // sltu/sltiu (unsigned)
            4'b0100: y = d0 ^ d1; // xor/xori 
            4'b1001: y = $signed(d0) >>> d1[4:0]; // sra/srai
            4'b1000: y = d0 >> d1[4:0]; // srl/srli
            4'b0011: y = d0 | d1; // or/ori
            4'b0010: y = d0 & d1; // and/andi
            default: y = 32'bx;
        endcase
    end
endmodule // ALU

module branch_unit (input logic [31:0] SrcAE, SrcBE,
                    input logic [2:0] funct3E,
                    output logic branchTakenE
);

    logic eqE, ltE, ltuE;

    assign eqE = (SrcAE == SrcBE);
    assign ltE = $signed(SrcAE) < $signed(SrcBE);
    assign ltuE = $unsigned(SrcAE) < $unsigned(SrcBE);

    always_comb begin
        case (funct3E)
            3'b000: branchTakenE = eqE; // beq
            3'b001: branchTakenE = !eqE; // bne
            3'b100: branchTakenE = ltE; // blt
            3'b101: branchTakenE = !ltE; // bge
            3'b110: branchTakenE = ltuE; // bltu
            3'b111: branchTakenE = !ltuE; // bgeu
            default: branchTakenE =  1'b0;
        endcase
    end
endmodule // Branch unit