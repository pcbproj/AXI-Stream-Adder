`ifndef TB_DEFINES_VH
`define TB_DEFINES_VH

// разрядность шины входных слагаемых
`ifndef WIDTH
  `define WIDTH 4
`endif

// ширина шины входных и выходных AXI-Stream интерфейсов
`define AXIS_IN_WIDTH $ceil($itor(`WIDTH)/8)*8
`define AXIS_OUT_WIDTH $ceil($itor(`WIDTH+1)/8)*8

// число транзакций в тесте
`ifndef TRANS_NUMBER
  `define TRANS_NUMBER 5
`endif

// начальное состояние генератора случайных чисел
`ifndef SEED
  `define SEED 0
`endif

// минимальная задержка в тактах на AXI-Stream интерфейсе
`ifndef MIN_AXIS_DELAY
  `define MIN_AXIS_DELAY 0
`endif

// максимальная задержка в тактах на AXI-Stream интерфейсе
`ifndef MAX_AXIS_DELAY
  `define MAX_AXIS_DELAY 10
`endif

// максимальное значение генерируемое драйвером AXI-Stream интерфейса
`ifndef MAX_AXIS_VALUE
  `define MAX_AXIS_VALUE 2**`WIDTH - 1
`endif

// максимальная длительность теста в тактах
`ifndef MAX_CLK_IN_TEST
  `define MAX_CLK_IN_TEST 300
`endif

`endif
