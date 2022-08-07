/*  This file is part of JT49.

******************************************************************
*** Modified by BrianHG providing a volumetric attenuation db, ***
*** and variable/higher resolution DAC. **************************
******************************************************************

    JT49 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT49 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT49.  If not, see <http://www.gnu.org/licenses/>.
    
    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 10-Nov-2018
    
    Based on sqmusic, by the same author
    
    */


// Compression vs dynamic range
// 0 -> 43.6dB
// 1 -> 29.1
// 2 -> 21.8
// 3 -> 13.4

module BHG_jt49_exp #(

parameter       DAC_BITS   = 8,        // The number of DAC bits defining the precision.
parameter  real VOL_ATT_DB = -36       // The decibel volume at 1 of 31.  **Maximum** -48 for 8 bit dac, -60 for 10 bit dac, -72 for 12 bit dac.
                                       // Best is -48 with 10bit dac, or -36 with 8 bit dac.

)(
    input                     clk,
    input      [1:0]          comp,  // *** NO LONGER USED
    input      [4:0]          din,
    output reg [DAC_BITS-1:0] dout = 0
);

localparam real VOL_factor = VOL_ATT_DB/31 ; // factor the decibel range over the 5bit volume range.

reg [DAC_BITS-1:0] lut[0:31];

always @(posedge clk)
    dout <= lut[ din ];

initial begin

                           lut[0] = (DAC_BITS)'(0) ;                                               // Make volume 0 = - infinity db, or mute.
                           lut[1] = (DAC_BITS)'(10**(((31-2)*VOL_factor)/20) *(2**DAC_BITS-1)/2) ; // Generate a soft linear initial volume step.                                             // Make volume 0 = - infinity db, or mute.
for (int i=2; i<=31 ; i++) lut[i] = (DAC_BITS)'(10**(((31-i)*VOL_factor)/20) *(2**DAC_BITS-1))   ; // Calculate db into a DAC integer level.

end
endmodule
