
module adder_axis_tb ();

  `include "tb_defines.vh"
  `include "tb_tasks.vh"

  // тактовый сигнал и сигнал сброса
  reg aclk = 1'b0;
  reg aresetn = 1'b0;

  // сигналы для AXI-Stream интерфейсов
  reg  data1_i_tvalid, data2_i_tvalid, data_o_tready;
  wire data1_i_tready, data2_i_tready, data_o_tvalid;

  // слагаемые и результат суммы
  reg  [ `AXIS_IN_WIDTH-1:0] data1_i_tdata;
  reg  [ `AXIS_IN_WIDTH-1:0] data2_i_tdata;
  wire [ `AXIS_OUT_WIDTH-1:0] data_o_tdata;

  // начальное состояние генератора случайных чисел
  integer seed = `SEED;

  // массивы для сохранения входных слагаемых
  reg [`WIDTH-1:0] axis_data1 [0:`TRANS_NUMBER];
  reg [`WIDTH-1:0] axis_data2 [0:`TRANS_NUMBER];

  // счетчики числа слагаемых и результатов суммы
  integer unsigned axis_data1_cnt = 0;
  integer unsigned axis_data2_cnt = 0;
  integer unsigned trans_cnt = 0;

  // события handshake на AXI-Stream интерфейсах
  event data1_i_e, data2_i_e, data_o_e;

  // флаг наличия ошибок в тесте
  reg error_flag = 1'b0;

  // проверяемый модуль
  adder_axis_pipe #(
      .ADDER_WIDTH(`WIDTH)
  ) dut (
      .aclk          (aclk),
      .aresetn       (aresetn),
      .data1_i_tdata (data1_i_tdata),
      .data1_i_tvalid(data1_i_tvalid),
      .data1_i_tready(data1_i_tready),
      .data2_i_tdata (data2_i_tdata),
      .data2_i_tvalid(data2_i_tvalid),
      .data2_i_tready(data2_i_tready),
      .data_o_tdata  (data_o_tdata),
      .data_o_tvalid (data_o_tvalid),
      .data_o_tready (data_o_tready)
  );

  // создание тактового сигнала
  always #5 aclk = ~aclk;

  // создание сигнала сброса
  initial begin
    repeat (10) @(posedge aclk);
    aresetn <= 1'b1;
  end

  // ---------------- DRIVERS -----------------

  // драйвер для data1_i AXI-Stream интерфейса
  initial begin
    // ожидаем выхода из состояния сброса
    @(posedge aresetn);
  
    while (1) begin
      data1_i_tvalid <= 1'b0;
      // выполняем задержку на случайное число тактов
      repeat ($urandom(seed) % (`MAX_AXIS_DELAY + 1) + `MIN_AXIS_DELAY) @(posedge aclk);
      // выставляем сигнал valid и данные
      data1_i_tdata  <= $urandom(seed) % (`MAX_AXIS_VALUE + 1);
      data1_i_tvalid <= 1'b1;
      @(posedge aclk);
      // ожидаем сигнал tready для handshake
      while (!data1_i_tready) @(posedge aclk);
    end
  end

  // драйвер для data2_i AXI-Stream интерфейса
  initial begin
    // ожидаем выхода из состояния сброса
    @(posedge aresetn);

    while (1) begin
      data2_i_tvalid <= 1'b0;
      // выполняем задержку на случайное число тактов
      repeat ($urandom(seed) % (`MAX_AXIS_DELAY + 1) + `MIN_AXIS_DELAY) @(posedge aclk);
      // выставляем сигнал valid и данные
      data2_i_tdata  <= $urandom(seed) % (`MAX_AXIS_VALUE + 1);
      data2_i_tvalid <= 1'b1;
      @(posedge aclk);
      // ожидаем сигнал tready для handshake
      while (!data2_i_tready) @(posedge aclk);
    end
  end

  // драйвер для data_o AXI-Stream интерфейса
  initial begin
    // ожидаем выхода из состояния сброса
    @(posedge aresetn);

    while (1) begin
      // сбрасываем сигнал tready
      data_o_tready <= 1'b0;
      // выполняем задержку на случайное число тактов
      repeat($urandom(seed) % (`MAX_AXIS_DELAY + 1) + `MIN_AXIS_DELAY)
        @(posedge aclk);
      // выставляем сигнал tready
      data_o_tready <= 1'b1;
      @(posedge aclk);
      // опять выполняем задержку на случайное число тактов
      repeat($urandom(seed) % (`MAX_AXIS_DELAY + 1) + `MIN_AXIS_DELAY)
        @(posedge aclk);
    end
  end

  // ---------------- MONITORS -----------------
  // на каждом такте проверяем handshake и если он есть, то триггерим event

  // мониторы для data1_i AXI-Stream интерфейса
  always begin
    @(posedge aclk);
    if (data1_i_tready && data1_i_tvalid) -> data1_i_e;
  end

  // мониторы для data2_i AXI-Stream интерфейса
  always begin
    @(posedge aclk);
    if (data2_i_tready && data2_i_tvalid) -> data2_i_e;
  end

    // мониторы для data_o AXI-Stream интерфейса
  always begin
    @(posedge aclk);
    if (data_o_tready && data_o_tvalid) -> data_o_e;
  end

  // ------------------ SCOREBOARD -----------------
  // COLLECTOR 1
  // запись данных на data1_i интерфейсе
  always begin
      @(data1_i_e);
      axis_data1[axis_data1_cnt] = data1_i_tdata;
      axis_data1_cnt = axis_data1_cnt + 1;
  end

  // COLLECTOR 2
  // запись данных на data1_i интерфейсе
  always begin
      @(data2_i_e);
      axis_data2[axis_data2_cnt] = data2_i_tdata;
      axis_data2_cnt = axis_data2_cnt + 1;
  end

  // CHECKER
  // ожидаем рультат суммы на data_o интерфейсе, получаем
  // сохраненные слагаемые, выполняем эталонное суммирование
  // и сравниваем результаты. Выполняем проверку на завершение теста
  always begin
      @(data_o_e);
      compare(axis_data1[trans_cnt], axis_data2[trans_cnt], data_o_tdata, error_flag);
      trans_cnt = trans_cnt + 1;
      check_finish(trans_cnt, `TRANS_NUMBER, error_flag);
  end

  // сторожевой таймер для отслеживания зависания теста
  initial begin
    repeat(`MAX_CLK_IN_TEST) @(posedge aclk);
    $display("ERROR! Watchdog error!");
    $display("----------------------");
    $display("---- TEST FAILED! ----");
    $display("----------------------");
    $finish;
  end

  // дамп waveforms в VCD файл
  initial begin
    $dumpfile("wave_dump.vcd");
    $dumpvars(0);
  end

endmodule
