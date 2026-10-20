//-----------------------------------------------------------------------------
//  Module   : apb_subsystem
//  Children : apb_master, apb_interconnect, apb_uart
//
//  Description:
//     Connects CPU requests to APB peripherals.
//     To add a peripheral: instantiate its slave on apb_peripherals_bus[IDX],
//     external pins, update apb_addr_map and add its register map to firmware.
//
//-----------------------------------------------------------------------------

module apb_subsystem #(
    parameter int unsigned CLOCK_RATE = 100_000_000,
    parameter int unsigned BAUD_RATE  = 115_200,
    parameter int unsigned FIFO_DEPTH = 32
) (
    input  logic           clk_i,
    input  logic           rst_ni,
    input  logic           req_valid_i,
    output logic           rsp_ready_o,
    output logic           rsp_error_o,

    input  apb_pkg::addr_t addr_i,
    input  logic           write_i,
    input  apb_pkg::data_t wdata_i,
    input  apb_pkg::strb_t wstrb_i,
    output apb_pkg::data_t rdata_o,

    input  logic           rxd_i,
    output logic           txd_o
);

    apb_if apb_ctrl_bus();
    apb_if apb_peripherals_bus[apb_addr_map_pkg::NUM_SLAVES]();

    apb_master u_apb_master (
        .pclk_i             (clk_i),
        .preset_ni          (rst_ni),
        .req_valid_i        (req_valid_i),
        .rsp_ready_o        (rsp_ready_o),
        .rsp_error_o        (rsp_error_o),
        .addr_i             (addr_i),
        .write_i            (write_i),
        .wdata_i            (wdata_i),
        .wstrb_i            (wstrb_i),
        .rdata_o            (rdata_o),
        .req                (apb_ctrl_bus)
    );

    apb_interconnect #(
        .SLOT_OFFSET_WIDTH  (apb_addr_map_pkg::SLOT_OFFSET_WIDTH),
        .NUM_SLAVES         (apb_addr_map_pkg::NUM_SLAVES),
        .BASE_ADDR          (apb_addr_map_pkg::PERIPH_BASE_ADDR)
    ) u_apb_interconnect (
        .cpl                (apb_ctrl_bus),
        .req                (apb_peripherals_bus)
    );

    apb_uart #(
        .CLOCK_RATE         (CLOCK_RATE),
        .BAUD_RATE          (BAUD_RATE),
        .FIFO_DEPTH         (FIFO_DEPTH)
    ) u_apb_uart0 (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .rxd_i              (rxd_i),
        .txd_o              (txd_o),
        .cpl                (apb_peripherals_bus[apb_addr_map_pkg::UART0_IDX])
    );

endmodule
