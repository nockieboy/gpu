module bitplane_to_raster (

	// inputs
	input wire clk,
	input wire pixel_in_ena,
	input wire [3:0] pc_ena,
	input wire [15:0] ram_byte_in,
	input wire [7:0] ram_byte_h,
	input wire [7:0] bg_colour,
	input wire [9:0] x_in,
	input wire [2:0] colour_mode_in,
	input wire two_byte_mode,
	
	// outputs
	output reg pixel_out_ena,
	output reg mode_16bit,					// high when in 16-bit mode
	output reg [7:0] pixel_out,
	output reg [7:0] pixel_out_h,
	output reg [9:0] x_out,
	output reg [2:0] colour_mode_out
	
);

// *****************************************************************************
// *                                                                           *
// *  PASS-THRUS                                                               *
// *                                                                           *
// *****************************************************************************

always @ ( posedge clk ) begin

	if (pc_ena[3:0] == 0) begin
		
		x_out					<= x_in;
		colour_mode_out	<= colour_mode_in;		
		
	end // pc_ena
	
end // always@clk
// *****************************************************************************


// *****************************************************************************
// *                                                                           *
// *  RASTER GENERATION                                                        *
// *                                                                           *
// *****************************************************************************

// color_mode_in determines the operating mode for the bitplane_to_raster module
// it is a 3-bit signal, providing 4 modes of operation to this module e.g.:
//
// 000 =   2 colour mode - 8 pixels per byte in GPU RAM
// 001 =   4 colour mode - 4 pixels -----"------"------
// 010 =  16 colour mode - 2 pixels -----"------"------
// 011 = 256 colour mode - 1 pixels -----"------"------
// 1xx = OFF

always @ (posedge clk) begin

	if (pc_ena[3:0] == 0) begin
		
		pixel_out_ena <= pixel_in_ena;	// pass pixel_ena through to the output
		
		if (~pixel_in_ena || colour_mode_in[2]) begin
			
			// nothing to see here (disabled)
			pixel_out	<= 8'b00000000;
			pixel_out_h	<= 8'b00000000;
			
		end
		else if (~two_byte_mode) begin // 8-bit mode
			
			case (colour_mode_in)
				
				2'h0 : begin	// 1-bit (2 colour) - 8 pixels per byte
					// set the output pixel color to the first 4 bits of the background color
					// when the bit on the picture bitplane byte is 0 and use the upper 4 bits
					// when the bit on the bit-plane byte is high
					
					mode_16bit <= 1'b0;	// update mode_16bit output to 8-bit mode
					
					if (ram_byte_in[(~x_in[2:0])] == 1'b1) begin
						
						pixel_out[7:4]	<= 4'b0000;
						pixel_out[3:0]	<= bg_colour[7:4];
						
					end
					else begin
						
						pixel_out[7:4]	<= 4'b0000;
						pixel_out[3:0]	<= bg_colour[3:0];
						
					end
					
				end
				
				2'h1 : begin	// 2-bit (4 colour) - 4 pixels per byte
					// output will be 2 bits stacked, 2 copies every second X pixel, you will
					// output a 2 bit color. EG pixel 0&1 output bitplane[7:6],  pixel 2&3
					// output bitplane[5:4], pixel 4&5 output bitplane[3:2]
					
					mode_16bit <= 1'b0;	// update mode_16bit output to 8-bit mode
					
					pixel_out[7:2] <= bg_colour[7:2];
					
					case (x_in[2:1])
						2'h0 : begin
							
							pixel_out[1:0] <= ram_byte_in[7:6];
							
						end
						2'h1 : begin
							
							pixel_out[1:0] <= ram_byte_in[5:4];
							
						end
						2'h2 : begin
							
							pixel_out[1:0] <= ram_byte_in[3:2];
							
						end
						2'h3 : begin
							
							pixel_out[1:0] <= ram_byte_in[1:0];
							
						end
					endcase
					
				end
				
				2'h2 : begin	// 4-bit (16 colour) - 2 pixels per byte
					// output will be 4 bits stacked, 4 copies every four X pixel, you will
					// output a 4 bit color.  EG pixel 0,1,2,3 output bitplane[7:4], EG pixel
					// 4,5,6,7 output bitplane[3:0]
					
					mode_16bit <= 1'b0;	// update mode_16bit output to 8-bit mode
					
					pixel_out[7:4] <= bg_colour[7:4];
					
					if (x_in[3])
						pixel_out[3:0] <= ram_byte_in[3:0];
					else
						pixel_out[3:0] <= ram_byte_in[7:4];
					
				end
				
				2'h3 : begin	// 8-bit (256 colour) - 1 pixel per byte
					// output will be 8 bits stacked, 8 copies every eight X pixel, you will
					// output a 4 bit color.  EG pixel 0,1,2,3,4,5,6,7 output bitplane[7:0],
					// yes that same 1 value will repeat 8 times is the source X counter
					// counts through those numbers sequentially
					
					mode_16bit <= 1'b0;	// update the mode output to show whether it's 8 or 16-bit mode
					
					pixel_out <= ram_byte_in[7:0];
					
				end
				
			endcase
			
		end // 8-bit mode
		else begin // 16-bit mode
			
			case (colour_mode_in)
				
				2'h0 : begin	// special colour text mode
					// 2-bit colour 2-byte mode
					// latch ram_byte as the bit plane graphic and colour_data
					// as a replacement for the background default color. The
					// rest should follow #1.
					
					mode_16bit <= 1'b0;	// update mode_16bit output to 8-bit mode
					
					if (ram_byte_in[(~x_in[2:0])] == 1'b1) begin
						
						pixel_out[7:4]	<= bg_colour[7:4];
						pixel_out[3:0]	<= ram_byte_h[7:4];
						
					end
					else begin
						
						pixel_out[7:4]	<= bg_colour[7:4];
						pixel_out[3:0]	<= ram_byte_h[3:0];
						
					end
					
				end
				2'h3 : begin	// 16-bit (true colour)
					// taking 2 sequential bytes, like the color text mode, and outputting
					// a full 16 bits parallel on the output
					
					mode_16bit <= 1'b1;	// update mode_16bit output to 16-bit mode
					
					pixel_out	<= ram_byte_in[7:0];
					pixel_out_h	<= ram_byte_h;
					
				end
				
			endcase
			
		end // 16-bit mode
		
	end // if (pc_ena[3:0] == 0)
	
end // always@clk

endmodule
