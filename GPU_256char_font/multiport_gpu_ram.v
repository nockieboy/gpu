module multiport_gpu_ram ( 

	input clk,				// Primary clk input (125 MHz)
	input [3:0] pc_ena_in,	// Pixel clock enable

	// address buses (input)
	input [19:0] addr_in_0,
	input [19:0] addr_in_1,
	input [19:0] addr_in_2,
	input [19:0] addr_in_3,
	input [19:0] addr_in_4,
	
	// auxilliary read command buses (input)
	input [15:0] cmd_in_0,
	input [15:0] cmd_in_1,
	input [15:0] cmd_in_2,
	input [15:0] cmd_in_3,
	input [15:0] cmd_in_4,
	
	// outputs
	output wire [3:0] pc_ena_out,
	
	// address pass-thru bus (output)
	output reg [19:0] addr_out_0,
	output reg [19:0] addr_out_1,
	output reg [19:0] addr_out_2,
	output reg [19:0] addr_out_3,
	output reg [19:0] addr_out_4,
	
	// auxilliary read command bus (pass-thru output)
	output reg [15:0] cmd_out_0,
	output reg [15:0] cmd_out_1,
	output reg [15:0] cmd_out_2,
	output reg [15:0] cmd_out_3,
	output reg [15:0] cmd_out_4,
	
	// data buses (output)
	output reg [7:0] data_out_0,
	output reg [7:0] data_out_1,
	output reg [7:0] data_out_2,
	output reg [7:0] data_out_3,
	output reg [7:0] data_out_4,

	input clk_b,			// Host (Z80) clock input
	input write_ena_b,	// Host (Z80) clock enable
	input [19:0] addr_host_in,
   input [7:0]  data_host_in,
	output [7:0] data_host_out
	
);

// dual-port GPU RAM handler

// define the maximum address bits and number of words - effectively the RAM size
parameter ADDR_SIZE = 14;
parameter NUM_WORDS = 2 ** ADDR_SIZE;

reg [19:0] addr_in_mux;
reg [15:0] cmd_mux_in;

reg [19:0] addr_lat_1;
reg [19:0] addr_lat_2;
reg [19:0] addr_lat_3;
reg [19:0] addr_lat_4;

reg [15:0] cmd_lat_1;
reg [15:0] cmd_lat_2;
reg [15:0] cmd_lat_3;
reg [15:0] cmd_lat_4;

wire [15:0] cmd_mux_out;
wire [19:0] addr_mux_out;
wire [7:0] data_mux_out;

// create a GPU RAM instance
gpu_dual_port_ram_INTEL gpu_RAM(
	.clk(clk),
	.pc_ena_in(pc_ena_in),
	.clk_b(clk_b),
	.wr_en_b(write_ena_b),   // **** error, you wrote (wr_en_b), it should be (write_ena_b)
	.addr_a(addr_in_mux),
	.addr_b(addr_host_in),
	.data_in_b(data_host_in),
	.cmd_in(cmd_mux_in),
	.addr_out_a(addr_mux_out),
	.pc_ena_out(pc_ena_out),
	.cmd_out(cmd_mux_out),
	.data_out_a(data_mux_out),
	.data_out_b(data_host_out)   // ****** error, you had this field empty.
);

defparam gpu_RAM.ADDR_SIZE = ADDR_SIZE,	// pass ADDR_SIZE into the gpu_RAM instance
			gpu_RAM.NUM_WORDS = NUM_WORDS;	// set non-default word size for the RAM (16 KB)


parameter   PIXEL_PIPE = 3;  // This externally set parameter defines the number of 25MHz pixels it takes to receive a new pixel from a presented address

localparam CLK_CYCLES_MUX = 1;	// adjust this parameter to the number of 'clk' cycles it takes to select 1 of 5 muxed outputs
localparam CLK_CYCLES_RAM = 2;	// adjust this figure to the number of clock cycles the DP_ram takes to retrieve valid data from the read address in
localparam CLK_CYCLES_PIX = 5;	// adjust this figure to the number of 125MHz clocks there are for each pixel, IE number of muxed inputs for each pixel

//  This parameter begins with the wanted top number of 125Mhz pixel clock headroom for the pixel pipe, then subtracts the additional 125MHz clocks used by the _MUX and _RAM cycles used to arrive at the first pixel out, DEMUX_PIPE_TOP position.
localparam  DEMUX_PIPE_TOP    =  (( (PIXEL_PIPE - 1) * CLK_CYCLES_PIX ) - 1) - CLK_CYCLES_MUX - CLK_CYCLES_RAM;


localparam MUX_0_POS = DEMUX_PIPE_TOP - 0;  // pixel offset positions in their respective synchronisation
localparam MUX_1_POS = DEMUX_PIPE_TOP - 1;	  // pipelines (where the pixels will be found in the pipeline
localparam MUX_2_POS = DEMUX_PIPE_TOP - 2;	  // when pc_ena[3:0]==0).
localparam MUX_3_POS = DEMUX_PIPE_TOP - 3;	  //
localparam MUX_4_POS = DEMUX_PIPE_TOP - 4;	//

// Now that we know the DEMUX_PIPE_TOP, we can assign the top size of the 3 pipe regs

reg [DEMUX_PIPE_TOP*8+7:0] data_pipe;
reg [DEMUX_PIPE_TOP*20+19:0] addr_pipe;
reg [DEMUX_PIPE_TOP*16+15:0] cmd_pipe;

always @(posedge clk) begin

// We also need to limit the pipe in the 3 ' <= '

	data_pipe[7:0] 	                   	<= data_mux_out[7:0];		// fill the first 8-bit word in the register pipe with data from RAM
	data_pipe[DEMUX_PIPE_TOP*8+7:1*8]	   <= data_pipe[ (DEMUX_PIPE_TOP-1) *8+7:0*8];	// shift over the next 9 words in this 10 word, 8-bit wide pipe
																	// this moves the data up one word at a time, dropping the top most 8 bits
	addr_pipe[19:0]	                  	<= addr_mux_out;
	addr_pipe[DEMUX_PIPE_TOP*20+19:1*20]	<= addr_pipe[ (DEMUX_PIPE_TOP-1) *20+19:0*20];
	
	cmd_pipe[15:0]	                     	<= cmd_mux_out[15:0];
	cmd_pipe[DEMUX_PIPE_TOP*16+15:1*16]	   <= cmd_pipe[ (DEMUX_PIPE_TOP-1) *16+15:0*16];


	if (pc_ena_in[3:0] == 0)
	begin
		addr_out_0 <= addr_pipe[MUX_0_POS*20+19:MUX_0_POS*20];
		addr_out_1 <= addr_pipe[MUX_1_POS*20+19:MUX_1_POS*20];
		addr_out_2 <= addr_pipe[MUX_2_POS*20+19:MUX_2_POS*20];
		addr_out_3 <= addr_pipe[MUX_3_POS*20+19:MUX_3_POS*20];
		addr_out_4 <= addr_pipe[MUX_4_POS*20+19:MUX_4_POS*20];
		
		cmd_out_0 <= cmd_pipe[MUX_0_POS*16+15:MUX_0_POS*16];
		cmd_out_1 <= cmd_pipe[MUX_1_POS*16+15:MUX_1_POS*16];
		cmd_out_2 <= cmd_pipe[MUX_2_POS*16+15:MUX_2_POS*16];
		cmd_out_3 <= cmd_pipe[MUX_3_POS*16+15:MUX_3_POS*16];
		cmd_out_4 <= cmd_pipe[MUX_4_POS*16+15:MUX_4_POS*16];
		
		data_out_0 <= data_pipe[MUX_0_POS*8+7:MUX_0_POS*8];
		data_out_1 <= data_pipe[MUX_1_POS*8+7:MUX_1_POS*8];
		data_out_2 <= data_pipe[MUX_2_POS*8+7:MUX_2_POS*8];
		data_out_3 <= data_pipe[MUX_3_POS*8+7:MUX_3_POS*8];
		data_out_4 <= data_pipe[MUX_4_POS*8+7:MUX_4_POS*8];
	end
	
	// perform 5:1 mux for all inputs to the dual-port RAM


	case (pc_ena_in[3:0])
		4'h0 : begin
						addr_in_mux <= addr_in_0;  // Send the first, #0 addr & cmd to the memory module.
						cmd_mux_in <= cmd_in_0;
						
						addr_lat_1 <= addr_in_1;  // latch all addr_in_# in parallel
						addr_lat_2 <= addr_in_2;
						addr_lat_3 <= addr_in_3;
						addr_lat_4 <= addr_in_4;

						cmd_lat_1  <= cmd_in_1;  // latch all cmd_in_# in parallel
						cmd_lat_2  <= cmd_in_2;
						cmd_lat_3  <= cmd_in_3;
						cmd_lat_4  <= cmd_in_4;
						
					end
		4'h1 : begin
						addr_in_mux <= addr_lat_1; //  Send the latched, #1 addr & cmd to the memory module.
						cmd_mux_in  <= cmd_lat_1;
					end
		4'h2 : begin   
						addr_in_mux <= addr_lat_2; //  Send the latched, #2 addr & cmd to the memory module.
						cmd_mux_in  <= cmd_lat_2;
					end
		4'h3 : begin    
						addr_in_mux <= addr_lat_3; //  Send the latched, #3 addr & cmd to the memory module.
						cmd_mux_in  <= cmd_lat_3;
					end
		4'h4 : begin    
						addr_in_mux <= addr_lat_4; //  Send the latched, #4 addr & cmd to the memory module.
						cmd_mux_in  <= cmd_lat_4;
					end
	endcase

end // always @clk

endmodule
