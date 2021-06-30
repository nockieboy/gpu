transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work
vmap work work
vlog -sv -work work {HDMI_PLL.sv}
vlog -sv -work work {HDMI_PLL_tb.sv}
vsim -default_radix unsigned -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L work -voptargs="+acc" HDMI_PLL_tb
