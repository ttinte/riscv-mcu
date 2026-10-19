module apb_master (
    input  logic           pclk_i,
    input  logic           preset_ni,
    input  logic           req_valid_i,
    output logic           rsp_ready_o,
    output logic           rsp_error_o,

    input  apb_pkg::addr_t addr_i,
    input  logic           write_i,
    input  apb_pkg::data_t wdata_i,
    input  apb_pkg::strb_t wstrb_i,
    output apb_pkg::data_t rdata_o,

    apb_if.Master          req
);

    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS,
        RESP
    } state_e;

    state_e state_q, state_d;
    logic   error_q;

    always_comb begin
        state_d = state_q;

        unique case (state_q)
            IDLE:   state_d = req_valid_i ? SETUP : IDLE;
            SETUP:  state_d = ACCESS;
            ACCESS: state_d = req.pready ? RESP : ACCESS;
            RESP:   state_d = IDLE;
        endcase
    end

    always_ff @(posedge pclk_i) begin
        if (!preset_ni) begin
            state_q    <= IDLE;
            req.paddr  <= '0;
            req.pwrite <= 1'b0;
            req.pwdata <= '0;
            req.pstrb  <= '0;
            error_q    <= 1'b0;
            rdata_o    <= '0;
        end
        else begin
            state_q <= state_d;

            if (req_valid_i && (state_q == IDLE)) begin
                req.paddr  <= addr_i;
                req.pwrite <= write_i;
                req.pwdata <= wdata_i;
                req.pstrb  <= write_i ? wstrb_i : '0;
            end

            if ((state_q == ACCESS) && req.pready) begin
                error_q <= req.pslverr;
                if (!req.pwrite) rdata_o <= req.prdata;
            end
        end
    end

    assign req.psel    = ((state_q == SETUP) || (state_q == ACCESS));
    assign req.penable = (state_q == ACCESS);
    assign rsp_ready_o = (state_q == RESP);
    assign rsp_error_o = (state_q == RESP) && error_q;

endmodule