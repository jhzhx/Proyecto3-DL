//Usamos el ejemplo del profesor -- Eliminador de rebote
//Espera un tiempo de 20 ms, si la señal permanece estable, genera un pulso (tick_out)
//El tick_out significa que la tecla (señal) es real y estable, que no fue rebote

module debouncer #(
    parameter CLK_FREQ = 27_000_000,
    parameter DEBOUNCE_TIME_MS = 20
)(
    input  logic clk,
    input  logic reset_n,
    input  logic noisy_in,
    output logic clean_level,
    output logic tick_out
);
    localparam COUNTER_MAX = (CLK_FREQ / 1000) * DEBOUNCE_TIME_MS;
    localparam N = $clog2(COUNTER_MAX);
    typedef enum logic [1:0] { ZERO, WAIT1, ONE, WAIT0 } state_t;
    state_t state_reg, state_next;
    logic [N-1:0] q_reg, q_next;
    wire q_is_zero;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state_reg <= ZERO; q_reg <= '0;
        end else begin
            state_reg <= state_next; q_reg <= q_next;
        end
    end

    assign q_next = (state_reg == ZERO || state_reg == ONE) ? COUNTER_MAX - 1 :
                    (q_is_zero) ? '0 : q_reg - 1;
    assign q_is_zero = (q_reg == 0);

    always_comb begin
        state_next = state_reg;
        tick_out = 1'b0;
        clean_level = (state_reg == ONE || state_reg == WAIT0);
        case (state_reg)
            ZERO:  if (noisy_in) state_next = WAIT1;
            WAIT1: if (!noisy_in) state_next = ZERO;
                   else if (q_is_zero) begin state_next = ONE; tick_out = 1'b1; end
            ONE:   if (!noisy_in) state_next = WAIT0;
            WAIT0: if (noisy_in) state_next = ONE;
                   else if (q_is_zero) begin state_next = ZERO; tick_out = 1'b1; end
            default: state_next = ZERO;
        endcase
    end
endmodule