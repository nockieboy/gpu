module gpu_dual_port_ram_INTEL (

	// inputs
	input clk,
	input wren_a,
	input wren_b,
	input [19:0] addr_a,
	input [19:0] addr_b,
	input [15:0] data_in_a,
	input [15:0] data_in_b,
	input [1:0]  byteena_a,
	input [1:0]  byteena_b,

	// direct outputs
	output wire [15:0] data_out_a,
	output wire [15:0] data_out_b
);

// define the maximum address bit
parameter ADDR_SIZE = 14;
// define the memory size (number of words) - this allows RAM sizes other than multiples of 2
// but defaults to power-of-two sizing based on ADDR_SIZE if not otherwise specified
parameter NUM_WORDS = 2 ** ADDR_SIZE;
parameter MIF_FILE = "gpu_8Kx16_VGA.mif" ;

// ****************************************************************************************************************************
// Dual-port GPU RAM
// 2 read write ports, at 16 bits, with 'BYTE' enable so that 8 bit of a 16 bit word may be written at 1 time.
// ****************************************************************************************************************************

altsyncram	altsyncram_component (
				.wren_a (wren_a),
				.clock0 (clk),
				.wren_b (wren_b),
				.byteena_a (byteena_a),
				.byteena_b (byteena_b),
				.address_a (addr_a[ADDR_SIZE - 1:1]),
				.address_b (addr_b[ADDR_SIZE - 1:1]),
				.data_a (data_in_a),
				.data_b (data_in_b),
				.q_a (data_out_a),
				.q_b (data_out_b),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.eccstatus (),
				.rden_a (1'b1),
				.rden_b (1'b1));
	
defparam
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.byteena_reg_b = "CLOCK0",
		altsyncram_component.byte_size = 8,
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.indata_reg_b = "CLOCK0",
		altsyncram_component.init_file = MIF_FILE,
		altsyncram_component.intended_device_family = "Cyclone II",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = NUM_WORDS/2,
		altsyncram_component.numwords_b = NUM_WORDS/2,
		altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.outdata_reg_b = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.read_during_write_mode_port_a = "OLD_DATA",
		altsyncram_component.read_during_write_mode_port_b = "OLD_DATA",
		altsyncram_component.widthad_a = ADDR_SIZE-1,
		altsyncram_component.widthad_b = ADDR_SIZE-1,
		altsyncram_component.width_a = 16,
		altsyncram_component.width_b = 16,
		altsyncram_component.width_byteena_a = 2,
		altsyncram_component.width_byteena_b = 2,
		altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK0";
	
// ****************************************************************************************************************************

endmodule
