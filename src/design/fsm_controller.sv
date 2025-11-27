//Controlador de FSM para la calculadora de división
//- Maneja la entrada de números, inicio de división, y muestra resultados
//- Controla para mostrar cociente, residuo y errores de división

module fsm_controller(
    input  logic clk_27mhz,
    input  logic reset_n,

    // Entradas del teclado
    input  logic key_is_digit,
    input  logic [3:0] digit_value,

    // Entradas de botones externos
    input  logic btn_div,
    input  logic btn_quot, 
    input  logic btn_rem,
    input  logic btn_clear,

    // Resultados de la división
    input  logic [7:0] quotient,
    input  logic [7:0] remainder,
    input  logic division_done,
    input  logic division_error,

    // Señales de control
    output logic num1_write_en,
    output logic num2_write_en,
    output logic num1_clear,
    output logic num2_clear,
    output logic start_division,

    // Salida al display
    output logic [15:0] display_data_out,

    // Estado actual
    output logic [2:0] current_state
);

    typedef enum logic [2:0] {
        IDLE,
        INPUT_NUM1,
        INPUT_NUM2,
        CALCULATING,
        SHOW_QUOTIENT,
        SHOW_REMAINDER,
        SHOW_ERROR  //para cuando se divide entre cero
    } state_t;

    state_t state_reg, state_next;
    logic [7:0] num1_reg, num2_reg;
    logic last_operation; // 0 = quot, 1 = rem
    logic error_occurred; // Registro para recordar que hubo error

    // REGISTROS DE ESTADO
    always_ff @(posedge clk_27mhz or negedge reset_n) begin
        if (!reset_n) begin
            state_reg      <= IDLE;
            num1_reg       <= '0;
            num2_reg       <= '0;
            last_operation <= 0;
            error_occurred <= 0;
        end 
        else begin
            state_reg <= state_next;

            // Actualizar num1
            if (num1_clear)
                num1_reg <= '0;
            else if (num1_write_en)
                num1_reg <= (num1_reg << 4) | digit_value;

            // Actualizar num2
            if (num2_clear)
                num2_reg <= '0;
            else if (num2_write_en)
                num2_reg <= (num2_reg << 4) | digit_value;

            // Guardar operación seleccionada SOLO cuando corresponde
            if (state_reg == INPUT_NUM2) begin
                if (btn_quot) last_operation <= 0;
                else if (btn_rem) last_operation <= 1;
            end
            
            // Registrar si ocurrió un error
            if (division_done && division_error) begin
                error_occurred <= 1;
            end else if (btn_clear || btn_div) begin
                error_occurred <= 0; // Limpiar error con clear o nueva operación
            end
        end
    end

    // LÓGICA DE SIGUIENTE ESTADO
    always_comb begin
        // Valores por defecto
        state_next     = state_reg;
        num1_write_en  = 1'b0;
        num2_write_en  = 1'b0;
        num1_clear     = 1'b0;
        num2_clear     = 1'b0;
        start_division = 1'b0;

        // Botón CLEAR global
        if (btn_clear) begin
            state_next = IDLE;
            num1_clear = 1'b1;
            num2_clear = 1'b1;
        end
        else begin
            case (state_reg)

                IDLE: begin
                    if (key_is_digit) begin
                        num1_clear    = 1'b1;
                        num1_write_en = 1'b1;
                        state_next    = INPUT_NUM1;
                    end
                end

                INPUT_NUM1: begin
                    if (key_is_digit)
                        num1_write_en = 1'b1;
                    else if (btn_div) begin
                        num2_clear = 1'b1;
                        state_next = INPUT_NUM2;
                    end
                end

                INPUT_NUM2: begin
                    if (key_is_digit) begin
                        num2_write_en = 1'b1;
                    end else if (btn_quot || btn_rem) begin
                        start_division = 1'b1;
                        state_next = CALCULATING;
                    end
                end

                CALCULATING: begin
                    if (division_done) begin
                        if (division_error) begin
                            state_next = SHOW_ERROR;
                        end else if (last_operation == 0) begin
                            state_next = SHOW_QUOTIENT;
                        end else begin
                            state_next = SHOW_REMAINDER;
                        end
                    end
                end

                SHOW_QUOTIENT: begin
                    if (btn_rem)
                        state_next = SHOW_REMAINDER;
                    else if (btn_div) begin
                        num1_clear = 1'b1;
                        num2_clear = 1'b1;
                        state_next = INPUT_NUM1;
                    end
                end

                SHOW_REMAINDER: begin
                    if (btn_quot)
                        state_next = SHOW_QUOTIENT;
                    else if (btn_div) begin
                        num1_clear = 1'b1;
                        num2_clear = 1'b1;
                        state_next = INPUT_NUM1;
                    end
                end
                
                SHOW_ERROR: begin
                    // Permanece en estado de error hasta que el usuario presione clear o div
                    if (btn_clear) begin
                        state_next = IDLE;
                        num1_clear = 1'b1;
                        num2_clear = 1'b1;
                    end else if (btn_div) begin
                        num1_clear = 1'b1;
                        num2_clear = 1'b1;
                        state_next = INPUT_NUM1;
                    end
                end
                
                default: begin
                    state_next = IDLE;
                end
            endcase
        end
    end

    // SALIDA AL DISPLAY
    always_comb begin
        case (state_reg)
            IDLE:            display_data_out = 16'h0000;
            INPUT_NUM1:      display_data_out = {8'h00, num1_reg};
            INPUT_NUM2:      display_data_out = {8'h00, num2_reg};
            CALCULATING:     display_data_out = 16'hDDDD;
            SHOW_QUOTIENT:   display_data_out = {8'h00, quotient};
            SHOW_REMAINDER:  display_data_out = {8'h00, remainder};
            SHOW_ERROR:      display_data_out = 16'hEEEE;  // Mostrar EEEE para error
            default:         display_data_out = 16'h0000;
        endcase
    end

    assign current_state = state_reg;
endmodule