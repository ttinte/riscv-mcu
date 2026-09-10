module regfile (
    input  logic        clk_i,
    input  logic        we_i,
    input  logic [4:0]  rd_i,
    input  logic [4:0]  rs1_i,
    input  logic [4:0]  rs2_i,
    input  logic [31:0] wr_data_i,
    output logic [31:0] rs1_data_o,
    output logic [31:0] rs2_data_o
);

    logic [31:0] regs_q [1:31];

    always_ff @(posedge clk_i) begin
        if (we_i && (rd_i != 5'd0)) begin
            regs_q[rd_i] <= wr_data_i;
        end
    end

    always_comb begin
        rs1_data_o = 32'd0;
        rs2_data_o = 32'd0;

        if (rs1_i != 5'd0) begin
            rs1_data_o = regs_q[rs1_i];
        end
        if (rs2_i != 5'd0) begin
            rs2_data_o = regs_q[rs2_i];
        end
    end

endmodule
