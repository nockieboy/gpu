module gpu_dual_port_ram_INTEL (

	// inputs
	input clk,
	input clk_b,
	input wr_en_b,
	input [3:0] pc_ena_in,
	input [19:0] addr_a,
	input [19:0] addr_b,
	input [7:0]  data_in_b,
	input [31:0] cmd_in,		// ****** changed to 32 bit width
	
	// registered outputs
	output reg [19:0] addr_out_a,
	output reg [3:0]  pc_ena_out,
	output reg [31:0] cmd_out,		// ****** changed to 32 bit width
	
	// direct outputs
	output wire [15:0] data_out_a,		// ****** changed to 16 bit data width
	output wire [7:0] data_out_b
	
);

// define the maximum address bit
parameter ADDR_SIZE = 14;

// define the memory size (number of words) - this allows RAM sizes other than multiples of 2
// but defaults to power-of-two sizing based on ADDR_SIZE if not otherwise specified
parameter NUM_WORDS = 2 ** ADDR_SIZE;

// define delay pipe registers
reg [19:0] rd_addr_pipe_a;
reg [31:0] cmd_pipe;		// ****** changed to 32 bit width
reg [3:0]  pc_ena_pipe;

// ********************************************************************************
// * NEW SECTION to reverse byte order of read-only port if addressed LSB is 0
// ********************************************************************************

wire [15:0] ram_out_a;

assign data_out_a[7:0]	= (addr_out_a[0] == 1'b0) ? ram_out_a[7:0]  : ram_out_a[15:8];
assign data_out_a[15:8]	= (addr_out_a[0] == 1'b0) ? ram_out_a[15:8] : ram_out_a[7:0];

// ********************************************************************************

// ****************************************************************************************************************************
// Dual-port GPU RAM
// 
// Port A 				- read only by GPU - 16 bit / 2 bytes wide
// Port B 				- read/writeable by host system - 8 bit / 1 byte wide
// Address buses 		- ADDR_SIZE wide (14 bits default)
// Memory word size 	- NUM_WORDS (16384 bytes default)
// ****************************************************************************************************************************
altsyncram	altsyncram_component (
	.clock0 (clk),
	.wren_a (1'b0),
	.address_b (addr_b[ADDR_SIZE - 1:0]),
	.clock1 (clk_b),
	.data_b (data_in_b),
	.wren_b (wr_en_b),
	.address_a (addr_a[ADDR_SIZE - 1:1]),	// ****** changed LSB from 0 to 1
	.data_a (16'b0000000000000000),			// ****** changed to 16 bit data width
	.q_a (ram_out_a),								// ****** changed from data_out_a to ram_out_a
	.q_b (data_out_b),
	.aclr0 (1'b0),
	.aclr1 (1'b0),
	.addressstall_a (1'b0),
	.addressstall_b (1'b0),
	.byteena_a (1'b1),
	.byteena_b (1'b1),
	.clocken0 (1'b1),
	.clocken1 (1'b1),
	.clocken2 (1'b1),
	.clocken3 (1'b1),
	.eccstatus (),
	.rden_a (1'b1),
	.rden_b (1'b1)
);
	
defparam
	altsyncram_component.address_reg_b = "CLOCK1",
	altsyncram_component.clock_enable_input_a = "BYPASS",
	altsyncram_component.clock_enable_input_b = "BYPASS",
	altsyncram_component.clock_enable_output_a = "BYPASS",
	altsyncram_component.clock_enable_output_b = "BYPASS",
	altsyncram_component.indata_reg_b = "CLOCK1",
	altsyncram_component.intended_device_family = "Cyclone II",
	altsyncram_component.lpm_type = "altsyncram",
	altsyncram_component.numwords_a = NUM_WORDS / 2,   // ****** changed to NUM_WORDS / 2
	altsyncram_component.numwords_b = NUM_WORDS,
	altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
	altsyncram_component.outdata_aclr_a = "NONE",
	altsyncram_component.outdata_aclr_b = "NONE",
	altsyncram_component.outdata_reg_a = "CLOCK0",
	altsyncram_component.outdata_reg_b = "CLOCK1",
	altsyncram_component.power_up_uninitialized = "FALSE",
	altsyncram_component.read_during_write_mode_port_a = "OLD_DATA",
	altsyncram_component.read_during_write_mode_port_b = "OLD_DATA",
	altsyncram_component.widthad_a = ADDR_SIZE - 1,  // ****** changed to ADDR_SIZE - 1
	altsyncram_component.widthad_b = ADDR_SIZE,
	altsyncram_component.width_a = 16,				// ****** changed from 8 to 16
	altsyncram_component.width_b = 8,
	altsyncram_component.width_byteena_a = 1,
	altsyncram_component.width_byteena_b = 1,
	altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1",
	altsyncram_component.init_file_layout = "PORT_B",
	altsyncram_component.init_file = "gpu_16K_VGA.mif";
	
// ****************************************************************************************************************************

always @(posedge clk) begin
	
	// **************************************************************************************************************************
	// *** Create a serial pipe where the PIPE_DELAY parameter selects the pixel count delay for the xxx_in to the xxx_out ports
	// **************************************************************************************************************************
	rd_addr_pipe_a <= addr_a;
	addr_out_a <= rd_addr_pipe_a;
	
	cmd_pipe <= cmd_in;
	cmd_out <= cmd_pipe;
	
	pc_ena_pipe <= pc_ena_in;
	pc_ena_out <= pc_ena_pipe;
	// **************************************************************************************************************************
	
end

endmodule
