package apb_pkg;

    localparam int unsigned APB_ADDR_WIDTH = 32;
    localparam int unsigned APB_DATA_WIDTH = 32;
    localparam int unsigned APB_STRB_WIDTH = APB_DATA_WIDTH / 8;

    typedef logic [APB_ADDR_WIDTH-1:0] addr_t;
    typedef logic [APB_DATA_WIDTH-1:0] data_t;
    typedef logic [APB_STRB_WIDTH-1:0] strb_t;

endpackage
