module YM2149_PSG_system #(

    parameter      CLK_IN_HZ  = 100000000, // Input clock frequency
    parameter      CLK_PSG_HZ = 1789000,   // PSG clock frequency
    parameter      I2S_DAC_HZ = 48000,     // I2S word clock frequency
    parameter      DAC_BITS   = 10,        // PSG DAC bit precision, 8 through 14 bits, the higher the bits, the higher the dynamic range.
    parameter      LPFILTER_DEPTH = 4      // 2=flat to 10khz, 4=flat to 5khz, 6=getting muffled, 8=no treble.

)(

    input  logic                       clk,
    input  logic                       reset,
    input  logic                [ 3:0] addr,      // register address
    input  logic                [ 7:0] data,      // data IN to PSG
    input  logic                       wr_n,      // data/addr valid

    output logic                [ 7:0] dout,      // PSG data output
    output logic                       i2s_sclk,  // I2S serial bit clock output
    output logic                       i2s_lrclk, // I2S L/R output
    output logic                       i2s_data,  // I2S serial audio out
    output logic signed [DAC_BITS+1:0] sound      // parallel   audio out

);

    // Signal declarations
    wire                       i2s_3072k   ; // I2S divided clock
    wire                       i2s_stb     ; // I2S divided strobe
    wire                       p_div       ; // PSG divided clock
    wire                       p_stb       ; // PSG divided strobe
    wire                       sample_stb  ; // Strobe for when the sample is ready
    wire        [DAC_BITS+1:0] sound_mix   ;
    wire signed [DAC_BITS+1:0] sound_dcf   ;

    // *******************************************************************************
    // Instantiate fp_div for PSG
    // *******************************************************************************
    fp_div #(
   
        .INPUT_CLK_HZ  (CLK_IN_HZ ),
        .OUTPUT_CLK_HZ (CLK_PSG_HZ)
   
    ) DUT (

        .clk_in        ( clk      ), // source clock for strobe (divided by DIVISOR if >1)
        .clk_out       ( p_div    ), // divided clock 50:50 duty cycle output
        .strobe_out    ( p_stb    )  // divided clock strobe output

    );

    // *******************************************************************************
    // Instantiate second fp_div for I2S transmitter
    // *******************************************************************************
    fp_div #(

        .INPUT_CLK_HZ        ( CLK_IN_HZ     ),
        .OUTPUT_CLK_HZ       ( I2S_DAC_HZ*64 ),
        .USE_FLOATING_DIVIDE (             1 )  

    ) fp_div_i2s (

        .clk_in              ( clk           ),
        .clk_out             ( i2s_3072k     ),
        .strobe_out          ( i2s_stb       )

    );

    // *******************************************************************************
    // Instantiate PSG
    // *******************************************************************************
    BHG_jt49 #(

        .DAC_BITS   ( DAC_BITS   )

    ) PSG (

        .rst_n      ( reset      ),
        .clk        ( clk        ),
        .clk_en     ( p_stb      ),
        .addr       ( addr       ),
        .cs_n       ( 1'b0       ),
        .wr_n       ( wr_n       ),
        .din        ( data       ),
        .sel        ( 1'b1       ),
        .dout       ( dout       ),
        .sound      ( sound_mix  ),
        .A          (            ),
        .B          (            ),
        .C          (            ),
        .sample     ( sample_stb ),
        .IOA_in     (            ),
        .IOA_out    (            ),
        .IOB_in     (            ),
        .IOB_out    (            )

    );

    // *******************************************************************************
    // Instantiate PSG DC filter and audio filter
    // *******************************************************************************
    jt49_dcrm2 #(

        .sw    ( DAC_BITS+2 )

    ) PSG_DCFILT (

        .clk   ( clk        ),
        .cen   ( sample_stb ),
        .rst   ( ~reset     ),
        .din   ( sound_mix  ),
        .dout  ( sound_dcf  )

    );

    jt49_mave #(

        .dw    ( DAC_BITS+2     ),
        .depth ( LPFILTER_DEPTH )

    ) PSG_LPF (

        .clk   ( clk            ),
        .cen   ( sample_stb     ),
        .rst   ( ~reset         ),
        .din   ( sound_dcf      ),
        .dout  ( sound          )
        
    );

    // *******************************************************************************
    // Instantiate I2S transmitter for HDMI / DAC
    // *******************************************************************************
    I2S_transmitter #(

        .BITS           ( DAC_BITS+2 ),
        .INV_BCLK       (          0 )

    ) I2S_TX (

        .clk_in         ( clk        ), // High speed clock
        .clk_i2s        ( i2s_3072k  ), // 50/50 duty cycle serial audio clock
        .clk_i2s_pulse  ( i2s_stb    ), // Strobe for 1 clk_in cycle at the beginning of each clk_i2s
        .sample_in      ( 1'b0       ), // Optional input to reset the sample position.  This should either be tied to GND or only pulse once every 64 'clk_i2s_pulse's
        .DAC_Left       ( sound      ), // Left channel digital audio sampled once every 'sample_pulse' output
        .DAC_Right      ( sound      ), // Right channel digital audio sampled once every 'sample_pulse' output

        .sample_pulse   (            ), // Pulses once when a new stereo sample is taken from the DAC_Left/Right inputs.
        .I2S_BCLK       ( i2s_sclk   ), // I2S serial bit clock output (SCLK), basically the clk_i2s input in the correct phase
        .I2S_WCLK       ( i2s_lrclk  ), // I2S !left / right output (LRCLK)
        .I2S_DATA       ( i2s_data   )  // Serial data output    

    );

endmodule
