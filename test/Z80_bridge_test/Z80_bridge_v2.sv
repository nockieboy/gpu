module Z80_bridge_v2 (

// **** INPUTS ****
   input wire  reset,            // GPU reset signal
   input wire  GPU_CLK,          // GPU clock (125 MHz)
   input wire  Z80_CLK,          // uCom clock signal (8 MHz)
   input wire  Z80_M1n,          // Z80 M1   - active LOW
   input wire  Z80_MREQn,        // Z80 MREQ - active LOW
   input wire  Z80_WRn,          // Z80 WR   - active LOW
   input wire  Z80_RDn,          // Z80 RD   - active LOW
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
   
   // inputs from geo_unit
   input logic [7:0] WR_PX_CTR,  // WRITE PIXEL collision counter from pixel_writer
   input logic [7:0] RD_PX_CTR,  // COPY READ PIXEL collision counter from pixel_writer
   input logic [7:0] GEO_STAT_RD,// bit 0 = scfifo's almost full flag, other bits free for other data

// **** OUTPUTS ****
   output wire Z80_245data_dir,  // Control level converter direction for data flow - HIGH = A->B (toward Z80)
   output wire [7:0]  Z80_rData, // Z80 DATA bus to return data from GPU RAM to Z80
   output wire Z80_rData_ena,    // Flag HIGH to write data back to Z80
   output wire Z80_245_oe,       // OE for 245 level translator *** ACTIVE LOW ***
   output wire gpu_wr_ena,       // Flag HIGH for 1 clock when writing to GPU RAM
   output wire gpu_rd_req,       // Flag HIGH for 1 clock when reading from GPU RAM
   output wire [19:0] gpu_addr,  // Connect to Z80_addr in vid_osd_generator to address GPU RAM
   output wire [7:0] gpu_wdata,  // 8-bit data bus to GPU RAM in vid_osd_generator
   output wire Z80_INT_REQ,      // Flag HIGH to signal to host for an interrupt request
   output wire Z80_IEO,          // Flag HIGH when GPU is requesting an interrupt to pull IEO LOW
   output wire EA_DIR,           // Controls level converter direction for EA address flow - HIGH = A->B (toward FPGA)
   output wire EA_OE,            // OE for EA address level converter *** ACTIVE LOW ***
   output wire SPKR_EN,          // HIGH to enable speaker output
   output wire VIDEO_EN,         // Controls BLANK input on DAC
   output wire snd_data_tx,      // HIGH for 1 clock for valid snd_data
   output wire [8:0] snd_data,   // Data bus to sound module
   
   // outputs to geo_unit
   output logic GEO_WR_LO_STROBE,// HIGH to write low byte to geo unit
   output logic [7:0] GEO_WR_LO, // low byte data for geo unit
   
   output logic GEO_WR_HI_STROBE,// HIGH to write high byte to geo unit
   output logic [7:0] GEO_WR_HI, // high byte data for geo unit - for little-endian input, this will connect to FIFO 'fifo_cmd_ready' input
   
   output logic WR_PX_CTR_STROBE,// HIGH to clear the WRITE PIXEL collision counter
   output logic RD_PX_CTR_STROBE,// HIGH to clear the COPY READ PIXEL collision counter
   output logic GEO_RD_STAT_STROBE, // HIGH when reading data on GEO_STAT_RD bus
   output logic GEO_WR_STAT_STROBE, // HIGH when sending data on GEO_STAT_WR bus
   output logic [7:0] GEO_STAT_WR// data bus out to geo unit
   
);

//
// TODO:
//
// 1) Interrupt handling for keyboard data
//
//
// **************************************** Parameters ***************************************************
//

parameter USE_Z80_CLK          = 1; // use 1 to wait for a Z80 clk input before considering a bus transaction.
parameter INV_Z80_CLK          = 0; // Invert the source Z80 clk when considering a bus transaction.
parameter Z80_CLK_FILTER       = 0; // The number of GPU clock cycles to filter the Z80 bus commands, use 0 through 7.
parameter Z80_CLK_FILTER_P     = 2; // The number of GPU clock cycles to filter the Z80 bus PORT commands, use 0 through 7.

parameter MEMORY_RANGE         = 3'b010;  // Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the uCom)
parameter MEM_SIZE_BYTES       = 40960;   // Specifies maximum size for the GPU RAM (anything above this returns $FF)
parameter BANK_RESPONSE        = 1;       // 1 - respond to reads at BANK_ID_ADDR with appropriate data, 0 - ignore reads to that address
parameter BANK_ID_ADDR         = 15'b111111111111111;      // Address to respond to BANK_ID queries with data (lowest 4 bits left off)
parameter int BANK_ID[16]      = '{9,3,71,80,85,32,69,80,52,67,69,49,48,0,255,255};  // The BANK_ID data to return

reg    Z80_CLKr,Z80_CLKr2;
wire   z80_pclk, z80_nclk, zclk;
assign z80_pclk = (INV_Z80_CLK ?  ( ~Z80_CLKr &&  Z80_CLKr2 ) : (  Z80_CLKr && ~Z80_CLKr2 )) || USE_Z80_CLK==0 ; // isolate the positive Z80 clk transition, invert edge detect if INV_Z80_CLK is used
assign z80_nclk = (INV_Z80_CLK ?  (  Z80_CLKr && ~Z80_CLKr2 ) : ( ~Z80_CLKr &&  Z80_CLKr2 )) || USE_Z80_CLK==0 ; // isolate the negative Z80 clk transition, invert edge detect if INV_Z80_CLK is used
assign zclk     =  z80_pclk || z80_nclk ;

// register bus control inputs with up to a Z80_CLK_FILTER
reg          Z80_M1n_r,          // Z80 M1 - active LOW
             Z80_MREQn_r,        // Z80 MREQ - active LOW
             Z80_WRn_r,          // Z80 WR - active LOW
             Z80_RDn_r,          // Z80 RD - active LOW
             Z80_IORQn_r,        // Z80 IOPORT - active LOW
             Z80_IEI_r;
reg   [21:0] Z80_addr_r;         // uCom 22-bit address bus
reg   [7:0]  Z80_wData_r;        // uCom 8 bit data bus input

reg   [2:0]  z80_read_opcode_fc, // command filter counters.  Counts the GPU clock cycles for a command to be solidly asserted before enable/disable
             z80_read_memory_fc,
             z80_read_port_fc,
             z80_write_memory_fc,
             z80_write_port_fc;
             
reg   [7:0]  PSR_RDY_r;

wire         z80_op_read_opcode, // decoded bus commands
             z80_op_read_memory,
             z80_op_write_memory,
             z80_op_read_port,
             z80_op_write_port;

assign       z80_op_read_opcode     =  ~Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r && ~Z80_RDn_r &&  Z80_WRn_r ; // bus controls for read opcode operation
assign       z80_op_read_memory     =   Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r && ~Z80_RDn_r &&  Z80_WRn_r ; // bus controls for memory RD operation
assign       z80_op_write_memory    =   Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r &&  Z80_RDn_r && ~Z80_WRn_r ; // bus controls for memory WR operation
assign       z80_op_read_port       =   Z80_M1n_r && ~Z80_IORQn_r  &&  Z80_MREQn_r && ~Z80_RDn_r &&  Z80_WRn_r ; // bus controls for IO RD operation
assign       z80_op_write_port      =   Z80_M1n_r && ~Z80_IORQn_r  &&  Z80_MREQn_r &&  Z80_RDn_r && ~Z80_WRn_r ; // bus controls for IO WR operation

reg  z80_read_opcode,
     z80_read_memory,
     z80_read_port,
     z80_write_memory,
     z80_write_port;
reg  last_z80_read_opcode,
     last_z80_read_memory,
     last_z80_read_port,
     last_z80_write_memory,
     last_z80_write_port;
wire z80_read_opcode_1s,   // these wires setup a 1 shot signal at the beginning of the bus transaction
     z80_read_memory_1s,
     z80_read_port_1s,
     z80_write_memory_1s,
     z80_write_port_1s;

// create 1 shots versions of each type of bus transaction cycle
assign z80_read_opcode_1s  = z80_read_opcode  && ~last_z80_read_opcode;
assign z80_read_memory_1s  = z80_read_memory  && ~last_z80_read_memory;
assign z80_read_port_1s    = z80_read_port    && ~last_z80_read_port;
assign z80_write_memory_1s = z80_write_memory && ~last_z80_write_memory;
assign z80_write_port_1s   = z80_write_port   && ~last_z80_write_port;

// Make sure Extended Address bus is always set to 'TO FPGA'
assign EA_DIR = 1'b1;    // Set EA address flow A->B
assign EA_OE  = 1'b0;    // Set EA address output on

// define the GPU ram access window
wire   mem_in_bank;
assign mem_in_bank         = (Z80_addr_r[21:19]==MEMORY_RANGE[2:0]); // Define memory access window (512 KB range)

wire   mem_in_ID;
assign mem_in_ID           = (Z80_addr_r[21:19]==MEMORY_RANGE[2:0]) && (Z80_addr_r[18:4]==BANK_ID_ADDR[14:0]); // Define BANK_ID access window (16 bytes)

wire   mem_in_range;
assign mem_in_range        = (Z80_addr_r[21:19]==MEMORY_RANGE[2:0]) && (Z80_addr_r[18:0] < MEM_SIZE_BYTES[19:0]) ; // Define valid GPU RAM range (GPU RAM + palette RAM)

// define the GPU access ports range
wire   port_in_range;
assign port_in_range       = ((Z80_addr_r[7:0] >= IO_DATA[7:0]) && (Z80_addr_r[7:0] <= IO_BLNK[7:0])) ; // You are better off reserving a range of ports

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
//
// Direction control for DATA BUS level converter
//
parameter bit data_in   = 0;        // 245_DIR for data in
parameter bit data_out  = 1;        // 245_DIR for data out
//
// *******************************************************************************************************
//
reg [7:0] PS2_CHAR   = 8'b0 ;        // Stores value to return when PS2_CHAR IO port is queried
reg [7:0] PS2_STAT   = 8'b0 ;        // Stores value to return when PS2_STATUS IO port is queried
reg PS2_prev         = 1'b0 ;
reg [12:0] port_dly  = 13'b0;       // Port delay pipeline delays data output on an IO port read
reg [7:0] PS2_RDY_r  = 8'b0 ;

always @(posedge GPU_CLK) begin

   // Latch and delay the Z80 CLK input for transition edge processing.
   Z80_CLKr    <= Z80_CLK   ;     // Register delay the Z80_CLK input.
   Z80_CLKr2   <= Z80_CLKr  ;    // Register delay the Z80_CLK input.

   // Latch bus controls and shift them into the filter pipes.
   Z80_M1n_r   <= Z80_M1n   ;  // Z80 M1 - active LOW
   Z80_MREQn_r <= Z80_MREQn ;  // Z80 MREQ - active LOW
   Z80_WRn_r   <= Z80_WRn   ;  // Z80 WR - active LOW
   Z80_RDn_r   <= Z80_RDn   ;  // Z80 RD - active LOW
   Z80_IORQn_r <= Z80_IORQn ;  // Z80 IORQ - active low
   Z80_IEI_r   <= Z80_IEI   ;

   // Latch address and data coming in from Z80.
   Z80_addr_r  <= Z80_addr  ;// uCom 22-bit address bus
   Z80_wData_r <= Z80_wData ;// uCom 8 bit data bus input

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
   last_z80_read_opcode  <= z80_read_opcode;
   last_z80_read_memory  <= z80_read_memory;
   last_z80_read_port    <= z80_read_port;
   last_z80_write_memory <= z80_write_memory;
   last_z80_write_port   <= z80_write_port;

   if ( z80_write_memory_1s && mem_in_bank && mem_in_range ) begin   // pass write request to GPU ram
      gpu_addr   <= Z80_addr_r[19:0];
      gpu_wdata  <= Z80_wData_r;
      gpu_wr_ena <= 1'b1;       // Flag HIGH for 1 clock when reading from GPU RAM
   end else begin
      gpu_wr_ena <= 1'b0;       // Flag HIGH for 1 clock when reading from GPU RAM
   end

   if ( z80_read_memory_1s && mem_in_bank && mem_in_range ) begin    // pass read request to GPU ram
      gpu_addr      <= Z80_addr_r[19:0] ;
      gpu_rd_req    <= 1'b1 ;       // Flag HIGH for 1 clock when reading from GPU RAM
   end else begin
      gpu_rd_req    <= 1'b0 ;       // Flag HIGH for 1 clock when reading from GPU RAM
   end

   if ( z80_write_port_1s && Z80_addr_r[7:0]==SND_OUT ) begin     // Write_port 1 clock & SPEAKER ENABLE address
      SPKR_EN       <= 1'b1 ;
   end else SPKR_EN <= 1'b0 ; // Enforce SPKR_EN as one-shot
   
   if ( z80_write_port_1s && Z80_addr_r[7:0]==SND_DUR ) begin     // Write_port 1 clock & sound module STOP flag address
      snd_data[8]   <= 1'b0 ;    // bit 8 LOW for STOP register
      snd_data[7:0] <= Z80_wData_r[7:0] ;  // data is ignored
      snd_data_tx   <= 1'b1 ;
   end
   
   if ( z80_write_port_1s && Z80_addr_r[7:0]==SND_TON ) begin     // Write_port 1 clock & sound module TONE register address
      snd_data[8]   <= 1'b1 ;    // bit 8 HIGH for TONE register
      snd_data[7:0] <= Z80_wData_r[7:0] ;
      snd_data_tx   <= 1'b1 ;
   end
   
   // **** Manage IO interface to GEOFF ****
   if ( z80_write_port_1s && Z80_addr_r[7:0]==GEO_LO ) begin     // Write to GEOFF low-byte register
      GEO_WR_LO     <= Z80_wData_r[7:0] ;
      GEO_WR_LO_STROBE <= 1'b1 ;                                 // Pulse strobe HIGH to signal to FIFO new data on the bus - wiring to FIFO will decide will STROBE to act upon
   end else GEO_WR_LO_STROBE <= 1'b0 ;
   
   if ( z80_write_port_1s && Z80_addr_r[7:0]==GEO_HI ) begin     // Write to GEOFF high-byte register
      GEO_WR_HI     <= Z80_wData_r[7:0] ;
      GEO_WR_HI_STROBE <= 1'b1 ;								 // Pulse strobe HIGH to signal to FIFO new data on the bus - wiring to FIFO will decide will STROBE to act upon
   end else GEO_WR_HI_STROBE <= 1'b0 ;
   // ***** End of GEOFFs IO interface *****
   
   // **** ONE-SHOTS ****
   if ( snd_data_tx ) snd_data_tx <= 1'b0 ; // Enforce snd_data_tx as one-shot
   // *******************

   if ( z80_read_port_1s && Z80_addr_r[7:0]==IO_DATA[7:0] ) begin  // Z80 is reading PS/2 port
      Z80_rData  <= PS2_CHAR ;
      PS2_CHAR   <= 8'b0 ;
      PS2_STAT   <= 8'b0 ;        // Reset PS2_STAT
   end

   PS2_RDY_r[7:0] <= {PS2_RDY_r[6:0],PS2_RDY};
   
   if (PS2_RDY_r[7:0] == 8'b00001111 ) begin            // valid data on PS2_DAT
      PS2_CHAR   <= PS2_DAT ;                           // Latch the character into Ps2_char register
      PS2_STAT   <= { 6'b0, PS2_DAT[7], 1'b1 } ;        // Set PS2_STAT bit 0 to indicate valid data, with bit 2 HIGH for BREAK codes
   end

   if ( z80_read_port_1s && Z80_addr_r[7:0]==IO_STAT[7:0] ) begin     // Read_port 1 clock & keyboard status address
      Z80_rData  <= PS2_STAT;
   end
   
   if ( ~Z80_RDn_r ) begin  // this section sets the output enable and sends the correct data back to the Z80
      //if (z80_read_opcode) // unused
      if ( z80_read_memory && mem_in_bank && mem_in_range && gpu_rd_rdy ) begin    // if a valid read memory range and the GPU returns a gpu_rd_rdy, send out data
         Z80_rData       <= gpu_rData ;
         Z80_245data_dir <= data_out;
         Z80_rData_ena   <= 1'b1 ;
         Z80_245_oe      <= 1'b0 ;
      end
      if ( z80_read_memory && mem_in_bank && ~mem_in_range ) begin        // memory read outside memory range, but inside the bank.  Return FF.
      if ( BANK_RESPONSE && mem_in_ID ) begin
         Z80_rData       <= BANK_ID[Z80_addr_r[3:0]]; // return BANK_ID byte
      end else begin
         Z80_rData       <= 8'b11111111 ;             // return 0xFF
      end
      Z80_245data_dir <= data_out;
      Z80_rData_ena   <= 1'b1 ;
      Z80_245_oe      <= 1'b0 ;
     end
      if ( z80_read_port && port_in_range ) begin  // if any read port within range, output the data
         //Z80_rData       <= Z80_port_rData ; // data for port reads are set above.
         Z80_245data_dir <= data_out;
         Z80_rData_ena   <= 1'b1 ;
         Z80_245_oe      <= 1'b0 ;
      end // end read port
   end else begin                  // No more read command present, disable sending data on the Z80 bus, ie make GPU Z80 data port an input.
      Z80_rData       <= 8'bzzzzzzzz ;
      Z80_245data_dir <= data_in ;
      Z80_rData_ena   <= 1'b0 ;
      Z80_245_oe      <= 1'b0 ;
   end

end // always @(posedge GPU_CLK) begin

endmodule
