module aludec (input logic opb5, // for sub detection
                input logic [2:0] funct3, // instr[14:12]
                input logic funct7b5, // instr[30] for SUB/SRA
                input logic [1:0] ALUOp,
                output logic [3:0] ALUControl
);

    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5; // TRUE for R-type SUB

    localparam [3:0]
        ADD = 4'b0000,
        SUB = 4'b0001,
        AND = 4'b0010,
        OR = 4'b0011,
        XOR = 4'b0100,
        SLT = 4'b0101,
        SLTU = 4'b0110,
        SLL = 4'b0111,
        SRL = 4'b1000,
        SRA = 4'b1001;

    always_comb begin
            case (ALUOp)
                2'b00: ALUControl = ADD; // load/store, addi
                2'b01: ALUControl = SUB; // brances
                default: begin
                    unique case (funct3)
                        3'b000: ALUControl = RtypeSub ? SUB : ADD;
                        3'b001: ALUControl = SLL;
                        3'b010: ALUControl = SLT; // slt/slti (signed)
                        3'b011: ALUControl = SLTU; // sltu/sltiu (unsigned)
                        3'b100: ALUControl = XOR;
                        3'b101: ALUControl = funct7b5 ? SRA : SRL; // sra/srai or srl/srli
                        3'b110: ALUControl = OR; // or/ori
                        3'b111: ALUControl = AND; // and/andi
                        default: ALUControl = ADD;
                    endcase
                end
            endcase
        end

endmodule