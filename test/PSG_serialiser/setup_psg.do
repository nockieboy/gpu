transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work
vmap work work

vlog -sv -work work {fp_div.sv}
vlog -sv -work work {BHG_jt49.v}
vlog -sv -work work {jt49_cen.v}
vlog -sv -work work {jt49_div.v}
vlog -sv -work work {jt49_noise.v}
vlog -sv -work work {jt49_eg.v}
vlog -sv -work work {BHG_jt49_exp.v}
vlog -sv -work work {filter/jt49_dcrm2.v}
vlog -sv -work work {filter/jt49_mave.v}
vlog -sv -work work {filter/jt49_dly.v}
vlog -sv -work work {I2S_transmitter.sv}
vlog -sv -work work {YM2149_PSG_system.sv}
vlog -sv -work work {jt49_tb.sv}

vsim -t 1ns -L work -voptargs="+acc"  jt49_tb

restart -force -nowave

# This line shows only the variable name instead of the full path and which module it was in
config wave -signalnamewidth 1

#add wave -divider     "INPUT: System Clock"
#add wave -hexadecimal sim:/jt49_tb/PSG_system/DUT/clk_i

#add wave -divider     "OUTPUT: ClockDiv"
#add wave -hexadecimal sim:/jt49_tb/PSG_system/DUT/clk_o

add wave -divider     "OUTPUT: ClockDiv Strobe"
#add wave -hexadecimal sim:/jt49_tb/PSG_system/DUT/strb_o
add wave -decimal     sim:/jt49_tb/f_count

#add wave -divider     ""
#add wave -divider     "JT49: PSG Module"

add wave -divider     "JT49: Clocks"
add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/clk
add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/clk_en

add wave -divider     "JT49: Control"
add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/rst_n
add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/wr_n
add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/addr
add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/din

add wave -divider     "JT49: Data"
add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/dout

add wave -divider     "JT49: Audio"
add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/A
add wave -unsigned -analog -min 0 -max 1023 -height 150 sim:/jt49_tb/PSG_system/PSG/A

add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/B
add wave -unsigned -analog -min 0 -max 1023 -height 150 sim:/jt49_tb/PSG_system/PSG/B

add wave -hexadecimal sim:/jt49_tb/PSG_system/PSG/C
add wave -unsigned -analog -min 0 -max 1023 -height 150 sim:/jt49_tb/PSG_system/PSG/C

add wave -hexadecimal sim:/jt49_tb/PSG_system/sound_mix
add wave -unsigned -analog -min 0 -max 4095 -height 150 sim:/jt49_tb/PSG_system/sound_mix

add wave -divider     "Post DC Filter"
add wave -hexadecimal sim:/jt49_tb/PSG_system/sound
add wave -decimal  -analog -min -2048 -max 2047 -height 150 sim:/jt49_tb/PSG_system/sound_dcf
add wave -decimal  -analog -min -2048 -max 2047 -height 150 sim:/jt49_tb/PSG_system/sound

add wave -divider	  "I2S Transmitter"
add wave -hexadecimal sim:/jt49_tb/PSG_system/I2S_TX/sample_pulse
add wave -hexadecimal sim:/jt49_tb/PSG_system/I2S_TX/I2S_BCLK
add wave -hexadecimal sim:/jt49_tb/PSG_system/I2S_TX/I2S_WCLK
add wave -hexadecimal sim:/jt49_tb/PSG_system/I2S_TX/I2S_DATA

do run_psg.do
