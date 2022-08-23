///////////////////////////////////////////////////////////////////////////////
// File downloaded from http://www.nandland.com
///////////////////////////////////////////////////////////////////////////////
// Description: 
// A LFSR or Linear Feedback Shift Register is a quick and easy way to generate
// pseudo-random data inside of an FPGA.  The LFSR can be used for things like
// counters, test patterns, scrambling of data, and others.  This module
// creates an LFSR whose width gets set by a parameter.  The o_LFSR_Done will
// pulse once all combinations of the LFSR are complete.  The number of clock
// cycles that it takes o_LFSR_Done to pulse is equal to 2^g_Num_Bits-1.  For
// example setting g_Num_Bits to 5 means that o_LFSR_Done will pulse every
// 2^5-1 = 31 clock cycles.  o_LFSR_Data will change on each clock cycle that
// the module is enabled, which can be used if desired.
//
// Parameters:
// NUM_BITS - Set to the integer number of bits wide to create your LFSR.
///////////////////////////////////////////////////////////////////////////////
module LFSR #(

    parameter NUM_BITS

)(

    input                 i_Clk,
    input                 i_Enable,
    input                 i_Seed_DV,   // Optional Seed Value
    input  [NUM_BITS-1:0] i_Seed_Data,
    output [NUM_BITS-1:0] o_LFSR_Data,
    output                o_LFSR_Done

);

reg [NUM_BITS:1] r_LFSR = 0;
reg              r_XNOR;

// Purpose: Load up LFSR with Seed if Data Valid (DV) pulse is detected.
// Othewise just run LFSR when enabled.
always_ff @(posedge i_Clk) begin
    if (i_Enable == 1'b1) begin
        if (i_Seed_DV == 1'b1) r_LFSR <= i_Seed_Data                    ;
        else                   r_LFSR <= {r_LFSR[NUM_BITS-1:1], r_XNOR} ;
    end
end

// Create Feedback Polynomials.  Based on Application Note:
// http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
always_comb begin
    case (NUM_BITS)
        3:  r_XNOR = r_LFSR[ 3] ^~ r_LFSR[ 2]                             ;
        4:  r_XNOR = r_LFSR[ 4] ^~ r_LFSR[ 3]                             ;
        5:  r_XNOR = r_LFSR[ 5] ^~ r_LFSR[ 3]                             ;
        6:  r_XNOR = r_LFSR[ 6] ^~ r_LFSR[ 5]                             ;
        7:  r_XNOR = r_LFSR[ 7] ^~ r_LFSR[ 6]                             ;
        8:  r_XNOR = r_LFSR[ 8] ^~ r_LFSR[ 6] ^~ r_LFSR[ 5] ^~ r_LFSR[ 4] ;
        9:  r_XNOR = r_LFSR[ 9] ^~ r_LFSR[ 5]                             ;
        10: r_XNOR = r_LFSR[10] ^~ r_LFSR[ 7]                             ;
        11: r_XNOR = r_LFSR[11] ^~ r_LFSR[ 9]                             ;
        12: r_XNOR = r_LFSR[12] ^~ r_LFSR[ 6] ^~ r_LFSR[ 4] ^~ r_LFSR[ 1] ;
        13: r_XNOR = r_LFSR[13] ^~ r_LFSR[ 4] ^~ r_LFSR[ 3] ^~ r_LFSR[ 1] ;
        14: r_XNOR = r_LFSR[14] ^~ r_LFSR[ 5] ^~ r_LFSR[ 3] ^~ r_LFSR[ 1] ;
        15: r_XNOR = r_LFSR[15] ^~ r_LFSR[14]                             ;
        16: r_XNOR = r_LFSR[16] ^~ r_LFSR[15] ^~ r_LFSR[13] ^~ r_LFSR[ 4] ;
        17: r_XNOR = r_LFSR[17] ^~ r_LFSR[14]                             ;
        18: r_XNOR = r_LFSR[18] ^~ r_LFSR[11]                             ;
        19: r_XNOR = r_LFSR[19] ^~ r_LFSR[ 6] ^~ r_LFSR[ 2] ^~ r_LFSR[ 1] ;
        20: r_XNOR = r_LFSR[20] ^~ r_LFSR[17]                             ;
        21: r_XNOR = r_LFSR[21] ^~ r_LFSR[19]                             ;
        22: r_XNOR = r_LFSR[22] ^~ r_LFSR[21]                             ;
        23: r_XNOR = r_LFSR[23] ^~ r_LFSR[18]                             ;
        24: r_XNOR = r_LFSR[24] ^~ r_LFSR[23] ^~ r_LFSR[22] ^~ r_LFSR[17] ;
        25: r_XNOR = r_LFSR[25] ^~ r_LFSR[22]                             ;
        26: r_XNOR = r_LFSR[26] ^~ r_LFSR[ 6] ^~ r_LFSR[ 2] ^~ r_LFSR[ 1] ;
        27: r_XNOR = r_LFSR[27] ^~ r_LFSR[ 5] ^~ r_LFSR[ 2] ^~ r_LFSR[ 1] ;
        28: r_XNOR = r_LFSR[28] ^~ r_LFSR[25]                             ;
        29: r_XNOR = r_LFSR[29] ^~ r_LFSR[27]                             ;
        30: r_XNOR = r_LFSR[30] ^~ r_LFSR[ 6] ^~ r_LFSR[ 4] ^~ r_LFSR[1 ] ;
        31: r_XNOR = r_LFSR[31] ^~ r_LFSR[28]                             ;
        32: r_XNOR = r_LFSR[32] ^~ r_LFSR[22] ^~ r_LFSR[ 2] ^~ r_LFSR[ 1] ;
    endcase // case (NUM_BITS)
end // always @ (*)

assign o_LFSR_Data =  r_LFSR[NUM_BITS:1]                               ;
assign o_LFSR_Done = (r_LFSR[NUM_BITS:1] == i_Seed_Data) ? 1'b1 : 1'b0 ;
 
endmodule // LFSR
