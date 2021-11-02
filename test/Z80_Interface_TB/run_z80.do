vlog -sv -work work {Z80_Bus_Interface.sv}
vlog -sv -work work {Z80_Bus_Interface_tb.sv}

restart -force
run -all

wave cursor active
wave refresh
wave zoom range 1000ns 2000ns
view signals
