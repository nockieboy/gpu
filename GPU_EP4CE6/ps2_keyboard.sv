`resetall
`timescale 1ns/100ps

module ps2_keyboard (
  reset,
  sys_clk_0,
  ps2_clk,
  ps2_data,
  ps2_char,
  ps2_char_rdy
);
  
// I/O declarations
input sys_clk_0;      // 50 MHz
input reset;

input ps2_clk;
input ps2_data;

output [7:0] ps2_char;
output ps2_char_rdy;

// Internal signal declarations
wire [7:0] ps2_scan_code;
wire [7:0] ps2_ascii;
wire [7:0] ps2_status;

wire ps2_key_released;
wire ps2_key_pressed = ~ps2_key_released;

//--------------------------------------------------------------------------
// Instantiations
//--------------------------------------------------------------------------

ps2_keyboard_interface #(2950, // number of clks for 60usec.
                         12,   // number of bits needed for 60usec. timer
                         63,   // number of clks for debounce
                         6,    // number of bits needed for debounce timer
                         1     // Trap the shift keys, no event generated
                         )                       
  ps2_block (                  // Instance name
  .clk(sys_clk_0),
  .reset(reset),
  .ps2_clk(ps2_clk),
  .ps2_data(ps2_data),
  .rx_extended(ps2_status[5]),
  .rx_released(ps2_key_released),
  .rx_shift_key_on(ps2_status[7]),
  .rx_scan_code(ps2_scan_code),
  .rx_ascii(ps2_char),
  .rx_data_ready(ps2_char_rdy),
  .rx_read(ps2_char_rdy)
  );
assign ps2_status[6] = ps2_key_released;
assign ps2_status[3] = 1'b0;

//--------------------------------------------------------------------------
// Module code
//--------------------------------------------------------------------------

assign ps2_status[2:0] = 0;

endmodule

