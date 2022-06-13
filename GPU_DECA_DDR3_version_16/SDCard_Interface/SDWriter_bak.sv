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
    input  logic [ 1:0] cardtype,
    input  logic [15:0] rca,
    output logic        wbusy,
    output logic        wdone,
    output logic        crc_ok,
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
assign  SD_D123_DIR    = 1'b0        ; // read-only to prevent writes to SD card whilst testing

// SD interface voltage - DECA-specific ******* THIS CAN BE MODIFIED SO 1.8V CARDS ARE SUPPORTED ********
assign  SD_SEL         = 1'b0        ; // LOW = 3.3V, HIGH = 1.8V

wire            sddat0      = sddat[0]         ; // only use 1bit mode of SDDAT
wire    [  2:0] rlsb        = 3'd7 - widx[2:0] ; // bit pointer for byte being written (counts from 7 to 0)
wire    [ 15:0] crc_out [3:0]        ;

logic           start       = 1'b0   ;
logic   [  5:0] cmd         = '0     ;
logic   [  4:0] crc_c                ;
logic   [  3:0] crc_in               ;
logic           crc_en               ;
logic           crc_rst              ;
logic   [  2:0] crc_s                ;
logic   [  1:0] crc_status           ;
logic   [  7:0] writebyte /* synthesis keep */; // this is the byte to be written to the SD card
logic   [ 15:0] clkdiv      = 16'd50 ;
logic   [ 15:0] precycles   = '0     ;
logic   [ 31:0] wsectoraddr = '0     ;
logic   [ 31:0] arg         = '0     ;
logic   [ 31:0] widx                 ; // bit counter for data transmission
logic   [ 31:0] resparg              ;
logic   [127:0] resparg_long         ;
logic           busy, done, timeout  ;
logic           syntaxerr            ;
logic           sdclkl      = 1'b0   ;

//      |---------- CARD INITIALISATION ---------|-SEL-|BLKLEN|
enum bit { /*CMD0, CMD8, CMD55_41, ACMD41, CMD2, CMD3, CMD7, CMD16,*/ IDLE, WRITING } sdstate = IDLE    ;
enum bit[4:0] { W_START, W_DAT, W_CRC, W_STOP, W_END, R_CRC, W_BUSY, WDONE, WTIMEOUT } wstate = W_START ;
//
localparam UNKNOWN = 2'b00 ;
localparam SDv1    = 2'b01 ;
localparam SDv2    = 2'b10 ;
localparam SDHCv2  = 2'b11 ;
//
assign bytePtr  = widx[6:3]       ; // point bytePtr at the correct byte in the 16-byte cache
assign sddat[1] = 1'b1            ;
assign sddat[2] = 1'b1            ;
assign sddat[3] = 1'b1            ;
assign wbusy    = (sdstate!=IDLE) ;

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

always @(posedge clk or negedge rst_n) begin : CMD_Controller

    if ( ~rst_n ) begin
        wdone       = 1'b0 ;
        wsectoraddr ='0    ;
        sdstate     = IDLE ; // SDWriter shouldn't try to access SD card at reset
    end else begin
        set_cmd(0)         ;
        wdone       = 1'b0 ;
        if ( sdstate == WRITING ) begin // Handle write timeouts and end process
            if ( wstate == WDONE ) begin
                wdone   = 1'b1 ;
                sdstate = IDLE ;
            end
        end else if ( busy ) begin // SD card is busy writing
            if ( done ) begin // SD card has finished
                if ( ~timeout && ~syntaxerr ) begin // No errors - go to WRITING2
                    sdstate = IDLE    ;
                end
                else begin // Errors - Resend WRITE command
                    set_cmd(1, 128 , FASTCLKDIV, 24, wsectoraddr) ;
                    sdstate = WRITING ;
                end
            end
        end else begin // IDLE
            if ( wstart ) begin // BEGIN WRITING
                wsectoraddr = ( cardtype == SDHCv2 ) ? wsector_no : ( wsector_no*512 );
                set_cmd ( 1, 32 , FASTCLKDIV, 24, wsectoraddr ) ; // Send WRITE command
                sdstate = WRITING ;
            end
        end
    end

end

always @( posedge clk or negedge rst_n ) begin : ByteWriter

    if ( ~rst_n ) begin

        crc_c      <= 16      ;
        crc_ok     <= 0       ;
        crc_rst    <= 1       ;
        crc_status <= 0       ;
        sdclkl     <= 1'b0    ;
        wstate      = W_START ;
        widx       <= '0      ;

    end else begin

        sdclkl <= sdclk   ; // update sdclk edge detect

        if ( sdstate != WRITING ) begin // IDLE
        
            wstate      = W_START ;
            widx       <= 0       ;
            crc_c      <= 16      ;
            crc_en     <= 1'b0    ; 
            crc_rst    <= 1       ;
            crc_status <= 0       ;

        end else if ( sdstate == WRITING & ~sdclkl & sdclk ) begin  // ONLY on rising edge of sdclk

            case ( wstate )

                W_START: begin
                    // ** Data transfer to the SD card is initiated here if sdstate == WRITING **
                    if ( done ) begin
                        writebyte <= wbyte ; // pull the first byte ready for transmission
                        SD_D0_DIR <= 1'b1  ; // writing to SD card via DAT0
                        crc_en    <= 1'b1  ; 
                        crc_rst   <= 0     ;
                        sddat[0]   = 0     ; // pull sddat[0] LOW to indicate start of write
                        widx      <= 0     ; 
                        wstate     = W_DAT ; 
                    end
                end
                W_DAT: begin  // Write 512 bytes, bit by bit
                    sddat[0] = writebyte[rlsb] ; // write byte one bit at a time
                    crc_in  <= { 3'h7, writebyte[rlsb] } ;
                    widx    <= widx + 1    ; 
                    if ( rlsb == 3'd0 ) begin // Reached last bit in the byte
                        writebyte <= wbyte ; 
                    end
                    if ( widx == 512*8 + 8 ) begin // End of 512*8 + 8 data bits
                        crc_c  <= 16       ; // set CRC bit counter
                        crc_en <= 1'b0     ;
                        //widx   <= 0        ; 
                        wstate  = W_CRC    ; 
                    end
                end
                W_CRC:  begin // Send CRC bits to SD card
                    crc_en <= 1'b0 ; 
                    if ( crc_c == 0 ) begin
                        wstate = W_STOP ; 
                    end
                    else begin
                        crc_c   <= crc_c - 5'h1          ;
                        sddat[0] = crc_out[0][crc_c - 1] ;
                    end
                end
                W_STOP: begin // send STOP bit
                    sddat[0]   = 1'b1   ; 
                    //widx      <= 0      ;
                    wstate     = W_END  ;
                end
                W_END:  begin // wait for CRC response START bit
                    SD_D0_DIR <= 1'b0   ; // set SD data to READ direction
                    if ( sddat[0] ) wstate = R_CRC ;
                end
                R_CRC:  begin // receive CRC OK bits
                    SD_D0_DIR <= 1'b0   ; // set SD data to READ direction
                    if ( crc_status < 3 ) begin
                        crc_s[crc_status] <= sddat[0] ;
                        crc_status        <= crc_status + 2'h1;
                    end else wstate = W_BUSY ;
                end
                W_BUSY: begin
                    if (crc_s == 3'b010) crc_ok <= 1 ;
                    else                 crc_ok <= 0 ;
                    if ( sddat[0] ) begin
                        wstate      = WDONE ; // tell CMD_Controller that we're done here
                        crc_c      <= 16    ;
                        crc_rst    <= 1     ;
                        crc_status <= 0     ;
                    end
                end
                WDONE: begin // wrap up
                    crc_c      <= 16      ;
                    crc_rst    <= 1       ;
                    crc_status <= 0       ;
                    wstate     <= W_START ;
                end

            endcase

        end

    end

end

endmodule
