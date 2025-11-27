// Módulo de control de botones con debounce
// - Sincroniza entradas asíncronas para evitar metaestabilidad
// - Filtro debounce con registro de 3 etapas
// - Detección de flanco de bajada (botones activos en bajo)

module button_controller(
    input  logic clk_27mhz,
    input  logic reset_n,
    input  logic btn_div,      // Botón: pasar al siguiente número
    input  logic btn_quot,     // Botón: calcular cociente
    input  logic btn_rem,      // Botón: calcular residuo
    input  logic btn_clear,    // Botón: clear
    output logic op_div,       // Operación: división (siguiente número)
    output logic op_quot,      // Operación: calcular cociente
    output logic op_rem,       // Operación: calcular residuo
    output logic op_clear      // Operación: clear
);

    // Registros para debounce
    logic [2:0] btn_div_sync;
    logic [2:0] btn_quot_sync;
    logic [2:0] btn_rem_sync;
    logic [2:0] btn_clear_sync;
    
    // Detección de flanco de bajada (botones activos en bajo)
    logic btn_div_prev, btn_quot_prev, btn_rem_prev, btn_clear_prev;

    // Sincronización para evitar metaestabilidad
    always_ff @(posedge clk_27mhz or negedge reset_n) begin
        if (!reset_n) begin
            btn_div_sync <= 3'b111;
            btn_quot_sync <= 3'b111;
            btn_rem_sync <= 3'b111;
            btn_clear_sync <= 3'b111;
            btn_div_prev <= 1'b1;
            btn_quot_prev <= 1'b1;
            btn_rem_prev <= 1'b1;
            btn_clear_prev <= 1'b1;
        end else begin
            // Sincronización con pipeline de 3 etapas
            btn_div_sync <= {btn_div_sync[1:0], btn_div};
            btn_quot_sync <= {btn_quot_sync[1:0], btn_quot};
            btn_rem_sync <= {btn_rem_sync[1:0], btn_rem};
            btn_clear_sync <= {btn_clear_sync[1:0], btn_clear};
            
            btn_div_prev <= btn_div_sync[2];
            btn_quot_prev <= btn_quot_sync[2];
            btn_rem_prev <= btn_rem_sync[2];
            btn_clear_prev <= btn_clear_sync[2];
        end
    end

    // Detección de flanco de bajada (cuando se presiona el botón)
    assign op_div = (btn_div_prev && !btn_div_sync[2]);
    assign op_quot = (btn_quot_prev && !btn_quot_sync[2]);
    assign op_rem = (btn_rem_prev && !btn_rem_sync[2]);
    assign op_clear = (btn_clear_prev && !btn_clear_sync[2]);

endmodule