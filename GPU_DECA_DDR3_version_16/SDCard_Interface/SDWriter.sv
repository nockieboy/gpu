// SD Interface - SDWriter v1.0
//
// by nockieboy, June 2022
//

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
    input  logic [ 3:0] sddat_i,        // READ  data FROM SD card (to read status)
    output logic [ 3:0] sddat_o,        // WRITE data TO   SD card (to write data )
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
    output logic        wtimeout,
    // sector data input interface
    output logic [ 3:0] bytePtr,        // points to byte in cache to be written
    input  wire  [ 7:0] wbyte,
    // these signals are direction controls specific to the DECA board
    output logic        SD_CMD_DIR,     // HIGH = TO SD card, LOW = FROM SD card
    output logic        sd_oe_en,       // HIGH = TO SD card, LOW = FROM SD card
    output logic        SD_SEL
);

localparam       SLOWCLKDIV  = (16'd1<<CLK_DIV)*16'd35 ;
localparam       FASTCLKDIV  =  16'd1<<CLK_DIV         ;
localparam       CMDTIMEOUT  = 15'd500   ; // according to SD datasheet, Ncr(max) = 64 clock cycles, so 500 cycles is enough
localparam       DATTIMEOUT  = 'd1000000 ; // according to SD datasheet, 1ms is enough to wait for DAT result, here, we set timeout to 1000000 clock cycles = 80ms (when SDCLK=12.5MHz)

// DECA SD direction controls - HIGH for writes to SD card, LOW for reads from SD card
assign  SD_CMD_DIR     = sdcmdoe      ;
// SD interface voltage - DECA-specific ******* THIS CAN BE MODIFIED SO 1.8V CARDS ARE SUPPORTED ********
assign  SD_SEL         = 1'b0         ; // LOW = 3.3V, HIGH = 1.8V

wire    [  2:0] rlsb = 3'd7-widx[2:0] ; // bit pointer for byte being written (counts from 7 to 0)
wire    [ 15:0] crc_out [3:0]         ;

logic           start       = 1'b0   ;
logic   [  5:0] cmd         = '0     ;
logic   [  4:0] crc_c                ;
logic   [  3:0] crc_in               ;
logic           crc_en               ;
logic           crc_rst              ;
logic   [  2:0] crc_status           ; // crc_s index
logic   [  6:0] crc_s                ;
logic   [  2:0] sb_idx               ; 
logic   [  3:0] cstate               ; // register to hold card's current state
logic   [  7:0] writebyte            ; // this is the byte to be written to the SD card
logic   [ 12:0] sderr                ; // register to hold card's error bits
logic   [ 14:0] data_cycles          ;
logic   [ 15:0] clkdiv      = 16'd50 ;
logic   [ 15:0] precycles   = '0     ;
logic   [ 31:0] wsectoraddr          ;
logic   [ 31:0] arg         = '0     ;
logic   [ 31:0] widx                 ; // bit counter for data transmission
logic   [ 31:0] resparg              ;
logic   [127:0] resparg_long         ;
logic           busy, done, timeout  ;
logic           syntaxerr            ;
logic           sdclkl      = 1'b0   ;
logic   [  2:0] updateByte           ; // delays update of writebyte until wbyte is valid

//      0     1      2        3        4       5
enum { IDLE, SEL, WRITING, WRITING2, STATUS, ENDSEL } sdstate = IDLE ;
//        0       1      2      3      4      5       6       
enum { W_START, W_DAT, W_CRC, W_END, R_CRC, W_BUSY, WDONE } wstate = W_START ;
//
localparam UNKNOWN = 2'b00 ;
localparam SDv1    = 2'b01 ;
localparam SDv2    = 2'b10 ;
localparam SDHCv2  = 2'b11 ;
//
assign bytePtr  = widx[6:3]       ; // point bytePtr at the correct byte in the 16-byte cache
assign wbusy    = (sdstate!=IDLE) ;
//
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
        cstate       = 4'b0  ;
        sderr        = 13'b0 ;
        sdstate      = IDLE  ; // SDWriter shouldn't try to access SD card at reset
        wdone        = 1'b0  ;
        wsectoraddr <=  '0   ;
    end else begin
        set_cmd(0)           ;
        wdone        = 1'b0  ;
        if ( sdstate == WRITING2 ) begin // SDWriter is transmitting payload
            //if ( wstate == WTIMEOUT ) begin
            //    sdstate = WRITING ;
            //end
            /*else*/ if ( wstate == WDONE ) begin
                if ( wtimeout ) begin
                    //sdstate = STATUS ; // get card status after a WR timeout
                    sdstate = ENDSEL ; // deselect card
                    wdone   = 1'b0   ; // 
                end else begin
                    wdone   = 1'b1   ; // set for WR_OK
                    sdstate = ENDSEL ; // deselect card
                end
            end
        end else if ( busy ) begin // command has been transmitted for current sdstate
            if ( done ) begin // command has finished
                case ( sdstate )
                    SEL     : if ( ~timeout && ~syntaxerr ) sdstate = WRITING ;
                    WRITING : begin
                        if ( ~timeout && ~syntaxerr ) begin // No CMD errors - transmit payload
                            sdstate = WRITING2 ;
                        end
                        else begin // Errors - Resend WRITE command
                            sdstate = WRITING  ;
                        end
                    end
                    STATUS  : begin
                        if ( ~timeout && ~syntaxerr ) begin
                            cstate <= resparg[12: 9] ; // current state
                            sderr  <= resparg[31:19] ; // error bits
                            sdstate = ENDSEL         ;
                            wdone   = 1'b1           ;
                        end
                    end
                    ENDSEL  : sdstate = IDLE ;
                endcase
            end
        end else begin // send appropriate command for current sdstate
            case ( sdstate )
                IDLE : begin
                    if ( wstart & ~wbusy ) begin // BEGIN WRITING
                        sdstate      = SEL ; // starting state for a write operation
                        wsectoraddr <= ( cardtype == SDHCv2 ) ? wsector_no : ( wsector_no*512 ) ;
                    end
                end
                SEL     : set_cmd( 1, 20, FASTCLKDIV,  7, { rca, 16'h0 } ) ; // SELECT CARD
                WRITING : set_cmd( 1, 32, FASTCLKDIV, 24, wsectoraddr    ) ; // Send WRITE command
                STATUS  : set_cmd( 1, 20, FASTCLKDIV, 13, { rca, 16'h0 } ) ; // Get card status
                ENDSEL  : set_cmd( 1, 20, FASTCLKDIV,  7, 'h00000000     ) ; // DESELECT CARD
            endcase 
        end
    end

end

always @( posedge clk or negedge rst_n ) begin : ByteWriter

    if ( ~rst_n ) begin

        crc_c      <= 0       ;
        crc_en     <= 1'b0    ;
        crc_in     <= 0       ;
        crc_ok     <= 1'b0    ;
        crc_rst    <= 1'b0    ;
        crc_s      <= 7'b0    ;
        crc_status <= 3'h7    ;
        sdclkl     <= 1'b0    ;
        sddat_o    <= 4'hF    ;
        sd_oe_en   <= 1'b1    ; // set direction to write
        updateByte <= 2'b0    ;
        widx       <= '0      ;
        wstate      = W_START ;
        wtimeout   <= 1'b0    ;

    end else begin

        sdclkl <= sdclk   ; // update sdclk edge detect

        if ( updateByte > 0 ) begin                     // The updateByte block here delays assignment of wbyte to writebyte
            if ( updateByte == 1 ) writebyte <= wbyte ; // and gives wbyte time to update to the new byte value when the end
            updateByte <= updateByte - 1'b1 ;           // of the last byte is reached by widx.
        end

        if ( sdstate != WRITING && sdstate != WRITING2 ) begin // IDLE
        
            crc_c       <= 0       ;
            crc_en      <= 1'b0    ; 
            crc_in      <= 0       ;
            crc_ok      <= 1'b0    ;
            crc_rst     <= 1'b0    ;
            crc_s       <= 7'b0    ;
            crc_status  <= 3'h7    ;
            data_cycles <= 512*8   ;
            sb_idx      <= 0       ;
            sddat_o     <= 4'hF    ; 
            sd_oe_en    <= 1'b1    ; // set direction to write
            updateByte  <= 2'b0    ;
            widx        <= '0      ;
            wstate       = W_START ;
            wtimeout    <= 1'b0    ;

        end else if ( sdstate == WRITING2 & ~sdclkl & sdclk ) begin  // ONLY on rising edge of sdclk

            case ( wstate )

                W_START: begin // wstate 0
                    if ( sb_idx == 0 ) begin
                        crc_c      <= 0    ;
                        crc_ok     <= 1'b0 ;
                        crc_rst    <= 1'b0 ;
                        crc_s      <= 7'b0 ;
                        crc_status <= 3'h7 ;
                        sb_idx     <= 4    ; // # of cycles to hold DAT0 HIGH before START bit
                        sd_oe_en   <= 1'b1 ; // writing to SD card
                        widx       <= 0    ; 
                        wtimeout   <= 1'b0 ;
                    end else begin
                        if ( sb_idx == 1 ) begin
                            crc_rst   <= 1'b1  ;
                            sddat_o   <= 4'hE  ; // send START bit
                            writebyte <= wbyte ; // pull the first byte ready for transmission
                            wstate     = W_DAT ; // 
                        end else begin
                            crc_en    <= 1'b0  ; 
                            crc_rst   <= 1'b0  ;
                            sddat_o   <= 4'hF  ; 
                        end
                        sb_idx <= sb_idx - 1 ;
                    end
                end

                W_DAT: begin  // wstate 1
                    // Write 512 bytes, bit by bit
                    crc_rst <= 1'b0     ;
                    widx    <= widx + 1 ; 
                    if ( rlsb == 3'd0 && widx != data_cycles ) begin // Reached last bit in the byte
                        updateByte <= 2 ; // set clock delay for writebyte update
                    end
                    if ( widx == data_cycles ) begin // Last bit of data payload - widx = 0x1000
                        crc_c     <= 15                              ; // set CRC bit counter
                        crc_en    <= 1'b0                            ; // disable CRC calculation
                        sddat_o   <= { 3'h7, crc_out[0][crc_c - 1] } ; // write first bit of CRC
                        writebyte <= 8'b0                            ;
                        wstate     = W_CRC                           ; 
                    end else begin
                        crc_en    <= 1'b1                            ; // enable CRC calculation
                        crc_in    <= { 3'h7, writebyte[rlsb] }       ; // write bit to CRC
                        sddat_o   <= { 3'h7, writebyte[rlsb] }       ; // write one bit at a time
                    end
                end

                W_CRC:  begin // wstate 2
                    // Send 16 CRC bits to SD card - data_cycles + 2 to data_cycles + 17
                    crc_en  <= 1'b0         ; 
                    crc_rst <= 1'b0         ;
                    crc_c   <= crc_c - 5'h1 ;
                    widx    <= widx + 1     ; 
                    if ( crc_c == 0 ) begin // widx = 4,113 (0x1011)
                        sddat_o  <= 4'hF  ; // send 'STOP' bit
                        sd_oe_en <= 1'b0  ; // set SD data to READ direction
                        wstate    = W_END ;
                    end else begin // widx = 4,097-4,112 (0x1001 - 0x1010)
                        sddat_o  <= { 3'h7, crc_out[0][crc_c - 1] } ;
                    end
                end

                W_END:  begin // wstate 3 - widx = 4,114
                    // wait for CRC response START bit - data_cycles + 18
                    crc_rst  <= 1'b0     ;
                    sd_oe_en <= 1'b0     ; // set SD data to READ direction
                    widx     <= widx + 1 ; 
                    if ( !sddat_i[0] ) wstate = R_CRC ; // wait for LOW on D0
                    else if ( widx > 8240 ) begin
                        wtimeout <= 1'b1  ;
                        wstate    = WDONE ;
                    end
                end

                R_CRC:  begin // wstate 4 - receive RESPONSE1 bits
                    sd_oe_en          <= 1'b0              ; // set SD data to READ direction
                    crc_s[crc_status] <= sddat_i[0]        ;
                    crc_status        <= crc_status - 3'h1 ;
                    if ( crc_status == 0 ) wstate = W_BUSY ;
                end

                W_BUSY: begin
                    crc_rst    <= 1'b0  ;
                    crc_status <= 3'b0  ;
                    sd_oe_en <= 1'b0 ; // set SD data to READ direction
                    if (crc_s[6:4] == 3'b010) crc_ok <= 1 ;
                    else                      crc_ok <= 0 ;
                    if ( sddat_i[0] ) begin // wait for DAT0 to go HIGH
                        wstate      = WDONE ; // tell CMD_Controller that we're done here
                        crc_c      <= 0     ;
                    end
                end

                WDONE: begin // wrap up
                    sd_oe_en <= 1'b1     ; // set SD data to WRITE direction
                    widx     <= 0        ;
                    wstate   <= W_START  ;
                end

            endcase

        end

    end

end

endmodule
