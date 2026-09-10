import rv32_pkg::*;

module alu (
    input  alu_op_e     alu_op_i,
    input  logic [31:0] operand_a_i,
    input  logic [31:0] operand_b_i,
    output logic [31:0] alu_result_o,
    output logic        alu_zero_o
); 

    always_comb begin
        unique case (alu_op_i)
            ALU_ADD: alu_result_o = operand_a_i + operand_b_i;
            ALU_SUB: alu_result_o = operand_a_i - operand_b_i;
            ALU_OR:  alu_result_o = operand_a_i | operand_b_i;
            ALU_AND: alu_result_o = operand_a_i & operand_b_i;
            ALU_SLT: alu_result_o = ($signed(operand_a_i) < $signed(operand_b_i)) ? 32'd1 : 32'd0;
            default: alu_result_o = 32'd0;
        endcase
    end

    assign alu_zero_o = (alu_op_i == ALU_SUB) && (alu_result_o == '0);

endmodule
