module Z80_bridge_v2 (

// **** INPUTS ****
   input logic  reset,            // GPU reset signal
   input logic  GPU_CLK,          // GPU clock (125 MHz)
   input logic  Z80_CLK,          // uCom clock signal (8 MHz)
   input logic  Z80_M1n,          // Z80 M1   - active LOW
   input logic  Z80_MREQn,        // Z80 MREQ - active LOW
   input logic  Z80_WRn,          // Z80 WR   - active LOW
   input logic  Z80_RDn,          // Z80 RD   - active LOW
   input logic  [21:0] Z80_addr,  // uCom 22-bit address bus
   input logic  [7:0]  Z80_wData, // Z80 DATA bus to pass incoming data to GPU RAM
   input logic  [7:0]  gpu_rData,
   input logic  gpu_rd_rdy,       // One-shot signal from mux or DDR3_Controller that data is ready
   input logic  PS2_RDY,          // goes HIGH when data is ready from PS2 keyboard on PS2_DAT
   input logic  [7:0] PS2_DAT,    // data from keyboard
   input logic  Z80_IORQn,        // Z80 IORQ - active LOW
   input logic  Z80_IEI,          // if HIGH, Z80_bridge can request interrupt immediately
   
   // inputs from geo_unit
   input logic [7:0] WR_PX_CTR,  // WRITE PIXEL collision counter from pixel_writer
   input logic [7:0] RD_PX_CTR,  // COPY READ PIXEL collision counter from pixel_writer
   input logic [7:0] GEO_STAT_RD,// bit 0 = scfifo's almost full flag, other bits free for other data
   input logic [7:0] PS2_STATUS,
	
   //input logic  sel_pclk,         // make HIGH to trigger the Z80 bus on the positive edge of Z80_CLK
   //input logic  sel_nclk,         // make LOW  to trigger the Z80 bus on the negative edge of Z80_CLK

// **** OUTPUTS ****
   output logic Z80_245data_dir_r,// Control level converter direction for data flow - HIGH = A->B (toward Z80)
   output logic [7:0] Z80_rData_r,// Z80 DATA bus to return data from GPU RAM to Z80
   output logic Z80_rData_ena_r,  // Flag HIGH to write data back to Z80
   output logic Z80_245_oe_r,     // OE for 245 level translator *** ACTIVE LOW ***
   output logic gpu_wr_ena,       // Flag HIGH for 1 clock when writing to GPU RAM
   output logic gpu_rd_req,       // Flag HIGH for 1 clock when reading from GPU RAM
   output logic [19:0] gpu_addr,  // Connect to Z80_addr in vid_osd_generator to address GPU RAM
   output logic [7:0] gpu_wdata,  // 8-bit data bus to GPU RAM in vid_osd_generator
   output logic Z80_INT_REQ_r,    // Flag HIGH to signal to host for an interrupt request
   output logic Z80_WAIT,         // Flag HIGH to pull Z80's WAIT line LOW
   output logic Z80_IEO_r,        // Flag HIGH when GPU is requesting an interrupt to pull IEO LOW
   output logic EA_DIR_r,         // Controls level converter direction for EA address flow - HIGH = A->B (toward FPGA)
   output logic EA_OE_r,          // OE for EA address level converter *** ACTIVE LOW ***
   output logic SPKR_EN,          // HIGH to enable speaker output
   output logic VIDEO_EN,         // Controls BLANK input on DAC
   output logic snd_data_tx,      // HIGH for 1 clock for valid snd_data
   output logic [8:0] snd_data,   // Data bus to sound module
   
   // outputs to geo_unit
   output logic GEO_WR_LO_STROBE, // HIGH to write low byte to geo unit
   output logic [7:0] GEO_WR_LO,  // low byte data for geo unit
   
   output logic GEO_WR_HI_STROBE, // HIGH to write high byte to geo unit
   output logic [7:0] GEO_WR_HI,  // high byte data for geo unit - for little-endian input, this will connect to FIFO 'fifo_cmd_ready' input
   
   output logic WR_PX_CTR_STROBE, // HIGH to clear the WRITE PIXEL collision counter
   output logic RD_PX_CTR_STROBE  // HIGH to clear the COPY READ PIXEL collision counter
	
   //output logic GEO_RD_STAT_STROBE, // HIGH when reading data on GEO_STAT_RD bus
   //output logic GEO_WR_STAT_STROBE, // HIGH when sending data on GEO_STAT_WR bus
   //output logic [7:0] GEO_STAT_WR  // data bus out to geo unit

);

//
// TODO:
//
// 1) Interrupt handling for keyboard data
//
//
// **************************************** Parameters ***************************************************
//

parameter ADD_WAITS            = 0; // Set to 1 to add RD/WR WAIT states for memory operations, 2 for RD WAITs only, 0 for none
parameter USE_Z80_CLK          = 1; // use 1 to wait for a Z80 clk input before considering a bus transaction.
parameter INV_Z80_CLK          = 0; // Invert the source Z80 clk when considering a bus transaction.
parameter Z80_CLK_FILTER       = 0; // The number of GPU clock cycles to filter the Z80 bus commands, use 0 through 7.
parameter Z80_CLK_FILTER_P     = 2; // The number of GPU clock cycles to filter the Z80 bus PORT commands, use 0 through 7.

parameter MEMORY_RANGE         = 3'b010;  // Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the uCom)
parameter MEM_SIZE_BYTES       = 196608;   // Specifies maximum size for the GPU RAM (anything above this returns $FF) (Default: 40960)
parameter BANK_RESPONSE        = 1;       // 1 - respond to reads at BANK_ID_ADDR with appropriate data, 0 - ignore reads to that address
parameter BANK_ID_ADDR         = 15'b111111111111111;      // Address to respond to BANK_ID queries with data (lowest 4 bits left off)
parameter bit [7:0] BANK_ID[0:15]  = '{9,3,71,80,85,32,69,80,52,67,69,49,48,0,255,255};  // The BANK_ID data to return

assign WR_PX_CTR_STROBE = 0 ; // Default to low to prevent compile warnings about no driver
assign RD_PX_CTR_STROBE = 0 ; // Default to low to prevent compile warnings about no driver

reg    Z80_CLKr,Z80_CLKr2;
wire   z80_pclk, z80_nclk, zclk;
assign z80_pclk = (INV_Z80_CLK ?  ( ~Z80_CLKr &&  Z80_CLKr2 ) : (  Z80_CLKr && ~Z80_CLKr2 )) || USE_Z80_CLK==0 ; // isolate the positive Z80 clk transition, invert edge detect if INV_Z80_CLK is used
assign z80_nclk = (INV_Z80_CLK ?  (  Z80_CLKr && ~Z80_CLKr2 ) : ( ~Z80_CLKr &&  Z80_CLKr2 )) || USE_Z80_CLK==0 ; // isolate the negative Z80 clk transition, invert edge detect if INV_Z80_CLK is used
assign zclk     =  z80_pclk || z80_nclk ;

// register bus control inputs with up to a Z80_CLK_FILTER
reg          Z80_M1n_r  ,        // Z80 M1 - active LOW
             Z80_MREQn_r,        // Z80 MREQ - active LOW
             Z80_WRn_r  ,        // Z80 WR - active LOW
             Z80_RDn_r  ,        // Z80 RD - active LOW
             Z80_IORQn_r;        // Z80 IOPORT - active LOW
             //Z80_IEI_r;
reg   [21:0] Z80_addr_r ;        // uCom 22-bit address bus
reg   [7:0]  Z80_wData_r;        // uCom 8 bit data bus input

reg   [2:0]  z80_read_opcode_fc ,// command filter counters.  Counts the GPU clock cycles for a command to be solidly asserted before enable/disable
             z80_read_memory_fc ,
             z80_read_port_fc   ,
             z80_write_memory_fc,
             z80_write_port_fc  ;
             
reg   [7:0]  PSR_RDY_r;

wire         z80_op_read_opcode , // decoded bus commands
             z80_op_read_memory ,
             z80_op_write_memory,
             z80_op_read_port   ,
             z80_op_write_port  ,
             z80_op_memory      ; // Quickly decode a memory op (read OR write) for WAIT insertion

assign       z80_op_memory       =  Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r                             ; // bus controls for start of memory operation
assign       z80_op_read_opcode  = ~Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r && ~Z80_RDn_r &&  Z80_WRn_r ; // bus controls for read opcode operation
assign       z80_op_read_memory  =  Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r && ~Z80_RDn_r &&  Z80_WRn_r ; // bus controls for memory RD operation
assign       z80_op_write_memory =  Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r &&  Z80_RDn_r && ~Z80_WRn_r ; // bus controls for memory WR operation
assign       z80_op_read_port    =  Z80_M1n_r && ~Z80_IORQn_r  &&  Z80_MREQn_r && ~Z80_RDn_r &&  Z80_WRn_r ; // bus controls for IO RD operation
assign       z80_op_write_port   =  Z80_M1n_r && ~Z80_IORQn_r  &&  Z80_MREQn_r &&  Z80_RDn_r && ~Z80_WRn_r ; // bus controls for IO WR operation

reg  z80_read_opcode      ,
     z80_read_memory      ,
     z80_read_port        ,
     z80_write_memory     ,
     z80_write_port       ,
     last_z80_memory_op   ,
     last_z80_read_opcode ,
     last_z80_read_memory ,
     last_z80_read_port   ,
     last_z80_write_memory,
     last_z80_write_port  ;

// these wires setup a 1 shot signal at the beginning of the bus transaction
wire z80_memory_op_1s   ,
     z80_read_opcode_1s ,
     z80_read_memory_1s ,
     z80_read_port_1s   ,
     z80_write_memory_1s,
     z80_write_port_1s  ;

// these wires signal when the Z80 is addressing a port, the last 16-bytes of/or the GPU's 512KB window
wire mem_in_bank        ,
	  mem_in_ID          ,
	  port_in_range      ;

// create 1 shots versions of each type of bus transaction cycle
assign z80_memory_op_1s    = z80_op_memory    && ~last_z80_memory_op    ;
assign z80_read_opcode_1s  = z80_read_opcode  && ~last_z80_read_opcode  ;
assign z80_read_memory_1s  = z80_read_memory  && ~last_z80_read_memory  ;
assign z80_read_port_1s    = z80_read_port    && ~last_z80_read_port    ;
assign z80_write_memory_1s = z80_write_memory && ~last_z80_write_memory ;
assign z80_write_port_1s   = z80_write_port   && ~last_z80_write_port   ;
// Make sure Extended Address bus is always set to 'TO FPGA'
assign EA_DIR              = 1'b1 ; // Set EA address flow A->B
assign EA_OE               = 1'b0 ; // Set EA address output on
// define the GPU ram access window
assign mem_in_bank         = (Z80_addr_r[21:19]==MEMORY_RANGE[2:0]) ; // Define memory access window (512 KB range)
assign mem_in_ID           = (Z80_addr_r[21:19]==MEMORY_RANGE[2:0]) && (Z80_addr_r[18:4] == BANK_ID_ADDR[14:0]) ; // Define BANK_ID access window (16 bytes)
// define the GPU access ports range
assign port_in_range       = ((Z80_addr_r[7:0] >= IO_DATA[7:0]) && (Z80_addr_r[7:0] <= WAIT_PORT[7:0])) ; // You are better off reserving a range of ports

//
// *******************************************************************************************************
//
// ************************************ Initial Values ***************************************************
//
initial VIDEO_EN = 1'b1;         // Default to video output enabled at switch-on/reset
//
// *******************************************************************************************************
//
//
// ********************** Settings and IO ports for features *********************************************
//
// INTerrupt enable and vector
parameter int INT_TYP   = 0;        // 0 = polled (IO), 1 = interrupt
parameter byte INT_VEC  = 'h30;     // INTerrupt VECtor to be passed to host in event of an interrupt acknowledge
//
// IO port addresses
//
parameter int IO_DATA   = 240;      // IO address for keyboard data polling
parameter int IO_STAT   = 241;      // IO address for keyboard status polling
parameter int SND_OUT   = 242;      // IO address for speaker/audio output enable
parameter int IO_BLNK   = 243;      // IO address for BLANK signal to video DAC
parameter int SND_TON   = 244;      // IO address for TONE register in sound module
parameter int SND_DUR   = 245;      // IO address for DURATION register in sound module
parameter int GEO_LO    = 246;      // IO address for GEOFF LOW byte
parameter int GEO_HI    = 247;      // IO address for GEOFF HIGH byte
parameter int FIFO_STAT = 248;      // IO address for GPU FIFO status on bit 0 - remaining bits free for other data
parameter int WAIT_PORT = 249;      // IO address for Z80_WAIT delay setting (EVEN value - WAIT OFF, ODD value - WAIT SET TO VALUE)
//
// Direction control for DATA BUS level converter
//
parameter bit data_in   = 0  ;      // 245_DIR for data in
parameter bit data_out  = 1  ;      // 245_DIR for data out
//
// *******************************************************************************************************
//
//reg        PS2_prev   = 1'b0        ;
//reg [12:0] port_dly   = 13'b0       ; // Port delay pipeline delays data output on an IO port read
reg [7:0]  PS2_CHAR   = 8'b0        ; // Stores value to return when PS2_CHAR IO port is queried
reg [7:0]  PS2_STAT   = 8'b0        ; // Stores value to return when PS2_STATUS IO port is queried
reg [7:0]  PS2_RDY_r  = 8'b0        ;
reg [7:0]  WAIT_VAL   = 8'b00000000 ; // WAIT delay value (this is upper 8-bits of the 10-bit WAIT counter)
reg [7:0]  WAIT_CNT   = 8'b00000000 ; // WAIT delay timer
reg        rd_DAT_rdy = 1'b0        ; // read_data_ready flag
reg        mem_op_dir = 1'b1        ; // memory operation direction (RD/WR) - 0 = RD, 1 = WR
reg [2:0]  memrange   = 3'b000      ; // 3-cycle buffer to make sure address is definitely valid in memory range

logic        Z80_245data_dir    ; // Control level converter direction for data flow - HIGH = A->B (toward Z80)
logic [7:0]  Z80_rData          ; // Z80 DATA bus to return data from GPU RAM to Z80
logic        Z80_rData_ena      ; // Flag HIGH to write data back to Z80
logic        Z80_245_oe         ; // OE for 245 level translator *** ACTIVE LOW ***
logic        Z80_INT_REQ = 0    ; // Flag HIGH to signal to host for an interrupt request
logic        Z80_IEO = 0        ; // Flag HIGH when GPU is requesting an interrupt to pull IEO LOW
logic        EA_DIR             ; // Controls level converter direction for EA address flow - HIGH = A->B (toward FPGA)
logic        EA_OE              ; // OE for EA address level converter *** ACTIVE LOW ***
logic        Z80_245data_dir_r2 ; // Control level converter direction for data flow - HIGH = A->B (toward Z80)
logic [7:0]  Z80_rData_r2       ; // Z80 DATA bus to return data from GPU RAM to Z80
logic        Z80_rData_ena_r2   ; // Flag HIGH to write data back to Z80
logic        Z80_245_oe_r2      ; // OE for 245 level translator *** ACTIVE LOW ***
logic        Z80_INT_REQ_r2     ; // Flag HIGH to signal to host for an interrupt request
logic        Z80_IEO_r2         ; // Flag HIGH when GPU is requesting an interrupt to pull IEO LOW
logic        EA_DIR_r2          ; // Controls level converter direction for EA address flow - HIGH = A->B (toward FPGA)
logic        EA_OE_r2           ; // OE for EA address level converter *** ACTIVE LOW ***
logic [7:0]  WAITbuff           ; // buffer to return data from GPU RAM to Z80 after a WAIT

wire   noWaitCount ;
assign noWaitCount = (WAIT_CNT[7:0] == 8'b00000000) ;

always @(posedge GPU_CLK) begin

   // Double register the outputs to the slow Z80 bus.
   Z80_245data_dir_r2 <= Z80_245data_dir    ; // Control level converter direction for data flow - HIGH = A->B (toward Z80)
   Z80_rData_r2       <= Z80_rData          ; // Z80 DATA bus to return data from GPU RAM to Z80
   Z80_rData_ena_r2   <= Z80_rData_ena      ;
   Z80_245_oe_r2      <= Z80_245_oe         ;
   Z80_INT_REQ_r2     <= Z80_INT_REQ        ;
   Z80_IEO_r2         <= Z80_IEO            ;
   EA_DIR_r2          <= EA_DIR             ;
   EA_OE_r2           <= EA_OE              ;
   // Triple register the outputs to the slow Z80 bus.
   Z80_245data_dir_r  <= Z80_245data_dir_r2 ; // Control level converter direction for data flow - HIGH = A->B (toward Z80)
   Z80_rData_r        <= Z80_rData_r2       ; // Z80 DATA bus to return data from GPU RAM to Z80
   Z80_rData_ena_r    <= Z80_rData_ena_r2   ;
   Z80_245_oe_r       <= Z80_245_oe_r2      ;
   Z80_INT_REQ_r      <= Z80_INT_REQ_r2     ;
   Z80_IEO_r          <= Z80_IEO_r2         ;
   EA_DIR_r           <= EA_DIR_r2          ;
   EA_OE_r            <= EA_OE_r2           ;
   // Update the memrange pipeline (used to identify a stable Z80 address)
   memrange[2:1]      <= memrange[1:0]      ;
   memrange[0]        <= ((Z80_addr_r[21:19] == MEMORY_RANGE[2:0]) && (Z80_addr_r[18:0] < MEM_SIZE_BYTES[18:0])) ; // HIGH if Z80 address is a valid GPU RAM location
   // Latch and delay the Z80 CLK input for transition edge processing.
   Z80_CLKr           <= Z80_CLK            ; // Register delay the Z80_CLK input.
   Z80_CLKr2          <= Z80_CLKr           ; // Register delay the Z80_CLK input.
   // Latch bus controls and shift them into the filter pipes.
   Z80_M1n_r          <= Z80_M1n            ; // Z80 M1 - active LOW
   Z80_MREQn_r        <= Z80_MREQn          ; // Z80 MREQ - active LOW
   Z80_WRn_r          <= Z80_WRn            ; // Z80 WR - active LOW
   Z80_RDn_r          <= Z80_RDn            ; // Z80 RD - active LOW
   Z80_IORQn_r        <= Z80_IORQn          ; // Z80 IORQ - active low
   //Z80_IEI_r          <= Z80_IEI            ;
   // Latch address and data coming in from Z80.
   Z80_addr_r         <= Z80_addr           ; // uCom 22-bit address bus
   Z80_wData_r        <= Z80_wData          ; // uCom 8 bit data bus input

   // generate a bidirectional 'hysteresis' counter set to Z80_CLK_FILTER clocks to ensure the stability of each opcode
        if (          Z80_RDn_r                                                            ) z80_read_opcode_fc  <= 3'd0;
   else if ( zclk &&  z80_op_read_opcode  && (z80_read_opcode_fc  != Z80_CLK_FILTER[2:0] ) ) z80_read_opcode_fc  <= z80_read_opcode_fc  + 1'd1;
        if (          Z80_RDn_r                                                            ) z80_read_opcode     <= 1'b0;
   else if ( zclk &&  z80_op_read_opcode  && (z80_read_opcode_fc  == Z80_CLK_FILTER[2:0] ) ) z80_read_opcode     <= 1'b1;

        if (          Z80_RDn_r                                                            ) z80_read_memory_fc  <= 3'd0;
   else if ( zclk &&  z80_op_read_memory  && (z80_read_memory_fc  != Z80_CLK_FILTER[2:0] ) ) z80_read_memory_fc  <= z80_read_memory_fc  + 1'd1;
        if (          Z80_RDn_r                                                            ) z80_read_memory     <= 1'b0;
   else if ( zclk &&  z80_op_read_memory  && (z80_read_memory_fc  == Z80_CLK_FILTER[2:0] ) ) z80_read_memory     <= 1'b1;

        if (          Z80_RDn_r                                                            ) z80_read_port_fc    <= 3'd0;
   else if ( zclk &&  z80_op_read_port    && (z80_read_port_fc    != Z80_CLK_FILTER_P[2:0])) z80_read_port_fc    <= z80_read_port_fc    + 1'd1;
        if (          Z80_RDn_r                                                            ) z80_read_port       <= 1'b0;
   else if ( zclk &&  z80_op_read_port    && (z80_read_port_fc    == Z80_CLK_FILTER_P[2:0])) z80_read_port       <= 1'b1;

        if (          Z80_WRn_r                                                            ) z80_write_memory_fc <= 3'd0;
   else if ( zclk &&  z80_op_write_memory && (z80_write_memory_fc != Z80_CLK_FILTER[2:0] ) ) z80_write_memory_fc <= z80_write_memory_fc + 1'd1;
        if (          Z80_WRn_r                                                            ) z80_write_memory    <= 1'b0;
   else if ( zclk &&  z80_op_write_memory && (z80_write_memory_fc == Z80_CLK_FILTER[2:0] ) ) z80_write_memory    <= 1'b1;

        if (          Z80_WRn_r                                                            ) z80_write_port_fc   <= 3'd0;
   else if ( zclk &&  z80_op_write_port   && (z80_write_port_fc   != Z80_CLK_FILTER_P[2:0])) z80_write_port_fc   <= z80_write_port_fc   + 1'd1;
        if (          Z80_WRn_r                                                            ) z80_write_port      <= 1'b0;
   else if ( zclk &&  z80_op_write_port   && (z80_write_port_fc   == Z80_CLK_FILTER_P[2:0])) z80_write_port      <= 1'b1;
   // end of generate a bydirectional 'hysteresis' counter set to Z80_CLK_FILTER clocks to ensure the stability of each opcode

   // delay registers to generate 1 shots for beginning of each bus transaction cycle
   last_z80_memory_op    <= z80_op_memory    ;
   last_z80_read_opcode  <= z80_read_opcode  ;
   last_z80_read_memory  <= z80_read_memory  ;
   last_z80_read_port    <= z80_read_port    ;
   last_z80_write_memory <= z80_write_memory ;
   last_z80_write_port   <= z80_write_port   ;
   
   // mem_in_bank  goes high when Z80_address is within GPU's 512KB window
   // memrange is 3'b111 when Z80_address is within GPU's valid RAM space for a minimum of 3 cycles
	// Intercept memory operations on GPU RAM as early as possible to get WAIT asserted in time for the Z80's T2 cycle.
	// Only pull trigger WAIT if the delay count is not zero, though.
	if ( z80_memory_op_1s && memrange[2:0] == 3'b111 && WAIT_VAL[7:0] != 8'b00000000 ) begin
		// A valid memory op is beginning - it'll either be a RD or a WR, so get WAIT asserted
		Z80_WAIT      <= 1'b1          ; // Pull WAIT low
		WAIT_CNT[7:0] <= WAIT_VAL[7:0] ; // Set WAIT_CNT to a variable delay chiefly set by WAIT_VAL, minimum 8 cycles
	end
	
   // Ensure GPU write and read requests are only generated for valid addresses in GPU RAM and not for the
   // entire 512KB window, access to which is handled further down the code.
   if ( z80_write_memory_1s && mem_in_bank && memrange[2:0] == 3'b111 ) begin  // *** START OF Z80 WRITE OP TO GPU RAM ***
   
      gpu_addr       <= Z80_addr_r[19:0] ;
      gpu_wdata      <= Z80_wData_r      ;
      gpu_wr_ena     <= 1'b1             ; // Flag HIGH for 1 clock when reading from GPU RAM
      mem_op_dir     <= 1'b1             ; // Set mem_op_dir to WR
      
   end else begin // not a write op to valid GPU RAM
   
      gpu_wr_ena     <= 1'b0             ; // Ensure only flags HIGH for 1 clock when reading from GPU RAM
      
   end
   
   
   if ( z80_read_memory_1s && mem_in_bank && memrange[2:0] == 3'b111 ) begin  // *** START OF Z80 READ OP FROM GPU RAM ***
   
      gpu_addr       <= Z80_addr_r[19:0] ;
      gpu_rd_req     <= 1'b1             ; // Flag HIGH for 1 clock when reading from GPU RAM
		rd_DAT_rdy     <= 1'b0             ; // Reset read_data_ready flag
      mem_op_dir     <= 1'b0             ; // Set mem_op_dir to RD
		
   end else begin
   
      gpu_rd_req     <= 1'b0                       ; // Ensure only flags HIGH for 1 clock when reading from GPU RAM
      
   end

   // *** MANAGE THE WAIT COUNTER AND END OF RD/WR OPS ***
   if ( Z80_WAIT == 1'b1 && !noWaitCount ) begin  // WAIT_CNT is non-zero
      
      WAIT_CNT        <= WAIT_CNT - 1'b1 ; // Decrement WAIT_CNT counter
      
   end else if ( noWaitCount && rd_DAT_rdy ) begin  // WAIT is asserted, WAIT counter is zero and read data is ready; end of RD op
      
      Z80_rData       <= WAITbuff ; // pass GPU RAM data to the data bus output
      Z80_245data_dir <= data_out ; // set the data bus buffer direction to 'TO HOST'
      Z80_rData_ena   <= 1'b1     ; // set the bidirectional IO port to OUT
      Z80_245_oe      <= 1'b0     ; // enable the data bus buffer
      rd_DAT_rdy      <= 1'b0     ; // reset read_data_ready flag
      Z80_WAIT        <= 1'b0     ; // release WAIT line

   end else if ( Z80_WAIT == 1'b1 && noWaitCount && mem_op_dir == 1'b1 ) begin // WAIT is asserted, WAIT counter is zero; end of WR op

      Z80_WAIT        <= 1'b0     ; // release WAIT line

   end
// ******

   if ( z80_write_port_1s && Z80_addr_r[7:0]==SND_OUT ) begin     // Write_port 1 clock & SPEAKER ENABLE address
   
      SPKR_EN <= 1'b1 ;
      
   end else begin
   
      SPKR_EN <= 1'b0 ; // Enforce SPKR_EN as one-shot
      
   end
   
   if ( z80_write_port_1s && Z80_addr_r[7:0]==SND_DUR ) begin     // Write_port 1 clock & sound module STOP flag address
   
      snd_data[8]   <= 1'b0             ; // bit 8 LOW for STOP register
      snd_data[7:0] <= Z80_wData_r[7:0] ; // data is ignored
      snd_data_tx   <= 1'b1             ;
      
   end
   
   if ( z80_write_port_1s && Z80_addr_r[7:0]==SND_TON ) begin     // Write_port 1 clock & sound module TONE register address
   
      snd_data[8]   <= 1'b1             ; // bit 8 HIGH for TONE register
      snd_data[7:0] <= Z80_wData_r[7:0] ;
      snd_data_tx   <= 1'b1             ;
      
   end
   
   // **** Manage IO interface to GEO_UNIT ****
   if ( z80_write_port_1s && Z80_addr_r[7:0]==GEO_LO ) begin     // Write to GEOFF low-byte register
   
      GEO_WR_LO        <= Z80_wData_r[7:0] ;
      GEO_WR_LO_STROBE <= 1'b1             ; // Pulse strobe HIGH to signal to FIFO new data on the bus - wiring to FIFO will decide will STROBE to act upon
      
   end else begin
	
	   GEO_WR_LO_STROBE <= 1'b0             ;
		
	end
   
   if ( z80_write_port_1s && Z80_addr_r[7:0]==GEO_HI ) begin     // Write to GEOFF high-byte register
   
      GEO_WR_HI        <= Z80_wData_r[7:0] ;
      GEO_WR_HI_STROBE <= 1'b1             ; // Pulse strobe HIGH to signal to FIFO new data on the bus - wiring to FIFO will decide will STROBE to act upon
      
   end else begin
	
	   GEO_WR_HI_STROBE <= 1'b0             ;
		
	end
   // ***** End of GEO_UNIT IO interface *****
   
   // **** ONE-SHOTS ****
   if ( snd_data_tx ) snd_data_tx <= 1'b0 ; // Enforce snd_data_tx as one-shot
   // *******************

   if ( z80_read_port_1s && Z80_addr_r[7:0]==IO_DATA[7:0] ) begin  // Z80 is reading PS/2 port
   
      Z80_rData  <= PS2_CHAR ;
      PS2_CHAR   <= 8'b0     ;
      PS2_STAT   <= { 3'b0, PS2_STATUS[2:0], PS2_DAT[7], 1'b0 } ; // Reset PS2_STAT
      
   end
   
   PS2_RDY_r[7:0] <= { PS2_RDY_r[6:0], PS2_RDY } ;
   
   if (PS2_RDY_r[7:0] == 8'b00001111 ) begin   // valid data on PS2_DAT
   
      PS2_CHAR <= PS2_DAT ; // Latch the character into Ps2_char register
      /*
       * PS2_STAT bits:
       * 0   - DATA READY
       * 1   - BREAK CODE
       * 2   - EXTENDED KEYCODE
       * 3   - CAPS LOCK
       * 4   - SHIFT KEY
       * 5-7 - unused
       */
      PS2_STAT <= { 3'b0, PS2_STATUS[2:0], PS2_DAT[7], 1'b1 } ;
      
   end

   if ( z80_read_port_1s && Z80_addr_r[7:0] == IO_STAT[7:0] ) begin     // Read_port 1 clock & keyboard status address
   
      Z80_rData <= PS2_STAT ;
      
   end
   
   if ( z80_read_port_1s && Z80_addr_r[7:0] == FIFO_STAT[7:0] ) begin   // Read_port 1 clock & GPU status
   
      Z80_rData <= GEO_STAT_RD ;
      
   end
   
   if ( z80_read_port_1s && Z80_addr_r[7:0] == WAIT_PORT[7:0] ) begin   // Read_port 1 clock & WAIT_PORT
   
      Z80_rData[7:0] <= WAIT_VAL[7:0] ; // return WAIT_VAL
      
   end
   
   if ( z80_write_port_1s && Z80_addr_r[7:0] == WAIT_PORT ) begin  // Write to WAIT_VAL
   
      WAIT_VAL[7:0] <= Z80_wData_r[7:0] ; // set WAIT_VAL
   
   end
   
   if ( ~Z80_RDn_r ) begin  // this section sets the output enable and sends the correct data back to the Z80
   
      //if (z80_read_opcode) // unused
      
      if ( z80_read_memory && mem_in_bank && memrange[2:0] == 3'b111 && gpu_rd_rdy ) begin // if a valid read memory range and the GPU returns a gpu_rd_rdy, send out data

         WAITbuff   <= gpu_rData ; // pass GPU RAM data to the WAIT buffer
         rd_DAT_rdy <= 1'b1      ; // set read_data_ready flag
         
         // set WAIT_CNT to zero to reset WAIT and return the data on the next clock cycle
         
      end
      
      if ( z80_read_memory && mem_in_bank && memrange[2:0] != 3'b111 ) begin        // memory read outside memory range, but inside the bank.  Return FF.
      
         if ( BANK_RESPONSE && mem_in_ID ) begin
            
            Z80_rData <= BANK_ID[Z80_addr_r[3:0]] ; // return BANK_ID byte
            
         end else begin
         
            Z80_rData <= 8'b11111111              ; // return 0xFF
            
         end
         
         Z80_245data_dir <= data_out ;
         Z80_rData_ena   <= 1'b1     ;
         Z80_245_oe      <= 1'b0     ;
         Z80_WAIT        <= 1'b0     ; // release WAIT line
      
      end
      
      if ( z80_read_port && port_in_range ) begin  // if any read port within range, output the data
      
         Z80_245data_dir <= data_out ;
         Z80_rData_ena   <= 1'b1     ;
         Z80_245_oe      <= 1'b0     ;
         
      end // end read port
      
   end else begin                  // No more read command present, disable sending data on the Z80 bus, ie make GPU Z80 data port an input.
   
      Z80_rData       <= 8'bzzzzzzzz ;
      Z80_245data_dir <= data_in     ;
      Z80_rData_ena   <= 1'b0        ;
      Z80_245_oe      <= 1'b0        ;
      
   end

end // always @(posedge GPU_CLK) begin

endmodule
