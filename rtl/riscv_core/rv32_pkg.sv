package rv32_pkg;

    typedef enum logic [6:0] {
        OPCODE_OP     = 7'b011_0011,    //R_type
        OPCODE_OP_IMM = 7'b001_0011,    //I_type
        OPCODE_LOAD   = 7'b000_0011,    //I_type
        OPCODE_STORE  = 7'b010_0011,    //S_type
        OPCODE_BRANCH = 7'b110_0011,    //B_type
        OPCODE_JAL    = 7'b110_1111     //J_type
    } opcode_e;

    localparam logic [2:0] FUNCT3_ADD_SUB = 3'b000;
    localparam logic [2:0] FUNCT3_SLT     = 3'b010;
    localparam logic [2:0] FUNCT3_OR      = 3'b110;
    localparam logic [2:0] FUNCT3_AND     = 3'b111;
    localparam logic [2:0] FUNCT3_ADDI    = 3'b000;
    localparam logic [2:0] FUNCT3_LW      = 3'b010;
    localparam logic [2:0] FUNCT3_SW      = 3'b010;
    localparam logic [2:0] FUNCT3_BEQ     = 3'b000;

    localparam logic [6:0] FUNCT7_BASE = 7'b000_0000;
    localparam logic [6:0] FUNCT7_SUB  = 7'b010_0000;

    typedef enum logic {
        MEM_ADDR_PC,
        MEM_ADDR_RESULT
    } mem_addr_sel_e;

    typedef enum logic [2:0] {
        IMM_NONE,
        IMM_I,
        IMM_S,
        IMM_B,
        IMM_J
    } imm_sel_e;

    typedef enum logic [1:0] {
        OP_A_PC,
        OP_A_OLD_PC,
        OP_A_RS1
    } op_a_sel_e;

    typedef enum logic [1:0] {
        OP_B_FOUR,
        OP_B_RS2,
        OP_B_IMM
    } op_b_sel_e;

    typedef enum logic [2:0] {
        ALU_ADD,
        ALU_SUB,
        ALU_OR,
        ALU_AND,
        ALU_SLT
    } alu_op_e;

    typedef enum logic [1:0] {
        RESULT_ALU_COMB,
        RESULT_ALU_OUT_Q,
        RESULT_MEM_DATA
    } result_sel_e;

    typedef struct packed {
        logic           pc_we;
        mem_addr_sel_e  mem_addr_sel;
        logic           mem_we;
        logic           mem_re;
        logic           ir_we;
        logic           reg_we;
        imm_sel_e       imm_sel;
        op_a_sel_e      op_a_sel;
        op_b_sel_e      op_b_sel;
        alu_op_e        alu_op;
        result_sel_e    result_sel;
    } decode_ctrl_t;

endpackage
