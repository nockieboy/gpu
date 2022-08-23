`timescale 1 ns/1 ns

localparam bit QUICK_SIM  = 0                                    ; // When running long simulations, turning this on will multiply the sim speed.
localparam     CLK_PSG_HZ = 1789000                              ; // PSG of simulated clock
localparam     CLK_I2S_HZ = 3072000                              ; // I2S bit clock rate of simulated clock
localparam     CLK_IN_HZ  = QUICK_SIM ? CLK_PSG_HZ*4 : 100000000 ; // Select operating frequency of simulation.
localparam     CLK_PERIOD = 1000000000/CLK_IN_HZ                 ; // Period of simulated clock.
localparam     ENDTIME    = (1000 * 1000 * 50) + 20              ; // Number of ns to stop simulation at.

module jt49_tb ();

    // Test parameters
    parameter      DAC_BITS       = 10  ; // The number of DAC bits defining the precision.
    parameter real VOL_ATT_DB     = -48 ; // The decibel volume at 1 of 31.  **Maximum** -48 for 8 bit dac, -60 for 10 bit dac, -72 for 12 bit dac.
                                          // Best is -48 with 10bit dac, or -36 with 8 bit dac.
    parameter      LPFILTER_DEPTH = 4   ; // 2=flat to 10khz, 4=flat to 5khz, 6=getting muffled, 8=no treble.

    // PSG command sequencer
    integer    step                 = 0   ; // instruction step position.
    localparam CMD_COUNT            = 14  ; // Number of commands to send to PSG.
    reg [ 3:0] addr [0:CMD_COUNT-1] = '{  0,  1,  2,  3,  4,  5,  6,           7,  8,  9, 10, 11, 12, 13 } ;
    reg [ 7:0] data [0:CMD_COUNT-1] = '{ 94,  4, 11,  0,  0,  3,  5, 8'b00101010, 15, 15, 15,125,  0, 14 } ;
    // Signal declarations
    reg                        clk     = 0 ;
    reg         [23:0]         f_count = 0 ;
    wire                       p_div       ;
    wire                       p_stb       ;
    wire                       s_div       ;
    wire                       s_stb       ;
    reg                        reset   = 0 ;
    reg                        wr_n    = 1 ;
    wire        [DAC_BITS+1:0] sound_mix   ;
    wire signed [DAC_BITS+1:0] sound_dcf   ;
    wire signed [DAC_BITS+1:0] sound       ;
    reg         [ 7:0]         dout        ;

    // Instantiate fp_div for PSG
    fp_div #(
   
        .INPUT_CLK_HZ  (CLK_IN_HZ ),
        .OUTPUT_CLK_HZ (CLK_PSG_HZ)
   
    ) DUT (

        .clk_in     ( clk   ), // source clock for strobe (divided by DIVISOR if >1)
        .clk_out    ( p_div ), // divided clock 50:50 duty cycle output
        .strobe_out ( p_stb )  // divided clock strobe output

    );

    // Instantiate second fp_div for I2S signal
    fp_div #(
   
        .INPUT_CLK_HZ  (CLK_IN_HZ ),
        .OUTPUT_CLK_HZ (CLK_I2S_HZ)
   
    ) fp_div_i2s (

        .clk_in     ( clk   ), // source clock for strobe (divided by DIVISOR if >1)
        .clk_out    ( s_div ), // divided clock 50:50 duty cycle output
        .strobe_out ( s_stb )  // divided clock strobe output

    );

    wire sample_stb ; // A new strobe for when the sample is ready.

    // Instantiate PSG
    BHG_jt49 #(

        .DAC_BITS   ( DAC_BITS   ), 
        .VOL_ATT_DB ( VOL_ATT_DB )

    ) PSG (

        .rst_n    ( reset      ),
        .clk      ( clk        ),
        .clk_en   ( p_stb      ),
        .addr     ( addr[step] ),
        .cs_n     ( 1'b0       ),
        .wr_n     ( wr_n       ),
        .din      ( data[step] ),
        .sel      ( 1'b1       ),
        .dout     ( dout       ),
        .sound    ( sound_mix  ),
        .A        (            ),
        .B        (            ),
        .C        (            ),
        .sample   ( sample_stb ),
        .IOA_in   (            ),
        .IOA_out  (            ),
        .IOB_in   (            ),
        .IOB_out  (            )

    );

    jt49_dcrm2 #(

        .sw    (  DAC_BITS+2   )

    ) PSG_DCFILT (

        .clk   (  clk         ),
        .cen   (  sample_stb  ),
        .rst   (  ~reset      ),
        .din   (  sound_mix   ),
        .dout  (  sound_dcf   )
    );

    jt49_mave #(

        .dw    (  DAC_BITS+2     ),
        .depth (  LPFILTER_DEPTH )

    ) PSG_LPF (

        .clk   (  clk         ),
        .cen   (  sample_stb  ),
        .rst   (  ~reset      ),
        .din   (  sound_dcf   ),
        .dout  (  sound       )
    );

    I2S_transmitter #(

        .BITS     ( DAC_BITS+2 ),
        .INV_BCLK (  0 )

    ) I2S_TX (

        .clk_in         ( clk    ), // High speed clock
        .clk_i2s        ( s_div  ), // 50/50 duty cycle serial audio clock
        .clk_i2s_pulse  ( s_stb  ), // Strobe for 1 clk_in cycle at the beginning of each clk_i2s
        .sample_in      ( ~reset ), // Optional input to reset the sample position.  This should either be tied to GND or only pulse once every 64 'clk_i2s_pulse's
        .DAC_Left       ( sound  ), //16'hAAAA ), // Left channel digital audio sampled once every 'sample_pulse' output
        .DAC_Right      ( sound  ), //16'h5555 ), // Right channel digital audio sampled once every 'sample_pulse' output

        .sample_pulse   (  ), // Pulses once when a new stereo sample is taken from the DAC_Left/Right inputs.  Hint: once every 64 clk_i2s_pulse's
        .I2S_BCLK       (  ), // I2S serial bit clock output (SCLK), basically the clk_i2s input in the correct phase
        .I2S_WCLK       (  ), // I2S !left / right output (LRCLK)
        .I2S_DATA       (  )  // Serial data output    

    );

    initial begin

        clk     = 1'b0  ;
        f_count = 24'b0 ;
        step    = 0     ;
        wr_n    = 1'b1  ;

        #(CLK_PERIOD*2) ; // Wait for 1 clock

        reset   = 1'b1  ; // release reset.

        #(CLK_PERIOD*2) ; // Wait for 1 system clk period before sending commands.

        // Count the command counter until the end, waiting a system clock between each command step.
        wr_n    = 1'b0  ; // Write enable
        for (step = 0; step < (CMD_COUNT - 1); step++ ) #(CLK_PERIOD) ; // send a new command every system clock.

        #(CLK_PERIOD)   ; // need 1 additional system clock before turning off the write enable to latch the last command.
        wr_n    = 1'b1  ; // Write disable

    end

    // Generate simulated clock
    always begin

		clk = 1'b1 ;
		#(CLK_PERIOD/2) ;     // high for 1*timescale

		clk = 1'b0 ;
		#(CLK_PERIOD/2) ;	  // low for 1*timescale
        
	end

    always #(ENDTIME) $stop ; // Stop simulation from going on forever

    always @(posedge clk) if (p_stb) f_count <= f_count + 1 ;

endmodule
