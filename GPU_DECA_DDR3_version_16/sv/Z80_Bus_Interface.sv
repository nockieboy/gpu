/*
 Z80 Bus Peripheral Interface
 Redone by Brian Guralnick.
 
 V1.50, Nov 29, 2021
 Beta new DDR3 interface.
 
  *v1.1 Patched smart async 'WAIT' generator.

 New input and output IO port bus added.
 
*/

module Z80_Bus_Interface #(

// Z80 bus timing settings.
   //parameter bit [3:0]  READ_PORT_CLK_POS     = 2,     // Number of Z80_CLK cycles before the bus interface responds to a Read Port command.
   parameter bit [3:0]  READ_PORT_CLK_sPOS = 0,     // Number of Z80_CLK cycles before the bus interface read strobe pulse outputs.
   parameter bit [3:0]  READ_PORT_CLK_aPOS = 2,     // Number of Z80_CLK cycles before the bus interface read port data is returned.

   parameter bit [3:0]  WRITE_PORT_CLK_POS = 2,     // Number of Z80_CLK cycles before the bus interface samples the Write Port command's data.

// 0 to 7, Number of CMD_CLK cycles to wait for DDR3 read before asserting the WAIT during a Read Memory cycle.
// Use 0 for an instant guaranteed 'WAIT' every read.  (Safest for Read Instruction Opcode cycle.)
// Use 2 for compatibility with waiting for a BrianHG_DDR3 read cache hit before asserting the 'WAIT'.

   parameter bit [2:0]  Z80_DELAY_WAIT_RI  = 0,     // 0 to 7, Number of CMD_CLK cycles to wait for DDR3 read_ready before asserting the WAIT during a Read Instruction Opcode cycle.
   parameter bit [2:0]  Z80_DELAY_WAIT_RM  = 2,     // 0 to 7, Number of CMD_CLK cycles to wait for DDR3 read_ready before asserting the WAIT during a Read Memory cycle.
   parameter bit        Z80_WAIT_QUICK_OFF = 0,     // 0 (Default) = WAIT is turned off only during a low Z80_CLK.  1 = WAIT is turned off as soon as a read_ready is received.

// Direction control for DATA BUS level converter
   parameter bit        data_in            = 0,     // 245_DIR for data in
   parameter bit        data_out           = 1,     // 245_DIR for data out

   parameter            MEMORY_RANGE       = 3'b010, // Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the uCom)
   parameter            MEM_SIZE_BYTES     = 196608, // Specifies maximum size for the GPU RAM (anything above this returns $FF) (Default: 40960)
   parameter            BANK_RESPONSE      = 1,      // 1 - respond to reads at BANK_ID_ADDR with appropriate data, 0 - ignore reads to that address
   parameter            BANK_ID_ADDR       = 15'b111111111111111, // Address to respond to BANK_ID queries with data (lowest 4 bits left off)
   parameter bit [7:0]  BANK_ID     [0:15] = '{9,3,71,80,85,32,69,80,52,67,69,49,48,0,255,255},  // The BANK_ID data to return

// INTerrupt enable and vector
   parameter int        INT_TYP            = 0,     // 0 = polled (IO), 1 = interrupt
   parameter int        INT_VEC            = 'h30,  // INTerrupt VECtor to be passed to host in event of an interrupt acknowledge

// Read IO port addresses range.
   parameter bit [7:0]  READ_PORT_BEGIN    = 56,    // Sets the beginning port number which can be read.
   parameter bit [7:0]  READ_PORT_END      = 251,   // Sets the ending    port number which can be read.
   parameter bit [7:0]  GPU_ML             = 'hFC,
   parameter bit [7:0]  GPU_MH             = 'hFD

)(

// **** System Reset and clock ****
   input  logic         reset,             // System reset signal
   input  logic         CMD_CLK,           // System clock (75-200 MHz)

// **** Z80 BUS ********************
(* useioff = 1 *) input  logic         Z80_CLK,           // Z80 clock signal (8 MHz)
(* useioff = 1 *) input  logic [ 21:0] Z80_ADDR,          // Z80 22-bit address bus
(* useioff = 1 *) input  logic         Z80_M1n,           // Z80 M1   - active LOW
(* useioff = 1 *) input  logic         Z80_IORQn,         // Z80 IORQ - active LOW
(* useioff = 1 *) input  logic         Z80_MREQn,         // Z80 MREQ - active LOW
(* useioff = 1 *) output logic         Z80_WAIT,          // Flag HIGH to pull Z80's WAIT line LOW
(* useioff = 1 *) input  logic         Z80_RDn,           // Z80 RD   - active LOW
(* useioff = 1 *) input  logic         Z80_WRn,           // Z80 WR   - active LOW
   
(* useioff = 1 *) inout  logic [  7:0] Z80_DATA,          // Z80 DATA bus IO

(* useioff = 1 *) input  logic         Z80_IEI,           // if HIGH, Z80_bridge can request interrupt immediately
(* useioff = 1 *) output logic         Z80_INT_REQ,       // Flag HIGH to signal to host for an interrupt request
(* useioff = 1 *) output logic         Z80_IEO,           // Flag HIGH when GPU is requesting an interrupt to pull IEO LOW

// **** bidirectional '245 buffer logic controls.
(* useioff = 1 *) output logic         Z80_245data_dir,   // Control level converter direction for data flow - HIGH = A->B (toward Z80)
(* useioff = 1 *) output logic         Z80_245_oe,        // OE for 245 level translator *** ACTIVE LOW ***

(* useioff = 1 *) output logic         EA_DIR,            // Controls level converter direction for EA address flow - HIGH = A->B (toward FPGA)
(* useioff = 1 *) output logic         EA_OE,             // OE for EA address level converter *** ACTIVE LOW ***


// *********************************
// *** Z80 <-> System RAM Access ***
// *********************************
   input  logic         CMD_busy,          // High when the DDR3 is busy.
   output logic         CMD_ena,           // Flag HIGH for 1 CMD_CLK when sending a DDR3 command
   output logic [31:0]  CMD_addr,          // Z80 requested address.
   output logic         CMD_write_ena,     // Write enable to DDR3 RAM
   output logic  [7:0]  CMD_write_data,    // Data from Z80 to be written into RAM.
   output logic  [0:0]  CMD_write_mask,    // Write data enable mask to RAM.
   input  logic         CMD_read_ready,    // One-shot signal from mux or DDR3_Controller that data is ready
   input  logic  [7:0]  CMD_read_data,     // Read Data from RAM to be sent to Z80.

// ***********************************
// *** Z80 IO Read and Write ports ***
// ***********************************

   output logic [255:0] WRITE_PORT_STROBE          = 0 , // The bit   [port_number] in this 256 bit bus will pulse when the Z80 writes to that port number.
   output logic   [7:0] WRITE_PORT_DATA   [0:255]      , // The array [port_number] will hold the last written data to that port number.
   output logic [255:0] READ_PORT_STROBE           = 0 , // The bit   [port_number] in this 256 bit bus will pulse when the Z80 reads from that port number.
   input  wire    [7:0] READ_PORT_DATA    [0:255]      , // The array [port_number] will be sent to the Z80 during a port read so long as the read port
                                                         // number is within parameter READ_PORT_BEGIN and READ_PORT_END.

    input  logic  [7:0]  RD_PX_CTR,          // COPY READ PIXEL collision counter from pixel_write
    input  logic  [7:0]  WR_PX_CTR,          // WRITE PIXEL collision counter from pixel_writer
    output logic         RD_PX_CTR_STROBE,   // HIGH to clear the COPY READ PIXEL collision counter
    output logic         WR_PX_CTR_STROBE    // HIGH to clear the WRITE PIXEL collision counter

);

// *****************************************************************
// Z80 Unused read port assignments
// *****************************************************************
assign  WR_PX_CTR_STROBE = 0 ; // Default to low to prevent compile warnings about no driver
assign  RD_PX_CTR_STROBE = 0 ; // Default to low to prevent compile warnings about no driver

// *****************************************************************
// **** FPGA Z80 tri-state data IO port.
// *****************************************************************
logic        Z80_fpga_data_oe   = 0 ;                                        // Original output enable for FPGA 8bit data bus.
logic [7:0]  Z80_fpga_data_out  = 0 ;                                        // Original output data from FPGA to Z80.
assign       Z80_DATA = Z80_fpga_data_oe ? Z80_fpga_data_out : 8'bzzzzzzzz ; // New Bidir IO port on Z80_Bus_Peripheral module.
reg          Z80_CLKr,Z80_CLKr2     ;
wire         zclk =  Z80_CLKr ^ Z80_CLKr2 ;
logic [3:0]  Z80_CK_POS = 0         ; // Counter for the Z80 clock position.
// register bus control inputs with up to a Z80_CLK_FILTER
reg          Z80_M1n_r  ,        // Z80 M1 - active LOW
             Z80_MREQn_r,        // Z80 MREQ - active LOW
             Z80_WRn_r  ,        // Z80 WR - active LOW
             Z80_RDn_r  ,        // Z80 RD - active LOW
             Z80_IORQn_r;        // Z80 IOPORT - active LOW
             //Z80_IEI_r;
reg   [21:0] Z80_addr_r ;        // uCom 22-bit address bus
reg   [7:0]  Z80_wData_r;        // uCom 8 bit data bus input
// These wires define the Z80 bus operation.
wire         z80_op_read_opcode  = ~Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r && ~Z80_RDn_r &&  Z80_WRn_r ; // bus controls for read opcode operation
wire         z80_op_read_memory  =  Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r && ~Z80_RDn_r &&  Z80_WRn_r ; // bus controls for memory RD operation
wire         z80_op_write_memory =  Z80_M1n_r &&  Z80_IORQn_r  && ~Z80_MREQn_r &&  Z80_RDn_r && ~Z80_WRn_r ; // bus controls for memory WR operation
wire         z80_op_read_port    =  Z80_M1n_r && ~Z80_IORQn_r  &&  Z80_MREQn_r && ~Z80_RDn_r &&  Z80_WRn_r ; // bus controls for IO RD operation
wire         z80_op_write_port   =  Z80_M1n_r && ~Z80_IORQn_r  &&  Z80_MREQn_r &&  Z80_RDn_r && ~Z80_WRn_r ; // bus controls for IO WR operation
wire         z80_op_nop          =                Z80_IORQn_r  &&  Z80_MREQn_r                             ; // Bus condition when Z80 has reached CK0 (T1) in data sheet.
//
// these wires signal when the Z80 is addressing a port, the last 16-bytes of/or the GPU's 512KB window
// define the GPU ram access window
wire         mem_in_bank         = (Z80_addr_r[21:19] == MEMORY_RANGE[2:0])                 ; // HIGH if accessing GPU memory window (512 KB range) in host memory map
// define the BANK_ID location - this needs to be moved to the start of GPU RAM, otherwise it will corrupt screen memory reads by the host
// (well, 16 bytes of it) if a screen mode is used that requires more than 512KB.
wire         mem_in_ID           = (Z80_addr_r[18:4]  == BANK_ID_ADDR[18:4]) && mem_in_bank && (READ_PORT_DATA[GPU_ML] == 8'b0 && READ_PORT_DATA[GPU_MH] == 8'b0); // Define BANK_ID access window (16 bytes)
// define the GPU access ports range
wire         port_in_range       = ((Z80_addr_r[7:0] >= READ_PORT_BEGIN) && (Z80_addr_r[7:0] <= READ_PORT_END)) ; // You are better off reserving a range of ports

// *******************************************************************************************************
// ************************************ Initial Values ***************************************************
// *******************************************************************************************************
// Make sure Extended Address bus is always set to 'TO FPGA'
assign EA_DIR             = 1'b1 ; // Set EA address flow A->B
assign EA_OE              = 1'b0 ; // Set EA address output on
assign Z80_INT_REQ        = 1'b0 ;
assign Z80_IEO            = 1'b0 ;     

// ********************************************************************************
// Get the read and write memory request out as fast as possible, 0 clock delay.  |
// These 2 may be changed to @(posedge CMD_CLK) to help improve internal FPGA     |
// routing at the expense of delaying the DDR3 memory request by 1 CMD_CLK cycle. |
// ********************************************************************************
logic CMD_R_sent = 0, CMD_W_sent = 0 ;
// DDR3 address bus translation.
assign    CMD_addr[18:0]  = Z80_addr_r[18:0]                                                            ; // Set the read address.
assign    CMD_addr[26:19] = READ_PORT_DATA[GPU_ML]                                                      ; // Lower component of DDR3's extended address (ups the addressable range to 27-bits, or 128MB)
assign    CMD_addr[31:27] = READ_PORT_DATA[GPU_ML][4:0]                                                 ; // Upper component of DDR3's extended address (ups the addressable range to 32-bits, or 4GB)
// DDR3 Write Request.
assign    CMD_write_ena   = ( z80_op_write_memory && mem_in_bank ) && !CMD_busy && !CMD_W_sent          ; // Set the write enable.
assign    CMD_write_data  = Z80_wData_r                                                                 ; // Send write data.
assign    CMD_write_mask  = 1'b1                                                                        ; // Write enable for the byte.
// DDR3 Read Request.
wire      CMD_read_req    = ((z80_op_read_memory || z80_op_read_opcode) && mem_in_bank ) && !CMD_R_sent ;
assign    CMD_ena         = CMD_read_req || CMD_write_ena                                               ; // Set the a read or write request.

// *******************************************************************
// Run the zwait_timer
// Used as a gate to decide whether to drive the
// Z80_WAIT during a read memory, or read instruction op-code.
// *******************************************************************
// The rules used to set enable the 'WAIT'.
// 1. When a read req is sent and the read data is not ready.
// 2. At the beginning of an in-bank Z80_MREQn and the write port's CMD_W_busy is set.  (This one will probably never occur, but, just in case.)
// 3. If wait_IO is asserted due to an IO read that cannot be handled in the Z80's usual IO cycle.
logic wait_IO     = 0 ; // This goes HIGH when WAIT should be asserted due to a slow IO operation.
wire  wait_enable = (CMD_read_req && !CMD_read_ready) || (CMD_busy && mem_in_bank && ~Z80_MREQn_r) || wait_IO ;

// Render a delay pipe containing the 'wait_enable' status.
// Make zwait_timer[0] always set to 1 in case a Z80_DELAY_WAIT_R? of 0 wait time is selected.
logic [7:0] zwait_timer ;
always_ff @(posedge CMD_CLK) begin

    zwait_timer[7:0] <= { zwait_timer[6:1], wait_enable, 1'b1 } ;

end

// Select which filter delay to used based on Z80_M1n fetch op-code signal.
wire wait_filter = Z80_M1n_r ? zwait_timer[Z80_DELAY_WAIT_RM] : zwait_timer[Z80_DELAY_WAIT_RI] ;

// Generate the wait signal as fast as possible, asynchronously.
always_comb begin

    if ( !Z80_CLK || Z80_WAIT_QUICK_OFF )  Z80_WAIT <= (wait_enable && wait_filter)             ; // Allow the Z80_WAIT to be SET and CLEARED while the un-registered Z80_CLK is low.
    else                                   Z80_WAIT <= (wait_enable && wait_filter) || Z80_WAIT ; // Otherwise set and hold Z80_WAIT.

end

// *******************************************************************************
// Z80 sync bus interface.
// *******************************************************************************
always_ff @( posedge CMD_CLK ) begin

    // Latch and delay the Z80 CLK input for transition edge processing.
    Z80_CLKr    <= Z80_CLK   ; // Register delay the Z80_CLK input.
    Z80_CLKr2   <= Z80_CLKr  ; // Register delay the Z80_CLK input.
    // Latch bus controls and shift them into the filter pipes.
    Z80_M1n_r   <= Z80_M1n   ; // Z80 M1 - active LOW
    Z80_MREQn_r <= Z80_MREQn ; // Z80 MREQ - active LOW
    Z80_WRn_r   <= Z80_WRn   ; // Z80 WR - active LOW
    Z80_RDn_r   <= Z80_RDn   ; // Z80 RD - active LOW
    Z80_IORQn_r <= Z80_IORQn ; // Z80 IORQ - active low
    //Z80_IEI_r   <= Z80_IEI   ;
    // Latch address and data coming in from Z80.
    Z80_addr_r  <= Z80_ADDR  ; // uCom 22-bit address bus
    Z80_wData_r <= Z80_DATA  ; // uCom 8 bit data bus input

    if ( reset ) begin

        CMD_R_sent        <= 0            ;
        CMD_W_sent        <= 0            ;
        READ_PORT_STROBE  <= 0            ; // Clear any active strobes
        WRITE_PORT_DATA   <= '{default:0} ; // Set WRITE_PORT_DATA bus to zero
        WRITE_PORT_STROBE <= 0            ; // Clear active strobes
        Z80_CK_POS        <= 0            ; // Reset the bus phase clock counter.
        Z80_245data_dir   <= data_in      ; // Set the 245 to send data from the Z80 to the FPGA.
        Z80_245_oe        <= 1'b1         ; // Disable 245 OE
        Z80_fpga_data_oe  <= 1'b0         ; // set the FPGA Z80_data bidirectional IO port to HI-Z.

    end else begin

        // **************************************************************************************************************************
        // This clock position counter will keep track of which state the Z80 bus is currently positioned.
        // It is required to schedule / delay output timing and to position interrupt requests.
        // **** Note: To keep proper count, it will require a read/input of the 'WAIT' from the Z80 bus so it will
        //            know if other peripheral are pausing the Z80 mid cycle.
        // **************************************************************************************************************************
        if (z80_op_nop) Z80_CK_POS <= 0                      ; // Reset the Z80 clock position counter position
        else if (zclk)  Z80_CK_POS <= Z80_CK_POS + !Z80_WAIT ; // Increment the reference clock position every toggle of the Z80 clock.
        // **************************************************************************************************************************
        
        if (z80_op_nop) begin
        
            Z80_fpga_data_oe    <= 1'b0        ; // set the FPGA Z80_data bidirectional IO port to HI-Z.
            Z80_245data_dir     <= data_in     ; // Set the 245 to send data from the Z80 to the FPGA.
            Z80_245_oe          <= 1'b0        ; // Enable 245 OE.
            CMD_R_sent          <= 0           ;
            CMD_W_sent          <= 0           ;
            READ_PORT_STROBE    <= 0           ; // Clear any active strobes
            WRITE_PORT_STROBE   <= 0           ; // Clear any active strobes

        end else begin // !z80_op_nop

            // ************************************************************
            // *** Read Instruction Opcode
            //     (separate of read memory so we may assign a different delayed 'WAIT' engage parameter.)
            // ************************************************************
            if (z80_op_read_opcode  && mem_in_bank ) begin

                if (CMD_read_ready) begin    // Once the DDR3 is ready.

                    CMD_R_sent        <= 1'b1          ;  // Make a note that the CMD_read_req has been sent so the command doesn't need to run throughout the z80_op_read_opcode
                    Z80_fpga_data_oe  <= 1'b1          ;  // set the FPGA Z80_data bidirectional IO port to output.
                    Z80_245data_dir   <= data_out      ;  // Set the 245 to send data from the Z80 to the FPGA.
                    Z80_245_oe        <= 1'b0          ;  // Enable 245 OE.
                    Z80_fpga_data_out <= CMD_read_data ;  // send data to read port.

                end
            
            // ************************************************************
            // *** Read memory
            //     (separate from read op-code so we may assign a different delayed 'WAIT' engage parameter.)
            // ************************************************************
            end else if ( z80_op_read_memory && mem_in_bank ) begin

                if (CMD_read_ready) begin    // Once the DDR3 is ready.

                    CMD_R_sent       <= 1'b1     ;  // Make a note that the CMD_read_req has been sent so the command doesn't need to run throughout the z80_op_read_memory
                    Z80_fpga_data_oe <= 1'b1     ;  // set the FPGA Z80_data bidirectional IO port to output.
                    Z80_245data_dir  <= data_out ;  // Set the 245 to send data from the Z80 to the FPGA.
                    Z80_245_oe       <= 1'b0     ;  // Enable 245 OE.
            
                    if (BANK_RESPONSE && mem_in_ID )   Z80_fpga_data_out <= BANK_ID[Z80_addr_r[3:0]] ; // Return BANK_ID byte.
                    //else if (!mem_in_range)            Z80_fpga_data_out <= 8'b11111111              ; // Mem in bank, but out of range.
                    else                               Z80_fpga_data_out <= CMD_read_data            ; // Mem in bank and in range, return read data.

                end

            // ************************************************************
            // *** Write memory
            // ************************************************************
            end else if ( z80_op_write_memory && mem_in_bank ) begin
        
                if (CMD_write_ena) CMD_W_sent <= 1'b1    ; // Make a note that the CMD_write_req has been sent so the command doesn't need to run throughout the z80_op_write_memory
                Z80_fpga_data_oe              <= 1'b0    ; // set the FPGA Z80_data bidirectional IO port to HI-Z.
                Z80_245data_dir               <= data_in ; // Set the 245 to send data from the Z80 to the FPGA.
                Z80_245_oe                    <= 1'b0    ; // Enable 245 OE.
        
            /// ************************************************************
            // *** Read port
            // *** This will trigger once on the transition of Z80_CLK
            // *** position READ_PORT_CLK_sPOS.
            // ************************************************************
            end else if ( z80_op_read_port && (Z80_CK_POS==READ_PORT_CLK_sPOS ) && zclk ) begin
       
                if (port_in_range) begin    // Only respond to a port read request if the read port is in range.

                    READ_PORT_STROBE[Z80_addr_r[7:0]] <= 1 ; // Generate the access strobe signal on the requested port number.

                end
       
            // ************************************************************
            // *** Read port
            // *** This will trigger once on the transition of Z80_CLK
            // *** position READ_PORT_CLK_aPOS, the acknowledge position for the read port.
            // ************************************************************
            end else if ( z80_op_read_port && (Z80_CK_POS==READ_PORT_CLK_aPOS ) && zclk ) begin
       
                if (port_in_range) begin    // Only respond to a port read request if the read port is in range.

                    Z80_fpga_data_oe               <= 1'b1     ; // set the FPGA Z80_data bidirectional IO port to output.
                    Z80_245data_dir                <= data_out ; // Set the 245 to send data from the Z80 to the FPGA.
                    Z80_245_oe                     <= 1'b0     ; // Enable 245 OE.
                    Z80_fpga_data_out <= READ_PORT_DATA[Z80_addr_r[7:0]] ; // send data to read port.

                end

            // ************************************************************
            // *** Write port
            // *** This will trigger once on the transition of Z80_CLK
            // *** position WRITE_PORT_CLK_POS.
            // ************************************************************
            end else if ( z80_op_write_port && (Z80_CK_POS==WRITE_PORT_CLK_POS) && zclk ) begin
        
                Z80_fpga_data_oe                   <= 1'b0        ; // set the FPGA Z80_data bidirectional IO port to HI-Z.
                Z80_245data_dir                    <= data_in     ; // Set the 245 to send data from the Z80 to the FPGA.
                Z80_245_oe                         <= 1'b0        ; // Enable 245 OE.
                WRITE_PORT_STROBE[Z80_addr_r[7:0]] <= 1           ; // Generate the access strobe signal on the requested port number.
                WRITE_PORT_DATA  [Z80_addr_r[7:0]] <= Z80_wData_r ;

                

            end else begin
        
                READ_PORT_STROBE  <= 0 ; // Make sure that the generated strobes are only active for 1 clock.
                WRITE_PORT_STROBE <= 0 ; // Make sure that the generated strobes are only active for 1 clock.
                CMD_R_sent        <= 0 ; //
                CMD_W_sent        <= 0 ; //

            end
        
        end // (!z80_op_nop)

    end // (!reset)

end // always @(posedge CMD_CLK) begin

// *******************************************************************************
// Wishbone bus master SM
// *******************************************************************************
/*
always_ff @(posedge CMD_CLK) begin

    if ( reset ) begin

        m_wb_adr_o <= 32'b0   ;
        m_wb_cyc_o <= 1'b0    ;
        m_wb_dat_o <= 32'b0   ;
        m_wb_sel_o <= 4'b0000 ;
        m_wb_stb_o <= 1'b0    ;
        m_wb_we_o  <= 1'b0    ;
        wb_STATE   <= 3'b000  ;
        wb_DATA_IN <= 32'b0   ;
        wb_DAT_RDY <= 1'b0    ;

    end
    else if ( wb_RQ_SEND && wb_STATE == 3'b000 ) begin
        wb_STATE <= 3'b001 ;
    end
    else if ( READ_PORT_STROBE[SD_DATA] && wb_STATE == 3'b000 ) begin
        wb_STATE <= 3'b101 ;
    end
    else begin

        case ( wb_STATE )

            // **********************************
            // ********** WRITE CYCLE ***********
            // **********************************
            3'b001 : begin  // WRITE COMMAND
                m_wb_adr_o <= SD_ADDRESS ; // pass the address of the required register
                m_wb_cyc_o <= 1'b1       ; //
                m_wb_dat_o <= SD_COMMAND ; // pass the COMMAND word
                m_wb_sel_o <= 4'b1111    ; // all banks in 32-bit array are valid
                m_wb_stb_o <= 1'b1       ; //
                m_wb_we_o  <= 1'b1       ; //
                wb_STATE   <= 3'b010     ; // set SM to next step
            end

            3'b010 : begin // WAIT FOR SLAVE ACK BEFORE SENDING ARGUMENT
                if ( m_wb_ack_i ) begin // this will be infinite loop if slave doesn't ACK
                    m_wb_cyc_o <= 1'b0   ; // end cycle
                    m_wb_stb_o <= 1'b0   ;
                    wb_STATE   <= 3'b011 ; 
                end
            end

            // If SD_ADDRESS is 4, the argument will be written to the ARGUMENT register
            // and sent to the SD card, otherwise it will be written to the interface
            // register specified by SD_ADDRESS.
            3'b011 : begin // WRITE ARGUMENT
                if ( SD_ADDRESS == 8'h04 ) begin
                    m_wb_adr_o <= 8'b0       ; // address the ARGUMENT register
                end
                else begin
                    m_wb_adr_o <= SD_ADDRESS ; // address the desired register
                end
                m_wb_cyc_o <= 1'b1        ; // 
                m_wb_dat_o <= SD_ARGUMENT ; // pass the ARGUMENT word
                m_wb_sel_o <= 4'b1111     ; // all banks in 32-bit array are valid
                m_wb_stb_o <= 1'b1        ; // 
                m_wb_we_o  <= 1'b1        ; // 
                wb_STATE   <= 3'b100      ; // set SM to next step
            end

            3'b100 : begin // WAIT FOR SLAVE ACK BEFORE RETURNING TO IDLE
                if ( m_wb_ack_i ) begin     // this will be infinite loop if slave doesn't ACK
                    m_wb_adr_o <= 32'b0   ;
                    m_wb_cyc_o <= 1'b0    ;
                    m_wb_dat_o <= 32'b0   ;
                    m_wb_sel_o <= 4'b0000 ;
                    m_wb_stb_o <= 1'b0    ;
                    m_wb_we_o  <= 1'b0    ;
                    wb_STATE   <= 3'b000  ;
                end
            end

            // **********************************
            // ********** READ CYCLE ************
            // **********************************
            3'b101 : begin // READ COMMAND
                m_wb_adr_o <= SD_ADDRESS ; // pass the address of the required register
                m_wb_cyc_o <= 1'b1       ; //
                m_wb_dat_o <= 0          ; // null COMMAND word
                m_wb_sel_o <= 4'b1111    ; // all banks in 32-bit array are valid
                m_wb_stb_o <= 1'b1       ; //
                m_wb_we_o  <= 1'b0       ; // Ensure WE_O is low to indicate a READ
                wb_STATE   <= 3'b110     ; // set SM to next step
            end

            3'b110 : begin // WAIT FOR SLAVE ACK BEFORE RETURNING TO IDLE
                if ( m_wb_ack_i ) begin // this will be infinite loop if slave doesn't ACK
                    m_wb_cyc_o <= 1'b0       ; // end cycle
                    m_wb_stb_o <= 1'b0       ; //
                    wb_DATA_IN <= m_wb_dat_i ; // latch data from m_wb_dat_i
                    wb_DAT_RDY <= 1'b1       ; // signal that read data is ready
                    wb_STATE   <= 3'b000     ; // reset state machine
                end
            end

            default : begin // IDLE
                m_wb_adr_o <= 32'b0   ;
                m_wb_cyc_o <= 1'b0    ;
                m_wb_dat_o <= 32'b0   ;
                m_wb_sel_o <= 4'b0000 ;
                m_wb_stb_o <= 1'b0    ;
                m_wb_we_o  <= 1'b0    ;
                wb_DAT_RDY <= 1'b0    ;
            end

        endcase

    end

end */

endmodule
