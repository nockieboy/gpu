/*
 * Flag_CrossDoman Module
 *
 * Taken from www.fpga4fun.com/CrossClockDomain2.html
 *
 * Passes a flag (a single-clock cycle pulse) across two clock domains
 *
 */

module Flag_CrossDomain(

	// inputs
   input clkA,
   input FlagIn_clkA,	// this is a one-clock pulse from the clkA domain
   input clkB,
	
	// outputs
   output FlagOut_clkB	// from which we generate a one-clock pulse in clkB domain
	
);

reg FlagToggle_clkA;
reg [2:0] SyncA_clkB;

assign FlagOut_clkB = (SyncA_clkB[2] ^ SyncA_clkB[1]);  // and create the clkB flag

always @(posedge clkA) begin

	FlagToggle_clkA <= FlagToggle_clkA ^ FlagIn_clkA;  // when flag is asserted, this signal toggles (clkA domain)
	
end

always @(posedge clkB) begin

	SyncA_clkB <= {SyncA_clkB[1:0], FlagToggle_clkA};  // now we cross the clock domains
	
end

endmodule
