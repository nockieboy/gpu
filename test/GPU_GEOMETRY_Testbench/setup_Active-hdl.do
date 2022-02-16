vlib work
vmap work work
setactivelib work
vlog -sv2k12 -dbg -work work {FIFO_2word_FWFT.sv}
vlog -sv2k12 -dbg -work work {BrianHG_DDR3_FIFOs.sv}
vlog -sv2k12 -dbg -work work {line_generator.sv}
vlog -sv2k12 -dbg -work work {ellipse_generator.sv}
vlog -sv2k12 -dbg -work work {geometry_xy_plotter.sv}
vlog -sv2k12 -dbg -work work {pixel_address_generator.sv}
vlog -sv2k12 -dbg -work work {geo_pixel_writer.sv}
vlog -sv2k12 -dbg -work work {GPU_GEO_tb.sv}
vsim -O5 +access +r GPU_GEO_tb

restart

# This line shows only the varible name instead of the full path and which module it was in
# config wave -signalnamewidth 1

#add wave -position insertpoint -unsigned /GPU_GEO_tb/*

add wave -divider "Script File"
add wave -ascii       /GPU_GEO_tb/TB_COMMAND_SCRIPT_FILE
add wave -divider "GPU_GEO Test Bench"

add wave -decimal     /GPU_GEO_tb/v_cnt
add wave -hexadecimal /GPU_GEO_tb/hse
add wave -hexadecimal /GPU_GEO_tb/vse
add wave -hexadecimal /GPU_GEO_tb/reset
add wave -hexadecimal /GPU_GEO_tb/busy_system 
add wave -hexadecimal /GPU_GEO_tb/GEOFF_busy
add wave -decimal     /GPU_GEO_tb/Script_LINE
add wave -ascii       /GPU_GEO_tb/Script_CMD
add wave -hexadecimal /GPU_GEO_tb/TB_cmd_ena
add wave -hexadecimal /GPU_GEO_tb/TB_cmd_in
add wave -hexadecimal /GPU_GEO_tb/clk

add wave -divider "DUT_GEOFF internal"

add wave -decimal     /GPU_GEO_tb/DUT_GEOFF/x
add wave -decimal     /GPU_GEO_tb/DUT_GEOFF/y
add wave -decimal     /GPU_GEO_tb/DUT_GEOFF/max_x
add wave -decimal     /GPU_GEO_tb/DUT_GEOFF/max_y

add wave -divider "DUT_GEOFF XY plotter"

add wave -hexadecimal /GPU_GEO_tb/DUT_GEOFF/plot_pixel_ena
add wave -decimal     /GPU_GEO_tb/DUT_GEOFF/plot_pixel_xy
add wave -decimal     /GPU_GEO_tb/DUT_GEOFF/plot_pixel_col

add wave -divider "DUT_GEOFF XY blitter"

add wave -decimal     /GPU_GEO_tb/DUT_GEOFF/p_blit_mask_col
add wave -binary      /GPU_GEO_tb/DUT_GEOFF/p_blit_features

add wave -divider "DUT_GEOFF output"

add wave -hexadecimal /GPU_GEO_tb/GEOFF_draw_cmd_rdy
add wave -hexadecimal /GPU_GEO_tb/GEOFF_draw_cmd
add wave -hexadecimal /GPU_GEO_tb/GEOFF_cmd_cmd
add wave -decimal     /GPU_GEO_tb/GEOFF_cmd_color
add wave -decimal     /GPU_GEO_tb/GEOFF_cmd_y
add wave -decimal     /GPU_GEO_tb/GEOFF_cmd_x 

add wave -divider "DUT_PAGET internal"

add wave -decimal     /GPU_GEO_tb/DUT_PAGET/dest_bits_per_pixel
add wave -decimal     /GPU_GEO_tb/DUT_PAGET/dest_rast_width
add wave -hexadecimal /GPU_GEO_tb/DUT_PAGET/dest_base_address
add wave -hexadecimal /GPU_GEO_tb/DUT_PAGET/dest_address
add wave -decimal     /GPU_GEO_tb/DUT_PAGET/srce_bits_per_pixel
add wave -decimal     /GPU_GEO_tb/DUT_PAGET/srce_rast_width
add wave -hexadecimal /GPU_GEO_tb/DUT_PAGET/srce_base_address
add wave -hexadecimal /GPU_GEO_tb/DUT_PAGET/srce_address

add wave -divider "DUT_PAGET output"

add wave -hexadecimal /GPU_GEO_tb/PAGET_cmd_rdy
add wave -hexadecimal /GPU_GEO_tb/PAGET_cmd_cmd
add wave -decimal     /GPU_GEO_tb/PAGET_cmd_color
add wave -decimal     /GPU_GEO_tb/PAGET_cmd_depth
add wave -hexadecimal /GPU_GEO_tb/PAGET_cmd_bit
add wave -hexadecimal /GPU_GEO_tb/PAGET_cmd_addr 

add wave -divider "DUT_PIXIE internal"

add wave -hexadecimal /GPU_GEO_tb/ENA_PIXIE
add wave -hexadecimal /GPU_GEO_tb/clk

add wave -divider "DUT_PIXIE output"

add wave -hexadecimal /GPU_GEO_tb/PIXIE_rd_req_a
add wave -hexadecimal /GPU_GEO_tb/PIXIE_rd_req_b
add wave -hexadecimal /GPU_GEO_tb/PIXIE_wr_ena
add wave -hexadecimal /GPU_GEO_tb/PIXIE_ram_addr
add wave -hexadecimal /GPU_GEO_tb/PIXIE_ram_wr_data
add wave -hexadecimal /GPU_GEO_tb/RAM_data_rdy_a
add wave -hexadecimal /GPU_GEO_tb/RAM_data_rdy_b
add wave -hexadecimal /GPU_GEO_tb/RAM_data_read

add wave -divider "DUT_PIXIE flags"

add wave -hexadecimal /GPU_GEO_tb/PIXIE_busy
add wave -hexadecimal /GPU_GEO_tb/PIXIE_col_rd_rst
add wave -hexadecimal /GPU_GEO_tb/PIXIE_col_wr_rst
add wave -hexadecimal /GPU_GEO_tb/PIXIE_col_rd
add wave -hexadecimal /GPU_GEO_tb/PIXIE_col_wr 

run
