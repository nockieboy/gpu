derive_pll_clocks -create_base_clocks
derive_clock_uncertainty

#Specify the clock period
set period 20.000
#Specify the required tSU
set tSU 0.900
#Specify the required tH
set tH 0.250
#Specify the required tCO
set tCO -0.900
set tCOm 0.000

set_input_delay  -clock clk54m -max $tSU  [get_ports {Z80*[*]}]
set_input_delay  -clock clk54m -max $tSU  [get_ports {Z80_CLK Z80_IORQ Z80_M1 Z80_MREQ Z80_RD Z80_RST Z80_WR}]
set_input_delay  -clock clk54m -max $tSU  [get_ports {PS2_CLK PS2_DAT uart_rxd RESET_PIN}]
set_input_delay  -clock clk54m -min $tH   [get_ports {Z80*[*]}]
set_input_delay  -clock clk54m -min $tH   [get_ports {Z80_CLK Z80_IORQ Z80_M1 Z80_MREQ Z80_RD Z80_RST Z80_WR}]
set_input_delay  -clock clk54m -min $tH   [get_ports {PS2_CLK PS2_DAT uart_rxd RESET_PIN}]

set_output_delay -clock clk54m -max $tCO  [get_ports {Z80_data[*]}]
set_output_delay -clock clk54m -max $tCO  [get_ports {OE_245 DIR_245 uart_txd PS2_DAT SPEAKER STATUS_LED}]
set_output_delay -clock clk54m -min $tCOm [get_ports {Z80_data[*]}]
set_output_delay -clock clk54m -min $tCOm [get_ports {OE_245 DIR_245 uart_txd PS2_DAT SPEAKER STATUS_LED}]

set_output_delay -clock clk54m -max $tCO [get_ports {r[*]}]
set_output_delay -clock clk54m -max $tCO [get_ports {g[*]}]
set_output_delay -clock clk54m -max $tCO [get_ports {b[*]}]
set_output_delay -clock clk54m -max $tCO [get_ports {hs pixel_clk vde vs}]
set_output_delay -clock clk54m -min $tCOm [get_ports {r[*]}]
set_output_delay -clock clk54m -min $tCOm [get_ports {g[*]}]
set_output_delay -clock clk54m -min $tCOm [get_ports {b[*]}]
set_output_delay -clock clk54m -min $tCOm [get_ports {hs pixel_clk vde vs}]

