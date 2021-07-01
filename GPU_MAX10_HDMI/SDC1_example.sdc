## Generated SDC file "GPU.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

## DATE    "Wed Aug 19 01:28:04 2020"

##
## DEVICE  "EP4CE10E22C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk54m} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk54m}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {inst17|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst17|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -divide_by 2 -master_clock {clk54m} [get_pins {inst17|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst17|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst17|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -master_clock {clk54m} [get_pins {inst17|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst17|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {inst17|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {clk54m} [get_pins {inst17|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {inst17|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {inst17|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -divide_by 2 -phase 45.000 -master_clock {clk54m} [get_pins {inst17|altpll_component|auto_generated|pll1|clk[3]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk54m}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {clk54m}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {clk54m}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {clk54m}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {clk54m}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {clk54m}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {clk54m}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {clk54m}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clk54m}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clk54m}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clk54m}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clk54m}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {clk54m}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {clk54m}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {clk54m}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {clk54m}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[3]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[3]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[3]}] -rise_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[3]}] -fall_to [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[1]}]  0.010  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {IEI}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {IEI}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {PS2_CLK}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {PS2_CLK}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {PS2_DAT}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {PS2_DAT}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {RESET_PIN}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {RESET_PIN}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[0]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[0]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[1]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[1]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[2]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[2]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[3]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[3]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[4]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[4]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[5]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[5]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[6]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[6]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[7]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[7]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[8]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[8]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[9]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[9]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[10]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[10]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[11]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[11]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[12]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[12]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[13]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[13]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[14]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[14]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[15]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[15]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[16]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[16]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[17]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[17]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[18]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[18]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[19]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[19]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[20]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[20]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_ADDR[21]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_ADDR[21]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_CLK}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_CLK}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_IORQ}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_IORQ}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_M1}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_M1}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_MREQ}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_MREQ}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_RD}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_RD}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_RST}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_RST}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_WR}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_WR}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_data[0]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_data[0]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_data[1]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_data[1]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_data[2]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_data[2]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_data[3]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_data[3]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_data[4]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_data[4]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_data[5]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_data[5]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_data[6]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_data[6]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {Z80_data[7]}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {Z80_data[7]}]
set_input_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.750 [get_ports {uart_rxd}]
set_input_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  7.750 [get_ports {uart_rxd}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {245_DIR}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {245_DIR}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {245_OE}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {245_OE}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {EA_DIR}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {EA_DIR}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {EA_OE}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {EA_OE}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {IEO}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {IEO}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {LED_rdx}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {LED_rdx}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {LED_txd}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {LED_txd}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {PS2_CLK}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {PS2_CLK}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {PS2_DAT}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {PS2_DAT}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {SPEAKER}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {SPEAKER}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {STATUS_LED}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {STATUS_LED}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {Z80_INT_RQ}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {Z80_INT_RQ}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {Z80_data[0]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {Z80_data[0]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {Z80_data[1]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {Z80_data[1]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {Z80_data[2]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {Z80_data[2]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {Z80_data[3]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {Z80_data[3]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {Z80_data[4]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {Z80_data[4]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {Z80_data[5]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {Z80_data[5]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {Z80_data[6]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {Z80_data[6]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {Z80_data[7]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {Z80_data[7]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {b[0]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {b[0]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {b[1]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {b[1]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {b[2]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {b[2]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {b[3]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {b[3]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {b[4]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {b[4]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {b[5]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {b[5]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {g[0]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {g[0]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {g[1]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {g[1]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {g[2]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {g[2]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {g[3]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {g[3]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {g[4]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {g[4]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {g[5]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {g[5]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {hs}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {hs}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {pixel_clk}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {pixel_clk}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {r[0]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {r[0]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {r[1]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {r[1]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {r[2]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {r[2]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {r[3]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {r[3]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {r[4]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {r[4]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {r[5]}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {r[5]}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {uart_txd}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {uart_txd}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {vde}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {vde}]
set_output_delay -add_delay -max -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  5.600 [get_ports {vs}]
set_output_delay -add_delay -min -clock [get_clocks {inst17|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {vs}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

