WIDTH=4

# сборка, моделирование и вывод waveforms
all:
	make build
	make sim
	make wave

# сборка проекта
build:
	iverilog src/adder_comb.v src/adder_axis_cu.v src/axis_inf_cu.v src/adder_axis_pipe.v tests/adder_axis_tb.v -o adder_snap -I tests -DWIDTH=$(WIDTH)

# моделирование проекта
sim:
	vvp adder_snap +trans_number=15 +seed=$(shell bash -c 'echo $$RANDOM') +max_axis_delay=0 +min_axis_delay=0

# отображение дампа waveforms через GTK Wave
wave:
	gtkwave wave_dump.vcd

# очищение проекта
clean:
	rm -f */a.out
	rm -f wave_dump.vcd
	rm -f adder_snap
