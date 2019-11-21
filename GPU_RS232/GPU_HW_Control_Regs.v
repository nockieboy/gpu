module GPU_HW_Control_Regs (
	
	input clk,
	
	// inputs
	input reg reset,
	input reg [19:0] wr_addr,
	input reg [7:0] wr_data,
	input reg wr_en,
	
	// output
	output reg [8*(HW_REGS_SIZE - 1):0] GPU_HW_Control_regs
	
);

parameter HW_REGS_SIZE = 256;
parameter [HW_REGS_SIZE - 1:0] RESET_BYTES;
parameter WRITE_BASE_ADDRESS = 16384 - HW_REGS_SIZE;

// handle data writes
always @(posedge clk)
begin

	if (wr_en && wr_data == wr_addr[19:8]) begin
	
		// valid address and data, write value to registers
		
	
	end // if wr_en & addr valid
	else if (wr_en && wr_addr[19:8] > 256) begin
	
		// ignore 9th bit of address [8]
		
	
	end // if wr_en & upper addr > 256

end // posedge clk

// handle reset signals
always @(posedge reset)
begin

end // posedge reset
