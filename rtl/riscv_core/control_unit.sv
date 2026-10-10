import rv32_pkg::*;

module control_unit (
    input  logic         clk_i,
    input  logic         rst_ni,
    input  logic         take_branch_i,
    input  logic [31:0]  instr_i,
    output decode_ctrl_t ctrl_o,
    output branch_op_e   branch_op_o,
    output logic         trace_valid_o
);

    localparam logic [2:0] FUNCT3_ADD_SUB   = 3'b000;     //OP
    localparam logic [2:0] FUNCT3_SLL       = 3'b001;
    localparam logic [2:0] FUNCT3_SLT       = 3'b010;
    localparam logic [2:0] FUNCT3_SLTU      = 3'b011;
    localparam logic [2:0] FUNCT3_XOR       = 3'b100;
    localparam logic [2:0] FUNCT3_SRL_SRA   = 3'b101;
    localparam logic [2:0] FUNCT3_OR        = 3'b110;
    localparam logic [2:0] FUNCT3_AND       = 3'b111;

    localparam logic [2:0] FUNCT3_ADDI      = 3'b000;     //OP-IMM
    localparam logic [2:0] FUNCT3_SLLI      = 3'b001;
    localparam logic [2:0] FUNCT3_SLTI      = 3'b010;
    localparam logic [2:0] FUNCT3_SLTIU     = 3'b011;
    localparam logic [2:0] FUNCT3_XORI      = 3'b100;
    localparam logic [2:0] FUNCT3_SRLI_SRAI = 3'b101;
    localparam logic [2:0] FUNCT3_ORI       = 3'b110;
    localparam logic [2:0] FUNCT3_ANDI      = 3'b111;

    localparam logic [2:0] FUNCT3_LB        = 3'b000;     //LOAD
    localparam logic [2:0] FUNCT3_LH        = 3'b001;
    localparam logic [2:0] FUNCT3_LW        = 3'b010;
    localparam logic [2:0] FUNCT3_LBU       = 3'b100;
    localparam logic [2:0] FUNCT3_LHU       = 3'b101;
    localparam logic [2:0] FUNCT3_SB        = 3'b000;     //STORE
    localparam logic [2:0] FUNCT3_SH        = 3'b001;
    localparam logic [2:0] FUNCT3_SW        = 3'b010;

    localparam logic [2:0] FUNCT3_JALR      = 3'b000;     //JALR
    localparam logic [2:0] FUNCT3_BEQ       = 3'b000;     //BRANCH
    localparam logic [2:0] FUNCT3_BNE       = 3'b001;
    localparam logic [2:0] FUNCT3_BLT       = 3'b100;
    localparam logic [2:0] FUNCT3_BGE       = 3'b101;
    localparam logic [2:0] FUNCT3_BLTU      = 3'b110;
    localparam logic [2:0] FUNCT3_BGEU      = 3'b111;

    typedef enum logic [3:0] {
        ST_IF_REQ,
        ST_IF_RESP,
        ST_ID,
        ST_JALR_TARGET,
        ST_EX,
        ST_LD_REQ,
        ST_LD_RESP,
        ST_ST,
        ST_WB
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
        ctrl_o.pc_clear_lsb = 1'b0;
        ctrl_o.mem_addr_sel = MEM_ADDR_PC;
        ctrl_o.mem_we       = 1'b0;
        ctrl_o.mem_re       = 1'b0;
        ctrl_o.load_op      = LOAD_NONE;
        ctrl_o.store_op     = STORE_NONE;
        ctrl_o.ir_we        = 1'b0;
        ctrl_o.reg_we       = 1'b0;
        ctrl_o.imm_sel      = IMM_NONE;
        ctrl_o.op_a_sel     = OP_A_PC;
        ctrl_o.op_b_sel     = OP_B_FOUR;
        ctrl_o.alu_op       = ALU_ADD;
        ctrl_o.result_sel   = RESULT_ALU_COMB;

        unique case (state_q)
            ST_IF_REQ: begin
                state_d = ST_IF_RESP;

                ctrl_o.mem_re = 1'b1;
            end

            ST_IF_RESP: begin
                state_d = ST_ID;

                ctrl_o.pc_we  = 1'b1;
                ctrl_o.ir_we = 1'b1;
            end

            ST_ID: begin
                state_d = ST_EX;

                unique case (opcode)
                    OPCODE_BRANCH: begin
                        if (funct3 == FUNCT3_BEQ || funct3 == FUNCT3_BNE  || funct3 == FUNCT3_BLT  || 
                            funct3 == FUNCT3_BGE || funct3 == FUNCT3_BLTU || funct3 == FUNCT3_BGEU) begin
                            ctrl_o.imm_sel  = IMM_B;
                            ctrl_o.op_a_sel = OP_A_OLD_PC;
                            ctrl_o.op_b_sel = OP_B_IMM;
                        end
                    end

                    OPCODE_AUIPC: begin
                        state_d = ST_WB;

                        ctrl_o.imm_sel  = IMM_U;
                        ctrl_o.op_a_sel = OP_A_OLD_PC;
                        ctrl_o.op_b_sel = OP_B_IMM;
                    end

                    OPCODE_LUI: begin
                        state_d = ST_WB;

                        ctrl_o.imm_sel  = IMM_U;
                        ctrl_o.op_b_sel = OP_B_IMM;
                        ctrl_o.alu_op   = ALU_PASS_B;
                    end

                    OPCODE_JALR: begin
                        if (funct3 == FUNCT3_JALR) begin
                            state_d = ST_JALR_TARGET;
                        end
                    end

                    OPCODE_JAL: begin
                        ctrl_o.imm_sel  = IMM_J;
                        ctrl_o.op_a_sel = OP_A_OLD_PC;
                        ctrl_o.op_b_sel = OP_B_IMM;
                    end

                    default: ;
                endcase
            end

            ST_JALR_TARGET: begin
                state_d = ST_EX;

                ctrl_o.imm_sel  = IMM_I;
                ctrl_o.op_a_sel = OP_A_RS1;
                ctrl_o.op_b_sel = OP_B_IMM;
            end

            ST_EX: begin
                unique case (opcode)
                    OPCODE_OP: begin
                        state_d = ST_WB;

                        ctrl_o.op_a_sel = OP_A_RS1;
                        ctrl_o.op_b_sel = OP_B_RS2;

                        unique case({funct7, funct3})
                            {7'h00, FUNCT3_ADD_SUB}: ctrl_o.alu_op = ALU_ADD;
                            {7'h20, FUNCT3_ADD_SUB}: ctrl_o.alu_op = ALU_SUB;
                            {7'h00, FUNCT3_SLL}:     ctrl_o.alu_op = ALU_SLL;
                            {7'h00, FUNCT3_SLT}:     ctrl_o.alu_op = ALU_SLT;
                            {7'h00, FUNCT3_SLTU}:    ctrl_o.alu_op = ALU_SLTU;
                            {7'h00, FUNCT3_XOR}:     ctrl_o.alu_op = ALU_XOR;
                            {7'h00, FUNCT3_SRL_SRA}: ctrl_o.alu_op = ALU_SRL;
                            {7'h20, FUNCT3_SRL_SRA}: ctrl_o.alu_op = ALU_SRA;
                            {7'h00, FUNCT3_OR}:      ctrl_o.alu_op = ALU_OR;
                            {7'h00, FUNCT3_AND}:     ctrl_o.alu_op = ALU_AND;
                            default: ;
                        endcase
                    end

                    OPCODE_OP_IMM: begin
                        state_d = ST_WB;

                        ctrl_o.imm_sel  = IMM_I;
                        ctrl_o.op_a_sel = OP_A_RS1;
                        ctrl_o.op_b_sel = OP_B_IMM;

                        unique case(funct3)
                            FUNCT3_ADDI:  ctrl_o.alu_op = ALU_ADD;
                            FUNCT3_SLTI:  ctrl_o.alu_op = ALU_SLT;
                            FUNCT3_SLTIU: ctrl_o.alu_op = ALU_SLTU;
                            FUNCT3_XORI:  ctrl_o.alu_op = ALU_XOR;
                            FUNCT3_ORI:   ctrl_o.alu_op = ALU_OR;
                            FUNCT3_ANDI:  ctrl_o.alu_op = ALU_AND;
                            FUNCT3_SLLI:  begin
                                if (funct7 == 7'h00) ctrl_o.alu_op = ALU_SLL;
                            end
                            FUNCT3_SRLI_SRAI: begin
                                if (funct7 == 7'h00) 
                                    ctrl_o.alu_op = ALU_SRL;
                                else if (funct7 == 7'h20) 
                                    ctrl_o.alu_op = ALU_SRA;
                            end
                            default: ;
                        endcase
                    end

                    OPCODE_LOAD: begin
                        state_d = ST_LD_REQ;

                        ctrl_o.imm_sel  = IMM_I;
                        ctrl_o.op_a_sel = OP_A_RS1;
                        ctrl_o.op_b_sel = OP_B_IMM;
                    end

                    OPCODE_STORE: begin
                        state_d = ST_ST;

                        ctrl_o.imm_sel  = IMM_S;
                        ctrl_o.op_a_sel = OP_A_RS1;
                        ctrl_o.op_b_sel = OP_B_IMM;
                    end

                    OPCODE_BRANCH: begin
                        state_d = ST_IF_REQ;

                        ctrl_o.pc_we      = take_branch_i;
                        ctrl_o.op_a_sel   = OP_A_RS1;
                        ctrl_o.op_b_sel   = OP_B_RS2;
                        ctrl_o.alu_op     = ALU_SUB;
                        ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    end

                    OPCODE_JALR: begin
                        state_d = ST_WB;

                        ctrl_o.pc_we        = 1'b1;
                        ctrl_o.pc_clear_lsb = 1'b1;
                        ctrl_o.op_a_sel     = OP_A_OLD_PC;
                        ctrl_o.op_b_sel     = OP_B_FOUR;
                        ctrl_o.result_sel   = RESULT_ALU_OUT_Q;
                    end

                    OPCODE_JAL: begin
                        state_d = ST_WB;

                        ctrl_o.pc_we        = 1'b1;
                        ctrl_o.op_a_sel     = OP_A_OLD_PC;
                        ctrl_o.op_b_sel     = OP_B_FOUR;
                        ctrl_o.result_sel   = RESULT_ALU_OUT_Q;
                    end
                    
                    default: ;
                endcase
            end

            ST_LD_REQ: begin
                state_d = ST_LD_RESP;

                ctrl_o.mem_addr_sel = MEM_ADDR_RESULT;
                ctrl_o.mem_re       = 1'b1;
                ctrl_o.result_sel   = RESULT_ALU_OUT_Q;
            end

            ST_LD_RESP: begin
                state_d = ST_WB;

                unique case (funct3)
                    FUNCT3_LB:  ctrl_o.load_op = LOAD_BYTE;
                    FUNCT3_LH:  ctrl_o.load_op = LOAD_HALF;
                    FUNCT3_LW:  ctrl_o.load_op = LOAD_WORD;
                    FUNCT3_LBU: ctrl_o.load_op = LOAD_BYTEU;
                    FUNCT3_LHU: ctrl_o.load_op = LOAD_HALFU;
                    default: ;
                endcase
            end

            ST_ST: begin
                state_d = ST_IF_REQ;

                ctrl_o.mem_addr_sel = MEM_ADDR_RESULT;
                ctrl_o.mem_we       = 1'b1;
                ctrl_o.result_sel   = RESULT_ALU_OUT_Q;

                unique case(funct3)
                    FUNCT3_SB: ctrl_o.store_op = STORE_BYTE;
                    FUNCT3_SH: ctrl_o.store_op = STORE_HALF;
                    FUNCT3_SW: ctrl_o.store_op = STORE_WORD;
                    default: ;
                endcase
            end

            ST_WB: begin
                state_d = ST_IF_REQ;

                ctrl_o.reg_we = 1'b1;
                
                unique case (opcode)
                    OPCODE_OP:     ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    OPCODE_OP_IMM: ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    OPCODE_LOAD:   ctrl_o.result_sel = RESULT_LOAD_DATA_Q;
                    OPCODE_AUIPC:  ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    OPCODE_LUI:    ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    OPCODE_JALR:   ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    OPCODE_JAL:    ctrl_o.result_sel = RESULT_ALU_OUT_Q;
                    default: ;
                endcase
            end

            default: ;
        endcase
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            state_q <= ST_IF_REQ;
        end else begin
            state_q <= state_d;
        end
    end

    // branch_op decode
    always_comb begin
        branch_op_o = BRANCH_NONE;

        if (opcode == OPCODE_BRANCH) begin
            unique case (funct3)
                FUNCT3_BEQ:  branch_op_o = BRANCH_EQ;
                FUNCT3_BNE:  branch_op_o = BRANCH_NE;
                FUNCT3_BLT:  branch_op_o = BRANCH_LT;
                FUNCT3_BGE:  branch_op_o = BRANCH_GE;
                FUNCT3_BLTU: branch_op_o = BRANCH_LTU;
                FUNCT3_BGEU: branch_op_o = BRANCH_GEU;
                default: ;
            endcase
        end
    end

    assign trace_valid_o = (state_q == ST_WB) || (state_q == ST_ST) ||
                           ((state_q == ST_EX) && (opcode == OPCODE_BRANCH));

endmodule
