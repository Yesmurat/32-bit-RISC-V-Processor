`timescale 1ns/1ps

module maindec (input logic [6:0] op,
                input logic funct7_b0,

                // outputs
                output logic [2:0] ResultSrcD,
                output logic MemWriteD,
                output logic BranchD,
                output logic ALUSrcD,
                output logic RegWriteD,
                output logic JumpD,
                output logic [2:0] ImmSrcD,
                output logic [1:0] ALUOp,
                output logic SrcAsrcD,
                output logic jumpRegD
    );

    always_comb begin
        unique case (op)

            // RegWriteD, ImmSrcD[2:0], ALUSrcD, MemWriteD, ResultSrcD[2:0], BranchD, ALUOpD[1:0], JumpD, SrcAsrcD, jumpRegD

            7'b0000011: begin

                //controls = 15'b1_000_1_0_001_0_00_0_1_1; // I-type (loads)
                RegWriteD = 1'b1;
                ImmSrcD = 3'b000;
                ALUSrcD = 1'b1;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b001;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b0;
                SrcAsrcD = 1'b0;
                jumpRegD = 1'b1;

            end // I-type (loads)

            7'b0100011: begin
                //controls = 15'b0_001_1_1_000_0_00_0_1_1; // S-type

                RegWriteD = 1'b0;
                ImmSrcD = 3'b001;
                ALUSrcD = 1'b1;
                MemWriteD = 1'b1;
                ResultSrcD = 3'b000;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b0;
                SrcAsrcD = 1'b0;
                jumpRegD = 1'b1;

            end // S-type

            7'b0110011: begin

                if (funct7_b0) begin // mult/div

                    // 1, 000, 0, 0, 100, 0, 10, 0, 0, 1 // mult/div
                    RegWriteD = 1'b1;
                    ImmSrcD = 3'b000;
                    ALUSrcD = 1'b0;
                    MemWriteD = 1'b0;
                    ResultSrcD = 3'b100;
                    BranchD = 1'b0;
                    ALUOp = 2'b10;
                    JumpD = 1'b0;
                    SrcAsrcD = 1'b0;
                    jumpRegD = 1'b1;

                end

                else begin

                    // 1, 000, 0, 0, 000, 0, 10, 0, 0, 1
                    RegWriteD = 1'b1;
                    ImmSrcD = 3'b000;
                    ALUSrcD = 1'b0;
                    MemWriteD = 1'b0;
                    ResultSrcD = 3'b000;
                    BranchD = 1'b0;
                    ALUOp = 2'b10;
                    JumpD = 1'b0;
                    SrcAsrcD = 1'b0;
                    jumpRegD = 1'b1;
                    
                end

            end // R-type

            7'b0010011: begin
                
                // 1, 000, 1, 0, 000, 0, 10, 0, 1, 1
                RegWriteD = 1'b1;
                ImmSrcD = 3'b000;
                ALUSrcD = 1'b1;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b000;
                BranchD = 1'b0;
                ALUOp = 2'b10;
                JumpD = 1'b0;
                SrcAsrcD = 1'b0;
                jumpRegD = 1'b1;

            end // I-type (immediates)

            7'b1100011: begin

                // 0, 010, 0, 0, 000, 1, 01, 0, 1, 1
                RegWriteD = 1'b0;
                ImmSrcD = 3'b010;
                ALUSrcD = 1'b0;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b000;
                BranchD = 1'b1;
                ALUOp = 2'b01;
                JumpD = 1'b0;
                SrcAsrcD = 1'b0;
                jumpRegD = 1'b1;

            end // B-type

            7'b0110111: begin

                // 1, 100, 1, 0, 011, 0, 00, 0, 0, 1
                RegWriteD = 1'b1;
                ImmSrcD = 3'b100;
                ALUSrcD = 1'b1;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b011;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b0;
                SrcAsrcD = 1'b0;
                jumpRegD = 1'b1;

            end // U-type (lui)

            7'b0010111: begin

                // 1, 100, 1, 0, 000, 0, 00, 0, 0, 1
                RegWriteD = 1'b1;
                ImmSrcD = 3'b100;
                ALUSrcD = 1'b1;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b000;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b0;
                SrcAsrcD = 1'b1;
                jumpRegD = 1'b1;

            end // U-type (auipc)

            7'b1101111: begin

                // 1, 011, 0, 0, 010, 0, 00, 1, 1, 1
                RegWriteD = 1'b1;
                ImmSrcD = 3'b011;
                ALUSrcD = 1'b0;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b010;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b1;
                SrcAsrcD = 1'b1;
                jumpRegD = 1'b1;

            end // J-type (jal)

            7'b1100111: begin

                // 1, 000, 0, 0, 010, 0, 00, 1, 1, 0
                RegWriteD = 1'b1;
                ImmSrcD = 3'b000;
                ALUSrcD = 1'b0;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b010;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b1;
                SrcAsrcD = 1'b0;
                jumpRegD = 1'b0;

            end // jalr
            
            default: begin
                
                RegWriteD = 1'b0;
                ImmSrcD = 3'b000;
                ALUSrcD = 1'b0;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b000;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b0;
                SrcAsrcD = 1'b0;
                jumpRegD = 1'b0;

            end
        endcase
    end
    
endmodule