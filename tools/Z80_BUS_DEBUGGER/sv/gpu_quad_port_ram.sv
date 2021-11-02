module gpu_quad_port_ram (
	// inputs
	input        clk,
	input        clk_2x,
	input        clk_2x_phase,
	input [3:0]  wren,
	input [19:0] addr[3:0],
	input [15:0] data_in[3:0],
	input  [3:0] mode_8bit,      // When writing in 8 bit mode, the high and low byte of the 'data_in' need to be wired together.
	// direct outputs
	output wire [15:0] data_out[3:0],
	output reg  [19:0] addr_out[3:0],
	
	input       [31:0] cmd_in[3:0],
	output reg  [31:0] cmd_out[3:0] );

// define the maximum address bit
parameter ADDR_SIZE = 14 ;              // Even though the memory is 16 bit, the addr size and num_words as accessed as if they are 8 bit.
parameter NUM_WORDS = 2 ** ADDR_SIZE ;
parameter MIF_FILE  = "gpu_8Kx16_VGA.mif" ;

wire   d_wren_a, d_wren_b;
assign d_wren_a = clkr ? wren[1] : wren[0] ;
assign d_wren_b = clkr ? wren[3] : wren[2] ;

wire   [19:0]  d_addr_a, d_addr_b;
assign d_addr_a = clkr ? addr[1] : addr[0] ;
assign d_addr_b = clkr ? addr[3] : addr[2] ;

wire   [15:0] d_data_in_a, d_data_in_b, d_data_out_a, d_data_out_b ;
assign d_data_in_a = clkr ? data_in[1] : data_in[0] ;
assign d_data_in_b = clkr ? data_in[3] : data_in[2] ;

wire   [1:0]  byte_ena[3:0] ;
wire   [1:0]  d_byte_ena_a, d_byte_ena_b ;

assign d_byte_ena_a = clkr ? byte_ena[1] : byte_ena[0] ;
assign d_byte_ena_b = clkr ? byte_ena[3] : byte_ena[2] ;

reg    [15:0]  dly_a_out, dly_b_out;
reg    [15:0]  reg_data_out[3:0];
reg    [31:0]  dly_cmd_out[3:0];
reg    [31:0]  dly_addr_out[3:0];

reg            clkr;
//assign       clkr = clk_2x_phase;

integer i;
always begin
	for (i=0 ; i<4 ; i=i+1) begin // generate the 'pseudo' byte write mode by generating the wires byte_ena[3:0][1:0].
		byte_ena[i][0]     = (wren[i] && ~addr[i][0]) || ~mode_8bit[i];
		byte_ena[i][1]     = (wren[i] &&  addr[i][0]) || ~mode_8bit[i];
								// generate the 'pseudo' byte read mode by swapping the high and low read byte according to read address[0].
		data_out[i][7:0]	= (addr_out[i][0] == 1'b0) ? reg_data_out[i][7:0]  : reg_data_out[i][15:8];
		data_out[i][15:8]	= (addr_out[i][0] == 1'b0) ? reg_data_out[i][15:8] : reg_data_out[i][7:0];
	end
end // always


// ****************************************************************************************************************************
// Call Dual-port GPU RAM
// 2 read write ports, at 16 bits, with 'BYTE' enable so that 8 bit of a 16 bit word may be written at 1 time.
// ****************************************************************************************************************************
gpu_dual_port_ram_INTEL  dual_port (

	.clk(clk_2x),
	.wren_a(d_wren_a),
	.wren_b(d_wren_b),
	.addr_a(d_addr_a),
	.addr_b(d_addr_b),
	.data_in_a(d_data_in_a),
	.data_in_b(d_data_in_b),
	.byteena_a(d_byte_ena_a),
	.byteena_b(d_byte_ena_b),

	.data_out_a(d_data_out_a),
	.data_out_b(d_data_out_b) );
defparam
	dual_port.ADDR_SIZE = ADDR_SIZE,
	dual_port.NUM_WORDS = NUM_WORDS,
	dual_port.MIF_FILE  = MIF_FILE ;

// ****************************************************************************************************************************

always @(posedge clk_2x) begin
	clkr      <= clk_2x_phase;         // highest possible FMAX.
	dly_a_out <= d_data_out_a;
	dly_b_out <= d_data_out_b;
	end

always @(posedge clk) begin
	reg_data_out[0] <= dly_a_out;     // swap the delay and non-delay phase based on the 'clkr' 0-1 input mux swap.
	reg_data_out[1] <= d_data_out_a;
	reg_data_out[2] <= dly_b_out;     // swap the delay and non-delay phase based on the 'clkr' 2-3 input mux swap.
	reg_data_out[3] <= d_data_out_b;
	
	dly_addr_out    <= addr;
	addr_out        <= dly_addr_out; // pipe through the address input so that the output address comes in paralel with the read ram data
	
	dly_cmd_out     <= cmd_in;
	cmd_out         <= dly_cmd_out; // pipe through the cmd input so that the output cmd is in paralel with the read ram data
	end // @posedge clk

endmodule
