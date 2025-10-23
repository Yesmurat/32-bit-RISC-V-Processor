module IFregister (input logic clk, en, reset,
                    input logic [31:0] d,
                    output logic [31:0] q);
    
    always_ff @(posedge clk)
        if (reset) begin
            q <= 32'b0;
        end
        else if (en) q <= d;
endmodule // IF stage register

module IFIDregister (input logic clk, en, reset,
                    input logic [31:0] RD_instr, PCF, PCPlus4F,
                    output logic [31:0] InstrD, PCD, PCPlus4D);
    
    always_ff @(posedge clk)

        if (reset) begin

            InstrD <= 32'b0;
            PCD <= 32'b0;
            PCPlus4D <= 32'b0;

        end

        else if (en) begin

            InstrD <= RD_instr;
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
            
        end

endmodule // ID stage register

module IDEXregister (input logic clk, en, reset,

                    // ID stage controls signals
                    input logic RegWriteD,
                    input logic [2:0] ResultSrcD,
                    input logic MemWriteD,
                    input logic JumpD,
                    input logic BranchD,
                    input logic [3:0] ALUControlD,
                    input logic ALUSrcD,
                    input logic SrcAsrcD,
                    input logic [2:0] funct3D,
                    input logic jumpRegD,

                    // EX stage control signals
                    output logic RegWriteE,
                    output logic [2:0] ResultSrcE,
                    output logic MemWriteE,
                    output logic JumpE,
                    output logic BranchE,
                    output logic [3:0] ALUControlE,
                    output logic ALUSrcE,
                    output logic SrcAsrcE,
                    output logic [2:0] funct3E,
                    output logic jumpRegE,

                    // Datapath inputs & outputs
                    input logic [31:0] RD1, RD2, PCD,
                    input logic [4:0] Rs1D, Rs2D, RdD,
                    input logic [31:0] ImmExtD,
                    input logic [31:0] PCPlus4D,

                    output logic [31:0] RD1E, RD2E, PCE,
                    output logic [4:0] Rs1E, Rs2E, RdE,
                    output logic [31:0] ImmExtE,
                    output logic [31:0] PCPlus4E

);

    always_ff @(posedge clk) begin

        if (reset) begin

            RegWriteE <= 1'b0;
            ResultSrcE <= 3'b0;
            MemWriteE <= 1'b0;
            JumpE <= 1'b0;
            BranchE <= 1'b0;
            ALUControlE <= 4'b0;
            ALUSrcE <= 1'b0;
            SrcAsrcE <= 1'b0;
            funct3E <= 3'b0;
            jumpRegE <= 1'b0;

            RD1E <= 32'b0;
            RD2E <= 32'b0;
            PCE <= 32'b0;
            Rs1E <= 5'b0;
            Rs2E <= 5'b0;
            RdE <= 5'b0;
            ImmExtE <= 32'b0;
            PCPlus4E <= 32'b0;
        end
        
        else if (en) begin

            RegWriteE <= RegWriteD;
            ResultSrcE <= ResultSrcD;
            MemWriteE <= MemWriteD;
            JumpE <= JumpD;
            BranchE <= BranchD;
            ALUControlE <= ALUControlD;
            ALUSrcE <= ALUSrcD;
            SrcAsrcE <= SrcAsrcD;
            funct3E <= funct3D;
            jumpRegE <= jumpRegD;

            RD1E <= RD1; RD2E <= RD2; PCE <= PCD;
            Rs1E <= Rs1D; Rs2E <= Rs2D; RdE <= RdD;
            ImmExtE <= ImmExtD;
            PCPlus4E <= PCPlus4D;
        end

    end   
endmodule

module EXMEMregister (input logic clk, en, reset, // EX -> MEM

                    // EX stage control signals
                    input logic RegWriteE,
                    input logic [2:0] ResultSrcE,
                    input logic MemWriteE,
                    input logic [2:0] funct3E,

                    // MEM stage control signals
                    output logic RegWriteM,
                    output logic [2:0] ResultSrcM,
                    output logic MemWriteM,
                    output logic [2:0] funct3M,

                    // datapath inputs & outputs
                    input logic [31:0] ALUResultE,
                    input logic [31:0] WriteDataE,
                    input logic [4:0] RdE,
                    input logic [31:0] ImmExtE,
                    input logic [31:0] PCPlus4E,
                    input logic [31:0] multiplier_resultE,

                    output logic [31:0] ALUResultM,
                    output logic [31:0] WriteDataM,
                    output logic [4:0] RdM,
                    output logic [31:0] ImmExtM,
                    output logic [31:0] PCPlus4M,
                    output logic [31:0] multiplier_resultM

);

    always_ff @(posedge clk) begin

        if (reset) begin
            RegWriteM <= 1'b0;
            ResultSrcM <= 3'b0;
            MemWriteM <= 1'b0;
            funct3M <= 3'b0;

            ALUResultM <= 32'b0;
            WriteDataM <= 32'b0;
            RdM <= 5'b0;
            ImmExtM <= 32'b0;
            PCPlus4M <= 32'b0;
            multiplier_resultM <= 32'b0;
        end
        
        else if (en) begin
            RegWriteM <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            MemWriteM <= MemWriteE;
            funct3M <= funct3E;

            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            RdM <= RdE;
            ImmExtM <= ImmExtE;
            PCPlus4M <= PCPlus4E;
            multiplier_resultM <= multiplier_resultE;
        end

    end  
endmodule

module MEMWBregister (input logic clk, reset, // MEM -> WB

                    // MEM stage control signals
                    input logic RegWriteM,
                    input logic [2:0] ResultSrcM,

                    // WB stage signals
                    output logic RegWriteW,
                    output logic [2:0] ResultSrcW,

                    // datapath inputs & outputs
                    input logic [31:0] ALUResultM,
                    input logic [31:0] load_data,
                    input logic [4:0] RdM,
                    input logic [31:0] ImmExtM,
                    input logic [31:0] PCPlus4M,
                    input logic [31:0] multiplier_resultM,

                    output logic [31:0] ALUResultW,
                    output logic [31:0] ReadDataW,
                    output logic [4:0] RdW,
                    output logic [31:0] ImmExtW,
                    output logic [31:0] PCPlus4W,
                    output logic [31:0] multiplier_resultW

);

    always_ff @(posedge clk) begin

        if (reset) begin
            RegWriteW <= 1'b0;
            ResultSrcW <= 3'b0;

            ALUResultW <= 32'b0;
            ReadDataW <= 32'b0;
            RdW <= 5'b0;
            ImmExtW <= 32'b0;
            PCPlus4W <= 32'b0;
            multiplier_resultW <= 32'b0;
        end

        else begin
            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;

            ALUResultW <= ALUResultM;
            ReadDataW <= load_data;
            RdW <= RdM;
            ImmExtW <= ImmExtM;
            PCPlus4W <= PCPlus4M;
            multiplier_resultW <= multiplier_resultM;
        end

    end   
endmodule