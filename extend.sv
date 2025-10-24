`timescale 1ns/1ps

module extend (
    input  logic [24:0] instr_31_7,
    input  logic [2:0]  immsrc,
    output logic [31:0] immext
);

    always_comb begin
        unique case (immsrc)

            // I-type
            3'b000: immext = { {20{instr_31_7[24]}}, instr_31_7[24:13] };

            // S-type
            3'b001: immext = { {20{instr_31_7[24]}}, instr_31_7[24:18], instr_31_7[4:0] };

            // B-type (branches)
            3'b010: immext = { {19{instr_31_7[24]}}, instr_31_7[0], instr_31_7[23:18],
                               instr_31_7[4:1], 1'b0 };

            // J-type (jal)
            3'b011: immext = { {11{instr_31_7[24]}}, instr_31_7[12:5], instr_31_7[13],
                               instr_31_7[23:14], 1'b0 };

            // U-type
            3'b100: immext = { instr_31_7[24:5], 12'b0 };

            default: immext = 32'b0; // undefined

        endcase
    end

endmodule