//! Конечный автомат управления служебными сигналами сумматора
//! с AXI-Stream интерфейсами. Модуль упарвляет загрузкой данных
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

  localparam IDLE = 3'b000;               //! состояние сброса устройста
  localparam WAIT_INPUT_DATA = 3'b001;    //! состояние готовности получать слагаемые
  localparam WAIT_DATA1_INPUT = 3'b010;   //! состояние после получения второго слагаемого и ожидание первого
  localparam WAIT_DATA2_INPUT = 3'b011;   //! состояние после получения первого слагаемого и ожидание второго
  localparam LOAD_OUTPUT_DATA = 3'b100;   //! состояние после получения слагаемых и формированя суммы
  localparam WAIT_OUTPUT_READY = 3'b101;  //! состояние j;blfybz,когда следующий блок заберет результат суммы

  //! состояние конечного автомата
  reg [2:0] state;

  //! логика перехода между состояними автомата
  always @(posedge aclk or negedge aresetn) begin : FSM_State_Transition
    if (!aresetn) state <= IDLE;
    else
      case (state)
        // после сброса ожидаем входные слагаемые
        IDLE:
          state <= WAIT_INPUT_DATA;

        // каждом такте можем получить первое слагаемое,
        // второе слагаемое или сразу оба. от этого зависит следующее
        // состояние. наличие входных данных определяется по
        // сигнал tvalid
        WAIT_INPUT_DATA:
          if (data1_i_tvalid && data2_i_tvalid) state <= LOAD_OUTPUT_DATA;
          else if (data1_i_tvalid) state <= WAIT_DATA2_INPUT;
          else if (data2_i_tvalid) state <= WAIT_DATA1_INPUT;

        // второе слагаемое получили, ждем первое слагаемое
        WAIT_DATA1_INPUT:
          if (data1_i_tvalid) state <= LOAD_OUTPUT_DATA;

        // первое слагаемое получили, ждем второе слагаемое
        WAIT_DATA2_INPUT:
          if (data2_i_tvalid) state <= LOAD_OUTPUT_DATA;

        // получили оба слагаемых. считаем сумму и загружаем
        // результат в выходной регистр
        LOAD_OUTPUT_DATA:
          state <= WAIT_OUTPUT_READY;

        // ожидаем готовности приемника получить результат суммы
        WAIT_OUTPUT_READY:
          if (data_o_tready) state <= WAIT_INPUT_DATA;

        default:
          state <= WAIT_INPUT_DATA;

      endcase
  end

  // пока не получено первое слагаемое его можно получить по AXI-Stream
  // и загрузить во входной внутренний регистр сумматора
  assign data1_i_ce = (state == WAIT_INPUT_DATA) || (state == WAIT_DATA1_INPUT);
  assign data1_i_tready = data1_i_ce;

  // пока не получено второе слагаемое его можно получить по AXI-Stream
  // и загрузить во входной внутренний регистр сумматора
  assign data2_i_ce = (state == WAIT_INPUT_DATA) || (state == WAIT_DATA2_INPUT);
  assign data2_i_tready = data2_i_ce;

  // загружаем резльтат суммы, после получения обоих слагаемых
  assign data_o_ce = (state == LOAD_OUTPUT_DATA);

  // после загрузки суммы в выходной регистр устанавливаем сигнал валидности
  assign data_o_tvalid = (state == WAIT_OUTPUT_READY);

endmodule


