vlog -sv -work work {clock_strobe.sv}
vcom -93 -work work {ym2149_audio.vhd}
vlog -sv -work work {psg_tb.sv}

restart -force
run -all

wave cursor active
wave refresh
wave zoom range 0ns 6500ns
view signals
