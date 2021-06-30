module GPU_HW_Control_Regs (

		input rst,
		input clk,
		input we,
		input [19:0] addr_in,
		input [7:0] data_in,
		
		output reg  [7:0] GPU_HW_Control_regs[0:(2**HW_REGS_SIZE-1)],
		output reg  [7:0] data_out
);
 
	parameter HW_REGS_SIZE = 8;
	parameter int BASE_WRITE_ADDRESS = 20'h0;
	
	parameter int RST_VALUES0[32] = '{0,16,0,16,2,143,1,239,0,0,0,0,0,0,0,0,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16};
	parameter int RST_VALUES1[32] = '{0,240,0,183,0,140,0,134,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16};
	parameter int RST_VALUES2[32] = '{0,16,0,16,0,16,0,16,0,16,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	parameter int RST_VALUES3[32] = '{128,16,0,0,18,0,0,80,2,127,1,223,0,240,0,0,72,0,15,0,2,0,0,0,0,0,0,0,0,1,0,0};
	parameter int RST_VALUES4[32] = '{132,16,0,0,27,96,0,80,1,63,0,239,1,241,0,0,76,0,15,0,2,0,0,0,0,0,0,0,0,1,0,0};
	parameter int RST_VALUES5[32] = '{26,16,0,0,51,0,0,96,0,191,0,119,0,0,0,0,26,112,0,0,51,0,0,96,0,191,0,119,1,1,0,0};
	
	wire enable,valid_wr;
	
	assign enable      = ( addr_in[19:HW_REGS_SIZE] == BASE_WRITE_ADDRESS[19:HW_REGS_SIZE] );	// upper x-bits of addr_in should equal BASE_WRITE_ADDRESS for a successful read or write
	assign valid_wr    = we && enable;
	
	integer i,x;
 
	always @ (posedge clk) begin
		
		if (rst) begin
			
			// reset key registers to initial values
			x=0;
			for (i = 0; i < 32; i = i + 1) begin
				GPU_HW_Control_regs[i+x*32] <= RST_VALUES0[i][7:0];
			end
			x=1;
			for (i = 0; i < 32; i = i + 1) begin
				GPU_HW_Control_regs[i+x*32] <= RST_VALUES1[i][7:0];
			end
			x=2;
			for (i = 0; i < 32; i = i + 1) begin
				GPU_HW_Control_regs[i+x*32] <= RST_VALUES2[i][7:0];
			end
			x=3;
			for (i = 0; i < 32; i = i + 1) begin
				GPU_HW_Control_regs[i+x*32] <= RST_VALUES3[i][7:0];
			end
			x=4;
			for (i = 0; i < 32; i = i + 1) begin
				GPU_HW_Control_regs[i+x*32] <= RST_VALUES4[i][7:0];
			end
			x=5;
			for (i = 0; i < 32; i = i + 1) begin
				GPU_HW_Control_regs[i+x*32] <= RST_VALUES5[i][7:0];
			end
			
			// reset remaining registers to zero
			for (i = 32*6; i < 2**HW_REGS_SIZE; i = i + 1) begin
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
		
		if (enable) begin
		
			data_out <= GPU_HW_Control_regs[addr_in[HW_REGS_SIZE-1:0]];
			
		end else data_out <= 0;
		
	end

endmodule
