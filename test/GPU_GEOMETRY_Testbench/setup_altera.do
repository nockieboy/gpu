transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work
vmap work work
vlog -sv -work work {FIFO_2word_FWFT.sv}
vlog -sv -work work {BrianHG_DDR3_FIFOs.sv}
vlog -sv -work work {line_generator.sv}
vlog -sv -work work {ellipse_generator.sv}
vlog -sv -work work {geometry_xy_plotter.sv}
vlog -sv -work work {pixel_address_generator.sv}
vlog -sv -work work {geo_pixel_writer.sv}
vlog -sv -work work {GPU_GEO_tb.sv}
#vsim -default_radix unsigned -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L work -voptargs="+acc" GPU_GEO_tb
vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L work -voptargs="+acc" GPU_GEO_tb
