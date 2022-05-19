// SD Interface v0.2
//
// by nockieboy, November 2021-22
//
// Connects the SD modules to the rest of the GPU.
//
// TODO: Handle write requests to the SD card.

module SDInterface #(
    parameter int          CLK_DIV     = 3,      // clock divider
    parameter int          BUFFER_ADDR = 'h5000, // default DDR3 buffer location
    parameter bit  [  1:0] OP_INIT     = 0,
    parameter bit  [  1:0] OP_READ     = 1,
    parameter bit  [  1:0] OP_WRITE    = 2
)(
    input  logic           CLK,            // 100MHz system clock
    input  logic           RESET,          // reset active HIGH
    // interface <-> Bridgette
    input  logic           ENABLE,         // HIGH for RD/WR request
    input  logic   [  1:0] MODE,           // 0 = INIT, 1 = READ, 2 = WRITE
    input  logic   [ 31:0] SECTOR,         // sector number to read/write
    output logic           WR_DONE,        // HIGH when write is complete
    output logic           SD_BUSY,        // HIGH when interface is busy
    output logic   [  3:0] SIDSTATE,       // current state machine value
    output logic   [  1:0] CARDTYPE,       // SD card type
    output logic           BUSY,           // HIGH when SDInterface is busy
    output logic   [  7:0] SD_STATUS,      // aggregated SD RD status byte of above 4 outputs
    // SD phy connections
    inout  logic   [  3:0] SD_DATA,        // data from SDReader.sv
    inout                  SD_CMD,         // CMD signal to SDReader.sv
    output logic           SD_CLK,         // clock signal to SD card
    output logic           SD_CMD_DIR,     // HIGH = TO SD card, LOW = FROM SD card
    output logic           SD_D0_DIR,      // HIGH = TO SD card, LOW = FROM SD card
    output logic           SD_D123_DIR,    // HIGH = TO SD card, LOW = FROM SD card
    output logic           SD_SEL,         // SD select
    // DDR3 connections
    //    input  (DDR3 -> SD WR ops)
    input  logic           DDR3_busy,      // HIGH when DDR3 is busy
    input  logic           DDR3_rd_rdy,    // data from DDR3 is ready
    input  logic   [127:0] DDR3_rd_data,   // read data from DDR3
    //    output (SD -> DDR3 RD ops)
    output logic    [31:0] DDR3_addr_o,
    output logic           DDR3_ena,       // Flag HIGH for 1 CMD_CLK when sending a DDR3 command
    output logic           DDR3_wr_ena,    // HIGH signals write request to DDR3 Controller
    output logic   [127:0] DDR3_wr_data,   // 128-bit data bus
    output logic    [15:0] DDR3_wr_mask    // Write data enable mask
);

// data IO for read and write data, to connect to buffer
wire    [1:0] cardtype    ;
wire          CMD_rd_req  ; // pulses HIGH to initiate DDR3 read
wire    [3:0] sd_state    ;
wire          DDR3_rd_ena ;
wire          cache_wren  ;
wire    [3:0] wr_ptr      ; // pointer to current byte in cache
wire          crc_ok      ;

wire          rd_sd_clk,  rd_cmd_in,  rd_cmd_oe,  cmd_out, rd_req, ini_req, rd_ready ;
wire          wr_sd_clk,  wr_cmd_in,  wr_cmd_oe,  wr_cmd_out,  wr_req, byte_req ;
wire          rd_sd_data, rd_cmd_dir, rd_d0_dir,  rd_d123_dir, rd_sel, sdr_busy ;
wire          wr_sd_data, wr_cmd_dir, wr_d0_dir,  wr_d123_dir, wr_sel, sdw_busy ;

logic         end_wr_op, first_row, lbl, wstart, wstarted ;
logic         CMD_R_sent ; // HIGH when a RD request to DDR3 has been made
logic         DDR3_req   ; // HIGH for one clock to trigger DDR3 memory transaction
logic         last_cache ; // HIGH when last 16 bytes of SD buffer are being written to SD card
logic         rdrdy_flag ; // toggles HIGH when RD_RDY pulses high
logic         wr_done    ; // toggles HIGH when wdone pulses high
logic         ini_op     ; // toggles HIGH when INI taking place
logic         rd_op      ; // toggles HIGH when RD taking place
logic         wr_op      ; // toggles HIGH when WR taking place
logic         cache_mpty ; // HIGH when 16-byte cache is empty (WR ops)
logic         cache_full ; // HIGH when 16-byte cache is full  (RD ops)
logic         rEna       ; // HIGH whilst rData is being sent
logic [  1:0] start      ;
logic [  3:0] data_ptr   ; // pointer to current byte in cache
logic [  7:0] SD_dat     ; // byte read from SDReader to write to DDR3 buffer
logic [  7:0] wr_dat     ; // byte to send to SDWriter
logic [  8:0] buf_ptr    ; // 512-byte buffer address pointer
logic [127:0] data_cache ; // temporary 16-byte storage to be written to DDR3 or SD

//                          7         6-5         4        3       2      1       0
assign SD_STATUS    = { rdrdy_flag, cardtype, sdw_busy, wr_done, crc_ok, 1'b0, SD_BUSY } ;
assign CARDTYPE     = cardtype                     ;
assign SIDSTATE     = sd_state                     ;
// DDR3 Read Request
assign DDR3_rd_ena  = DDR3_req && cache_mpty && !DDR3_busy ; // Set the write enable.
// DDR3 Write Request
assign DDR3_wr_ena  = cache_full && !DDR3_busy     ; // Set the write enable.
assign DDR3_wr_data = data_cache                   ; // Send write data.
assign DDR3_wr_mask = 16'hFFFF                     ; // Write enable for the byte.
// DDR3 transaction controls
assign DDR3_addr_o  = BUFFER_ADDR + buf_ptr        ; // DDR3 read/write address.
assign DDR3_ena     = DDR3_wr_ena || DDR3_rd_ena   ; // Write full 128-bits.
// SD interface voltage - DECA-specific ******* THIS CAN BE MODIFIED SO 1.8V CARDS ARE SUPPORTED ********
assign SD_SEL      = 1'b0                          ; // LOW = 3.3V, HIGH = 1.8V
// Bidir ports direction controls for sub-modules
assign SD_D0_DIR   = sddata_dir ? 1'b1       : 1'b0    ;
assign SD_D123_DIR = SD_D0_DIR                         ;
assign SD_CMD      = SD_CMD_DIR ? cmd_out    : 1'bz    ;
assign SD_DATA     = sddata_dir ? wr_sd_data : 4'bzzzz ;
// operation request triggers
assign ini_req     = ( ENABLE && MODE == OP_INIT  )    ; // pulses HIGH when an INIT  request is made
assign rd_req      = ( ENABLE && MODE == OP_READ  )    ; // pulses HIGH when an READ  request is made
assign wr_req      = ( ENABLE && MODE == OP_WRITE )    ; // pulses HIGH when an WRITE request is made

SDReaderWriter #(

    .BLKSIZE        ( 12'd512 ),
    .CLK_DIV        ( CLK_DIV )

) SDReaderWriter_inst (

    .clk            ( CLK        ), 
    .rst_n          ( ~RESET     ), 
    // Tx Fifo - FROM SDInterface for SD WR ops
    .data_in        (            ), // data from BYTESTREAM in SDInterface module
    .rd             (            ), // cache request (no direct parallel in SDInterface module)
    // Rx Fifo - TO SDInterface for SD RD ops
    .data_out       ( SD_dat     ), // read byte from SDReaderWriter module
    .we             ( cache_wren ), // HIGH when byte is valid from SDReaderWriter module
    // SDcard signals (connect to SDcard)
    .sdclk          ( SD_CLK     ), // SD_CLK generated by SDCmdCtrl sub-module
    // CMD lines
    .sdcmdin        ( SD_CMD     ), 
    .sdcmdout       ( cmd_out    ), 
    .sdcmdoe        ( SD_CMD_DIR ), 
    // DAT lines
    .DAT_dat_i      ( SD_DATA    ), // rd_sd_data
    .DAT_dat_o      ( wr_sd_data ), // wr_sd_data
    .DAT_oe_o       ( sddata_dir ), // data dir control
    // user read sector command interface
    //.rstart         (        ), 
    .rsector_no     ( SECTOR     ), 
    .rdone          ( rd_ready   ), 
    // show card status
    .card_type      ( cardtype   ), 
    .card_stat      ( sd_state   ), 
    // Control signals
    .blksize        ( 12'd512    ), // could be fixed or a parameter
    .bus_4bit       ( 1'b0       ), // 0 = 1-bit, 1 = 4-bit SD bus width mode
    .blkcnt         ( 12'b1      ), // fix to 1 block
    .cstart         ( ENABLE     ), // signal from SDInterface module to initiate RD/WR
    .mode           ( MODE       ), // operation type (INIT, READ or WRITE)
    .byte_alignment ( 2'b0       ), // ** no parallel in SDInterface module
    .sd_data_busy   ( SD_BUSY    ), // SD_BUSY in SDInterface module
    .busy           ( BUSY       ), // BUSY in SDInterface module
    .crc_ok         ( crc_ok     )  // flag for CRC check

);

always @( posedge CLK ) begin

    if ( RESET ) begin
        buf_ptr    <= 'hFF0  ; // start at 0xFF0 so when first read completes, buf_ptr = 0 for first memory write
        cache_full <= 1'b0   ; // RD cache starts empty
        cache_mpty <= 1'b1   ; // WR cache starts empty
        data_cache <= 128'b0 ;
        data_ptr   <= 4'b0   ;
        DDR3_req   <= 1'b0   ;
        last_cache <= 1'b0   ; // reset last_cache flag
        lbl        <= 1'b0   ;
        rdrdy_flag <= 1'b0   ;
        ini_op     <= 1'b0   ;
        rd_op      <= 1'b0   ;
        wr_op      <= 1'b0   ;
        wstart     <= 1'b0   ;
        wstarted   <= 1'b0   ;
        WR_DONE    <= 1'b0   ;
    end else if ( ini_req ) begin
        ini_op     <= 1'b1   ;
    end else if ( rd_req ) begin // new read request received
        buf_ptr    <= 'hFF0  ; // buf_ptr starts at 0 - 16
        rdrdy_flag <= 1'b0   ; 
        WR_DONE    <= 1'b0   ; 
        rd_op      <= 1'b1   ; // Enable RD op
    end else if ( wr_req ) begin // new write request received
        buf_ptr    <= 'h000  ; // buf_ptr offset for first row
        CMD_R_sent <= 1'b0   ;
        cache_mpty <= 1'b1   ; // WR cache starts empty
        first_row  <= 1'b1   ; // read first row of buffer
        last_cache <= 1'b0   ; // reset last_cache flag
        rdrdy_flag <= 1'b0   ; // Reset rdrdy_flag 
        WR_DONE    <= 1'b0   ; // Reset WR_DONE flag
        wr_op      <= 1'b1   ; // Enable WR op
    // *****************************************
    // *************** INI OP ****                        **************
    // *****************************************
    end else if ( ini_op && !BUSY ) begin
        //ini_op     <= 1'b0   ; // INITialisation complete
    end
    // *****************************************
    // *************** READ OP *****************
    // *****************************************
    else if ( rd_op ) begin
        if ( !rd_ready && cache_full && !DDR3_busy ) begin // 16-byte cache is full
            cache_full <= 1'b0   ;
        end else if ( rd_ready ) begin // End of SD Read; reset pointers and data bus
            buf_ptr    <= 'hFF0  ;
            cache_full <= 1'b0   ;
            data_cache <= 128'b0 ;
            data_ptr   <= 'hF    ;
            rdrdy_flag <= 1'b1   ;
            rd_op      <= 1'b0   ;
        end else if ( cache_wren ) begin // byte received from SDReader
            buf_ptr                   <= buf_ptr  + 1'b1 ;
            data_cache[data_ptr*8+:8] <= SD_dat          ; // assign byte to appropriate section of data_cache
            data_ptr                  <= data_ptr - 1'b1 ;
            if ( data_ptr == 'h0 ) cache_full <= 1'b1    ; // LSB read, write the cache to the buffer
        end
    end
    // ******************************************
    // *************** WRITE OP *****************
    // ******************************************
    else if ( wr_op ) begin
        if ( cache_mpty && !CMD_R_sent ) begin // WR cache is empty, perform a DDR3 read
            if ( !first_row ) begin
                buf_ptr <= buf_ptr +16 ; // increment buf_ptr by 16 bytes
                if ( buf_ptr == 'h1E0 ) begin
                    last_cache <= 1'b1 ;
                end
            end
            else begin
                first_row  <= 1'b0 ;
            end
            if (!last_cache) begin
                DDR3_req   <= 1'b1 ; // fire off a read request
                CMD_R_sent <= 1'b1 ; // flag that a RD has been requested
            end
        end
        else if ( CMD_R_sent && DDR3_rd_rdy ) begin // 16 bytes received from DDR3 for cache
            data_cache <= DDR3_rd_data ; // populate cache with read data from buffer
            cache_mpty <= 1'b0         ; // cache no longer empty
            DDR3_req   <= 1'b0         ;
            CMD_R_sent <= 1'b0         ; // no longer waiting for a RD result
            if (!wstarted) begin
                wstart   <= 1'b1 ;
                wstarted <= 1'b1 ;
            end
        end
        else if ( !cache_mpty && !end_wr_op ) begin // SDWriter requesting another byte
            wr_dat <= data_cache[(15-wr_ptr)*8+:8] ; // make correct byte available according to wr_ptr
            if ( wr_ptr == 15 ) begin
                lbl <= 1'b1 ;
                if ( !lbl && !last_cache ) begin
                    cache_mpty <= 1'b1 ;
                end
                else if ( !lbl ) begin
                    end_wr_op  <= 1'b1 ; // end the write operation
                end
            end else begin
                lbl <= 1'b0 ;
            end
            wstart     <= 1'b0   ;
            DDR3_req   <= 1'b0   ;
        end
        else if ( end_wr_op ) begin // end of 512-byte write op
            data_cache <= 128'b0 ;
            end_wr_op  <= 1'b0   ;
            last_cache <= 1'b0   ;
            wr_op      <= 1'b0   ; // end the write operation
            wstarted   <= 1'b0   ;
        end

    end

end

endmodule
