// Testbench для проверки сумматора с регистровыми входами и выходом
module adder_regs_tb ();

  localparam integer WIDTH = 4;  // разрядность входных данных

  integer seed = 0;           // начальное значение генератора случайных чисел
  integer trans_number = 10;  // число суммирований
  integer trans_cnt;          // счетчик суммирований

  reg clk = 1'b0;    // тактовый сигнал
  reg reset = 1'b1;  // сигнал сброса, активный уровень - 1

  // входные слагаемые и результат суммы
  reg [WIDTH-1:0] data1_i;
  reg [WIDTH-1:0] data2_i;
  wire [WIDTH:0] data_o;

  // проверяемый модуль
  adder_regs #(
      .WIDTH(WIDTH)
  ) dut (
      .clk(clk),
      .reset(reset),
      .data1_i(data1_i),
      .data2_i(data2_i),
      .data_o(data_o)
  );

  // формирование тактового сигнала
  always #5 clk = ~clk;

  // удержание сигнала сброса в активном уровне в течение 3 тактов
  initial begin
    repeat (3) @(posedge clk);
    reset <= 1'b0;
  end

  // Формирование входных воздействий. Сначала дожидаемся снятия сигнала
  // сброса. Затем в цикле выполняем следующие действия:
  //   - формируем случайные значения входных слагаемых,
  //   - дожидаемся фронта тактового сигнала;
  //   - выводим значение сигналов на экран.
  // После подачи заданного числа слагаемых завершаем тест.
  initial begin
    @(negedge reset);

    for (trans_cnt = 0; trans_cnt < trans_number; trans_cnt = trans_cnt + 1) begin
      data1_i <= $urandom(seed);
      data2_i <= $urandom(seed);
      @(posedge clk);
      $display("%0d: data_1_i = %0d, data_2_i = %0d, data_o = %0d", trans_cnt, data1_i, data2_i, data_o);
    end

    $finish;
  end

  // дамп waveforms в VCD формате
  initial begin
    $dumpfile("wave_dump.vcd");
    $dumpvars(0);
  end
endmodule
