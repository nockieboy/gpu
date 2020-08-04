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

module data_mux_geo (

   // general inputs
   input logic        clk,
   input logic        reset,
   
   // gpu inputs
   input logic [15:0] gpu_data_in,   // data is valid here once gpu_data_in pulses HIGH
   
   // inputs Port A - Z80
   input logic        wr_ena_a,
   input logic        rd_req_a,
   input logic [19:0] address_a,
   input logic [7:0]  data_in_a,
   
   // inputs Port B - RS232
   input logic        wr_ena_b,
   input logic        rd_req_b,
   input logic [19:0] address_b,
   input logic [7:0]  data_in_b,
   
   // gpu outputs
   output logic        gpu_wr_ena,    // output pulses high for 1 clock when a write request takes place
   output logic        gpu_ena_16bit,
   output logic [19:0] gpu_address,
   output logic [15:0] gpu_data_out,
   
   // outputs Port A
   output logic       gpu_rd_rdy_a,  // one-CLK HIGH pulse here indicates valid data on data_out_a
   output logic [7:0] data_out_a,
   
   // outputs Port B
   output logic       gpu_rd_rdy_b,  // one-CLK HIGH pulse here indicates valid data on data_out_b
   output logic [7:0] data_out_b,

   // Geometry IO ports
   input  logic        geo_rd_req_a,
   input  logic        geo_rd_req_b,
   input  logic        geo_wr_ena,
   input  logic [19:0] address_geo,
   input  logic [15:0] data_in_geo,
   output logic        geo_rd_rdy_a,  // one-CLK HIGH pulse here indicates valid data on data_out_b
   output logic        geo_rd_rdy_b,  // one-CLK HIGH pulse here indicates valid data on data_out_b
   output logic [15:0] data_out_geo,
   output logic        geo_port_full  // Tells the pixel writer that the command fifo is full
);

parameter int READ_CLOCK_CYCLES    = 2; // Clock cycles until the ram returns valid read data
parameter bit REGISTER_GPU_PORT    = 1; // When set to 1 this will improve FMAX at the cost of 1 extra clock cycle on the rd_req.
parameter bit ZERO_LATENCY         = 1; // When set to 1 this will make the read&write commands immediate instead of a clock cycle later.
parameter bit overflow_protection  = 0; // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
parameter bit underflow_protection = 0; // Prevents internal position position increment if the fifo is empty
parameter bit GEO_FIFO_SIZE_7      = 0; // Set to 0 for 3 words, set to 1 for 7 words only for the GEOMETRY COMMAND FIFO INPUT

logic [1:0]  mux_priority ;
logic [9:0]  rd_req_dlya, rd_req_dlyb, geo_rd_req_dlya, geo_rd_req_dlyb ;

logic        F_ena_16bit[7:0];
logic        F_wr_ena[7:0];
logic        F_rd_req[7:0];
logic        F_rd_req_geob;      // special second read request channel for the geometry r/w port.
logic [19:0] F_address[7:0];
logic [7:0]  F_data_in[7:0];
logic [7:0]  F_data_inH[7:0];
logic        cmd_a_next, cmd_a_rdy;
logic        cmd_b_next, cmd_b_rdy;
logic        cmd_c_next, cmd_c_rdy;

logic        gpu_ena_16bit_reg;
logic	     gpu_wr_ena_reg;
logic [19:0] gpu_address_reg;
logic [15:0] gpu_data_out_reg;

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
		input_cmd_fifo_1.bits                 = (1+1+20+8),           // The number of bits containing the command.
		input_cmd_fifo_1.zero_latency         = ZERO_LATENCY,
		input_cmd_fifo_1.overflow_protection  = overflow_protection,  // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
		input_cmd_fifo_1.underflow_protection = underflow_protection, // Prevents internal position position increment if the fifo is empty
		input_cmd_fifo_1.size7_ena            = 0;                    // Set to 0 for 3 words

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
		input_cmd_fifo_2.bits                 = (1+1+20+8),           // The number of bits containing the command.
		input_cmd_fifo_2.zero_latency         = ZERO_LATENCY,
		input_cmd_fifo_2.overflow_protection  = overflow_protection,  // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
		input_cmd_fifo_2.underflow_protection = underflow_protection, // Prevents internal position position increment if the fifo is empty
		input_cmd_fifo_2.size7_ena            = 0;                    // Set to 0 for 3 words

FIFO_3word_0_latency input_cmd_fifo_3 (     // Zero Latency Command buffer.
                      .clk             (clk),                                              // CLK input
                      .reset           (reset),                                            // reset FIFO

                      .shift_in        ( geo_rd_req_a || geo_rd_req_b || geo_wr_ena ),                           // load a word into the FIFO.
                      .shift_out       ( cmd_c_next ),                                     // shift data out of the FIFO.
                      .data_in         ( {geo_rd_req_a,geo_rd_req_b,geo_wr_ena,address_geo,data_in_geo} ), // data word input.

                      .fifo_not_empty  ( cmd_c_rdy ),                                      // High when there is data available.
                      .fifo_full       ( geo_port_full ),                                  // High when the FIFO is full.
                      .data_out        ( {F_rd_req[4],F_rd_req_geob,F_wr_ena[4],F_address[4],F_data_inH[4],F_data_in[4]} ) // FIFO data word output
                       );
	defparam
		input_cmd_fifo_3.bits                 = (1+1+1+20+16),           // The number of bits containing the command.
		input_cmd_fifo_3.zero_latency         = ZERO_LATENCY,
		input_cmd_fifo_3.overflow_protection  = overflow_protection,  // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
		input_cmd_fifo_3.underflow_protection = underflow_protection, // Prevents internal position position increment if the fifo is empty
		input_cmd_fifo_3.size7_ena            = GEO_FIFO_SIZE_7;      // Set to 0 for 3 words

always_comb begin
 gpu_rd_rdy_a  = rd_req_dlya[READ_CLOCK_CYCLES-1+REGISTER_GPU_PORT]; // needs to be high when 2 clock cycles has passed since address_a was sent out
 gpu_rd_rdy_b  = rd_req_dlyb[READ_CLOCK_CYCLES-1+REGISTER_GPU_PORT]; // needs to be high when 2 clock cycles has passed since address_b was sent out
 geo_rd_rdy_a  = geo_rd_req_dlya[READ_CLOCK_CYCLES-1+REGISTER_GPU_PORT]; // needs to be high when 2 clock cycles has passed since geometry address was sent out
 geo_rd_rdy_b  = geo_rd_req_dlyb[READ_CLOCK_CYCLES-1+REGISTER_GPU_PORT]; // needs to be high when 2 clock cycles has passed since geometry address was sent out

//  Priority truth table
//
//  mux_priority, cmd_a_rdy, cmd_b_rdy, cmd_c_rdy   cmd_#_next
//          0         0          0          0           0
//          0         1          0          0           a
//          0         0          1          0           b
//          0         1          1          0           b
//          0         0          0          1           c
//          0         1          0          1           a
//          0         0          1          1           b
//          0         1          1          1           b
//
//          1         0          0          0           0
//          1         1          0          0           a
//          1         0          1          0           b
//          1         1          1          0           b
//          1         0          0          1           c
//          1         1          0          1           a
//          1         0          1          1           b
//          1         1          1          1           b
//
//          2         0          0          0           0
//          2         1          0          0           a
//          2         0          1          0           b
//          2         1          1          0           a
//          2         0          0          1           c
//          2         1          0          1           a
//          2         0          1          1           b
//          2         1          1          1           a
//
//          3         0          0          0           0       Note as observed, cmd_c_rdy has no priority whatsoever
//          3         1          0          0           a       as the other 2 ports are the Z80 & rs232, being so slow
//          3         0          1          0           b       they're given immediate access on request.  Also note
//          3         1          1          0           b       that only the GEO unit responds to the FIFO full flag,
//          3         0          0          1           c       so it is the only one who can actually pause commands
//          3         1          0          1           a
//          3         0          1          1           b       This is whay the mux_priority only goes between 0 & 1.
//          3         1          1          1           b
//
 cmd_a_next = (cmd_a_rdy && (!cmd_b_rdy || mux_priority!=2'd0) );
 cmd_b_next = (cmd_b_rdy && (!cmd_a_rdy || mux_priority!=2'd1) );
 cmd_c_next = (cmd_c_rdy && !(cmd_a_rdy || cmd_b_rdy ) );

 F_wr_ena[0]         =  1'b0;  // Zero all unused ports
 F_address[0]        =  20'd0;
 F_data_in[0]        =  8'd0;
 F_wr_ena[3]         =  1'b0;
 F_address[3]        =  20'b0;
 F_data_in[3]        =  8'd0;
 F_wr_ena[5]         =  1'b0;
 F_address[5]        =  20'b0;
 F_data_in[5]        =  8'd0;
 F_wr_ena[6]         =  1'b0;
 F_address[6]        =  20'b0;
 F_data_in[6]        =  8'd0;
 F_wr_ena[7]         =  1'b0;
 F_address[7]        =  20'b0;
 F_data_in[7]        =  8'd0;

for (int i=0 ; i<4 ; i++) F_data_inH[i]  =  8'd0;      // Set 16 bit upper 8 bits to 0 when not using the GEO port
for (int i=5 ; i<8 ; i++) F_data_inH[i]  =  8'd0;      // Set 16 bit upper 8 bits to 0 when not using the GEO port
for (int i=0 ; i<8 ; i++) F_ena_16bit[i] =  (i == 4);  // Set 16 bit mode when cmd_c_next/geometry access

 gpu_ena_16bit       =  REGISTER_GPU_PORT ? gpu_ena_16bit_reg      : F_ena_16bit[{cmd_c_next,cmd_b_next,cmd_a_next}] ;
 gpu_wr_ena          =  REGISTER_GPU_PORT ? gpu_wr_ena_reg         : F_wr_ena[{cmd_c_next,cmd_b_next,cmd_a_next}]    ;
 gpu_address         =  REGISTER_GPU_PORT ? gpu_address_reg        : F_address[{cmd_c_next,cmd_b_next,cmd_a_next}]   ;
 gpu_data_out[7:0]   =  REGISTER_GPU_PORT ? gpu_data_out_reg[7:0]  : F_data_in[{cmd_c_next,cmd_b_next,cmd_a_next}]   ;
 gpu_data_out[15:8]  =  REGISTER_GPU_PORT ? gpu_data_out_reg[15:8] : F_data_inH[{cmd_c_next,cmd_b_next,cmd_a_next}]   ;

 data_out_a   =  gpu_data_in[7:0] ;  // with this line, it is the responsibility of the next module to latch the data when the gpu_rd_rdy_a is high
 data_out_b   =  gpu_data_in[7:0] ;  // with this line, it is the responsibility of the next module to latch the data when the gpu_rd_rdy_b is high
 data_out_geo =  gpu_data_in[15:0] ; // the 16bit memory access for the geometry unit
end // always_comb

always_ff @(posedge clk) begin

   rd_req_dlya[9:1]        <= rd_req_dlya[8:0] ;     // delay the read request by the correct amount of clocks matching the 
   rd_req_dlyb[9:1]        <= rd_req_dlyb[8:0] ;     // delay the read request by the correct amount of clocks matching the 
   geo_rd_req_dlya[9:1]    <= geo_rd_req_dlya[8:0] ; // delay the read request by the correct amount of clocks matching the 
   geo_rd_req_dlyb[9:1]    <= geo_rd_req_dlyb[8:0] ; // delay the read request by the correct amount of clocks matching the 

   gpu_ena_16bit_reg       <=  F_ena_16bit[{cmd_c_next,cmd_b_next,cmd_a_next}] ; // used when REGISTER_GPU_PORT = 1
   gpu_wr_ena_reg          <=  F_wr_ena[{cmd_c_next,cmd_b_next,cmd_a_next}]  ;   // used when REGISTER_GPU_PORT = 1
   gpu_address_reg         <=  F_address[{cmd_c_next,cmd_b_next,cmd_a_next}] ;   // used when REGISTER_GPU_PORT = 1
   gpu_data_out_reg[7:0]   <=  F_data_in[{cmd_c_next,cmd_b_next,cmd_a_next}] ;   // used when REGISTER_GPU_PORT = 1
   gpu_data_out_reg[15:8]  <=  F_data_inH[{cmd_c_next,cmd_b_next,cmd_a_next}] ;  // used when REGISTER_GPU_PORT = 1


	if ( cmd_a_next ) begin
             mux_priority    <=  2'd0;
             rd_req_dlya[0]  <=  F_rd_req[1] ;  // internally hold the read request
	end else rd_req_dlya[0]  <=  1'b0;

	if ( cmd_b_next ) begin
             mux_priority    <=  2'd1;
             rd_req_dlyb[0]  <=  F_rd_req[2] ;  // internally hold the read request
	end else rd_req_dlyb[0]	 <=  1'b0;

	if ( cmd_c_next ) begin
             mux_priority        <=  2'd1;
             geo_rd_req_dlya[0]  <=  F_rd_req[4]   ;  // internally hold the read request
             geo_rd_req_dlyb[0]  <=  F_rd_req_geob ;  // internally hold the read request
	end else begin
	         geo_rd_req_dlya[0]	 <=  1'b0;
	         geo_rd_req_dlyb[0]	 <=  1'b0;
             end

end // always_ff

endmodule
