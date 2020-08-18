module pixel_address_generator (

    // inputs
    input logic        clk,              // System clock
    input logic        reset,            // Force reset
    
    input logic        draw_cmd_rdy,     // Pulsed HIGH when data on draw_cmd[15:0] is valid
    input logic[35:0]  draw_cmd,         // Bits [35:32] hold AUX function number 0-15:
    input logic        draw_busy,        // HIGH when pixel writer is busy

    // outputs
    output logic       pixel_cmd_rdy,
    output logic[39:0] pixel_cmd,
    output logic       pix_adr_busy
// pixel_cmd format:
// 3     3 3             2 2     2 2     2 1                                     0
// 9     6 5             8 7     4 3     0 9                                     0
// |     | |             | |     | |     | |                                     |
// 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
// |-CMD-| |----COLOUR---| |WIDTH| |-BIT-| |-----------MEMORY ADDRESS------------|
//
// Where CMD:
// bit 36 = COLOUR (HIGH for colour data included, LOW for none)
// bit 35 = WRITE bit (HIGH for WR, LOW for RD)
// bit 34 = TRANSPARENT bit (HIGH for transparent mask, LOW for none, ignored if bit 35 is LOW)
// bit 33 = READ/MODIFY/WRITE (ignored if bit 35 is LOW)
//
// WIDTH is bits per pixel (screen mode)
//
// BIT is the bit in the addressed word that is the target of the RD/WR operation
//
    
);

// 3     3 3             2 2               1     1 1     0 0             0
// 5     2 1             4 3               5     2 1     8 7             0
// |     | |             | |               |     | |     | |             |
// 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
// |AUX01| |----COLOUR---| |-----Y COORDINATE----| |-----X COORDINATE----|
// |AUX02| |----COLOUR---| |-----Y COORDINATE----| |-----X COORDINATE----|
// |AUX03|                 |-----Y COORDINATE----| |-----X COORDINATE----|
// |AUX04|                 |-----Y COORDINATE----| |-----X COORDINATE----|
// ...
// |AUX06|                 |-----Y COORDINATE----| |-----X COORDINATE----|  READ
// |AUX07| |-ALPHA BLEND-| |-------------24-bit RGB COLOUR---------------|
// ...
// |AUX10| |-TRANSP MASK-| |RGB 24-bit MASK COLOUR OR 3 ADD TRANS COLOURS|
// |AUX11| |-TRANSP MASK-| |RGB 24-bit MASK COLOUR OR 3 ADD TRANS COLOURS|
// |AUX12| |BITPLANE MODE|                 |---DEST RASTER IMAGE WIDTH---|
// |AUX13| |BITPLANE MODE|                 |--SOURCE RASTER IMAGE WIDTH--|
// |AUX14|                 |-------DESTINATION BASE MEMORY ADDRESS-------|
// |AUX15|                 |----------SOURCE BASE MEMORY ADDRESS---------|
//

logic [2:0] LUT_bits_to_shift[0:15] = '{ 4,3,3,2,2,2,2,1,1,1,1,1,1,1,1,0 };  // shift bits/pixel-1  0=1 bit, 1=2bit, 3=4bit, 7=8bit, 15-16bit.
/*
localparam CMD_IN_NOP           = 0;
localparam CMD_IN_PXWRI         = 1;
localparam CMD_IN_PXWRI_M       = 2;
localparam CMD_IN_PXPASTE       = 3;
localparam CMD_IN_PXPASTE_M     = 4;

localparam CMD_IN_PXCOPY        = 6;
localparam CMD_IN_SETARGB       = 7;

localparam CMD_IN_RST_PXWRI_M   = 10;
localparam CMD_IN_RST_PXPASTE_M = 11;
localparam CMD_IN_DSTRWDTH      = 12;
localparam CMD_IN_SRCRWDTH      = 13;
localparam CMD_IN_DSTMADDR      = 14;
localparam CMD_IN_SRCMADDR      = 15;

// CMD_OUT:
localparam CMD_OUT_NOP           = 0;
localparam CMD_OUT_PXWRI         = 1;
localparam CMD_OUT_PXWRI_M       = 2;
localparam CMD_OUT_PXPASTE       = 3;
localparam CMD_OUT_PXPASTE_M     = 4;
localparam CMD_OUT_PXCOPY        = 6;
localparam CMD_OUT_SETARGB       = 7;
localparam CMD_OUT_RST_PXWRI_M   = 10;
localparam CMD_OUT_RST_PXPASTE_M = 11;
*/
logic [3:0] CMD_IN_NOP           = 0;
logic [3:0] CMD_IN_PXWRI         = 1;
logic [3:0] CMD_IN_PXWRI_M       = 2;
logic [3:0] CMD_IN_PXPASTE       = 3;
logic [3:0] CMD_IN_PXPASTE_M     = 4;

logic [3:0] CMD_IN_PXCOPY        = 6;
logic [3:0] CMD_IN_SETARGB       = 7;

logic [3:0] CMD_IN_RST_PXWRI_M   = 10;
logic [3:0] CMD_IN_RST_PXPASTE_M = 11;
logic [3:0] CMD_IN_DSTRWDTH      = 12;
logic [3:0] CMD_IN_SRCRWDTH      = 13;
logic [3:0] CMD_IN_DSTMADDR      = 14;
logic [3:0] CMD_IN_SRCMADDR      = 15;

// CMD_OUT:
logic [3:0] CMD_OUT_NOP           = 0;
logic [3:0] CMD_OUT_PXWRI         = 1;
logic [3:0] CMD_OUT_PXWRI_M       = 2;
logic [3:0] CMD_OUT_PXPASTE       = 3;
logic [3:0] CMD_OUT_PXPASTE_M     = 4;
logic [3:0] CMD_OUT_PXCOPY        = 6;
logic [3:0] CMD_OUT_SETARGB       = 7;
logic [3:0] CMD_OUT_RST_PXWRI_M   = 10;
logic [3:0] CMD_OUT_RST_PXPASTE_M = 11;



logic[23:0] dest_base_address_offset ;
logic[23:0] srce_base_address_offset ;
logic[23:0] s2_dest_base_address_offset ;
logic[23:0] s2_srce_base_address_offset ;
logic[3:0]  dest_target_bit ;
logic[3:0]  srce_target_bit ;
logic[3:0]  aux_cmd_in ;
logic[7:0]  bit_mode ;
logic[7:0]  s2_bit_mode ;
logic[11:0] x ;
logic[11:0] y ;
logic[11:0] s2_x ;
logic[11:0] s2_y ;
logic[11:0] s3_x ;
logic[11:0] s3_y ;

// internal registers
logic[3:0]  dest_bits_per_pixel = 4'b0  ; // how many bits make up one pixel (1-16) - screen mode
logic[3:0]  srce_bits_per_pixel = 4'b0  ; // how many bits make up one pixel (1-16) - screen mode
//
logic[15:0] dest_rast_width     = 16'b0 ; // number of bits in a horizontal raster line
logic[15:0] srce_rast_width     = 16'b0 ; // number of bits in a horizontal raster line
//
logic[23:0] dest_base_address   = 24'b0 ; // points to first byte in the graphics display memory
logic[23:0] srce_base_address   = 24'b0 ; // points to first byte in the graphics display memory

logic[19:0] dest_address   = 20'b0 ; // points to first byte in the graphics display memory
logic[19:0] srce_address   = 20'b0 ; // points to first byte in the graphics display memory

// Logic registers for STAGE CLOCK #2
logic       s2_draw_cmd_rdy;
logic[3:0]  s2_aux_cmd_in;
logic[35:0] s2_draw_cmd;
logic       s3_draw_cmd_rdy;
logic[3:0]  s3_aux_cmd_in;
logic[35:0] s3_draw_cmd;

logic       pixel_cmd_reg;
logic       draw_cmd_rdy_f;
logic[35:0] draw_cmd_f;


FIFO_2word_FWFT input_cmd_fifo_1 (              // Zero Latency Command buffer
    .clk              ( clk                  ), // CLK input
    .reset            ( reset                ), // Reset FIFO

    .shift_in         ( draw_cmd_rdy         ), // Load data into the FIFO
    .shift_out        ( !draw_busy           ), // Shift data out of the FIFO
    .data_in          ( draw_cmd[35:0]       ), // Data input from PAGET

    .fifo_not_empty   ( draw_cmd_rdy_f       ), // High when there is data available for the pixel writer
    .fifo_full        ( pix_adr_busy         ), // High when the FIFO is full - used to tell GEOFF and PAGET to halt until there is room in the FIFO again
    .data_out         ( draw_cmd_f[35:0]     )  // FIFO data output to pixel writer
);
defparam
    input_cmd_fifo_1.bits  = 36; // The number of bits containing the command


always_comb begin
//draw_cmd_rdy_f = draw_cmd_rdy ; // FIFO bypass
//draw_cmd_f     = draw_cmd     ; // FIFO bypass
//pix_adr_busy   = draw_busy    ; // FIFO bypass

    aux_cmd_in[3:0] = draw_cmd_f[35:32] ;
    bit_mode[7:0]   = draw_cmd_f[31:24] ;   // number of bits per pixel - needs to be sourced from elsewhere (MAGGIE#?)
    y[11:0]         = draw_cmd_f[23:12] ;
    x[11:0]         = draw_cmd_f[11:0]  ;
    
    dest_address = dest_base_address[19:0] + (dest_base_address_offset[19:0] >> LUT_bits_to_shift[dest_bits_per_pixel[3:0]]);
    srce_address = srce_base_address[19:0] + (srce_base_address_offset[19:0] >> LUT_bits_to_shift[srce_bits_per_pixel[3:0]]);

    pixel_cmd_rdy = pixel_cmd_reg && !draw_busy;
    
end // always_comb


always_ff @(posedge clk or posedge reset) begin

    if (reset) begin

        dest_bits_per_pixel <= 4'b0 ;
        srce_bits_per_pixel <= 4'b0 ;
        dest_rast_width     <= 16'b0;
        srce_rast_width     <= 16'b0;
        dest_base_address   <= 24'b0;
        srce_base_address   <= 24'b0;
        pixel_cmd[39:0]     <= 40'b0;
        
    end else begin
  
if (!draw_busy) begin
s2_bit_mode     <= bit_mode;
s2_draw_cmd_rdy <= draw_cmd_rdy_f;
s2_aux_cmd_in   <= aux_cmd_in;
s2_draw_cmd     <= draw_cmd_f;

        if ( draw_cmd_rdy_f ) begin

    dest_base_address_offset <=  (y * dest_rast_width[15:0]  + x) << 1 ; // This calculation will only be ready for the S2 - second stage clock cycle.
    srce_base_address_offset <=  (y * srce_rast_width[15:0]  + x) << 1 ; // This calculation will only be ready for the S2 - second stage clock cycle.

    dest_target_bit[3:0]     <= (y * dest_rast_width[15:0]  + x) ;
    srce_target_bit[3:0]     <= (y * srce_rast_width[15:0]  + x) ;


            case (aux_cmd_in) //  These functions will happen on the first stage clock cycle
                              // no output functions are to take place
                
                CMD_IN_DSTRWDTH : begin
                    dest_rast_width[15:0]    <= draw_cmd_f[15:0] ;    // set destination raster image width
                    dest_bits_per_pixel[3:0] <= bit_mode[3:0] ;     // set screen mode (bits per pixel)
                end
                
                CMD_IN_SRCRWDTH : begin
                    srce_rast_width[15:0]    <= draw_cmd_f[15:0] ;    // set source raster image width
                    srce_bits_per_pixel[3:0] <= bit_mode[3:0] ;     // set screen mode (bits per pixel)
                end
            
                CMD_IN_DSTMADDR : begin
                    dest_base_address[23:0]  <= draw_cmd_f[23:0] ;    // set destination base memory address
                end
                
                CMD_IN_SRCMADDR : begin
                    srce_base_address[23:0]  <= draw_cmd_f[23:0] ;    // set source base memory address (even addresses only?)
                end                
            endcase

        end // if ( draw_cmd_RDY_Ff ) 


        if ( s2_draw_cmd_rdy ) begin
            case (s2_aux_cmd_in) //  These functions will happen on the second stage clock cycle
        
                CMD_IN_PXWRI, CMD_IN_PXWRI_M, CMD_IN_PXPASTE, CMD_IN_PXPASTE_M : begin   // write pixel with colour command through pixel paste with mask command.
                    pixel_cmd[0]     <= 1'b0 ;                       // generate address for the pixel
                    pixel_cmd[19:1]  <= dest_address[19:1] ;         // generate address for the pixel
                    pixel_cmd[23:20] <= dest_target_bit[3:0] ;       // which bit to edit in the addressed byte
                    pixel_cmd[27:24] <= dest_bits_per_pixel[3:0] ;   // set bits per pixel for current screen mode
                    pixel_cmd[35:28] <= s2_draw_cmd[31:24] ;          // include colour information
                    pixel_cmd[39:36] <= s2_aux_cmd_in ;         // COLOUR, WRITE, NO TRANSPARENCY, NO R/M/W
                    pixel_cmd_reg    <= 1'b1 ;
                end
               
                CMD_IN_PXCOPY : begin   // read pixel with x & y
                    pixel_cmd[0]     <= 1'b0 ;                       // generate address for the pixel
                    pixel_cmd[19:1]  <= srce_address[19:1] ;         // generate address for the pixel
                    pixel_cmd[23:20] <= srce_target_bit[3:0] ;       // which bit to read from the addressed byte
                    pixel_cmd[27:24] <= srce_bits_per_pixel[3:0] ;   // set bits per pixel for current screen mode
                    pixel_cmd[35:28] <= s2_draw_cmd[31:24] ;         // transparent color value used for read pixel collision counter
                    pixel_cmd[39:36] <= s2_aux_cmd_in ;        // NO COLOUR, READ, NO TRANS, NO R/M/W
                    pixel_cmd_reg    <= 1'b1 ;
                end

                CMD_IN_SETARGB       : begin
                    pixel_cmd[31:0]  <= s2_draw_cmd[31:0] ;    // pass through first 32-bits of input to output ( Alpha Blend and 24-bit RGB colour data)
                    pixel_cmd[39:36] <= s2_aux_cmd_in ;   // pass through command only
                    pixel_cmd_reg    <= 1'b1 ;
                end
                
                CMD_IN_RST_PXWRI_M   : begin
                    pixel_cmd[31:0]  <= s2_draw_cmd[31:0] ;          // pass through first 32-bits of input to output ( Alpha Blend and 24-bit RGB colour data)
                    pixel_cmd[39:36] <= s2_aux_cmd_in ;   // pass through command only
                    pixel_cmd_reg    <= 1'b1 ;
                end
                
                CMD_IN_RST_PXPASTE_M : begin
                    pixel_cmd[31:0]  <= s2_draw_cmd[31:0] ;           // pass through first 32-bits of input to output ( Alpha Blend and 24-bit RGB colour data)
                    pixel_cmd[39:36] <= s2_aux_cmd_in ;  // pass through command only
                    pixel_cmd_reg    <= 1'b1 ;
                end
                
                default : pixel_cmd_reg      <= 1'b0 ;              // NOP - reset pixel_cmd_reg for one-clock operation
                
            endcase

        end else pixel_cmd_reg      <= 1'b0 ; //if ( s2_draw_cmd_rdy )



  end // if !draw_busy
 end // if !reset

end // always_ff @ posedge clk or reset

endmodule
