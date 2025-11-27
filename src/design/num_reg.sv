//Registro acumulador de dígitos hexadecimales
//- Almacena número de 8 bits formado por 2 dígitos de 4 bits
//- Primer dígito en bits bajos, segundo desplazado
//- Reset asíncrono y clear síncrono

module num_reg(
    input  logic clk,
    input  logic reset_n,
    input  logic clear,
    input  logic write_en,
    input  logic [3:0] digit_in,
    output logic [7:0] number_out
);
    logic [7:0] number_next;
    logic first_digit; // Registro para saber si es el primer dígito

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            number_out <= '0;
            first_digit <= 1'b1;
        end else if (clear) begin
            number_out <= '0;
            first_digit <= 1'b1;
        end else if (write_en) begin
            number_out <= number_next;
            first_digit <= 1'b0; // Después del primer dígito, ya no es el primero
        end
    end

    always_comb begin
        if (first_digit) begin
            // Primer dígito: poner en los bits bajos, no desplazar
            number_next = {4'b0, digit_in};
        end else begin
            // Dígitos siguientes: desplazar y agregar
            number_next = (number_out << 4) | digit_in;
        end
    end
endmodule