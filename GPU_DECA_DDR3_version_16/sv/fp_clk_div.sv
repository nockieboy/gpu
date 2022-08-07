//
// Floating-point clock divider
//
// By BrianHG - https://www.eevblog.com/forum/fpga/fpga-vga-controller-for-8-bit-computer/3425
//

module fp_clk_div (

);

// Forcing 64 bits is required due to a ModelSim internal bug where if 'PLL1_OUT_TRUE_HZ*4096' exceedes 31 bits,
// it's considered negative and cropped when computing the localparam.  So, never use 'localparam int' when going
// above 2 billion anywhere inside, or you will get bogus results.
localparam bit [63:0] aud_per_x4096  = PLL1_OUT_TRUE_HZ*4096/HDPLL_AUDIO_HZ ;                               // Determine the audio period 4096 fold.
localparam bit [63:0] aud_per_round  = aud_per_x4096 + 2048 ;                                               // Prepare a rounded version.
localparam bit [12:0] aud_per_int    = HDPLL_AUDIO_TCK_FLOAT ? aud_per_x4096[24:12] : aud_per_round[24:12]; // Select between the rounded integer period or true integer period.
localparam bit [11:0] aud_per_f      = HDPLL_AUDIO_TCK_FLOAT ? aud_per_x4096[11:0]  : 12'd0  ;              // select between no floating point and floating point adjusted audio clock generation.
localparam bit [63:0] aud_tru_hz     = PLL1_OUT_TRUE_HZ*4096 / (aud_per_int*4096+aud_per_f)  ;              // Calculate the true audio output clock based on oscilator frequencies & HDPLL_AUDIO_TCK_FLOAT settings.

assign clk_audio_true_hz = 32'( aud_tru_hz )       ; // pass the true audio sample frequency to an output port.
assign clk_true_hz       = 32'( PLL1_OUT_TRUE_HZ ) ; // pass the true pixel clock frequency to an output port.

logic [12:0]  aud_cnt_m  = 13'd0 ;
logic [12:0]  aud_cnt_n  = 13'd0 ;

always_ff @(posedge clk) begin

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
