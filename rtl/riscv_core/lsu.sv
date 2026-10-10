import rv32_pkg::*;

module lsu (
    input  logic        we_i,
    input  logic        re_i,
    input  logic [1:0]  addr_lsb_i,
    input  load_op_e    load_op_i,
    input  store_op_e   store_op_i,

    input  logic [31:0] mem_rdata_i,
    output logic [31:0] load_data_o,
    output logic        mem_re_o,
    
    input  logic [31:0] store_data_i,
    output logic [31:0] mem_wdata_o,
    output logic [3:0]  mem_wstrb_o
);

    logic [7:0]  byte_src;
    logic [15:0] half_src;

    assign byte_src = mem_rdata_i[8 * addr_lsb_i +: 8];
    assign half_src = addr_lsb_i[1] ? mem_rdata_i[31:16] : mem_rdata_i[15:0];

    always_comb begin
        load_data_o = mem_rdata_i;
        mem_wdata_o = store_data_i;
        mem_wstrb_o = 4'b0000;

        unique case (load_op_i)
            LOAD_BYTE:  load_data_o = {{24{byte_src[7]}}, byte_src};
            LOAD_HALF:  load_data_o = {{16{half_src[15]}}, half_src};
            LOAD_WORD:  load_data_o = mem_rdata_i;
            LOAD_BYTEU: load_data_o = {24'd0, byte_src};
            LOAD_HALFU: load_data_o = {16'd0, half_src};
            default: ;
        endcase

        if (store_op_i == STORE_BYTE) begin
            unique case (addr_lsb_i)
                2'd0: begin
                    mem_wdata_o = {24'd0, store_data_i[7:0]};
                    mem_wstrb_o = we_i ? 4'b0001 : 4'b0000;
                end
                2'd1: begin
                    mem_wdata_o = {16'd0, store_data_i[7:0], 8'd0};
                    mem_wstrb_o = we_i ? 4'b0010 : 4'b0000;
                end
                2'd2: begin
                    mem_wdata_o = {8'd0, store_data_i[7:0], 16'd0};
                    mem_wstrb_o = we_i ? 4'b0100 : 4'b0000;
                end
                2'd3: begin
                    mem_wdata_o = {store_data_i[7:0], 24'd0};
                    mem_wstrb_o = we_i ? 4'b1000 : 4'b0000;
                end
                default: ;
            endcase
        end
        else if (store_op_i == STORE_HALF) begin
            unique case (addr_lsb_i[1])
                1'b0: begin
                    mem_wdata_o = {16'd0, store_data_i[15:0]};
                    mem_wstrb_o = we_i ? 4'b0011 : 4'b0000;
                end
                1'b1: begin
                    mem_wdata_o = {store_data_i[15:0], 16'd0};
                    mem_wstrb_o = we_i ? 4'b1100 : 4'b0000;
                end
                default: ;
            endcase
        end
        else if (store_op_i == STORE_WORD) begin
            mem_wdata_o = store_data_i;
            mem_wstrb_o = we_i ? 4'b1111 : 4'b0000;
        end
    end

    assign mem_re_o = re_i;
    
endmodule