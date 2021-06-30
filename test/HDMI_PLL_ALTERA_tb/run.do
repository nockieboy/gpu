vlog -sv -work work {HDMI_PLL.sv}
vlog -sv -work work {HDMI_PLL_tb.sv}
#vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L work -voptargs="+acc" HDMI_PLL_tb

restart -force -nowave
# This line shows only the varible name instead of the full path and which module it was in
config wave -signalnamewidth 1

add wave -position insertpoint -radix unsigned sim:/HDMI_PLL_tb/*

add wave -position insertpoint  \
-radix unsigned \
-divider "Audio CLK Gen" \
sim:/HDMI_PLL_tb/DUT/aud_per_x4096 \
sim:/HDMI_PLL_tb/DUT/aud_per_int \
sim:/HDMI_PLL_tb/DUT/aud_per_f \
sim:/HDMI_PLL_tb/DUT/aud_cnt_m \
sim:/HDMI_PLL_tb/DUT/aud_cnt_n

view structure
view signals

run -all

wave cursor active
wave refresh
wave zoom range 1000500ns 1000560ns
view signals
