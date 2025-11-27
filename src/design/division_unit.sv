//Unidad de división binaria secuencial
//- Implementa división por resta y desplazamiento
//- Soporta detección de división por cero y señal de error

module division_unit (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        start,
    input  logic [7:0]  dividend,
    input  logic [7:0]  divisor,
    output logic [7:0]  quotient,
    output logic [7:0]  remainder,
    output logic        done,
    output logic        error // Señal de error por división por cero
);

    logic [15:0] shift_reg; // Registro de desplazamiento para el dividendo y cociente
    logic [3:0]  counter; // Contador
    logic        busy; // Indica si la unidad está ocupada
    logic [7:0]  divisor_reg;
    logic [8:0]  temp_diff; // Diferencia temporal para la resta
    logic        error_flag;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            shift_reg <= 0;
            counter <= 0;
            busy <= 0;
            error_flag <= 0;
            divisor_reg <= 0;
        end else begin
            if (start && !busy) begin
                // Reiniciar error_flag al comenzar nueva operación
                error_flag <= 0;
                
                if (divisor == 0) begin
                    // División por cero - establecer error inmediatamente
                    error_flag <= 1;
                    busy <= 0; // No iniciar el proceso
                end else begin
                    shift_reg <= {8'b0, dividend};
                    divisor_reg <= divisor;
                    counter <= 8;
                    busy <= 1;
                end
            end else if (busy) begin
                if (counter > 0) begin
                    // Calcular diferencia temporal
                    temp_diff = {shift_reg[14:8], shift_reg[7]} - {1'b0, divisor_reg};
                    
                    if (!temp_diff[8]) begin // Si no hay underflow (>= divisor)
                        shift_reg <= {temp_diff[7:0], shift_reg[6:0], 1'b1};
                    end else begin
                        shift_reg <= {shift_reg[14:0], 1'b0};
                    end
                    counter <= counter - 1;
                end else begin
                    busy <= 0;
                end
            end
        end
    end

    assign quotient = (error_flag) ? 8'hEE : shift_reg[7:0]; // Cociente en los bits bajos
    assign remainder = (error_flag) ? 8'hEE : shift_reg[15:8]; // Resto en los bits altos
    assign done = !busy; 
    assign error = error_flag;
endmodule