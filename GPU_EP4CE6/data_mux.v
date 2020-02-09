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
   input wire        clk,
   input wire        reset,
   
   // gpu inputs
   input wire [7:0]  gpu_data_in,   // data is valid here once gpu_data_in pulses HIGH
   
   // inputs Port A - Z80
   input wire        wr_ena_a,
   input wire        rd_req_a,
   input wire [19:0] address_a,
   input wire [7:0]  data_in_a,
   
   
   // inputs Port B - RS232
   input wire        wr_ena_b,
   input wire        rd_req_b,
   input wire [19:0] address_b,
   input wire [7:0]  data_in_b,
   
   // gpu outputs
   output reg        gpu_wr_ena,    // output pulses high for 1 clock when a write request takes place
   output reg [19:0] gpu_address,
   output reg [7:0]  gpu_data_out,
   
   // outputs Port A
   output reg        gpu_rd_rdy_a,  // one-CLK HIGH pulse here indicates valid data on data_out_a
   output wire [7:0] data_out_a,
   
   // outputs Port B
   output reg        gpu_rd_rdy_b,  // one-CLK HIGH pulse here indicates valid data on data_out_b
   output wire [7:0] data_out_b

);

parameter  READ_CLOCK_CYCLES = 2 ;

reg    dumb_ab_mux, ab_mux_dl1, ab_mux_dl2, ab_mux_dl3, wena_a_dly, wena_b_dly, rdreq_a_dly,  rdreq_b_dly ;
reg [9:0] rd_req_dlya, rd_req_dlyb ;

assign data_out_a   =  gpu_data_in ;  // with this line, it is the responsibility of the next module to latch the data when the gpu_rd_rdy_a is high
assign data_out_b   =  gpu_data_in ;  // with this line, it is the responsibility of the next module to latch the data when the gpu_rd_rdy_b is high



always @ (posedge clk) begin

	dumb_ab_mux     <= ~dumb_ab_mux; // as dumb as it gets, just switches between A & B once every clock.

	gpu_rd_rdy_a   <= rd_req_dlya[READ_CLOCK_CYCLES-1]; // needs to be high when 2 clock cycles has passed since address_a was sent out
	gpu_rd_rdy_b   <= rd_req_dlyb[READ_CLOCK_CYCLES-1]; // needs to be high when 2 clock cycles has passed since address_b was sent out


	gpu_wr_ena     <=  dumb_ab_mux ? (wr_ena_a || wena_a_dly)  : (wr_ena_b || wena_b_dly)  ;
	gpu_address    <=  dumb_ab_mux ?  address_a                :  address_b                ;
	gpu_data_out 	<=  dumb_ab_mux ?  data_in_a                :  data_in_b                ;

	rd_req_dlya[0]	<=   dumb_ab_mux && (rd_req_a || rdreq_a_dly)  ;  // internally hold the read request
	rd_req_dlyb[0]	<=  ~dumb_ab_mux && (rd_req_b || rdreq_b_dly)  ;  // internally hold the read request

	rd_req_dlya[9:1] <= rd_req_dlya[8:0] ; // delay the read request by the correct amount of clocks matching the 
	rd_req_dlyb[9:1] <= rd_req_dlyb[8:0] ; // delay the read request by the correct amount of clocks matching the 


	wena_a_dly   <=  wr_ena_a ; // widen the write pulse by 1 clock
	wena_b_dly   <=  wr_ena_b ; // widen the write pulse by 1 clock
	rdreq_a_dly  <=  rd_req_a ; // widen the read request pulse by 1 clock.
	rdreq_b_dly  <=  rd_req_b ; // widen the read request pulse by 1 clock.

end // always

endmodule
