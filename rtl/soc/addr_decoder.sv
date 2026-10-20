import soc_addr_map_pkg::*;

module addr_decoder #(
    parameter int unsigned DEPTH_WORDS = RAM_DEPTH_WORDS
) (
    input  logic        clk_i,
    input  logic        rst_ni,

    input  logic        valid_i,
    output logic        ready_o,
    output logic        error_o,
    input  logic [31:0] addr_i,
    input  logic        we_i,
    output logic [31:0] rdata_o,

    output logic        ram_valid_o,
    input  logic        ram_ready_i,
    output logic        ram_write_o,
    input  logic [31:0] ram_rdata_i,

    output logic        apb_valid_o,
    input  logic        apb_ready_i,
    input  logic        apb_error_i,
    output logic        apb_write_o,
    input  logic [31:0] apb_rdata_i
);

    initial begin : check_memory_map
        if (64'd4 * DEPTH_WORDS > 64'(APB_BASE_ADDR))
            $fatal(1, "RAM overlaps or exceeds APB base");
    end

    typedef enum logic [1:0]{
        RSP_NONE,
        RSP_RAM,
        RSP_APB,
        RSP_ERR
    } rsp_sel_e;

    rsp_sel_e rsp_sel_d, rsp_sel_q;

    always_comb begin
        rsp_sel_d    = RSP_NONE;
        ram_valid_o  = 1'b0;
        ram_write_o  = 1'b0;
        apb_valid_o  = 1'b0;
        apb_write_o  = 1'b0;

        if ((addr_i >= RAM_BASE_ADDR) && (addr_i < RAM_BASE_ADDR + 4 * DEPTH_WORDS)) begin
            rsp_sel_d   = valid_i ? RSP_RAM : RSP_NONE;
            ram_valid_o = valid_i;
            ram_write_o = we_i;
        end
        else if ((addr_i >= APB_BASE_ADDR) && (addr_i < APB_END_ADDR)) begin
            rsp_sel_d   = valid_i ? RSP_APB : RSP_NONE;
            apb_valid_o = valid_i;
            apb_write_o = we_i;
        end
        else begin
            rsp_sel_d = valid_i ? RSP_ERR : RSP_NONE;
        end
    end

    always_comb begin
        ready_o = 1'b0;
        error_o = 1'b0;
        rdata_o = '0;

        unique case (rsp_sel_q)
            RSP_RAM: begin
                ready_o = ram_ready_i;
                rdata_o = ram_rdata_i;
            end
            RSP_APB: begin
                ready_o = apb_ready_i;
                error_o = apb_error_i;
                rdata_o = apb_rdata_i;
            end
            RSP_ERR: begin
                ready_o = 1'b1;
                error_o = 1'b1;
            end
            default: ;
        endcase
    end

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if (!rst_ni) begin
            rsp_sel_q <= RSP_NONE;
        end
        else begin
            rsp_sel_q <= rsp_sel_d;
        end
    end

endmodule
