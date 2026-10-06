//-----------------------------------------------------------------------------
//  Module   : baud_gen.sv
//  Children : None
//
//  Description:
//     Generates a one-clock 16x baud-rate enable pulse.
//
//-----------------------------------------------------------------------------

module baud_gen #(
    parameter int CLOCK_RATE = 100_000_000,
    parameter int BAUD_RATE  = 115_200
)(
    input  logic clk_i,
    input  logic rst_ni,
    output logic baud_x16_en_o
);

    initial begin
        if (CLOCK_RATE == 0)
            $fatal(1, "CLOCK_RATE must be greater than zero");
        if (BAUD_RATE == 0)
            $fatal(1, "BAUD_RATE must be greater than zero");
        if (CLOCK_RATE < 16*BAUD_RATE)
            $fatal(1, "CLOCK_RATE must be at least 16 times BAUD_RATE");
    end

    localparam int OVERSAMPLE_RATE = 16 * BAUD_RATE;
    localparam int DIVIDER         = (CLOCK_RATE + OVERSAMPLE_RATE/2) / OVERSAMPLE_RATE;
    localparam int CNT_WIDTH       = $clog2(DIVIDER);

    logic [CNT_WIDTH-1:0] cnt;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            cnt           <= '0;
            baud_x16_en_o <= 1'b0;
        end
        else begin
            if (cnt == CNT_WIDTH'(DIVIDER-1)) begin
                cnt           <= '0;
                baud_x16_en_o <= 1'b1;
            end
            else begin
                cnt           <= cnt + 1'b1;
                baud_x16_en_o <= 1'b0;
            end
        end
    end

endmodule