module sixteen_port_gpu_ram ( 

	input clk_2x,
	input clk_2x_phase,
	input clk,				// Primary clk input (125 MHz)
	input [3:0] pc_ena_in,	// Pixel clock enable

	// address buses (input)
	input [19:0] addr_in[14:0],
	
	// auxilliary read command buses (input)
	input [31:0] cmd_in[14:0],				// ****** changed to 32 bit width
		
	// address pass-thru bus (output)
	output reg [19:0] addr_out[14:0],
	
	// auxilliary read command bus (pass-thru output)
	output reg [31:0] cmd_out[14:0],		// ****** changed to 32 bit width
	
	// data buses (output)
	output reg [15:0] data_out[14:0],		// ****** changed to 16 bit width

	input          write_ena_host,  // host GPU ram port write enable
	input          ena_host_16bit,  // host GPU ram port write enable 16bit.
	input  [19:0]  addr_host_in,
   input  [15:0]  data_host_in,
	output [15:0]  data_host_out
	
);

// dual-port GPU RAM handler

// define the maximum address bits and number of words - effectively the RAM size
parameter ADDR_SIZE         = 14;
parameter NUM_WORDS         = 2 ** ADDR_SIZE;
parameter HOST_BASE_ADDRESS = 20'h0;
parameter MIF_FILE          = "gpu_16K_VGA.mif";

wire host_enable;
assign host_enable = (HOST_BASE_ADDRESS[19:ADDR_SIZE] == addr_host_in[19:ADDR_SIZE]) && ( addr_host_in[ADDR_SIZE-1:0] < NUM_WORDS ); // Limnit the read & write enable window 

reg   [19:0] addr_mux_in[3:0];
reg   [31:0] cmd_mux_in[3:0];		// ****** changed to 32 bit width

wire  [19:0] w_addr_mux_in[3:0];
wire  [31:0] w_cmd_mux_in[3:0];		// ****** changed to 32 bit width
wire  [15:0] data_mux_in[3:0];

reg [19:0] addr_lat[3:0][4:1];

reg [31:0] cmd_lat[3:0][4:1];		// ****** changed to 32 bit width

wire [31:0] cmd_mux_out[3:0];	// ****** changed to 32 bit width
wire [19:0] addr_mux_out[3:0];
wire [15:0] data_mux_out[3:0];	// ****** changed to 16 bit width

wire [3:0]  wren_host;
wire [3:0]  mode_8bit_host;

assign      w_addr_mux_in[2:0]     = addr_mux_in[2:0];
assign      w_cmd_mux_in[2:0]      = cmd_mux_in[2:0];

assign      mode_8bit_host         = { ~ena_host_16bit, 3'b000 } ;    // Assign port 4 to writing 8 or 16 bits depending on 16bit writing mode input.
assign      wren_host[2:0]         = 3'b000  ;                        // disable writing of first 3 ports
assign      wren_host[3]           = write_ena_host && host_enable ;  // Set port 4 to the host port write enable.
assign      w_cmd_mux_in[3][0]     = host_enable ;                    // pipe into the cmd mux of port 4 a the host enable function.       
assign      w_addr_mux_in[3]       = addr_host_in ;                   // Set port 4 to host address
assign      data_mux_in[3][7:0]    = data_host_in[7:0] ;              // Set port 4 write data low byte to host data input
//assign      data_mux_in[3][15:8]   = ena_host_16bit    ? data_host_in[15:8]    : data_host_in[7:0] ; // in 8 bit mode, automatically set upper byte write data to the first 8 bits, in 16 bit mode, set it to the upper 8 bits.
assign      data_mux_in[3][15:8]   = data_host_in[15:0] ; // When writing in 8 bit mode, make sure the upper byte has a copy of the first 8 bits.
assign      data_host_out          = cmd_mux_out[3][0] ? data_mux_out[3][15:0] : 16'h0 ;             // set the host read port to port 4 if a hosr_enable read command went in, otherwise return 0

// create a GPU RAM instance
gpu_quad_port_ram gpu_RAM(

	.clk         ( clk ),
	.clk_2x      ( clk_2x ),
	.clk_2x_phase ( clk_2x_phase ),
	.wren        ( wren_host ),
	.addr        ( w_addr_mux_in ),
	.data_in     ( data_mux_in ),
	.mode_8bit   ( mode_8bit_host ),      // When writing in 8 bit mode, the high and low byte of the 'data_in' need to be wired together.
	.data_out    ( data_mux_out ),
	.addr_out    ( addr_mux_out ),
	
	.cmd_in      ( w_cmd_mux_in ),
	.cmd_out     ( cmd_mux_out ) );


defparam    gpu_RAM.ADDR_SIZE = ADDR_SIZE,	// pass ADDR_SIZE into the gpu_RAM instance
			gpu_RAM.NUM_WORDS = NUM_WORDS,  // set non-default word size for the RAM (16 KB)
			gpu_RAM.MIF_FILE  = MIF_FILE  ;	// set powerup initialization file.


parameter PIXEL_PIPE = 3;  // This externally set parameter defines the number of 25MHz pixels it takes to receive a new pixel from a presented address

localparam CLK_CYCLES_MUX = 1;	// adjust this parameter to the number of 'clk' cycles it takes to select 1 of 5 muxed outputs
localparam CLK_CYCLES_RAM = 2;	// adjust this figure to the number of clock cycles the DP_ram takes to retrieve valid data from the read address in
localparam CLK_CYCLES_PIX = 5;	// adjust this figure to the number of 125MHz clocks there are for each pixel, IE number of muxed inputs for each pixel

//  This parameter begins with the wanted top number of 125Mhz pixel clock headroom for the pixel pipe, then subtracts the additional 125MHz clocks used by the _MUX and _RAM cycles used to arrive at the first pixel out, DEMUX_PIPE_TOP position.
localparam  DEMUX_PIPE_TOP    =  (( (PIXEL_PIPE - 1) * CLK_CYCLES_PIX ) - 1) - CLK_CYCLES_MUX - CLK_CYCLES_RAM;


localparam MUX_0_POS = DEMUX_PIPE_TOP - 0;	// pixel offset positions in their respective synchronisation
localparam MUX_1_POS = DEMUX_PIPE_TOP - 1;	// pipelines (where the pixels will be found in the pipeline
localparam MUX_2_POS = DEMUX_PIPE_TOP - 2;	// when pc_ena[3:0]==0).
localparam MUX_3_POS = DEMUX_PIPE_TOP - 3;	//
localparam MUX_4_POS = DEMUX_PIPE_TOP - 4;	//

// Now that we know the DEMUX_PIPE_TOP, we can assign the top size of the 3 pipe regs

reg [15:0] data_pipe[3:0][DEMUX_PIPE_TOP:0];		// ****** changed to 16 bit width
reg [19:0] addr_pipe[3:0][DEMUX_PIPE_TOP:0];
reg [31:0] cmd_pipe[3:0][DEMUX_PIPE_TOP:0];		// ****** changed to 32 bit width

integer i;

always @(posedge clk) begin

// We also need to limit the pipe in the 3 ' <= '
for (i=0 ; i<3; i=i+1) begin

	data_pipe[i][0]    	            <= data_mux_out[i];		// fill the first 16-bit word in the register pipe with data from RAM
	data_pipe[i][DEMUX_PIPE_TOP:1]	<= data_pipe[i][DEMUX_PIPE_TOP-1:0];	// shift over the next 9 words in this 10 word, 16-bit wide pipe
																	// this moves the data up two words at a time, dropping the top most 16 bits
	addr_pipe[i][0]                	<= addr_mux_out[i];
	addr_pipe[i][DEMUX_PIPE_TOP:1]	<= addr_pipe[i][DEMUX_PIPE_TOP-1:0];
	
	cmd_pipe[i][0]                 	<= cmd_mux_out[i];
	cmd_pipe[i][DEMUX_PIPE_TOP:1]   <= cmd_pipe[i][DEMUX_PIPE_TOP-1:0];		// ****** changed to 32 bit width

	if (pc_ena_in[3:0] == 0)
	begin

		addr_out[0+i*5] <= addr_pipe[i][MUX_0_POS];
		addr_out[1+i*5] <= addr_pipe[i][MUX_1_POS];
		addr_out[2+i*5] <= addr_pipe[i][MUX_2_POS];
		addr_out[3+i*5] <= addr_pipe[i][MUX_3_POS];
		addr_out[4+i*5] <= addr_pipe[i][MUX_4_POS];
		
		cmd_out[0+i*5] <= cmd_pipe[i][MUX_0_POS];		// ****** changed to 32 bit width
		cmd_out[1+i*5] <= cmd_pipe[i][MUX_1_POS];
		cmd_out[2+i*5] <= cmd_pipe[i][MUX_2_POS];
		cmd_out[3+i*5] <= cmd_pipe[i][MUX_3_POS];
		cmd_out[4+i*5] <= cmd_pipe[i][MUX_4_POS];
		
		data_out[0+i*5] <= data_pipe[i][MUX_0_POS];		// ****** changed to 16 bit width
		data_out[1+i*5] <= data_pipe[i][MUX_1_POS];
		data_out[2+i*5] <= data_pipe[i][MUX_2_POS];
		data_out[3+i*5] <= data_pipe[i][MUX_3_POS];
		data_out[4+i*5] <= data_pipe[i][MUX_4_POS];
	end
	
	// perform 5:1 mux for all inputs to the dual-port RAM
	case (pc_ena_in[3:0])
		4'h0 : begin
						addr_mux_in[i] <= addr_in[0+i*5];  // Send the first, #0 addr & cmd to the memory module.
						cmd_mux_in[i]  <= cmd_in[0+i*5];
						
						addr_lat[i][1] <= addr_in[1+i*5];  // latch all addr_in_# in parallel
						addr_lat[i][2] <= addr_in[2+i*5];
						addr_lat[i][3] <= addr_in[3+i*5];
						addr_lat[i][4] <= addr_in[4+i*5];

						cmd_lat[i][1]  <= cmd_in[1+i*5];  // latch all cmd_in_# in parallel
						cmd_lat[i][2]  <= cmd_in[2+i*5];
						cmd_lat[i][3]  <= cmd_in[3+i*5];
						cmd_lat[i][4]  <= cmd_in[4+i*5];
						
					end
		4'h1 : begin
						addr_mux_in[i] <= addr_lat[i][1]; //  Send the latched, #1 addr & cmd to the memory module.
						cmd_mux_in[i]  <= cmd_lat[i][1];
					end
		4'h2 : begin   
						addr_mux_in[i] <= addr_lat[i][2]; //  Send the latched, #2 addr & cmd to the memory module.
						cmd_mux_in[i]  <= cmd_lat[i][2];
					end
		4'h3 : begin    
						addr_mux_in[i] <= addr_lat[i][3]; //  Send the latched, #3 addr & cmd to the memory module.
						cmd_mux_in[i]  <= cmd_lat[i][3];
					end
		4'h4 : begin    
						addr_mux_in[i] <= addr_lat[i][4]; //  Send the latched, #4 addr & cmd to the memory module.
						cmd_mux_in[i]  <= cmd_lat[i][4];
					end
		endcase

	end // for i loop

end // always @clk

endmodule
