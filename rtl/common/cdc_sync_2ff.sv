//-----------------------------------------------------------------------------
//  Module   : cdc_sync_2ff.sv
//  Children : None
//
//  Description:
//     Two-flop synchronizer for a single asynchronous input.
//
//-----------------------------------------------------------------------------

module cdc_sync_2ff #(
    parameter logic RESET_VALUE = 1'b0
)(
    input  logic clk_i,
    input  logic rst_ni,
    input  logic async_i,
    output logic sync_o
);

    (* ASYNC_REG = "TRUE" *) logic sync_ff1, sync_ff2;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            sync_ff1 <= RESET_VALUE;
            sync_ff2 <= RESET_VALUE;
        end
        else begin
            sync_ff1 <= async_i;
            sync_ff2 <= sync_ff1;
        end
    end

    assign sync_o = sync_ff2;

endmodule