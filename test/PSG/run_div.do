vlog -sv -work work {clock_strobe.sv}
vlog -sv -work work {clock_strobe_tb.sv}

restart -force
run -all

wave cursor active
wave refresh
wave zoom range 0ns 500ns
view signals
