
//! Параметризируемый беззнаковый сумматор с регистровыми входами и выходом.

//! { signal: [
//!  { name: "clk", wave: "P....." },
//!  { name: "reset", wave: "10...."},
//!  { name: "data1_i", wave: "x=====", data: ["4", "9",  "13", "5", "7"], node: '.a.b..' },
//!  { name: "data2_i", wave: "x=====", data: ["1", "3",  "13", "2", "6"]},
//!  { name: "data_o",  wave: "xxx===", data: ["5", "12", "26"], node: '...x.y.' }
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

module adder_regs #(
    parameter integer WIDTH = 4  //! разрядность слагаемых
) (
    input clk,                      //! тактовый сигнал
    input reset,                    //! сигнал сброса, активный уровень - 1
    input [WIDTH-1:0] data1_i,      //! первое слагаемое
    input [WIDTH-1:0] data2_i,      //! второе слагаемое
    output reg [WIDTH:0] data_o     //! результат сложения
);

  reg  [WIDTH-1:0] adder_in_1;  //! первый вход комбинационного сумматора
  reg  [WIDTH-1:0] adder_in_2;  //! второй вход комбинационного сумматора
  wire [  WIDTH:0] adder_out;   //! выход комбинационного сумматора

  //! входный регистр для первого слагаемого
  always @(posedge clk) begin : data1_i_reg
    if (reset) adder_in_1 <= '0;
    else adder_in_1 <= data1_i;
  end

  //! входный регистр для второго слагаемого
  always @(posedge clk) begin : data2_i_reg
    if (reset) adder_in_2 <= '0;
    else adder_in_2 <= data2_i;
  end

  //! комбинационный сумматор
  adder_comb #(
      .WIDTH(WIDTH)
  ) adder_comb (
      .data1_i(adder_in_1),
      .data2_i(adder_in_2),
      .data_o (adder_out)
  );

  //! выходной регистр
  always @(posedge clk) begin : data_o_reg
    if (reset) data_o <= '0;
    else data_o <= adder_out;
  end


endmodule
