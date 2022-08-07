`timescale 1 ns/1 ns

localparam  CLK_MHZ    = 100          ; // Frequency of simulated clock
localparam  CLK_PERIOD = 1000/CLK_MHZ ; // Period of simulated clock.
localparam  CMD_COUNT  = 8            ; // Number of commands to send to PSG.
localparam  ENDTIME    = 1000 * 1000 * 2 ; // Number of ns to stop simulation at.

module jt49_tb ();

    // Test parameters
    parameter       DIVISOR  = 28'd2 ; // ****** temporarily using 2 for fast simulation // 28'd56    ; // clock divisor value
    parameter [1:0] COMP     = 2'b00     ;

    // PSG command sequencer
    integer    step = 0 ; // instruction step
    reg [ 3:0] addr [0:CMD_COUNT-1] = '{   11,  12,   0,   1,     8,   6,  13,   7 } ;
    reg [ 7:0] data [0:CMD_COUNT-1] = '{  120,   0,  40,   0, 32+16,   1,  14,   8 } ;

    // Signal declarations
    reg                clk     = 0 ;
    reg         [23:0] f_count = 0 ;
    wire               p_div       ;
    wire               p_stb       ;
    reg                reset   = 0 ;
    reg                wr_n    = 1 ;

    wire        [ 9:0] sound_mix   ;
    wire signed [ 9:0] sound       ;
    reg         [ 7:0] dout        ;

    // Instantiate DUT
    fp_div DUT (

        .clk_in     ( clk   ), // source clock for strobe (divided by DIVISOR if >1)
        .clk_out    ( p_div ), // divided clock 50:50 duty cycle output
        .strobe_out ( p_stb )  // divided clock strobe output

    );

    // Instantiate PSG
    jt49 #(

        .COMP     ( COMP       )

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
        .sample   (            ),
        .IOA_in   (            ),
        .IOA_out  (            ),
        .IOB_in   (            ),
        .IOB_out  (            )

    );

    jt49_dcrm2 #(

        .sw    (  10          )

    ) PSG_DCFILT (

        .clk   (  clk         ),
        .cen   (  p_stb       ),
        .rst   (  ~reset      ),
        .din   (  sound_mix   ),
        .dout  (  sound       )
    );

    I2S_transmitter #(

        .BITS     ( 16 ),
        .INV_BCLK (  0 )

    ) I2S_TX (

        .clk_in         ( clk      ), // High speed clock
        .clk_i2s        ( p_div    ), // 50/50 duty cycle serial audio clock
        .clk_i2s_pulse  ( p_stb    ), // Strobe for 1 clk_in cycle at the beginning of each clk_i2s
        .sample_in      ( ~reset   ), // Optional input to reset the sample position.  This should either be tied to GND or only pulse once every 64 'clk_i2s_pulse's
        .DAC_Left       ( 16'hAAAA ), // Left channel digital audio sampled once every 'sample_pulse' output
        .DAC_Right      ( 16'h5555 ), // Right channel digital audio sampled once every 'sample_pulse' output

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

        #(CLK_PERIOD*2)  // Wait for 1 clock

        reset   = 1'b1  ;       // release reset.

        #(CLK_PERIOD*2)  // Wait for 1 system clk period before sending commands.



        // Count the command counter until the end, waiting a system clock between each command step.
        wr_n    = 1'b0 ; // Write enable
        for (step = 0; step < (CMD_COUNT - 1); step++ ) #(CLK_PERIOD) ; // send a new command every system clock.

        #(CLK_PERIOD) ; // need 1 additional system clock before turning off the write enable to latch the last command.
        wr_n    = 1'b1 ; // Write disable

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
