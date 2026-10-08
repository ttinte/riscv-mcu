import rv32_pkg::*;

module branch_unit (
    input  branch_op_e branch_op_i,
    input  alu_flags_t flags_i,
    output logic       take_branch_o
);

    always_comb begin
        take_branch_o = 1'b0;

        unique case (branch_op_i)
            BRANCH_EQ:  take_branch_o = flags_i.zero;
            BRANCH_NE:  take_branch_o = ~flags_i.zero;
            BRANCH_LT:  take_branch_o = (flags_i.sign ^ flags_i.overflow);
            BRANCH_GE:  take_branch_o = ~(flags_i.sign ^ flags_i.overflow);
            BRANCH_LTU: take_branch_o = ~flags_i.carry;
            BRANCH_GEU: take_branch_o = flags_i.carry;
            default: ;
        endcase
    end

endmodule