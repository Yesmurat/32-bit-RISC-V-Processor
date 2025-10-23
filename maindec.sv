`timescale 1ns/1ps

module maindec (input logic [6:0] op,
                input logic [6:0] funct7,

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

    // logic [14:0] controls;

    // assign {RegWriteD, ImmSrcD, ALUSrcD, MemWriteD,
            // ResultSrcD, BranchD, ALUOp, JumpD, SrcAsrcD, jumpRegD} = controls;

    always_comb begin
        case (op)

            // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump_SrcAsrcD_jumpRegD

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
                SrcAsrcD = 1'b1;
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
                SrcAsrcD = 1'b1;
                jumpRegD = 1'b1;

            end // S-type

            7'b0110011: begin

                if (funct7 == 7'b0000001) begin // multiplication

                    // controls = 15'b1_000_0_0_100_0_10_0_1_1; // multiplication
                    RegWriteD = 1'b1;
                    ImmSrcD = 3'b000;
                    ALUSrcD = 1'b0;
                    MemWriteD = 1'b0;
                    ResultSrcD = 3'b100;
                    BranchD = 1'b0;
                    ALUOp = 2'b10;
                    JumpD = 1'b0;
                    SrcAsrcD = 1'b1;
                    jumpRegD = 1'b1;

                end

                else begin

                    // controls = 15'b1_000_0_0_000_0_10_0_1_1;
                    RegWriteD = 1'b1;
                    ImmSrcD = 3'b000;
                    ALUSrcD = 1'b0;
                    MemWriteD = 1'b0;
                    ResultSrcD = 3'b000;
                    BranchD = 1'b0;
                    ALUOp = 2'b10;
                    JumpD = 1'b0;
                    SrcAsrcD = 1'b1;
                    jumpRegD = 1'b1;
                    
                end

            end // R-type

            7'b0010011: begin
                
                // controls = 15'b1_000_1_0_000_0_10_0_1_1; // I-type
                RegWriteD = 1'b1;
                ImmSrcD = 3'b000;
                ALUSrcD = 1'b1;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b000;
                BranchD = 1'b0;
                ALUOp = 2'b10;
                JumpD = 1'b0;
                SrcAsrcD = 1'b1;
                jumpRegD = 1'b1;

            end // I-type (immediates)

            7'b1100011: begin

                // controls = 15'b0_010_0_0_000_1_01_0_1_1; // B-type
                RegWriteD = 1'b0;
                ImmSrcD = 3'b010;
                ALUSrcD = 1'b0;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b000;
                BranchD = 1'b1;
                ALUOp = 2'b01;
                JumpD = 1'b0;
                SrcAsrcD = 1'b1;
                jumpRegD = 1'b1;

            end // B-type

            7'b0110111: begin

                // controls = 15'b1_100_1_0_011_0_00_0_0_1; // lui
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

                // controls = 15'b1_100_1_0_000_0_00_0_0_1; // auipc
                RegWriteD = 1'b1;
                ImmSrcD = 3'b100;
                ALUSrcD = 1'b1;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b000;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b0;
                SrcAsrcD = 1'b0;
                jumpRegD = 1'b1;

            end // U-type (auipc)

            7'b1101111: begin

                // controls = 15'b1_011_0_0_010_0_00_1_1_1; // jal
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

                // controls = 15'b1_000_0_0_010_0_00_1_1_0; // jalr
                RegWriteD = 1'b1;
                ImmSrcD = 3'b000;
                ALUSrcD = 1'b0;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b010;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b1;
                SrcAsrcD = 1'b1;
                jumpRegD = 1'b0;

            end // jalr
            
            default: begin
                
                RegWriteD = 1'b1;
                ImmSrcD = 3'b000;
                ALUSrcD = 1'b1;
                MemWriteD = 1'b0;
                ResultSrcD = 3'b001;
                BranchD = 1'b0;
                ALUOp = 2'b00;
                JumpD = 1'b0;
                SrcAsrcD = 1'b1;
                jumpRegD = 1'b1;

            end
        endcase
    end
    
endmodule