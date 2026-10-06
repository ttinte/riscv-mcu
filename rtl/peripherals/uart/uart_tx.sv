//-----------------------------------------------------------------------------
//  Project  : UART Transmitter
//  Module   : uart_tx
//  Children : baud_gen, uart_tx_core
//
//  Description:
//     Top-level UART TX wrapper with baud generator and TX core.
//
//-----------------------------------------------------------------------------

module uart_tx #(
    parameter int CLOCK_RATE = 100_000_000,
    parameter int BAUD_RATE  = 115_200
)(
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic       tx_data_valid_i,
    output logic       tx_data_ready_o,
    input  logic [7:0] tx_data_i,
    output logic       txd_o
);

    logic baud_x16_en;

    baud_gen #(
        .CLOCK_RATE (CLOCK_RATE),
        .BAUD_RATE  (BAUD_RATE)
    ) u_baud_gen (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .baud_x16_en_o      (baud_x16_en)
    );

    uart_tx_core u_uart_tx_core (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .baud_x16_en_i      (baud_x16_en),
        .tx_data_i          (tx_data_i),
        .tx_data_valid_i    (tx_data_valid_i),
        .tx_data_ready_o    (tx_data_ready_o),
        .txd_o              (txd_o)
    );

endmodule
