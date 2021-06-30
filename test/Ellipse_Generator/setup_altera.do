transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work
vmap work work
vlog -sv -work work {ellipse_generator.sv}
vlog -sv -work work {ellipse_generator_tb.sv}
#vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L work -voptargs="+acc"  ellipse_generator_tb
vsim -t 1ns -L work -voptargs="+acc"  ellipse_generator_tb
