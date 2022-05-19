vlog -sv -work work {BrianHG_DDR3/altera_gpio_lite.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_GEN_tCK.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_PLL.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_FIFOs.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_CMD_SEQUENCER.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_IO_PORT_ALTERA.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_PHY_SEQ.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_COMMANDER_v15.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_CONTROLLER_v15_top.sv}
vlog -sv -work work {HW_Regs.sv}
vlog -sv -work work {Z80_Bus_Interface.sv}
vlog -sv -work work {Z80_Bus_Interface_to_DDR3_tb.sv}

restart -force
run -all

wave cursor active
wave refresh
wave zoom range 19125ns 20125ns
view signals
