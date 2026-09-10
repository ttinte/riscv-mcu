module mem #(
    parameter int unsigned DEPTH_WORDS = 256
) (
    input  logic        clk_i,
    input  logic        we_i,
    input  logic        re_i,
    input  logic [31:0] addr_i,
    input  logic [31:0] wr_data_i,
    output logic [31:0] rd_data_o
);

    logic [31:0] mem_q [0:DEPTH_WORDS-1];
    logic [$clog2(DEPTH_WORDS)-1:0] word_index;

    assign word_index = addr_i[$clog2(DEPTH_WORDS)+1:2];
    assign rd_data_o  = re_i ? mem_q[word_index] : 32'd0;

    always_ff @(posedge clk_i) begin
        if (we_i) begin
            mem_q[word_index] <= wr_data_i;
        end
    end

endmodule