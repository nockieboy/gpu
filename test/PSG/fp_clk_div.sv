//
// Floating-point clock divider
//
// Adapted from code provided by BrianHG:
// https://www.eevblog.com/forum/fpga/fpga-vga-controller-for-8-bit-computer/3425
//

module fp_clk_div (

    input  logic clk_i,

    output logic clk_audio_true_hz,
    output logic clk_true_hz

);

parameter CLK_IN  = 100    ; // input  clock frequency in MHz
parameter CLK_OUT = 1.7815 ; // output clock frequency in MHz

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

localparam int PLL1_mult = PLL1_table_md [ (PLL1_table_clkin_sel * PLL1_table_width*2 + PLL1_table_clkout_sel*2 + 0) ]; // Select the PLL multiplication factor.
localparam int PLL1_div  = PLL1_table_md [ (PLL1_table_clkin_sel * PLL1_table_width*2 + PLL1_table_clkout_sel*2 + 1) ]; // Select the PLL division factor.

// Forcing 64 bits is required due to a ModelSim internal bug where if 'PLL1_OUT_TRUE_HZ*4096' exceedes 31 bits,
// it's considered negative and cropped when computing the localparam.  So, never use 'localparam int' when going
// above 2 billion anywhere inside, or you will get bogus results.
localparam int PLL1_OUT_TRUE_KHZ = (PLL1_KHZ_IN * PLL1_mult / PLL1_div / 5) ; // Register the true clk frequency in KHz.
localparam int PLL1_OUT_TRUE_HZ  = (PLL1_KHZ_IN * 200*PLL1_mult / PLL1_div) ; // Register the true clk frequency in Hz.  Extra precision needed for audio clock generator.
localparam bit [63:0] aud_per_x4096  = PLL1_OUT_TRUE_HZ*4096/HDPLL_AUDIO_HZ ;                               // Determine the audio period 4096 fold.
localparam bit [63:0] aud_per_round  = aud_per_x4096 + 2048 ;                                               // Prepare a rounded version.
localparam bit [12:0] aud_per_int    = HDPLL_AUDIO_TCK_FLOAT ? aud_per_x4096[24:12] : aud_per_round[24:12]; // Select between the rounded integer period or true integer period.
localparam bit [11:0] aud_per_f      = HDPLL_AUDIO_TCK_FLOAT ? aud_per_x4096[11:0]  : 12'd0  ;              // Select between no floating point and floating point adjusted audio clock generation.
localparam bit [63:0] aud_tru_hz     = PLL1_OUT_TRUE_HZ*4096 / (aud_per_int*4096+aud_per_f)  ;              // Calculate the true audio output clock based on oscilator frequencies & HDPLL_AUDIO_TCK_FLOAT settings.

assign clk_audio_true_hz = 32'( aud_tru_hz )       ; // pass the true audio sample frequency to an output port.
assign clk_true_hz       = 32'( PLL1_OUT_TRUE_HZ ) ; // pass the true pixel clock frequency to an output port.

logic [12:0]  aud_cnt_m  = 13'd0 ;
logic [12:0]  aud_cnt_n  = 13'd0 ;

always_ff @(posedge clk_i) begin

    if ( aud_cnt_m == (aud_per_int - !aud_cnt_n[12]) ) begin // Add 1 extra count to the period if the carry flag aud_cnt_n[12] is set.

        aud_cnt_m <= 13'd0;
        audio_ena <= 1'b1;
        clk_audio <= 1'b1;
        aud_cnt_n <= aud_cnt_n[11:0] + (aud_per_f) ; // add the floating point period while clearing the carry flag aud_cnt_n[12].

    end else begin

        aud_cnt_m <= aud_cnt_m + 1'b1;
        audio_ena <= 1'b0;
        if (aud_cnt_m[11:0]==aud_per_int[12:1]) clk_audio <= 1'b0; // generate an aproximate 50/50 duty cycle clk_audio output.

    end

end

endmodule;
