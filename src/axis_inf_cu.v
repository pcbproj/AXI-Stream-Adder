//! Конечный автомат управлния загрузкой во внутренний регистр сумматора

module axis_inf_cu (
  input aclk,     //! тактовый сигнал
  input aresetn,  //! асинхронный сброс. активный уровень - 0

  output load_en, //! сигнал разрешения загрузки внутреннего регистра

  //! @virtualbus upstream @dir in
  input  upstream_tvalid,  //! сигнал валидности данных
  output upstream_tready,  //! сигнал готовности принять данные @end

  //! @virtualbus upstream @dir out
  output downstream_tvalid,  //! сигнал валидности данных
  input  downstream_tready   //! сигнал готовности принять данные @end
);

  localparam EMPTY = 1'b0; //! состояние свободного внутреннего регистра
  localparam FULL  = 1'b1; //! состояние занятого внутреннего регистра

  //! состояние конечного автомата
  reg state;

  //! логика перехода между состояними автомата
  always @(posedge aclk or negedge aresetn) begin : FSM_State_Transition
    if (!aresetn) state <= EMPTY;
    else
      case (state)

        // если регистр пустой и данные валидны, то записываем данные
        EMPTY:
          if (upstream_tvalid) state <= FULL;

        // если в регистре есть данные и приемник их готов принять,
        // то данные считываются. Если одновременно на входе есть
        // валидные данные, то они записываются в регистр, и он
        // остается в заполенном состоянии
        FULL:
          if (downstream_tready && !upstream_tvalid) state <= EMPTY;

        default:
          state <= EMPTY;
      endcase
  end

  // выставляем сигнал готовности к приему данных и сигнал записи в регистр,
  // если регистр не занят, или если занять, но приемник готов
  // из него считать данные
  assign load_en = (state == EMPTY) || (downstream_tready & state == FULL);
  assign upstream_tready = load_en;

  // выставляем сигнал валидности, если данные загружены в регистр
  assign downstream_tvalid = (state == FULL);

endmodule
