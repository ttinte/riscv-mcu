import rv32_pkg::*;

module rv32_core (
    input  logic        clk_i,
    input  logic        rst_ni,

    output logic        mem_we_o,
    output logic        mem_re_o,
    output logic [31:0] mem_addr_o,
    output logic [31:0] mem_wr_data_o,
    input  logic [31:0] mem_rd_data_i,

    output logic        trace_valid_o,
    output logic [31:0] trace_pc_o,
    output logic [31:0] trace_instr_o,
    output logic        trace_rf_we_o,
    output logic [4:0]  trace_rf_rd_o,
    output logic [31:0] trace_rf_wr_data_o
);

    decode_ctrl_t ctrl;
    logic         take_branch;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] imm_ext;
    logic [31:0] alu_result;
    alu_flags_t  alu_flags;

    logic [31:0] mem_addr;
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [31:0] result;

    logic [31:0] pc_q;
    logic [31:0] old_pc_q;
    logic [31:0] instr_q;
    logic [31:0] mem_rd_data_q;
    logic [31:0] rs1_data_q;
    logic [31:0] rs2_data_q;
    logic [31:0] imm_u_q;
    logic [31:0] alu_out_q;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            pc_q          <= '0;
            old_pc_q      <= '0;
            instr_q       <= '0;
            mem_rd_data_q <= '0;
            rs1_data_q    <= '0;
            rs2_data_q    <= '0;
            imm_u_q       <= '0;
            alu_out_q     <= '0;
        end
        else begin
            pc_q          <= ctrl.pc_we ? result        : pc_q;
            old_pc_q      <= ctrl.ir_we ? pc_q          : old_pc_q;
            instr_q       <= ctrl.ir_we ? mem_rd_data_i : instr_q;
            mem_rd_data_q <= mem_rd_data_i;
            rs1_data_q    <= rs1_data;
            rs2_data_q    <= rs2_data;
            imm_u_q       <= imm_ext;
            alu_out_q     <= alu_result;
        end
    end 

    always_comb begin
        mem_addr  = pc_q;
        operand_a = pc_q;
        operand_b = 32'd4;
        result    = alu_result;

        if (ctrl.op_a_sel == OP_A_OLD_PC) begin
            operand_a = old_pc_q;
        end else if (ctrl.op_a_sel == OP_A_RS1) begin
            operand_a = rs1_data_q;
        end

        if (ctrl.op_b_sel == OP_B_RS2) begin
            operand_b = rs2_data_q;
        end else if (ctrl.op_b_sel == OP_B_IMM) begin
            operand_b = imm_ext;
        end

        if (ctrl.result_sel == RESULT_ALU_OUT_Q) begin
            result = ctrl.pc_clear_lsb ? {alu_out_q[31:1], 1'b0} : alu_out_q;
        end else if (ctrl.result_sel == RESULT_MEM_DATA_Q) begin
            result = mem_rd_data_q;
        end else if (ctrl.result_sel == RESULT_IMM_U_Q) begin
            result = imm_u_q;
        end

        if (ctrl.mem_addr_sel == MEM_ADDR_RESULT) begin
            mem_addr = result;
        end
    end

    assign mem_we_o      = ctrl.mem_we;
    assign mem_re_o      = ctrl.mem_re;
    assign mem_addr_o    = mem_addr;
    assign mem_wr_data_o = rs2_data_q;

    control_unit u_control_unit (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .take_branch_i      (take_branch),
        .instr_i            (instr_q),
        .ctrl_o             (ctrl),
        .trace_valid_o      (trace_valid_o)
    );

    branch_unit u_branch_unit (
        .br_funct3_i        (instr_q[14:12]),
        .alu_flags_i        (alu_flags),
        .take_branch_o      (take_branch)
    );

    regfile u_regfile (
        .clk_i              (clk_i),
        .we_i               (ctrl.reg_we),
        .rd_i               (instr_q[11:7]),
        .rs1_i              (instr_q[19:15]),
        .rs2_i              (instr_q[24:20]),
        .wr_data_i          (result),
        .rs1_data_o         (rs1_data),
        .rs2_data_o         (rs2_data)
    );

    imm_gen u_imm_gen (
        .imm_sel_i          (ctrl.imm_sel),
        .instr_i            (instr_q),
        .imm_ext_o          (imm_ext)
    );

    alu u_alu (
        .alu_op_i           (ctrl.alu_op),
        .operand_a_i        (operand_a),
        .operand_b_i        (operand_b),
        .alu_result_o       (alu_result),
        .alu_flags_o        (alu_flags)
    );

    assign trace_pc_o         = old_pc_q;
    assign trace_instr_o      = instr_q;
    assign trace_rf_we_o      = ctrl.reg_we && (instr_q[11:7] != 5'd0);
    assign trace_rf_rd_o      = instr_q[11:7];
    assign trace_rf_wr_data_o = result;

endmodule