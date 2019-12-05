module bitplane_to_raster (

	// inputs
	input wire clk,
	input wire [3:0] pc_ena,
	input wire [7:0] ram_byte_in,
	input wire [7:0] ram_byte_h,
	input wire [7:0] bg_colour,
	input wire [9:0] x_in,
	input wire [1:0] colour_mode_in,
	input wire two_byte_mode,
	
	// outputs
	output reg pixel_out_ena,
	output reg mode_16bit,					// high when in 16-bit mode
	output reg [7:0] pixel_out,
	output reg [7:0] pixel_out_h,
	output reg [9:0] x_out,
	output reg [1:0] colour_mode_out
	
);

// parameters
parameter PIPE_DELAY = 3; // minimum value of 2

// internal registers
reg [7:0] colour_data;
reg [7:0] ram_byte;

// *****************************************************************************
// *                                                                           *
// *  DELAY PIPES                                                              *
// *                                                                           *
// *****************************************************************************
reg [9:0] dly_x [9:0];
reg [9:0] dly_ram_byte [7:0];
reg [9:0] dly_ram_h_byte [7:0];
reg [9:0] dly_colour_mode [1:0];
reg [9:0] dly_mode_bit [1:0];

always @ ( posedge clk ) begin

	if (pc_ena[3:0] == 0) begin
		
		dly_x[0]		<= x_in;
		dly_x[9:1]	<= dly_x[8:0];
		x_out			<= dly_x[PIPE_DELAY-1];
		
		dly_mode_bit[0]	<= two_byte_mode;
		dly_mode_bit[9:1]	<= dly_mode_bit[8:0];
		mode_16bit			<= dly_mode_bit[PIPE_DELAY-1];
		
		dly_ram_byte[0]	<= ram_byte_in;
		dly_ram_byte[9:1]	<= dly_ram_byte[8:0];
		ram_byte				<= dly_ram_byte[PIPE_DELAY-1];
		colour_data			<= dly_ram_byte[PIPE_DELAY-2]; // in two-byte mode, colour_data should follow the ram_data byte
		
		dly_ram_h_byte[0]		<= ram_byte_h;
		dly_ram_h_byte[9:1]	<= dly_ram_h_byte[8:0];
		pixel_out_h				<= dly_ram_h_byte[PIPE_DELAY-1];
		
		dly_colour_mode[0]	<= colour_mode_in;
		dly_colour_mode[9:1]	<= dly_colour_mode[8:0];
		colour_mode_out		<= dly_colour_mode[PIPE_DELAY-1];		
		
	end // pc_ena
	
end // always@clk
// *****************************************************************************


// *****************************************************************************
// *                                                                           *
// *  RASTER GENERATION                                                        *
// *                                                                           *
// *****************************************************************************

// color_mode_in determines the operating mode for the bitplane_to_raster module
// it is a 2-bit signal, providing 4 modes of operation to this module e.g.:
//
// 00 =   2 colour mode - 8 pixels per byte in GPU RAM
// 01 =   4 colour mode - 4 pixels -----"------"------
// 10 =  16 colour mode - 2 pixels -----"------"------
// 11 = 256 colour mode - 1 pixels -----"------"------

always @ (posedge clk) begin

	if (pc_ena[3:0] == 0) begin
		
		if (~two_byte_mode) begin // 8-bit mode
			
			case (colour_mode_in)
				
				2'h0 : begin	// 1-bit (2 colour) - 8 pixels per byte
					// set the output pixel color to the first 4 bits of the background color
					// when the bit on the picture bitplane byte is 0 and use the upper 4 bits
					// when the bit on the bit-plane byte is high
					
					mode_16bit <= 1'b0;	// update mode_16bit output to 8-bit mode
					
					if (ram_byte[(~x_out[2:0])] == 1'b1) begin
						
						pixel_out[7:5]	<= 3'b000;
						pixel_out[4]	<= 1'b1;
						pixel_out[3:0]	<= bg_colour[7:4];
						
					end
					else begin
						
						pixel_out[7:5]	<= 3'b000;
						pixel_out[4]	<= 1'b0;
						pixel_out[3:0]	<= bg_colour[3:0];
						
					end
					
				end
				
				2'h1 : begin	// 2-bit (4 colour) - 4 pixels per byte
					// output will be 2 bits stacked, 2 copies every second X pixel, you will
					// output a 2 bit color. EG pixel 0&1 output bitplane[7:6],  pixel 2&3
					// output bitplane[5:4], pixel 4&5 output bitplane[3:2]
					
					mode_16bit <= 1'b0;	// update mode_16bit output to 8-bit mode
					
					pixel_out[7:2] <= 6'b000000;
					
					case (x_out[2:1])
						2'h0 : begin
							
							pixel_out[1:0] <= ram_byte[7:6];
							
						end
						2'h1 : begin
							
							pixel_out[1:0] <= ram_byte[5:4];
							
						end
						2'h2 : begin
							
							pixel_out[1:0] <= ram_byte[3:2];
							
						end
						2'h3 : begin
							
							pixel_out[1:0] <= ram_byte[1:0];
							
						end
					endcase
					
				end
				
				2'h2 : begin	// 4-bit (16 colour) - 2 pixels per byte
					// output will be 4 bits stacked, 4 copies every four X pixel, you will
					// output a 4 bit color.  EG pixel 0,1,2,3 output bitplane[7:4], EG pixel
					// 4,5,6,7 output bitplane[3:0]
					
					mode_16bit <= 1'b0;	// update mode_16bit output to 8-bit mode
					
					pixel_out[7:4] <= 4'b0000;
					
					if (x_out[3])
						pixel_out[3:0] <= ram_byte[3:0];
					else
						pixel_out[3:0] <= ram_byte[7:4];
					
				end
				
				2'h3 : begin	// 8-bit (256 colour) - 1 pixel per byte
					// output will be 8 bits stacked, 8 copies every eight X pixel, you will
					// output a 4 bit color.  EG pixel 0,1,2,3,4,5,6,7 output bitplane[7:0],
					// yes that same 1 value will repeat 8 times is the source X counter
					// counts through those numbers sequentially
					
					mode_16bit <= 1'b0;	// update the mode output to show whether it's 8 or 16-bit mode
					
					pixel_out <= ram_byte;
					
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
					
					if (ram_byte[(x_out[2:0])] == 1'b1) begin
						
						pixel_out	<= ram_byte;
						pixel_out_h	<= ram_byte_h;
						
					end
					else begin
						
						pixel_out	<= ram_byte;
						pixel_out_h	<= bg_colour;
						
					end
					
				end
				2'h3 : begin	// 16-bit (true colour)
					// taking 2 sequential bytes, like the color text mode, and outputting
					// a full 16 bits parallel on the output
					
					mode_16bit <= 1'b1;	// update mode_16bit output to 16-bit mode
					
					pixel_out	<= ram_byte;
					pixel_out_h	<= ram_byte_h;
					
				end
				
			endcase
			
		end // 16-bit mode
		
	end // if (pc_ena[3:0] == 0)
	
end // always@clk

endmodule
