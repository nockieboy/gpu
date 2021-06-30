// *********************************************************************
//
// HDMI_PLL.sv clock generator with a fractional DPLL audio
// sample clock generator synchronous to the pixel clock.
//
// Version 1.0, Jan 18, 2021
// Written by Brian Guralnick.
// For public use.
// Leave questions in the https://www.eevblog.com/forum/ in the FPGA section.
//
// *********************************************************************

//
// Parameter Support table: ( .HDPLL_CLK_KHZ_IN(), .HDPLL_PIXEL_KHZ_OUT() )
// Output pixel frequencies are chosen based on clean multiples or (27MHz/4)
// 48MHz and 50MHz cannot always achieve perfect frequencies when .HDPLL_USE_2_PLLS() is disabled.
// If you have a spare PLL, it is recommended that you use the 'HDPLL_USE_2_PLLS' feature
// which first converts the source clock into 13.500MHz for the pixel clock PLL.
//
// .HDPLL_CLK_KHZ_IN() supported frequencies for 1 PLL mode.
//
// 27000, 27000  = 27 MHz in, 27    MHz  clk_pixel   *** Use this guy when RTL simulating using a 25MHz source clk so that the waveform grid lines up perfectly.
// 27000, 54000  = 27 MHz in, 54    MHz  clk_pixel   *** Good for 480p @ 120Hz
// 27000, 74250  = 27 MHz in, 74.25 MHz  clk_pixel
// 27000, 81000  = 27 MHz in, 81    MHz  clk_pixel   Used for 1280x960p    @60Hz, 4:3,  ModeID 964   More support on PC monitors.
// 27000, 94500  = 27 MHz in, 94.5  MHz  clk_pixel   Used for 1280x1024p   @60Hz. Overclocking here on non -GX Cyclones, recommend an HDMI cable driver amp.
// 27000, 108000 = 27 MHz in, 108   MHz  clk_pixel   Used for 1440x960p    @60Hz, 16:9, ModeID 961   More compatible than 4:3 version
// 27000, 121500 = 27 MHz in, 121.5 MHz  clk_pixel   Used for 1920x1080p   @50hz, 16:9, ModeID 1850  **Non standard, wont work on many monitors.
// 27000, 148500 = 27 MHz in, 148.5 MHz  clk_pixel   Used for normal 1080p @60Hz, but GX series Cyclones with high speed transmitters required.
// 27000, 25200  = 27 MHz in, 25.2  MHz  clk_pixel   Used for VGA 640x480  @60Hz.
//
// 54000, ^^^^^  > ********** same accuracy as 27000. *************
// 13500, ^^^^^  > ********** same accuracy as 27000. *************
//
// 48000, 27000  = 48 MHz in, 27    MHz  clk_pixel x5=135
// 48000, 54000  = 48 MHz in, 54    MHz  clk_pixel x5=270
// 48000, 74250  = 48 MHz in,*74.25 MHz* clk_pixel x5=371.25  *=clk_pixel is not exact
// 48000, 81000  = 48 MHz in, 81    MHz  clk_pixel x5=405
// 48000, 94500  = 48 MHz in,*94.5  MHz* clk_pixel x5=472.5   *=clk_pixel is not exact
// 48000, 108000 = 48 MHz in, 108   MHz  clk_pixel x5=540
// 48000, 121500 = 48 MHz in,*121.5 MHz* clk_pixel x5=607.5   *=clk_pixel is not exact
// 48000, 148500 = 48 MHz in,*148.5 MHz* clk_pixel x5=742.5   *=clk_pixel is not exact
// 48000, 25200  = 48 MHz in, 25.2  MHz  clk_pixel x5=126
//
// 50000, 27000  = 50 MHz in, 27    MHz  clk_pixel
// 50000, 54000  = 50 MHz in, 54    MHz  clk_pixel
// 50000, 74250  = 50 MHz in,*74.25 MHz* clk_pixel             *=clk_pixel is not exact
// 50000, 81000  = 50 MHz in, 81    MHz  clk_pixel
// 50000, 94500  = 50 MHz in,*94.5  MHz* clk_pixel             *=clk_pixel is not exact
// 50000, 108000 = 50 MHz in, 108   MHz  clk_pixel
// 50000, 121500 = 50 MHz in, 121.5 MHz  clk_pixel
// 50000, 148000 = 50 MHz in,*148.5 MHz* clk_pixel             *=clk_pixel is not exact
// 48000, 25200  = 50 MHz in, 25.2  MHz  clk_pixel
//
// In 2 PLL mode, these are the additional supported .HDPLL_CLK_KHZ_IN frequencies:
//
//  13500, 14318*, 16000, 20000, 24000, 25000, 27000, 32000, 36000, 40000, 48000,
//  50000, 54000, 60000, 65000, 66000, 75000, 100000, 150000, 33333*, 66666* KHz.
//
// For 2 PLL mode, the output frequencies are exact just as if the source frequency was 27000KHz.
// * Note: 14318 is the NTSC color burst frequency 3.57954545MHz X4, or 14.3181818MHz.
//         The conversion is x66/35, the broadcast standard compatible conversion to 27.000000MHz.
//         33333* = 33.333333MHz and 66666* = 66.666666MHz.
//
// The audio_ena output 1 pixel strobe will have a correction based on the true achieved pixel_clk.
// The clk_audio output is logic generated and an approximate 50/50 duty cycle, +/- 1 pixel clock.
//

module HDMI_PLL #(

parameter int  HDPLL_CLK_KHZ_IN      = 50000,   // PLL source clock frequency in KHz.
parameter int  HDPLL_PIXEL_KHZ_OUT   = 27000,   // PLL clk_pixel output frequency in KHz

parameter bit  HDPLL_USE_2_PLLS      = 1'b1,    // If the source clock isn't 27MHz and you want an exact pixel clock for every frequency, enabling
                                                // this bit sets up a pre-pll to convert the clk_in first into 27MHz to feed the main pixel clock's PLL.

parameter int  HDPLL_TRICK_MBPS      = 0,       // 0=disable, set to 640 or 740 to trick Quartus into believing the LVDS is running at that speed
                                                // when your pixel clock goes slightly above your chosen LVDS/LVDS_E_3R port's toggle rate limit.
                                                // Gate level timing simulation with this option enabled will fail.  This will also cause improper timing
                                                // reports & potentially poor system stability.  It is better to use the separate dedicated altlvds_tx 
                                                // based PLL so that only a tiny few gates in the serializer are the only ones running outside of spec.

parameter int  HDPLL_AUDIO_HZ        = 48000,   // Selects the desired number of pulses per second the audio_ena output strobes.
                                                // Allowable range is 32000Hz to 500000Hz.

parameter bit  HDPLL_AUDIO_TCK_FLOAT = 1'b1     // Does an interpreted sub-clk_pixel division when generating the audio_ena output.
                                                // Example: at 74.25MHz, the period of (74250000/48000=1546.875) is required, but when
                                                // that period is rounded to an integer value of 1547 pixel clocks.  The result is 
                                                // 74250000/1547 = 47996.12153 Hz, or an error of -3.87847Hz.  With FLOAT enabled, the 
                                                // period divider will have up to 12 additional floating point bits. For (74250000/48000), 3 additional
                                                // bits would be used for the new period, now at 12375, 74250000*8/12375=48000 exact.  The resulting
                                                // audio_ena strobe will occasionally delay for 1 pixel clock when counting the 1546 integer
                                                // figure to make a true 48000Hz reference.  That occasional 1 pixel clock shift
                                                // may be considered jitter.  However, looking at the HDMI audio packet subsystem,
                                                // it looks like a grand degree of jitter is inserted with any async source clock
                                                // and it is up to the playback hardware to deal/clean it up.  Just leave this option
                                                // enabled unless you absolutely must avoid that occasional 1 pixel clock correction jitter.
                                                // Otherwise, don't use this clock and supply your own external audio clock.
)
(
   clk_in,                // Input clock.

   clk_pixel,             // Output pixel clock.
   clk_pixel_x5,          // Output pixel clock 5x the frequency for serializer.
   clk_pixel_half,        // Output half the output pixel clock frequency.

   audio_ena,             // Output DLL Generated Audio sample enable pulse synchronous to pixel clock.
   clk_audio,             // Output Logic DLL generated audio clock.

   clk_pixel_true_hz,     // A 29 bit integer containing the true pixel clock frequency in Hz.
   clk_audio_true_hz      // A 19 bit integer containing the true audio clock frequency in Hz.
);

input               clk_in;                 // Input clock.
output              clk_pixel;              // Output pixel clock.
output              clk_pixel_x5;           // Output pixel clock 5x the frequency for serializer.
output              clk_pixel_half;         // Output half the output pixel clock frequency.

output logic        audio_ena = 1'b0;       // Output DLL Generated Audio sample enable pulse synchronous to pixel clock.
output logic        clk_audio = 1'b0;       // Output Logic DLL generated audio clock.

output logic [28:0] clk_pixel_true_hz;      // A 29 bit integer containing the true pixel clock frequency in Hz.
output logic [18:0] clk_audio_true_hz;      // A 19 bit integer containing the true audio clock frequency in Hz.







// ********************* Register error if an unsupported HDPLL_AUDIO_HZ output frequency was chosen. *********************
generate
if ( HDPLL_AUDIO_HZ < 32000 || HDPLL_AUDIO_HZ > 500000  ) initial begin

$warning("********************************");
$warning("*** HDMI_PLL PARAMETER ERROR ***");
$warning("*********************************************************************");
$warning("*** HDMI_PLL parameter .HDPLL_AUDIO_HZ(%d) is not supported. ***",20'(HDPLL_AUDIO_HZ));
$warning("*** Only a frequency from 32000Hz to 500000Hz is allowed.         ***");
$warning("*********************************************************************");
$error;
$stop;

end
endgenerate







// If HDPLL_USE_2_PLLS is enabled but the source clock is already 13.5MHz, 27MHz or 54MHz, disable the first PLL.
localparam bit HDPLL_USE_2_PLLS_TRUE = HDPLL_USE_2_PLLS && (HDPLL_CLK_KHZ_IN != 27000) && (HDPLL_CLK_KHZ_IN != 54000) && (HDPLL_CLK_KHZ_IN != 13500);


localparam int PLL0_inps             = ( 1.0E9 / HDPLL_CLK_KHZ_IN ) ;    // In 2 PLL mode, specify the first PLL's input clock period.
localparam int PLL0_table_clkin_sel  = ( (HDPLL_CLK_KHZ_IN==14318 )*1  + // actually 14.318181MHz = 4xNTSC 3.57954545MHz crystal, 
                                         (HDPLL_CLK_KHZ_IN==16000 )*2  + // yes, we hit 27MHz as NTSC * 4 * (66 / 35) = 26999999.97Hz.  An error of 0.03Hz.
                                         (HDPLL_CLK_KHZ_IN==20000 )*3  +
                                         (HDPLL_CLK_KHZ_IN==24000 )*4  +
                                         (HDPLL_CLK_KHZ_IN==25000 )*5  +
                                         (HDPLL_CLK_KHZ_IN==32000 )*6  +
                                         (HDPLL_CLK_KHZ_IN==36000 )*7  +
                                         (HDPLL_CLK_KHZ_IN==40000 )*8  +
                                         (HDPLL_CLK_KHZ_IN==48000 )*9  +
                                         (HDPLL_CLK_KHZ_IN==50000 )*10 +
                                         (HDPLL_CLK_KHZ_IN==54000 )*11 +
                                         (HDPLL_CLK_KHZ_IN==60000 )*12 +
                                         (HDPLL_CLK_KHZ_IN==65000 )*13 +
                                         (HDPLL_CLK_KHZ_IN==66000 )*14 +
                                         (HDPLL_CLK_KHZ_IN==75000 )*15 +
                                         (HDPLL_CLK_KHZ_IN==100000)*16 +
                                         (HDPLL_CLK_KHZ_IN==150000)*17 +
                                         (HDPLL_CLK_KHZ_IN==33333 )*18 +
                                         (HDPLL_CLK_KHZ_IN==66666 )*19   ) ;    // Select the multiplier & divider factors for PLL0.








// ********************* Register error if an unsupported PLL input frequency was chosen in 2 PLL mode. *********************
generate
if ( PLL0_table_clkin_sel == 0 && HDPLL_USE_2_PLLS_TRUE ) initial begin

$warning("********************************");
$warning("*** HDMI_PLL PARAMETER ERROR ***");
$warning("************************************************************************************************");
$warning("*** HDMI_PLL parameter .HDPLL_CLK_KHZ_IN(%d) is not available in 2 PLL mode.            ***",20'(HDPLL_CLK_KHZ_IN));
$warning("*** Only 13500, 14318, 16000, 20000, 24000, 25000, 27000, 32000, 33333, 36000, 40000, 48000, ***");
$warning("*** 50000, 54000, 60000, 65000, 66000, 66666, 75000, 100000, or 150000 KHz is allowed.       ***");
$warning("************************************************************************************************");
$error;
$stop;

end
endgenerate









// PLL0's settings table.
localparam int PLL0_table_md  [0:(20*2-1)]  = '{                                        // For 2 PLL mode, table selection for PLL0's
// ERROR 14.3M 16.0M 20.0M 24.0M 25.0M 32.0M 36.0M 40.0M 48.0M 50.0M  54.0M 60.0M 65.0M 66.0M 75.0M  100M  150M   33.333m 66.666m    // multiply and divide factors
// 1,1,  66,35,27,16,27,20,09,08,27,25,27,32,03,04,27,40,09,15,27,50, 01,02,09,20,27,65,09,22,09,25,27,100,09,50 ,81,100, 81,200 };  // 27000 out table
   1,1,  33,35,27,32,27,40,09,16,27,50,27,64,03,08,27,80,03,10,27,100,01,04,09,40,27,70,09,44,09,50,27,200,09,100,81,200, 81,400 };  // 13500 out table

localparam int PLL0_mult         = PLL0_table_md [ (PLL0_table_clkin_sel*2 + 0) ]   ; // Select the PLL multiplication factor.
localparam int PLL0_div          = PLL0_table_md [ (PLL0_table_clkin_sel*2 + 1) ]   ; // Select the PLL division factor.

// Register the true PLL0's output frequency in Hz correcting the rounding error for source clocks
// with infinite repeating decimals like 14.3181818181818181818181818181MHz or 66.66666666666666666MHz.
localparam int PLL0_OUT_TRUE_KHZ = (HDPLL_CLK_KHZ_IN==14318 ||
                                    HDPLL_CLK_KHZ_IN==33333 ||
                                    HDPLL_CLK_KHZ_IN==66666    ) ? (HDPLL_CLK_KHZ_IN * PLL0_mult / PLL0_div)+1 : (HDPLL_CLK_KHZ_IN * PLL0_mult / PLL0_div) ;


localparam int PLL1_KHZ_IN = HDPLL_USE_2_PLLS_TRUE ? PLL0_OUT_TRUE_KHZ : HDPLL_CLK_KHZ_IN ; // Specify pixel clock PLL's input frequency

localparam int PLL1_table_height     =  5  +1  ;                                   // Number of input frequencies in table, ie Y coordinate size.
localparam int PLL1_table_width      =  9  +1  ;                                   // Number of output frequencies in table, ie X coordinate size.

localparam int PLL1_table_clkin_sel  = ( (PLL1_KHZ_IN==27000)*1 +                  // Select the Y coordinate for PLL1's settings table.
                                         (PLL1_KHZ_IN==48000)*2 +
                                         (PLL1_KHZ_IN==50000)*3 +
                                         (PLL1_KHZ_IN==54000)*4 +
                                         (PLL1_KHZ_IN==13500)*5   ) ;







// ********************* Register error if an unsupported PLL input frequency was chosen in 1 PLL mode. *********************
generate
if ( PLL1_table_clkin_sel == 0 ) initial begin

$warning("********************************");
$warning("*** HDMI_PLL PARAMETER ERROR ***");
$warning("*************************************************************************************");
$warning("*** HDMI_PLL parameter .HDPLL_CLK_KHZ_IN(%d) is not available in 1 PLL mode. ***",20'(HDPLL_CLK_KHZ_IN));
$warning("*** Only 13500, 27000, 48000, 50000, or 54000 KHz is allowed.                     ***");
$warning("*************************************************************************************");
$error;
$stop;

end
endgenerate






localparam int PLL1_table_clkout_sel = ( (HDPLL_PIXEL_KHZ_OUT==27000 )*1 +         // Select the X coordinate for PLL1's settings table.
                                         (HDPLL_PIXEL_KHZ_OUT==54000 )*2 +
                                         (HDPLL_PIXEL_KHZ_OUT==74250 )*3 +
                                         (HDPLL_PIXEL_KHZ_OUT==81000 )*4 +
                                         (HDPLL_PIXEL_KHZ_OUT==94500 )*5 +
                                         (HDPLL_PIXEL_KHZ_OUT==108000)*6 +
                                         (HDPLL_PIXEL_KHZ_OUT==121500)*7 +
                                         (HDPLL_PIXEL_KHZ_OUT==148500)*8 +
                                         (HDPLL_PIXEL_KHZ_OUT==25200 )*9   ) ;







// ********************* Register error if an unsupported PLL output frequency was chosen. *********************
generate
if ( PLL1_table_clkout_sel == 0 ) initial begin

$warning("********************************");
$warning("*** HDMI_PLL PARAMETER ERROR ***");
$warning("***************************************************************************");
$warning("*** HDMI_PLL parameter .HDPLL_PIXEL_KHZ_OUT(%d) is not supported.  ***",20'(HDPLL_PIXEL_KHZ_OUT));
$warning("*** Only pixel frequencies of 25200, 27000, 54000, 74250, 81000,        ***");
$warning("*** 94500, 108000, 121500, or 148500 KHz are available.                 ***");
$warning("***************************************************************************");
$error;
$stop;

end
endgenerate







// PLL1's settings table.
localparam int PLL1_table_md  [0:(PLL1_table_width*2*PLL1_table_height-1)] = '{                 // The first number is the PLL multiplier while the second is the PLL divider
//         X=0     X=1     X=2    X=3      X=4      X=5    X=6     X=7      X=8     x=9
// clk_1x  ERROR   27.0m   54.0m  74.25m   81.0m    94.5m  108.0m  121.5m   148.5m  25.2m       // Note that the PLL tables actually generate the clk_pixel_5x frequency

           1 ,1 ,  1 ,1 ,  1 ,1,  1  ,1 ,  1  ,1 ,  1 ,1,  1 ,1,   1  ,1 ,  1  ,1,  1 ,1 ,      // Y=ERROR
           1 ,1 ,  5 ,1 ,  10,1,  55 ,4 ,  15 ,1 ,  35,2,  20,1,   45 ,2 ,  55 ,2,  14,3 ,      // Y=1 Table for 27000KHz clkin
           1 ,1 ,  45,16,  45,8,  116,15,  135,16,  59,6,  45,4,   38 ,3 ,  31 ,2,  21,8 ,      // Y=2 table for 48000KHz clkin
           1 ,1 ,  27,10,  27,5,  52 ,7 ,  81 ,10,  85,9,  54,5,   243,20,  104,7,  63,25,      // Y=3 table for 50000KHz clkin
           1 ,1 ,  5 ,2 ,  5 ,1,  52 ,7 ,  15 ,2 ,  34,4,  10,1,   45 ,4 ,  55 ,4,  7 ,3 ,      // Y=4 table for 54000KHz clkin
           1 ,1 ,  10,1 ,  20,1,  55 ,2 ,  31 ,1 ,  35,1,  40,1,   45 ,1 ,  55 ,1,  28,3   };   // Y=5 table for 13500KHz clkin

// clk_x5          135.0m  270.0m 371.25m  405.0m   472.5m 540.0m  607.5m   742.5m  126.0m

localparam int PLL1_mult         = PLL1_table_md [ (PLL1_table_clkin_sel * PLL1_table_width*2 + PLL1_table_clkout_sel*2 + 0) ]; // Select the PLL multiplication factor.
localparam int PLL1_div          = PLL1_table_md [ (PLL1_table_clkin_sel * PLL1_table_width*2 + PLL1_table_clkout_sel*2 + 1) ]; // Select the PLL division factor.

localparam int PLL1_OUT_TRUE_KHZ = (PLL1_KHZ_IN * PLL1_mult / PLL1_div / 5) ;                                                   // Register the true clk_pixel frequency in KHz.
localparam int PLL1_OUT_TRUE_HZ  = (PLL1_KHZ_IN * 200*PLL1_mult / PLL1_div) ; // Register the true clk_pixel frequency in Hz.  Extra precision needed for audio clock generator.


// Generate a phony input clock frequency for PLL1 to underscore what Quartus
// believes the LVDS transmitter is working at.  This will cause improper timing
// reports and poor system stability.  It is better to use the separate LVDS based PLL
// so that a single tiny few gates in the serializer are the only ones running overclocked.
localparam int PLL1_KHZ_IN_TRICK = PLL1_KHZ_IN * HDPLL_TRICK_MBPS / PLL1_OUT_TRUE_KHZ * 100 ;

 
// Specify PLL1, the pixel clock PLL's source clock period in picoseconds.
localparam int PLL1_inps = (HDPLL_TRICK_MBPS==0 || HDPLL_TRICK_MBPS>(PLL1_OUT_TRUE_KHZ/100)) ? (1.0E9 / PLL1_KHZ_IN) : (1.0E9 / PLL1_KHZ_IN_TRICK) ; 







// ********************* Generate warning if the HDPLL_TRICK_MBPS is enabled. *********************
generate
if ( HDPLL_TRICK_MBPS!=0 ) initial begin
if (HDPLL_TRICK_MBPS>(PLL1_OUT_TRUE_KHZ/100)) begin
$info("*********************");
$info("*** HDMI_PLL Info ***");
$info("**********************************************************************");
$info("*** HDMI_PLL parameter .HDPLL_TRICK_MBPS setting of (%d) was not ***",12'(HDPLL_TRICK_MBPS));
$info("*** used since the pixel clock frequency X 10 is only %d mbps.   ***",12'(PLL1_OUT_TRUE_KHZ/100));
$info("**********************************************************************");
end else begin
$warning("************************");
$warning("*** HDMI_PLL WARNING ***");
$warning("****************************************************************************");
$warning("*** HDMI_PLL parameter .HDPLL_TRICK_MBPS setting of (%d) is in use     ***",12'(HDPLL_TRICK_MBPS));
$warning("*** since the pixel clock frequency X10 is higher at %d mbps.  Quartus ***",12'(PLL1_OUT_TRUE_KHZ/100));
$warning("*** is being falsely instructed that the HDMI_PLL pixel clock is running ***");
$warning("*** slower to allow full compilation for LVDS or LVDS_E_3R ports.  The   ***");
$warning("*** timing report will be inaccurate.  Read the instructions in the      ***");
$warning("*** 'HDMI_PLL.sv' source code to see if this is EXACTLY what you want to ***");
$warning("*** do.  Proper design functionality is not guaranteed.                  ***");
$warning("****************************************************************************");
end
end
endgenerate









// ***************************************************************
// *** Begin Initiate Altera PLL when using 2 PLL mode.        ***
// *** This PLL takes the clk_in and converts it to a perfect  ***
// *** 27MHz source clock for the clk in of clk_pixel PLL1     ***
// *** to generate a dead perfect pixel clock for every mode.  ***
// *** If your source is already 27MHz or the HDPLL_USE_2_PLLS ***
// *** is disabled, this first PLL will be bypassed when       ***
// *** compiling the design.  Some frequencies like 74.25MHz   ***
// *** may no longer be exact wit some source frequencies      ***
// ***************************************************************
wire [4:0]  PLL0_clk_out;        // PLL has 5 outputs.
generate
if (HDPLL_USE_2_PLLS_TRUE) begin // Add this PLL0 only if HDPLL_USE_2_PLLS_TRUE is set.

 altpll HPLL0 ( .inclk ({1'b0,clk_in}),  .clk (PLL0_clk_out),
                .activeclock (),         .areset (1'b0),       .clkbad (),          .clkena ({6{1'b1}}), .clkloss (),
                .clkswitch (1'b0),       .configupdate (1'b0), .enable0 (),         .enable1 (),         .extclk (),
                .extclkena ({4{1'b1}}),  .fbin (1'b1),         .fbmimicbidir (),    .fbout (),           .fref (),
                .icdrclk (),             .locked (),           .pfdena (1'b1),      .phasedone (),       .phasestep (1'b1),
                .phaseupdown (1'b1),     .pllena (1'b1),       .scanaclr (1'b0),    .scanclk (1'b0),     .scanclkena (1'b1),
                .scandata (1'b0),        .scandataout (),      .scandone (),        .scanread (1'b0),    .scanwrite (1'b0),
                .sclkout0 (),            .sclkout1 (),         .vcooverrange (),    .vcounderrange (),   .phasecounterselect ({4{1'b1}}));
 defparam
  HPLL0.bandwidth_type = "AUTO",          HPLL0.inclk0_input_frequency = PLL0_inps, HPLL0.compensate_clock = "CLK0",        HPLL0.lpm_hint = "CBX_MODULE_PREFIX=HDMI_PLL",
  HPLL0.clk0_divide_by =  PLL0_div,       HPLL0.clk0_duty_cycle = 50,               HPLL0.clk0_multiply_by = PLL0_mult,     HPLL0.clk0_phase_shift = "0",

  HPLL0.lpm_type         = "altpll",      HPLL0.operation_mode    = "NORMAL",       HPLL0.pll_type         = "AUTO",        HPLL0.port_activeclock        = "PORT_UNUSED",
  HPLL0.port_areset      = "PORT_UNUSED", HPLL0.port_clkbad0      = "PORT_UNUSED",  HPLL0.port_clkbad1     = "PORT_UNUSED", HPLL0.port_clkloss            = "PORT_UNUSED",
  HPLL0.port_clkswitch   = "PORT_UNUSED", HPLL0.port_configupdate = "PORT_UNUSED",  HPLL0.port_fbin        = "PORT_UNUSED", HPLL0.port_inclk0             = "PORT_USED",
  HPLL0.port_inclk1      = "PORT_UNUSED", HPLL0.port_locked       = "PORT_UNUSED",  HPLL0.port_pfdena      = "PORT_UNUSED", HPLL0.port_phasecounterselect = "PORT_UNUSED",
  HPLL0.port_phasedone   = "PORT_UNUSED", HPLL0.port_phasestep    = "PORT_UNUSED",  HPLL0.port_phaseupdown = "PORT_UNUSED", HPLL0.port_pllena             = "PORT_UNUSED",
  HPLL0.port_scanaclr    = "PORT_UNUSED", HPLL0.port_scanclk      = "PORT_UNUSED",  HPLL0.port_scanclkena  = "PORT_UNUSED", HPLL0.port_scandata           = "PORT_UNUSED",
  HPLL0.port_scandataout = "PORT_UNUSED", HPLL0.port_scandone     = "PORT_UNUSED",  HPLL0.port_scanread    = "PORT_UNUSED", HPLL0.port_scanwrite          = "PORT_UNUSED",
  HPLL0.port_clk0        = "PORT_USED",   HPLL0.port_clk1         = "PORT_UNUSED",  HPLL0.port_clk2        = "PORT_UNUSED", HPLL0.port_clk3               = "PORT_UNUSED",
  HPLL0.port_clk4        = "PORT_UNUSED", HPLL0.port_clk5         = "PORT_UNUSED",  HPLL0.port_clkena0     = "PORT_UNUSED", HPLL0.port_clkena1            = "PORT_UNUSED",
  HPLL0.port_clkena2     = "PORT_UNUSED", HPLL0.port_clkena3      = "PORT_UNUSED",  HPLL0.port_clkena4     = "PORT_UNUSED", HPLL0.port_clkena5            = "PORT_UNUSED",
  HPLL0.port_extclk0     = "PORT_UNUSED", HPLL0.port_extclk1      = "PORT_UNUSED",  HPLL0.port_extclk2     = "PORT_UNUSED", HPLL0.port_extclk3            = "PORT_UNUSED",
  HPLL0.width_clock      = 5,             HPLL0.intended_device_family = "Cyclone IV E";

end else begin                           // HDPLL_USE_2_PLLS_TRUE is not set, in 1 PLL mode.
assign        PLL0_clk_out[0] = clk_in ; // Pass the clk_in directly to PLL1.
end
endgenerate

// **********************************************************
// *** Begin Initiate Altera PLL for clk_pixel generation ***
// **********************************************************
wire [4:0]  PLL1_clk_out;                     // PLL has 5 outputs.
wire        clk_pixel      = PLL1_clk_out[0]; // clk_pixel      is on PLL output 0
wire        clk_pixel_x5   = PLL1_clk_out[1]; // clk_pixel_x5   is on PLL output 1
wire        clk_pixel_half = PLL1_clk_out[2]; // clk_pixel_half is on PLL output 2

 altpll HPLL1 ( .inclk ({1'b0, PLL0_clk_out[0]}), .clk (PLL1_clk_out),
                .activeclock (),         .areset (1'b0),       .clkbad (),          .clkena ({6{1'b1}}), .clkloss (),
                .clkswitch (1'b0),       .configupdate (1'b0), .enable0 (),         .enable1 (),         .extclk (),
                .extclkena ({4{1'b1}}),  .fbin (1'b1),         .fbmimicbidir (),    .fbout (),           .fref (),
                .icdrclk (),             .locked (),           .pfdena (1'b1),      .phasedone (),       .phasestep (1'b1),
                .phaseupdown (1'b1),     .pllena (1'b1),       .scanaclr (1'b0),    .scanclk (1'b0),     .scanclkena (1'b1),
                .scandata (1'b0),        .scandataout (),      .scandone (),        .scanread (1'b0),    .scanwrite (1'b0),
                .sclkout0 (),            .sclkout1 (),         .vcooverrange (),    .vcounderrange (),   .phasecounterselect ({4{1'b1}}));
 defparam
  HPLL1.bandwidth_type = "AUTO",          HPLL1.inclk0_input_frequency = PLL1_inps, HPLL1.compensate_clock = "CLK0",        HPLL1.lpm_hint = "CBX_MODULE_PREFIX=HDMI_PLL",
  HPLL1.clk0_divide_by = (PLL1_div*5),    HPLL1.clk0_duty_cycle = 50,               HPLL1.clk0_multiply_by = PLL1_mult,     HPLL1.clk0_phase_shift = "0",
  HPLL1.clk1_divide_by = PLL1_div,        HPLL1.clk1_duty_cycle = 50,               HPLL1.clk1_multiply_by = PLL1_mult,     HPLL1.clk1_phase_shift = "0",
  HPLL1.clk2_divide_by = (PLL1_div*10),   HPLL1.clk2_duty_cycle = 50,               HPLL1.clk2_multiply_by = PLL1_mult,     HPLL1.clk2_phase_shift = "0",

  HPLL1.lpm_type         = "altpll",      HPLL1.operation_mode    = "NORMAL",       HPLL1.pll_type         = "AUTO",        HPLL1.port_activeclock        = "PORT_UNUSED",
  HPLL1.port_areset      = "PORT_UNUSED", HPLL1.port_clkbad0      = "PORT_UNUSED",  HPLL1.port_clkbad1     = "PORT_UNUSED", HPLL1.port_clkloss            = "PORT_UNUSED",
  HPLL1.port_clkswitch   = "PORT_UNUSED", HPLL1.port_configupdate = "PORT_UNUSED",  HPLL1.port_fbin        = "PORT_UNUSED", HPLL1.port_inclk0             = "PORT_USED",
  HPLL1.port_inclk1      = "PORT_UNUSED", HPLL1.port_locked       = "PORT_UNUSED",  HPLL1.port_pfdena      = "PORT_UNUSED", HPLL1.port_phasecounterselect = "PORT_UNUSED",
  HPLL1.port_phasedone   = "PORT_UNUSED", HPLL1.port_phasestep    = "PORT_UNUSED",  HPLL1.port_phaseupdown = "PORT_UNUSED", HPLL1.port_pllena             = "PORT_UNUSED",
  HPLL1.port_scanaclr    = "PORT_UNUSED", HPLL1.port_scanclk      = "PORT_UNUSED",  HPLL1.port_scanclkena  = "PORT_UNUSED", HPLL1.port_scandata           = "PORT_UNUSED",
  HPLL1.port_scandataout = "PORT_UNUSED", HPLL1.port_scandone     = "PORT_UNUSED",  HPLL1.port_scanread    = "PORT_UNUSED", HPLL1.port_scanwrite          = "PORT_UNUSED",
  HPLL1.port_clk0        = "PORT_USED",   HPLL1.port_clk1         = "PORT_USED",    HPLL1.port_clk2        = "PORT_USED",   HPLL1.port_clk3               = "PORT_UNUSED",
  HPLL1.port_clk4        = "PORT_UNUSED", HPLL1.port_clk5         = "PORT_UNUSED",  HPLL1.port_clkena0     = "PORT_UNUSED", HPLL1.port_clkena1            = "PORT_UNUSED",
  HPLL1.port_clkena2     = "PORT_UNUSED", HPLL1.port_clkena3      = "PORT_UNUSED",  HPLL1.port_clkena4     = "PORT_UNUSED", HPLL1.port_clkena5            = "PORT_UNUSED",
  HPLL1.port_extclk0     = "PORT_UNUSED", HPLL1.port_extclk1      = "PORT_UNUSED",  HPLL1.port_extclk2     = "PORT_UNUSED", HPLL1.port_extclk3            = "PORT_UNUSED",
  HPLL1.width_clock      = 5,             HPLL1.intended_device_family = "Cyclone IV E";
// *******************************
// *** End Initiate Altera PLL ***
// *******************************

// Forcing 64 bits is required due to a ModelSim internal bug where if 'PLL1_OUT_TRUE_HZ*4096' exceedes 31 bits, it's considered negative and cropped
// when computing the localparam.  So, never use 'localparam int' when going above 2 billion anywhere inside, or you will get bogus results.
localparam bit [63:0] aud_per_x4096  = PLL1_OUT_TRUE_HZ*4096/HDPLL_AUDIO_HZ ;                               // Determine the audio period 4096 fold.
localparam bit [63:0] aud_per_round  = aud_per_x4096 + 2048 ;                                               // Prepare a rounded version. 
localparam bit [12:0] aud_per_int    = HDPLL_AUDIO_TCK_FLOAT ? aud_per_x4096[24:12] : aud_per_round[24:12]; // Select between the rounded integer period or true integer period.
localparam bit [11:0] aud_per_f      = HDPLL_AUDIO_TCK_FLOAT ? aud_per_x4096[11:0]  : 12'd0  ;              // select between no floating point and floating point adjusted audio clock generation.
localparam bit [63:0] aud_tru_hz     = PLL1_OUT_TRUE_HZ*4096 / (aud_per_int*4096+aud_per_f)  ;              // Calculate the true audio output clock based on oscilator frequencies & HDPLL_AUDIO_TCK_FLOAT settings.

assign          clk_audio_true_hz    = 19'( aud_tru_hz );        // pass the true audio sample frequency to an output port.
assign          clk_pixel_true_hz    = 29'( PLL1_OUT_TRUE_HZ ) ; // pass the true pixel clock frequency to an output port.

logic   [12:0]  aud_cnt_m  = 13'd0;
logic   [12:0]  aud_cnt_n  = 9'd0;

always_ff @(posedge clk_pixel) begin

if ( aud_cnt_m == (aud_per_int - !aud_cnt_n[12]) ) begin                          // Add 1 extra count to the period if the carry flag aud_cnt_n[12] is set.
                                        aud_cnt_m        <= 13'd0;
                                        audio_ena        <= 1'b1;
                                        clk_audio        <= 1'b1;
                                        aud_cnt_n        <= aud_cnt_n[11:0] + (aud_per_f) ; // add the floating point period while clearing the carry flag aud_cnt_n[12].
                        end else begin
                                        aud_cnt_m        <= aud_cnt_m + 1'b1;
                                        audio_ena        <= 1'b0;
                        if (aud_cnt_m[11:0]==aud_per_int[12:1]) clk_audio <= 1'b0; // generate an aproximate 50/50 duty cycle clk_audio output.
                        end

end

endmodule
