//-----------------------------------------------------------------------------
//  Module   : sync_fifo.sv
//  Children : None
//
//  Description:
//     Standard synchronous FIFO with registered read data.
//
//-----------------------------------------------------------------------------

module sync_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16
)(
    input  logic             clk_i,
    input  logic             rst_ni,

    input  logic             we_i,
    input  logic [WIDTH-1:0] data_i,

    input  logic             re_i,
    output logic [WIDTH-1:0] data_o,

    output logic             full_o,
    output logic             empty_o
);

    initial begin
        if (WIDTH == 0)
            $fatal(1, "FIFO WIDTH must be greater than zero");

        if (DEPTH == 0)
            $fatal(1, "FIFO DEPTH must be greater than zero");
    end

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    logic [$clog2(DEPTH)-1:0] wr_ptr;
    logic [$clog2(DEPTH)-1:0] rd_ptr;

    logic [$clog2(DEPTH+1)-1:0] count;

    assign full_o  = (count == DEPTH);
    assign empty_o = (count == '0);


    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            wr_ptr  <= '0;
            rd_ptr  <= '0;
            count   <= '0;
            data_o  <= '0;
        end
        else begin
            if (we_i && !full_o) begin
                mem[wr_ptr] <= data_i;

                if (wr_ptr == DEPTH-1)
                    wr_ptr <= '0;
                else
                    wr_ptr <= wr_ptr + 1'b1;
                
                if (re_i && !empty_o)
                    count <= count;
                else
                    count <= count + 1'b1;
            end

            if (re_i && !empty_o) begin
                data_o <= mem[rd_ptr];
                
                if (rd_ptr == DEPTH-1)
                    rd_ptr <= '0;
                else
                    rd_ptr <= rd_ptr + 1'b1;

                if (we_i && !full_o)
                    count <= count;
                else
                    count <= count - 1'b1;
            end
        end
    end

endmodule
