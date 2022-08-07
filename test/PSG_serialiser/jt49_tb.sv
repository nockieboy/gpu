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

    YM2149_PSG_system #(

        .CLK_IN_HZ      (  CLK_IN_HZ ), // Calculated input clock frequency
        .CLK_PSG_HZ     (    1789000 ), // Desired PSG clock frequency (Hz)
        .I2S_DAC_HZ     (      48000 ), // Desired I2S clock frequency (Hz)
        .DAC_BITS       (         10 ), // PSG DAC bit precision
        .VOL_ATT_DB     (        -48 ), // Decibel volume at 1 of 31. **Maximum** -48 for 8 bit dac, -60 for 10 bit dac,
                                        // -72 for 12 bit dac.
                                        // Best is -48 with 10bit dac, or -36 with 8 bit dac.
        .LPFILTER_DEPTH (          4 )  // 2=flat to 10khz, 4=flat to 5khz, 6=getting muffled, 8=no treble.

    ) PSG_system (

        .clk            (        clk ),
        .reset          (      reset ),
        .addr           ( addr[step] ), // register address
        .data           ( data[step] ), // data IN to PSG
        .wr_n           (       wr_n ), // data/addr valid

        .dout           (       dout ), // PSG data output
        .i2s_sclk       (  HDMI_SCLK ), // I2S serial bit clock output
        .i2s_lrclk      ( HDMI_LRCLK ), // I2S L/R output
        .i2s_data       (   i2s_data ), // I2S serial audio out
        .sound          (  sound_mix )  // parallel   audio out

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
