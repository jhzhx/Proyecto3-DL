// Módulo de refresco para display de 7 segmentos de 4 dígitos
// - Refresca los dígitos a ~1.6kHz usando un contador con reloj de 27MHz
// - Convierte valores hexadecimales (0-F) a segmentos
// - Controla los ánodos para multiplexar los dígitos

module display_refresh (
    input  logic clk,
    input  logic reset_n,
    input  logic [15:0] bcd_in,  // Datos hexadecimales para mostrar
    output logic [7:0] segmentos_out,
    output logic [3:0] anodos_out
);
    // Usamos un contador de 14 bits para un refresco de ~1.6kHz con reloj de 27MHz
    localparam COUNTER_WIDTH = 14;
    logic [COUNTER_WIDTH-1:0] refresh_counter;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            refresh_counter <= '0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    logic [3:0] bcd_digit;
    logic [1:0] digit_select;
    
    // Usamos los 2 bits más significativos del contador para seleccionar
    assign digit_select = refresh_counter[COUNTER_WIDTH-1:COUNTER_WIDTH-2];

    // D1 (izquierda) = MSB ... D4 (derecha) = LSB
    always_comb begin
        case (digit_select)
            2'b00:  bcd_digit = bcd_in[15:12]; // D1 (anodos_out[0])
            2'b01:  bcd_digit = bcd_in[11:8];  // D2 (anodos_out[1])
            2'b10:  bcd_digit = bcd_in[7:4];   // D3 (anodos_out[2])
            default: bcd_digit = bcd_in[3:0];   // D4 (anodos_out[3])
        endcase
    end
    
    // Asignación: {g, f, e, d, c, b, a}
    // Display de cátodo común (1 enciende el segmento)
    always_comb begin
        case (bcd_digit)
            // Números
            4'h0: segmentos_out[6:0] = 7'b0111111; // 0
            4'h1: segmentos_out[6:0] = 7'b0000110; // 1
            4'h2: segmentos_out[6:0] = 7'b1011011; // 2
            4'h3: segmentos_out[6:0] = 7'b1001111; // 3
            4'h4: segmentos_out[6:0] = 7'b1100110; // 4
            4'h5: segmentos_out[6:0] = 7'b1101101; // 5
            4'h6: segmentos_out[6:0] = 7'b1111101; // 6
            4'h7: segmentos_out[6:0] = 7'b0000111; // 7
            4'h8: segmentos_out[6:0] = 7'b1111111; // 8
            4'h9: segmentos_out[6:0] = 7'b1101111; // 9
            
            // Letras hexadecimales
            4'hA: segmentos_out[6:0] = 7'b1110111; // A
            4'hB: segmentos_out[6:0] = 7'b1111100; // b (minúscula)
            4'hC: segmentos_out[6:0] = 7'b0111001; // C
            4'hD: segmentos_out[6:0] = 7'b1011110; // d (minúscula)
            4'hE: segmentos_out[6:0] = 7'b1111001; // E
            4'hF: segmentos_out[6:0] = 7'b1110001; // F
            
            default: segmentos_out[6:0] = 7'b0000000; // Blank
        endcase
        
        // Punto decimal en el segundo dígito
        if (digit_select == 2'b01) 
            segmentos_out[7] = 1'b1; 
        else 
            segmentos_out[7] = 1'b0;
    end

    // Asignación: {D4, D3, D2, D1}
    always_comb begin
        case (digit_select)
            2'b00:  anodos_out = 4'b0001; // Enciende D1 (anodos_out[0])
            2'b01:  anodos_out = 4'b0010; // Enciende D2 (anodos_out[1])
            2'b10:  anodos_out = 4'b0100; // Enciende D3 (anodos_out[2])
            default: anodos_out = 4'b1000; // Enciende D4 (anodos_out[3])
        endcase
    end
endmodule