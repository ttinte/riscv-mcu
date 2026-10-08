import rv32_pkg::*;

module alu (
    input  alu_op_e     alu_op_i,
    input  logic [31:0] operand_a_i,
    input  logic [31:0] operand_b_i,
    output logic [31:0] alu_result_o,
    output alu_flags_t  alu_flags_o
); 

    logic [31:0] operand_b_src;
    logic [32:0] adder_result;

    assign operand_b_src = (alu_op_i == ALU_ADD) ? operand_b_i :
                           (alu_op_i == ALU_SUB || alu_op_i == ALU_SLT || 
                            alu_op_i == ALU_SLTU ) ? ~operand_b_i : '0;
    assign adder_result  = {1'b0, operand_a_i} + {1'b0, operand_b_src} + 
                           {32'd0, (alu_op_i == ALU_SUB || alu_op_i == ALU_SLT || 
                                    alu_op_i == ALU_SLTU)};

    always_comb begin
        unique case (alu_op_i)
            ALU_ADD:    alu_result_o = adder_result[31:0];
            ALU_SUB:    alu_result_o = adder_result[31:0];
            ALU_XOR:    alu_result_o = operand_a_i ^ operand_b_i;
            ALU_OR:     alu_result_o = operand_a_i | operand_b_i;
            ALU_AND:    alu_result_o = operand_a_i & operand_b_i;
            ALU_SLT:    alu_result_o = {31'd0, adder_result[31] ^ alu_flags_o.overflow};
            ALU_SLTU:   alu_result_o = {31'd0, ~adder_result[32]};
            ALU_PASS_B: alu_result_o = operand_b_i;
            default: alu_result_o = '0;
        endcase
    end

    assign alu_flags_o.zero     = alu_result_o == '0;
    assign alu_flags_o.sign     = alu_result_o[31];
    assign alu_flags_o.carry    = adder_result[32];
    assign alu_flags_o.overflow = ~(operand_a_i[31] ^ operand_b_src[31]) & 
                                  (operand_a_i[31] ^ adder_result[31]);

endmodule
