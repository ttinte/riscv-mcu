//-----------------------------------------------------------------------------
//  Module   : sync_fifo_buffer.sv
//  Children : None
//
//  Description:
//     Read-side adapter for a standard synchronous FIFO.
//
//-----------------------------------------------------------------------------

module sync_fifo_buffer #(
    parameter int WIDTH = 8
)(
    input  logic             clk_i,
    input  logic             rst_ni,

    output logic             fifo_re_o,
    input  logic [WIDTH-1:0] fifo_data_i,
    input  logic             fifo_empty_i,

    output logic             data_valid_o,
    input  logic             data_ready_i,
    output logic [WIDTH-1:0] data_o
);

    logic take_data;
    logic load_pending;
    logic start_load;

    assign take_data  = data_valid_o && data_ready_i;
    assign start_load = rst_ni && !fifo_empty_i && !load_pending && (!data_valid_o || take_data);
    assign fifo_re_o  = start_load;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            load_pending  <= 1'b0;
            data_o        <= '0;
            data_valid_o  <= 1'b0;
        end
        else begin
            if (take_data) begin
                data_valid_o <= 1'b0;
            end

            if (load_pending) begin
                data_o         <= fifo_data_i;
                data_valid_o   <= 1'b1;
                load_pending   <= 1'b0;
            end

            if (start_load) begin
                load_pending <= 1'b1;
            end
        end
    end

endmodule
