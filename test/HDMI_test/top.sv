module top (

	input  logic       clk_pixel_x10,
	input  logic       clk_pixel,
	input  logic       clk_audio,

	output logic [2:0] tmds_p,
	output logic [2:0] tmds_n,
	output logic 		 tmds_clock_p,
	output logic 		 tmds_clock_n

);

parameter BIT_WIDTH   = 12 ;
parameter BIT_HEIGHT  = 11 ;
parameter FONT_WIDTH  = 8  ;
parameter FONT_HEIGHT = 16 ;

logic [15:0] audio_sample_word [1:0] = '{ 16'sd0, 16'sd0 } ;

always @(posedge clk_audio) begin

  audio_sample_word <= '{ audio_sample_word[0] + 16'sd1, audio_sample_word[1] - 16'sd1 } ;
  
end

logic [23:0] rgb = 24'd0    ;
logic [BIT_WIDTH - 1:0]  cx ;
logic [BIT_HEIGHT - 1:0] cy ;
logic [11:0] screen_start_x ;
logic [11:0] screen_start_y ;
logic [11:0] frame_width    ;
logic [11:0] frame_height   ;
logic [11:0] screen_width   ;
logic [11:0] screen_height  ;

// Video ID Code 1 = 640  x 480 @ 60Hz - c0=126/25, c1=63/125,      c2=3/3125
// Video ID Code 2 = 720  x 480 @ 60Hz - c0=27/5,   c1=27027/50000, c2=3/3125
// Video ID Code 4 = 1280 x 720 @ 60Hz - c0=297/40, c1=297/200,     c2=3/3125, DDRIO ON
hdmi #(
	.VIDEO_ID_CODE(1),		 // Defaults to 640x480 which should be supported by almost if not all HDMI sinks. See README.md or CEA-861-D for enumeration of video id codes.
	.DVI_OUTPUT(1'b0),       // Enable this flag for DVI output. Use this to reduce resource usage if you're only outputting video (non-HDMI).
	.DDRIO(1'b0),				 // Enable Double-Data Rate (x10 pixel clock only needs to be x5 instead of x10)
	.VIDEO_REFRESH_RATE(60), // Specify the refresh rate in Hz we're using for audio calculations
	.AUDIO_RATE(48000),      // As specified in Section 7.3, the minimal audio requirements are met: 16-bit or more L-PCM audio at 32 kHz, 44.1 kHz, or 48 kHz.
	.AUDIO_BIT_WIDTH(16) 	 // Defaults to minimum bit lengths required to represent positions. Modify these parameters if you have alternate desired bit lengths.
) hdmi(
  // inputs
  .clk_pixel_x10(clk_pixel_x10),
  .clk_pixel(clk_pixel),
  .clk_audio(clk_audio),
  .rgb(rgb),
  .audio_sample_word(audio_sample_word),
  // video outputs
  .tmds_p(tmds_p),
  .tmds_clock_p(tmds_clock_p),
  .tmds_n(tmds_n),
  .tmds_clock_n(tmds_clock_n),
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

logic [7:0] character = 8'h30;
logic [5:0] prevcy = 6'd0;

// Border test (left = red, top = green, right = blue, bottom = blue, fill = black)
always @(posedge clk_pixel) begin

	//rgb <= { cx == screen_start_x ? ~8'd0 : 8'd0, cy == screen_start_y ? ~8'd0 : 8'd0, cx == frame_width - 1'd1 || cy == frame_height - 1'd1 ? ~8'd0 : 8'd0 } ;
	if (cy == 10'd0)
    begin
        character <= 8'h30;
        prevcy <= 6'd0;
    end
    else if (prevcy != cy[9:4])
    begin
        character <= character + 8'h01;
        prevcy <= cy[9:4];
    end
  
end

console console(.clk_pixel(clk_pixel), .codepoint(character), .attribute({cx[9], cy[8:6], cx[8:5]}), .cx(cx), .cy(cy), .rgb(rgb));

endmodule
