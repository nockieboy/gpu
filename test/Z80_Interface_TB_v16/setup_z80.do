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
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_busy 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_ena 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_addr 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_read_ready 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_read_data
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_write_ena 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_write_data 
add wave -hexadecimal /Z80_Bus_Interface_tb/CMD_write_mask 

add wave -divider     "Write IO PORTS"
add wave -hexadecimal sim:/Z80_Bus_Interface_tb/Z80_BRIDGE/WRITE_PORT_CLK_POS 
add wave -hexadecimal {sim:/Z80_Bus_Interface_tb/Z80_BRIDGE/WRITE_PORT_STROBE[242]} 
add wave -hexadecimal {sim:/Z80_Bus_Interface_tb/Z80_BRIDGE/WRITE_PORT_DATA[242]} 

add wave -divider     "Read IO PORTS"
add wave -hexadecimal sim:/Z80_Bus_Interface_tb/Z80_BRIDGE/READ_PORT_CLK_sPOS
add wave -hexadecimal sim:/Z80_Bus_Interface_tb/Z80_BRIDGE/READ_PORT_CLK_aPOS
add wave -hexadecimal {sim:/Z80_Bus_Interface_tb/Z80_BRIDGE/READ_PORT_ACK[240]}
add wave -hexadecimal {sim:/Z80_Bus_Interface_tb/Z80_BRIDGE/READ_PORT_STROBE[240]}
add wave -hexadecimal {sim:/Z80_Bus_Interface_tb/Z80_BRIDGE/READ_PORT_DATA[240]}


do run_z80.do
