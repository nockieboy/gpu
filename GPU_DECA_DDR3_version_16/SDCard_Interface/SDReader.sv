/*
    SDReader
    v2.0 by nockieboy

    This HDL is based upon *this project* by *this person* (update these).

    Modified to separate initialisation from reading to optimise block reads.
    The module starts by INITialising the SD card and getting its RCA and card type. These
    are used by SDWriter as well, so need to be obtained.  The SD card is then deselected,
    placing it in Standby-State.

    Subsequent reads (or writes) select the SD card with CMD7, perform their transaction,
    then de-select the card with DESEL, putting the card back into Standy-State.

*/

module SDReader # (
    parameter  CLK_DIV = 1  // when clk = 0~25MHz   , set CLK_DIV to 0,
                            // when clk = 25~50MHz  , set CLK_DIV to 1,
                            // when clk = 50~100MHz , set CLK_DIV to 2,
                            // when clk = 100~200MHz, set CLK_DIV to 3,
                            // when clk = 200~400MHz, set CLK_DIV to 4,
                            // ......
) (
    // clock
    input  logic        clk,
    
    // rst_n active-low
    input  logic        rst_n,
    
    // SDcard signals (connect to SDcard)
    output logic        sdclk,
    output logic        sdcmdout,
    output logic        sdcmdoe,
    input  logic        sdcmdin,
    //inout               sdcmd,
    input  logic [ 3:0] sddat,
    
    // show card status
    output logic [ 1:0] card_type,
    output logic [ 3:0] card_stat,
    output logic [15:0] rca,
    
    // user read sector command interface
    input  logic [ 1:0] MODE,           // 0 = INIT, 1 = READ, 2 = WRITE
    input  logic        rstart, 
    input  logic [31:0] rsector_no,
    output logic        rbusy,
    output logic        rdone,
    
    // sector data output interface
    output logic        outreq,
    output logic [ 8:0] outaddr,  // outaddr from 0 to 511, because the sector size is 512
    output logic [ 7:0] outbyte,
    
    // these signals are direction controls specific to the DECA board
    output  logic       SD_CMD_DIR,     // HIGH = TO SD card, LOW = FROM SD card
    output  logic       SD_D0_DIR,      // HIGH = TO SD card, LOW = FROM SD card
    output  logic       SD_D123_DIR,    // HIGH = TO SD card, LOW = FROM SD card
    output  logic       SD_SEL
);

localparam  SLOWCLKDIV = ( 16'd1 << CLK_DIV ) * 16'd35 ;
localparam  FASTCLKDIV = ( 16'd1 << CLK_DIV )          ;
localparam  CMDTIMEOUT = 15'd500   ; // SD datasheet: Ncr(max) = 64 clock cycles, so 500 cycles is enough
localparam  DATTIMEOUT = 'd1000000 ; // SD datasheet: 1ms is enough to wait for DAT result, here, we set timeout to 1000000 clock cycles = 80ms (when SDCLK=12.5MHz)

// DECA SD direction controls - HIGH for writes to SD card, LOW for reads from SD card
assign  SD_CMD_DIR  = sdcmdoe ;
assign  SD_D0_DIR   = 1'b0    ; // read-only currently
assign  SD_D123_DIR = 1'b0    ; // read-only currently

// SD interface voltage - DECA-specific ******* THIS CAN BE MODIFIED SO 1.8V CARDS ARE SUPPORTED ********
assign  SD_SEL      = 1'b0    ; // LOW = 3.3V, HIGH = 1.8V

wire         sddat0 = sddat[0]         ; // only use 1bit mode of SDDAT
wire  [ 2:0] rlsb   = 3'd7 - ridx[2:0] ;

logic           start       = 1'b0   ;
logic   [  5:0] cmd         = '0     ;
logic   [ 15:0] clkdiv      = 16'd50 ;
logic   [ 15:0] precycles   = '0     ;
logic   [ 31:0] rsectoraddr = '0     ;
logic   [ 31:0] arg         = '0     ;
logic   [ 31:0] ridx        = 0      ;
logic   [ 31:0] resparg              ;
logic   [127:0] resparg_long         ;
logic           busy, done, timeout  ;
logic           syntaxerr            ;
//logic           sdcmdoe, sdcmdout    ;
logic           sdclkl      = 1'b0   ;

//       0     1      2         3      4    5     6      7      8      9       A      B      C        D
enum { CMD0, CMD8, CMD55_41, ACMD41, CMD2, CMD3, CMD7, CMD7F, CMD16, CMD17, ENDSEL, IDLE, READING, READING2 } sdstate = CMD0 ;
enum { UNKNOWN, SDv1, SDv2, SDHCv2, SDv1Maybe } cardtype = UNKNOWN ;
enum { RWAIT, RDURING, RTAIL, RDONE, RTIMEOUT } rstate   = RWAIT   ;

assign rbusy     = (sdstate!=IDLE) | rdone ;
assign card_stat =  sdstate[3:0]           ;
assign card_type = cardtype[1:0]           ;

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

task automatic set_cmd(input _start, input[15:0] _precycles='0, input[15:0] _clkdiv=SLOWCLKDIV, input[5:0] _cmd='0, input[31:0] _arg='0 );
    start     = _start     ;
    precycles = _precycles ;
    clkdiv    = _clkdiv    ;
    cmd       = _cmd       ;
    arg       = _arg       ;
endtask

always @(posedge clk or negedge rst_n) begin
    if ( ~rst_n ) begin
        set_cmd(0)            ;
        rdone       = 1'b0    ;
        rsectoraddr ='0       ;
        sdstate     = CMD0    ; // default state at power-up
        cardtype    = UNKNOWN ;
        rca         = '0      ;
    end else begin
        set_cmd(0)   ;
        rdone = 1'b0 ;
        if ( sdstate == READING2 ) begin
            if ( rstate == RTIMEOUT ) begin
                set_cmd(1, 16 , FASTCLKDIV, 17, rsectoraddr) ;
                sdstate = READING ;
            end
            else if ( rstate == RDONE ) begin
                rdone   = 1'b1   ;
                sdstate = ENDSEL ; // deselect card at end of read
            end
        end else if ( busy ) begin
            if ( done ) begin
                case ( sdstate )
                    CMD0    :   sdstate = CMD8 ;
                    CMD8    :   begin
                                    if ( timeout ) begin
                                        cardtype <= SDv1Maybe ;
                                        sdstate   = CMD55_41  ;
                                    end else if ( ~syntaxerr && resparg[7:0] == 8'hAA ) sdstate  = CMD55_41  ;
                                end
                    CMD55_41:   if ( ~timeout && ~syntaxerr ) sdstate = ACMD41 ;
                    ACMD41  :   begin
                                    if( ~timeout && ~syntaxerr && resparg[31] ) begin
                                        cardtype <= (cardtype==SDv1Maybe) ? SDv1 : (resparg[30] ? SDHCv2 : SDv2) ;
                                        sdstate   = CMD2      ;
                                    end else sdstate  = CMD55_41  ;
                                end
                    CMD2    :   if ( ~timeout && ~syntaxerr ) sdstate = CMD3;
                    CMD3    :   begin
                                    if ( ~timeout && ~syntaxerr ) begin
                                        rca    <= resparg[31:16] ;
                                        sdstate = CMD7           ;
                                    end
                                end
                    CMD7    :   if ( ~timeout && ~syntaxerr ) begin
                                    sdstate = CMD16 ; // INIT
                                end
                    CMD7F   :   if ( ~timeout && ~syntaxerr ) begin
                                    sdstate = CMD17 ; // READ
                                end
                    CMD16   :   if ( ~timeout && ~syntaxerr ) begin
                                    sdstate = ENDSEL; // deselect card at end of init
                                end
                    ENDSEL  :   sdstate = IDLE ;
                    READING :   begin
                                    if ( ~timeout && ~syntaxerr ) sdstate = READING2   ;
                                    else set_cmd(1, 128 , FASTCLKDIV, 17, rsectoraddr) ;
                                end
                endcase
            end
        end else begin
            case ( sdstate )
                CMD0    :   set_cmd( 1, 99999 , SLOWCLKDIV,  0, 'h00000000  ) ; // GO_IDLE_STATE
                CMD8    :   set_cmd( 1, 20    , SLOWCLKDIV,  8, 'h000001AA  ) ; // SEND_IF_COND
                CMD55_41:   set_cmd( 1, 20    , SLOWCLKDIV, 55, 'h00000000  ) ; //
                ACMD41  :   set_cmd( 1, 20    , SLOWCLKDIV, 41, 'hC0100000  ) ; // SEND_OP_COND
                CMD2    :   set_cmd( 1, 20    , SLOWCLKDIV,  2, 'h00000000  ) ; // ALL_SEND_CID
                CMD3    :   set_cmd( 1, 20    , SLOWCLKDIV,  3, 'h00000000  ) ; // SEND_RELATIVE_ADDR
                CMD7    :   set_cmd( 1, 20    , SLOWCLKDIV,  7, {rca,16'h0} ) ; // SELECT CARD
                CMD7F   :   set_cmd( 1, 20    , FASTCLKDIV,  7, {rca,16'h0} ) ; // SELECT CARD FAST CLOCK
                CMD16   :   set_cmd( 1, 99999 , FASTCLKDIV, 16, 'h00000200  ) ; // SET_BLOCKLEN
                CMD17   :   begin
                    rsectoraddr = ( cardtype == SDHCv2 ) ? rsector_no : ( rsector_no*512 );
                    set_cmd ( 1, 32 , FASTCLKDIV, 17, rsectoraddr ) ; // READ_SINGLE_BLOCK
                    sdstate = READING ;
                end
                ENDSEL  :   set_cmd( 1, 20    , FASTCLKDIV,  7, 'h00000000 ) ; // DESELECT ALL CARDS
                IDLE    :   if ( rstart & ~rbusy ) sdstate = CMD7F ; // start RD off with SD card select
            endcase
        end
    end
end

always @( posedge clk or negedge rst_n ) begin

    if ( ~rst_n ) begin

        outaddr = '0    ;
        outbyte = '0    ;
        outreq  = 1'b0  ;
        ridx    = '0    ;
        rstate  = RWAIT ;
        sdclkl  <= 1'b0 ;

    end else begin

        sdclkl <= sdclk ;
        outreq  = 1'b0  ;
        outaddr = '0    ;

        if ( sdstate != READING && sdstate != READING2 ) begin

            rstate = RWAIT ;
            ridx   = 0     ;

        end else if ( ~sdclkl & sdclk ) begin  // on rising edge of sdclk

            case ( rstate )
                RWAIT:  begin
                    if ( ~sddat0 ) begin
                        rstate = RDURING  ;
                        ridx   = 0        ;
                    end else if ( ( ++ridx ) > DATTIMEOUT ) begin
                        rstate = RTIMEOUT ;
                    end
                end
                RDURING: begin
                    outbyte[rlsb] = sddat0 ;
                    if ( rlsb == 3'd0 ) begin
                        outreq  = 1          ;
                        outaddr = ridx[11:3] ;
                    end
                    if ( ( ++ridx ) >= 512*8 ) begin
                        rstate = RTAIL ;
                        ridx   = 0     ;
                    end
                end
                RTAIL:  begin
                    if ( ( ++ridx ) >= 8*8 ) begin
                        rstate = RDONE ;
                    end
                end
            endcase

        end

    end

end

endmodule

