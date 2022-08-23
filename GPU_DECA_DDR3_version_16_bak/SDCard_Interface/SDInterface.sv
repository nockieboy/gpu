// SD Interface v1.0
//
// by nockieboy, November 2021-22
//
// Connects the SD modules to the rest of the GPU and provides init/read/write functions.
//

module SDInterface #(
    parameter int          CLK_DIV     = 2,      // clock divider
    parameter int          BUFFER_ADDR = 'h5000, // default DDR3 buffer location
    parameter bit  [  1:0] OP_INIT     = 0,
    parameter bit  [  1:0] OP_READ     = 1,
    parameter bit  [  1:0] OP_WRITE    = 2
)(
    input  logic           CLK,            // 100MHz system clock
    input  logic           RESET,          // reset active HIGH
    // interface <-> Bridgette
    input  logic           ENABLE,         // HIGH for RD/WR request
    //input  logic           WR_ENA,         // HIGH for write request
    input  logic   [  1:0] MODE,           // 0 = INIT 1-bit mode, 1 = READ, 2 = WRITE, 3 = INIT 4-bit mode
    input  logic   [ 31:0] SECTOR,         // sector number to read/write
    output logic           WR_DONE,        // HIGH when write is complete
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
wire    [7:0] wr_dat      ; // byte to send to SDWriter
wire    [3:0] wr_ptr      ; // pointer to current byte in cache
wire    [3:0] wr_sd_data  ;
wire          wr_ena,     crcok,      timeout,     bus_4bit,    sd_busy          ;
wire          rd_sd_clk,  rd_cmd_in,  rd_cmd_oe,   rd_cmd_out,  rd_req, rd_ready ;
wire          wr_sd_clk,  wr_cmd_in,  wr_cmd_oe,   wr_cmd_out,  wr_req, byte_req ;
wire          rd_cmd_dir, rd_d0_dir,  rd_d123_dir, rd_sel,      sdr_busy         ;
wire          wr_cmd_dir, wr_dir,     wr_d123_dir, sdw_busy,    wr_sel           ;

logic         end_wr_op, first_row, lbl, wstart, wstarted ;
logic         CMD_R_sent ; // HIGH when a RD request to DDR3 has been made
logic         DDR3_req   ; // HIGH for one clock to trigger DDR3 memory transaction
logic         last_cache ; // HIGH when last 16 bytes of SD buffer are being written to SD card
logic         rdrdy_flag ; // toggles HIGH when RD_RDY pulses high
logic         wr_done    ; // toggles HIGH when wdone pulses high
logic         rd_op      ; // toggles HIGH when RD taking place
logic         wr_op      ; // toggles HIGH when WR taking place
logic         cache_mpty ; // HIGH when 16-byte cache is empty (WR ops)
logic         cache_full ; // HIGH when 16-byte cache is full  (RD ops)
logic         rEna       ; // HIGH whilst rData is being sent
logic [  3:0] data_ptr   ; // pointer to current byte in cache
logic [  7:0] SD_dat     ; // byte read from SDReader to write to DDR3 buffer
logic [  8:0] buf_ptr    ; // 512-byte buffer address pointer
logic [ 15:0] rca        ; // RCA for initialised card
logic [127:0] data_cache ; // temporary 16-byte storage to be written to DDR3 or SD

//     SD_STATUS bits      7         6-5         4        3       2       1       0
assign SD_STATUS   = { rdrdy_flag, cardtype, sdw_busy, wr_done, crcok, timeout, sd_busy } ;
assign sd_busy     = sdr_busy || sdw_busy        ;
// operation request triggers
//assign ini_req     = ( ENABLE && ( MODE == 0 || MODE == 3 ) ) ; // pulses HIGH when an INIT  request is made
assign wr_ena      = ( MODE == OP_WRITE  )       ;
assign rd_req      = ( ENABLE && ~wr_ena )       ; // pulses HIGH when a READ  request is made
assign wr_req      = ( ENABLE && wr_ena  )       ; // pulses HIGH when a WRITE request is made

// DDR3 Read Request
assign DDR3_rd_ena  = DDR3_req && cache_mpty && !DDR3_busy ; // Set the write enable.
// DDR3 Write Request
assign DDR3_wr_ena  = cache_full && !DDR3_busy   ; // Set the write enable.
assign DDR3_wr_data = data_cache                 ; // Send write data.
assign DDR3_wr_mask = 16'hFFFF                   ; // Write enable for the byte.
// DDR3 transaction controls
assign DDR3_addr_o  = BUFFER_ADDR + buf_ptr      ; // DDR3 read/write address.
assign DDR3_ena     = DDR3_wr_ena || DDR3_rd_ena ; // Write full 128-bits.

// *********************************************************************************
// *********************************************************************************
// *************************    READ/WRITE SWITCH    *******************************
// *********************************************************************************
// *********************************************************************************
// Multiplex direction controls from SDReader and SDWriter modules according to
// whether a read or write is taking place.  Defaults to read settings.
//                     IF        TRUE          FALSE
assign SD_CLK      = wr_ena ? wr_sd_clk  : rd_sd_clk  ;
assign SD_SEL      = wr_ena ? wr_sel     : rd_sel     ;
assign SD_CMD_DIR  = wr_ena ? wr_cmd_dir : rd_cmd_dir ;
assign SD_D0_DIR   = wr_ena ? wr_dir     : rd_d0_dir  ;
assign SD_D123_DIR = wr_ena ? wr_dir     : rd_d0_dir  ;
// Bidir ports direction controls for sub-modules
assign SD_DATA     = ( wr_ena && wr_dir ) ? wr_sd_data : 4'bzzzz ;
assign SD_CMD      = wr_ena ? ( ( wr_cmd_oe ) ? wr_cmd_out : 1'bz ) : ( ( rd_cmd_oe ) ? rd_cmd_out : 1'bz ) ;
assign rd_cmd_in   = SD_CMD ;
assign wr_cmd_in   = SD_CMD ;

SDReader #(
    .CLK_DIV     ( CLK_DIV     )  // because clk=100MHz, CLK_DIV is set to 2 - see SDReader.sv for detail
) SDReader_inst(
    .clk         ( CLK         ),
    .rst_n       ( !RESET      ), // rst_n is active low, so RESET must be inverted
    // signals connect to SD bus
    .sdclk       ( rd_sd_clk   ), 
    .sdcmdin     ( rd_cmd_in   ), 
    .sdcmdout    ( rd_cmd_out  ), 
    .sdcmdoe     ( rd_cmd_oe   ), 
    .sddat       ( SD_DATA     ), 
    // status and information
    .card_type   ( cardtype    ), // 0=Unknown, 1=SDv1.1 , 2=SDv2 , 3=SDHCv2
    .card_stat   ( sd_state    ), // current state of SDReader's state machine
    .rca         ( rca         ), // Relative Card Address obtained by SDReader
    // user read sector command interface
    .MODE        ( MODE        ), // 0 = INIT 1-bit, 1 = READ, 2 = WRITE, 3 = INIT 4-bit
    .rstart      ( rd_req      ), // rstart HIGH starts read operation
    .rsector_no  ( SECTOR      ), // target sector to read in SDcard
    .rbusy       ( sdr_busy    ), // signals read is ongoing or complete
    .rdone       ( rd_ready    ), // signals read is complete
    .bus_4bit    ( bus_4bit    ), // HIGH for 4-bit SD interface, LOW for 1-bit
    // sector data output interface
    .outreq      ( cache_wren  ), // HIGH whilst data is received from SD card (for each byte?)
    .outaddr     (             ), // cache address to be written to
    .outbyte     ( SD_dat      ), // data read from SD card
    // bus direction controls
    .SD_CMD_DIR  ( rd_cmd_dir  ), // HIGH = TO SD card, LOW = FROM SD card
    .SD_D0_DIR   ( rd_d0_dir   ), // HIGH = TO SD card, LOW = FROM SD card
    .SD_SEL      ( rd_sel      )  // SD socket select
);

SDWriter #(
    .CLK_DIV     ( CLK_DIV     )  // because clk=100MHz, CLK_DIV is set to 2 - see SDReader.sv for detail
) SDWriter_inst(
    .clk         ( CLK         ),
    .rst_n       ( !RESET      ),   
    // SDcard signals (connect to SD card)
    .sdclk       ( wr_sd_clk   ),
    .sdcmdin     ( wr_cmd_in   ), 
    .sdcmdout    ( wr_cmd_out  ), 
    .sdcmdoe     ( wr_cmd_oe   ), 
    .sddat_i     ( SD_DATA     ),
    .sddat_o     ( wr_sd_data  ),
    // user write sector command interface
    .wstart      ( wstart      ), // pulse high to start write op
    .wsector_no  ( SECTOR      ), // user-supplied sector address
    .cardtype    ( cardtype    ),
    .rca         ( rca         ),
    .bus_4bit    ( bus_4bit    ), // HIGH for 4-bit SD interface, LOW for 1-bit
    .wbusy       ( sdw_busy    ),
    .wdone       ( wr_done     ),
    .crc_ok      ( crcok       ),
    .wtimeout    ( timeout     ), // HIGH when a WRITE has timed out waiting for CRC response
    // sector data input interface
    .bytePtr     ( wr_ptr      ),
    .wbyte       ( wr_dat      ), // byte to write to SD card
    // these signals are direction controls specific to the DECA board
    .SD_CMD_DIR  ( wr_cmd_dir  ), // HIGH = TO SD card, LOW = FROM SD card
    .sd_oe_en    ( wr_dir      ), // HIGH = TO SD card, LOW = FROM SD card
    .SD_SEL      ( wr_sel      )
);

always @( posedge CLK ) begin

    if ( RESET ) begin
        buf_ptr    <=  'h1F0 ; // start at 0xFF0 so when first read completes, buf_ptr = 0 for first memory write
        BUSY       <= 1'b0   ;
        cache_full <= 1'b0   ; // RD cache starts empty
        cache_mpty <= 1'b1   ; // WR cache starts empty
        data_cache <= 128'b0 ;
        data_ptr   <=  'hF   ;
        DDR3_req   <= 1'b0   ;
        last_cache <= 1'b0   ; // reset last_cache flag
        lbl        <= 1'b0   ;
        rdrdy_flag <= 1'b0   ;
        rd_op      <= 1'b0   ;
        WR_DONE    <= 1'b0   ;
        wr_op      <= 1'b0   ;
        wstart     <= 1'b0   ;
        wstarted   <= 1'b0   ;
    end else if ( rd_req ) begin // new read request received
        buf_ptr    <= 'h1F0  ; // buf_ptr starts at 0 - 16
        data_ptr   <=  'hF   ; // 
        rdrdy_flag <= 1'b0   ; 
        WR_DONE    <= 1'b0   ; 
        if ( MODE == 1 ) begin // only update as busy and enable a rd_op if a read is being performed
            BUSY  <= 1'b1 ;
            rd_op <= 1'b1 ; // Enable RD op
        end
    end else if ( wr_req ) begin // new write request received
        buf_ptr    <= 'h000  ; // buf_ptr offset for first row
        CMD_R_sent <= 1'b0   ;
        BUSY       <= 1'b1   ; // Interface is now busy
        cache_mpty <= 1'b1   ; // WR cache starts empty
        first_row  <= 1'b1   ; // read first row of buffer
        last_cache <= 1'b0   ; // reset last_cache flag
        rdrdy_flag <= 1'b0   ; // Reset rdrdy_flag 
        WR_DONE    <= 1'b0   ; // Reset WR_DONE flag
        wr_op      <= 1'b1   ; // Enable WR op
    // *****************************************
    // *********** BYTESTREAMREADER ************
    // *****************************************
    end else if ( rd_op ) begin
        if ( !rd_ready && cache_full && !DDR3_busy ) begin // 16-byte cache is full
            cache_full <=   1'b0   ; // ensure cache_full is a single-clock pulse
        end else if ( rd_ready ) begin // End of SD Read; reset pointers and data bus
            buf_ptr    <=    'h1F0 ;
            cache_full <=   1'b0   ;
            data_cache <= 128'b0   ;
            data_ptr   <=    'hF   ; // DATA ALIGNMENT TESTING
            BUSY       <=   1'b0   ;
            rdrdy_flag <=   1'b1   ;
            rd_op      <=   1'b0   ;
        end else if ( cache_wren ) begin // byte received from SDReader
            buf_ptr                   <= buf_ptr  + 1'b1 ;
            data_cache[data_ptr*8+:8] <= SD_dat          ; // assign byte to appropriate section of data_cache
            data_ptr                  <= data_ptr - 1'b1 ;
            if ( data_ptr == 1'h0 )   cache_full <= 1'b1 ; // LSB read, write the cache to the buffer
        end
    end
    // ******************************************
    // *********** BYTESTREAMWRITER *************
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
            if ( !last_cache ) begin
                DDR3_req   <= 1'b1 ; // fire off a read request
                CMD_R_sent <= 1'b1 ; // flag that a RD has been requested
            end
        end
        else if ( CMD_R_sent && DDR3_rd_rdy ) begin // 16 bytes received from DDR3 for cache
            data_cache <= DDR3_rd_data ; // populate cache with read data from buffer
            cache_mpty <= 1'b0         ; // cache no longer empty
            DDR3_req   <= 1'b0         ;
            CMD_R_sent <= 1'b0         ; // no longer waiting for a RD result
            if ( !wstarted ) begin
                wstart   <= 1'b1 ; // start the WR transaction
                wstarted <= 1'b1 ; // ensure that wstart is HIGH only once during the WR transaction
            end
        end
        else if ( !cache_mpty && !end_wr_op ) begin // SDWriter requesting another byte
            DDR3_req <= 1'b0                         ;
            wr_dat    = data_cache[(15-wr_ptr)*8+:8] ; // make correct byte available according to wr_ptr
            wstart   <= 1'b0                         ;
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
        end
        else if ( end_wr_op && !sd_busy ) begin // end of 512-byte write op
            BUSY       <= 1'b0   ;
            data_cache <= 128'b0 ;
            end_wr_op  <= 1'b0   ;
            last_cache <= 1'b0   ;
            wr_op      <= 1'b0   ; // end the write operation
            wstarted   <= 1'b0   ;
        end

    end

end

endmodule
