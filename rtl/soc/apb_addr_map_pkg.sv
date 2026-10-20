//-----------------------------------------------------------------------------
//  Packages : apb_addr_map_pkg, uart_reg_pkg
//
//  Description:
//     Shared peripherals address map and register offsets.
//     NUM_SLAVES and PERIPH_BASE_ADDR must match the enabled peripheral branches.
//     To add a peripheral: allocate a unique index, increase NUM_SLAVES,
//     and add its aligned, non-overlapping BASE_ADDR entry.
//
//-----------------------------------------------------------------------------

package apb_addr_map_pkg;
    localparam int unsigned SLOT_OFFSET_WIDTH = 12;

    localparam int unsigned UART0_IDX  = 0;
    localparam int unsigned NUM_SLAVES = 1;

    localparam apb_pkg::addr_t PERIPH_BASE_ADDR [NUM_SLAVES] = '{
        UART0_IDX:  32'h8000_0000
    };

endpackage

package uart_reg_pkg;

    localparam logic [11:0] TX_OFFSET     = 12'h000;
    localparam logic [11:0] RX_OFFSET     = 12'h004;
    localparam logic [11:0] STATUS_OFFSET = 12'h008;

endpackage
