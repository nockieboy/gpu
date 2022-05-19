module SDWriter # (
    parameter   CLK_DIV = 1,    // when clk = 0~25MHz   , set CLK_DIV to 0,
                                // when clk = 25~50MHz  , set CLK_DIV to 1,
                                // when clk = 50~100MHz , set CLK_DIV to 2,
                                // when clk = 100~200MHz, set CLK_DIV to 3,
                                // when clk = 200~400MHz, set CLK_DIV to 4, etc...
    parameter   WIDTH   = 1     // SD interface width (1 or 4)
) (
    // clock
    input  logic        clk,
    // rst_n active-low
    input  logic        rst_n,
    // SDcard signals (connect to SDcard)
    output logic        sdclk,
    output logic [ 3:0] sddat,
    output logic        sdcmdin,
    output logic        sdcmdout,
    output logic        sdcmdoe,
    // user write sector command interface
    input  logic        wstart,         // pulse high to start write op
    input  logic [31:0] wsector_no,     // user-supplied sector address
    output logic        wbusy,
    output logic        wdone,
    // sector data input interface
    output logic [ 3:0] bytePtr,        // points to byte in cache to be written
    input  logic [ 7:0] wbyte,
    // these signals are direction controls specific to the DECA board
    output logic        SD_CMD_DIR,     // HIGH = TO SD card, LOW = FROM SD card
    output logic        SD_D0_DIR,      // HIGH = TO SD card, LOW = FROM SD card
    output logic        SD_D123_DIR,    // HIGH = TO SD card, LOW = FROM SD card
    output logic        SD_SEL
);

localparam  SLOWCLKDIV = (16'd1<<CLK_DIV)*16'd35 ;
localparam  FASTCLKDIV =  16'd1<<CLK_DIV         ;
localparam  CMDTIMEOUT = 15'd500     ; // according to SD datasheet, Ncr(max) = 64 clock cycles, so 500 cycles is enough
localparam  DATTIMEOUT = 'd1000000   ; // according to SD datasheet, 1ms is enough to wait for DAT result, here, we set timeout to 1000000 clock cycles = 80ms (when SDCLK=12.5MHz)

// DECA SD direction controls - HIGH for writes to SD card, LOW for reads from SD card
assign  SD_CMD_DIR     = sdcmdoe     ;
assign  SD_D0_DIR      = d0dir       ;
assign  SD_D123_DIR    = 1'b0        ; // read-only to prevent writes to SD card whilst testing

// SD interface voltage - DECA-specific ******* THIS CAN BE MODIFIED SO 1.8V CARDS ARE SUPPORTED ********
assign  SD_SEL         = 1'b0        ; // LOW = 3.3V, HIGH = 1.8V

wire            sddat0      = sddat[0]         ; // only use 1bit mode of SDDAT
wire    [  2:0] rlsb        = 3'd7 - widx[2:0] ; // bit pointer for byte being written (counts from 7 to 0)
wire    [ 15:0] crc_out [3:0]        ;

logic           start       = 1'b0   ;
logic   [  5:0] cmd         = '0     ;
logic   [  3:0] crc_in               ;
logic           crc_en               ;
logic           crc_rst              ;
logic   [  7:0] writebyte /* synthesis keep */; // this is the byte to be written to the SD card
logic   [ 15:0] clkdiv      = 16'd50 ;
logic   [ 15:0] precycles   = '0     ;
logic   [ 15:0] rca         = '0     ;
logic   [ 31:0] wsectoraddr = '0     ;
logic   [ 31:0] arg         = '0     ;
logic   [ 31:0] widx        =  0     ; // bit counter for data transmission
logic   [ 31:0] resparg              ;
logic   [127:0] resparg_long         ;
logic           busy, done, timeout  ;
logic           syntaxerr            ;
logic           sdclkl      = 1'b0   ;
logic           d0dir       = 1'b0   ; // READ ONLY FOR TESTING

// TEST VALUES
//logic        enable     ;
//logic [ 8:0] byte_count ; // maximum value 512
//logic [ 7:0] testByte   ;
//logic [24:0] timer      ;

//    |---------- CARD INITIALISATION ---------|-SEL-|BLKLEN|
enum { /*CMD0, CMD8, CMD55_41, ACMD41, CMD2, CMD3, CMD7, CMD16,*/ IDLE, WRITING, WRITING2 } sdstate = IDLE ;
//
enum { UNKNOWN, SDv1, SDv2, SDHCv2, SDv1Maybe }                         cardtype = UNKNOWN       ;
enum { WRITE_START, WRITE_DAT, WRITE_CRC, WRITE_BUSY, WDONE, WTIMEOUT } wstate   = WRITE_START   ;

assign bytePtr   = widx    [6:3]   ; // point bytePtr at the correct byte in the 16-byte cache
assign wbusy     = (sdstate!=IDLE) ;
assign card_stat = sdstate [3:0]   ;
assign card_type = cardtype[1:0]   ;

// Instantiate an SDCmdCtrl instance, using implicit named port connections,
// which are automatically connected to wires/ports of same name with equivalent data types.
SDCmdCtrl #(
    CMDTIMEOUT
) sd_cmd_ctrl_inst (
    .clk,
    .rst_n,
    // user input signal
    .start,
    .precycles,
    .clkdiv,
    .cmd,
    .arg,
    // user output signal
    .resparg,
    .resparg_long,
    .busy,
    .done,
    .timeout,
    .syntaxerr,
    // SD CLK output
    .sdclk,
    // 1bit SD CMD
    .sdcmdoe,
    .sdcmdout,  // <- from cmd_ctrl
    .sdcmdin    // CMD -> cmd_ctrl
);

task automatic set_cmd(input _start, input[15:0] _precycles='0, input[15:0] _clkdiv=SLOWCLKDIV, input[5:0] _cmd='0, input[31:0] _arg='0 ) ;
    start     = _start     ;
    precycles = _precycles ;
    clkdiv    = _clkdiv    ;
    cmd       = _cmd       ;
    arg       = _arg       ;
endtask

// Instantiate CRC generators for the required number of lanes in the SD interface
genvar i ;
generate
    for ( i = 0 ; i < WIDTH ; i = i + 1 ) begin: CRC_16_gen
        sd_crc_16 CRC_16_i ( crc_in[i], crc_en, sdclk, crc_rst, crc_out[i] ) ;
    end
endgenerate

/*
always @(posedge clk or negedge rst_n) begin

    if ( ~rst_n ) begin
        byte_count <= 0    ;
        enable     <= 0    ;
        timer      <= 0    ;
        wdone      <= 0    ;
        widx       <= 0    ;
    end
    else if ( wstart ) begin
        byte_count <= 0    ;
        enable     <= 1'b1 ;
        timer      <= 0    ;
        wdone      <= 0    ;
        widx       <= 0    ;
        sdstate    <= WRITING ;
    end
    else if ( enable ) begin
        timer <= timer + 1'b1 ;
        if (timer > 50) begin
            if ( byte_count < 512 ) begin // request byte
                if ( byte_count == 511 ) begin
                    wdone      <= 1'b1 ;
                    enable     <= 1'b0 ;
                    widx       <= 0    ;
                    sdstate    <= IDLE ;
                end
                else begin
                    byte_count <= byte_count + 1 ;
                    widx       <= widx + 8       ;
                    writebyte  <= wbyte          ;
                end
            end
            timer <= 0 ; // reset timer
        end
    end

end */

always @(posedge clk or negedge rst_n) begin

    if ( ~rst_n ) begin
        wdone       = 1'b0    ;
        wsectoraddr ='0       ;
        sdstate     = IDLE    ; // SDWriter shouldn't try to access SD card at reset
        cardtype    = UNKNOWN ;
        rca         = '0      ;
    end else begin
        wdone       = 1'b0    ;
        if ( sdstate == WRITING2 ) begin // Handle write timeouts and end process
            if ( wstate == WTIMEOUT ) begin
                set_cmd(1, 16 , FASTCLKDIV, 24, wsectoraddr) ; // Send WRITE command
                sdstate = WRITING ;
            end
            else if ( wstate == WDONE ) begin
                wdone   = 1'b1 ;
                sdstate = IDLE ;
            end
        end else if ( busy ) begin // SD card is busy writing
            if ( done ) begin // SD card has finished
                if ( ~timeout && ~syntaxerr ) begin // No errors - go to WRITING2
                    sdstate = WRITING2     ;
                end
                else begin // Errors - Resend WRITE command
                    set_cmd(1, 128 , FASTCLKDIV, 24, wsectoraddr);
                end
            end
        end else begin // IDLE
            if ( wstart & ~wbusy ) begin // BEGIN WRITING
                wsectoraddr = ( cardtype == SDHCv2 ) ? wsector_no : ( wsector_no*512 );
                set_cmd ( 1, 32 , FASTCLKDIV, 24, wsectoraddr ) ; // Send WRITE command
                sdstate = WRITING ;
            end
        end
    end
end

always @( posedge clk or negedge rst_n ) begin

    if ( ~rst_n ) begin

        sdclkl  <= 1'b0       ;
        wstate  = WRITE_START ;
        widx    = '0          ;

    end else begin

        sdclkl  <= sdclk      ; // update sdclk edge detect
        if ( sdstate != WRITING && sdstate != WRITING2 ) begin // IDLE
        
            wstate = WRITE_START ;
            widx   = 0           ;

        end else if ( ~sdclkl & sdclk ) begin  // ONLY on rising edge of sdclk

            case ( wstate )
                WRITE_START:  begin
                    // ** Data transfer to the SD card is initiated here  **
                    writebyte <= wbyte   ; // pull the first byte ready for transmission
                    SD_D0_DIR <= 1'b1    ; // writing to SD card via DAT0
                    sddat[0] = 0         ; // pull sddat[0] LOW to indicate start of write
                    widx     = 0         ;
                    wstate   = WRITE_DAT ;
                end
                WRITE_DAT: begin  // Write 512 bytes, bit by bit
                    sddat[0] = writebyte[rlsb] ;  // write byte one bit at a time
                    crc_in   <= { 3'h7, writebyte[rlsb] } ;
                    if ( rlsb == 3'd0 ) begin   // Reached last bit in the byte
                        writebyte <= wbyte ;
                    end
                    if ( ( ++widx ) >= 512*8 ) begin
                        wstate = WRITE_CRC ;
                        widx   = 0         ;
                    end
                end
                WRITE_CRC:  begin
                    // Insert CRC value here then stop

                    if ( ( ++widx ) >= 8*8 ) begin
                        wstate = WDONE ;
                    end
                end
                WRITE_BUSY: begin


                end
            endcase

        end

    end

end

endmodule
