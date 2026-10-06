//-----------------------------------------------------------------------------
//  Module   : uart_rx_core.sv
//  Children : None
//
//  Description:
//     UART RX FSM with 16x oversampling, 8-bit data capture, and stop-bit check.
//
//-----------------------------------------------------------------------------

module uart_rx_core (
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic       baud_x16_en_i,
    input  logic       rxd_i,

    output logic [7:0] rx_data_o,
    output logic       rx_data_valid_o,
    output logic       frame_err_o
);

    localparam logic [3:0] HALF_BIT_TICKS = 4'd7;
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
    logic [7:0] shifter;

    // FSM Next-state logic
    always_comb begin
        state_d = state_q;

        unique case (state_q)
            IDLE: begin
                if (!rxd_i) begin
                    state_d = START;
                end
            end

            START: begin
                if (tick == HALF_BIT_TICKS) begin
                    if (rxd_i) begin        
                        state_d = IDLE;
                    end
                    else begin            
                        state_d = DATA;
                    end
                end
            end

            DATA:  begin
                if (tick == FULL_BIT_TICKS && nbits == 3'd7) begin   
                    state_d = STOP;
                end
            end

            STOP: begin
                if (tick == FULL_BIT_TICKS) begin    
                    state_d = IDLE;
                end
            end

            default: state_d = IDLE;
        endcase
    end 

    // FSM state ff
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            state_q         <= IDLE;
            tick            <= '0;
            nbits           <= '0;
            shifter         <= '0;
            rx_data_o       <= '0;
            rx_data_valid_o <= 1'b0;
            frame_err_o     <= 1'b0;
        end
        else begin
            rx_data_valid_o <= 1'b0;
            frame_err_o     <= 1'b0;

            if (baud_x16_en_i) begin
                state_q <= state_d;

                case (state_q)
                    IDLE: begin
                        tick <= '0;
                    end

                    START: begin
                        tick <= tick + 4'd1;
                        if (tick == HALF_BIT_TICKS) begin
                            tick  <= '0;
                            nbits <= '0;
                        end
                    end

                    DATA: begin
                        tick <= tick + 4'd1;
                        if (tick == FULL_BIT_TICKS) begin
                            tick    <= '0;
                            shifter <= {rxd_i, shifter[7:1]};
                            nbits   <= nbits + 3'd1;
                        end
                    end

                    STOP: begin
                        tick <= tick + 4'd1;
                        if (tick == FULL_BIT_TICKS) begin
                            tick            <= '0;
                            rx_data_o       <= shifter;
                            rx_data_valid_o <= rxd_i;
                            frame_err_o     <= !rxd_i;
                        end
                    end

                endcase
            end
        end
    end

endmodule