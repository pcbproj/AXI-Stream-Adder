`ifndef TB_PLUSARGS_VH
`define TB_PLUSARGS_VH

`include "tb_defines.vh"

integer seed;            // начальное состояние генератора случайных чисел
integer trans_number;    // число транзакций в тесте
integer min_axis_delay;  // минимальная задержка в тактах на AXI-Stream интерфейсе
integer max_axis_delay;  // максимальная задержка в тактах на AXI-Stream интерфейсе
integer max_axis_value;  // максимальное значение, которое может появится на шине tdata
integer max_clk_in_test; // максимальная длительность теста в тактах

// получение +args
task get_plusargs();
begin
    // число транзакций в тесте
    if (!$value$plusargs("trans_number=%d", trans_number))
      trans_number = 5;

    // начальное состояние генератора случайных чисел
    if (!$value$plusargs("seed=%d", seed))
      seed = 0;

    // минимальная задержка в тактах на AXI-Stream интерфейсе
    if (!$value$plusargs("min_axis_delay=%d", min_axis_delay))
      min_axis_delay = 0;

    // максимальная задержка в тактах на AXI-Stream интерфейсе
    if (!$value$plusargs("max_axis_delay=%d", max_axis_delay))
      max_axis_delay = 10;
    
    // максимальное значение, которое может появится на шине tdata
    if (!$value$plusargs("max_axis_value=%d", max_axis_value))
      max_axis_value = 2**`WIDTH - 1;

    // максимальная длительность теста в тактах
    if (!$value$plusargs("max_clk_in_test=%d", max_clk_in_test))
      max_clk_in_test = 300;
end
endtask

`endif