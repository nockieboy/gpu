// This module will force mute the RGB video output data outside the active video display area.
// It will also generate the vid_de_out use by many DVI transmitters.
// This module, as an example, also has all the inputs and outputs used along the pixel pipe.
// It illustrates since there is a pixel delay in the video switch, the syncs and video enables are also delayed,
// making the output picture window perfectly parallel with the video coming in, then being fed out.
//
// Written by BrianHG

module vid_out_stencil(

	input wire pclk,
	input wire reset,
	input wire [3:0] pc_ena,	// Pixel clock enable
	input wire hde_in,	// Horizontal Display Enable - high when in display area (valid drawing area)
	input wire vde_in,	// Vertical Display Enable - high when in display area (valid drawing area)
	input wire hs_in,		// horizontal sync
	input wire vs_in,		// vertical sync

	input wire [RGB_hbit:0] r_in,
	input wire [RGB_hbit:0] g_in,
	input wire [RGB_hbit:0] b_in,
	
	output reg hde_out,
	output reg vde_out,
	output reg hs_out,
	output reg vs_out,

	output reg [RGB_hbit:0] r_out,
	output reg [RGB_hbit:0] g_out,
	output reg [RGB_hbit:0] b_out,

	output reg vid_de_out			// Actual H&V data enable required by some DVI encoders/serializers
	
);

	parameter RGB_hbit  = 3;		// 1 will make the RGB ports go from 1 to 0, eg [1:0].  I know others prefer a '2' here for 2 bits
	parameter HS_invert = 1;		// use a 1 to invert the HS output, the invert feature is only for this video output module
	parameter VS_invert = 1;		// use a 1 to invert the VS output, the invert feature is only for this video output module

	always @(posedge pclk)
	begin
		if (reset) // global reset
		begin

			// not in use for this module

		end
		else
		begin
			if (pc_ena[3:0] == 0)	// once per pixel
			begin

				hde_out <= hde_in;             // since the video muting switch algorithm delays the output by 1 pixel clock,
				vde_out <= vde_in;             // all the video timing reference signals will also get the 1 pixel delay treatment to keep the output aligned perfectly.
				hs_out  <= hs_in ^ HS_invert[0]; // the invert feature is only for this video output module
				vs_out  <= vs_in ^ VS_invert[0]; // the invert feature is only for this video output module

				if ( hde_in && vde_in )
				begin
					vid_de_out <= 1'b1;  // turn on video enable for DVI transmitters
					r_out <= r_in;			// copy video input to output
					g_out <= g_in;			// copy video input to output
					b_out <= b_in;			// copy video input to output
				end
				else
				begin
					vid_de_out <= 1'b0;  // turn off video enable for DVI transmitters
					r_out <= 0;				// Mute video output to black
					g_out <= 0;				// Mute video output to black
					b_out <= 0;				// Mute video output to black
				end

			end
		end
	end
endmodule
