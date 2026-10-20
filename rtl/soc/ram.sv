module ram #(
    parameter int unsigned DEPTH_WORDS = 8192,
    parameter string       INIT_FILE   = ""
) (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        valid_i,
    output logic        ready_o,
    input  logic [31:0] addr_i,
    input  logic        write_i,
    input  logic [31:0] wdata_i,
    input  logic [3:0]  wstrb_i,
    output logic [31:0] rdata_o
);

    initial begin : check_ram
        if (DEPTH_WORDS < 2)
            $fatal(1, "DEPTH_WORDS must be at least 2");
    end

    (* ram_style = "block" *)
    logic [31:0] mem [0:DEPTH_WORDS-1];
    logic [$clog2(DEPTH_WORDS)-1:0] word_idx;
    logic accept;

    initial begin
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    assign word_idx = addr_i[$clog2(DEPTH_WORDS)+1:2];
    assign accept   = rst_ni && valid_i && !ready_o;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            ready_o <= 1'b0;
        end else begin
            ready_o <= accept;
        end
    end

    always_ff @(posedge clk_i) begin
        if (accept) begin
            if (write_i) begin
                if (wstrb_i[0]) mem[word_idx][7:0]   <= wdata_i[7:0];
                if (wstrb_i[1]) mem[word_idx][15:8]  <= wdata_i[15:8];
                if (wstrb_i[2]) mem[word_idx][23:16] <= wdata_i[23:16];
                if (wstrb_i[3]) mem[word_idx][31:24] <= wdata_i[31:24];
            end
            else if (!write_i) begin
                rdata_o <= mem[word_idx];
            end
        end
    end

endmodule