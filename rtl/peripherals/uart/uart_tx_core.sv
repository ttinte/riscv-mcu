//-----------------------------------------------------------------------------
//  Module   : uart_tx_core.sv
//  Children : None
//
//  Description:
//     UART TX FSM with 16x baud timing, start bit, 8 data bits, and stop bit.
//
//-----------------------------------------------------------------------------

module uart_tx_core (
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic       baud_x16_en_i,

    input  logic [7:0] tx_data_i,
    input  logic       tx_data_valid_i,

    output logic       tx_data_ready_o,
    output logic       txd_o
);

    localparam logic [3:0] FULL_BIT_TICKS = 4'd15;

    // FSM states
    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_e;

    state_e state_q, state_d;

    logic [3:0] tick;
    logic [2:0] nbits;
    logic [7:0] tx_data_reg;

    // FSM Next-state logic
    always_comb begin
        state_d = state_q;

        unique case (state_q)
            IDLE: begin
                if (tx_data_valid_i && tx_data_ready_o) begin
                    state_d = START;
                end
            end

            START: begin
                if (baud_x16_en_i && tick == FULL_BIT_TICKS) begin
                    state_d = DATA;
                end
            end

            DATA: begin
                if (baud_x16_en_i && tick == FULL_BIT_TICKS && nbits == 3'd7) begin
                    state_d = STOP;
                end
            end

            STOP: begin
                if (baud_x16_en_i && tick == FULL_BIT_TICKS) begin
                    state_d = IDLE;
                end
            end

            default: state_d = IDLE;
        endcase
    end

    // FSM state ffs
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            state_q     <= IDLE;
            tick        <= '0;
            nbits       <= '0;
            tx_data_reg <= '0;
            txd_o       <= 1'b1;
        end
        else begin
            state_q <= state_d;
            
            if (tx_data_valid_i && tx_data_ready_o) begin
                tx_data_reg <= tx_data_i;
            end

            case (state_q)
                IDLE: begin
                    txd_o <= 1'b1;
                    tick  <= '0;
                end

                START: begin
                    if (baud_x16_en_i) begin
                        txd_o <= 1'b0;

                        tick <= tick + 4'd1;
                        if (tick == FULL_BIT_TICKS) begin
                            tick  <= '0;
                            nbits <= '0;
                        end
                    end
                end

                DATA: begin
                    if (baud_x16_en_i) begin
                        txd_o <= tx_data_reg[nbits];

                        tick <= tick + 4'd1;
                        if (tick == FULL_BIT_TICKS) begin
                            tick  <= '0;
                            nbits <= nbits + 3'd1;
                        end
                    end
                end

                STOP: begin
                    if (baud_x16_en_i) begin
                        txd_o <= 1'b1;

                        tick <= tick + 4'd1;
                        if (tick == FULL_BIT_TICKS) begin
                            tick <= '0;
                        end
                    end
                end
            endcase
        end
    end

    assign tx_data_ready_o = rst_ni && (state_q == IDLE);

endmodule
