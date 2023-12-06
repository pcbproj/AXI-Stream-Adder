module adder_axis_tb ();
   
  `include "axis_vip.vh"
  `include "tb_defines.vh"
  `include "tb_plusargs.vh"
  `include "tb_tasks.vh"

  // тактовый сигнал и сигнал сброса
  reg aclk = 1'b0;
  reg aresetn = 1'b0;

  // сигналы для AXI-Stream интерфейсов
  reg  data1_i_tvalid, data2_i_tvalid, data_o_tready;
  wire data1_i_tready, data2_i_tready, data_o_tvalid;

  // слагаемые и результат суммы
  reg  [ `AXIS_IN_WIDTH-1:0]  data1_i_tdata;
  reg  [ `AXIS_IN_WIDTH-1:0]  data2_i_tdata;
  wire [ `AXIS_OUT_WIDTH-1:0] data_o_tdata;

  // массивы для сохранения входных слагаемых
  reg [`WIDTH-1:0] axis_data1 [0:`MAX_TRANS_NUMBER];
  reg [`WIDTH-1:0] axis_data2 [0:`MAX_TRANS_NUMBER];

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

  // запуск тестового окружения
  initial begin
    // получаем +args
    get_plusargs();

    // ждем 10 тактов и снимаем сигнал сброса
    repeat(10) @(posedge aclk);
    aresetn <= 1'b1;

    fork
      // --------- drivers --------
      `AXIS_SLAVE_DRIVER(aclk, data1_i_tready, data1_i_tdata, data1_i_tvalid, min_axis_delay, max_axis_delay, max_axis_value, seed)
      `AXIS_SLAVE_DRIVER(aclk, data2_i_tready, data2_i_tdata, data2_i_tvalid, min_axis_delay, max_axis_delay, max_axis_value, seed)
      `AXIS_MASTER_DRIVER(aclk, data_o_tready, min_axis_delay, max_axis_delay, seed) 

      // -------- monitors --------
      `AXIS_MONITOR(aclk, data1_i_tvalid, data1_i_tready, data1_i_e)
      `AXIS_MONITOR(aclk, data2_i_tvalid, data2_i_tready, data2_i_e)
      `AXIS_MONITOR(aclk, data_o_tvalid, data_o_tready, data_o_e)

      // -------- scoreboard ---------
      while (1) begin // запись даннх на data1_i интерфейсе
        @(data1_i_e);
        axis_data1[axis_data1_cnt] = data1_i_tdata;
        axis_data1_cnt = axis_data1_cnt + 1;
      end
      while (1) begin // запись даннх на data2_i интерфейсе
        @(data2_i_e);
        axis_data2[axis_data2_cnt] = data2_i_tdata;
        axis_data2_cnt = axis_data2_cnt + 1;
      end
      while (1) begin // сравнение результатов с моделью
        @(data_o_e);
        compare(axis_data1[trans_cnt], axis_data2[trans_cnt], data_o_tdata, error_flag);
        trans_cnt = trans_cnt + 1;
        check_finish(trans_cnt, trans_number, error_flag);
      end
    join
  end

  // создание тактового сигнала
  always #5 aclk = ~aclk;

  // сторожевой таймер для отслеживания зависания теста
  initial begin
    repeat(max_clk_in_test) @(posedge aclk);
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
