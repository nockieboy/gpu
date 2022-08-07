/*  

This source code was written to replace jt49_exp.v which was part of the JT49 YM2149 PSG.

BHG_jt49_exp.v v1.0, Aug 6, 2022 by Brian Guralnick.

This code is free to use.  Just be fair and give credit where it is due.

******************************************************************
*** This code was written by BrianHG providing an optional     ***
*** volume decibel attenuation, or decibel volumetric power    ***
*** with optional DAC bit width parameter output.              ***
***                                                            ***
******************************************************************

*/


module BHG_jt49_exp #(

parameter       DAC_BITS   = 8        // The number of DAC bits for each channel of the YM2149 PSG.  Supports 8 thru 14.

)(
    input                     clk,
    input      [1:0]          comp,  // *** NO LONGER USED
    input      [4:0]          din,
    output reg [DAC_BITS-1:0] dout = 0
);

`include "BHG_jt49_exp_lut.vh"
localparam int dlut[0:31] = dlut_sel[DAC_BITS];

generate
initial begin
$warning("********************************************");
$warning("*** BrianHG's BHG_jt49_exp.v dlut table. ***");
$warning("*********************************************************************");
$warning("*** dlut[0:31]='{%d,%d,%d,%d,%d,%d,%d,%d, ***",16'(dlut[ 0]),16'(dlut[ 1]),16'(dlut[ 2]),16'(dlut[ 3]),16'(dlut[ 4]),16'(dlut[ 5]),16'(dlut[ 6]),16'(dlut[ 7]));
$warning("***              %d,%d,%d,%d,%d,%d,%d,%d, ***",16'(dlut[ 8]),16'(dlut[ 9]),16'(dlut[10]),16'(dlut[11]),16'(dlut[12]),16'(dlut[13]),16'(dlut[14]),16'(dlut[15]));
$warning("***              %d,%d,%d,%d,%d,%d,%d,%d, ***",16'(dlut[16]),16'(dlut[17]),16'(dlut[18]),16'(dlut[19]),16'(dlut[20]),16'(dlut[21]),16'(dlut[22]),16'(dlut[23]));
$warning("***              %d,%d,%d,%d,%d,%d,%d,%d} ***",16'(dlut[24]),16'(dlut[25]),16'(dlut[26]),16'(dlut[27]),16'(dlut[28]),16'(dlut[29]),16'(dlut[30]),16'(dlut[31]));
$warning("*********************************************************************");

end
endgenerate

// Clock the look-up table.
always @(posedge clk) dout <= (DAC_BITS)'( dlut[din] );

endmodule
