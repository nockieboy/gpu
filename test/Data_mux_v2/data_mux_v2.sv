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

module data_mux_v2 (

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
   output wire        gpu_wr_ena,    // output pulses high for 1 clock when a write request takes place
   output wire [19:0] gpu_address,
   output wire [7:0]  gpu_data_out,
   
   // outputs Port A
   output wire       gpu_rd_rdy_a,  // one-CLK HIGH pulse here indicates valid data on data_out_a
   output wire [7:0] data_out_a,
   
   // outputs Port B
   output wire       gpu_rd_rdy_b,  // one-CLK HIGH pulse here indicates valid data on data_out_b
   output wire [7:0] data_out_b

);

parameter  READ_CLOCK_CYCLES = 2 ; // Clock cycles until the ram returns valid read data
parameter  ZERO_LATENCY      = 1 ; // When set to 1 this will make the read&write commands immediate instead of a clock cycle later.
parameter  REGISTER_GPU_PORT = 1 ; // When set to 1 this will improve FMAX at the cost of 1 extra clock cycle on the rd_req.

reg [1:0] mux_priority ;
reg [9:0] rd_req_dlya, rd_req_dlyb ;

assign data_out_a   =  gpu_data_in ;  // with this line, it is the responsibility of the next module to latch the data when the gpu_rd_rdy_a is high
assign data_out_b   =  gpu_data_in ;  // with this line, it is the responsibility of the next module to latch the data when the gpu_rd_rdy_b is high

wire        gpu_wr_ena_reg;
wire [19:0] gpu_address_reg;
wire [7:0]  gpu_data_out_reg;

wire        F_wr_ena[3:0];
wire        F_rd_req[3:0];
wire [19:0] F_address[3:0];
wire [7:0]  F_data_in[3:0];
wire        cmd_a_next, cmd_a_rdy;
wire        cmd_b_next, cmd_b_rdy;

FIFO_3word_0_latency input_cmd_fifo_1 (     // Zero Latency Command buffer.
                      .clk(clk),                                                    // CLK input
                      .reset(reset),                                                // reset FIFO

                      .shift_in        ( rd_req_a || wr_ena_a ),                    // load a word into the FIFO.
                      .shift_out       ( cmd_a_next ),                              // shift data out of the FIFO.
                      .data_in         ( {rd_req_a,wr_ena_a,address_a,data_in_a} ), // data word input.

                      .fifo_not_empty  ( cmd_a_rdy ),                                      // High when there is data available.
                      .fifo_full       (),                                                 // High when the FIFO is full.
                      .data_out        ( {F_rd_req[1],F_wr_ena[1],F_address[1],F_data_in[1]} ) // FIFO data word output
                       );
	defparam
		input_cmd_fifo_1.bits         = (1+1+20+8),  // The number of bits containing the command.
		input_cmd_fifo_1.zero_latency = ZERO_LATENCY;

FIFO_3word_0_latency input_cmd_fifo_2 (     // Zero Latency Command buffer.
                      .clk             (clk),                                              // CLK input
                      .reset           (reset),                                            // reset FIFO

                      .shift_in        ( rd_req_b || wr_ena_b ),                           // load a word into the FIFO.
                      .shift_out       ( cmd_b_next ),                                     // shift data out of the FIFO.
                      .data_in         ( {rd_req_b,wr_ena_b,address_b,data_in_b} ), // data word input.

                      .fifo_not_empty  ( cmd_b_rdy ),                                      // High when there is data available.
                      .fifo_full       (),                                                 // High when the FIFO is full.
                      .data_out        ( {F_rd_req[2],F_wr_ena[2],F_address[2],F_data_in[2]} ) // FIFO data word output
                       );
	defparam
		input_cmd_fifo_2.bits         = (1+1+20+8),  // The number of bits containing the command.
		input_cmd_fifo_2.zero_latency = ZERO_LATENCY;

assign gpu_rd_rdy_a  = rd_req_dlya[READ_CLOCK_CYCLES-1+REGISTER_GPU_PORT]; // needs to be high when 2 clock cycles has passed since address_a was sent out
assign gpu_rd_rdy_b  = rd_req_dlyb[READ_CLOCK_CYCLES-1+REGISTER_GPU_PORT]; // needs to be high when 2 clock cycles has passed since address_b was sent out

assign cmd_a_next = (cmd_a_rdy && (~cmd_b_rdy || mux_priority!=2'd0) );
assign cmd_b_next = (cmd_b_rdy && (~cmd_a_rdy || mux_priority!=2'd1) );

assign  F_wr_ena[0]         =  1'b0;
assign  F_address[0]        =  20'd0;
assign  F_data_in[0]        =  8'd0;
assign  F_wr_ena[3]         =  1'b0;
assign  F_address[3]        =  20'b0;
assign  F_data_in[3]        =  8'd0;

assign	gpu_wr_ena          =  REGISTER_GPU_PORT ? gpu_wr_ena_reg   : F_wr_ena[{cmd_b_next,cmd_a_next}]  ;
assign	gpu_address         =  REGISTER_GPU_PORT ? gpu_address_reg  : F_address[{cmd_b_next,cmd_a_next}] ;
assign  gpu_data_out        =  REGISTER_GPU_PORT ? gpu_data_out_reg : F_data_in[{cmd_b_next,cmd_a_next}] ;


always @ (posedge clk) begin

	rd_req_dlya[9:1] <= rd_req_dlya[8:0] ; // delay the read request by the correct amount of clocks matching the 
	rd_req_dlyb[9:1] <= rd_req_dlyb[8:0] ; // delay the read request by the correct amount of clocks matching the 

	gpu_wr_ena_reg          <=  F_wr_ena[{cmd_b_next,cmd_a_next}]  ; // used when REGISTER_GPU_PORT = 1
	gpu_address_reg         <=  F_address[{cmd_b_next,cmd_a_next}] ;
    gpu_data_out_reg        <=  F_data_in[{cmd_b_next,cmd_a_next}] ;


if ( cmd_a_next ) begin
		     mux_priority    <=  2'd0;
		     rd_req_dlya[0]  <=  F_rd_req[1] ;  // internally hold the read request
	end else rd_req_dlya[0]  <=  1'b0;

if ( cmd_b_next ) begin
		     mux_priority    <=  2'd1;
		     rd_req_dlyb[0]  <=  F_rd_req[2] ;  // internally hold the read request
	end else rd_req_dlyb[0]	 <=  1'b0;

end // always


always  begin


end // always

endmodule
