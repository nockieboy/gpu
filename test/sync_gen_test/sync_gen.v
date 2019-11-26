// VGA Sync Generator
//
// Default: 640x480x60
//
// Can take parameters when initialised
// to output sync signals for any screen
// resolution
	
module sync_generator(
	// inputs
	input wire pclk,							// base pixel clock (125 MHz)
	input wire reset,							// reset: restarts frame
	// outputs
	output reg [3:0] pc_ena,  				// Pixel clock enable (4-bit to allow clock division in video sub-modules)
	output reg hde,							// Horizontal Display Enable - high when in display area (valid drawing area)
	output reg vde,							// Vertical Display Enable - high when in display area (valid drawing area)
	output reg hsync,							// horizontal sync
	output reg vsync							// vertical sync
	);

	// default resolution if no parameters are passed
	parameter H_RES = 640;					// horizontal display resolution
	parameter V_RES = 480;					// vertical display resolution

	// image offset parameters
	parameter IMAGE_OFFSET_X = 16;
	parameter IMAGE_OFFSET_Y = 16;
	
	// no-draw area definitions
	// defined as parameters so you can edit these on Quartus' block diagram editor
	parameter H_FRONT_PORCH = 16;
	parameter HSYNC_WIDTH   = 96;
	parameter H_BACK_PORCH  = 48;
	parameter V_FRONT_PORCH = 10;
	parameter VSYNC_HEIGHT	= 2;
	parameter V_BACK_PORCH  = 33;
	parameter PIX_CLK_DIVIED = 4;
	
	// total screen resolution
	localparam LINE		= H_RES + H_FRONT_PORCH + HSYNC_WIDTH + H_BACK_PORCH;		// complete line (inc. horizontal blanking area)
	localparam SCANLINES	= V_RES + V_FRONT_PORCH + VSYNC_HEIGHT + V_BACK_PORCH;	// total scan lines (inc. vertical blanking area)
	
	// useful trigger points
	localparam HS_STA = IMAGE_OFFSET_X + H_RES + H_FRONT_PORCH - 1;						// horizontal sync ON (the minus 1 is because hsync is a REG, and thus one clock behind)
	localparam HS_END = IMAGE_OFFSET_X + H_RES + H_FRONT_PORCH + HSYNC_WIDTH - 1;	// horizontal sync OFF (the minus 1 is because hsync is a REG, and thus one clock behind)
	localparam VS_STA = IMAGE_OFFSET_Y + V_RES + V_FRONT_PORCH;							// vertical sync ON
	localparam VS_END = IMAGE_OFFSET_Y + V_RES + V_FRONT_PORCH + VSYNC_HEIGHT;		// vertical sync OFF

	reg [9:0] h_count;				// current pixel x position
	reg [9:0] v_count;				// current line y position
	
   always @(posedge pclk)
if (pc_ena == PIX_CLK_DIVIED) pc_ena <= 0;
else pc_ena <= pc_ena +1;
	
	// handle signal generation
	always @(posedge pclk)
	begin
		if (reset)	// reset to start of frame
		begin
			h_count <= (H_RES - 2);
			v_count <= (SCANLINES - 2);
			//z_count <= 1'b0;
			hsync   <= 1'b0;
			vsync   <= 1'b0;
			vde     <= 1'b0;
			hde     <= 1'b0;
		end
		else
		begin
			if (pc_ena[3:0] == 0)	// once per pixel
			begin

				// Horizontal blanking area - set HDE LOW
				if (h_count == IMAGE_OFFSET_X + H_RES - 1)
				begin
					hde <= 1'b0;
				end

				// check for generation of HSYNC pulse
				if (h_count == HS_STA)
				begin
					hsync <= 1'b1;		// turn on HSYNC pulse
				end
				else if (h_count == HS_END)
					hsync <= 1'b0;		// turn off HSYNC pulse
				
				// check for generation of VSYNC pulse
				if (v_count == VS_STA)
				begin
					vsync <= 1'b1;		// turn on VSYNC pulse
				end
				else if (v_count == VS_END)
					vsync <= 1'b0;		// turn off VSYNC pulse
				
				// reset h_count & increment v_count at end of scanline
				if (h_count == LINE - 1)	// end of line
				begin
					h_count	<= 1'b0;
					hde		<= 1'b1;  		// Turn on horizontal video data enable

					// Now h_count has been zeroed, check if the V-count should be cleared at end of SCANLINES
					if (v_count == SCANLINES - 1)
					begin
						v_count	<= 1'b0;
						vde		<= 1'b1;		// Turn on vertical video data enable
					end
					else
					begin	// If v_count isn't being cleared, increment v_count
						v_count <= v_count + 1'b1;	// increment v_count to next scanline
						if (v_count == V_RES - 1)
							vde <= 1'b0 ; // Turn off vertical video data enable - reached bottom of display area
					end
				end
				else		// not at end of scanline, so just increment horizontal counter
					h_count <= h_count + 1'b1;
					if (h_count == H_RES - 1)
						hde <= 1'b0 ;  // Turn off vertical video data enable
			
			end // if (pc_ena)
			
		end // else !reset
		
	end // always @clk

endmodule
