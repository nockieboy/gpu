transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work
vmap work work
vlog -sv -work work {Z80_Bus_Interface.sv}
vlog -sv -work work {Z80_Bus_Interface_tb.sv}

vsim -t 1ps -L work -voptargs="+acc"  Z80_Bus_Interface_tb

restart -force -nowave
# This line shows only the variable name instead of the full path and which module it was in
config wave -signalnamewidth 1

#add  wave /Z80_Bus_Interface_tb/*

add wave -divider "Script File"
add wave -ascii       /Z80_Bus_Interface_tb/TB_COMMAND_SCRIPT_FILE
add wave -decimal     /Z80_Bus_Interface_tb/Script_LINE
add wave -ascii       /Z80_Bus_Interface_tb/Script_CMD

add wave -divider     "Z80 MASTER"
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_RSTn 
#add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_CKS_pos 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_CKS 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_CLK 

add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_ADDR 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_M1 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_MREQ
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_IORQ 

add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_WAIT 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_wait_sh 

add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_RD 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_WR 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_DATA 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_read_sh 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_REFRESH 

#add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_INT 
#add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_NMI 

#add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_BUSREQ 
#add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_BUSACK 
#add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_HALT 

add wave -divider     "LVT245 buffer control"
add wave -hexadecimal /Z80_Bus_Interface_tb/DIR_245 
add wave -hexadecimal /Z80_Bus_Interface_tb/OE_245 
add wave -hexadecimal /Z80_Bus_Interface_tb/EA_DIR 
add wave -hexadecimal /Z80_Bus_Interface_tb/EA_OE 

add wave -divider     "Core CMD_CLK"
add wave -hexadecimal /Z80_Bus_Interface_tb/reset
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_CLK

add wave -divider     "DDR3 CMD_IO"
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_R_busy 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_read_req 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_raddr 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_read_ready 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_read_data 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_W_busy 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_write_req 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_waddr 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_write_data 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_write_mask 

add wave -divider     "IO PORTS"
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_BRIDGE/GEO_WR_LO 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_BRIDGE/GEO_WR_LO_STROBE 
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_BRIDGE/GEO_STAT_RD
add wave -hexadecimal /Z80_Bus_Interface_tb/Z80_BRIDGE/GEO_STAT_RD_STROBE

do run_z80.do
