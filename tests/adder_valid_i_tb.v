// Testbench для проверки сумматора с входным строб-сигналом
module adder_valid_i_tb ();

  localparam integer WIDTH = 4;  // разрядность входных данных

  integer seed = 0;           // начальное значение генератора случайных чисел
  integer trans_number = 10;  // число суммирований
  integer trans_cnt;          // счетчик суммирований

  reg clk = 1'b0;    // тактовый сигнал
  reg reset = 1'b1;  // сигнал сброса, активный уровень - 1

  reg  valid_i; // входной строб-сигнал

  // входные слагаемые и результат суммы
  reg [WIDTH-1:0] data1_i;
  reg [WIDTH-1:0] data2_i;
  wire [WIDTH:0] data_o;

  // проверяемый модуль
  adder_valid_i #(
      .WIDTH(WIDTH)
  ) dut (
      .clk(clk),
      .reset(reset),
      .valid_i(valid_i),
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
  //   - выполняем задержку в два такта, имитируя отсутствие строба;
  //   - в момент отсутвия строба формируем фиктивные входные данные;
  //   - устанавиваем строб-сигнал в 1 и выставляем слагаемые на входы сумматора;
  //   - дожидаемся фронта тактового сигнала;
  // После подачи заданного числа слагаемых завершаем тест.
  initial begin
    // ожидание снятия сброса
    @(negedge reset);

    for (trans_cnt = 0; trans_cnt < trans_number; trans_cnt = trans_cnt + 1) begin
      // задержка формирования строба в два такта
      // в момент отсутстия строб формируются фиктивные данные
      valid_i <= 1'b0;
      repeat(2) begin
          data1_i <= $urandom(seed);
          data2_i <= $urandom(seed);
          @(posedge clk);
          $display("%0d: valid_i = %0b, data_1_i = %0d, data_2_i = %0d, data_o = %0d", trans_cnt, valid_i, data1_i, data2_i, data_o);
      end
      // формировние валидных данных и строба
      valid_i <= 1'b1;
      data1_i <= $urandom(seed);
      data2_i <= $urandom(seed);
      @(posedge clk);
      $display("%0d: valid_i = %0b, data_1_i = %0d, data_2_i = %0d, data_o = %0d", trans_cnt, valid_i, data1_i, data2_i, data_o);
    end
    // завершение теста
    $finish;
  end

  // дамп waveforms в VCD формате
  initial begin
    $dumpfile("wave_dump.vcd");
    $dumpvars(0);
  end
endmodule
