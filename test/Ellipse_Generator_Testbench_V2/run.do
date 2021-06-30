vlog -sv -work work ellipse_generator.sv
vlog -sv -work work ellipse_generator_tb.sv

restart -force -nowave
# This line shows only the varible name instead of the full path and which module it was in
config wave -signalnamewidth 1

add wave -position insertpoint  \
-divider "RST/ENA/RUN" \
-radix binary   sim:/ellipse_generator_tb/reset \
-radix binary   sim:/ellipse_generator_tb/enable \
-radix binary   sim:/ellipse_generator_tb/ena_pause \
-radix binary   sim:/ellipse_generator_tb/run \
-divider "Fill/Quad/Coord" \
-radix binary   sim:/ellipse_generator_tb/ellipse_filled \
-radix unsigned sim:/ellipse_generator_tb/quadrant \
-radix decimal  sim:/ellipse_generator_tb/Xc \
-radix decimal  sim:/ellipse_generator_tb/Yc \
-radix decimal  sim:/ellipse_generator_tb/Xr \
-radix decimal  sim:/ellipse_generator_tb/Yr \
-divider "CLOCK" \
-radix binary   sim:/ellipse_generator_tb/clk \
-divider "OUTPUT" \
-radix binary   sim:/ellipse_generator_tb/pixel_data_rdy \
-radix decimal  sim:/ellipse_generator_tb/X_coord \
-radix decimal  sim:/ellipse_generator_tb/Y_coord \
-radix binary   sim:/ellipse_generator_tb/busy \
-radix binary   sim:/ellipse_generator_tb/ellipse_complete 


add wave -position insertpoint  \
-divider "CORE REGS" \
-radix unsigned \
sim:/ellipse_generator_tb/DUT/filled \
sim:/ellipse_generator_tb/DUT/quadrant_latch \
-radix decimal \
sim:/ellipse_generator_tb/DUT/xcr \
sim:/ellipse_generator_tb/DUT/ycr \
-radix unsigned \
sim:/ellipse_generator_tb/DUT/sub_function \
sim:/ellipse_generator_tb/DUT/inv \
sim:/ellipse_generator_tb/DUT/draw_flat \
-radix decimal \
sim:/ellipse_generator_tb/DUT/x \
sim:/ellipse_generator_tb/DUT/y \
-radix unsigned \
sim:/ellipse_generator_tb/DUT/xrr \
sim:/ellipse_generator_tb/DUT/yrr \
-radix decimal \
sim:/ellipse_generator_tb/DUT/p \
sim:/ellipse_generator_tb/DUT/px \
sim:/ellipse_generator_tb/DUT/py \
sim:/ellipse_generator_tb/DUT/rx2 \
sim:/ellipse_generator_tb/DUT/ry2 \
-radix unsigned \
sim:/ellipse_generator_tb/DUT/pixel_data_rdy_int \
sim:/ellipse_generator_tb/DUT/busy_int \
sim:/ellipse_generator_tb/DUT/ena_process \
sim:/ellipse_generator_tb/DUT/freeze \
-divider "Consolidated Multiplier" \
sim:/ellipse_generator_tb/DUT/alu_mult_a \
sim:/ellipse_generator_tb/DUT/alu_mult_b \
sim:/ellipse_generator_tb/DUT/alu_mult_y 



view structure
view signals

run -all

wave cursor active
wave refresh
wave zoom range 0ns 250ns
view signals
