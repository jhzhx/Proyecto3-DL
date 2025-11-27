// Módulo para convertir un número binario de 8 bits a BCD de 4 dígitos

module bin_to_bcd(
    input  logic [7:0] binary_in, // Máximo 255
    output logic [15:0] bcd_out    // 4 dígitos BCD
);
    always_comb begin
        logic [7:0] bin_copy;
        logic [15:0] bcd_temp;
        
        bin_copy = binary_in;
        bcd_temp = '0;

        for (int i = 0; i < 8; i = i + 1) begin
            // Primero desplazar
            bcd_temp = {bcd_temp[14:0], bin_copy[7]};
            bin_copy = bin_copy << 1;
            
            // Luego corregir
            if (bcd_temp[3:0] > 4)   bcd_temp[3:0]   = bcd_temp[3:0]   + 3;
            if (bcd_temp[7:4] > 4)   bcd_temp[7:4]   = bcd_temp[7:4]   + 3;
            if (bcd_temp[11:8] > 4)  bcd_temp[11:8]  = bcd_temp[11:8]  + 3;
            if (bcd_temp[15:12] > 4) bcd_temp[15:12] = bcd_temp[15:12] + 3;
        end
        bcd_out = bcd_temp;
    end
endmodule