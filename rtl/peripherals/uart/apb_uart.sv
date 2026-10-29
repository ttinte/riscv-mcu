//-----------------------------------------------------------------------------
//  Module   : apb_uart
//  Children : uart_wrapper
//
//  Description:
//     APB interface for 8-bit UART TX/RX with FIFOs.
//     Transfers normally take 2 APB cycles (SETUP + ACCESS).
//     Software may check STATUS before accessing TX/RX. If the TX FIFO is full
//     or the RX FIFO is empty, PREADY is held low until the transfer can be
//     completed. Invalid register offsets and access directions complete with
//     PSLVERR; temporary FIFO states use wait states instead of bus errors.
//     TX writes use only PSTRB[0]; other lanes are ignored without error.
//
//-----------------------------------------------------------------------------

module apb_uart #(
    parameter int unsigned CLOCK_RATE = 100_000_000,
    parameter int unsigned BAUD_RATE  = 115_200,
    parameter int unsigned FIFO_DEPTH = 32
) (
    input  logic clk_i,
    input  logic rst_ni,
    input  logic rxd_i,
    output logic txd_o,
    apb_if.Slave cpl
);
    import uart_reg_pkg::*;

    logic       tx_full;
    logic       tx_we;
    logic       rx_empty;
    logic       rx_re;
    logic [7:0] rx_data;
    logic       access_error;
    logic       access_done;
    logic       tx_access;
    logic       rx_access;

    always_comb begin
        cpl.prdata   = '0;
        access_error = 1'b0;

        if (cpl.psel) begin
            unique case (cpl.paddr[11:0])
                TX_OFFSET: begin
                    access_error = !cpl.pwrite;
                end

                RX_OFFSET: begin
                    access_error = cpl.pwrite;
                    if (!cpl.pwrite && !rx_empty)
                        cpl.prdata[7:0] = rx_data;
                end

                STATUS_OFFSET: begin
                    access_error = cpl.pwrite;
                    cpl.prdata[0] = tx_full;
                    cpl.prdata[1] = rx_empty;
                end
                
                default: access_error = 1'b1;
            endcase
        end
    end

    assign tx_access = cpl.psel && cpl.pwrite &&
                       (cpl.paddr[11:0] == TX_OFFSET) && cpl.pstrb[0];
    assign rx_access = cpl.psel && !cpl.pwrite &&
                       (cpl.paddr[11:0] == RX_OFFSET);
    assign access_done = cpl.psel && cpl.penable && cpl.pready;

    assign tx_we = access_done && !access_error && tx_access;
    assign rx_re = access_done && !access_error && rx_access;

    uart_wrapper #(
        .CLOCK_RATE         (CLOCK_RATE),
        .BAUD_RATE          (BAUD_RATE),
        .FIFO_DEPTH         (FIFO_DEPTH)
    ) u_uart_wrapper (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .tx_full_o          (tx_full),
        .tx_we_i            (tx_we),
        .tx_data_i          (cpl.pwdata[7:0]),
        .rx_empty_o         (rx_empty),
        .rx_re_i            (rx_re),
        .rx_data_o          (rx_data),
        .txd_o              (txd_o),
        .rxd_async_i        (rxd_i)
    );

    assign cpl.pready  = rst_ni &&
                         !(tx_access && tx_full) &&
                         !(rx_access && rx_empty);
    assign cpl.pslverr = access_done && access_error;

endmodule
