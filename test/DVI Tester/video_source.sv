module video_source(
    // inputs
    input        clk,       // 25MHz pixel clock
    input        clk_TMDS,  // 250MHz TDMS clock
    // outputs
    output [2:0] TMDSp,     // TMDS data out
    output [2:0] TMDSn,
    output       TMDS_CLKp, // pixel clock out
    output       TMDS_CLKn
    
);

reg [9:0] x, y ; // horizontal & vertical pixel counters
reg hSync      ;
reg vSync      ;
reg D_EN       ; // Display ENable

/* Create timing signals for a valid 640x480 display.
 *
 * This requires D_EN to be enabled when the raster is
 * within the visible display area and for the raster
 * counters (X and Y) to be updated and reset according
 * to their position on the screen.
 *
 * hSync and vSync should also go high according to the
 * specifications outlined for the 640x480 video mode.
 */
always @(posedge clk) begin

    D_EN <= ( x < 640 ) && ( y < 480 ) ; // enable display if pixel counters are in visible display area
    x    <= ( x == 799 ) ? 0 : x + 1   ; // increment horizontal pixel counter, or reset if at end of line
    
    if( x == 799 ) begin // horizontal pixel counter has reached end of row
        if ( y == 524 ) begin
            y <= 0     ; // reset vertical pixel counter
        end else begin
            y <= y + 1 ; // increment vertical pixel counter
        end
    end
    
    hSync <= ( x >= 656 ) && ( x < 752 ) ; // hSync goes HIGH when horizontal pixel counter is between 655 and 752
    vSync <= ( y >= 490 ) && ( y < 492 ) ; // vSync goes HIGH when vertical pixel counter is between 489 and 492
    
end

wire [7:0] W = {8{x[7:0]==y[7:0]}} ;
wire [7:0] A = {8{x[7:5]==3'h2 && y[7:5]==3'h2}} ;
reg  [7:0] red   ;
reg  [7:0] green ;
reg  [7:0] blue  ;

// Create a display pattern
always @(posedge clk) begin

    red   <= ( { x[5:0] & { 6 { y[4:3] == ~x[4:3] } }, 2'b00 } | W ) & ~A ;
    green <= ( x[7:0] & { 8{ y[6] } } | W ) & ~A ;
    blue  <= y[7:0] | W | A ;
    
end

//
// Create three TMDS_encoder instances to handle the Red, Green, Blue and Control signals
//
wire [9:0] TMDS_red   ;
wire [9:0] TMDS_green ;
wire [9:0] TMDS_blue  ;

TMDS_encoder encode_R(
    .clk ( clk      ),
    .VD  ( red      ),
    .CD  ( 2'b00    ),
    .VDE ( D_EN     ),
    .TMDS( TMDS_red )
);
TMDS_encoder encode_G(
    .clk ( clk        ),
    .VD  ( green      ),
    .CD  ( 2'b00      ),
    .VDE ( D_EN       ),
    .TMDS( TMDS_green )
);
TMDS_encoder encode_B(
    .clk ( clk              ),
    .VD  ( blue             ),
    .CD  ( { vSync, hSync } ),
    .VDE ( D_EN             ),
    .TMDS( TMDS_blue        )
);

//
// Multiply 25MHz clock by 10 to generate a 250MHz clock
//wire clk_TMDS       ;
//wire DCM_TMDS_CLKFX ; // 25MHz x 10 = 250MHz

//DCM_SP #(.CLKFX_MULTIPLY(10)) DCM_TMDS_inst(.CLKIN(clk), .CLKFX(DCM_TMDS_CLKFX), .RST(1'b0) ) ;
//BUFG BUFG_TMDSp(.I(DCM_TMDS_CLKFX), .O(clk_TMDS)) ;

//
// Create three 10-bit shift registers running at 250MHz
reg [3:0] TMDS_mod10       = 0 ; // modulus 10 counter
reg [9:0] TMDS_shift_red   = 0 ;
reg [9:0] TMDS_shift_green = 0 ;
reg [9:0] TMDS_shift_blue  = 0 ;
reg       TMDS_shift_load  = 0 ;

always @(posedge clk_TMDS) begin

    TMDS_shift_load  <= ( TMDS_mod10 == 4'd9 )                                    ;
    TMDS_shift_red   <= TMDS_shift_load ? TMDS_red    : TMDS_shift_red  [9:1]     ;
    TMDS_shift_green <= TMDS_shift_load ? TMDS_green  : TMDS_shift_green[9:1]     ;
    TMDS_shift_blue  <= TMDS_shift_load ? TMDS_blue   : TMDS_shift_blue [9:1]     ;
    TMDS_mod10       <= ( TMDS_mod10 == 4'd9 ) ? 4'd0 : TMDS_mod10 + 4'd1         ;
    
end

OBUFDS OBUFDS_red  ( .I( TMDS_shift_red  [0] ),  .O( TMDSp[2] ), .OB( TMDSn[2] ) ) ;
OBUFDS OBUFDS_green( .I( TMDS_shift_green[0] ),  .O( TMDSp[1] ), .OB( TMDSn[1] ) ) ;
OBUFDS OBUFDS_blue ( .I( TMDS_shift_blue [0] ),  .O( TMDSp[0] ), .OB( TMDSn[0] ) ) ;
OBUFDS OBUFDS_clock( .I( clk ), .O( TMDS_CLKp ), .OB( TMDS_CLKn ) )                ;

endmodule

//*********************************************************************************************************
//
// TMDS Encoder Module
//
//*********************************************************************************************************
module TMDS_encoder(
    input            clk,
    input      [7:0] VD,      // video data (red, green or blue)
    input      [1:0] CD,      // control data
    input            VDE,     // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
    output reg [9:0] TMDS = 0
);

wire [3:0] Nb1s            = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7]                                   ;
wire       XNOR            = ( Nb1s > 4'd4 ) || ( Nb1s == 4'd4 && VD[0] == 1'b0 )                                            ;
wire [8:0] q_m             = { ~XNOR, q_m[6:0] ^ VD[7:1] ^ { 7{ XNOR } }, VD[0] }                                            ;
reg  [3:0] balance_acc     = 0                                                                                               ;
wire [3:0] balance         = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4                    ;
wire       balance_sign_eq = ( balance[3] == balance_acc[3] )                                                                ;
wire       invert_q_m      = ( balance == 0 || balance_acc == 0 ) ? ~q_m[8] : balance_sign_eq                                ;
wire [3:0] balance_acc_inc = balance - ( { q_m[8] ^ ~balance_sign_eq } & ~( balance == 0 || balance_acc == 0 ) )             ;
wire [3:0] balance_acc_new = invert_q_m ? balance_acc-balance_acc_inc : balance_acc + balance_acc_inc                        ;
wire [9:0] TMDS_data       = { invert_q_m, q_m[8], q_m[7:0] ^ { 8{ invert_q_m } } }                                          ;
wire [9:0] TMDS_code       = CD[1] ? (CD[0] ? 10'b1010101011 : 10'b0101010100) : ( CD[0] ? 10'b0010101011 : 10'b1101010100 ) ;

always @(posedge clk) begin

    TMDS        <= VDE ? TMDS_data : TMDS_code  ;
    balance_acc <= VDE ? balance_acc_new : 4'h0 ;
    
end

endmodule
