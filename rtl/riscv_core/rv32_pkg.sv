package rv32_pkg;

    typedef enum logic [6:0] {
        OPCODE_OP     = 7'd51,
        OPCODE_OP_IMM = 7'd19,
        OPCODE_LOAD   = 7'd3,
        OPCODE_STORE  = 7'd35,
        OPCODE_BRANCH = 7'd99,
        OPCODE_AUIPC  = 7'd23,
        OPCODE_LUI    = 7'd55,
        OPCODE_JALR   = 7'd103,
        OPCODE_JAL    = 7'd111
    } opcode_e;

    localparam logic [2:0] FUNCT3_ADD_SUB = 3'b000;     //OP
    localparam logic [2:0] FUNCT3_SLT     = 3'b010;
    localparam logic [2:0] FUNCT3_SLTU    = 3'b011;
    localparam logic [2:0] FUNCT3_XOR     = 3'b100;
    localparam logic [2:0] FUNCT3_OR      = 3'b110;
    localparam logic [2:0] FUNCT3_AND     = 3'b111;
    localparam logic [2:0] FUNCT3_ADDI    = 3'b000;     //OP-IMM
    localparam logic [2:0] FUNCT3_SLTI    = 3'b010;
    localparam logic [2:0] FUNCT3_SLTIU   = 3'b011;
    localparam logic [2:0] FUNCT3_XORI    = 3'b100;
    localparam logic [2:0] FUNCT3_ORI     = 3'b110;
    localparam logic [2:0] FUNCT3_ANDI    = 3'b111;
    localparam logic [2:0] FUNCT3_JALR    = 3'b000;     //JALR
    localparam logic [2:0] FUNCT3_LW      = 3'b010;     //LOAD
    localparam logic [2:0] FUNCT3_SW      = 3'b010;     //STORE
    localparam logic [2:0] FUNCT3_BEQ     = 3'b000;     //BRANCH
    localparam logic [2:0] FUNCT3_BNE     = 3'b001;
    localparam logic [2:0] FUNCT3_BLT     = 3'b100;
    localparam logic [2:0] FUNCT3_BGE     = 3'b101;
    localparam logic [2:0] FUNCT3_BLTU    = 3'b110;
    localparam logic [2:0] FUNCT3_BGEU    = 3'b111;

    localparam logic [6:0] FUNCT7_BASE = 7'b000_0000;   //OP
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
        IMM_U,
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
        ALU_XOR,
        ALU_OR,
        ALU_AND,
        ALU_SLT,
        ALU_SLTU,
        ALU_PASS_B
    } alu_op_e;

    typedef struct packed {
        logic zero;
        logic sign;
        logic carry;
        logic overflow;
    } alu_flags_t;

    typedef enum logic [1:0] {
        RESULT_ALU_COMB,
        RESULT_ALU_OUT_Q,
        RESULT_MEM_DATA_Q
    } result_sel_e;

    typedef struct packed {
        logic           pc_we;
        logic           pc_clear_lsb;
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
