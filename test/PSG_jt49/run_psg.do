vlog -sv -work work {fp_div.sv}
vlog -sv -work work {jt49.v}
vlog -sv -work work {jt49_cen.v}
vlog -sv -work work {jt49_div.v}
vlog -sv -work work {jt49_noise.v}
vlog -sv -work work {jt49_eg.v}
vlog -sv -work work {jt49_exp.v}
vlog -sv -work work {filter/jt49_dcrm2.v}
vlog -sv -work work {jt49_tb.sv}

restart -force
run -all

wave cursor active
wave refresh
wave zoomfull
view signals
