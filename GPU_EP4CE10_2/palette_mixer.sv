module palette_mixer (
	// inputs
	input clk_2x,
	input clk_2x_phase,
	input clk,
	input [3:0]  pc_ena_in,
	input [17:0] pixel_in[14:0],
	
	// outputs
	output reg [7:0] pixel_out_r,
	output reg [7:0] pixel_out_g,
	output reg [7:0] pixel_out_b,

	// host port
	input         host_wrena,
	input  [19:0] host_addr_in,
	input  [7:0]  host_data_in,
	output [7:0]  host_data_out
);

parameter PALETTE_ADDR = 19'h4000;	// Position the text palette after the top of the GPU RAM
parameter NUM_LAYERS   = 5;	// Position the text palette after the top of the GPU RAM

wire pc_enable = (pc_ena_in[3:0]==0);

wire [19:0] pal_in_addr[14:0];
wire [15:0] pal_out[14:0];
wire [19:0] pal_out_addr[14:0];
wire [3:0]  alpha_blend[14:0];
reg [7:0]  clut_r[14:0];
reg [7:0]  clut_g[14:0];
reg [7:0]  clut_b[14:0];
wire [3:0]  nblk_565[14:0];
wire [14:0] mode_565;
wire [14:0] video_active;

reg [7:0] pixel_r[14:0];
reg [7:0] pixel_g[14:0];
reg [7:0] pixel_b[14:0];

integer i;
wire [3:0] layer_sel;

// *********************************************************************
// *
// * create a multiport palette RAM
// *
// *********************************************************************
sixteen_port_gpu_ram palette_RAM(

	.clk_2x       (clk_2x),
	.clk_2x_phase (clk_2x_phase),
	.clk          (clk),		// Primary clk input (125 MHz)
	.pc_ena_in    (pc_ena_in),  // Pixel clock enable

	.addr_in  (pal_in_addr ),
	.data_out (pal_out     ),
	.addr_out (pal_out_addr),

	.cmd_in(),
	.cmd_out(),

// Z80 Host port direct 8 bit access
	.write_ena_host(host_wrena),
	.addr_host_in(host_addr_in),
    .data_host_in(host_data_in),
	.data_host_out(host_data_out)

);

defparam palette_RAM.MIF_FILE          = "palette.mif",
         palette_RAM.ADDR_SIZE         = 10,
         palette_RAM.HOST_BASE_ADDRESS = PALETTE_ADDR;


// *********************************************************************

always @(posedge clk) begin

for (i = 0 ; i < 15; i = i + 1) begin  // Wire all 15 channels of the palette outputs to all 24 bit RGB values, from the selected palette amd select the transparency alpha blending values.
	pal_in_addr[i][0]   = 1'b1 ;     // Swap the high and low 8 bits of the 16 bit read byte since the palette is stored in big-endian.
	pal_in_addr[i][8:1] = pixel_in[i][7:0] ;  // Shift the read address over 1 bit since we are using this memory port in 16 bit data mode only.  Remember, Address[0] is reserved to swap the high and low 8 bits in the 16 bit data read result.
	pal_in_addr[i][9]   = pixel_in[i][16]  ;  // Tie the 565 mode input to the palette ADDR MSB 
	pal_in_addr[i][10]  = pixel_in[i][17]  ;  // Though unused by the 1024 byte palette, tie the vide active flag to the 11th address bit for pass through to next stage when palette data is ready.
	mode_565[i]         = pal_out_addr[i][9]; // remember that these bits shifted +1 when addressing the 16 bit data from the dual mode 8/16 bit ram which uses Address[0] as a byte swap in 8 bit mode.
	video_active[i]     = pal_out_addr[i][10];

	nblk_565[i]     = (pal_out[i][15:0]==0 || ~video_active[i]) ?  4'h0                                 :  4'hF ;                               // make output layer transparent if video is inactive or the color coming out of the palette is 0
	alpha_blend[i]  = (mode_565[i] || ~video_active[i])         ?  nblk_565[i]                          :  15-pal_out[i][15:12] ;                  // set translucency in ARGB 4444 mode to the ALPHA, or, set opaque when in 565 mode or video is inactive
	clut_r[i][7:0]  =  mode_565[i]                              ? {pal_out[i][15:11],pal_out[i][15:13]} : {pal_out[i][11:8],pal_out[i][11:8]} ; // wire palette output to correct 8 red color bits depending on if the layer is in ARGB 4444 mode, or 565 RGB mode.
	clut_g[i][7:0]  =  mode_565[i]                              ? {pal_out[i][10:5] ,pal_out[i][10:9] } : {pal_out[i][7:4] ,pal_out[i][7:4] } ; // wire palette output to correct 8 green color bits depending on if the layer is in ARGB 4444 mode, or 565 RGB mode.
	clut_b[i][7:0]  =  mode_565[i]                              ? {pal_out[i][4:0]  ,pal_out[i][4:2]  } : {pal_out[i][3:0] ,pal_out[i][3:0] } ; // wire palette output to correct 8 blue color bits depending on if the layer is in ARGB 4444 mode, or 565 RGB mode.

	end



// calculate all the transparency blend strengths	

	if (pc_enable) begin		
// Priority layer mux selection.
			layer_sel=NUM_LAYERS[3:0]-1'b1;
for ( i = NUM_LAYERS-1 ; i >= 0; i=i-1) begin
			if (alpha_blend[i][3]) layer_sel=i[3:0];
			end

		// superimpose mix all the output RGB channel layers on top of each other to produce a final RGB 24 bit output pixel.

		// sum all the output pixel data
		pixel_out_r <= clut_r[layer_sel];
		pixel_out_g <= clut_g[layer_sel];
		pixel_out_b <= clut_b[layer_sel];

	end

end

endmodule
