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

module HDMI_serializer_altlvds #(
    // Set to 0 to activate the external clk_pixel_x5 input.
    // Set to 1 to automatically internally generate a PLL for the TMDS TXD clock.
    // Using 1 will usually use an additional PLL if Quartus cannot merge the required clock with an existing external PLL.
    parameter bit HDMI_SERTX_INTERNAL_PLL = 1'b0,

    // Tells the ALTLVDS_TX serializer what the approximate source pixel clock is.  Only needs to be within 1 MHz.
    // Only used when USE_EXT_PLLx5 is disabled.
    // You may lie here and state your pixel clock is only 740mbps or 640mbps allowing compile for -7/-8 Cyclone FPGAs
    // while still truly running a 74.25MHz pixel clock, 742.5mbps when using either LVDS or emulated LVDS_E_3R IO standard.
    parameter int HDMI_SERTX_PIXEL_MBPS = 270,

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

logic [39:0] tmds_stack_rev;

// Creates the tmds clock channel output.
// Replacing always_ff with always_comb will slightly lower pixel clock FMAX & save 30 registers.
// We are talking 130Mhz to 120Mhz, so nothing important
always_ff @(posedge clk_pixel)  begin
// Flip around the direction of the data bits
     for (int x=0 ; x<=9 ; x++ ) begin
     tmds_stack_rev[30+x]  <= INV_TMDS3 ? !tmds_par_in[3][9-x] : tmds_par_in[3][9-x] ;
     tmds_stack_rev[20+x]  <= INV_TMDS2 ? !tmds_par_in[2][9-x] : tmds_par_in[2][9-x] ;
     tmds_stack_rev[10+x]  <= INV_TMDS1 ? !tmds_par_in[1][9-x] : tmds_par_in[1][9-x] ;
     tmds_stack_rev[00+x]  <= INV_TMDS0 ? !tmds_par_in[0][9-x] : tmds_par_in[0][9-x] ;
     end
end

// call altlvds_tx.
	altlvds_tx	altlvds_tx_component (
				.tx_syncclock  (HDMI_SERTX_INTERNAL_PLL ? 1'b0      : clk_pixel    ), // Select the input clock source when the internal PLL is off.
				.tx_inclock    (HDMI_SERTX_INTERNAL_PLL ? clk_pixel : clk_pixel_x5 ), // Select the output clock source.
				.tx_in         (tmds_stack_rev),
				.tx_out        (tmds_ser_out),
				.pll_areset    (1'b0),
				.sync_inclock  (1'b0),
				.tx_coreclock  (),
				.tx_data_reset (1'b0),
				.tx_enable     (1'b1),
				.tx_locked     (),
				.tx_outclock   (),
				.tx_pll_enable (1'b1));
	defparam
		altlvds_tx_component.common_rx_tx_pll = "OFF",
		altlvds_tx_component.deserialization_factor = 10,
		altlvds_tx_component.implement_in_les = "ON",
		altlvds_tx_component.inclock_data_alignment = "UNUSED",
		altlvds_tx_component.inclock_period = (10000000/HDMI_SERTX_PIXEL_MBPS),
		altlvds_tx_component.inclock_phase_shift = 0,
		altlvds_tx_component.lpm_hint = "CBX_MODULE_PREFIX=TMDS_ser",
		altlvds_tx_component.lpm_type = "altlvds_tx",
		altlvds_tx_component.number_of_channels = 4,
		altlvds_tx_component.output_data_rate = (HDMI_SERTX_PIXEL_MBPS),
		altlvds_tx_component.pll_self_reset_on_loss_lock = "ON",
		altlvds_tx_component.registered_input = "TX_CLKIN",
		altlvds_tx_component.use_external_pll = (HDMI_SERTX_INTERNAL_PLL ? "OFF" : "ON" ); // Select whether to generate the output PLL or use an external bit clock.

endmodule
