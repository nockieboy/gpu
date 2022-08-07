transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work
vmap work work

vlog -sv -work work {fp_div.sv}
vlog -sv -work work {jt49.v}
vlog -sv -work work {jt49_cen.v}
vlog -sv -work work {jt49_div.v}
vlog -sv -work work {jt49_noise.v}
vlog -sv -work work {jt49_eg.v}
vlog -sv -work work {jt49_exp.v}
vlog -sv -work work {filter/jt49_dcrm2.v}
vlog -sv -work work {jt49_tb.sv}

vsim -t 1ns -L work -voptargs="+acc"  jt49_tb

restart -force -nowave

# This line shows only the variable name instead of the full path and which module it was in
config wave -signalnamewidth 1

#add wave -divider     "INPUT: System Clock"
#add wave -hexadecimal sim:/jt49_tb/DUT/clk_i

#add wave -divider     "OUTPUT: ClockDiv"
#add wave -hexadecimal sim:/jt49_tb/DUT/clk_o

add wave -divider     "OUTPUT: ClockDiv Strobe"
#add wave -hexadecimal sim:/jt49_tb/DUT/strb_o
add wave -decimal     sim:/jt49_tb/f_count

#add wave -divider     ""
#add wave -divider     "JT49: PSG Module"

add wave -divider     "JT49: Clocks"
add wave -hexadecimal sim:/jt49_tb/PSG/clk
add wave -hexadecimal sim:/jt49_tb/PSG/clk_en

add wave -divider     "JT49: Control"
add wave -hexadecimal sim:/jt49_tb/PSG/rst_n
add wave -hexadecimal sim:/jt49_tb/PSG/wr_n
add wave -hexadecimal sim:/jt49_tb/PSG/addr
add wave -hexadecimal sim:/jt49_tb/PSG/din

add wave -divider     "JT49: Data"
add wave -hexadecimal sim:/jt49_tb/PSG/dout

add wave -divider     "JT49: Audio"
add wave -hexadecimal sim:/jt49_tb/PSG/A
add wave -unsigned -analog -min 0 -max 255 -height 150 sim:/jt49_tb/PSG/A

add wave -hexadecimal sim:/jt49_tb/PSG/B
add wave -unsigned -analog -min 0 -max 255 -height 150 sim:/jt49_tb/PSG/B

add wave -hexadecimal sim:/jt49_tb/PSG/C
add wave -unsigned -analog -min 0 -max 255 -height 150 sim:/jt49_tb/PSG/C

add wave -hexadecimal sim:/jt49_tb/sound_mix
add wave -unsigned -analog -min 0 -max 1023 -height 150 sim:/jt49_tb/sound_mix

add wave -divider     "Post DC Filter"
add wave -hexadecimal sim:/jt49_tb/sound
add wave -decimal  -analog -min -512 -max 511 -height 150 sim:/jt49_tb/sound

do run_psg.do
