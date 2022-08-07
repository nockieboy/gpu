module fp_div (

    input  clk_in,
    output logic clk_out,
    output logic strobe_out

);

parameter INPUT_CLK_HZ = 100000000 ;
parameter OUTPUT_CLK_HZ = 3579545  ;
parameter USE_FLOATING_DIVIDE = 1  ;

// Forcing 64 bits is required due to a ModelSim internal bug where if 'PLL1_OUT_TRUE_HZ*4096' exceedes 31 bits, it's considered negative and cropped
// when computing the localparam.  So, never use 'localparam int' when going above 2 billion anywhere inside, or you will get bogus results.
localparam bit [63:0] aud_per_x65k  = INPUT_CLK_HZ*65536/OUTPUT_CLK_HZ ; // Determine the audio period 4096 fold.
localparam bit [63:0] aud_per_round = aud_per_x65k + 32768             ; // Prepare a rounded version.
localparam bit [12:0] aud_per_int   = USE_FLOATING_DIVIDE ? aud_per_x65k[28:16] : aud_per_round[28:16] ; // Select between the rounded integer period or true integer period.
localparam bit [15:0] aud_per_f     = USE_FLOATING_DIVIDE ? aud_per_x65k[15:0]  : 16'd0                ; // select between no floating point and floating point adjusted audio clock generation.
localparam bit [63:0] aud_tru_hz    = INPUT_CLK_HZ*65536 / (aud_per_int*65536+aud_per_f)               ; // Calculate the true audio output clock based on oscillator frequencies & USE_FLOATING_DIVIDE settings.

logic [12:0] aud_cnt_m = 13'd0 ;
logic [16:0] aud_cnt_n = 17'd0 ;

always_ff @(posedge clk_in) begin

    if ( aud_cnt_m == (aud_per_int - !aud_cnt_n[16]) ) begin // Add 1 extra count to the period if the carry flag aud_cnt_n[12] is set.

        aud_cnt_m  <= 13'd0 ;
        strobe_out <= 1'b1  ;
        clk_out    <= 1'b1  ;
        aud_cnt_n  <= aud_cnt_n[15:0] + (aud_per_f) ; // add the floating point period while clearing the carry flag aud_cnt_n[12].

    end else begin

        aud_cnt_m  <= aud_cnt_m + 1'b1 ;
        strobe_out <= 1'b0 ;
        if (aud_cnt_m[11:0]==aud_per_int[12:1]) clk_out <= 1'b0 ; // generate an aproximate 50/50 duty cycle clk_out output.

    end

end

endmodule
