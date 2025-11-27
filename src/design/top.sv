module top (
    input  logic clk_27mhz,
    input  logic reset_n,
    output logic [3:0] keypad_cols,
    input  logic [3:0] keypad_rows,
    input  logic btn_div,      // Botón 1: pasar al siguiente número
    input  logic btn_quot,     // Botón 2: calcular cociente  
    input  logic btn_rem,      // Botón 3: calcular residuo
    input  logic btn_clear,    // Botón 4: clear
    output logic [7:0] segmentos_out,
    output logic [3:0] anodos_out
);

    // Señales internas
    logic key_pressed_noisy;
    logic [7:0] key_code_raw;
    logic key_valid_pulse;
    logic key_is_digit;
    logic [3:0] digit_value;
    logic op_div, op_quot, op_rem, op_clear;
    logic num1_write_en, num2_write_en;
    logic num1_clear, num2_clear;
    logic start_division;
    logic [2:0] current_state;
    logic [7:0] num1_reg, num2_reg;
    logic division_done, division_error;
    logic [7:0] quotient, remainder;
    logic [15:0] display_data;

    // --- CONEXIONES EXISTENTES ---
    keypad_scanner u_scanner (
        .clk_27mhz(clk_27mhz),
        .reset_n(reset_n),
        .keypad_cols(keypad_cols),
        .keypad_rows(keypad_rows),
        .key_pressed(key_pressed_noisy),
        .key_code_raw(key_code_raw)
    );

    debouncer u_debouncer (
        .clk(clk_27mhz),
        .reset_n(reset_n),
        .noisy_in(key_pressed_noisy),
        .clean_level(), // No conectado
        .tick_out(key_valid_pulse)
    );

    key_deco u_decoder (
        .clk_27mhz(clk_27mhz),
        .reset_n(reset_n),
        .key_valid(key_valid_pulse),
        .key_code_raw(key_code_raw),
        .key_is_digit(key_is_digit),
        .digit_value(digit_value)
    );

    button_controller u_buttons (
        .clk_27mhz(clk_27mhz),
        .reset_n(reset_n),
        .btn_div(btn_div),
        .btn_quot(btn_quot),
        .btn_rem(btn_rem),
        .btn_clear(btn_clear),
        .op_div(op_div),
        .op_quot(op_quot),
        .op_rem(op_rem),
        .op_clear(op_clear)
    );

    num_reg u_reg1 (
        .clk(clk_27mhz),
        .reset_n(reset_n),
        .clear(num1_clear),
        .write_en(num1_write_en),
        .digit_in(digit_value),
        .number_out(num1_reg)
    );

    num_reg u_reg2 (
        .clk(clk_27mhz),
        .reset_n(reset_n),
        .clear(num2_clear),
        .write_en(num2_write_en),
        .digit_in(digit_value),
        .number_out(num2_reg)
    );

    division_unit u_div (
        .clk(clk_27mhz),
        .reset_n(reset_n),
        .start(start_division),
        .dividend(num1_reg),
        .divisor(num2_reg),
        .quotient(quotient),
        .remainder(remainder),
        .done(division_done),
        .error(division_error)
    );

    fsm_controller u_fsm (
        .clk_27mhz(clk_27mhz),
        .reset_n(reset_n),
        .key_is_digit(key_is_digit),
        .digit_value(digit_value),
        .btn_div(op_div),
        .btn_quot(op_quot),
        .btn_rem(op_rem),
        .btn_clear(op_clear),
        .quotient(quotient),
        .remainder(remainder),
        .division_done(division_done),
        .division_error(division_error),
        .num1_write_en(num1_write_en),
        .num2_write_en(num2_write_en),
        .num1_clear(num1_clear),
        .num2_clear(num2_clear),
        .start_division(start_division),
        .display_data_out(display_data),
        .current_state(current_state)
    );

    // --- DISPLAY SIN IDLE_STATE ---
    display_refresh u_display (
        .clk(clk_27mhz),
        .reset_n(reset_n),
        .bcd_in(display_data),
        .segmentos_out(segmentos_out),
        .anodos_out(anodos_out)
    );

endmodule