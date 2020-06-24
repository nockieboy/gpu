module sound (

	// inputs
	input wire clk,
	input wire enable,
	
	// outputs
	output reg speaker
	
);

reg [30:0] counter;
reg last_enable = 1'b0;

wire enabled;

assign enabled = enable & ~last_enable;

always @(posedge clk) begin

	if (enabled) begin
	
		counter <= 30'b0;
	
	end

	if (counter[25] == 1'b0) begin
	
		counter <= counter + 1'b1;
		speaker <= counter[16];
		
	end
	
	last_enable <= enable;
 
end

endmodule
