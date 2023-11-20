`ifndef TB_DEFINES_VH
`define TB_DEFINES_VH

// разрядность шины входных слагаемых
`ifndef WIDTH
  `define WIDTH 4
`endif

// ширина входных и выходных шины AXI-Stream интерфейса
`define AXIS_IN_WIDTH $ceil($itor(`WIDTH)/8)*8
`define AXIS_OUT_WIDTH $ceil($itor(`WIDTH+1)/8)*8

// максимальное число транзакций в тесте
`ifndef MAX_TRANS_NUMBER
  `define MAX_TRANS_NUMBER 1000
`endif

`endif