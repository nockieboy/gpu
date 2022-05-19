transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work
vmap work work
vlog -sv -work work {BrianHG_DDR3/altera_gpio_lite.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_GEN_tCK.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_PLL.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_FIFOs.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_CMD_SEQUENCER.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_IO_PORT_ALTERA.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_PHY_SEQ.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_COMMANDER_v15.sv}
vlog -sv -work work {BrianHG_DDR3/BrianHG_DDR3_CONTROLLER_v15_top.sv}
vlog -sv -work work {HW_Regs.sv}
vlog -sv -work work {Z80_Bus_Interface.sv}
vlog -sv -work work {Z80_Bus_Interface_to_DDR3_tb.sv}

# Make Cyclone IV E Megafunctions and PLL available.
vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L work -voptargs="+acc"  Z80_Bus_Interface_to_DDR3_tb

restart -force -nowave
# This line shows only the variable name instead of the full path and which module it was in
config wave -signalnamewidth 1

#add  wave /Z80_Bus_Interface_to_DDR3_tb/*

add wave -divider "Script File"
add wave -ascii       /Z80_Bus_Interface_to_DDR3_tb/TB_COMMAND_SCRIPT_FILE
add wave -decimal     /Z80_Bus_Interface_to_DDR3_tb/Script_LINE
add wave -ascii       /Z80_Bus_Interface_to_DDR3_tb/Script_CMD

add wave -divider     "Z80 MASTER"
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_RSTn 
#add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_CKS_pos 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_CKS 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_CLK 

add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_ADDR 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_M1 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_MREQ
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_IORQ 

add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_WAIT 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_wait_sh 

add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_RD 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_WR 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_DATA 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_read_sh 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_REFRESH 

#add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_INT 
#add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_NMI 

#add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_BUSREQ 
#add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_BUSACK 
#add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_HALT 

add wave -divider     "LVT245 buffer control"
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DIR_245 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/OE_245 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/EA_DIR 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/EA_OE 

add wave -divider     "Core CMD_CLK"
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/RST_IN
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/PLL_LOCKED
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_READY
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/CMD_CLK

add wave -divider     "DDR3 CMD_IO"
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/CMD_busy 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/CMD_ena 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/CMD_addr 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/CMD_read_ready 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/CMD_read_data  
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/CMD_write_ena
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/CMD_wdata 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/CMD_wmask 

add wave -divider     "Write DDR3 TAP port"
add wave -hexadecimal Z80_Bus_Interface_to_DDR3_tb/TAP_WRITE_ENA
add wave -hexadecimal Z80_Bus_Interface_to_DDR3_tb/TAP_ADDR
add wave -hexadecimal Z80_Bus_Interface_to_DDR3_tb/TAP_WDATA
add wave -hexadecimal Z80_Bus_Interface_to_DDR3_tb/TAP_WMASK

add wave -divider     "HW_Regs"
add wave -hexadecimal Z80_Bus_Interface_to_DDR3_tb/HW_Registers/enable
add wave -hexadecimal Z80_Bus_Interface_to_DDR3_tb/HW_Registers/valid_wr
add wave -hexadecimal Z80_Bus_Interface_to_DDR3_tb/HW_REGS__8bit
add wave -hexadecimal Z80_Bus_Interface_to_DDR3_tb/HW_REGS_16bit
add wave -hexadecimal Z80_Bus_Interface_to_DDR3_tb/HW_REGS_32bit

add wave -divider     "IO PORTS"
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_BRIDGE/GEO_WR_LO 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_BRIDGE/GEO_WR_LO_STROBE 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_BRIDGE/GEO_STAT_RD
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/Z80_BRIDGE/GEO_STAT_RD_STROBE


add wave -divider     "DDR3 SEQ RAM IO"
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_RESET_n
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_CKE
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_CMD
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_CK_p
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_CS_n
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_RAS_n
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_CAS_n
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_WE_n
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_ODT
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_A
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_BA
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_DQS_p 
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_DQ
add wave -hexadecimal /Z80_Bus_Interface_to_DDR3_tb/DDR3_DM


do run_z80_to_ddr3.do
