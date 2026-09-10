import rv32_pkg::*;

module imm_gen (
    input  imm_sel_e    imm_sel_i,
    input  logic [31:0] instr_i,
    output logic [31:0] imm_ext_o
);

    always_comb begin
        unique case (imm_sel_i)
            IMM_NONE: imm_ext_o = '0;

            IMM_I: imm_ext_o = {
                {20{instr_i[31]}}, 
                instr_i[31:20]
            };

            IMM_S: imm_ext_o = {
                {20{instr_i[31]}}, 
                instr_i[31:25], 
                instr_i[11:7]
            };

            IMM_B: imm_ext_o = {
                {19{instr_i[31]}}, 
                instr_i[31], 
                instr_i[7], 
                instr_i[30:25], 
                instr_i[11:8], 
                1'b0
            };

            IMM_J: imm_ext_o = {
                {11{instr_i[31]}},
                instr_i[31],
                instr_i[19:12],
                instr_i[20],
                instr_i[30:21],
                1'b0
            };

            default: imm_ext_o = '0;
        endcase
    end

endmodule