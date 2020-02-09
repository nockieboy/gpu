module Z80_bridge (

   // input
   input wire  reset,            // GPU reset signal
   input wire  GPU_CLK,          // GPU clock (125 MHz)
   input wire  Z80_CLK,          // Microcom clock signal (8 MHz)
   input wire  Z80_M1n,          // Z80 M1 - active LOW
   input wire  Z80_MREQn,        // Z80 MREQ - active LOW
   input wire  Z80_WRn,          // Z80 WR - active LOW
   input wire  Z80_RDn,          // Z80 RD - active LOW
   input wire  [21:0] Z80_addr,  // Microcom 22-bit address bus
   input wire  [7:0]  Z80_wData, // Z80 DATA bus to pass incoming data to GPU RAM
   input wire  [7:0]  gpu_rData,
   input wire  gpu_rd_rdy,       // one-shot signal from mux that data is ready
   input wire  sel_pclk,         // make HIGH to trigger the Z80 bus on the positive edge of Z80_CLK
   input wire  sel_nclk,         // make LOW  to trigger the Z80 bus on the negative edge of Z80_CLK
   input wire  PS2_RDY,          // goes HIGH when data is ready from PS2 keyboard on PS2_DAT
   input wire  [7:0] PS2_DAT,    // data from keyboard
   input wire  Z80_IORQn,        // Z80 IORQ - active LOW
   input wire  Z80_IEI,          // if HIGH, Z80_bridge can request interrupt immediately
   
   // output
   output reg  Z80_245data_dir,  // control level converter direction for data flow - HIGH = A -> B (toward FPGA)
   output reg  [7:0]  Z80_rData, // Z80 DATA bus to return data from GPU RAM to Z80
   output reg  Z80_rData_ena,    // flag HIGH to write data back to Z80
   output reg  Z80_245_oe,       // OE for 245 level translator *** ACTIVE LOW ***
   output reg  gpu_wr_ena,       // flag HIGH for 1 clock when writing to GPU RAM
   output reg  gpu_rd_req,       // flag HIGH for 1 clock when reading from GPU RAM
   output reg  [19:0] gpu_addr,  // connect to Z80_addr in vid_osd_generator to address GPU RAM
   output reg  [7:0]  gpu_wdata, // 8-bit data bus to GPU RAM in vid_osd_generator
   output reg  Z80_INT_REQ,      // flag HIGH to signal to host for an interrupt request
   output reg  Z80_IEO           // flag HIGH when GPU is requesting an interrupt to pull IEO LOW
   
);

// TODO:
//
// 1) Implement PS2 keyboard interface and IO-polled / interrupt handling
//

parameter MEMORY_RANGE  = 3'b010;      // Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the Microcom)
parameter MEM_SIZE_BITS = 15;          // Specifies maximum address size for the GPU RAM (anything above this returns $FF)
parameter BANK_RESPONSE = 1;           // 1 - respond to reads at BANK_ID_ADDR with appropriate data, 0 - ignore reads to that address
parameter BANK_ID_ADDR  = 17'b10111111111111111;      // Address to respond to BANK_ID queries with data (lowest 4 bits left off)

parameter int BANK_ID[16] = '{9,3,71,80,85,32,69,80,52,67,69,54,0,255,255,255};  // The BANK_ID data to return

wire 	Z80_mreq,
		Z80_write,
		Z80_read,
		Write_GPU_RAM,
		Read_GPU_RAM,
		Z80_clk_pos,
		Z80_clk_neg,
		Z80_clk_trig;

reg	Z80_clk_delay,
		last_Z80_WR,
		last_Z80_RD,
		mem_valid_range,
		mem_window,
		last_Z80_WR2,
		last_Z80_WR3,
		last_Z80_RD2,
		last_Z80_RD3,
		bank_id_access;


// ********************** PS2 Keyboard interface stuff ********************** 
//
parameter int INT_TYP  = 0;            // 0 = polled (IO), 1 = interrupt
parameter byte INT_VEC = 'h30;         // INTerrupt VECtor to be passed to host in event of an interrupt acknowledge
parameter int IO_DATA  = 240;          // IO address for keyboard polling

wire PS2_READY, IO_DATA_RQ, IO_DATA_ST, IO_DATA_RL, IO_DATA_EX, INTA_start, INTA_end, Z80_INTACK;

reg [7:0] PS2_CHAR 	= 'b0;
reg PS2_prev 			= 'b0;
reg INTACK_prev 		= 'b0;
reg IO_DATA_prev 		= 'b0;
reg [4:0] INT_DELAY 	= 'b0;
reg [4:0] IO_245_DLY = 'b0;

assign PS2_READY     = PS2_RDY && ~PS2_prev;                                  // HIGH for 1 CLK when valid data is available on PS2_DAT

assign IO_DATA_RQ    = ~Z80_IORQn && (IO_DATA == Z80_addr[7:0]) & ~Z80_RDn;   // HIGH when host is reading data via appropriate IO address
assign IO_DATA_ST		= IO_DATA_RQ && ~IO_DATA_prev;									// HIGH for 1 CLK when valid IO_DATA cycle starts
assign IO_DATA_RL		= IO_DATA_RQ && IO_245_DLY[4];									// HIGH for 1 CLK after 4 CLK delay to ReLease IO_DATA onto bus
assign IO_DATA_EX		= ~IO_DATA_RQ && IO_DATA_prev;									// HIGH for 1 CLK when valid IO_DATA cycle ends

assign Z80_INTACK    = INT_TYP && ~Z80_M1n && ~Z80_IORQn;                     // HIGH when host is acknowledging interrupt
assign INTA_start    = INT_TYP && Z80_INT_REQ && Z80_INTACK && ~INTACK_prev;  // HIGH for 1 CLK when interrupt acknowledge detected
assign INTA_end      = INT_TYP && Z80_INT_REQ && ~Z80_INTACK && INTACK_prev;  // HIGH for 1 CLK when interrupt acknowledge ends
//
// ******************************************************************** 

assign Z80_clk_pos   = ~Z80_clk_delay &&  Z80_CLK;
assign Z80_clk_neg   =  Z80_clk_delay && ~Z80_CLK;
assign Z80_clk_trig  = (Z80_clk_pos && sel_pclk) || (Z80_clk_neg && ~sel_nclk);

assign Z80_mreq      = ~Z80_MREQn && Z80_M1n;   // Define a bus memory access state
assign Z80_write     = ~Z80_WRn;                // write transaction
assign Z80_read      = ~Z80_RDn;                // read transaction

// Only allow WR to valid GPU RAM space
assign Write_GPU_RAM  =  mem_window && Z80_mreq && Z80_write && mem_valid_range; // Define a GPU Write action - only write to address within GPU RAM bounds
// Only allow RD to valid GPU RAM space
//assign Read_GPU_RAM   =  mem_window && Z80_mreq && Z80_read  && mem_valid_range; // Define the beginning of a Z80 read request of GPU Ram.

// Allow WR to entire 512KB memory window
//assign Write_GPU_RAM  =  mem_window && Z80_mreq && Z80_write;   // Define a GPU Write action - only write to address within GPU RAM bounds
// Allow RD of entire 512KB memory window
assign Read_GPU_RAM   =  mem_window && Z80_mreq && Z80_read;   	// Define the beginning of a Z80 read request of GPU Ram.

// **********************************************************************************************************

always @ (posedge GPU_CLK) begin

   gpu_addr             <=  Z80_addr[18:0];                       // Latch address bus onto GPU address bus
   mem_valid_range      <= (Z80_addr[18:0]  <  2**MEM_SIZE_BITS); // Define GPU addressable memory space
   mem_window           <= (Z80_addr[21:19] == MEMORY_RANGE);     // Define an active memory range (this decides which socket the GPU replaces)
   bank_id_access       <= (Z80_addr[21:4]  == BANK_ID_ADDR);     // Define access to BANK_ID area
   
   if (Write_GPU_RAM) begin   // *** WRITING TO GPU RAM
      
      Z80_245data_dir   <= 1'b1;       // Set 245 DIR to FPGA
      Z80_rData_ena     <= 1'b0;       // Set FPGA pins to input (should be by default)
      Z80_245_oe        <= 1'b0;       // Enable 245 output
      gpu_wdata         <= Z80_wData;  // Latch data bus onto GPU data bus
      
   end
   
   if (Read_GPU_RAM) begin    // *** READING FROM GPU RAM
      
      Z80_245data_dir   <= 1'b0;       // Set 245 DIR TO Z80
      Z80_245_oe        <= 1'b0;       // Enable 245 output
      Z80_rData_ena     <= 1'b1;       // Set bidir pins to output
      
   end

   if (gpu_rd_rdy) begin
      
      if (mem_valid_range) begin
         
         Z80_rData[7:0] <= gpu_rData[7:0];  // Latch the GPU RAM read into the output register for the Z80
         
      end else begin
         
         if (BANK_RESPONSE && bank_id_access) begin
            
            Z80_rData[7:0] <= BANK_ID[Z80_addr[3:0]]; // Return the appropriate value
            
         end else begin
            
            Z80_rData[7:0] <= 8'b11111111;   // return $FF if addressed byte is outside the GPU's upper RAM limit
            
         end
         
      end
      
   end
   
   if (INT_TYP && INT_DELAY[2]) begin  // *** RESPONDING TO INTERRUPT ACKNOWLEDGE
      
      Z80_rData[7:0]    <= INT_VEC;    // Put INT_VEC onto data bus after delay to allow 245 to get itself sorted
      
   end

   if (INTA_start) begin      // *** Valid INTerrupt ACKnowledge detected
      
      Z80_245data_dir   <= 1'b0;       // Set 245 DIR TO Z80
      Z80_245_oe        <= 1'b0;       // Enable 245 output
      Z80_rData_ena     <= 1'b1;       // Set bidir pins to output
      INT_DELAY[0]      <= 1'b1;       // Start delay timer
      
   end
   else if (INTA_end) begin   // *** End of valid INTerrupt cycle
      
      Z80_245data_dir   <= 1'b1;       // Set 245 dir toward FPGA
      Z80_rData_ena     <= 1'b0;       // Re-set bidir pins to input
      Z80_INT_REQ       <= 1'b0;       // Cancel INTerrupt REQuest
      Z80_IEO           <= 1'b0;       // Allow downstream interrupt requests again
      
   end
	
   if (PS2_READY) begin       // valid data on PS2_DAT
      
      PS2_CHAR          <= PS2_DAT; 	// Latch the character into Ps2_char register
      
      // Check IEI here to make sure we can request an interrupt
      
      if (INT_TYP) begin
         Z80_INT_REQ    <= 1'b1;   		// Fire off an INTerrupt REQuest
         Z80_IEO        <= 1'b1;   		// Pull IEO LOW to prevent anything downstream from requesting interrupts
      end
      
   end
   
   // *** START of IO cycle requesting PS2_CHAR byte
   if (IO_DATA_ST) begin
      
      Z80_245data_dir   <= 1'b0;       // Set 245 DIR TO Z80
      Z80_245_oe        <= 1'b0;       // Enable 245 output
      Z80_rData_ena     <= 1'b1;       // Set bidir pins to output
      IO_245_DLY[0]     <= 1'b1;       // Start delay timer before putting data on bus
      
   end
   
   // *** RESPONDING TO IO READ FOR PS2_CHAR
   if (IO_DATA_RL) begin
      
      Z80_rData[7:0]    <= PS2_CHAR;   // Put PS2_CHAR onto data bus after delay to allow 245 to get itself sorted
		//Z80_rData[7:0]		<= 'hAA;
      
   end
   
   // *** END of IO cycle
   if (IO_DATA_EX) begin
      
      Z80_245data_dir   <= 1'b1;       // Set 245 dir toward FPGA
      Z80_rData_ena     <= 1'b0;       // Re-set bidir pins to input
      PS2_CHAR          <= 8'b0;       // Reset PS_CHAR value
      
   end
   
   //
   // *** IF NO INTERRUPT, MEMORY OR IO READ OPERATIONS ARE ONGOING, ENFORCE DATA BUS DEFAULTS ***
   //
   if (~Z80_INT_REQ && ~Read_GPU_RAM && ~IO_DATA_RQ) begin
      
      Z80_245data_dir   <= 1'b1;       // Set 245 dir toward FPGA
      Z80_rData_ena     <= 1'b0;       // Re-set bidir pins to input
      Z80_IEO           <= ~Z80_IEI;   // Pass-through Interrupt Enable flag from upstream devices
      
   end
   
   //
   // *** FLAG & SIGNAL MAINTENANCE ***
   //
   
   // CLOCK EDGE DETECT
   Z80_clk_delay  <= Z80_CLK;

   // WRITE EDGE DETECT
   last_Z80_WR    <= Write_GPU_RAM;
   last_Z80_WR2   <= last_Z80_WR;
   last_Z80_WR3   <= last_Z80_WR2;

   // READ PROCESSING
   last_Z80_RD    <= Read_GPU_RAM;
   last_Z80_RD2   <= last_Z80_RD;
   last_Z80_RD3   <= last_Z80_RD2;
   
   // IO EDGE DETECT & PIPELINE
   IO_DATA_prev   <= IO_DATA_RQ;
   IO_245_DLY[4:1]<= IO_245_DLY[3:0];
   
   // INTERRUPT EDGE DETECT & PIPELINE
   INTACK_prev    <= Z80_INTACK;
   INT_DELAY[4:1] <= INT_DELAY[3:0];
   
   // PS2 KEYBOARD EDGE DETECT
   PS2_prev       <= PS2_RDY;

   // GPU RAM FLAGS
   gpu_wr_ena     <= Write_GPU_RAM && ~last_Z80_WR2 ; // Pulse the GPU ram's write enable only once after the Z80 write cycle has completed
   gpu_rd_req     <= Read_GPU_RAM  && ~last_Z80_RD2 ; // Pulse the read request only once at the beginning of a read cycle.
   
end

// **********************************************************************************************************

endmodule
