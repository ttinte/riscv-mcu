interface apb_if;

    apb_pkg::addr_t paddr;
    logic           psel;
    logic           penable;
    logic           pwrite;
    apb_pkg::data_t pwdata;
    apb_pkg::strb_t pstrb;
    logic           pready;
    apb_pkg::data_t prdata;
    logic           pslverr;

    modport Master (
        input  pready, prdata, pslverr,
        output paddr, psel, penable, pwrite, pwdata, pstrb
    );

    modport Slave (
        input  paddr, psel, penable, pwrite, pwdata, pstrb,
        output pready, prdata, pslverr
    );

    initial begin : check_widths
        if ((apb_pkg::APB_ADDR_WIDTH < 1) ||
            (apb_pkg::APB_ADDR_WIDTH > 32))
            $fatal(1, "APB_ADDR_WIDTH must be between 1 and 32");

        if ((apb_pkg::APB_DATA_WIDTH != 8) &&
            (apb_pkg::APB_DATA_WIDTH != 16) &&
            (apb_pkg::APB_DATA_WIDTH != 32))
            $fatal(1, "APB_DATA_WIDTH must be 8, 16 or 32");

        if (apb_pkg::APB_STRB_WIDTH != apb_pkg::APB_DATA_WIDTH / 8)
            $fatal(1, "APB_STRB_WIDTH must equal APB_DATA_WIDTH / 8");
    end

endinterface
