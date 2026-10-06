module uart_wrapper #(
    parameter int CLOCK_RATE = 100_000_000,
    parameter int BAUD_RATE  = 115_200,
    parameter int WIDTH      = 8,
    parameter int DEPTH      = 16
)(
    input  logic        clk_i,
    input  logic        rst_ni,

    output logic        tx_full_o,
    input  logic        tx_we_i,
    input  logic [31:0] tx_data_i,

    output logic        rx_empty_o,
    input  logic        rx_re_i,
    output logic [31:0] rx_data_o,

    output logic        txd_o,
    input  logic        rxd_async_i
);

    // uart_tx channel

    logic             tx_fifo_re;
    logic [WIDTH-1:0] tx_fifo_data;
    logic             tx_fifo_empty;

    logic             tx_core_valid;
    logic             tx_core_ready;
    logic [WIDTH-1:0] tx_core_data;

    sync_fifo #(
        .WIDTH              (WIDTH),
        .DEPTH              (DEPTH)
    ) u_fifo_tx (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .we_i               (tx_we_i),
        .data_i             (tx_data_i[WIDTH-1:0]),
        .re_i               (tx_fifo_re),
        .data_o             (tx_fifo_data),
        .full_o             (tx_full_o),
        .empty_o            (tx_fifo_empty)
    );

    sync_fifo_buffer #(
        .WIDTH              (WIDTH)
    ) u_fifo_buffer_tx (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .fifo_re_o          (tx_fifo_re),
        .fifo_data_i        (tx_fifo_data),
        .fifo_empty_i       (tx_fifo_empty),
        .data_valid_o       (tx_core_valid),
        .data_ready_i       (tx_core_ready),
        .data_o             (tx_core_data)
    );

    uart_tx #(
        .CLOCK_RATE         (CLOCK_RATE),
        .BAUD_RATE          (BAUD_RATE)
    ) u_uart_tx (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .tx_data_valid_i    (tx_core_valid),
        .tx_data_ready_o    (tx_core_ready),
        .tx_data_i          (tx_core_data),
        .txd_o              (txd_o)
    );

    // uart_rx channel

    logic             rx_core_valid;
    logic [WIDTH-1:0] rx_core_data;
    logic [WIDTH-1:0] rx_data;
    logic             rx_valid;

    logic             rx_fifo_re;
    logic [WIDTH-1:0] rx_fifo_data;
    logic             rx_fifo_empty;
    logic             rx_fifo_full;

    uart_rx #(
        .CLOCK_RATE         (CLOCK_RATE),
        .BAUD_RATE          (BAUD_RATE)
    ) u_uart_rx (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .rxd_async_i        (rxd_async_i),
        .rx_data_valid_o    (rx_core_valid),
        .rx_data_o          (rx_core_data),
        .frame_err_o        ()
    );

    sync_fifo #(
        .WIDTH              (WIDTH),
        .DEPTH              (DEPTH)
    ) u_rx_fifo (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .we_i               (rx_core_valid && !rx_fifo_full),
        .data_i             (rx_core_data),
        .re_i               (rx_fifo_re),
        .data_o             (rx_fifo_data),
        .full_o             (rx_fifo_full),
        .empty_o            (rx_fifo_empty)
    );

    sync_fifo_buffer #(
        .WIDTH              (WIDTH)
    ) u_rx_fifo_buffer (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .fifo_re_o          (rx_fifo_re),
        .fifo_data_i        (rx_fifo_data),
        .fifo_empty_i       (rx_fifo_empty),
        .data_valid_o       (rx_valid),
        .data_ready_i       (rx_re_i),
        .data_o             (rx_data)
    );

    assign rx_empty_o = !rx_valid;
    assign rx_data_o  = {{(32-WIDTH){1'b0}}, rx_data};

    

endmodule
