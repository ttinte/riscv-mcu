package soc_addr_map_pkg;

    localparam logic [31:0] APB_BASE_ADDR = 32'h8000_0000;
    localparam logic [31:0] APB_END_ADDR  = 32'h8001_0000;

    localparam logic [31:0] RAM_BASE_ADDR = 32'h0000_0000;
    localparam logic [31:0] RAM_END_ADDR  = 32'h0000_8000;

    localparam int unsigned RAM_DEPTH_WORDS = (RAM_END_ADDR - RAM_BASE_ADDR) / 4;

endpackage
