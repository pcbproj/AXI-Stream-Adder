`ifndef TB_TASKS_VH
`define TB_TASKS_VH

`include "tb_defines.vh"

// эталонный сумматор
task gold_adder(input integer data1_i, input integer data2_i, output integer data_o);
  integer gold, in_1, in_2;
  begin
    in_1 = data1_i[`WIDTH-1:0];
    in_2 = data2_i[`WIDTH-1:0];
    data_o = in_1 + in_2 + 1;
  end
endtask

// сравнение с эталонной моделью
task compare(input integer data1_i, input integer data2_i, input integer data_o, inout reg error_flag);
  integer gold_out, dut_out;
  begin
    gold_adder(data1_i, data2_i, gold_out);
    dut_out = data_o[`WIDTH:0];
    // вывод на экран и установка флага ошибки
    if (gold_out != dut_out) begin
      $display("ERROR! Data mismatch! input 1: %0d, input 2: %0d, output: %0d, gold: %0d, time: %0t", data1_i, data2_i, dut_out, gold_out, $time);
      error_flag = 1'b1;
    end
  end
endtask

// проверка число обработанных сложений и завершение теста
task check_finish(input integer trans_cnt, input integer trans_number, input reg error_flag);
  begin
    if (trans_cnt == trans_number) begin
      if (error_flag) begin
        $display("----------------------");
        $display("---- TEST FAILED! ----");
        $display("----------------------");
      end else begin
        $display("----------------------");
        $display("---- TEST PASSED! ----");
        $display("----------------------");
      end
      $finish;
    end
  end
endtask

`endif
