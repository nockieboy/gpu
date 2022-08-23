module sd_data_serial_host(

    parameter   BLKSIZE = 12'd512,
    parameter   CLK_DIV = 3, // when clk = 0~25MHz   , set CLK_DIV to 0,
                             // when clk = 25~50MHz  , set CLK_DIV to 1,
                             // when clk = 50~100MHz , set CLK_DIV to 2,
                             // when clk = 100~200MHz, set CLK_DIV to 3,
                             // when clk = 200~400MHz, set CLK_DIV to 4,
                             // ......
    parameter   SIMULATION = 0

) (

    input  logic            clk,            // 125 MHz clock
    input  logic            rst_n,          // !RESET in SDInterface module
    // Tx Fifo - FROM SDInterface
    input  logic    [31:0]  data_in,        // data from BYTESTREAM in SDInterface module
    output logic            rd,             // cache request (no direct parallel in SDInterface module)
    // Rx Fifo - TO SDInterface
    //output logic    [31:0]  data_out,       // SD_dat in SDInterface module
    output logic    [ 7:0]  data_out,       // SD_dat in SDInterface module
    output logic            we,             // cache_wren in SDInterface module
    // SDcard signals (connect to SDcard)
    output logic            sdclk,
    output logic            sdcmdout,
    output logic            sdcmdoe,
    input  logic            sdcmdin,
    // tristate data
    output logic            DAT_oe_o,       // WR_ENA in SDInterface module
    output logic    [ 3:0]  DAT_dat_o,      // wr_sd_data
    input  logic    [ 3:0]  DAT_dat_i,      // rd_sd_data
    // user read sector command interface
    input  logic            rstart, 
    input  logic    [31:0]  rsector_no,
    output logic            rbusy,
    output logic            rdone,
    // show card status
    output logic    [ 1:0]  card_type,
    // Control signals
    input  logic    [11:0]  blksize,        // could be fixed to 512, or a parameter
    input  logic            bus_4bit,       // could be a parameter, or a signal from SDInterface module
    input  logic    [11:0]  blkcnt,         // could be fixed to 1, or a signal from SDInterface module
    input  logic    [ 1:0]  start,          // signal from SDInterface module to initiate RD/WR
    input  logic    [ 1:0]  byte_alignment, // ** no parallel in SDInterface module
    output logic            sd_data_busy,   // SD_BUSY in SDInterface module
    output logic            busy,           // BUSY in SDInterface module
    output logic            crc_ok          // ** no parallel in SDInterface module

);

parameter IDLE       = 6'd0 ;
parameter READ_DAT   = 6'd1 ;
parameter READ_WAIT  = 6'd2 ;
parameter WRITE_BUSY = 6'd3 ;
parameter WRITE_CRC  = 6'd4 ;
parameter WRITE_DAT  = 6'd5 ;

localparam  SLOWCLKDIV = (16'd1<<CLK_DIV)*16'd35 ;
localparam  FASTCLKDIV = (16'd1<<CLK_DIV)        ;
localparam  CMDTIMEOUT = 15'd500                 ; // according to SD datasheet, Ncr(max) = 64 clock cycles, so 500 cycles is enough
localparam  DATTIMEOUT = 'd1000000               ; // according to SD datasheet, 1ms is enough to wait for DAT result, here, we set timeout to 1000000 clock cycles = 80ms (when SDCLK=12.5MHz)

task automatic set_cmd(input _start, input[15:0] _precycles='0, input[15:0] _clkdiv=SLOWCLKDIV, input[5:0] _cmd='0, input[31:0] _arg='0 );
    start     = _start     ;
    precycles = _precycles ;
    clkdiv    = _clkdiv    ;
    cmd       = _cmd       ;
    arg       = _arg       ;
endtask

enum logic [3:0] {
        IDLE,
        CMD0,
        CMD8,
        CMD55_41,
        ACMD41,
        CMD2,
        CMD3,
        CMD7,
        CMD16,
        READ_DAT,
        READ_WAIT,
        WRITE_BUSY,
        WRITE_CRC,
        WRITE_DAT
} state ;

enum { UNKNOWN, SDv1, SDv2, SDHCv2, SDv1Maybe } cardtype = UNKNOWN ;

logic   [ 3:0]  DAT_dat_reg          ;
logic   [14:0]  data_cycles          ;
logic           bus_4bit_reg         ;
//CRC16
logic   [ 3:0]  crc_in               ;
logic           crc_en               ;
logic           crc_rst              ;
wire    [15:0]  crc_out [3:0]        ;
//
logic   [15:0]  transf_cnt           ;
//logic   [SIZE-1:0]  state              ;
logic   [ 3:0]  next_state           ;
logic   [ 1:0]  crc_status           ;
logic           busy_int             ;
logic   [15:0]  blkcnt_reg           ;
logic   [ 1:0]  byte_alignment_reg   ;
logic   [11:0]  blksize_reg          ;
logic           next_block           ;
wire            start_bit            ;
logic   [ 4:0]  crc_c                ;
logic   [ 3:0]  last_din             ;
logic   [ 2:0]  crc_s                ;
logic   [ 4:0]  data_index           ;

// imported from SDReader.sv
logic           start       = 1'b0   ;
logic   [  5:0] cmd         = '0     ;
logic   [ 15:0] clkdiv      = 16'd50 ;
logic   [ 15:0] precycles   = '0     ;
logic   [ 15:0] rca         = '0     ;
logic   [ 31:0] rsectoraddr = '0     ;
logic   [ 31:0] arg         = '0     ;

assign card_type = cardtype[1:0]     ;

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

//sd data input pad register
always @(posedge sdclk)
    DAT_dat_reg <= DAT_dat_i;

genvar i;
generate
    for(i=0; i<4; i=i+1) begin: CRC_16_gen
        sd_crc_16 CRC_16_i (crc_in[i],crc_en, sdclk, crc_rst, crc_out[i]);
    end
endgenerate

assign busy         = (state != IDLE) ;
assign start_bit    = !DAT_dat_reg[0] ;
assign sd_data_busy = !DAT_dat_reg[0] ;

always @(state or start or start_bit or transf_cnt or data_cycles or crc_status or crc_ok or busy_int or next_block)
begin: FSM_COMBO
    if ( ~rst_n ) begin

        cardtype    = UNKNOWN ;
        rca         = '0      ;
        rdone       = 1'b0    ;

    end else if ( busy ) begin
        // This section deals with the results of a CMD being sent to the SD card.
        if ( done ) begin // done goes HIGH when set_cmd completes
            case(state)
                CMD0: begin
                    next_state = CMD8 ;
                end
                CMD8: begin
                    if ( timeout ) begin
                        cardtype   = SDv1Maybe ;
                        next_state = CMD55_41  ;
                    end else if ( ~syntaxerr && resparg[7:0] == 8'hAA ) next_state = CMD55_41  ;
                end
                CMD55_41: begin
                    if ( ~timeout && ~syntaxerr ) next_state = ACMD41 ;
                end
                ACMD41: begin
                    if( ~timeout && ~syntaxerr && resparg[31] ) begin
                        cardtype    = (cardtype==SDv1Maybe) ? SDv1 : (resparg[30] ? SDHCv2 : SDv2) ;
                        next_state  = CMD2 ;
                    end else next_state  = CMD55_41  ;
                end
                CMD2: begin
                    if ( ~timeout && ~syntaxerr ) next_state = CMD3;
                end
                CMD3: begin
                    if ( ~timeout && ~syntaxerr ) begin
                        rca        = resparg[31:16] ;
                        next_state = CMD7           ;
                    end
                end
                CMD7:   if ( ~timeout && ~syntaxerr ) next_state = CMD16 ;
                CMD16:  if ( ~timeout && ~syntaxerr ) next_state = IDLE  ;
                READ_START: begin
                    if ( ~timeout && ~syntaxerr ) sdstate = READ_WAIT  ;
                    else set_cmd(1, 128 , FASTCLKDIV, 17, rsectoraddr) ;
                end
            endcase
        end

    end else begin

        case (state)
            CMD0    :   set_cmd( 1, 99999 , SLOWCLKDIV,  0, 'h00000000  ) ; // GO_IDLE_STATE
            CMD8    :   set_cmd( 1, 20    , SLOWCLKDIV,  8, 'h000001AA  ) ; // SEND_IF_COND
            CMD55_41:   set_cmd( 1, 20    , SLOWCLKDIV, 55, 'h00000000  ) ; //
            ACMD41  :   set_cmd( 1, 20    , SLOWCLKDIV, 41, 'hC0100000  ) ; // SEND_OP_COND
            CMD2    :   set_cmd( 1, 20    , SLOWCLKDIV,  2, 'h00000000  ) ; // ALL_SEND_CID
            CMD3    :   set_cmd( 1, 20    , SLOWCLKDIV,  3, 'h00000000  ) ; // SEND_RELATIVE_ADDR
            CMD7    :   set_cmd( 1, 20    , SLOWCLKDIV,  7, {rca,16'h0} ) ; // SELECT/DESELECT_CARD
            CMD16   :   set_cmd( 1, 99999 , FASTCLKDIV, 16, 'h00000200  ) ; // SET_BLOCKLEN
            IDLE: begin
                if      (start == 2'b01) next_state = WRITE_DAT ; // WR OP
                else if (start == 2'b10) next_state = READ_INIT ; // RD OP
                else if (start == 2'b11) next_state = CMD0      ; // INIT
                else                     next_state = IDLE      ; // IDLE
            end
            WRITE_DAT: begin
                if (transf_cnt >= data_cycles+21 && start_bit) next_state = WRITE_CRC ;
                else                                           next_state = WRITE_DAT ;
            end
            WRITE_CRC: begin
                if (crc_status == 3) next_state = WRITE_BUSY ;
                else                 next_state = WRITE_CRC  ;
            end
            WRITE_BUSY: begin
                if      (!busy_int && next_block && crc_ok) next_state = WRITE_DAT  ;
                else if (!busy_int)                         next_state = IDLE       ;
                else                                        next_state = WRITE_BUSY ;
            end
            READ_INIT : begin
                if ( rstart & ~rbusy ) begin 
                    rsectoraddr = ( cardtype == SDHCv2 ) ? rsector_no : ( rsector_no*512 );
                    set_cmd ( 1, 32 , FASTCLKDIV, 17, rsectoraddr ) ; // READ_SINGLE_BLOCK
                    sdstate = READ_START ;
                end
            end
            READ_WAIT: begin
                if (start_bit) next_state = READ_DAT  ;
                else           next_state = READ_WAIT ;
            end
            READ_DAT: begin
                if (transf_cnt == data_cycles+17 && next_block && crc_ok)
                    next_state  = READ_WAIT ;
                else if (transf_cnt == data_cycles+17) begin
                    next_state = IDLE ;
                    rdone      = 1'b1 ;
                end
                else next_state = READ_DAT  ;
            end
            default: next_state = IDLE      ;
        endcase
        //abort
        if (start == 2'b11) next_state = IDLE ;

    end
end

always @(posedge sdclk or negedge rst_n) begin: FSM_OUT

    if ( ~rst_n ) begin
        state              <= IDLE ;
        DAT_oe_o           <= 0    ;
        crc_en             <= 0    ;
        crc_rst            <= 1    ;
        transf_cnt         <= 0    ; // transmission bit counter
        crc_c              <= 15   ;
        rd                 <= 0    ;
        last_din           <= 0    ;
        crc_c              <= 0    ;
        crc_in             <= 0    ;
        DAT_dat_o          <= 0    ;
        crc_status         <= 0    ;
        crc_s              <= 0    ;
        we                 <= 0    ;
        data_out           <= 0    ;
        crc_ok             <= 0    ;
        busy_int           <= 0    ;
        data_index         <= 0    ;
        next_block         <= 0    ;
        blkcnt_reg         <= 0    ;
        blksize_reg        <= 0    ;
        byte_alignment_reg <= 0    ;
        data_cycles        <= 0    ; // block size in bits plus 8 bits/1 byte (presumably for the CRC)
        bus_4bit_reg       <= 0    ;      
    end
    else begin
        state <= next_state;
        case(state)
            IDLE: begin
                DAT_oe_o     <= 0  ;
                DAT_dat_o    <= 4'b1111 ;
                crc_en       <= 0  ;
                crc_rst      <= 1  ;
                transf_cnt   <= 0  ;
                crc_c        <= 16 ;
                crc_status   <= 0  ;
                crc_s        <= 0  ;
                we           <= 0  ;
                rd           <= 0  ;
                data_index   <= 0  ;
                next_block   <= 0  ;
                blkcnt_reg   <= blkcnt   ;
                byte_alignment_reg <= byte_alignment ;
                blksize_reg  <= blksize  ;
                data_cycles  <= (bus_4bit ? (blksize << 1) + `BLKSIZE_W'd2 : (blksize << 3) + `BLKSIZE_W'd8) ;
                bus_4bit_reg <= bus_4bit ;
            end
            WRITE_DAT: begin
                crc_ok     <= 0 ;
                transf_cnt <= transf_cnt + 16'h1 ;
                next_block <= 0 ;
                rd <= 0;
                //special case
                if (transf_cnt == 0 && byte_alignment_reg == 2'b11 && bus_4bit_reg) begin
                    rd <= 1;
                end
                else if (transf_cnt == 1) begin
                    crc_rst <= 0 ;
                    crc_en  <= 1 ;
                    if (bus_4bit_reg) begin
                        last_din <= {
                            data_in[31-(byte_alignment_reg << 3)], 
                            data_in[30-(byte_alignment_reg << 3)], 
                            data_in[29-(byte_alignment_reg << 3)], 
                            data_in[28-(byte_alignment_reg << 3)]
                        };
                        crc_in <= {
                            data_in[31-(byte_alignment_reg << 3)], 
                            data_in[30-(byte_alignment_reg << 3)], 
                            data_in[29-(byte_alignment_reg << 3)], 
                            data_in[28-(byte_alignment_reg << 3)]
                        };
                    end
                    else begin
                        // last_din is the value to be written to DAT0
                        // the array below ensures DAT1-3 are HIGH, whatever value is on DAT0
                        last_din <= {3'h7, data_in[31-(byte_alignment_reg << 3)]} ;
                        crc_in   <= {3'h7, data_in[31-(byte_alignment_reg << 3)]} ;
                    end
                    DAT_oe_o   <= 1 ;
                    DAT_dat_o  <= bus_4bit_reg ? 4'h0 : 4'hE ; // set DAT1-3 HIGH, DAT0 LOW in 1-bit mode
                    data_index <= bus_4bit_reg ? {2'b00, byte_alignment_reg, 1'b1} : {byte_alignment_reg, 3'b001} ;
                end
                else if ((transf_cnt >= 2) && (transf_cnt <= data_cycles+1)) begin
                    DAT_oe_o <= 1 ;
                    if (bus_4bit_reg) begin
                        last_din <= {
                            data_in[31-(data_index[2:0]<<2)], 
                            data_in[30-(data_index[2:0]<<2)], 
                            data_in[29-(data_index[2:0]<<2)], 
                            data_in[28-(data_index[2:0]<<2)]
                        };
                        crc_in <= {
                            data_in[31-(data_index[2:0]<<2)], 
                            data_in[30-(data_index[2:0]<<2)], 
                            data_in[29-(data_index[2:0]<<2)], 
                            data_in[28-(data_index[2:0]<<2)]
                        };
                        if (data_index[2:0] == 3'h5/*not 7 - read delay !!!*/ && transf_cnt <= data_cycles-1) begin
                            rd <= 1;
                        end
                    end
                    else begin
                        last_din <= {3'h7, data_in[31-data_index]} ;
                        crc_in   <= {3'h7, data_in[31-data_index]} ;
                        if (data_index == 29/*not 31 - read delay !!!*/) begin
                            rd <= 1;
                        end
                    end
                    data_index <= data_index + 5'h1 ;
                    DAT_dat_o  <= last_din          ;
                    if (transf_cnt == data_cycles+1) crc_en <= 0 ;
                end
                else if (transf_cnt > data_cycles+1 & crc_c!=0) begin
                    crc_en       <= 0            ;
                    crc_c        <= crc_c - 5'h1 ;
                    DAT_oe_o     <= 1            ;
                    DAT_dat_o[0] <= crc_out[0][crc_c-1] ;
                    if (bus_4bit_reg)
                        DAT_dat_o[3:1]  <= {crc_out[3][crc_c-1], crc_out[2][crc_c-1], crc_out[1][crc_c-1]} ;
                    else DAT_dat_o[3:1] <= {3'h7} ;
                end
                else if (transf_cnt == data_cycles+18) begin
                    DAT_oe_o  <= 1    ;
                    DAT_dat_o <= 4'hF ;
                end
                else if (transf_cnt >= data_cycles+19) DAT_oe_o <= 0 ;
            end
            WRITE_CRC: begin
                DAT_oe_o   <= 0 ;
                if (crc_status < 3) crc_s[crc_status] <= DAT_dat_reg[0] ;
                crc_status <= crc_status + 2'h1 ;
                busy_int   <= 1 ;
            end
            WRITE_BUSY: begin
                if (crc_s == 3'b010) crc_ok <= 1 ;
                else                 crc_ok <= 0 ;
                if (next_state != WRITE_BUSY) begin
                    blkcnt_reg         <= blkcnt_reg - `BLKCNT_W'h1 ;
                    byte_alignment_reg <= byte_alignment_reg + blksize_reg[1:0] + 2'b1 ;
                    crc_rst            <= 1  ;
                    crc_c              <= 16 ;
                    crc_status         <= 0  ;
                end
                busy_int   <= !DAT_dat_reg[0]    ;
                next_block <= (blkcnt_reg != 0)  ;
                transf_cnt <= 0 ;
            end
            READ_WAIT: begin
                DAT_oe_o   <= 0  ;
                crc_rst    <= 0  ;
                crc_en     <= 1  ;
                crc_in     <= 0  ;
                crc_c      <= 15 ; // end
                next_block <= 0  ;
                transf_cnt <= 0  ;
                //data_index <= bus_4bit_reg ? (byte_alignment_reg << 1) : (byte_alignment_reg << 3) ;
                data_index <= bus_4bit_reg ? (byte_alignment_reg << 1) : (byte_alignment_reg << 1) ;
            end
            READ_DAT: begin
                if (transf_cnt < data_cycles) begin
                    if (bus_4bit_reg) begin
                        we <= (data_index[2:0] == 7 || (transf_cnt == data_cycles-1  && !(|blkcnt_reg))) ;
                        //data_out[31-(data_index[2:0]<<2)] <= DAT_dat_reg[3] ;
                        //data_out[30-(data_index[2:0]<<2)] <= DAT_dat_reg[2] ;
                        //data_out[29-(data_index[2:0]<<2)] <= DAT_dat_reg[1] ;
                        //data_out[28-(data_index[2:0]<<2)] <= DAT_dat_reg[0] ;
                    end
                    else begin
                        //we <= (data_index == 31 || (transf_cnt == data_cycles-1  && !(|blkcnt_reg))) ;
                        we <= (data_index == 7 || (transf_cnt == data_cycles-1  && !(|blkcnt_reg))) ;
                        //data_out[31-data_index] <= DAT_dat_reg[0] ;
                        data_out[7-data_index] <= DAT_dat_reg[0] ;
                    end
                    data_index <= data_index + 5'h1  ;
                    crc_in     <= DAT_dat_reg        ;
                    crc_ok     <= 1                  ;
                    transf_cnt <= transf_cnt + 16'h1 ;
                end
                else if (transf_cnt <= data_cycles+16) begin
                    transf_cnt <= transf_cnt + 16'h1 ;
                    crc_en     <= 0                  ;
                    last_din   <= DAT_dat_reg        ;
                    we<=0;
                    if (transf_cnt > data_cycles) begin
                        crc_c  <= crc_c - 5'h1       ;
                        if (crc_out[0][crc_c] != last_din[0])                 crc_ok <= 0 ;
                        if (crc_out[1][crc_c] != last_din[1] && bus_4bit_reg) crc_ok <= 0 ;
                        if (crc_out[2][crc_c] != last_din[2] && bus_4bit_reg) crc_ok <= 0 ;
                        if (crc_out[3][crc_c] != last_din[3] && bus_4bit_reg) crc_ok <= 0 ;
                        if (crc_c == 0) begin
                            next_block         <= (blkcnt_reg != 0)                            ;
                            blkcnt_reg         <= blkcnt_reg - `BLKCNT_W'h1                    ;
                            byte_alignment_reg <= byte_alignment_reg + blksize_reg[1:0] + 2'b1 ;
                            crc_rst            <= 1                                            ;
                        end
                    end
                end
            end
        endcase
    end
end

endmodule
