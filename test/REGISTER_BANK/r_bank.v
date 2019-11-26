module GPU_HW_Control_Regs (

		input rst,
		input clk,
		input we,
		input [19:0] addr_in,
		input [7:0] data_in,
		
		output reg  [7:0] GPU_HW_Control_regs[0:(2**HW_REGS_SIZE-1)]
		
);
 
	parameter HW_REGS_SIZE = 8;
	parameter int BASE_WRITE_ADDRESS = 20'h0;
	
	parameter int RST_VALUES [32] = '{
	8'h01,
	8'h02,
	8'h03,
	8'h04,
	8'h05,
	8'h06,
	8'h07,
	8'h08,
	8'h09,
	8'h0A,
	8'h0B,
	8'h0C,
	8'h0D,
	8'h0E,
	8'h0F,
	8'h10,
	8'h11,
	8'h12,
	8'h13,
	8'h14,
	8'h15,
	8'h16,
	8'h17,
	8'h18,
	8'h19,
	8'h1A,
	8'h1B,
	8'h1C, 
	8'h1D,
	8'h1E,
	8'h1F,
	8'h20 };
	
	wire valid_wr;
	
	assign valid_wr = we && ( addr_in[19:HW_REGS_SIZE] == BASE_WRITE_ADDRESS[19:HW_REGS_SIZE] );		// upper 8-bits of addr_in should equal data_in for a successful write
	
	integer i;
 
	always @ (posedge clk) begin
		
		if (rst) begin
			
			// reset key registers to initial values		
			for (i = 0; i < 32; i = i + 1) begin
				GPU_HW_Control_regs[i] <= RST_VALUES[i][7:0];
			end
			
			// reset remaining registers to zero
			for (i = 32; i < 2**HW_REGS_SIZE; i = i + 1) begin
				GPU_HW_Control_regs[i] <= 8'h0;
			end
			
		end
		else
		begin
			
			if (valid_wr) begin
				
				// apply written value to addressed register
				GPU_HW_Control_regs[addr_in[HW_REGS_SIZE-1:0]] <= data_in;
				
			end
			
		end
	end

endmodule
