module Z80_bridge (

	// input
	input wire	reset,			// GPU reset signal
	input wire	GPU_CLK,			// GPU clock (125 MHz)
	input wire	Z80_CLK,			// Microcom clock signal (8 MHz)
	input wire	Z80_M1n,			// Z80 M1 - active LOW
	input wire	Z80_MREQn,		// Z80 MREQ - active LOW
	input wire	Z80_WRn,			// Z80 WR - active LOW
	input wire	Z80_RDn,			// Z80 RD - active LOW
	input wire	[21:0] Z80_addr,	// Microcom 22-bit address bus
	input wire	[7:0]	 Z80_wData,	// Z80 DATA bus to pass incoming data to GPU RAM
	input wire	[7:0]	 gpu_rData,
	input wire	gpu_rd_rdy,		// one-shot signal from mux that data is ready
	
	// output
	output reg	Z80_245data_dir,	// control level converter direction for data flow - HIGH = A -> B (toward FPGA)
	output reg	[7:0]  Z80_rData,	// Z80 DATA bus to return data from GPU RAM to Z80
	output reg	Z80_rData_ena,		// flag HIGH to write data back to Z80
	output reg	Z80_245_oe,			// OE for 245 level translator *** ACTIVE LOW ***
	output reg	gpu_wr_ena,			// flag HIGH for 1 clock when writing to GPU RAM
	output reg	gpu_rd_req,			// flag HIGH for 1 clock when reading from GPU RAM
	output reg	[19:0] gpu_addr,	// connect to Z80_addr in vid_osd_generator to address GPU RAM
	output reg	[7:0]  gpu_wdata	// 8-bit data bus to GPU RAM in vid_osd_generator

);

// TODO:
//
// 1) Prevent reads to GPU RAM above top of GPU RAM
// 2) Respond with appropriate data to any requests from Microcom ROM identification routines
//

parameter MEMORY_RANGE = 3'b010;	// Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the Microcom)
parameter DELAY_CYCLES = 2;		// number of cycles to delay write for 245

wire mem_window, Z80_mreq, Z80_write, Z80_read, Z80_nRead, Write_GPU_RAM, GPU_data_oe;
wire Read_GPU_RAM_BEGIN, Read_GPU_RAM_END;

reg last_Z80_WR	= 1'b0;  // keep these low on power-up, otherwise a read or write pulse may be triggered
reg last_Z80_RD	= 1'b0;
reg Z80_clk_delay;
reg [9:0] Z80_write_sequencer;
//reg [18:0] rd_addr;

//assign mem_valid  = (rd_addr[15] == 1'b0);					// HIGH if address is inside GPU RAM bounds (GPU RAM may not fill the 512KB host memory window, so this flag determines if the address is within GPU RAM bounds)
assign mem_window	= (Z80_addr[21:19] == MEMORY_RANGE);	// Define an active memory range
assign Z80_mreq	= 	~Z80_MREQn && Z80_M1n;					// Define a bus memory access state
assign Z80_write	= ~Z80_WRn && last_Z80_WR;					// Isolate a single write transaction
assign Z80_read	= 	~Z80_RDn && last_Z80_RD;				// Isolate a single read transaction
assign Z80_nRead	= 	Z80_RDn && ~last_Z80_RD;				// Isolate end of a read transaction

assign Write_GPU_RAM			= mem_window && Z80_mreq && Z80_write;	// Define a GPU Write action - only write to address within GPU RAM bounds
assign Read_GPU_RAM_BEGIN	= mem_window && Z80_mreq && ~Z80_RDn && Z80_CLK && ~Z80_clk_delay && ~Z80_rData_ena;   // Define the beginning of a Z80 read request of GPU Ram.
assign Read_GPU_RAM_END		= Z80_RDn && ~last_Z80_RD;					// Define the time to end a GPU ram read
assign GPU_data_oe			= mem_window && Z80_mreq && ~Z80_RDn;	// Define the time the GPU ouputs data onto the Z80 data bus

// **********************************************************************************************************

always @ (posedge GPU_CLK) begin

	Z80_write_sequencer[9:0] <= { Z80_write_sequencer[8:0], Write_GPU_RAM };

	if ( Z80_write_sequencer[0] )                 Z80_245data_dir  <= 1'b1;				// set 245 dir toward FPGA
	if ( Z80_write_sequencer[0] )                 Z80_rData_ena    <= 1'b0;				// set FPGA pins to input (should be by default)
	if ( Z80_write_sequencer[0] )                 Z80_245_oe       <= 1'b0;				// enable 245 output (WAS 1 - moved forward to step 0)

	if ( Z80_write_sequencer[DELAY_CYCLES + 1] )  gpu_addr         <= Z80_addr[18:0];// latch address bus onto GPU address bus
	if ( Z80_write_sequencer[DELAY_CYCLES + 1] )  gpu_wdata        <= Z80_wData;		// latch data bus onto GPU data bus
	if ( Z80_write_sequencer[DELAY_CYCLES + 1] )  gpu_wr_ena       <= 1'b1;				// turn on FPGA RAM we

	if ( Z80_write_sequencer[DELAY_CYCLES + 3] )  gpu_wr_ena       <= 1'b0;				// turn off FPGA RAM we (WAS STEP +2, now STEP +3 for additional WR)
	if ( Z80_write_sequencer[DELAY_CYCLES + 3] )  Z80_245_oe       <= 1'b1;				// disable 245 output (WAS STEP +2, now STEP +3 for additional WR)

	if ( Read_GPU_RAM_BEGIN ) begin
		
		gpu_addr				<= Z80_addr[18:0];// pass address to GPU RAM (cropped to 512KB range as that's all we're interested in)
		gpu_rd_req			<= 1'b1;				// flag a read request to the mux which is one-shotted in the mux
		Z80_245data_dir	<= 1'b0;				// set 245 direction (TO Z80)
		Z80_245_oe			<= 1'b0;				// enable 245 output
		
	end else begin
		
		gpu_rd_req			<= 1'b0;				// end GPU read req after 1 pulse
		
	end

	if ( gpu_rd_rdy )	begin // gpu_rd_rdy is a one-shot from the mux, reset after one clock
		
		Z80_rData_ena	<= 1'b1;					// set bidir pins to output
		
		//if (mem_valid) begin
			
			Z80_rData[7:0]	<= gpu_rData[7:0];// Latch the GPU RAM read into the output register for the Z80
			
		//end else begin
			
		//	Z80_rData[7:0] <= 8'b11111111;	// return $FF if addressed byte is outside the GPU's upper RAM limit
			
		//end
		
	end
	
	if ( Read_GPU_RAM_END ) begin
		// data is being output to Z80, which has signalled end of read transaction
		Z80_245_oe		<= 1'b1;					// disable 245 output
		Z80_rData_ena	<= 1'b0;					// re-set bidir pins to input
	end
	
	last_Z80_WR		<= Z80_WRn;
	last_Z80_RD		<= Z80_RDn;
	Z80_clk_delay	<= Z80_CLK;					// find the rising clock edge

end

// **********************************************************************************************************

endmodule
