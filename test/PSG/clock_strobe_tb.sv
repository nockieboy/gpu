`timescale 1 ns/1 ns

localparam  CLK_MHZ    = 100          ; // Frequency of simulated clock
localparam  CLK_PERIOD = 1000/CLK_MHZ ; // Period of simulated clock.
localparam  ENDTIME    = 1000 * 1000  ; // Number of ns to stop simulation at.

module clock_strobe_tb ();

    // Test parameters
    parameter DIVISOR = 28'd56 ; // clock divisor value

    // Signal declarations
    reg [23:0] f_count = 0 ;
    reg        clk     = 0 ;
    wire       p_div       ;
    wire       p_stb       ;

    // Instantiate DUT
    clock_strobe #(

        .DIVISOR ( DIVISOR )

    ) DUT (

        .clk_i   ( clk     ), // source clock for strobe (divided by DIVISOR if >1)
        .clk_o   ( p_div   ), // divided clock 50:50 duty cycle output
        .strb_o  ( p_stb   )  // divided clock strobe output

    );
    
    initial begin

        clk     = 1'b0  ;
        f_count = 24'b0 ;

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
