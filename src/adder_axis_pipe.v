//! Усовершенствованный сумматор с AXI-Stream интерфейсами. Добавлена конвейеризация
//! загрузки слагаемых во входные регистры и вывод результатов сложения наружу. 
//! Разрядность результата суммирования на один бит больше разрядности слагаемых.
//! В соответсвие со стандартом на AXI-Stream ширина шины tdata должна быть кратна 8.aclk

module adder_axis_pipe #(
  parameter integer ADDER_WIDTH = 4,                                        //! разрядность слагаемых
  parameter integer IN_AXIS_WIDTH  = $ceil($itor(ADDER_WIDTH) / 8) * 8,     //! разрядность шины tdata для слагаемых
  parameter integer OUT_AXIS_WIDTH  = $ceil($itor(ADDER_WIDTH+1) / 8) * 8   //! разрядность шины tdata для суммы
) (
  input                           aclk,            //! тактовый сигнал
  input                           aresetn,         //! асинхронный сброс. активный уровень - 0
  //! @virtualbus data1_i @dir in
  input       [IN_AXIS_WIDTH-1:0] data1_i_tdata,   //! входные данные
  input                           data1_i_tvalid,  //! сигнал валидности данных
  output                          data1_i_tready,  //! сигнал готовности принять данные @end
  //! @virtualbus data2_i @dir in
  input       [IN_AXIS_WIDTH-1:0] data2_i_tdata,   //! входные данные
  input                           data2_i_tvalid,  //! сигнал валидности данных
  output                          data2_i_tready,  //! сигнал готовности принять данные @end
  //! @virtualbus data_o @dir out
  output reg [OUT_AXIS_WIDTH-1:0] data_o_tdata,    //! выходные данные
  output                          data_o_tvalid,   //! сигнал валидности данных
  input                           data_o_tready    //! сигнал готовности принять данные @end
);

  reg  [ADDER_WIDTH-1:0] adder_in_1;  //! первый вход комбинационного сумматора
  reg  [ADDER_WIDTH-1:0] adder_in_2;  //! второй вход комбинационного сумматора
  wire [  ADDER_WIDTH:0] adder_out;   //! выход комбинационного сумматора

  wire data1_i_ce; //! сигнал загрузки во входной регистр первого слагаемого
  wire data2_i_ce; //! сигнал загрузки во входной регистр второго слагаемого
  wire data_o_ce;  //! сигнал загрузки в выходной регистр рузельтата суммирования

  //! входной регистр первого слагаемого
  always @(posedge aclk or negedge aresetn) begin : data1_i_reg
    if (!aresetn) adder_in_1 <= '0;
    else if (data1_i_ce) adder_in_1 <= data1_i_tdata;
  end

  //! входной регистр второго слагаемого
  always @(posedge aclk or negedge aresetn) begin : data2_i_reg
    if (!aresetn) adder_in_2 <= '0;
    else if (data2_i_ce) adder_in_2 <= data2_i_tdata;
  end

  //! комбинационный сумматор
  adder_comb #(
      .WIDTH(ADDER_WIDTH)
  ) adder_comb (
      .data1_i(adder_in_1),
      .data2_i(adder_in_2),
      .data_o (adder_out)
  );

  //! выходной регистр рузельтата суммирования
  always @(posedge aclk or negedge aresetn) begin : data_o_reg
    if (!aresetn) data_o_tdata <= '0;
    else if (data_o_ce) data_o_tdata <= adder_out;
  end

  //! блок управления загрузкой регистров и сигналами AXI-Stream интерфейса
  adder_axis_cu adder_axis_cu (
      .aclk(aclk),
      .aresetn(aresetn),
      .data1_i_ce(data1_i_ce),
      .data2_i_ce(data2_i_ce),
      .data_o_ce(data_o_ce),
      .data1_i_tready(data1_i_tready),
      .data1_i_tvalid(data1_i_tvalid),
      .data2_i_tready(data2_i_tready),
      .data2_i_tvalid(data2_i_tvalid),
      .data_o_tready(data_o_tready),
      .data_o_tvalid(data_o_tvalid)
  );

endmodule
