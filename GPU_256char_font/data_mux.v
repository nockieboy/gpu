// 2-port data_mux
//
// Prioritises Port A for bi-directional data transfer,
// holds requests from Port x for x cycles whilst another
// request is in progress (x cycles = GPU RAM delay).
//
// All requests should take no longer than the specified
// number of cycles to read data from the GPU RAM, but in
// any case be quicker than the reading device attached
// to this mux unit - i.e. the Z80 or RS232 interfaces.

module data_mux (

	// general inputs
	input wire			clk,
	input wire			reset,
	
	// gpu inputs
	input wire [7:0]	gpu_data_in,	// data is valid here once gpu_data_in pulses HIGH
	
	// inputs Port A - Z80
	input wire 			wr_ena_a,
	input wire 			rd_req_a,
	input wire [19:0]	address_a,
	input wire [7:0]	data_in_a,
	
	
	// inputs Port B - RS232
	input wire 			wr_ena_b,
	input wire 			rd_req_b,
	input wire [14:0]	address_b,
	input wire [7:0]	data_in_b,
	
	// gpu outputs
	output reg 			gpu_wr_ena,		// output pulses high for 1 clock when a write request takes place
	output reg [19:0]	gpu_address,
	output reg [7:0]	gpu_data_out,
	
	// outputs Port A
	output wire 		gpu_rd_rdy_a,	// one-CLK HIGH pulse here indicates valid data on data_out_a
	output wire [7:0]	data_out_a,
	
	// outputs Port B
	output wire 		gpu_rd_rdy_b,	// one-CLK HIGH pulse here indicates valid data on data_out_b
	output wire [7:0]	data_out_b

);

parameter DELAY_CYCLES = 2;

reg [9:0] rd_sequencer_a;
reg [9:0] rd_sequencer_b;

reg porta_bsy, portb_bsy;

wire run_r_porta, run_r_portb, run_w_porta, run_w_portb;

assign run_r_porta	= rd_req_a && ~portb_bsy;
assign run_w_porta	= wr_ena_a && ~portb_bsy;
assign run_r_portb	= rd_req_b && ~porta_bsy && ~run_r_porta && ~run_w_porta;
assign run_w_portb	= wr_ena_b && ~porta_bsy && ~run_r_porta && ~run_w_porta;

assign gpu_rd_rdy_b	= rd_sequencer_b[DELAY_CYCLES];
assign gpu_rd_rdy_a	= rd_sequencer_a[DELAY_CYCLES];

assign data_out_a		= gpu_data_in ;
assign data_out_b		= gpu_data_in ;

always @ (posedge clk) begin

	// *** UPDATE GPU_WR_ENA AND FLAGS EACH CLOCK ***
	gpu_wr_ena	<= run_w_porta || run_w_portb;
	porta_bsy	<= run_r_porta || run_w_porta;
	portb_bsy	<= run_r_portb || run_w_portb;

	// *** HANDLE PORT A READ REQUESTS AND SEQUENCER ***
	if (run_r_porta) begin
		rd_sequencer_a[9:0] <= { rd_sequencer_a[8:0], 1'b1 };
		gpu_address		     <= address_a;
	end else begin
		rd_sequencer_a[9:0] <= { rd_sequencer_a[8:0], 1'b0 };	// this line must always run no matter any other state
	end
	
	// *** HANDLE PORT A WRITE REQUESTS ***
	if (run_w_porta) begin
		gpu_address		     <= address_a;
		gpu_data_out        <= data_in_a;
	end
	
	// *** HANDLE PORT B READ REQUESTS AND SEQUENCER ***
	if (run_r_portb) begin
		rd_sequencer_b[9:0] <= { rd_sequencer_b[8:0], 1'b1 };
		gpu_address		     <= address_b;
	end else begin
		rd_sequencer_b[9:0] <= { rd_sequencer_b[8:0], 1'b0 };	// this line must always run no matter any other state
	end
	
	// *** HANDLE PORT B WRITE REQUESTS ***
	if (run_w_portb) begin
		gpu_address		     <= address_b;
		gpu_data_out        <= data_in_b;
	end
	
end

endmodule
