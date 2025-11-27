//Testbench para el módulo divisor solamente
`timescale 1ns / 1ps

module tb_divisor;

    // Señales de prueba
    reg clk;
    reg reset_n;
    reg start;
    reg [7:0] dividend;
    reg [7:0] divisor;
    wire [7:0] quotient;
    wire [7:0] remainder;
    wire done;
    wire error;

    // Instancia del módulo a probar
    division_unit dut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .done(done),
        .error(error)
    );

    always #18.519 clk = ~clk;

    // Tarea para realizar una división
    task test_division;
        input [7:0] test_dividend;
        input [7:0] test_divisor;
        input [7:0] expected_quotient;
        input [7:0] expected_remainder;
        input expected_error;
        integer start_time, end_time;
        begin
            $display("Test: %h / %h", test_dividend, test_divisor);
            
            // Aplicar entradas
            dividend = test_dividend;
            divisor = test_divisor;
            start_time = $time;
            start = 1;
            @(posedge clk);
            start = 0;
            
            // Esperar a que termine la división
            wait(done == 1);
            end_time = $time;
            @(posedge clk);
            
            // Verificar resultados
            if (expected_error) begin
                if (error) begin
                    $display("  PASS: Error detectado correctamente");
                    $display("  Error signal: %b, Done: %b", error, done);
                end else begin
                    $display("  FAIL: Se esperaba error pero no ocurrio");
                    $display("  Error signal: %b, Done: %b", error, done);
                end
            end else begin
                if (error) begin
                    $display("  FAIL: Error inesperado");
                end else if (quotient === expected_quotient && remainder === expected_remainder) begin
                    $display("  PASS: Cociente = %h, Residuo = %h (Tiempo: %0t ns)", 
                             quotient, remainder, end_time - start_time);
                end else begin
                    $display("  FAIL: Esperado Q=%h R=%h, Obtenido Q=%h R=%h", 
                             expected_quotient, expected_remainder, quotient, remainder);
                end
            end
            $display("");
            
            // Esperar entre pruebas
            repeat(5) @(posedge clk);
        end
    endtask

    // Procedimiento de prueba principal
    initial begin
        // Inicialización
        clk = 0;
        reset_n = 0;
        start = 0;
        dividend = 0;
        divisor = 0;
        
        // Reset
        repeat(5) @(posedge clk);
        reset_n = 1;
        repeat(2) @(posedge clk);
        
        $display("PRUEBAS DEL MODULO DIVISION - CON ERRORES");
        $display("");
        
        // Test específico para división por cero
        $display("=== PRUEBA ESPECÍFICA DIVISIÓN POR CERO ===");
        test_division(8'h0A, 8'h00, 8'h00, 8'h00, 1);
        
        // Otros tests
        $display("=== PRUEBAS NORMALES ===");
        test_division(8'hC8, 8'h32, 8'h04, 8'h00, 0);
        test_division(8'h0F, 8'h04, 8'h03, 8'h03, 0);
    
        $display("RESUMEN FINAL");
        $finish;
    end

endmodule