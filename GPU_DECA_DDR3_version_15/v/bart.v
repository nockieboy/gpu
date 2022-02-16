//
// BART - bitplane-to-raster module
// 
// version 2.0
//

module bart (

   // inputs
   input wire         clk,
   input wire [3:0]   pc_ena,
   input wire [31:0]  cmd_in,
   input wire [23:0]  bp_2_rast_cmd,
   input wire [15:0]  ram_byte_in,
   
   // outputs
   output wire [18:0] pixel_out
   
);

// *****************************************************************************
// colour_mode_in[3:0] defines the video mode:
//
// bit3 - module on/off, bit 2 - 16-bit mode, bits 1-0 - video mode
//
// 1000 - 1 bit colour
// 1001 - 2 bit colour
// 1010 - 4 bit colour
// 1011 - 8 bit colour
// 1100 - 16 bit 8 pixels per word
// 1101 - 16 bit 4 pixels per word
// 1110 - 16 bit 2 pixels per word
// 1111 - 16 bit true colour
// *****************************************************************************

wire [7:0]  bg_colour                  ;
wire [7:0]  fg_colour                  ;
wire [7:0]  font_colour                ;
wire [9:0]  x_in                       ;
wire [7:0]  colour_mode_in             ;
wire        window_enable, mode_565    ;
reg         window_ena_out, mode_16bit ;
reg  [15:0] reg_pixel_out              ;

// *****************************************************************************
// *                                                                           *
// *  ASSIGNMENTS                                                              *
// *                                                                           *
// *****************************************************************************

assign colour_mode_in[7:0] = bp_2_rast_cmd[7:0]   ;
assign bg_colour[7:0]      = bp_2_rast_cmd[15:8]  ;
assign fg_colour[7:0]      = bp_2_rast_cmd[23:16] ;
assign window_enable       = cmd_in[7]            ; // used to be "pixel_in_ena"
assign x_in[4:0]           = cmd_in[4:0]          ;
assign font_colour[7:0]    = cmd_in[15:8]         ;
assign mode_565            = colour_mode_in[4]    ;

assign pixel_out[15:0]      = reg_pixel_out[15:0] ;
assign pixel_out[16]        = mode_565            ;
assign pixel_out[17]        = window_ena_out      ;
assign pixel_out[18]        = mode_16bit          ;

// *****************************************************************************
// *                                                                           *
// *  RASTER GENERATION                                                        *
// *                                                                           *
// *****************************************************************************

always @ (posedge clk) begin

   if (pc_ena[3:0] == 0) begin
      
      if (~window_enable | ~colour_mode_in[3]) begin
         
         // disable output as turned off
         reg_pixel_out  <= 16'b0000000000000000;
         // disable output as not in display area
         window_ena_out <= 1'b0;
         
      end
      else begin
         
         case (colour_mode_in[2:0]) // select case based on video mode bits
            
            3'b000 : begin // 1-bit (2 colour) - 8 pixels per byte
               
               mode_16bit <= 1'b0;     // set mode_16bit output to 8-bit mode
               window_ena_out <= 1'b1; // set enable_out HIGH
               
               if (ram_byte_in[(~x_in[2:0])] == 1'b1 ) begin
                  
                  reg_pixel_out <= fg_colour;
                  
               end
               else begin
                  
                  reg_pixel_out <= bg_colour;
                  
               end
               
            end
            
            3'b001 : begin // 2-bit (4 colour) - 4 pixels per byte
               
               mode_16bit <= 1'b0;     // set mode_16bit output to 8-bit mode
               window_ena_out <= 1'b1; // set enable_out HIGH
               
               reg_pixel_out[7:2] <= bg_colour[7:2];
               
               case (x_in[2:1])
                  2'h0 : begin
                     
                     reg_pixel_out[1:0] <= ram_byte_in[7:6];
                     
                  end
                  2'h1 : begin
                     
                     reg_pixel_out[1:0] <= ram_byte_in[5:4];
                     
                  end
                  2'h2 : begin
                     
                     reg_pixel_out[1:0] <= ram_byte_in[3:2];
                     
                  end
                  2'h3 : begin
                     
                     reg_pixel_out[1:0] <= ram_byte_in[1:0];
                     
                  end
               endcase
               
            end
            
            3'b010 : begin // 4-bit (16 colour) - 2 pixels per byte
               
               mode_16bit <= 1'b0;     // set mode_16bit output to 8-bit mode
               window_ena_out <= 1'b1; // set enable_out HIGH
               
               reg_pixel_out[7:4] <= bg_colour[7:4];
               
               if (~x_in[2])
                  reg_pixel_out[3:0] <= ram_byte_in[7:4];
               else
                  reg_pixel_out[3:0] <= ram_byte_in[3:0];
               
            end
            
            3'b011 : begin // 8-bit (256 colour) - 1 pixel per byte
               
               mode_16bit <= 1'b0;     // set mode_16bit output to 8-bit mode
               window_ena_out <= 1'b1; // set enable_out HIGH
               
               reg_pixel_out <= ram_byte_in[7:0];
               
            end
            
            3'b100 : begin // 16-bit text mode - 8 pixels per word
               
               mode_16bit     <= 1'b0; // I know this is weird, the 16 bit mode is reserved for turning off the palette and passing 16 bits straight to the DAC
               window_ena_out <= 1'b1; // set enable_out HIGH
               
               if (ram_byte_in[(~x_in[2:0])] == 1'b1 ) begin
                  
                  reg_pixel_out[3:0] <= font_colour[7:4];
                  reg_pixel_out[7:4] <= fg_colour[7:4];
                  
               end
               else begin
                  
                  reg_pixel_out[3:0] <= font_colour[3:0];
                  reg_pixel_out[7:4] <= bg_colour[7:4];
                  
               end
               
            end
            
            3'b101 : begin // 16-bit text mode - 4 pixels per word
               
               mode_16bit     <= 1'b0; // I know this is weird, the 16 bit mode is reserved for turning off the palette and passing 16 bits straight to the DAC
               window_ena_out <= 1'b1; // set enable_out HIGH
               reg_pixel_out[7:2] <= font_colour[7:2];
               
               case (x_in[2:1])
                  2'h0 : begin
                     
                     reg_pixel_out[1:0] <= ram_byte_in[7:6];
                     
                  end
                  2'h1 : begin
                     
                     reg_pixel_out[1:0] <= ram_byte_in[5:4];
                     
                  end
                  2'h2 : begin
                     
                     reg_pixel_out[1:0] <= ram_byte_in[3:2];
                     
                  end
                  2'h3 : begin
                     
                     reg_pixel_out[1:0] <= ram_byte_in[1:0];
                     
                  end
               endcase
               
            end
            
            3'b110 : begin // 16-bit 4-bit colour pixel - 4 bits per pixel
               
               mode_16bit     <= 1'b0; // I know this is weird, the 16 bit mode is reserved for turning off the palette and passing 16 bits straight to the DAC
               window_ena_out <= 1'b1; // set enable_out HIGH
               
               reg_pixel_out[7:4] <= font_colour[7:4];
               
               if (~x_in[2])
                  reg_pixel_out[3:0] <= ram_byte_in[7:4];
               else
                  reg_pixel_out[3:0] <= ram_byte_in[3:0];
               
            end
            
            3'b111 : begin // 16-bit (true colour)
               
               mode_16bit     <= 1'b1; // set mode_16bit output to 16-bit mode
               window_ena_out <= 1'b1; // set enable_out HIGH
               
               reg_pixel_out  <= ram_byte_in;
               
            end
            
         endcase
         
      end
      
   end // if (pc_ena[3:0] == 0)
   
end // always@clk

endmodule
