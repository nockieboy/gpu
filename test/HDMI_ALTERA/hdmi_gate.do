restart -force -nowave
# This line shows only the varible name instead of the full path and which module it was in
config wave -signalnamewidth 1

add wave -position insertpoint  \
-radix binary \
-color #00ffff \
-label "clk" sim:/HDMI_test_tb/clk  \
-color #00ff00 \
-divider "TMDS_CLOCK" \
-radix binary \
-expand -label "PLL clk bus" {sim:/HDMI_test_tb/DUT/\HDMI_PLL|HPLL1|auto_generated|pll1_CLK_bus }  \
-divider "" \
-divider "TMDS_3" \
-label "TNDS_3(p)" {sim:/HDMI_test_tb/tmds[3]}  \
-label "TNDS_3(n)" {sim:/HDMI_test_tb/DUT/\tmds[3](n) }  \
-divider "TMDS_2" \
-label "TMDS_2(p)" {sim:/HDMI_test_tb/tmds[2]}  \
-label "TMDS_2(n)" {sim:/HDMI_test_tb/DUT/\tmds[2](n) } \
-divider "TMDS_1" \
-label "TNDS_1(p)" {sim:/HDMI_test_tb/tmds[1]}  \
-label "TNDS_1(n)" {sim:/HDMI_test_tb/DUT/\tmds[1](n) } \
-divider "TMDS_1" \
-label "TNDS_0(p)" {sim:/HDMI_test_tb/tmds[0]}  \
-label "TNDS_0(n)" {sim:/HDMI_test_tb/DUT/\tmds[0](n) } \
-divider "" \


view structure
view signals
wave zoom range 0ns 1000ns
run -all
