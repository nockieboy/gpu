module data_mux (

	// general inputs
	input wire clk,
	input wire reset,
	
	// gpu inputs
	input wire rd_rdy,						// this should be HIGH for 1 clock once 'gpu_data_in[7:0]' contains valid data
	input wire gpu_data_in[7:0],
	
	// inputs Port A
	input wire wr_ena_a,
	input wire rd_req_a,
	input wire address_a[19:0],
	input wire data_in_a[7:0],
	
	
	// inputs Port B
	input wire wr_ena_b,
	input wire rd_req_b,
	input wire address_b[19:0],
	input wire data_in_b[7:0],
	
	// gpu outputs
	output reg gpu_rd_req,					// this will pulse high for 1 clock when a read request takes place
	output reg gpu_address[19:0],
	output reg gpu_data_out[7:0],
	
	// outputs Port A
	output reg gpu_rd_rdy_a,
	output reg data_out_a[7:0],
	
	// outputs Port B
	output reg gpu_rd_rdy_b,
	output reg data_out_b[7:0]

);


endmodule
