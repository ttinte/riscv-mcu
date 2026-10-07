import rv32_pkg::*;

module branch_unit (
    input  logic [2:0] br_funct3_i,
    input  logic       alu_zero_i,
    output logic       take_branch_o
);

    always_comb begin
        take_branch_o = 1'b0;

        unique case (br_funct3_i)
            FUNCT3_BEQ: take_branch_o = alu_zero_i;
            FUNCT3_BNE: take_branch_o = !alu_zero_i;
            default: ;
        endcase
    end

endmodule