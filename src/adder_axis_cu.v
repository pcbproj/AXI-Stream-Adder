//! Конечный автомат управления служебными сигналами сумматора
//! с AXI-Stream интерфейсами. Модуль управляет загрузкой данных
//! во внутренние регитры сумматора и формирует tvalid и tready
//! сигналы
module adder_axis_cu (
    input aclk,    //! тактовый сигнал
    input aresetn, //! асинхронный сброс. активный уровень - 0

    output data1_i_ce,  //! загрузка первого слагаемого во внутренний регистр
    output data2_i_ce,  //! загрузка второго слагаемого во внутренний регистр
    output data_o_ce,   //! загрузка результата вы выходной регистр

    //! @virtualbus data1_i @dir in
    input  data1_i_tvalid,  //! сигнал валидности данных
    output data1_i_tready,  //! сигнал готовности принять данные @end

    //! @virtualbus data2_i @dir in
    input  data2_i_tvalid,  //! сигнал валидности данных
    output data2_i_tready,  //! сигнал готовности принять данные @end

    //! @virtualbus data_o @dir out
    output data_o_tvalid,  //! сигнал валидности данных
    input  data_o_tready   //! сигнал готовности принять данные @end
);

  wire data1_i_reg_valid; //! сигнал готовности первого слагаемого во входном регистре
  wire data2_i_reg_valid; //! сигнал готовности второго слагаемого во входном регистре
  wire data_o_reg_ready;  //! сигнал готовности выходного регистра принять данные

  wire start_summation;   //! сигнал готовности выпонить суммирование слагаемых

  //! конечный автомат управления загрузкой входного регистра для первого слагаемого
  axis_inf_cu data1_i_cu (
    .aclk(aclk),
    .aresetn(aresetn),
    .load_en(data1_i_ce),
    .upstream_tready(data1_i_tready),
    .upstream_tvalid(data1_i_tvalid),
    .downstream_tready(start_summation),
    .downstream_tvalid(data1_i_reg_valid)
  );

  //! конечный автомат управления загрузкой входного регистра для второго слагаемого
  axis_inf_cu data2_i_cu (
    .aclk(aclk),
    .aresetn(aresetn),
    .load_en(data2_i_ce),
    .upstream_tready(data2_i_tready),
    .upstream_tvalid(data2_i_tvalid),
    .downstream_tready(start_summation),
    .downstream_tvalid(data2_i_reg_valid)
  );

  //! конечный автомат управления загрузкой выходного регистра
  axis_inf_cu data_o_cu (
    .aclk(aclk),
    .aresetn(aresetn),
    .load_en(data_o_ce),
    .upstream_tready(data_o_reg_ready),
    .upstream_tvalid(start_summation),
    .downstream_tready(data_o_tready),
    .downstream_tvalid(data_o_tvalid)
  );

  // выполнять сложение можно, если входные регистры содержат данные и выходной
  // регистр готов их принять
  assign start_summation = data1_i_reg_valid & data2_i_reg_valid & data_o_reg_ready;

endmodule


