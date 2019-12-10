module dual_port_palette_ram_INTEL (
	
	// inputs
	input	clock_a,
	input	clock_b,
	input	[7:0]  pixel_addr_in,	// address_a
	input	[8:0]  host_address,
	input	[15:0] data_a,
	input	[7:0]  host_data_in,
	input	enable_a,
	input	host_enable,
	input	wren_a,
	input	host_wren,
	input rden_a,
	input rden_b,
	input sclr_n_rd_b,
	
	// outputs
	output [15:0] pixel_out,		// data_out_a
	output reg [7:0]  host_data_out	
	
);

parameter INIT_PALETTE = "palette_565.mif";

wire [7:0] pre_data_out_b;

reg aclr_delay;

// ****************************************************************************************************************************
// Dual-port palette RAM
// ****************************************************************************************************************************
altsyncram	altsyncram_component (
	.clocken0 (enable_a),
	.clocken1 (host_enable),
	.wren_a (wren_a),
	.clock0 (clock_a),
	.wren_b (host_wren),
	.clock1 (clock_b),
	.address_a (pixel_addr_in),
	.address_b (host_address),
	.data_a (data_a),
	.data_b (host_data_in),
	.q_a (pixel_out),
	.q_b (pre_data_out_b),
	.aclr0 (1'b0),
	.aclr1 (1'b0),
	.addressstall_a (1'b0),
	.addressstall_b (1'b0),
	.byteena_a (1'b1),
	.byteena_b (1'b1),
	.clocken2 (1'b1),
	.clocken3 (1'b1),
	.eccstatus (1'b0),
	.rden_a (rden_a),
	.rden_b (rden_b)
);
	
defparam
	altsyncram_component.address_reg_b = "CLOCK1",
	altsyncram_component.clock_enable_input_a = "NORMAL",
	altsyncram_component.clock_enable_input_b = "NORMAL",
	altsyncram_component.clock_enable_output_a = "NORMAL",
	altsyncram_component.clock_enable_output_b = "NORMAL",
	altsyncram_component.indata_reg_b = "CLOCK1",
	altsyncram_component.init_file = INIT_PALETTE,
	altsyncram_component.init_file_layout = "PORT_A",
	altsyncram_component.intended_device_family = "Cyclone IV",
	altsyncram_component.lpm_type = "altsyncram",
	altsyncram_component.numwords_a = 256,
	altsyncram_component.numwords_b = 512,
	altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
	altsyncram_component.outdata_aclr_a = "NONE",
	altsyncram_component.outdata_aclr_b = "NONE",
	altsyncram_component.outdata_reg_a = "CLOCK0",
	altsyncram_component.outdata_reg_b = "UNREGISTERED",
	altsyncram_component.power_up_uninitialized = "FALSE",
	altsyncram_component.read_during_write_mode_port_a = "OLD_DATA",
	altsyncram_component.read_during_write_mode_port_b = "OLD_DATA",
	altsyncram_component.widthad_a = 8,
	altsyncram_component.widthad_b = 9,
	altsyncram_component.width_a = 16,
	altsyncram_component.width_b = 8,
	altsyncram_component.width_byteena_a = 1,
	altsyncram_component.width_byteena_b = 1,
	altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";
	
// ****************************************************************************************************************************

always @(posedge clock_b) begin

	aclr_delay	<= rden_b;
	if (aclr_delay)
		host_data_out <= pre_data_out_b;
	else
		host_data_out <= 1'b0;

end

endmodule
