
//! Параметризируемый беззнаковый сумматор с входным и выходным строб-сигналом.

//! { signal: [
//!  { name: "clk", wave: "P......." },
//!  { name: "reset", wave: "10......"},
//!  { name: "valid_i", wave: "x010.10.", node: '..a..b.'},
//!  { name: "data1_i", wave: "xx=xx=xx", data: ["4", "9"] },
//!  { name: "data2_i", wave: "xx=xx=xx", data: ["1", "3"]},
//!  { name: "valid_o", wave: "x0..10.1", node: '....x..y'},
//!  { name: "data_o",  wave: "xxxx=xx=", data: ["5", "12"] }
//! ],
//! edge: [
//!    'a~>x', 'b~>y'
//!  ],
//!  head:{
//!     text:'Временные диаграммы работы'
//!  },
//!  config: {
//!    hscale: 2
//!  }
//!}

module adder_valid_io #(
    parameter integer WIDTH = 4  //! разрядность слагаемых
) (
    input              clk,      //! тактовый сигнал
    input              reset,    //! сигнал сброса, активный уровень - 1
    input              valid_i,  //! входной строб-сигнал
    input  [WIDTH-1:0] data1_i,  //! первое слагаемое
    input  [WIDTH-1:0] data2_i,  //! второе слагаемое
    output             valid_o,  //! выходной строб-сигнал
    output [  WIDTH:0] data_o    //! результат сложения
);

  //! регистр сдвига для задержки строб-сигнала
  reg [1:0] valid_shift_reg;

  //! сумматор с входным строб-сигналом
  adder_valid_i #(
      .WIDTH(WIDTH)
  ) adder_valid_i (
      .clk    (clk),
      .reset  (reset),
      .data1_i(data1_i),
      .data2_i(data2_i),
      .valid_i(valid_i),
      .data_o (data_o)
  );

  //! задерживаем входной строб-сигнал на два такта для
  //! выравния его с выходными данными
  always @(posedge clk) begin : valid_i_shift_reg
    if (reset) valid_shift_reg <= 2'b00;
    else valid_shift_reg <= {valid_shift_reg[0], valid_i};
  end
  assign valid_o = valid_shift_reg[1];


endmodule
