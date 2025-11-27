//Usamos el método de barrido por columnas, encendiendo cada columna a la vez
//Si al activar la columna 2 encuentra que una fila se va a 0, esa tecla está siendo presionada
//Basicamente el scanner hace:
//- Detiene el barrido
//- Latch a los valores {columna,fila}
//- Produce key_pressed = 1
//- Deja estable key_code_raw hasta que sueltes la tecla

module keypad_scanner #(
    parameter CLK_FREQ = 27_000_000,
    parameter SCAN_FREQ = 1900 
)(
    input  logic clk_27mhz,
    input  logic reset_n,
    output logic [3:0] keypad_cols,
    input  logic [3:0] keypad_rows,
    output logic key_pressed,     //hacer que se estabilice la señal 
    output logic [7:0] key_code_raw 
);
    
    localparam SCAN_RATE_DIV = CLK_FREQ / (SCAN_FREQ * 4); 
    
    // Contador para el barrido
    logic [$clog2(SCAN_RATE_DIV)-1:0] scan_counter;
    logic [1:0] col_reg;
    
    // FSM interna del scanner
    typedef enum logic { SCANNING, PRESSED } state_t;
    state_t state;
    
    // Latch para las tecla
    logic [3:0] latched_cols;
    logic [3:0] latched_rows;
    
    // Detección de tecla, cualquier fila en la columna activa
    wire any_row_low = ~(&keypad_rows); // ~r0 | ~r1 | ~r2 | ~r3

    // Salida de columnas (depende del estado), la salida es combinacional y depende de col_reg
    always_comb begin
        case (col_reg)
            2'b00:   keypad_cols = 4'b1110; // Col 0 activa (baja)
            2'b01:   keypad_cols = 4'b1101; // Col 1 activa (baja)
            2'b10:   keypad_cols = 4'b1011; // Col 2 activa (baja)
            default: keypad_cols = 4'b0111; // Col 3 activa (baja)
        endcase
    end

    // FSM y Lógica de Barrido
    always_ff @(posedge clk_27mhz or negedge reset_n) begin
        if (!reset_n) begin
            scan_counter <= '0;
            col_reg <= '0;
            state <= SCANNING;
            latched_cols <= 4'b1111;
            latched_rows <= 4'b1111;
        end else begin
            case (state)
                SCANNING: begin
                    // Sigue barriendo
                    if (scan_counter == SCAN_RATE_DIV - 1) begin
                        scan_counter <= '0;
                        col_reg <= col_reg + 1;
                    end else begin
                        scan_counter <= scan_counter + 1;
                    end
                    
                    // Se presionó una tecla?
                    if (any_row_low) begin
                        state <= PRESSED;
                        // Latchea los valores en el momento de la detección
                        latched_cols <= keypad_cols; // Se latchea el valor actual
                        latched_rows <= keypad_rows; 
                    end
                end
                
                PRESSED: begin
                    // Mantiene el estado y los latches. Deja de escanear (col_reg no cambia).
                    // La 'keypad_cols' se queda fija.
                    
                    // Espera a que se suelte la tecla
                    // 'any_row_low' se volverá '0' cuando el usuario suelte
                    // la tecla en la columna que está activ
                    if (!any_row_low) begin 
                        state <= SCANNING; // Vuelve a escanear
                        latched_cols <= 4'b1111; // Limpia latches
                        latched_rows <= 4'b1111;
                    end
                end
            endcase
        end
    end

    // Salidas (ahora son estables)
    assign key_pressed = (state == PRESSED);
    assign key_code_raw = {latched_cols, latched_rows};

endmodule