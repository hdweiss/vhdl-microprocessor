OPTIONS=-93 -quiet -lint
DIR=.


all: clean base
	vcom $(OPTIONS) $(DIR)/ProcessorTestBench.vhd
	vsim -do sim.do ProcessorTestBench

base:
	vlib work
	vcom $(OPTIONS) $(DIR)/pro_types.vhd
	vcom $(OPTIONS) $(DIR)/Mul16_4.vhd
	vcom $(OPTIONS) $(DIR)/Mul16.vhd
	vcom $(OPTIONS) $(DIR)/Mul4.vhd
	vcom $(OPTIONS) $(DIR)/Extend11_0.vhd
	vcom $(OPTIONS) $(DIR)/Extend3_0.vhd
	vcom $(OPTIONS) $(DIR)/Extend7_0.vhd
	vcom $(OPTIONS) $(DIR)/alu.vhd
	vcom $(OPTIONS) $(DIR)/InstructionMemory.vhd
	vcom $(OPTIONS) $(DIR)/Registers.vhd
	vcom $(OPTIONS) $(DIR)/ALU.vhd
	vcom $(OPTIONS) $(DIR)/Branch.vhd
	vcom $(OPTIONS) $(DIR)/Control.vhd
	vcom $(OPTIONS) $(DIR)/"DataMemory .vhd"
	vcom $(OPTIONS) $(DIR)/Hazard_Unit.vhd
	vcom $(OPTIONS) $(DIR)/InstructionMemory.vhd
	vcom $(OPTIONS) $(DIR)/pro_types.vhd
	vcom $(OPTIONS) $(DIR)/Registers.vhd
	vcom $(OPTIONS) $(DIR)/SPMemory.vhd
	vcom $(OPTIONS) $(DIR)/uart/sim_sc_uart.vhd
	vcom $(OPTIONS) $(DIR)/DataPath.vhd
	vcom $(OPTIONS) $(DIR)/Processor.vhd
	vcom $(OPTIONS) $(DIR)/ProcessorTestBench.vhd
clean:
	-rm *.wlf
