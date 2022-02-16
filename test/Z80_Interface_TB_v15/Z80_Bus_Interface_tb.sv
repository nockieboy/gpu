//************************************************************************************************************************************************************
//
// Z80_Bus_Interface_tb.sv -> Tests a simulated Z80 driving the Z80_Bus_Interface.sv
//
// v1.10, October 10, 2021.
//
// *v1.1 Patched smart async 'WAIT' generator.
//
// Simulates a Z80 performing
//   Read Instruction Op-code.
//   Read memory
//   Write Memory
//   Read Port
//   Write Port
//
//   Monitors an active high 'Z80_WAIT' input and adapts
//   the clock cycles accordingly.
//
// Written by Brian Guralnick.
// For public use.
//
// Leave Z80 GPU questions in  https://www.eevblog.com/forum/fpga/fpga-vga-controller-for-8-bit-computer/
//
//
// Instructions:
//
// Open ModelSim 20.x
// Select ' File / Change Directory ' -> 'Z80_Interface_TB'
// 
// In transcript, type:
// do setup_z80.do
//
// Every time you edit code or ascii script and you want to re-run the simulation, type:
// do run_z80.do
//
// Ascii file 'Z80_cmd_stimulus.txt' allows you to enter Z80 commands to be simulated.
//
//
//************************************************************************************************************************************************************
//************************************************************************************************************************************************************
//************************************************************************************************************************************************************
`timescale 1 ps/ 1 ps // 1 picosecond steps, 1 picosecond precision.

module Z80_Bus_Interface_tb #(

parameter int        Z80_SPEED_GRADE         = 8,                // Set which Z80 speed grade CPU, 4/6/8/10/20.
parameter int        Z80_MHZ                 = 8,                // Set the Z80_CLK oscillator frequency in MHz.
parameter int        FPGA_IO_tsu             = 5,                // Set the number of nanoseconds which the FPGA takes to output and return data.
                                                                 // This setting only effects the sample period and placement of the special xxx_sh markers
                                                                 // for viewing in the waveform window.

parameter int        CMD_CLK_MHZ             = 125,              // Set the FPGA internal GPU/DDR3 command CLK frequency.

parameter int        dummy_read_delay        = 0                 // Used the delay the generated dummy read data.

)(

// **** Z80 simulator IO pins.
inout logic        Z80_RSTn     ,
inout logic        Z80_CLK      ,
inout logic [15:0] Z80_ADDR     ,
inout logic        Z80_M1       ,
inout logic        Z80_MREQ     ,
inout logic        Z80_IORQ     ,
inout logic        Z80_WAIT     ,
inout logic        Z80_wait_sh  , // Special marker which shows you where and for how long the wait needs to remain a valid. 
inout logic        Z80_RD       ,
inout logic        Z80_WR       ,
inout logic  [7:0] Z80_DATA     ,
inout logic        Z80_read_sh  , // Special marker which shows you where and for how long the read data needs to remain a valid. 
inout logic        Z80_INT      ,
inout logic        Z80_NMI      ,
inout logic        Z80_REFRESH  ,
inout logic        Z80_BUSREQ   ,
inout logic        Z80_BUSACK   ,
inout logic        Z80_HALT     ,


// **** FPGA internal core signals
output logic       reset         ,
output logic       CMD_CLK     

);

// These logic latches feed the INOUT ports
logic        lZ80_RSTn     = 0 ;
logic        lZ80_CLK      = 0 ;
logic [15:0] lZ80_ADDR     = 0 ;
logic        lZ80_M1       = 0 ;
logic        lZ80_MREQ     = 0 ;
logic        lZ80_IORQ     = 0 ;
logic        lZ80_WAIT     = 1'bz ;
logic        lZ80_wait_sh  = 1'bz ; // Special marker which shows you where and for how long the wait needs to remain a valid. 
logic        lZ80_RD       = 0 ;
logic        lZ80_WR       = 0 ;
logic  [7:0] lZ80_DATA     = 8'bzzzzzzzz ;
logic        lZ80_read_sh  = 1'bz ; // Special marker which shows you where and for how long the read data needs to remain a valid. 
logic        lZ80_INT      = 0 ;
logic        lZ80_NMI      = 0 ;
logic        lZ80_REFRESH  = 0 ;
logic        lZ80_BUSREQ   = 0 ;
logic        lZ80_BUSACK   = 0 ;
logic        lZ80_HALT     = 0 ;

// These logic latches are used for setting the next transition time position since the last Z80_CLK relative to $time-time_offset.
logic [15:0] nZ80_ADDR     = 0 ;
logic  [7:0] nZ80_DATA     = 8'bzzzzzzzz ;

assign Z80_RSTn     = lZ80_RSTn     ;
assign Z80_CLK      = lZ80_CLK      ;
assign Z80_ADDR     = lZ80_ADDR     ;
assign Z80_M1       = lZ80_M1       ;
assign Z80_MREQ     = lZ80_MREQ     ;
assign Z80_IORQ     = lZ80_IORQ     ;
assign Z80_WAIT     = lZ80_WAIT     ;
assign Z80_wait_sh  = lZ80_wait_sh  ;
assign Z80_RD       = lZ80_RD       ;
assign Z80_WR       = lZ80_WR       ;
assign Z80_DATA     = lZ80_DATA     ;
assign Z80_read_sh  = lZ80_read_sh  ;
assign Z80_INT      = lZ80_INT      ;
assign Z80_NMI      = lZ80_NMI      ;
assign Z80_REFRESH  = lZ80_REFRESH  ;
assign Z80_BUSREQ   = lZ80_BUSREQ   ;
assign Z80_BUSACK   = lZ80_BUSACK   ;
assign Z80_HALT     = lZ80_HALT     ;






// **** DDR3 port
logic        CMD_busy       = 0 ;
logic        CMD_ena            ;
logic [31:0] CMD_addr           ;
logic        CMD_write_ena      ;
logic  [7:0] CMD_write_data     ;
logic  [0:0] CMD_write_mask     ;
logic        CMD_read_ready = 0 ;
logic  [7:0] CMD_read_data  = 0 ;

logic  [7:0] DUMMY_DATA     = 0 ;
logic [63:0] read_ready     = 0 ;


logic        video_en       ;
logic  [7:0] key_stat       ;
logic  [7:0] key_dat        ;
logic        PS2_DAT_RDY    ;
logic        SP_EN          ;
logic        snd_data_tx    ;
logic  [8:0] snd_data       ;
logic        send_geo_cmd   ;
logic [15:0] geo_cmd        ;
logic  [7:0] geo_stat_rd        = 0 ;
logic        geo_stat_rd_strobe     ;
logic  [7:0] collision_rd   ;
logic  [7:0] collision_wr   ;
logic        rd_px_ctr_rs   ;
logic        wr_px_ctr_rs   ;



// ***************************************************************************************************************
// ***************************************************************************************************************
// *** Z80 Core timing ************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************

localparam  zp = 500000 / Z80_MHZ ; //1/2 Z80_CLK period in picoseconds

// ***************************************************************************************************************
// ***************************************************************************************************************
// *** Z80 Bridge ************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
Z80_Bus_Interface #(

// Z80 bus timing settings.
   .READ_PORT_CLK_POS     ( 2       ), // Number of Z80_CLK cycles before the bus interface responds to a Read Port command.
   .WRITE_PORT_CLK_POS    ( 2       ), // Number of Z80_CLK cycles before the bus interface samples the Write Port command's data.

// 0 to 7, Number of CMD_CLK cycles to wait for DDR3 read before asserting the WAIT during a Read Memory cycle.
// Use 0 for an instant guaranteed 'WAIT' every read.  (Safest for Read Instruction Opcode cycle.)
// Use 2 for compatibility with waiting for a BrianHG_DDR3 read cache hit before asserting the 'WAIT'.

   .Z80_DELAY_WAIT_RI     ( 0       ), // 0 to 7, Number of CMD_CLK cycles to wait for DDR3 read_ready before asserting the WAIT during a Read Instruction Opcode cycle.
   .Z80_DELAY_WAIT_RM     ( 2       ), // 0 to 7, Number of CMD_CLK cycles to wait for DDR3 read_ready before asserting the WAIT during a Read Memory cycle.
   .Z80_WAIT_QUICK_OFF    ( 0       ), // 0 (Default) = WAIT is turned off only during a low Z80_CLK.  1 = WAIT is turned off as soon as a read_ready is received.

// Direction control for DATA BUS level converter
   .data_in               ( 1'b0    ), // Direction controls for 74LVC245 buffers - hardware dependent!
   .data_out              ( 1'b1    ), // Direction controls for 74LVC245 buffers - hardware dependent!

// GPU access settings.
   .BANK_ID               ( '{9,3,71,80,85,32,77,65,88,49,48,0,255,255,255,255} ),  // The BANK_ID data to return ('GPU MAX10')
   .BANK_ID_ADDR          ( 17'b10111111111111111 ),                                // Address to return BANK_ID data from
   .BANK_RESPONSE         ( 1       ), // 1 - respond to reads at BANK_ID_ADDR with BANK_ID data, 0 - ignore reads to that address
   .MEM_SIZE_BYTES        ( 32767   ), // Specifies size of GPU RAM available to host (anything above this returns $FF)
   .MEMORY_RANGE          ( 3'b000  ), // Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the uCom)
   .INT_TYP               ( 0       ), // 0 = polled (IO), 1 = interrupt.
   .INT_VEC               ( 48      ), // INTerrupt VECtor to be passed to host in event of an interrupt acknowledge.


// Read IO port addresses range.
   .READ_PORT_BEGIN       ( 240     ), // Sets the beginning port number which can be read.
   .READ_PORT_END         ( 249     ), // Sets the ending    port number which can be read.

// ************** Legacy IO port addresses. *********** Move outside Z80 bus interface with the new port bus.
   .IO_DATA               ( 240     ), // IO address for keyboard data polling.
   .IO_STAT               ( 241     ), // IO address for keyboard status polling.
   .SND_OUT               ( 242     ), // IO address for speaker/audio output enable.
   .IO_BLNK               ( 243     ), // IO address for BLANK signal to video DAC.
   .SND_TON               ( 244     ), // IO address for TONE register in sound module.
   .SND_DUR               ( 245     ), // IO address for DURATION register in sound module.
   .GEO_LO                ( 246     ), // IO address for GEOFF LOW byte.
   .GEO_HI                ( 247     ), // IO address for GEOFF HIGH byte.
   .FIFO_STAT             ( 248     )  // IO address for GPU FIFO status on bit 0 - remaining bits free for other data.
// ************** Legacy IO port addresses. *********** Move outside Z80 bus interface with the new port bus.

) Z80_BRIDGE (

   // ***********************************
   // *** Core System Clock and Reset ***
   // ***********************************
   .CMD_CLK           ( CMD_CLK        ), // System clock (75-200 MHz)
   .reset             ( reset          ), // System reset signal

   // ***********************************
   // *** Z80 bus control connections ***
   // ***********************************
   .Z80_CLK           ( Z80_CLK        ), // Z80 host's clock signal (8 MHz default).
   .Z80_ADDR          ( 22'(Z80_ADDR)  ), // Z80 address bus (22-bit).

   .Z80_M1n           ( Z80_M1         ), // Z80 M1 goes LOW with MREQ to signal Z80 Machine Cycle 1 (opcode fetch).
                                          // Z80 M1 goes LOW with IORQ to signal an interrupt acknowledge (INTACK).
   .Z80_IORQn         ( Z80_IORQ       ), // Z80 IORQ goes LOW when Z80 is performing an IO operation.
   .Z80_MREQn         ( Z80_MREQ       ), // Z80 MREQ goes LOW when Z80 is performing a memory operation.
   .Z80_WAIT          ( Z80_WAIT       ), // Active HIGH, signals to Z80 to WAIT.
   .Z80_RDn           ( Z80_RD         ), // Z80 RD goes LOW to signal a Z80 ReaD operation.
   .Z80_WRn           ( Z80_WR         ), // Z80 WR goes LOW when Z80 is performing a WRite operation.

   .Z80_DATA          ( Z80_DATA       ), // Data from GPU FPGA to Z80.

   .Z80_IEI           ( IEI            ), // NOT USED, Z80 INTerrupt daisy chain input - active LOW, prevents Z80_bridge from raising an INTerrupt request.
   .Z80_INT_REQ       ( Z80_INT_RQ     ), // Active HIGH, signals to Z80 an INTerrupt request.
   .Z80_IEO           ( IEO            ), // NOT USED, Active LOW, prevents devices further down the daisy chain from requesting INTerrupts.


   // *** Z80 bidir data bus and bus steering connections. ***

   .Z80_245data_dir   ( DIR_245        ), // Controls direction of the Z80 data bus buffer.
   .Z80_245_oe        ( OE_245         ), // Enable/disable signal for Z80 data bus buffer.

   // *** Extended Address (EA) bus steering connections ***
   .EA_DIR            ( EA_DIR         ), // Controls direction of the EA bus buffer.
   .EA_OE             ( EA_OE          ), // Enable/disable signal for EA bus buffer.
                                          // The EA bus direction control should default to Z80 > FPGA direction.
                                          // These controls are present for a future FPGA MMU to replace the hardware MMU on the memory card, or
                                          // for EA bus control by an optional FPGA CPU core.
   

   // *********************************
   // *** Z80 <-> System RAM Access ***
   // *********************************
   .CMD_busy          ( CMD_busy       ), // High when a write req is not allowed to take place.
   .CMD_ena           ( CMD_ena        ), // High when a write req is not allowed to take place.
   .CMD_addr          ( CMD_addr       ), // Z80 requested write address.
   .CMD_write_ena     ( CMD_write_ena  ), // Flag HIGH for 1 CMD_CLK when writing to RAM
   .CMD_write_data    ( CMD_write_data ), // Data from Z80 to be written into RAM.
   .CMD_write_mask    ( CMD_write_mask ), // Write data enable mask to RAM.
   .CMD_read_ready    ( CMD_read_ready ), // One-shot signal from mux or DDR3_Controller that data is ready
   .CMD_read_data     ( CMD_read_data  ), // Read Data from RAM to be sent to Z80.


   // *******************************
   // *** Z80 peripheral IO ports ***
   // *******************************

   .WRITE_PORT_STROBE  (               ), // The bit   [port_number] in this 256 bit bus will pulse when the Z80 writes to that port number.
   .WRITE_PORT_DATA    (               ), // The array [port_number] will hold the last written data to that port number.
   .READ_PORT_STROBE   (               ), // The bit   [port_number] in this 256 bit bus will pulse when the Z80 reads from that port number.

// until the legacy ports are moved out, this port needs cannot be used.
//   .READ_PORT_DATA     (               ), // The array [port_number] will be sent to the Z80 during a port read so long as the read port
                                          // number is within parameter READ_PORT_BEGIN and READ_PORT_END.



// ***************************************************************************************************
// ***************************************************************************************************
// ***************************************************************************************************
// **** Legacy Peripheral IO ports. 
// ***************************************************************************************************
// ***************************************************************************************************
// ***************************************************************************************************

   // *** Enable/Disable video output port.
   .VIDEO_EN          ( video_en       ), // Active HIGH, enables video output.

   // *** PS2 keyboard IO.
   .PS2_STATUS        ( key_stat       ), // 8-bit PS/2 STATUS bus.
   .PS2_DAT           ( key_dat        ), // Keycode/ASCII data bus from the PS/2 terminal.
   .PS2_RDY           ( PS2_DAT_RDY    ), // Active HIGH, signals Z80_bridge valid data is available from the PS/2 keyboard interface.

   // *** Speaker
   .SPKR_EN           ( SP_EN          ), // Active HIGH, enables sound output via the sound module.
   .snd_data_tx       ( snd_data_tx    ), // Active HIGH, signals sound module that valid data is available on the snd_data bus.
   .snd_data          ( snd_data       ), // 8-bit data bus to the sound module.

   // 2D accelerated Geometry unit IO access.
   .GEO_STAT_RD        ( geo_stat_rd        ), // 8-bit data_mux_geo STATUS bus.  bit 0 = scfifo-almost-full flag, other bits free for other data.
   .GEO_STAT_RD_STROBE ( geo_stat_rd_strobe ), // Strobe when read port occurs.
   //.GEO_STAT_WR       ( geo_stat_wr    ), // Bit 0 is used to soft-reset the geometry unit.

   .GEO_WR_HI_STROBE  ( send_geo_cmd   ), // Active HIGH, signals GEOFF that valid 16-bit data is available on geo_cmd bus.
   .GEO_WR_LO_STROBE  (                ), // Active HIGH, signals GEOFF that valid 16-bit data is available on geo_cmd bus.
   .GEO_WR_HI         ( geo_cmd[15:8]  ), // MSB in geo_cmd bus.
   .GEO_WR_LO         ( geo_cmd[7:0]   ), // LSB in geo_cmd bus.

   .RD_PX_CTR         ( collision_rd   ), // COPY READ PIXEL collision counter from pixel_writer.
   .WR_PX_CTR         ( collision_wr   ), // WRITE PIXEL     collision counter from pixel_writer.
   .RD_PX_CTR_STROBE  ( rd_px_ctr_rs   ), // Active HIGH, signals GEOFF to reset READ PIXEL  collision counter.
   .WR_PX_CTR_STROBE  ( wr_px_ctr_rs   )  // Active HIGH, signals GEOFF to reset WRITE PIXEL collision counter.

);



// ********************************************************************************************
// Test bench IO logic.
// ********************************************************************************************
localparam             period_cmd = 1000000/CMD_CLK_MHZ    ;  // Set the CMD_CLK period timing.
string     TB_COMMAND_SCRIPT_FILE = "Z80_cmd_stimulus.txt" ;  // Choose one of the following strings...
string                Script_CMD  = "*** POWER_UP ***"     ;  // Message line in waveform
logic [12:0]          Script_LINE = 0  ;                      // Message line in waveform

localparam string  Z80_CKS_str [0:31] = '{" T1 ","    "," T2 ","    "," T3 ","    "," T4 ","    ",   // This string is for displaying the Z80 clock position.
                                          "TWxx","    "," TW ","    ","TWxx","    ","TWxx","    ",
                                          "TWax","    "," TWA","    ","TWax","    ","TWax","    ",
                                          "TWax","    ","TWA+","    ","TWax","    ","Tnop","    " };
string                  Z80_CKS           = "    ";  // Default blank.
logic           [5:0]   Z80_CKS_pos       = 0 ;
logic unsigned  [31:0]  zaddr;
logic unsigned  [7:0]   zdata;

logic       [7:0]            WDT_COUNTER;                                                       // Wait for 15 clocks or inactivity before forcing a simulation stop.
logic                        WAIT_IDLE        = 0;                                              // When high, insert a idle wait before every command.
localparam int               WDT_RESET_TIME   = 255;                                            // Set the WDT timeout clock cycles.
localparam int               SYS_IDLE_TIME    = WDT_RESET_TIME-64;                              // Consider system idle after 12 clocks of inactivity.
localparam real              DDR3_CK_MHZ_REAL = CMD_CLK_MHZ ;                                   // Generate the DDR3 CK clock frequency.
localparam real              DDR3_CK_pERIOD   = 1000 / CMD_CLK_MHZ ;                            // Generate the DDR3 CK period in nanoseconds.

logic                        MASTER_BUSY ;  // Single flag which goes high whenever anything happens or the system is in reset.


initial begin
WDT_COUNTER       = WDT_RESET_TIME  ; // Set the initial inactivity timer to maximum so that the code later-on wont immediately stop the simulation.
MASTER_BUSY       = 0 ;

reset    = 1'b1 ; // Reset input
CMD_CLK  = 1'b0 ;
lZ80_CLK = 1'b0 ;
#(50000);
reset    = 1'b0 ; // Release reset at 50ns.

op_z80 ( "nop", 16'h0000, 8'h00 );


while (reset) @(negedge CMD_CLK);
execute_ascii_file(TB_COMMAND_SCRIPT_FILE);
end


always_comb                 Z80_CKS     = Z80_CKS_str[((Z80_CKS_pos-1)<<1)+(lZ80_CLK==0)];                 // Generate the waveform display string for the Z80 clock cycle position
always #(zp)                lZ80_CLK    = !lZ80_CLK;                                              // create source clock oscillator

always #(period_cmd/2)      CMD_CLK     = !CMD_CLK;                                               // create source clock oscillator
always @(posedge CMD_CLK)   WDT_COUNTER = (MASTER_BUSY) ? WDT_RESET_TIME : (WDT_COUNTER-1'b1) ;   // Setup a simulation inactivity watchdog countdown timer.
always @(posedge CMD_CLK) if (WDT_COUNTER==0) begin
                                             Script_CMD  = "*** WDT_STOP ***" ;
                                             $stop;                                               // Automatically stop the simulation if the inactivity timer reaches 0.
                                             end

// *********  Generate a dummy read return data

always  @(posedge CMD_CLK) begin

    read_ready[63:0] <= {read_ready[62:0],(CMD_ena && !CMD_write_ena)}; // Generate a data pipe to delay the read request.
    CMD_read_ready   <= read_ready[dummy_read_delay] ;   // parameter select the delayed read request.
    CMD_read_data    <= 8'(Script_LINE) ;                // pass the script line number to the read dummy data.
    geo_stat_rd      <= 8'(Script_LINE) ;                // pass the script line number to the read dummy data.
end



// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
// task execute_ascii_file(<"source ASCII file name">);
// 
// Opens the ASCII file and scans for the '@' symbol.
// After each '@' symbol, a string is read as a command function.
// Each function then goes through a 'case(command_in)' which then executes the appropriate function.
//
// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************

task execute_ascii_file(string source_file_name);
 begin
    integer fin_pointer,fout_pointer,fin_running,r;
    string  command_in,message_string,destination_file_name,bmp_file_name;

    byte    unsigned    char        ;
    byte    unsigned    draw_color  ;
    integer unsigned    line_number ;

    line_number  = 1;
    fout_pointer = 0;

    fin_pointer= $fopen(source_file_name, "r");
    if (fin_pointer==0)
    begin
       $display("Could not open file '%s' for reading",source_file_name);
       $stop;     
    end

while (fin_pointer!=0 && ! $feof(fin_pointer)) begin // Continue processing until the end of the source file.

  char = 0;
  while (char != "@" && ! $feof(fin_pointer) && fin_pointer!=0 ) begin // scan for the @ character until end of source file.
  char = $fgetc(fin_pointer);
  if (char==0 || fin_pointer==0 )  $stop;                               // something went wrong
  if (char==10) line_number = line_number + 1;       // increment the internal source file line counter.
  end


if (! $feof(fin_pointer) ) begin  // if not end of source file retrieve command string

  r = $fscanf(fin_pointer,"%s",command_in); // Read in the command string after the @ character.
  if (fout_pointer!=0) $fwrite(fout_pointer,"Line#%d, ",13'(line_number)); // :pg the executed command line number.

  case (command_in) // select command string.

  "CMD"        : begin
                 tx_z80_cmd(fin_pointer, fout_pointer, line_number);
                 end

  "RESET"      : begin
                 Script_LINE = line_number;
                 Script_CMD  = command_in;
                 send_rst();                                          // pulses the reset signal for 1 clock.
                 if (fout_pointer!=0) $fwrite(fout_pointer,"Sending a reset to the Z80_bus module.\n");
                 end

  "WAIT_SEQ_READY" : begin
                 Script_LINE = line_number;
                 Script_CMD  = command_in;
                 wait_rdy();                                          // pulses the reset signal for 1 clock.
                 if (fout_pointer!=0) $fwrite(fout_pointer,"Waiting for the Z80_bus module to become ready.\n");
                 end

  "LOG_FILE"   : begin                                                  // begin logging the results.
                   if (fout_pointer==0) begin
                   r = $fscanf(fin_pointer,"%s",destination_file_name); // Read file name for the log file
                     fout_pointer= $fopen(destination_file_name,"w");   // Open that file name for writing.
                     if (fout_pointer==0) begin
                          $display("\nCould not open log file '%s' for writing.\n",destination_file_name);
                          $stop;
                     end else begin
                     $fwrite(fout_pointer,"Log file requested in '%s' at line#%d.\n\n",source_file_name,13'(line_number));
                     end
                   end else begin
                     $sformat(message_string,"\n*** Error in command script at line #%d.\n    You cannot open a LOG_FILE since the current log file '%s' is already running.\n    You must first '@END_LOG_FILE' if you wish to open a new log file.\n",13'(line_number),destination_file_name);
                     $display("%s",message_string);
                     $fclose(fin_pointer);
                     if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
                     if (fout_pointer!=0) $fclose(fout_pointer);
                     $stop;
                   end
                 end

  "END_LOG_FILE" : if (fout_pointer!=0)begin                           // Stop logging the commands and close the current log file.
                       $sformat(message_string,"@%s command at line number %d.\n",command_in,13'(line_number));
                       $display("%s",message_string);
                       $fwrite(fout_pointer,"%s",message_string);
                       $fclose(fout_pointer);
                       fout_pointer = 0;
                   end

  "STOP"       :  begin // force a temporary stop.
                  $sformat(message_string,"@%s command at line number %d.\nType 'Run -All' to continue.",command_in,13'(line_number));
                  $display("%s",message_string);
                  if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
                  $stop;
                  end

  "END"        :  begin // force seek to the end of the source file.

                 op_z80 ( "nop", 16'h0000, 8'h00 );
                 wait_idle();

                  $sformat(message_string,"@%s command at line number %d.\n",command_in,13'(line_number));
                  $display("%s",message_string);
                  $fclose(fin_pointer);
                  if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
                  fin_pointer = 0;
                  end

  default      :  begin // Unknown command
                  $sformat(message_string,"Source ASCII file '%s' has an unknown command '@%s' at line number %d.\nProcessign stopped due to error.\n",source_file_name,command_in,13'(line_number));
                  $display("%s",message_string);
                  if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
                  $stop;
                  end
  endcase

end // if !end of source file

end// while not eof


// Finished reading source file.  Close files and stop.
while ((WDT_COUNTER >= SYS_IDLE_TIME )) @(negedge CMD_CLK); // wait for busy to clear
Script_CMD  = "*** END of script file. ***" ;

$sformat(message_string,"\nEnd of command source ASCII file '%s'.\n%d lines processed.\n",source_file_name,13'(line_number));
$display("%s",message_string);
$fclose(fin_pointer);
if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
if (fout_pointer!=0) $fclose(fout_pointer);
fin_pointer  = 0;
fout_pointer = 0;
end
endtask





// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
// task send_rst();
// 
// sends a reset.
//
// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
task send_rst();
begin
@(negedge Z80_CLK); 
reset = 1;
@(negedge Z80_CLK); 
@(negedge Z80_CLK); 
@(negedge Z80_CLK); 
reset = 0;

@(negedge Z80_CLK); // Re-sync to lZ80_CLK.

wait_rdy();

end
endtask

// ***********************************************************************************************************
// task wait_rdy();
// Wait for DUT_GEOFF input buffer ready.
// ***********************************************************************************************************
task wait_rdy();
begin
  //while (SEQ_BUSY_t) @(negedge CMD_CLK); // wait for busy to clear
  //while (MASTER_BUSY || !DDR3_READY || RST_OUT) @(negedge CMD_CLK); // wait for busy to clear with toggle style interface
end
endtask


// ***********************************************************************************************************
// task wait_idle();
// ***********************************************************************************************************
task wait_idle();
begin
Script_CMD = "Waiting for last command to finish.";
  while (WDT_COUNTER > SYS_IDLE_TIME) @(negedge CMD_CLK); // wait for busy to clear
  WDT_COUNTER          = WDT_RESET_TIME ; // Reset the watchdog timer.
end
endtask


// ***********************************************************************************************************
// task tx_DDR3_cmd(integer src, integer dest, integer ln);
// tx the DDR3 command.
// ***********************************************************************************************************
task tx_z80_cmd(integer src, integer dest, integer ln);
begin

   integer unsigned                         r;//,faddr,fvect;
   string                                   cmd,msg;

  //while (WAIT_IDLE && (WDT_COUNTER > SYS_IDLE_TIME)) @(negedge CMD_CLK); // wait for busy to clear

   r = $fscanf(src,"%s",cmd);                      // retrieve which shape to draw

$timeformat (-9, 1, " ns", 1);

case (cmd)

   "RM","rm" : begin // Z80 will Read Memory Data from bus
 
                r = $fscanf(src,"%h",zaddr); // retrieve the DDR Bank # and ADDRESS command.

                @(posedge Z80_CLK); // Synchronize waveform display text with function

                $sformat(msg,"Begin Read memory address (%h).",zaddr); // Create the log and waveform message.
                //if (dest!=0) $fwrite(dest,"%m: at time %t INFO: %s",$time,msg);
                $display("%m: at time %t INFO: %s",$time,msg);
                 Script_LINE = ln;
                 Script_CMD  = msg;

                op_z80 ( "rm", zaddr, 8'bzzzzzzzz ) ;

                $sformat(msg,"Read memory address (%h) returns data (%h).",zaddr,zdata); // Create the log and waveform message.
                if (dest!=0) $fwrite(dest,"%m: at time %t INFO: %s",$time,msg);
                $display ("%m: at time %t INFO: %s",$time,msg);
                 Script_LINE = ln;
                 Script_CMD  = msg;

                end

   "WM","wm" : begin // Z80 will Write Memory data to bus
 
                r = $fscanf(src,"%h%h",zaddr,zdata); // retrieve the DDR Bank # and ADDRESS command.

                @(posedge Z80_CLK); // Synchronize waveform display text with function

                $sformat(msg,"Write memory address (%h) with data (%h).",zaddr,zdata); // Create the log and waveform message.
                if (dest!=0) $fwrite(dest,"%m: at time %t INFO: %s",$time,msg);
                $display("%m: at time %t INFO: %s",$time,msg);
                 Script_LINE = ln;
                 Script_CMD  = msg;

                op_z80 ( "wm", zaddr, zdata ) ;


                end

   "RI","ri" : begin // Z80 will Read Instruction Opcode Memory from bus
 
                r = $fscanf(src,"%h",zaddr); // retrieve the DDR Bank # and ADDRESS command.

                @(posedge Z80_CLK); // Synchronize waveform display text with function

                $sformat(msg,"Begin Read Instruction Opcode memory address (%h).",zaddr); // Create the log and waveform message.
                //if (dest!=0) $fwrite(dest,"%m: at time %t INFO: %s",$time,msg);
                $display("%m: at time %t INFO: %s",$time,msg);
                 Script_LINE = ln;
                 Script_CMD  = msg;

                op_z80 ( "ri", zaddr, 8'bzzzzzzzz ) ;

                $sformat(msg,"Read Instruction Opcode memory address (%h) returns data (%h).",zaddr,zdata); // Create the log and waveform message.
                if (dest!=0) $fwrite(dest,"%m: at time %t INFO: %s",$time,msg);
                $display ("%m: at time %t INFO: %s",$time,msg);
                 Script_LINE = ln;
                 Script_CMD  = msg;

                end

   "RP","rp" : begin // Z80 will Read from a port
 
                r = $fscanf(src,"%h",zaddr); // retrieve the DDR Bank # and ADDRESS command.
                zaddr = { 8'd0,zaddr[7:0] }; // Trim address to 8 bits.

                @(posedge Z80_CLK); // Synchronize waveform display text with function

                $sformat(msg,"Begin Read IO port (%h).",zaddr); // Create the log and waveform message.
                //if (dest!=0) $fwrite(dest,"%m: at time %t INFO: %s",$time,msg);
                $display("%m: at time %t INFO: %s",$time,msg);
                 Script_LINE = ln;
                 Script_CMD  = msg;

                op_z80 ( "rp", zaddr, 8'bzzzzzzzz ) ;

                $sformat(msg,"Read IO port (%h) returns data (%h).",zaddr,zdata); // Create the log and waveform message.
                if (dest!=0) $fwrite(dest,"%m: at time %t INFO: %s",$time,msg);
                $display ("%m: at time %t INFO: %s",$time,msg);
                 Script_LINE = ln;
                 Script_CMD  = msg;

                end

   "WP","wp" : begin // Z80 will rite to a port
 
                r = $fscanf(src,"%h%h",zaddr,zdata); // retrieve the DDR Bank # and ADDRESS command.
                zaddr = { 8'd0,zaddr[7:0] }; // Trim address to 8 bits.

                @(posedge Z80_CLK); // Synchronize waveform display text with function

                $sformat(msg,"Write IO port (%h) with data (%h).",zaddr,zdata); // Create the log and waveform message.
                if (dest!=0) $fwrite(dest,"%m: at time %t INFO: %s",$time,msg);
                $display("%m: at time %t INFO: %s",$time,msg);
                 Script_LINE = ln;
                 Script_CMD  = msg;

                op_z80 ( "wp", zaddr, zdata ) ;
                end



   default : begin
                wait_rdy();
                 while ((WDT_COUNTER > SYS_IDLE_TIME)) @(negedge CMD_CLK); // wait for busy to clear
                 
                  $sformat(msg,"Unknown CMD '%s' at line number %d.\nProcessign stopped due to error.\n",cmd,13'(ln));
                  $display("%s",msg);
                  while ((WDT_COUNTER >= 2 )) @(negedge CMD_CLK); // wait for busy to clear
                  if (dest!=0) $fwrite(dest,"%s",msg);
                  @(negedge CMD_CLK);
                  $stop;

                end


endcase

if (dest!=0) $fwrite(dest,"\n"); // Add a carriage return.

end
endtask




// ***********************************************************************************************************
// ***********************************************************************************************************
// **** Simulate Output of a Z80
// ***********************************************************************************************************
// ***********************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// *** Z80 Core timing ************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
int etc [0:63]  ;

localparam  int zsg    = ( Z80_SPEED_GRADE == 4  ) ? 0 :     // LUT to select which Z80 speed grade to use.
                         ( Z80_SPEED_GRADE == 6  ) ? 1 :
                         ( Z80_SPEED_GRADE == 8  ) ? 2 :
                         ( Z80_SPEED_GRADE == 10 ) ? 3 :
                         ( Z80_SPEED_GRADE == 20 ) ? 4 : 0 ;


// Timings found in Zilog Z8400/Z84C00 NMOS/CMOS Z80 CPU Product Specification data sheet.
//                                      4 MHz,  6 MHz,  8 MHz, 10 MHz, 20 MHz
localparam  int  tc6        [0:4] = '{ 110000,  90000,  80000,  65000,  57000}; // TdCr(A)
localparam  int  tc8        [0:4] = '{  85000,  70000,  60000,  55000,  40000}; // TdCf(MREQf)
localparam  int  tc9        [0:4] = '{  85000,  70000,  60000,  55000,  40000}; // TdCr(MREQr)
localparam  int  tc10       [0:4] = '{ 110000,  65000,  45000,  30000,  10000}; // TwMREQl
localparam  int  tc12       [0:4] = '{  85000,  70000,  60000,  55000,  40000}; // TdCf(MREQr)
localparam  int  tc13       [0:4] = '{  95000,  80000,  70000,  65000,  40000}; // TdCf(RDf)
localparam  int  tc14       [0:4] = '{  85000,  70000,  60000,  55000,  40000}; // TdCr(RDr)
localparam  int  tc15       [0:4] = '{  35000,  30000,  30000,  25000,  12000}; // TsD(Cr)
localparam  int  tc19       [0:4] = '{ 100000,  80000,  70000,  65000,  45000}; // TdCr(M1f)
localparam  int  tc20       [0:4] = '{ 100000,  80000,  70000,  65000,  45000}; // TdCr(M1r)
localparam  int  tc21       [0:4] = '{ 130000, 110000,  95000,  80000,  60000}; // TdCr(RFSHf)
localparam  int  tc22       [0:4] = '{ 120000, 100000,  85000,  80000,  60000}; // TdCr(RFSHr)
localparam  int  tc23       [0:4] = '{  85000,  70000,  60000,  55000,  40000}; // TdCf(RDr)
localparam  int  tc24       [0:4] = '{  85000,  70000,  60000,  55000,  40000}; // TdCr(RDf)
localparam  int  tc27       [0:4] = '{  75000,  65000,  55000,  50000,  40000}; // TdCr(IORQf)
localparam  int  tc28       [0:4] = '{  85000,  70000,  60000,  55000,  40000}; // TdCr(IORQr)
localparam  int  tc30       [0:4] = '{  80000,  70000,  60000,  55000,  40000}; // TdCf(WRf)
localparam  int  tc32       [0:4] = '{  80000,  70000,  60000,  55000,  40000}; // TdCf(WRr)
localparam  int  tc34       [0:4] = '{  65000,  60000,  60000,  50000,  40000}; // TdCr(WRf)
localparam  int  tc42       [0:4] = '{  90000,  80000,  70000,  65000,  40000}; // TdCr(Dz)
localparam  int  tc53       [0:4] = '{ 150000, 130000, 115000, 110000,  75000}; // TdCf(D)

localparam  int  tc17       [0:4] = '{  70000,  60000,  50000,  20000,   7500}; // TsWAIT(Cf)
localparam  int  tc18       [0:4] = '{  10000,  10000,  10000,  10000,  10000}; // ThWAIT(Cf)

localparam  int  tc25       [0:4] = '{  50000,  40000,  30000,  25000,   1200}; // TsD(Cf)
localparam  int  tc16       [0:4] = '{      0,      0,      0,      0,      0}; // ThD(RDr) add off of tc23


task op_z80 ( string tx_func, logic [15:0] tx_addr, logic [7:0] tx_data );
begin

    case (tx_func)
        "nop" : begin // ***** NOP
                                          MASTER_BUSY  =  1 ; // Clear simulation timeout watchdog timer
                                          //@(posedge Z80_CLK);
                                          Z80_CKS_pos   =  16 ;

                                          lZ80_ADDR     =  16'bxxxxxxxxxxxxxxxx;
                                          lZ80_DATA     =  8'bxxxxxxxx ;

                                          lZ80_RSTn     =  1       ;
                                          lZ80_M1       =  1       ;
                                          lZ80_MREQ     =  1       ;
                                          lZ80_IORQ     =  1       ;
                                          lZ80_wait_sh  =  1'bz    ;
                                          lZ80_RD       =  1       ;
                                          lZ80_WR       =  1       ;
                                          lZ80_read_sh  =  1'bz    ;
                                          lZ80_REFRESH  =  1       ;
                                          lZ80_BUSACK   =  1       ;
                                          lZ80_HALT     =  1       ;

                                          etc[6]        =  tc6[zsg]  + $time ;                          // Time until the Z80_data bus goes HI-Z
                                          //etc[42]       =  tc42[zsg] + $time ;                          // Time until the Z80_data bus address is valid.

                                          @(negedge Z80_CLK);

                                          MASTER_BUSY  =  0 ; // Allow simulation timeout watchdog timer.

                end

        "wm" : begin  // ***** WRITE MEMORY
                                          MASTER_BUSY  =  1 ; // Clear simulation timeout watchdog timer
                                          //@(posedge Z80_CLK);
                                          Z80_CKS_pos   =  1 ;

                                          lZ80_ADDR     =  16'bxxxxxxxxxxxxxxxx;

                                          nZ80_ADDR     =  tx_addr;
                                          nZ80_DATA     =  tx_data ;

                                          etc[6]        =  tc6[zsg]  + $time ;                          // Time until the Z80_ADDR becomes valid.
                                          etc[42]       =  tc42[zsg] + $time ;                          // Time until the Z80_data bus becomes HI-Z.
                                          etc[8]        =  tc8 [zsg] + $time + zp ;                     // Time until the Z80_MREQ goes low.

                                          etc[53]       =  tc53[zsg] + $time + zp ;                     // Time until the Z80 output data is valid.  +zp means wait for the falling clock

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  2 ;

                                          etc[17]       =  $time + zp - tc17[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the 'WAIT' input.
                                          etc[18]       =  tc18[zsg] + $time + zp - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the 'WAIT' input.
                                          
                                          etc[30]       =  tc30[zsg] + $time + zp ;                      // Time until the Z80_WR goes low.

                                          @(negedge Z80_CLK);
                                          op_zwait();   // ************************************* Wait for Z80_WAIT signal

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  3 ;

                                          etc[12]       =  tc12[zsg] + $time + zp ;                      // Time until the Z80_MREQ goes high.
                                          etc[32]       =  tc32[zsg] + $time + zp ;                      // Time until the Z80_WR   goes high.
                                          etc[23]       =  tc23[zsg] + $time + zp ;                      // Time until the Z80_RD   goes high.

                                          @(negedge Z80_CLK); // Z80_CKS_pos   =  5 ;

                                          MASTER_BUSY  =  0 ; // Allow simulation timeout watchdog timer.

                end

        "rm" : begin  // ***** READ MEMORY
                                          MASTER_BUSY  =  1 ; // Clear simulation timeout watchdog timer
                                          //@(posedge Z80_CLK);
                                          Z80_CKS_pos   =  1 ;

                                          lZ80_ADDR     =  16'bxxxxxxxxxxxxxxxx;

                                          nZ80_ADDR     =  tx_addr;
                                          nZ80_DATA     =  tx_data ;

                                          etc[6]        =  tc6[zsg]  + $time ;                          // Time until the Z80_ADDR becomes valid.
                                          etc[42]       =  tc42[zsg] + $time ;                          // Time until the Z80_data bus becomes HI-Z.
                                          etc[8]        =  tc8 [zsg] + $time + zp ;                     // Time until the Z80_MREQ goes low.
                                          etc[13]       =  tc13[zsg] + $time + zp ;                     // Time until the Z80_RD   goes low.

                                          //etc[53]       =  tc53[zsg] + $time + zp ;                     // Time until the Z80 output data is valid.  +zp means wait for the falling clock

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  2 ;

                                          etc[17]       =  $time + zp - tc17[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the 'WAIT' input.
                                          etc[18]       =  tc18[zsg] + $time + zp - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the 'WAIT' input.
                                          
                                          //etc[30]       =  tc30[zsg] + $time + zp ;                      // Time until the Z80_WR goes low.

                                          @(negedge Z80_CLK);
                                          op_zwait();   // ************************************* Wait for Z80_WAIT signal

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  3 ;

                                          etc[12]       =  tc12[zsg] + $time + zp ;                      // Time until the Z80_MREQ goes high.
                                          etc[32]       =  tc32[zsg] + $time + zp ;                      // Time until the Z80_WR   goes high.
                                          etc[23]       =  tc23[zsg] + $time + zp ;                      // Time until the Z80_RD   goes high.

                                          etc[25]       =  $time + zp - tc25[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the Z80_DATA input.
                                          etc[16]       =  tc16[zsg] +  etc[23]   - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the Z80_DATA input.


                                          @(negedge Z80_CLK); // Z80_CKS_pos   =  5 ;

                                          zdata         =  Z80_DATA ;                                    // Sample the data from the Z80_bus_Interface read ram.

                                          MASTER_BUSY  =  0 ; // Allow simulation timeout watchdog timer.

                end



        "ri" : begin  // ***** READ INSTRUCTION OPCODE MEMORY
                                          MASTER_BUSY  =  1 ; // Clear simulation timeout watchdog timer
                                          //@(posedge Z80_CLK);
                                          Z80_CKS_pos   =  1 ;

                                          lZ80_ADDR     =  16'bxxxxxxxxxxxxxxxx;

                                          nZ80_ADDR     =  tx_addr;
                                          nZ80_DATA     =  tx_data ;

                                          etc[6]        =  tc6 [zsg] + $time ;                          // Time until the Z80_ADDR becomes valid.
                                          etc[42]       =  tc42[zsg] + $time ;                          // Time until the Z80_data bus becomes HI-Z.
                                          etc[19]       =  tc19[zsg] + $time ;                          // Time until the Z80_M1   goes low.
                                          etc[8]        =  tc8 [zsg] + $time + zp ;                     // Time until the Z80_MREQ goes low.
                                          etc[13]       =  tc13[zsg] + $time + zp ;                     // Time until the Z80_RD   goes low.

                                          //etc[53]       =  tc53[zsg] + $time + zp ;                     // Time until the Z80 output data is valid.  +zp means wait for the falling clock

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  2 ;

                                          etc[17]       =  $time + zp - tc17[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the 'WAIT' input.
                                          etc[18]       =  tc18[zsg] + $time + zp - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the 'WAIT' input.
                                          
                                          //etc[30]       =  tc30[zsg] + $time + zp ;                      // Time until the Z80_WR goes low.


                                          @(negedge Z80_CLK);
                                          op_zwait();   // ************************************* Wait for Z80_WAIT signal

                                          etc[15]       =  $time + zp - tc15[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the Z80_DATA input.



                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  3 ;

                                          nZ80_ADDR     =  16'bxxxxxxxxxxxxxxxx;                        // This will be the refresh address, viewed red.
                                          etc[6]        =  tc6 [zsg] + $time ;                          // Time until the Z80_ADDR becomes valid.

                                          etc[9]        =  tc9 [zsg] + $time  ;                          // Time until the Z80_MREQ goes high.
                                          etc[10]       =  tc10[zsg] + etc[9] ;                          // Time until the Z80_MREQ goes low.


                                          etc[32]       =  tc32[zsg] + $time + zp ;                      // Time until the Z80_WR   goes high.
                                          etc[14]       =  tc14[zsg] + $time ;                           // Time until the Z80_RD   goes high.

                                          etc[16]       =  tc16[zsg] +  etc[14]   - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the Z80_DATA input.

                                          etc[20]       =  tc20[zsg] + $time ;                           // Time until the Z80_M1   goes high.

                                          etc[21]       =  tc21[zsg] + $time ;                           // Time until the Z80_RFSH goes low.

                                          zdata         =  Z80_DATA ;                                    // Sample the data from the Z80_bus_Interface read ram.

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  4 ;

                                          etc[12]       =  tc12[zsg] + $time + zp ;                     // Time until the Z80_MREQ goes high.


                                          @(negedge Z80_CLK); // Z80_CKS_pos   =  7 ;

                                          etc[22]       =  tc22[zsg] + $time + zp ;                     // Time until the Z80_RFSH goes high.

                                          MASTER_BUSY  =  0 ; // Allow simulation timeout watchdog timer.

                end


        "rp" : begin  // ***** READ PORT
                                          MASTER_BUSY  =  1 ; // Clear simulation timeout watchdog timer
                                          //@(posedge Z80_CLK);
                                          Z80_CKS_pos   =  1 ;

                                          lZ80_ADDR     =  16'bxxxxxxxxxxxxxxxx;

                                          nZ80_ADDR     =  tx_addr;
                                          nZ80_DATA     =  tx_data ;

                                          etc[6]        =  tc6[zsg]  + $time ;                          // Time until the Z80_ADDR becomes valid.
                                          etc[42]       =  tc42[zsg] + $time ;                          // Time until the Z80_data bus becomes HI-Z.
                                          //etc[8]        =  tc8 [zsg] + $time + zp ;                     // Time until the Z80_MREQ goes low.
                                          //etc[13]       =  tc13[zsg] + $time + zp ;                     // Time until the Z80_RD   goes low.

                                          //etc[53]       =  tc53[zsg] + $time + zp ;                     // Time until the Z80 output data is valid.  +zp means wait for the falling clock

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  2 ;

                                          etc[27]       =  tc27[zsg] + $time ;                          // Time until the Z80_IORQ goes low.
                                          etc[24]       =  tc24[zsg] + $time ;                          // Time until the Z80_RD   goes low.


                                          etc[17]       =  $time + zp - tc17[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the 'WAIT' input.
                                          etc[18]       =  tc18[zsg] + $time + zp - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the 'WAIT' input.
                                          
                                          //etc[30]       =  tc30[zsg] + $time + zp ;                    // Time until the Z80_WR goes low.

                                          @(negedge Z80_CLK);
                                          op_zwait();   // ************************************* Wait for Z80_WAIT signal

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  2 + 8 ; // Show TWA
                                          etc[17]       =  $time + zp - tc17[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the 'WAIT' input.
                                          etc[18]       =  tc18[zsg] + $time + zp - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the 'WAIT' input.



                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  3 ;

                                          etc[12]       =  tc12[zsg] + $time + zp ;                      // Time until the Z80_MREQ goes high.
                                          etc[32]       =  tc32[zsg] + $time + zp ;                      // Time until the Z80_WR   goes high.
                                          etc[23]       =  tc23[zsg] + $time + zp ;                      // Time until the Z80_RD   goes high.
                                          etc[28]       =  tc27[zsg] + $time + zp ;                     // Time until the Z80_IORQ goes low.

                                          etc[25]       =  $time + zp - tc25[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the Z80_DATA input.
                                          etc[16]       =  tc16[zsg] +  etc[23]   - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the Z80_DATA input.


                                          @(negedge Z80_CLK); // Z80_CKS_pos   =  5 ;

                                          zdata         =  Z80_DATA ;                                    // Sample the data from the Z80_bus_Interface read ram.

                                          MASTER_BUSY  =  0 ; // Allow simulation timeout watchdog timer.

                end


        "wp" : begin  // ***** WRITE PORT
                                          MASTER_BUSY  =  1 ; // Clear simulation timeout watchdog timer
                                          //@(posedge Z80_CLK);
                                          Z80_CKS_pos   =  1 ;

                                          lZ80_ADDR     =  16'bxxxxxxxxxxxxxxxx;

                                          nZ80_ADDR     =  tx_addr;
                                          nZ80_DATA     =  tx_data ;

                                          etc[6]        =  tc6[zsg]  + $time ;                          // Time until the Z80_ADDR becomes valid.
                                          etc[42]       =  tc42[zsg] + $time ;                          // Time until the Z80_data bus becomes HI-Z.
                                          //etc[8]        =  tc8 [zsg] + $time + zp ;                     // Time until the Z80_MREQ goes low.
                                          //etc[13]       =  tc13[zsg] + $time + zp ;                     // Time until the Z80_RD   goes low.

                                          etc[53]       =  tc53[zsg] + $time + zp ;                     // Time until the Z80 output data is valid.  +zp means wait for the falling clock

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  2 ;

                                          etc[27]       =  tc27[zsg] + $time      ;                     // Time until the Z80_IORQ goes low.
                                          //etc[24]       =  tc24[zsg] + $time      ;                     // Time until the Z80_RD   goes low.
                                          etc[34]       =  tc34[zsg] + $time      ;                    // Time until the Z80_WR goes low.

                                          etc[17]       =  $time + zp - tc17[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the 'WAIT' input.
                                          etc[18]       =  tc18[zsg] + $time + zp - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the 'WAIT' input.
                                          
                                          @(negedge Z80_CLK);
                                          op_zwait();   // ************************************* Wait for Z80_WAIT signal

                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  2 + 8 ; // Show TWA
                                          etc[17]       =  $time + zp - tc17[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the 'WAIT' input.
                                          etc[18]       =  tc18[zsg] + $time + zp - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the 'WAIT' input.



                                          @(posedge Z80_CLK);
                                          Z80_CKS_pos   =  3 ;

                                          etc[12]       =  tc12[zsg] + $time + zp ;                      // Time until the Z80_MREQ goes high.
                                          etc[23]       =  tc23[zsg] + $time + zp ;                      // Time until the Z80_RD   goes high.
                                          etc[28]       =  tc27[zsg] + $time + zp ;                      // Time until the Z80_IORQ goes low.
                                          etc[32]       =  tc32[zsg] + $time + zp ;                      // Time until the Z80_WR   goes high.

                                          //etc[25]       =  $time + zp - tc25[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the Z80_DATA input.
                                          //etc[16]       =  tc16[zsg] +  etc[23]   - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the Z80_DATA input.


                                          @(negedge Z80_CLK); // Z80_CKS_pos   =  5 ;

                                          zdata         =  Z80_DATA ;                                    // Sample the data from the Z80_bus_Interface read ram.

                                          MASTER_BUSY  =  0 ; // Allow simulation timeout watchdog timer.

                end


    endcase

end
endtask


task op_zwait () ;
begin
    while (Z80_WAIT) begin
    @(posedge Z80_CLK);
    Z80_CKS_pos   =  2 + 4;

    etc[17]       =  $time + zp - tc17[zsg] - (FPGA_IO_tsu*1000) ; // Setup time for sampling the 'WAIT' input.
    etc[18]       =  tc18[zsg] + $time + zp - (FPGA_IO_tsu*1000) ; // Hold  time for sampling the 'WAIT' input.

    @(negedge Z80_CLK);
    end
end
endtask



always #(100) begin

if (($time/100)==(etc[ 6]/100)) lZ80_ADDR       = nZ80_ADDR ;
if (($time/100)==(etc[42]/100)) lZ80_DATA       = 8'bzzzzzzzz ;
if (($time/100)==(etc[53]/100)) lZ80_DATA       = nZ80_DATA ;

if (($time/100)==(etc[27]/100)) lZ80_IORQ       = 0 ;
if (($time/100)==(etc[28]/100)) lZ80_IORQ       = 1 ;
if (($time/100)==(etc[ 8]/100)) lZ80_MREQ       = 0 ;
if (($time/100)==(etc[10]/100)) lZ80_MREQ       = 0 ;
if (($time/100)==(etc[ 9]/100)) lZ80_MREQ       = 1 ;
if (($time/100)==(etc[12]/100)) lZ80_MREQ       = 1 ;
if (($time/100)==(etc[30]/100)) lZ80_WR         = 0 ;
if (($time/100)==(etc[34]/100)) lZ80_WR         = 0 ;
if (($time/100)==(etc[32]/100)) lZ80_WR         = 1 ;
if (($time/100)==(etc[13]/100)) lZ80_RD         = 0 ;
if (($time/100)==(etc[24]/100)) lZ80_RD         = 0 ;
if (($time/100)==(etc[14]/100)) lZ80_RD         = 1 ;
if (($time/100)==(etc[23]/100)) lZ80_RD         = 1 ;
if (($time/100)==(etc[19]/100)) lZ80_M1         = 0 ;
if (($time/100)==(etc[20]/100)) lZ80_M1         = 1 ;
if (($time/100)==(etc[21]/100)) lZ80_REFRESH    = 0 ;
if (($time/100)==(etc[22]/100)) lZ80_REFRESH    = 1 ;

if (($time/100)==(etc[17]/100)) lZ80_wait_sh    = 1'bx ; // Make the waveform red  as a visual aid.
if (($time/100)==(etc[18]/100)) lZ80_wait_sh    = 1'bz ; // Make the waveform blue as a visual aid.

if (($time/100)==(etc[25]/100)) lZ80_read_sh    = 1'bx ; // Make the waveform red as a visual aid.
if (($time/100)==(etc[15]/100)) lZ80_read_sh    = 1'bx ; // Make the waveform red as a visual aid.
if (($time/100)==(etc[16]/100)) lZ80_read_sh    = 1'bz ; // Make the waveform blue as a visual aid.

end

endmodule
