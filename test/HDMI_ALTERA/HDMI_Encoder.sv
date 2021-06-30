module HDMI_Encoder (

	input  logic       clk,

	output logic [3:0] tmds,  // Remember to set your IO standard in Quartus to LVDS or LVDS_E_3R mode.
	output logic       DE     // Data enable for NXP TMDS Amp.
	
);

// Video ID Code 1    = 640  x 480  @ 60Hz    - c0=25200  KHz
// Video ID Code 2    = 720  x 480  @ 59.94Hz - c0=27000  KHz
// Video ID Code 4    = 1280 x 720  @ 59.94Hz - c0=74250  KHz
// Video ID Code 34   = 1920 x 1080 @ 29.97Hz - c0=74250  KHz
// Video ID Code 964  = 1280 x 960  @ 59.94Hz - c0=94500  KHz  4:3  4x VGA 640x480  Brian Special,  4:3 960p, = 4x VGA640x480 - 94.5MHz
// Video ID Code 965  = 1280 x 960  @ 60Hz    - c0=108000 KHz  Vesa  1280x960
// Video ID Code 969  = 1440 x 960  @ 59.94Hz - c0=108000 KHz  16:9 4x 480p 720x480 Brian Special, 16:9 960p, = 4x 480p - 108MHz
// Video ID Code 1024 = 1280 x 1024 @ 60Hz    - c0=108000 KHz  Vesa  1280x1024 - 108MHz
// Video ID Code 1084 = 1920 x 1080 @ 49Hz    - c0=108000 KHz  Brian Special 1080p49hz super reduced blanking - 108MHz
//
// These 2 modes are 'TOO FAST FOR NORMAL PLL SETTINGS' since Quartus tries to run the PLL's core oscilator at 4x since we
// we have under-scored the source clock frequency to allow Quartus to fully compile the design with the over clocked serial TMDS outputs.
// A manual forced hand-made PLL configuration sent into a re-configurable PLL with the core at 2x might function.
//
// Video ID Code 16   = 1920 x 1080 @ 59.94Hz - c0=148500 KHz
// Video ID Code 1085 = 1920 x 1080 @ 50Hz    - c0=121500 KHz  Brian Special 1080p50hz reduced blanking - 121.5MHz
//

parameter  int VIDEO_ID        = 2     ;
parameter  int DVI_MODE        = 0     ;
parameter      VIDEO_REFRESH   = 59.94 ;

// Read instructions inside "HDMI_PLL.sv" for allowable PLL settings and which are best to be used.
parameter  int  HDPLL_CLK_KHZ_IN        = 50000 ; // PLL source clock frequency in KHz.    *** There is a limited selection.  Read instructions inside "HDMI_PLL.sv" for allowable PLL settings.
parameter  int  HDPLL_PIXEL_KHZ_OUT     = 27000 ; // PLL clk_pixel output frequency in KHz *** There is a limited selection.  Read instructions inside "HDMI_PLL.sv" for allowable PLL settings.
parameter  bit  HDPLL_USE_2_PLLS        = 1'b1  ; // If the source clock isn't 27MHz and you want an exact pixel clock for every frequency, enabling will 
parameter  int  HDPLL_TRICK_MBPS        = 0     ; // 0=disable, set to 640 or 740 to trick Quartus into believing the LVDS is running at that this speed.
                                                  // Not as safe as using the HDMI_SERTX_INTERNAL_PLL feature in the HDMI_SERTX_altlvds module.
parameter  int  HDPLL_AUDIO_HZ          = 48000 ; // Selects the desired frequency of the clk_audio out & number of pulses per second the audio_ena output strobes.
parameter  bit  HDPLL_AUDIO_TCK_FLOAT   = 1'b1  ; // Does a interpreted sub-clk_pixel division when generating the clk_audio and audio_ena output.

parameter  bit  HDMI_SERTX_INTERNAL_PLL = 0     ; // When enabled, the altlvds_tx serializer will generate it's own 5x PLL for it's serial transmit clock
parameter  int  HDMI_SERTX_PIXEL_MBPS   = HDPLL_PIXEL_KHZ_OUT/100 ; // When the INTERNAL_PLL is enabled, this value specifies the pixel clock frequency.
                                                  // You may underscore the clock frequency to trick quartus into allowing compilation for slower LVDS ports.
                                                  // IE, use a setting of 740 to allow a Cyclone-7 740mbps LVDS bus compile when using 720p's 742.5mbps.

parameter  bit INV_TMDS0 = 1'b0 ; // Invert the TMDS channel 0 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
parameter  bit INV_TMDS1 = 1'b0 ; // Invert the TMDS channel 1 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
parameter  bit INV_TMDS2 = 1'b0 ; // Invert the TMDS channel 2 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
parameter  bit INV_TMDS3 = 1'b0 ; // Invert the TMDS channel 3 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 

parameter  int AUDIO_BIT_WIDTH = 16    ;
localparam int SAMPLE_RATE     = HDPLL_AUDIO_HZ ;

parameter FONT_WIDTH  = 8  ;
parameter FONT_HEIGHT = 16 ;

logic        [15:0] audio_sample_word [1:0] = '{ 16'sd0, 16'sd0 } ;
logic signed [15:0] sine_1k ;
logic               clk_pixel, clk_pixel_x5, clk_audio, audio_ena;

// *********************************************************************************************************
// *** Read instructions inside "HDMI_PLL.sv" for allowable PLL settings and which are best to be used.  ***
// *********************************************************************************************************
HDMI_PLL #( .HDPLL_CLK_KHZ_IN(HDPLL_CLK_KHZ_IN), .HDPLL_PIXEL_KHZ_OUT(HDPLL_PIXEL_KHZ_OUT), .HDPLL_USE_2_PLLS(HDPLL_USE_2_PLLS),
            .HDPLL_TRICK_MBPS(HDPLL_TRICK_MBPS), .HDPLL_AUDIO_HZ(HDPLL_AUDIO_HZ),           .HDPLL_AUDIO_TCK_FLOAT(HDPLL_AUDIO_TCK_FLOAT)
) HDMI_PLL( .clk_in(clk),                        .clk_pixel(clk_pixel),                     .clk_audio(clk_audio),
            .audio_ena(audio_ena),               .clk_pixel_x5(clk_pixel_x5)  );
// *********************************************************************************************************

always_comb DE = 1'b0;
always_comb audio_sample_word [1:0] = '{ sine_1k, sine_1k } ;

// only use .clk_ena if the .clk is tied to the clk_pixel instead of an audio sample clock.
Sine_1KHz_16b_48ksps Sine_1k ( .clk(clk_pixel), .clk_ena(audio_ena), .audio(sine_1k) ); 

logic [23:0] rgb = 24'd0    ;
logic [12:0] cx             ; // Maximum of 8191 pixels from left to right, IE frame width of 4400 for 2160p can be done.
logic [11:0] cy             ; // Maximum of 4095 lines counter for Y counter, IE 2160p which had 2250 lines can be done.
logic [12:0] screen_start_x ;
logic [11:0] screen_start_y ;
logic [12:0] frame_width    ;
logic [11:0] frame_height   ;
logic [12:0] screen_width   ;
logic [11:0] screen_height  ;

hdmi #(
    .HDMI_SERTX_INTERNAL_PLL (HDMI_SERTX_INTERNAL_PLL), // Set to 1 to activate a dedicated PLL for the altlvds_tc.  Set to 0 and you need to provide the clk_pixel_x5.
    .HDMI_SERTX_PIXEL_MBPS   (HDMI_SERTX_PIXEL_MBPS),   // Sets the pixel clock frequency for Altera's altlvds_tx serializer megafunction.  Only used when HDMI_SERTX_INTERNAL_PLL is enabled.
	                                                     // May be used to trick the compiler's maximum mbps, IE claim a slower clock than what the compiler will allow for specific IO standards.
    .INV_TMDS0         (INV_TMDS0),      // Invert the TMDS channel 0 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
    .INV_TMDS1         (INV_TMDS1),      // Invert the TMDS channel 1 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
    .INV_TMDS2         (INV_TMDS2),      // Invert the TMDS channel 2 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 
    .INV_TMDS3         (INV_TMDS3),      // Invert the TMDS channel 3 (IE swaps the +&- pins/output polarity when using a LVDS differential output.) 

	.VIDEO_ID_CODE      (VIDEO_ID),       // Defaults to 640x480 which should be supported by almost if not all HDMI sinks. See README.md or CEA-861-D for enumeration of video id codes.
	.DVI_OUTPUT         (DVI_MODE),       // Enable this flag for DVI output. Use this to reduce resource usage if you're only outputting video (non-HDMI).
	.VIDEO_REFRESH_RATE (VIDEO_REFRESH),  // Specify the refresh rate in Hz we're using for audio calculations
	.AUDIO_RATE         (SAMPLE_RATE),    // As specified in Section 7.3, the minimal audio requirements are met: 16-bit or more L-PCM audio at 32 kHz, 44.1 kHz, or 48 kHz.
	.AUDIO_BIT_WIDTH    (AUDIO_BIT_WIDTH) // Defaults to minimum bit lengths required to represent positions. Modify these parameters if you have alternate desired bit lengths.
) hdmi(
  // inputs
  .clk_pixel_x5        (clk_pixel_x5),
  .clk_pixel           (clk_pixel),
  .clk_audio           (clk_pixel),      // When using the clk_pixel synchronous enable audio sample, clk_audio_ena, place clk_pixel here.
  .clk_audio_ena       (audio_ena),      // Set this to 1'b1 if you are using a true speed asynchronous clk_audio clock instead of synchronous clk_pixel mode.
  .rgb                 (rgb),
  .audio_sample_word   (audio_sample_word),
  // video outputs
  .tmds_tx             (tmds),
  // internal outputs (don't go outside FPGA)
  .cx                  (cx),
  .cy                  (cy),
  .screen_start_x      (screen_start_x),
  .screen_start_y      (screen_start_y),
  .frame_width         (frame_width),
  .frame_height        (frame_height),
  .screen_width        (screen_width),
  .screen_height       (screen_height)
);

//logic [7:0] character = 8'h30 ;
//logic [5:0] prevcy    = 6'd0  ;

// Border test (left = red, top = green, right = blue, bottom = blue, fill = black)
always @(posedge clk_pixel) begin

  rgb <= { cx == screen_start_x ? ~8'd0 : 8'd0, cy == screen_start_y ? ~8'd0 : 8'd0, cx == frame_width - 1'd1 || cy == frame_height - 1'd1 ? ~8'd0 : 8'd0 } ;
/*
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
*/ 
end

//console console(.clk_pixel(clk_pixel), .codepoint(character), .attribute({cx[9], cy[8:6], cx[8:5]}), .cx(cx), .cy(cy), .rgb(rgb));

endmodule
