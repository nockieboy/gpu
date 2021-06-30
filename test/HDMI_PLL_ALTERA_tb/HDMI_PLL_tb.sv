//
// HDMI_PLL_tb PLL testbench
//
// Written by Brian Guralnick.
//
//
// This test bench times the PLL for 1ms, so it takes a minute to simulate.
// It proves the accuracy of the clk_audio output generator when the requested
// frequency does not evenly divide into the clk_pixel output frequency.
//
//
`timescale 1 ps/ 1 ps // 1 picosecond steps, 1 picosecond precision.

module HDMI_PLL_tb();
logic        clk = 1'b0;
logic        clk_pixel;
logic        clk_pixel_x5;
logic        audio_ena;
logic        clk_audio;
logic        [28:0] clk_pixel_true_hz;
logic        [18:0] clk_audio_true_hz;

localparam       CLK_KHz            = 20000 ;  // Source clock in KHz.
localparam       CLK_pixel          = 74250 ;  // Pixel clk in KHz.
localparam bit   USE_2_PLLs         = 1;       // More source clock speeds supported when enabled.  Disabled, some of the pixel clock
                                               // frequencies may be slightly off when the source clock isn't a multiple of 27MHz.
localparam       CLK_audio          = 48000 ;  // Frequency of software generated audio clock.
localparam bit   FLOAT_audio_clkgen = 1;       // Enable to perform precision synthesis of the audio clock frequency.

localparam       period  = 500000000/CLK_KHz ;
localparam real STOP_uS  = 1000000 ;
localparam      endtime  = STOP_uS * 1000;

// assign statements (if any)                          
HDMI_PLL #(
.HDPLL_CLK_KHZ_IN(CLK_KHz),   .HDPLL_PIXEL_KHZ_OUT(CLK_pixel), .HDPLL_USE_2_PLLS(1), .HDPLL_TRICK_MBPS(0),
.HDPLL_AUDIO_HZ  (CLK_audio), .HDPLL_AUDIO_TCK_FLOAT(FLOAT_audio_clkgen)
) DUT (
	.clk_in             (clk),               // Input clock.
	
	.clk_pixel          (clk_pixel),         // Output pixel clock.
	.clk_pixel_x5       (clk_pixel_x5),      // Output pixel clock 5x the frequency for serializer.
	.clk_pixel_half     (),                  // Output half the output pixel clock frequency.

	.audio_ena          (audio_ena),         // Output DLL Generated Audio sample enable pulse synchronous to pixel clock.
	.clk_audio          (clk_audio),         // Output Logic DLL generated audio clock.

        .clk_pixel_true_hz  (clk_pixel_true_hz), // A 29 bit integer containing the true pixel clock frequency in Hz.
        .clk_audio_true_hz  (clk_audio_true_hz)  // A 19 bit integer containing the true audio clock frequency in Hz.
);

logic [31:0] cntr_clk_pixel = 0;
logic [31:0] cntr_clk_audio = 0;


always #period clk = !clk; // create source clock oscilator
always @ (posedge clk_pixel) cntr_clk_pixel=cntr_clk_pixel+1;
always @ (posedge clk_audio) cntr_clk_audio=cntr_clk_audio+1;

always @(cntr_clk_pixel!=0) #(endtime) $stop; // Wait for PLL to start, then run the simulation until 1ms has been reached.
endmodule

