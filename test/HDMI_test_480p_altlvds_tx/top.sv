module top (

	input  logic       clk_pixel,
	input  logic       clk_audio,

	output logic [3:0] tmds
);

logic [15:0] audio_sample_word [1:0] = '{ 16'sd0, 16'sd0 } ;

always @(posedge clk_audio) begin

  audio_sample_word <= '{ audio_sample_word[0] + 16'sd1, audio_sample_word[1] - 16'sd1 } ;
  
end

logic [23:0] rgb = 24'd0;
logic [9:0]  cx, cy, screen_start_x, screen_start_y, frame_width, frame_height, screen_width, screen_height;

// Video ID Code 1 = 640  x 480 @ 60Hz    - c0=25.200 MHz
// Video ID Code 2 = 720  x 480 @ 59.94Hz - c0=27.000 MHz
// Video ID Code 4 = 1280 x 720 @ 59.94Hz - c0=74.250 MHz
hdmi_altlvds #(
    .INV_LVDS0(1'b1),        // Invert the TMDS channel 0 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
    .INV_LVDS1(1'b1),        // Invert the TMDS channel 1 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
    .INV_LVDS2(1'b1),        // Invert the TMDS channel 2 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
    .INV_LVDS3(1'b0),        // Invert the TMDS channel 3 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
	.VIDEO_ID_CODE(2),		 // Defaults to 640x480 which should be supported by almost if not all HDMI sinks. See README.md or CEA-861-D for enumeration of video id codes.
	.DVI_OUTPUT(1'b0),       // Enable this flag for DVI output. Use this to reduce resource usage if you're only outputting video (non-HDMI).
	.PIXEL_MHZ(27.000),		 // Sets the pixel clock frequency for Altera's altlvds_tx serializer megafunction.
	.VIDEO_REFRESH_RATE(59.94), // Specify the refresh rate in Hz we're using for audio calculations
	.AUDIO_RATE(48000),      // As specified in Section 7.3, the minimal audio requirements are met: 16-bit or more L-PCM audio at 32 kHz, 44.1 kHz, or 48 kHz.
	.AUDIO_BIT_WIDTH(16) 	 // Defaults to minimum bit lengths required to represent positions. Modify these parameters if you have alternate desired bit lengths.
) hdmi_altlvds(
  // inputs
  .clk_pixel(clk_pixel),
  .clk_audio(clk_audio),
  .rgb(rgb),
  .audio_sample_word(audio_sample_word),
  // video outputs
  .tmds_tx(tmds),
  // internal outputs (don't go outside FPGA)
  .cx(cx),
  .cy(cy),
  .screen_start_x(screen_start_x),
  .screen_start_y(screen_start_y),
  .frame_width(frame_width),
  .frame_height(frame_height),
  .screen_width(screen_width),
  .screen_height(screen_height)
);

// Border test (left = red, top = green, right = blue, bottom = blue, fill = black)
always @(posedge clk_pixel) begin

  rgb <= { cx == screen_start_x ? ~8'd0 : 8'd0, cy == screen_start_y ? ~8'd0 : 8'd0, cx == frame_width - 1'd1 || cy == frame_height - 1'd1 ? ~8'd0 : 8'd0 } ;
  
end

endmodule
