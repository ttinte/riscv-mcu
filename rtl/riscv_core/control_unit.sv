import rv32_pkg::*;

module control_unit (
    input  logic         clk_i,
    input  logic         rst_ni,
    input  logic         alu_zero_i,
    input  logic [31:0]  instr_i,
    output decode_ctrl_t ctrl_o,
    output logic         trace_valid_o
);

    typedef enum logic [2:0] {
        STATE_IF,
        STATE_ID,
        STATE_EX,
        STATE_MEM_RD,
        STATE_MEM_WR,
        STATE_WB
    } state_e;

    state_e state_q, state_d;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr_i[6:0];
    assign funct3 = instr_i[14:12];
    assign funct7 = instr_i[31:25];

    always_comb begin
        state_d             = state_q;
        ctrl_o.pc_we        = 1'b0;
        ctrl_o.mem_addr_sel = MEM_ADDR_PC;
        ctrl_o.mem_we       = 1'b0;
        ctrl_o.mem_re       = 1'b0;
        ctrl_o.ir_we        = 1'b0;
        ctrl_o.reg_we       = 1'b0;
        ctrl_o.imm_sel      = IMM_NONE;
        ctrl_o.op_a_sel     = OP_A_PC;
        ctrl_o.op_b_sel     = OP_B_FOUR;
        ctrl_o.alu_op       = ALU_ADD;
        ctrl_o.result_sel   = RESULT_ALU_COMB;

        unique case (state_q)
            STATE_IF: begin
                state_d = STATE_ID;

                ctrl_o.pc_we  = 1'b1;
                ctrl_o.mem_re = 1'b1;
                ctrl_o.ir_we  = 1'b1;
            end

            STATE_ID: begin
                state_d = STATE_EX;

                if ((opcode == OPCODE_BRANCH) && (funct3 == FUNCT3_BEQ)) begin
                    ctrl_o.imm_sel  = IMM_B;
                    ctrl_o.op_a_sel = OP_A_OLD_PC;
                    ctrl_o.op_b_sel = OP_B_IMM;
                    ctrl_o.alu_op   = ALU_ADD;
                end
                else if (opcode == OPCODE_JAL) begin
                    ctrl_o.imm_sel  = IMM_J;
                    ctrl_o.op_a_sel = OP_A_OLD_PC;
                    ctrl_o.op_b_sel = OP_B_IMM;
                    ctrl_o.alu_op   = ALU_ADD;
                end
            end

            STATE_EX: begin
                unique case (opcode)
                    OPCODE_OP: begin
                        state_d = STATE_WB;

                        ctrl_o.op_a_sel = OP_A_RS1;
                        ctrl_o.op_b_sel = OP_B_RS2;

                        unique case({funct7, funct3})
                            {FUNCT7_BASE, FUNCT3_ADD_SUB}: ctrl_o.alu_op = ALU_ADD;
                            {FUNCT7_SUB,  FUNCT3_ADD_SUB}: ctrl_o.alu_op = ALU_SUB;
                            {FUNCT7_BASE, FUNCT3_SLT}:     ctrl_o.alu_op = ALU_SLT;
                            {FUNCT7_BASE, FUNCT3_OR}:      ctrl_o.alu_op = ALU_OR;
                            {FUNCT7_BASE, FUNCT3_AND}:     ctrl_o.alu_op = ALU_AND;
                            default: ;
                        endcase
                    end

                    OPCODE_OP_IMM: begin
                        state_d = STATE_WB;

                        ctrl_o.imm_sel  = IMM_I;
                        ctrl_o.op_a_sel = OP_A_RS1;
                        ctrl_o.op_b_sel = OP_B_IMM;

                        if (funct3 == FUNCT3_ADDI) begin
                            ctrl_o.alu_op = ALU_ADD;
                        end
                    end

                    OPCODE_LOAD: begin
                        state_d = STATE_MEM_RD;

                        ctrl_o.imm_sel  = IMM_I;
                        ctrl_o.op_a_sel = OP_A_RS1;
                        ctrl_o.op_b_sel = OP_B_IMM;
                        ctrl_o.alu_op   = ALU_ADD;
                    end

                    OPCODE_STORE: begin
                        state_d = STATE_MEM_WR;

                        ctrl_o.imm_sel  = IMM_S;
                        ctrl_o.op_a_sel = OP_A_RS1;
                        ctrl_o.op_b_sel = OP_B_IMM;
                        ctrl_o.alu_op   = ALU_ADD;
                    end

                    OPCODE_BRANCH: begin
                        state_d = STATE_IF;

                        if (alu_zero_i) begin
                            ctrl_o.pc_we  = 1'b1;
                        end
                        ctrl_o.op_a_sel   = OP_A_RS1;
                        ctrl_o.op_b_sel   = OP_B_RS2;
                        ctrl_o.alu_op     = ALU_SUB;
                        ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    end

                    OPCODE_JAL: begin
                        state_d = STATE_WB;

                        ctrl_o.pc_we      = 1'b1;
                        ctrl_o.op_a_sel   = OP_A_OLD_PC;
                        ctrl_o.op_b_sel   = OP_B_FOUR;
                        ctrl_o.alu_op     = ALU_ADD;
                        ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    end
                    
                    default: ;
                endcase
            end

            STATE_MEM_RD: begin
                state_d = STATE_WB;

                ctrl_o.mem_addr_sel = MEM_ADDR_RESULT;
                ctrl_o.mem_re       = 1'b1;
                ctrl_o.result_sel   = RESULT_ALU_OUT_Q;
            end

            STATE_MEM_WR: begin
                state_d = STATE_IF;

                ctrl_o.mem_addr_sel = MEM_ADDR_RESULT;
                ctrl_o.mem_we       = 1'b1;
                ctrl_o.result_sel   = RESULT_ALU_OUT_Q;
            end

            STATE_WB: begin
                state_d = STATE_IF;

                ctrl_o.reg_we = 1'b1;
                
                unique case (opcode)
                    OPCODE_OP:     ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    OPCODE_OP_IMM: ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    OPCODE_LOAD:   ctrl_o.result_sel = RESULT_MEM_DATA;
                    OPCODE_JAL:    ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    default: ;
                endcase
            end

            default: ;
        endcase
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            state_q <= STATE_IF;
        end else begin
            state_q <= state_d;
        end
    end

    assign trace_valid_o = (state_q == STATE_WB) || (state_q == STATE_MEM_WR) ||
                           ((state_q == STATE_EX) && (opcode == OPCODE_BRANCH));

endmodule
