module Z80_bridge (
	//
   // input
   input wire  reset,            // GPU reset signal
   input wire  GPU_CLK,          // GPU clock (125 MHz)
   input wire  Z80_CLK,          // uCom clock signal (8 MHz)
   input wire  Z80_M1n,          // Z80 M1 - active LOW
   input wire  Z80_MREQn,        // Z80 MREQ - active LOW
   input wire  Z80_WRn,          // Z80 WR - active LOW
   input wire  Z80_RDn,          // Z80 RD - active LOW
   input wire  [21:0] Z80_addr,  // uCom 22-bit address bus
   input wire  [7:0]  Z80_wData, // Z80 DATA bus to pass incoming data to GPU RAM
   input wire  [7:0]  gpu_rData,
   input wire  gpu_rd_rdy,       // one-shot signal from mux that data is ready
   input wire  sel_pclk,         // make HIGH to trigger the Z80 bus on the positive edge of Z80_CLK
   input wire  sel_nclk,         // make LOW  to trigger the Z80 bus on the negative edge of Z80_CLK
   input wire  PS2_RDY,          // goes HIGH when data is ready from PS2 keyboard on PS2_DAT
   input wire  [7:0] PS2_DAT,    // data from keyboard
   input wire  Z80_IORQn,        // Z80 IORQ - active LOW
   input wire  Z80_IEI,          // if HIGH, Z80_bridge can request interrupt immediately
   //
   // output
   output reg  Z80_245data_dir,  // Control level converter direction for data flow - HIGH = A->B (toward Z80)
   output reg  [7:0]  Z80_rData, // Z80 DATA bus to return data from GPU RAM to Z80
   output reg  Z80_rData_ena,    // Flag HIGH to write data back to Z80
   output reg  Z80_245_oe,       // OE for 245 level translator *** ACTIVE LOW ***
   output reg  gpu_wr_ena,       // Flag HIGH for 1 clock when writing to GPU RAM
   output reg  gpu_rd_req,       // Flag HIGH for 1 clock when reading from GPU RAM
   output reg  [19:0] gpu_addr,  // Connect to Z80_addr in vid_osd_generator to address GPU RAM
   output reg  [7:0]  gpu_wdata, // 8-bit data bus to GPU RAM in vid_osd_generator
   output reg  Z80_INT_REQ,      // Flag HIGH to signal to host for an interrupt request
   output reg  Z80_IEO,          // Flag HIGH when GPU is requesting an interrupt to pull IEO LOW
   output reg  EA_DIR,           // Controls level converter direction for EA address flow - HIGH = A->B (toward FPGA)
   output reg  EA_OE,            // OE for EA address level converter *** ACTIVE LOW ***
   output reg  SPKR_EN,          // HIGH to enable speaker output
	output reg  VIDEO_EN				// Controls BLANK input on DAC
);
//
// TODO:
//
// 1) Implement PS2 keyboard interface and IO-polled / interrupt handling
//
// **************************************** Parameters ***************************************************
//
parameter MEMORY_RANGE  = 3'b010;// Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the uCom)
parameter MEM_SIZE_BITS = 15;    // Specifies maximum address size for the GPU RAM (anything above this returns $FF)
parameter BANK_RESPONSE = 1;     // 1 - respond to reads at BANK_ID_ADDR with appropriate data, 0 - ignore reads to that address
parameter BANK_ID_ADDR  = 17'b10111111111111111;      // Address to respond to BANK_ID queries with data (lowest 4 bits left off)
parameter int BANK_ID[16] = '{9,3,71,80,85,32,69,80,52,67,69,54,0,255,255,255};  // The BANK_ID data to return
//
// *******************************************************************************************************
//
// ************************************ Initial Values ***************************************************
//
initial VIDEO_EN = 1'b1;			// Default to video output enabled at switch-on/reset
//
// *******************************************************************************************************
//
wire  Z80_mreq,
      Z80_write,
      Z80_read,
      Write_GPU_RAM,
      Read_GPU_RAM/*,
      Z80_clk_pos,
      Z80_clk_neg,
      Z80_clk_trig*/;

reg   Z80_clk_delay,
      last_Z80_WR,
      last_Z80_RD,
      mem_valid_range,
      mem_window,
      last_Z80_WR2,
      last_Z80_WR3,
      last_Z80_RD2,
      last_Z80_RD3,
      bank_id_access;
//
// ********************** Settings and IO ports for features *********************************************
//
// INTerrupt enable and vector
parameter int INT_TYP   = 0;           // 0 = polled (IO), 1 = interrupt
parameter byte INT_VEC  = 'h30;        // INTerrupt VECtor to be passed to host in event of an interrupt acknowledge
//
// IO port addresses
//
parameter int IO_DATA   = 240;         // IO address for keyboard data polling
//parameter int IO_STAT   = 241;         // IO address for keyboard status polling
parameter int IO_SPKR   = 242;         // IO address for speaker/audio output enable
parameter int IO_BLNK   = 243;         // IO address for BLANK signal to video DAC
//
// Direction control for DATA BUS level converter
//
parameter bit data_in   = 0;				// 245_DIR for data in
parameter bit data_out  = 1;				// 245_DIR for data out
//
// *******************************************************************************************************
//
wire  PS2_READY,
      IO_DATA_RQ,
      IO_DATA_ST,
      IO_DATA_RL,
      IO_DATA_EX,
		
      IO_STAT_RQ,
      IO_STAT_ST,
      IO_STAT_RL,
      IO_STAT_EX,
		
      IO_SPKR_WR,
      IO_SPKR_ST,
		
		IO_BLNK_WR,
      IO_BLNK_ST,
		
      INTA_start,
      INTA_end,
      Z80_INTACK;

reg [7:0] PS2_CHAR   = 8'b0;           // Stores value to return when PS2_CHAR IO port is queried
//reg [7:0] PS2_STAT   = 8'b0;           // Stores value to return when PS2_STATUS IO port is queried
reg PS2_prev         = 1'b0;
reg INTACK_prev      = 1'b0;
reg IO_DATA_prev     = 1'b0;
reg IO_STAT_prev     = 1'b0;
reg IO_SPKR_prev     = 1'b0;
reg IO_BLNK_prev     = 1'b0;
reg [4:0] INT_DELAY  = 5'b0;
reg [14:0] IO_245_DLY = 5'b0;
reg IIR_flag         = 1'b0;           // Internal Interrupt Request flag

assign PS2_READY     = PS2_RDY && ~PS2_prev;                                  // HIGH for 1 CLK when valid data is available on PS2_DAT and PS2_dly_ena is LOW

assign IO_DATA_RQ    = ~Z80_IORQn && (IO_DATA == Z80_addr[7:0]) & ~Z80_RDn;   // HIGH when host is reading data from IO_DATA address
assign IO_DATA_ST    = IO_DATA_RQ && ~IO_DATA_prev;                           // HIGH for 1 CLK when valid IO_DATA cycle starts
assign IO_DATA_RL    = IO_DATA_RQ && IO_245_DLY[6];                           // HIGH for 1 CLK after 4 CLK delay to ReLease IO_DATA onto bus
assign IO_DATA_EX    = ~IO_DATA_RQ && IO_DATA_prev;                           // HIGH for 1 CLK when valid IO_DATA cycle ends
/*
assign IO_STAT_RQ    = ~Z80_IORQn && (IO_STAT == Z80_addr[7:0]) & ~Z80_RDn;   // HIGH when host is reading data from IO_STAT address
assign IO_STAT_ST    = IO_STAT_RQ && ~IO_STAT_prev;                           // HIGH for 1 CLK when valid IO_STAT cycle starts
assign IO_STAT_RL    = IO_STAT_RQ && IO_245_DLY[4];                           // HIGH for 1 CLK after 4 CLK delay to ReLease IO_STAT onto bus
assign IO_STAT_EX    = ~IO_STAT_RQ && IO_STAT_prev;                           // HIGH for 1 CLK when valid IO_STAT cycle ends
*/
assign IO_SPKR_WR    = ~Z80_IORQn && (IO_SPKR == Z80_addr[7:0]) & ~Z80_WRn;   // HIGH when host is writing data to IO_SPKR address
assign IO_SPKR_ST    = IO_SPKR_WR && ~IO_SPKR_prev;                           // HIGH for 1 CLK when valid IO_SPKR cycle starts

assign IO_BLNK_WR    = ~Z80_IORQn && (IO_BLNK == Z80_addr[7:0]) & ~Z80_WRn;   // HIGH when host is writing data to IO_BLNK address
assign IO_BLNK_ST    = IO_BLNK_WR && ~IO_BLNK_prev;                           // HIGH for 1 CLK when valid IO_BLNK cycle starts

assign Z80_INTACK    = INT_TYP && ~Z80_M1n && ~Z80_IORQn;                     // HIGH when host is acknowledging interrupt
assign INTA_start    = INT_TYP && Z80_INT_REQ && Z80_INTACK && ~INTACK_prev;  // HIGH for 1 CLK when interrupt acknowledge detected
assign INTA_end      = INT_TYP && Z80_INT_REQ && ~Z80_INTACK && INTACK_prev;  // HIGH for 1 CLK when interrupt acknowledge ends
//
// ******************************************************************** 

//assign Z80_clk_pos   = ~Z80_clk_delay &&  Z80_CLK;
//assign Z80_clk_neg   =  Z80_clk_delay && ~Z80_CLK;
//assign Z80_clk_trig  = (Z80_clk_pos && sel_pclk) || (Z80_clk_neg && ~sel_nclk); // Positive/Negative edge trigger for host Z80 CLK

assign Z80_mreq      = ~Z80_MREQn && Z80_M1n;   // Define a bus memory access state
assign Z80_write     = ~Z80_WRn;                // write transaction
assign Z80_read      = ~Z80_RDn;                // read transaction

// Only allow WR to valid GPU RAM space
assign Write_GPU_RAM =  mem_window && Z80_mreq && Z80_write && mem_valid_range; // Define a GPU Write action - only write to address within GPU RAM bounds
// Only allow RD to valid GPU RAM space
//assign Read_GPU_RAM   =  mem_window && Z80_mreq && Z80_read  && mem_valid_range; // Define the beginning of a Z80 read request of GPU Ram.

// Allow WR to entire 512KB memory window
//assign Write_GPU_RAM  =  mem_window && Z80_mreq && Z80_write;   // Define a GPU Write action - only write to address within GPU RAM bounds
// Allow RD of entire 512KB memory window
assign Read_GPU_RAM  =  mem_window && Z80_mreq && Z80_read;    // Define the beginning of a Z80 read request of GPU Ram.

// **********************************************************************************************************

always @(posedge GPU_CLK) begin

// *******************************************************************************************************
// *************************** EA Address Level Converter Control ****************************************
// *******************************************************************************************************
   EA_DIR         <= 1'b1;    // Set EA address flow A->B (towards FPGA) at all times
   EA_OE          <= 1'b0;    // Set EA address output on
// *******************************************************************************************************

// *******************************************************************************************************
// *************************************** Audio Output Control ******************************************
// *******************************************************************************************************
   if (IO_SPKR_ST && ~SPKR_EN) begin      // *** WRITING TO SPKR_EN REGISTER
   
      if (Z80_wData == 0)
         SPKR_EN  <= 1'b0;    // Disable sound output if value written is 0
      else
         SPKR_EN  <= 1'b1;    // Enable sound output if value written is anything else
   
   end
	else if (SPKR_EN) begin
	
		SPKR_EN		<= 1'b0;		// Disable SPKR_EN for one-shot signal
	
	end
	
// *******************************************************************************************************

// *******************************************************************************************************
// *************************************** Video Output Control ******************************************
// *******************************************************************************************************
   if (IO_BLNK_ST) begin      // *** WRITING TO VIDEO_EN REGISTER
   
      if (Z80_wData == 0)
         VIDEO_EN <= 1'b0;    // Disable video output if value written is 0
      else
         VIDEO_EN <= 1'b1;    // Enable video output if value written is anything else
   
   end
// *******************************************************************************************************
   
   gpu_addr             <=  Z80_addr[18:0];                       // Latch address bus onto GPU address bus
   mem_valid_range      <= (Z80_addr[18:0]  <  2**MEM_SIZE_BITS); // Define GPU addressable memory space
   mem_window           <= (Z80_addr[21:19] == MEMORY_RANGE);     // Define an active memory range (this decides which socket the GPU replaces)
   bank_id_access       <= (Z80_addr[21:4]  == BANK_ID_ADDR);     // Define access to BANK_ID area
   
   if (Write_GPU_RAM) begin   // *** WRITING TO GPU RAM
      
      Z80_245data_dir   <= data_in;    // Set 245 DIR to FPGA
      Z80_rData_ena     <= 1'b0;       // Set FPGA pins to input (should be by default)
      Z80_245_oe        <= 1'b0;       // Enable 245 output
      gpu_wdata         <= Z80_wData;  // Latch data bus onto GPU data bus
      
   end
   
   if (Read_GPU_RAM) begin    // *** READING FROM GPU RAM
      
      Z80_245data_dir   <= data_out;   // Set 245 DIR TO Z80
      Z80_245_oe        <= 1'b0;       // Enable 245 output
      Z80_rData_ena     <= 1'b1;       // Set bidir pins to output
      
   end

   if (gpu_rd_rdy) begin
      
      if (mem_valid_range) begin
         
         Z80_rData[7:0] <= gpu_rData[7:0];  // Latch the GPU RAM read into the output register for the Z80
         
      end else if (BANK_RESPONSE && bank_id_access) begin
         
         Z80_rData[7:0] <= BANK_ID[Z80_addr[3:0]]; // Return the appropriate value
         
      end else begin
         
         Z80_rData[7:0] <= 2'hFF;      // return $FF if addressed byte is outside the GPU's upper RAM limit
         
      end
      
   end
   
   if (INT_TYP && INT_DELAY[2]) begin  // *** RESPONDING TO INTERRUPT ACKNOWLEDGE
      
      Z80_rData[7:0]    <= INT_VEC;    // Put INT_VEC onto data bus after delay to allow 245 to get itself sorted
      
   end

   if (INTA_start) begin      // *** Valid INTerrupt ACKnowledge detected
      
      Z80_245data_dir   <= data_out;   // Set 245 DIR TO Z80
      Z80_245_oe        <= 1'b0;       // Enable 245 output
      Z80_rData_ena     <= 1'b1;       // Set bidir pins to output
      INT_DELAY[0]      <= 1'b1;       // Start delay timer
      
   end
   else if (INTA_end) begin   // *** End of valid INTerrupt cycle
      
      Z80_245data_dir   <= data_in;    // Set 245 dir toward FPGA
      Z80_rData_ena     <= 1'b0;       // Re-set bidir pins to input
      Z80_INT_REQ       <= 1'b0;       // Cancel INTerrupt REQuest
      Z80_IEO           <= 1'b0;       // Allow downstream interrupt requests again
      Z80_rData[7:0]    <= 8'bz;       // Set FPGA data bus to high impedance
      
   end
   
   if (PS2_READY) begin       // valid data on PS2_DAT
      
      PS2_CHAR          <= PS2_DAT;    // Latch the character into Ps2_char register
      //PS2_STAT          <= 2'h01;      // Set PS2_STAT to show valid data is available
      
      if (INT_TYP) begin
         
         IIR_flag       <= 1'b1;       // Set internal interrupt request flag
         Z80_IEO        <= 1'b1;       // Pull IEO LOW to prevent anything downstream from requesting interrupts
         
      end
      
   end
   
   // *** REQUEST INTERRUPT WHEN IEI, IIR_flag AND INT_TYP ARE HIGH
   if (INT_TYP && IIR_flag && Z80_IEI) begin
      
      IIR_flag          <= 1'b0;          // Reset internal interrupt flag
      Z80_INT_REQ       <= 1'b1;          // Fire off an INTerrupt REQuest
      
   end

// *******************************************************************************************************
// *** START of IO cycle requesting PS2_CHAR byte
// *******************************************************************************************************
   if (IO_DATA_ST) begin
      
      //Z80_245data_dir   <= data_out;   // Set 245 DIR TO Z80
      //Z80_rData_ena     <= 1'b1;       // Set bidir pins to output
      IO_245_DLY[0]     <= 1'b1;       // Start delay timer before putting data on bus
      Z80_rData[7:0]    <= 8'bz;       // Set FPGA data bus to high impedance
      
   end
   
   // *** RESPONDING TO IO READ FOR PS2_CHAR AFTER DELAY
   if (IO_DATA_RL) begin
      
      Z80_245data_dir   <= data_out;   // Set 245 DIR TO Z80
      Z80_rData_ena     <= 1'b1;       // Set bidir pins to output
      //Z80_rData[7:0]    <= PS2_CHAR;   // Put PS2_CHAR onto data bus after delay to allow 245 to get itself sorted
      Z80_245_oe        <= 1'b0;       // Enable 245 output
      Z80_rData[7:0]    <= 'h55;       // DEBUG: Return fixed value when read by host
      
   end
   
   // *** END of PS2_CHAR IO cycle
   if (IO_DATA_EX) begin
	
      Z80_245data_dir   <= data_in;    // Set 245 dir toward FPGA
      Z80_rData_ena     <= 1'b0;       // Re-set bidir pins to input
      PS2_CHAR          <= 8'b0;       // Reset PS_CHAR value
      Z80_rData[7:0]    <= 8'bz;       // Set FPGA data bus to high impedance
		
	end

// *******************************************************************************************************
 
// *******************************************************************************************************
// *** START of IO cycle requesting PS2_STATUS
// *******************************************************************************************************
/*   if (IO_STAT_ST) begin
      
      Z80_245data_dir   <= data_out;   // Set 245 DIR TO Z80
      Z80_245_oe        <= 1'b0;       // Enable 245 output
      Z80_rData_ena     <= 1'b1;       // Set bidir pins to output
      IO_245_DLY[0]     <= 1'b1;       // Start delay timer before putting data on bus
      
   end
   
   // *** RESPONDING TO IO READ FOR PS2_STATUS
   //if (IO_STAT_RL) begin
      
      //Z80_rData[7:0]    <= PS2_STAT;   // Put PS2_STAT onto data bus after delay to allow 245 to get itself sorted
      
   //end
   
   // *** END of PS2_STATUS IO cycle
   if (IO_STAT_EX) begin
      
      Z80_245data_dir   <= data_in;    // Set 245 dir toward FPGA
      Z80_rData_ena     <= 1'b0;       // Re-set bidir pins to input
      
   end */
// *******************************************************************************************************
 
// *******************************************************************************************************
// *** IF NO INTERRUPT, MEMORY OR IO READ OPERATIONS ARE ONGOING, ENFORCE DATA BUS DEFAULTS            ***
// *******************************************************************************************************
   if (~Z80_INT_REQ && ~Read_GPU_RAM && ~Write_GPU_RAM && ~IO_DATA_RQ /*&& ~IO_STAT_RQ*/) begin
      
      //Z80_245_oe        <= 1'b1;       // Disable 245 output
      Z80_245data_dir   <= data_in;    // Set 245 dir toward FPGA
      Z80_rData_ena     <= 1'b0;       // Re-set bidir pins to input
      Z80_IEO           <= ~Z80_IEI;   // Pass-through Interrupt Enable flag from upstream devices
      Z80_rData[7:0]    <= 8'bz;       // Set FPGA data bus to high impedance
      
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
   IO_SPKR_prev   <= IO_SPKR_WR;
   IO_DATA_prev   <= IO_DATA_RQ;
   IO_245_DLY[14:1]<= IO_245_DLY[13:0];
	//IO_END_DLY[9:1]<= IO_END_DLY[8:0];
   
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
