// Place this module in the MEM stage, connecting its input RD_data to Data Memory's RD_data output
module loadext (
    input logic [2:0] LoadTypeM, // which is funct3M propagated from funct3D from the contorl unit
    input logic [31:0] RD_data,
    input logic [1:0] byteAddrM,
    output logic [31:0] load_data
);

    always_comb begin
        unique case (LoadTypeM)

            3'b000: 
            case (byteAddrM) // lb

                2'b00: load_data = {{24{RD_data[7]}}, RD_data[7:0]};
                2'b01: load_data = {{24{RD_data[15]}}, RD_data[15:8]};
                2'b10: load_data = {{24{RD_data[23]}}, RD_data[23:16]};
                2'b11: load_data = {{24{RD_data[31]}}, RD_data[31:24]};
                default: load_data = 31'b0;

            endcase

            3'b100: 
            case (byteAddrM) // lbu

                2'b00: load_data = {24'b0, RD_data[7:0]};
                2'b01: load_data = {24'b0, RD_data[15:8]};
                2'b10: load_data = {24'b0, RD_data[23:16]};
                2'b11: load_data = {24'b0, RD_data[31:24]};
                default: load_data = 32'b0;

            endcase

            3'b001: load_data = (byteAddrM[1] ==  1'b0)
                                ? {{16{RD_data[15]}}, RD_data[15:0]}
                                : {{16{RD_data[31]}}, RD_data[31:16]};


            3'b101: load_data = (byteAddrM[1] == 1'b0)
                                ? {16'b0, RD_data[15:0]}
                                : {16'b0, RD_data[31:16]};

            3'b010: load_data = RD_data; // lw
            
            default: load_data = 32'b0; // don't care
        endcase
    end
    
endmodule