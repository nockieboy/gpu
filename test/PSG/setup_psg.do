transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work
vmap work work

vlog -sv -work work {clock_strobe.sv}
vcom -93 -work work {ym2149_audio.vhd}
vlog -sv -work work {psg_tb.sv}

vsim -t 1ns -L work -voptargs="+acc"  psg_tb

restart -force -nowave

# This line shows only the variable name instead of the full path and which module it was in
config wave -signalnamewidth 1

#add wave -divider     "INPUT: System Clock"
#add wave -hexadecimal sim:/psg_tb/DUT/clk_i

#add wave -divider     "OUTPUT: ClockDiv"
#add wave -hexadecimal sim:/psg_tb/DUT/clk_o

add wave -divider     "OUTPUT: ClockDiv Strobe"
#add wave -hexadecimal sim:/psg_tb/DUT/strb_o
add wave -decimal     sim:/psg_tb/f_count

#add wave -divider     ""
#add wave -divider     "YM2149: PSG Module"

add wave -divider     "YM2149: Clocks"
add wave -hexadecimal sim:/psg_tb/PSG/clk_i
add wave -hexadecimal sim:/psg_tb/PSG/en_clk_psg_i

add wave -divider     "YM2149: Control"
add wave -hexadecimal sim:/psg_tb/PSG/reset_n_i
add wave -hexadecimal sim:/psg_tb/PSG/sel_n_i
add wave -hexadecimal sim:/psg_tb/PSG/bc_i
add wave -hexadecimal sim:/psg_tb/PSG/bdir_i

add wave -divider     "YM2149: Data"
add wave -hexadecimal sim:/psg_tb/PSG/data_i
add wave -hexadecimal sim:/psg_tb/PSG/data_r_o

add wave -divider     "YM2149: Audio"
add wave -hexadecimal sim:/psg_tb/PSG/ch_a_o
add wave -hexadecimal sim:/psg_tb/PSG/ch_b_o
add wave -hexadecimal sim:/psg_tb/PSG/ch_c_o
add wave -hexadecimal sim:/psg_tb/PSG/mix_audio_o
add wave -hexadecimal sim:/psg_tb/PSG/pcm14s_o

do run_psg.do
