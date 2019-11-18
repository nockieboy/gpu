module vid_osd_generator ( clk, pc_ena, hde_in, vde_in, hs_in, vs_in, osd_ena_out, osd_image, hde_out, vde_out, hs_out, vs_out,
			host_clk, host_wr_ena, host_addr, host_wr_data, host_rd_data );

// To write contents into the display and font memories, the wr_addr[15:0] selects the address
// the wr_data[7:0] contains a byte which will be written
// the wren_disp is the write enable for the ascii text ram.  Only the wr_addr[8:0] are used as the character display is 32x16.
// the wren_font is the write enable for the font memory.  Only 2 bits are used of the wr_data[1:0] and wr_addr[12:0] are used.
// tie these ports to GND for now disabling them

input clk;
input [3:0] pc_ena;
input hde_in, vde_in, hs_in, vs_in;

output 	osd_ena_out;
reg    	osd_ena_out;
output 	[2:0] osd_image;
output 	hde_out, vde_out, hs_out, vs_out;
reg 		hde_out, vde_out, hs_out, vs_out;

reg  [9:0] disp_x,dly1_disp_x,dly2_disp_x,dly3_disp_x,dly4_disp_x,dly5_disp_x,dly6_disp_x,dly7_disp_x,dly8_disp_x;
reg  [8:0] disp_y,dly1_disp_y,dly2_disp_y,dly3_disp_y,dly4_disp_y;

reg  dena,dly1_dena,dly2_dena,dly3_dena,dly4_dena,dly5_dena,dly6_dena;
reg  [7:0] dly1_letter, dly2_letter, dly3_letter, dly4_letter;

reg  [9:0] hde_pipe, vde_pipe, hs_pipe, vs_pipe;

input wire         host_clk;
input wire         host_wr_ena;
input wire  [19:0] host_addr;
input wire  [7:0]  host_wr_data;
output wire [7:0]  host_rd_data;

parameter   PIPE_DELAY =  6;   // This parameter selects the number of pixel clocks to delay the VDE and sync outputs.  Only use 2 through 9.

wire [12:0] font_pos;
wire [8:0] disp_pos;
wire [2:0] osd_image;
wire [19:0] read_text_adr;
wire [19:0] read_font_adr;
wire [7:0] letter;
wire [7:0] char_line;


// ****************************************************************************************************************************
// create a multiport GPU RAM handler instance
// ****************************************************************************************************************************
multiport_gpu_ram gpu_RAM(

	.clk(clk),
	.pc_ena_in(pc_ena[3:0]),
	
	.addr_in_0(read_text_adr[19:0]),
	.addr_in_1(read_font_adr[19:0]),
	.addr_in_2(20'b0),
	.addr_in_3(20'b0),
	.addr_in_4(20'b0),
	
	.cmd_in_0(16'b0),
	.cmd_in_1(16'b0),
	.cmd_in_2(16'b0),
	.cmd_in_3(16'b0),
	.cmd_in_4(16'b0),
	
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
	
	.clk_b(host_clk),			// Host (Z80) clock input
	.write_ena_b(host_wr_ena),	// Host (Z80) clock enable
	.addr_host_in(host_addr[19:0]),
    .data_host_in(host_wr_data[7:0]),
	.data_host_out(host_rd_data[7:0])

);
defparam gpu_RAM.ADDR_SIZE = 14,	// pass ADDR_SIZE into the gpu_RAM instance
         gpu_RAM.PIXEL_PIPE = 3;    // set the length of the pixel pipe to offset multi-read port sequencing

//  The disp_x is the X coordinate counter.  It runs from 0 to 512 and stops there
//  The disp_y is the Y coordinate counter.  It runs from 0 to 256 and stops there

// Get the character at the current x, y position
assign disp_pos[4:0]  = disp_x[8:4] ;  // The disp_pos[4:0] is the lower address for the 32 characters for the ascii text.
assign disp_pos[8:5]  = disp_y[7:4] ;  // the disp_pos[8:5] is the upper address for the 16 lines of text

//  The result from the ascii memory component 'altsyncram_component_osd_mem'  is called letter[7:0]
//  Since disp_pos[8:0] has entered the read address, it takes 2 pixel clock cycles for the resulting letter[7:0] to come out.

//  Now, font_pos[12:0] is the read address for the memory block containing the character specified in letter[]

assign font_pos[9:3]    = letter[6:0] ;       // Select the upper font address with the 7 bit letter, note the atari font has only 128 characters.
assign font_pos[2:0]	= dly3_disp_y[3:1] ;  // select the font x coordinate with a 2 pixel clock DELAYED disp_x address.  [3:1] is used so that every 2 x lines are repeats

//  The resulting 2-bit font image at x is assigned to the OSD[1:0] output
//  Also, since there is an 8th bit in the ascii text memory, I use that as a third OSD output color bit
assign osd_image[0] = 0;
assign osd_image[1] = char_line[(~dly6_disp_x[3:1])];
assign osd_image[2] = dly3_letter[7];  // Remember, it takes 2 pixel clocks for osd_img[1:0] data to be valid from read address letter[6:0]

assign read_text_adr[8:0] = disp_pos[8:0];
assign read_text_adr[9] =  1'b0;
assign read_text_adr[19:10] = 10'h4;        // my mistake, I has 1bit instead of 10bits

assign read_font_adr[9:0] = font_pos[9:0];
assign read_font_adr[19:10] = 10'h2;        // my mistake, I has 1bit instead of 10bits

always @ ( posedge clk ) begin

	if (pc_ena[3:0] == 0) begin

		// **************************************************************************************************************************
		// *** Create a serial pipe where the PIPE_DELAY parameter selects the pixel count delay for the xxx_in to the xxx_out ports
		// **************************************************************************************************************************

		hde_pipe[0]   <= hde_in;
		hde_pipe[9:1] <= hde_pipe[8:0];
		hde_out       <= hde_pipe[PIPE_DELAY-1];

		vde_pipe[0]   <= vde_in;
		vde_pipe[9:1] <= vde_pipe[8:0];
		vde_out       <= vde_pipe[PIPE_DELAY-1];

		hs_pipe[0]    <= hs_in;
		hs_pipe[9:1]  <= hs_pipe[8:0];
		hs_out        <= hs_pipe[PIPE_DELAY-1];

		vs_pipe[0]    <= vs_in;
		vs_pipe[9:1]  <= vs_pipe[8:0];
		vs_out        <= vs_pipe[PIPE_DELAY-1];

		// **********************************************************************************************
		// This OSD generator's window is only 512 pixels by 256 lines.
		// Since the disp_X&Y counters are the screens X&Y coordinates, I'm using an extra most 
		// significant bit in the counters to determine if the OSD ena flag should be on or off.

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
		osd_ena_out  <= dly4_dena;	// This is used to drive a graphics A/B switch which tells when the OSD graphics should be shown
											// It needs to be delayed by the number of pixel clocks required for the above memories

	end // ena
	
end // always@clk

endmodule
