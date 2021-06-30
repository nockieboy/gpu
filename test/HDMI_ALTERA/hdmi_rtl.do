# Quick re-compile the source files incase there were some changes between running this script
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL {C:/altera/Qdesigns/HDMI_PLL/HDMI_Encoder.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/HDMI_PLL.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/hdmi.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src/Audio_Sample {C:/altera/Qdesigns/HDMI_PLL/src/Audio_Sample/Sine_1KHz_16b_48ksps.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/tmds_channel.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/source_product_description_info_frame.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/packet_assembler.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/auxiliary_video_information_info_frame.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/audio_sample_packet.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/audio_info_frame.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/audio_clock_regeneration_packet.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/HDMI_serializer_altlvds.sv}
vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL/src {C:/altera/Qdesigns/HDMI_PLL/src/packet_picker.sv}

vlog -sv -work work +incdir+C:/altera/Qdesigns/HDMI_PLL {C:/altera/Qdesigns/HDMI_PLL/HDMI_Encoder_tb.sv}


restart -force -nowave
# This line shows only the varible name instead of the full path and which module it was in
config wave -signalnamewidth 1

radix -unsigned
add wave *
add wave -position insertpoint  \
-divider "TMDS_CLOCK" \
-radix binary sim:/HDMI_test_tb/DUT/HDMI_PLL/clk_pixel_x5 \
-divider "HDMI TOP" \
-color #ffff00 \
-radix binary sim:/HDMI_test_tb/DUT/HDMI_PLL/clk_pixel  \
-color #00ff00 \
-radix hexadecimal sim:/HDMI_test_tb/DUT/rgb \
-radix unsigned sim:/HDMI_test_tb/DUT/cx \
sim:/HDMI_test_tb/DUT/cy \
sim:/HDMI_test_tb/DUT/screen_start_x \
sim:/HDMI_test_tb/DUT/screen_start_y \
sim:/HDMI_test_tb/DUT/frame_width \
sim:/HDMI_test_tb/DUT/frame_height \
sim:/HDMI_test_tb/DUT/screen_width \
sim:/HDMI_test_tb/DUT/screen_height 

add wave -position insertpoint  \
-color #00ffff \
 -divider "Audio Generator" \
-format logic \
-radix binary \
sim:/HDMI_test_tb/DUT/HDMI_PLL/clk_audio  \
-format analog-step -max 35000 -min -32000 -height 48 \
-radix decimal \
sim:/HDMI_test_tb/DUT/sine_1k \
-format logic -height 17 \
sim:/HDMI_test_tb/DUT/HDMI_PLL/audio_ena

add wave -position insertpoint  \
-color #00ff00 \
-divider "HDMI Core" \
-radix hexadecimal \
-expand sim:/HDMI_test_tb/DUT/hdmi/tmds \
sim:/HDMI_test_tb/DUT/hdmi/hsync \
sim:/HDMI_test_tb/DUT/hdmi/vsync \
sim:/HDMI_test_tb/DUT/hdmi/video_data_period \
sim:/HDMI_test_tb/DUT/hdmi/mode \
sim:/HDMI_test_tb/DUT/hdmi/true_hdmi_output/VIDEO_RATE

view structure
view signals
wave zoom range 0ns 1000ns
run -all
