//-----------------------------------------------------------------------------
//  Module   : apb_interconnect
//  Children : None
//
//  Description:
//     APB address decoder and slave response mux.
//     Unmapped accesses complete with PSLVERR.
//
//-----------------------------------------------------------------------------
import apb_pkg::*;

module apb_interconnect #(
    parameter int unsigned SLOT_OFFSET_WIDTH = 12,
    parameter int unsigned NUM_SLAVES = 1,
    parameter addr_t BASE_ADDR [NUM_SLAVES] = '{default: 32'h8000_0000}
) (
    apb_if.Slave  cpl,
    apb_if.Master req [NUM_SLAVES]
);

    logic  pselx [NUM_SLAVES];
    logic  ready [NUM_SLAVES];
    logic  error [NUM_SLAVES];
    data_t rdata [NUM_SLAVES];

    for (genvar i = 0; i < NUM_SLAVES; i++) begin
        assign pselx[i] = cpl.psel && (cpl.paddr >> SLOT_OFFSET_WIDTH == 
                                    BASE_ADDR[i] >> SLOT_OFFSET_WIDTH);

        assign req[i].paddr   = cpl.paddr;
        assign req[i].psel    = pselx[i];
        assign req[i].penable = cpl.penable;
        assign req[i].pwrite  = cpl.pwrite;
        assign req[i].pwdata  = cpl.pwdata;
        assign req[i].pstrb   = cpl.pstrb;

        assign ready[i] = req[i].pready;
        assign rdata[i] = req[i].prdata;
        assign error[i] = req[i].pslverr;
    end

    always_comb begin
        cpl.pready  = 1'b1;
        cpl.prdata  = '0;
        cpl.pslverr = cpl.psel && cpl.penable;

        for (int i = 0; i < NUM_SLAVES; i++) begin
            if (pselx[i]) begin
                cpl.pready  = ready[i];
                cpl.prdata  = rdata[i];
                cpl.pslverr = error[i];
            end
        end
    end

    initial begin : check_map
    
        if (NUM_SLAVES == 0)
            $fatal(1, "NUM_SLAVES must be greater than zero");

        if ((SLOT_OFFSET_WIDTH == 0) ||
            (SLOT_OFFSET_WIDTH >= APB_ADDR_WIDTH))
            $fatal(1, "Invalid SLOT_OFFSET_WIDTH");

        for (int i = 0; i < NUM_SLAVES; i++) begin
            if (((BASE_ADDR[i] >> SLOT_OFFSET_WIDTH) << SLOT_OFFSET_WIDTH) != BASE_ADDR[i])
                $fatal(1, "Slave %0d base is not aligned", i);

            for (int j = i + 1; j < NUM_SLAVES; j++) begin
                if ((BASE_ADDR[i] >> SLOT_OFFSET_WIDTH) ==
                    (BASE_ADDR[j] >> SLOT_OFFSET_WIDTH))
                    $fatal(1, "Slave slots %0d and %0d overlap", i, j);
            end
        end
    end

endmodule
