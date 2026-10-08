import rv32_pkg::*;

module branch_unit (
    input  logic [2:0] br_funct3_i,
    input  alu_flags_t flags_i,
    output logic       take_branch_o
);

    always_comb begin
        take_branch_o = 1'b0;

        unique case (br_funct3_i)
            FUNCT3_BEQ:  take_branch_o = flags_i.zero;
            FUNCT3_BNE:  take_branch_o = ~flags_i.zero;
            FUNCT3_BLT:  take_branch_o = (flags_i.sign ^ flags_i.overflow);
            FUNCT3_BGE:  take_branch_o = ~(flags_i.sign ^ flags_i.overflow);
            FUNCT3_BLTU: take_branch_o = ~flags_i.carry;
            FUNCT3_BGEU: take_branch_o = flags_i.carry;
            default: ;
        endcase
    end

endmodule