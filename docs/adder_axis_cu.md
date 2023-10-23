
# Модуль: adder_axis_cu 
- **Файл**: adder_axis_cu.v

## Диаграмма
![Диаграмма](adder_axis_cu.svg "Диаграмма")
## Описание

Конечный автомат управления служебными сигналами сумматора
с AXI-Stream интерфейсами. Модуль управляет загрузкой данных
во внутренние регитры сумматора и формирует tvalid и tready
сигналы

## Порты

| Название   | Направление | Тип         | Описание                                          |
| ---------- | ----------- | ----------- | ------------------------------------------------- |
| aclk       | input       |             | тактовый сигнал                                   |
| aresetn    | input       |             | асинхронный сброс. активный уровень - 0           |
| data1_i_ce | output      |             | загрузка первого слагаемого во внутренний регистр |
| data2_i_ce | output      |             | загрузка второго слагаемого во внутренний регистр |
| data_o_ce  | output      |             | загрузка результата вы выходной регистр           |
| data1_i    | in          | Virtual bus |                                                   |
| data2_i    | in          | Virtual bus |                                                   |
| data_o     | out         | Virtual bus |                                                   |

### Виртуальные шины

#### data1_i

| Название       | Направление | Тип | Описание                         |
| -------------- | ----------- | --- | -------------------------------- |
| data1_i_tvalid | input       |     | сигнал валидности данных         |
| data1_i_tready | output      |     | сигнал готовности принять данные |
#### data2_i

| Название       | Направление | Тип | Описание                         |
| -------------- | ----------- | --- | -------------------------------- |
| data2_i_tvalid | input       |     | сигнал валидности данных         |
| data2_i_tready | output      |     | сигнал готовности принять данные |
#### data_o

| Название      | Направление | Тип | Описание                         |
| ------------- | ----------- | --- | -------------------------------- |
| data_o_tvalid | output      |     | сигнал валидности данных         |
| data_o_tready | input       |     | сигнал готовности принять данные |

## Сигналы

| Название          | Тип  | Описание                                                 |
| ----------------- | ---- | -------------------------------------------------------- |
| data1_i_reg_valid | wire | сигнал готовности первого слагаемого во входном регистре |
| data2_i_reg_valid | wire | сигнал готовности второго слагаемого во входном регистре |
| data_o_reg_ready  | wire | сигнал готовности выходного регистра принять данные      |
| start_summation   | wire | сигнал готовности выпонить суммирование слагаемых        |

## Подключенные модули

- data1_i_cu: axis_inf_cu
  -  конечный автомат управления загрузкой входного регистра для первого слагаемого- data2_i_cu: axis_inf_cu
  -  конечный автомат управления загрузкой входного регистра для второго слагаемого- data_o_cu: axis_inf_cu
  -  конечный автомат управления загрузкой выходного регистра