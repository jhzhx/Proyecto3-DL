//Testbench para el módulo top
`timescale 1ns/1ps

module tb_top;

    logic clk = 0;
    logic reset_n = 0;

    // Señales del top
    logic [3:0] keypad_rows;
    logic [3:0] keypad_cols;
    logic btn_div, btn_quot, btn_rem, btn_clear;
    logic [7:0] segmentos_out;
    logic [3:0] anodos_out;

    // Instancia del DUT
    top DUT (
        .clk_27mhz(clk),
        .reset_n(reset_n),
        .keypad_cols(keypad_cols),
        .keypad_rows(keypad_rows),
        .btn_div(btn_div),
        .btn_quot(btn_quot),
        .btn_rem(btn_rem),
        .btn_clear(btn_clear),
        .segmentos_out(segmentos_out),
        .anodos_out(anodos_out)
    );

    always #18.519 clk = ~clk;

    initial begin
        $dumpfile("top.vcd");
        //Solo volcamos lo realmente necesario
        $dumpvars(0, tb_top.DUT.u_div);
        $dumpvars(0, tb_top.DUT.u_fsm);
        $dumpvars(0, tb_top.DUT.num1_reg);
        $dumpvars(0, tb_top.DUT.num2_reg);
    end


    initial begin
        reset_n = 0;
        btn_div = 0; btn_quot = 0; btn_rem = 0; btn_clear = 0;
        keypad_rows = 4'b1111;
        reset_n = 1;

        $display("=== INICIANDO PRUEBA ===");

        // Simular operación C8 / 32 (ejemplo)
        send_digit(4'hC);
        send_digit(4'h8);
        press(btn_div);

        send_digit(3);
        send_digit(2);
        press(btn_quot);
        $finish;
    end

    task send_digit(input [3:0] d);
        keypad_rows = d;
        #100;
        keypad_rows = 4'b1111;
        #100;
    endtask

    task press(inout logic btn);
        btn = 1; #100;
        btn = 0; #100;
    endtask

endmodule
