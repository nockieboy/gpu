//
// This module takes in a 30 bit parallel TMDS
// pixel stream, swaps bit order and feeds
// Altera's altlvds_tx megafunction in a manner
// to generate 4 lane DVI/HDMI compliant TMDS signal.
//
// Extended features include swapping of the +&- LVDS output
// polarity, enable/disable self generated internal PLL
// for the serial output and a manually set parameter for the
// LVDS speed.
//
// Written by Brian Guralnick.
// Jan 16, 2021.
//

module HDMI_serializer_software #(

    // Invert the TMDS channels, 0 thru 2, and 3 for the clock channel.
    // IE - Swaps the +&- pins of the LVDS output pins for ease of PCB routing.
    parameter bit INV_TMDS0 = 1'b0,
    parameter bit INV_TMDS1 = 1'b0,
    parameter bit INV_TMDS2 = 1'b0,
    parameter bit INV_TMDS3 = 1'b0
)
(
    input  logic        clk_pixel,
    input  logic        clk_pixel_x5,
    input  logic [9:0]  tmds_par_in[3:0],

    output logic [3:0]  tmds_ser_out
);


endmodule
