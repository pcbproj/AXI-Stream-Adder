# сборка, моделирование и вывод waveforms
all:
	make build
	make sim
	make wave

# сборка проекта
build:
	iverilog src/adder_comb.v src/adder_valid_i.v src/adder_valid_io.v tests/adder_valid_io_tb.v -o adder_snap

# моделирование проекта
sim:
	vvp adder_snap

# отображение дампа waveforms через GTK Wave
wave:
	gtkwave wave_dump.vcd

# очищение проекта
clean:
	rm -f */a.out
	rm -f wave_dump.vcd
	rm -f adder_snap