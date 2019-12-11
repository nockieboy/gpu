module vid_osd_generator (

	// inputs
	input clk,
	input [3:0] pc_ena,
	input hde_in,
	input vde_in,
	input hs_in,
	input vs_in,
	input wire host_clk,
	input wire host_wr_ena,
	input wire [19:0] host_addr,
	input wire [7:0] host_wr_data,
	input wire [7:0] GPU_HW_Control_regs[0:(2**HW_REGS_SIZE-1)],
	input wire [47:0] HV_triggers_in,
	
	// outputs
	output reg osd_ena_out,
	output reg pixel_out_ena,
	output reg pixel_out_top_16bit,
	output reg [7:0] pixel_out_top,
	output reg [7:0] pixel_out_top_h,
	output reg hde_out,
	output reg vde_out,
	output reg hs_out,
	output reg vs_out,
	output wire [7:0] host_rd_data,
	output reg [47:0] HV_triggers_out
	
);

// To write contents into the display and font memories, the wr_addr[15:0] selects the address
// the wr_data[7:0] contains a byte which will be written
// the wren_disp is the write enable for the ascii text ram.  Only the wr_addr[8:0] are used as the character display is 32x16.
// the wren_font is the write enable for the font memory.  Only 2 bits are used of the wr_data[1:0] and wr_addr[12:0] are used.
// tie these ports to GND for now disabling them

reg [9:0] disp_x,dly1_disp_x,dly2_disp_x,dly3_disp_x,dly4_disp_x,dly5_disp_x,dly6_disp_x,dly7_disp_x,dly8_disp_x;
reg [8:0] disp_y,dly1_disp_y,dly2_disp_y,dly3_disp_y,dly4_disp_y;

reg dena,dly1_dena,dly2_dena,dly3_dena,dly4_dena,dly5_dena,dly6_dena;
reg [7:0] dly1_letter, dly2_letter, dly3_letter, dly4_letter;
reg [9:0] hde_pipe, vde_pipe, hs_pipe, vs_pipe;
reg [47:0] HV_pipe[9:0];

parameter PIPE_DELAY		= 6;	// This parameter selects the number of pixel clocks to delay the VDE and sync outputs.  Only use 2 through 9.
parameter FONT_8x16		= 0;	// 0 = 8 pixel tall font, 1 = 16 pixel tall font.
parameter HW_REGS_SIZE	= 8;	// default size for hardware register bus - set by HW_REGS parameter in design view

wire pixel_ena;
wire [12:0] font_pos;
wire [10:0] disp_pos;
wire [19:0] read_text_adr;
wire [19:0] read_font_adr;
wire [7:0]  letter;
wire [7:0]  char_line;


// ****************************************************************************************************************************
// *
// * create a multiport GPU RAM handler instance
// *
// ****************************************************************************************************************************
multiport_gpu_ram gpu_RAM(

	.clk(clk),
	.pc_ena_in(pc_ena[3:0]),
	
	.addr_in_0(read_text_adr[19:0]),
	.addr_in_1(read_font_adr[19:0]),
	.addr_in_2(20'b0),
	.addr_in_3(20'b0),
	.addr_in_4(20'b0),
	
	.cmd_in_0(32'b0),
	.cmd_in_1(32'b0),
	.cmd_in_2(32'b0),
	.cmd_in_3(32'b0),
	.cmd_in_4(32'b0),
	
	.pc_ena_out(),
	
	.addr_out_0(),
	.addr_out_1(),
	.addr_out_2(),
	.addr_out_3(),
	.addr_out_4(),
	
	.cmd_out_0(),
	.cmd_out_1(),
	.cmd_out_2(),
	.cmd_out_3(),
	.cmd_out_4(),
	
	.data_out_0(letter[7:0]),
	.data_out_1(char_line[7:0]),
	.data_out_2(),
	.data_out_3(),
	.data_out_4(),
	
	.clk_b(host_clk),				// Host (Z80) clock input
	.write_ena_b(host_wr_ena),	// Host (Z80) clock enable
	.addr_host_in(host_addr[19:0]),
   .data_host_in(host_wr_data[7:0]),
	.data_host_out(host_rd_data[7:0])

);

defparam gpu_RAM.ADDR_SIZE = 14,	// pass ADDR_SIZE into the gpu_RAM instance
         gpu_RAM.PIXEL_PIPE = 3;	// set the length of the pixel pipe to offset multi-read port sequencing

// ****************************************************************************************************************************
// *
// * create a bitplane_to_raster instance
// *
// * NOTE:  For testing, GPU_HW_Control_regs [10] sets foreground and background colour
// *                                         [11] sets two_byte_mode
// *                                         [00] sets colour_mode_in (set in bitplane_to_raster)
// *
// ****************************************************************************************************************************
bitplane_to_raster b2r_1(

	.clk(clk),
	.pc_ena(pc_ena[3:0]),
	
	// inputs
	.pixel_in_ena(pixel_ena),
	.enable_in(1'b1),
	.ram_byte_in(char_line),
	.ram_byte_h(8'b00000000),
	.bg_colour( GPU_HW_Control_regs[10] ),
	.x_in( dly6_disp_x ),
	//.colour_mode_in( GPU_HW_Control_regs[12][2:0] ),
	.two_byte_mode( GPU_HW_Control_regs[11][0] ),
	.GPU_HW_Control_regs(GPU_HW_Control_regs[0:(2**HW_REGS_SIZE-1)]),
	
	// outputs
	.enable_out(),
	.pixel_out_ena( pixel_out_ena ),
	.mode_16bit( pixel_out_top_16bit ),
	.pixel_out( pixel_out_top ),
	.pixel_out_h( pixel_out_top_h ),
	.x_out()//,
	//.colour_mode_out()

);

//  The disp_x is the X coordinate counter.  It runs from 0 to 512 and stops there
//  The disp_y is the Y coordinate counter.  It runs from 0 to 256 and stops there

// Get the character at the current x, y position
assign disp_pos[5:0]  = disp_x[8:3] ;  // The disp_pos[5:0] is the lower address for the 64 characters for the ascii text.
assign disp_pos[10:6] = disp_y[7+FONT_8x16:3+FONT_8x16] ;  // the disp_pos[10:6] is the upper address for the 32 lines of text

//  The result from the ascii memory component 'altsyncram_component_osd_mem'  is called letter[7:0]
//  Since disp_pos[8:0] has entered the read address, it takes 2 pixel clock cycles for the resulting letter[7:0] to come out.

//  Now, font_pos[12:0] is the read address for the memory block containing the character specified in letter[]

assign font_pos[10+FONT_8x16:3+FONT_8x16] = letter[7:0] ;       // Select the upper font address with the 7 bit letter, note the atari font has only 128 characters.
assign font_pos[2+FONT_8x16:0]				= dly3_disp_y[2+FONT_8x16:0] ;  // select the font x coordinate with a 2 pixel clock DELAYED disp_x address.  [3:1] is used so that every 2 x lines are repeats

//  The resulting 2-bit font image at x is assigned to the OSD[1:0] output
//  Also, since there is an 8th bit in the ascii text memory, I use that as a third OSD output color bit

//assign osd_image = char_line[(~dly6_disp_x[2:0])];   <--- edited out - replaced by bitplane_to_raster instance

assign read_text_adr[10:0] = disp_pos[10:0];
assign read_text_adr[19:11] = 9'h2;        // my mistake, I has 1bit instead of 10bits

assign read_font_adr[10+FONT_8x16:0] = font_pos[10+FONT_8x16:0];
assign read_font_adr[19:11+FONT_8x16] = 0;        // my mistake, I has 1bit instead of 10bits

always @ ( posedge clk ) begin

	if (pc_ena[3:0] == 0) begin
		
		// **************************************************************************************************************************
		// *** Create a serial pipe where the PIPE_DELAY parameter selects the pixel count delay for the xxx_in to the xxx_out ports
		// **************************************************************************************************************************
		hde_pipe[0]		<= hde_in;
		hde_pipe[9:1]	<= hde_pipe[8:0];
		hde_out			<= hde_pipe[PIPE_DELAY-1];
		
		vde_pipe[0]		<= vde_in;
		vde_pipe[9:1]	<= vde_pipe[8:0];
		vde_out			<= vde_pipe[PIPE_DELAY-1];
		
		hs_pipe[0]		<= hs_in;
		hs_pipe[9:1]	<= hs_pipe[8:0];
		hs_out			<= hs_pipe[PIPE_DELAY-1];
		
		vs_pipe[0]		<= vs_in;
		vs_pipe[9:1]	<= vs_pipe[8:0];
		vs_out			<= vs_pipe[PIPE_DELAY-1];
		
		HV_pipe[0]		<= HV_triggers_in;
		HV_pipe[9:1]	<= HV_pipe[8:0];
		HV_triggers_out	<= HV_pipe[PIPE_DELAY-1];
		
		// **********************************************************************************************
		// This OSD generator's window is only 512 pixels by 256 lines.
		// Since the disp_X&Y counters are the screens X&Y coordinates, I'm using an extra most 
		// significant bit in the counters to determine if the OSD ena flag should be on or off.
		// **********************************************************************************************
		if (disp_x[9] || disp_y[8])
			dena <= 0;									// When disp_x > 511 or disp_y > 255, then turn off the OSD's output enable flag
		else
			dena <= 1;									// otherwise, turn on the OSD output enable flag
		
		if (~vde_in)
			disp_y[8:0] <= 9'b111111111;			// preset the disp_y counter to max while the vertical display is disabled
			
		else if (hde_in && ~hde_pipe[0])
		begin		// isolate a single event at the begining of the active display area
		
			disp_x[9:0] <= 10'b0000000000;		// clear the disp_x counter
			if (!disp_y[8] | (disp_y[8:7] == 2'b11))
				disp_y <= disp_y + 1'b1;				// only increment the disp_y counter if it hasn't reached it's end
				
		end
		else if (!disp_x[9])
			disp_x <= disp_x + 1'b1;  // keep on addind to the disp_x counter until it reaches it's end.
		
		// **********************************************************************************************
		// *** These delay pipes registers are explained in the 'assign's above
		// **********************************************************************************************
		dly1_disp_x <= disp_x;
		dly2_disp_x <= dly1_disp_x;
		dly3_disp_x <= dly2_disp_x;
		dly4_disp_x <= dly3_disp_x;
		dly5_disp_x <= dly4_disp_x;
		dly6_disp_x <= dly5_disp_x;
		dly7_disp_x <= dly6_disp_x;
		dly8_disp_x <= dly7_disp_x;
		
		dly1_disp_y <= disp_y;
		dly2_disp_y <= dly1_disp_y;
		dly3_disp_y <= dly2_disp_y;
		dly4_disp_y <= dly3_disp_y;
		
		dly1_letter <= letter;
		dly2_letter <= dly1_letter;
		dly3_letter <= dly2_letter;
		dly4_letter <= dly3_letter;
		
		dly1_dena   <= dena;
		dly2_dena   <= dly1_dena;
		dly3_dena   <= dly2_dena;
		dly4_dena   <= dly3_dena;
		dly5_dena   <= dly4_dena;
		dly6_dena   <= dly5_dena;
		
		// **********************************************************************************************
		osd_ena_out	<= dly4_dena;	// This is used to drive a graphics A/B switch which tells when the OSD graphics should be shown
											// It needs to be delayed by the number of pixel clocks required for the above memories
		pixel_ena	<= dly4_dena;
		
	end // ena
	
end // always@clk

endmodule
