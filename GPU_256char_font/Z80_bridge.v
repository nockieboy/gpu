module Z80_bridge (

	// input
	input wire	reset,				// GPU reset signal
	input wire	GPU_CLK,				// GPU clock (125 MHz)
	input wire	Z80_CLK,				// Microcom clock signal (8 MHz)
	input wire	Z80_M1n,				// Z80 M1 - active LOW
	input wire	Z80_MREQn,			// Z80 MREQ - active LOW
	input wire	Z80_WRn,				// Z80 WR - active LOW
	input wire	Z80_RDn,				// Z80 RD - active LOW
	input wire	[21:0] Z80_addr,	// Microcom 22-bit address bus
	input wire	[7:0]	 Z80_wData,	// Z80 DATA bus to pass incoming data to GPU RAM
	input wire	[7:0]	 gpu_rData,
	input wire	gpu_rd_rdy,			// one-shot signal from mux that data is ready
	
	// output
	output reg	Z80_245data_dir,	// control level converter direction for data flow - HIGH = A -> B (toward FPGA)
	output reg	[7:0]  Z80_rData,	// Z80 DATA bus to return data from GPU RAM to Z80
	output reg	Z80_rData_ena,		// flag HIGH to write data back to Z80
	output reg	Z80_245_oe,			// OE for 245 level translator *** ACTIVE LOW ***
	output reg	gpu_wr_ena,			// flag HIGH for 1 clock when writing to GPU RAM
	output reg	gpu_rd_req,			// flag HIGH for 1 clock when reading from GPU RAM
	output reg	[19:0] gpu_addr,	// connect to Z80_addr in vid_osd_generator to address GPU RAM
	output reg	[7:0]  gpu_wdata,	// 8-bit data bus to GPU RAM in vid_osd_generator

   input wire  sel_pclk, 			// make HIGH to trigger the Z80 bus on the positive edge of Z80_CLK
   input wire  sel_nclk   			// make LOW  to trigger the Z80 bus on the negative edge of Z80_CLK
);

// TODO:
//
// 1) Respond with appropriate data to any requests from Microcom ROM identification routines
//

parameter MEMORY_RANGE  = 3'b010;// Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the Microcom)
parameter MEM_SIZE_BITS = 15;		//

wire Z80_mreq, Z80_write, Z80_read, Write_GPU_RAM;
wire Read_GPU_RAM;
wire Z80_clk_pos,Z80_clk_neg,Z80_clk_trig;

reg Z80_clk_delay, last_Z80_WR, last_Z80_RD, mem_valid_range, mem_window, last_Z80_WR2, last_Z80_WR3, last_Z80_RD2, last_Z80_RD3 ;


assign Z80_clk_pos   = ~Z80_clk_delay &&  Z80_CLK;
assign Z80_clk_neg   =  Z80_clk_delay && ~Z80_CLK;
assign Z80_clk_trig  = (Z80_clk_pos && sel_pclk) || (Z80_clk_neg && ~sel_nclk);

assign Z80_mreq	    = ~Z80_MREQn && Z80_M1n;	// Define a bus memory access state
assign Z80_write		 = ~Z80_WRn ;					// write transaction

assign Z80_read	    = ~Z80_RDn;					// read transaction

assign Write_GPU_RAM	 =  mem_window && Z80_mreq && Z80_write && mem_valid_range;	// Define a GPU Write action - only write to address within GPU RAM bounds
assign Read_GPU_RAM   =  mem_window && Z80_mreq && Z80_read  && mem_valid_range; // Define the beginning of a Z80 read request of GPU Ram.

// **********************************************************************************************************

always @ (posedge GPU_CLK) begin

	gpu_addr         <=  Z80_addr[18:0];                        // latch address bus onto GPU address bus
	mem_valid_range  <= (Z80_addr[18:0]  <  2**MEM_SIZE_BITS);	// Define GPU addressable memory space
	mem_window		  <= (Z80_addr[21:19] == MEMORY_RANGE);	   // Define an active memory range

	if ( Write_GPU_RAM ) begin
		Z80_245data_dir  <= 1'b1;			// set 245 dir toward FPGA
		Z80_rData_ena    <= 1'b0;			// set FPGA pins to input (should be by default)
		Z80_245_oe       <= 1'b0;			// enable 245 output (WAS 1 - moved forward to step 0)
		gpu_wdata        <= Z80_wData;	// latch data bus onto GPU data bus
	end

	if ( Read_GPU_RAM ) begin
		Z80_245data_dir	<= 1'b0;			// set 245 direction (TO Z80)
		Z80_245_oe			<= 1'b0;			// enable 245 output
		Z80_rData_ena	   <= 1'b1;			// set bidir pins to output
	end else begin
		Z80_245data_dir   <= 1'b1;			// set 245 dir toward FPGA
		Z80_rData_ena		<= 1'b0;			// re-set bidir pins to input
	end

	if ( gpu_rd_rdy ) begin
		if (mem_valid_range) Z80_rData[7:0]	<= gpu_rData[7:0];  // Latch the GPU RAM read into the output register for the Z80
		else Z80_rData[7:0]  					<= 8'b11111111;	  // return $FF if addressed byte is outside the GPU's upper RAM limit
	end
	
	Z80_clk_delay	<= Z80_CLK;				// find the rising clock edge

	last_Z80_WR		<= Write_GPU_RAM;
	last_Z80_WR2	<= last_Z80_WR;
	last_Z80_WR3	<= last_Z80_WR2;

	last_Z80_RD		<= Read_GPU_RAM;
	last_Z80_RD2	<= last_Z80_RD;
	last_Z80_RD3	<= last_Z80_RD2;

	gpu_wr_ena     <= Write_GPU_RAM && ~last_Z80_WR2 ; // Pulse the GPU ram's write enable only once after the Z80 write cycle has completed
	gpu_rd_req     <= Read_GPU_RAM  && ~last_Z80_RD2 ; // Pulse the read request only once at the beginning of a read cycle.
	
end

// **********************************************************************************************************

endmodule
