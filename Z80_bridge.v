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
	//output wire [7:0]  	h_rd_data,	// Z80 DATA bus to return data from GPU RAM to Z80
	//output reg            h_rd_req,	//
	output reg	gpu_wr_ena,					// flag HIGH when writing to GPU RAM
	output reg	Z80_245data_dir,			// control level converter direction for data flow - HIGH = A -> B (toward FPGA)
	output reg	[19:0]  gpu_addr,			// connect to Z80_addr in vid_osd_generator to address GPU RAM
	output reg	[7:0]   gpu_wdata,		// 8-bit data bus to GPU RAM in vid_osd_generator
	output reg	[7:0]   Z80_rData,
	output reg	Z80_rData_ena,				// flag HIGH to write data back to Z80
	output reg	gpu_rd_req,
	output reg	Z80_245_oe					// OE for 245 level translator (active LOW)

);

parameter MEMORY_RANGE = 3'b011;	// Z80_addr[21:19] == 3'b011 targets the 512KB 'window' at 0x180000-0x1FFFFF
parameter DELAY_CYCLES = 2;		// number of cycles to delay write for 245

wire mem_window, Z80_mreq, Z80_write, Z80_read, Z80_nRead, Write_GPU_RAM, Read_GPU_RAM, GPU_data_oe, Z80_clk_delay;
wire Read_GPU_RAM_BEGIN, Read_GPU_RAM_END;

reg last_Z80_WR	= 1'b0;  // keep these low on power-up, otherwise a read or write pulse may be triggered
reg last_Z80_RD	= 1'b0;
//reg data_hold		= 1'b0;	// used to latch the gpu_rd_rdy signal
reg [9:0] Z80_write_sequencer;

assign mem_window	= (Z80_addr[21:19] == MEMORY_RANGE);	// Define an active memory range
assign Z80_mreq	= 	~Z80_MREQn && Z80_M1n;		// Define a bus memory access state
assign Z80_write	= ~Z80_WRn && last_Z80_WR;		// Isolate a single write transaction
assign Z80_read	= 	~Z80_RDn && last_Z80_RD;	// Isolate a single read transaction
assign Z80_nRead	= 	Z80_RDn && ~last_Z80_RD;	// Isolate end of a read transaction

assign Write_GPU_RAM	= mem_window && Z80_mreq && Z80_write;	// Define a GPU Write action
//assign Read_GPU_RAM	= mem_window && Z80_mreq && Z80_read;	// Define a GPU Read action
assign Read_GPU_RAM_BEGIN = mem_window && Z80_mreq && ~Z80_RDn && Z80_CLK && ~Z80_clk_delay;   // Define the beginning of a Z80 read request of GPU Ram.
assign Read_GPU_RAM_END = Z80_RDn && ~last_Z80_RD;  // Define the time to end a GPU ram read
assign GPU_data_oe	= mem_window && Z80_mreq && ~Z80_RDn;	// Define the time the GPU ouputs data onto the Z80 data bus

assign gpu_rd_req = 1'b0;				// default gpu_rd_req to LOW
assign Z80_245_oe		= 1'b0;				// disable 245 output
assign Z80_rData_ena = 1'b0;			// set Z80 data pins to input on the FPGA

always @ (posedge GPU_CLK)
begin

	Z80_write_sequencer[9:0] <= { Z80_write_sequencer[8:0], Write_GPU_RAM };

	if ( Z80_write_sequencer[0] )                 Z80_245data_dir  <= 1'b1;					// set 245 dir toward FPGA
	if ( Z80_write_sequencer[0] )                 Z80_rData_ena    <= 1'b0;					// set FPGA pins to input (should be by default)

	if ( Z80_write_sequencer[1] )                 Z80_245_oe       <= 1'b1;					// enable 245 output

	if ( Z80_write_sequencer[DELAY_CYCLES + 1] )  gpu_addr         <= Z80_addr[18:0];	// latch address bus onto GPU address bus
	if ( Z80_write_sequencer[DELAY_CYCLES + 1] )  gpu_wdata        <= Z80_wData;			// latch data bus onto GPU data bus
	if ( Z80_write_sequencer[DELAY_CYCLES + 1] )  gpu_wr_ena       <= 1'b1;					// turn on FPGA RAM we

	if ( Z80_write_sequencer[DELAY_CYCLES + 2] )  gpu_wr_ena       <= 1'b0;					// turn off FPGA RAM we
	if ( Z80_write_sequencer[DELAY_CYCLES + 2] )  Z80_245_oe       <= 1'b0;					// disable 245 output

	if ( Read_GPU_RAM_BEGIN )
	begin
		gpu_addr				<= Z80_addr[18:0];// pass address to GPU RAM
		gpu_rd_req			<= 1'b1;				// flag a read request to the mux which is one-shotted in the mux
		Z80_245data_dir	<= 1'b0;				// set 245 direction (TO Z80)
		Z80_245_oe			<= 1'b1;				// enable 245 output
	end

	if ( gpu_rd_rdy )	// gpu_rd_rdy is a one-shot from the mux, reset after one clock
	begin
		
		//data_hold		<= 1'b1;					// latch the gpu_rd_rdy signal to keep outputting data until Z80 is done with it
		Z80_rData_ena	<= 1'b1;					// set bidir pins to output
		gpu_rd_req		<= 1'b0;					// End the read request once the read is ready
		Z80_rData[7:0]	<= gpu_rData[7:0];	// Latch the GPU RAM read into the output register for the Z80
		
	end
	
	if ( Read_GPU_RAM_END )
	begin
		// data is being output to Z80, which has signalled end of read transaction
		Z80_245_oe		<= 1'b0;					// disable 245 output
		//data_hold		<= 1'b0;					// reset the latch
		Z80_rData_ena	<= 1'b0;					// set bidir pins to input
	end

	//Z80_245data_dir	<= GPU_data_oe;
	//Z80_rData_ena	<= GPU_data_oe;
	
	last_Z80_WR	<= Z80_WRn;
	last_Z80_RD	<= Z80_RDn;
	Z80_clk_delay <= Z80_CLK;  // find the rising clock edge

end

endmodule
