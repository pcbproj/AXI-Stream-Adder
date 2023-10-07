// Testbench для проверки комбинационного сумматора
module adder_comb_tb ();

  localparam integer WIDTH = 4;  // разрядность входных данных

  integer seed = 0;           // начальное значение генератора случайных чисел
  integer trans_number = 10;  // число суммирований

  // входные и выходные сигналы
  reg [WIDTH-1:0] data1_i;
  reg [WIDTH-1:0] data2_i;
  wire [WIDTH:0] data_o;

  // проверяемый модуль
  adder_comb #(
      .WIDTH(WIDTH)
  ) dut (
      .data1_i(data1_i),
      .data2_i(data2_i),
      .data_o (data_o)
  );

  // Формирование входных воздействий. В цикле формируем случайные значения
  // входных слагаемых и после задержки выводим результат на экран. После
  // подачи заданного числа слагаемых завершаем тест.
  initial begin
    repeat (trans_number) begin
      data1_i = $urandom(seed);
      data2_i = $urandom(seed);
      #10;
      $display("%0d + %0d = %0d", data1_i, data2_i, data_o);
    end
    $finish;
  end

  // дамп waveforms в VCD формате
  initial begin
    $dumpfile("wave_dump.vcd");
    $dumpvars(0);
  end
endmodule
