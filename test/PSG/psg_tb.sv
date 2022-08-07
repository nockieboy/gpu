`timescale 1 ns/1 ns

localparam  CLK_MHZ    = 100          ; // Frequency of simulated clock
localparam  CLK_PERIOD = 1000/CLK_MHZ ; // Period of simulated clock.
localparam  CMD_COUNT  = 10           ; // Number of commands to send to PSG.
localparam  ENDTIME    = 1000 * 1000  ; // Number of ns to stop simulation at.

module psg_tb ();

    // Test parameters
    parameter DIVISOR  = 28'd56  ; // clock divisor value
    parameter CMD_CLKS = DIVISOR ; // numbers of clk per command.

    // PSG command sequencer
    reg        bc   [0:CMD_COUNT-1] = '{  0,  1,  0,  1,  0,  1,  0,  1,  0,  0 } ;
    reg        bdir [0:CMD_COUNT-1] = '{  0,  1,  1,  1,  1,  1,  1,  1,  1,  0 } ;
    reg [ 7:0] data [0:CMD_COUNT-1] = '{  0,  0, 37,  1,  1,  8, 14,  7,  7,  0 } ;

    // Signal declarations
    reg        clk        = 0 ;
    reg [23:0] f_count    = 0 ;
    wire       p_div          ;
    wire       p_stb          ;
    reg        reset      = 0 ;
    
    logic [ 3:0] step     = 0 ; // instruction step

    // Instantiate DUT
    clock_strobe #(

        .DIVISOR ( DIVISOR )

    ) DUT (

        .clk_i   ( clk     ), // source clock for strobe (divided by DIVISOR if >1)
        .clk_o   ( p_div   ), // divided clock 50:50 duty cycle output
        .strb_o  ( p_stb   )  // divided clock strobe output

    );

    // Instantiate PSG
    ym2149_audio #(

    ) PSG (

        .clk_i        ( clk   ),
        .en_clk_psg_i ( p_stb ),
        .sel_n_i      ( 1'b1  ),
        .reset_n_i    ( reset ),
        .bc_i         ( bc[step]   ),
        .bdir_i       ( bdir[step] ),
        .data_i       ( data[step] ),
        .data_r_o     (  ),
        .ch_a_o       (  ),
        .ch_b_o       (  ),
        .ch_c_o       (  ),
        .mix_audio_o  (  ),
        .pcm14s_o     (  )

    );
    
    initial begin

        clk     = 1'b0  ;
        f_count = 24'b0 ;
        step    = 3'b0  ;

        //#(CLK_PERIOD*5) reset = 1'b1 ; // release reset after 5 clocks

        #(CLK_PERIOD*CMD_CLKS)  // Wait for CMD_CLKS oscillations of the system clk period before releasing reset

        reset   = 1'b1  ;       // release reset.

        #(CLK_PERIOD*CMD_CLKS)  // Wait for CMD_CLKS oscillations of the system clk period before sending commands.

        // Count the command counter until the end, waiting a CMD_CLKS between each command step.
        for (step = 0; step < (CMD_COUNT - 1); step++ ) #(CLK_PERIOD*CMD_CLKS) ;

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
