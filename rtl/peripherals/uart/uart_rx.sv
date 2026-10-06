//-----------------------------------------------------------------------------
//  Project  : UART Receiver
//  Module   : uart_rx
//  Children : baud_gen, uart_rx_core
//
//  Description:
//     Top-level UART RX wrapper with input sync, baud generator, and RX core.
//
//-----------------------------------------------------------------------------

module uart_rx #(
    parameter int CLOCK_RATE = 100_000_000,
    parameter int BAUD_RATE  = 115_200
)(
    input  logic clk_i,
    input  logic rst_ni,
    input  logic rxd_async_i,
    output logic [7:0] rx_data_o,
    output logic rx_data_valid_o,
    output logic frame_err_o
);

    logic baud_x16_en;
    logic rxd;

    cdc_sync_2ff #(
        .RESET_VALUE (1'b1)
    ) u_rxd_sync (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .async_i            (rxd_async_i),
        .sync_o             (rxd)
    );

    baud_gen #(
        .CLOCK_RATE (CLOCK_RATE),
        .BAUD_RATE  (BAUD_RATE)
    ) u_baud_gen (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .baud_x16_en_o      (baud_x16_en)
    );

    uart_rx_core u_uart_rx_core (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .baud_x16_en_i      (baud_x16_en),
        .rxd_i              (rxd),
        .rx_data_o          (rx_data_o),
        .rx_data_valid_o    (rx_data_valid_o),
        .frame_err_o        (frame_err_o)
    );

endmodule