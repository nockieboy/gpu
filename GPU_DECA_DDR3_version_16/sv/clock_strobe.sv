// clock_strobe v1.0 - nockieboy, 2022.
//
// Produces a strobe triggered by the rising edge
// of clk_i, after it has been divided by DIVISOR.
// Its pulse width that of the undivided clk_i.
//
// This module was specifically written to produce
// the PSG clock enable strobe required by the
// YM2149 audio module.

module clock_strobe (

    // inputs
    input  logic clk_i,  // input clock to divide
    // outputs
    output logic clk_o,  // divided clock output
    output logic strb_o  // output strobe after dividing the input clock by divisor

);

parameter    DIVISOR = 28'd2 ; // clock divisor value

logic [27:0] counter = 28'd0 ;
logic        clk_p           ; // edge-detect for clk_o

always_ff @( posedge clk_i ) begin

    // increment counter or reset to zero at count
    counter <= counter + 28'd1 ;
    if ( counter >= ( DIVISOR - 1 ) ) counter <= 28'd0 ;
    // divide clock
    clk_o <= ( counter < DIVISOR / 2 ) ? 1'b1 : 1'b0   ;
    clk_p <= clk_o ; // update edge-detect

end

always_comb begin

    // generate strobe
    if   ( clk_o && !clk_p ) strb_o = 1'b1 ; // start pulse on rising edge of divided clock
    else                     strb_o = 1'b0 ; // end pulse on next rising edge of undivided clock

end

endmodule
