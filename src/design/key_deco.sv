//Decodificador de teclado matricial 4x4
//- Convierte el código de tecla (columna activa + fila activa) en valor hexadecimal
//- Indica si la tecla es un dígito válido (0-F)

module key_deco(
    input  logic clk_27mhz,
    input  logic reset_n,
    input  logic key_valid,
    input  logic [7:0] key_code_raw,
    output logic key_is_digit,
    output logic [3:0] digit_value
);

    logic [7:0] key_code_stable;

    always_ff @(posedge clk_27mhz or negedge reset_n) begin
        if (!reset_n)
            key_code_stable <= '0;
        else if (key_valid)
            key_code_stable <= key_code_raw;
    end

    always_comb begin
        key_is_digit = 0; 
        digit_value = 4'hF;

        if (key_valid) begin
            case (key_code_stable)
                // Col 0 - Teclas: 1, 4, 7, E (antes *)
                8'b1110_1110: begin key_is_digit = 1; digit_value = 4'h1; end
                8'b1110_1101: begin key_is_digit = 1; digit_value = 4'h4; end
                8'b1110_1011: begin key_is_digit = 1; digit_value = 4'h7; end
                8'b1110_0111: begin key_is_digit = 1; digit_value = 4'hE; end
                
                // Col 1 - Teclas: 2, 5, 8, 0
                8'b1101_1110: begin key_is_digit = 1; digit_value = 4'h2; end
                8'b1101_1101: begin key_is_digit = 1; digit_value = 4'h5; end
                8'b1101_1011: begin key_is_digit = 1; digit_value = 4'h8; end
                8'b1101_0111: begin key_is_digit = 1; digit_value = 4'h0; end
                
                // Col 2 - Teclas: 3, 6, 9, F (antes #)
                8'b1011_1110: begin key_is_digit = 1; digit_value = 4'h3; end
                8'b1011_1101: begin key_is_digit = 1; digit_value = 4'h6; end
                8'b1011_1011: begin key_is_digit = 1; digit_value = 4'h9; end
                8'b1011_0111: begin key_is_digit = 1; digit_value = 4'hF; end
                
                // Col 3 - Teclas: A, B, C, D
                8'b0111_1110: begin key_is_digit = 1; digit_value = 4'hA; end
                8'b0111_1101: begin key_is_digit = 1; digit_value = 4'hB; end
                8'b0111_1011: begin key_is_digit = 1; digit_value = 4'hC; end
                8'b0111_0111: begin key_is_digit = 1; digit_value = 4'hD; end
                
                default: begin
                    key_is_digit = 0;
                    digit_value = 4'hF;
                end
            endcase
        end
    end
endmodule