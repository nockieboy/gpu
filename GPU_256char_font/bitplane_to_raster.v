module bitplane_to_raster (

	// inputs
	input wire clk,
	input wire pixel_in_ena,
	input wire two_byte_mode,
	input wire enable_in,
	input wire [3:0]  pc_ena,
	input wire [15:0] ram_byte_in,
	input wire [7:0]  ram_byte_h,
	input wire [9:0]  x_in,
	input wire [7:0]  GPU_HW_Control_regs[0:(2**HW_REGS_SIZE-1)],
	
	// outputs
	output reg enable_out,
	output reg pixel_out_ena,
	output reg mode_16bit,					// high when in 16-bit mode
	output reg [7:0] pixel_out,
	output reg [7:0] pixel_out_h,
	output reg [9:0] x_out
	
);

parameter CTRL_BYTE_BASE = 16;	// defines the base address of the 3 control bytes (video_mode, bg_colour, fg_colour) in the HW_REGS

// *****************************************************************************
// video_mode byte - CTRL_BYTE_BASE + 0
//
// This HW_REG defines the video mode:
//
// 0000 - Off
// 0001 - 1 bit color
// 0010 - 2 bit color
// 0011 - 4 bit color
// 0100 - 8 bit color
// 0101 - 16 bit color
// 0110 - Special 2-byte text colour mode
// 0111 - ARGB4444
// 1000 - RGB565
// 1001 - 16 bit 565 thru
// 1010 - Mixed 16-bit 656 thru with last 256 colors assigned through the palette
// *****************************************************************************

parameter HW_REGS_SIZE	= 8;		// default size for hardware register bus - set by HW_REGS parameter in design view

wire [7:0] bg_colour = GPU_HW_Control_regs[CTRL_BYTE_BASE + 1];
wire [7:0] fg_colour = GPU_HW_Control_regs[CTRL_BYTE_BASE + 2];

// *****************************************************************************
// *                                                                           *
// *  PASS-THRUS                                                               *
// *                                                                           *
// *****************************************************************************

always @ ( posedge clk ) begin

	if (pc_ena[3:0] == 0) begin
		
		x_out					<= x_in;
		
	end // pc_ena
	
end // always@clk
// *****************************************************************************


// *****************************************************************************
// *                                                                           *
// *  RASTER GENERATION                                                        *
// *                                                                           *
// *****************************************************************************

always @ (posedge clk) begin

	if (pc_ena[3:0] == 0) begin
		
		pixel_out_ena	<= pixel_in_ena;	// pass pixel_ena through to the output
		enable_out 		<= enable_in;
		
		if (~pixel_in_ena || ~enable_in) begin
			
			// disable output as not in display area or enable_in is LOW
			pixel_out	<= 8'b00000000;
			pixel_out_h	<= 8'b00000000;
			
		end
		else begin
			
			case (GPU_HW_Control_regs[CTRL_BYTE_BASE + 0]) // select case based on video_mode HW_reg
				
				2'h0 : begin	// off
					// disable output as turned off
					pixel_out	<= 8'b00000000;
					pixel_out_h	<= 8'b00000000;
					enable_out 	<= 1'b0;				// set enable_out LOW
				end
				
				2'h1 : begin	// 1-bit (2 colour) - 8 pixels per byte
					
					mode_16bit <= 1'b0;	// set mode_16bit output to 8-bit mode
					enable_out <= 1'b1;	// set enable_out HIGH
					
					if (ram_byte_in[(~x_in[2:0])] == 1'b1) begin
						
						//pixel_out[7:4]	<= 4'b0000;
						//pixel_out[3:0]	<= bg_colour[7:4];
						pixel_out <= fg_colour;
						
					end
					else begin
						
						//pixel_out[7:4]	<= 4'b0000;
						//pixel_out[3:0]	<= bg_colour[3:0];
						pixel_out <= bg_colour;
						
					end
					
				end
				
				2'h2 : begin	// 2-bit (4 colour) - 4 pixels per byte
					
					mode_16bit <= 1'b0;	// set mode_16bit output to 8-bit mode
					enable_out <= 1'b1;	// set enable_out HIGH
					
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
				
				2'h3 : begin	// 4-bit (16 colour) - 2 pixels per byte
					
					mode_16bit <= 1'b0;	// set mode_16bit output to 8-bit mode
					enable_out <= 1'b1;	// set enable_out HIGH
					
					pixel_out[7:4] <= bg_colour[7:4];
					
					if (x_in[3])
						pixel_out[3:0] <= ram_byte_in[3:0];
					else
						pixel_out[3:0] <= ram_byte_in[7:4];
					
				end
				
				2'h4 : begin	// 8-bit (256 colour) - 1 pixel per byte
					
					mode_16bit <= 1'b0;	// set mode_16bit output to 8-bit mode
					enable_out <= 1'b1;	// set enable_out HIGH
					
					pixel_out <= ram_byte_in[7:0];
					
				end
				
				2'h5 : begin	// 16-bit (true colour)
					
					mode_16bit <= 1'b1;	// set mode_16bit output to 16-bit mode
					enable_out <= 1'b1;	// set enable_out HIGH
					
					pixel_out	<= ram_byte_in[7:0];
					pixel_out_h	<= ram_byte_h;
					
				end
				
				2'h6 : begin	// special colour text mode
					
					mode_16bit <= 1'b0;	// set mode_16bit output to 8-bit mode
					enable_out <= 1'b1;	// set enable_out HIGH
					
					if (ram_byte_in[(~x_in[2:0])] == 1'b1) begin
						
						pixel_out[7:4]	<= bg_colour[7:4];
						pixel_out[3:0]	<= ram_byte_h[7:4];
						
					end
					else begin
						
						pixel_out[7:4]	<= bg_colour[7:4];
						pixel_out[3:0]	<= ram_byte_h[3:0];
						
					end
					
				end
				
			endcase
			
		end
		
	end // if (pc_ena[3:0] == 0)
	
end // always@clk

endmodule
