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
	input wire [7:0] GPU_HW_Control_regs[0:(2**HW_REGS_SIZE-1)],
	
	// outputs
	output reg [3:0] pc_ena,  				// Pixel clock enable (4-bit to allow clock division in video sub-modules)
	output reg hde,							// Horizontal Display Enable - high when in display area (valid drawing area)
	output reg vde,							// Vertical Display Enable - high when in display area (valid drawing area)
	output reg hsync,							// horizontal sync
	output reg vsync,							// vertical sync
	
	output reg [15:0] frame_ctr,
	output reg [47:0] raster_HV_triggers
	
);

	// default resolution if no parameters are passed
	parameter H_RES = 640;					// horizontal display resolution
	parameter V_RES = 480;					// vertical display resolution
	
	// image offset parameters
	parameter IMAGE_OFFSET_X	= 16;		// offset the display to allow room at the start
	parameter IMAGE_OFFSET_Y	= 16;		// for things to go off edge of screen

	// no-draw area definitions
	// defined as parameters so you can edit these on Quartus' block diagram editor
	parameter H_FRONT_PORCH		= 16;
	parameter HSYNC_WIDTH		= 96;
	parameter H_BACK_PORCH		= 48;
	parameter V_FRONT_PORCH		= 10;
	parameter VSYNC_HEIGHT		= 2;
	parameter V_BACK_PORCH		= 33;
	parameter PIX_CLK_DIVIDER	= 4;
	
	parameter HW_REGS_SIZE		= 8;	// hardware register size set by HW_REGS parameter in design sheet
	parameter BASE_OFFSET		= 32;	// hardware register base offset for raster triggers
	
	// total screen resolution
	localparam LINE		= H_RES + H_FRONT_PORCH + HSYNC_WIDTH + H_BACK_PORCH;		// complete line (inc. horizontal blanking area)
	localparam SCANLINES	= V_RES + V_FRONT_PORCH + VSYNC_HEIGHT + V_BACK_PORCH;	// total scan lines (inc. vertical blanking area)
	
	// useful trigger points
	localparam HS_STA = IMAGE_OFFSET_X + H_RES + H_FRONT_PORCH - 1;					// horizontal sync ON (the minus 1 is because hsync is a REG, and thus one clock behind)
	localparam HS_END = IMAGE_OFFSET_X + H_RES + H_FRONT_PORCH + HSYNC_WIDTH - 1;	// horizontal sync OFF (the minus 1 is because hsync is a REG, and thus one clock behind)
	localparam VS_STA = IMAGE_OFFSET_Y + V_RES + V_FRONT_PORCH;							// vertical sync ON
	localparam VS_END = IMAGE_OFFSET_Y + V_RES + V_FRONT_PORCH + VSYNC_HEIGHT;		// vertical sync OFF

	reg [9:0] h_count;				// current pixel x position
	reg [9:0] v_count;				// current line y position
	
   always @(posedge pclk)
		if (pc_ena == PIX_CLK_DIVIDER) pc_ena <= 0;
		else pc_ena <= pc_ena +1;
	
	integer i;
	
	// handle signal generation
	always @(posedge pclk)
	begin
		
		if (reset)	// reset to start of frame
		begin
			h_count <= (IMAGE_OFFSET_X + H_RES - 2);
			v_count <= (SCANLINES - 2);
			//z_count <= 1'b0;
			hsync   <= 1'b0;
			vsync   <= 1'b0;
			vde     <= 1'b0;
			hde     <= 1'b0;
			frame_ctr <= 16'h0000;
		end
		else
		begin
			if (pc_ena[3:0] == 0)	// once per pixel
			begin
				
				// horizontal raster trigger generation
				for (i = 0; i < 24; i = i + 1) begin
					
					if ( h_count[9:8] == GPU_HW_Control_regs[i*4+BASE_OFFSET+0][1:0] && h_count[7:0] == GPU_HW_Control_regs[i*4+BASE_OFFSET+1][7:0] )
						raster_HV_triggers[i*2+0] <= 1'b1;
					else
						raster_HV_triggers[i*2+0] <= 1'b0;
					
				end
				
				// start of visible display area - set HDE HIGH
				if (h_count == IMAGE_OFFSET_X)
					hde <= 1'b1;  		// Turn on horizontal video data enable
				else if (h_count == IMAGE_OFFSET_X + H_RES)
					hde <= 1'b0 ;  	// Turn off horizontal video data enable
				
				// check for generation of HSYNC pulse
				if (h_count == HS_STA)
					hsync <= 1'b1;		// turn on HSYNC pulse
				else if (h_count == HS_END)
					hsync <= 1'b0;		// turn off HSYNC pulse
				
				// check for generation of VSYNC pulse
				if (v_count == VS_STA)
					vsync <= 1'b1;		// turn on VSYNC pulse
				else if (v_count == VS_END)
					vsync <= 1'b0;		// turn off VSYNC pulse
				
				// reset h_count & increment v_count at end of scanline
				if (h_count == LINE - 1)	// end of line
				begin
					
					h_count	<= 9'b0;	// reset h_count
					
					// vertical raster trigger generation
					for (i = 0; i < 24; i = i + 1) begin
						
						if ( v_count[9:8] == GPU_HW_Control_regs[i*4+BASE_OFFSET+2][1:0] && v_count[7:0] == GPU_HW_Control_regs[i*4+BASE_OFFSET+3][7:0] )
							raster_HV_triggers[i*2+1] <= 1'b1;
						else
							raster_HV_triggers[i*2+1] <= 1'b0;
						
					end
					
					if (v_count == IMAGE_OFFSET_Y)
							vde <= 1'b1;				// Turn on vertical video data enable - start of display area
						else if (v_count == IMAGE_OFFSET_Y + V_RES)
							vde <= 1'b0 ; 				// Turn off vertical video data enable - reached bottom of display area
					
					// Now h_count has been zeroed, check if the V-count should be cleared at end of SCANLINES
					if (v_count == SCANLINES - 1)
					begin
						
						v_count		<= 9'b0;
						frame_ctr	<= frame_ctr + 1'b1; // Increment the frame counter
						
					end
					else
					begin	// If v_count isn't being cleared, increment v_count
						
						v_count <= v_count + 1'b1;	// increment v_count to next scanline
						
					end
				end
				else		// not at end of scanline, so just increment horizontal counter
				begin
					
					h_count <= h_count + 1'b1;
					
				end // if (h_count == LINE - 1)
				
			end // if (pc_ena)
			
		end // else !reset
		
	end // always @clk

endmodule
