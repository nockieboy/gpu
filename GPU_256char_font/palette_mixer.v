module palette_mixer (

	// inputs
	input clk,
	input [3:0] pc_ena_in,
	input [7:0] txt_pixel_in,
	input [7:0] gfx_pixel_in,
	input hde_in,
	input vde_in,
	input hs_in,
	input vs_in,
	input wire [47:0] HV_triggers_in,
	
	// outputs
	output reg [3:0] pc_ena_out,
	//
	output reg [7:0] pixel_out_r,
	output reg [7:0] pixel_out_g,
	output reg [7:0] pixel_out_b,
	//
	output reg hde_out,
	output reg vde_out,
	output reg hs_out,
	output reg vs_out,

	// host port
	input host_wrena,
	input [19:0] host_addr_in,
	input [7:0] host_data_in,
	output [7:0] host_data_out,
	
	output reg [47:0] HV_triggers_out

);

parameter PIPE_DELAY = 6;							// This parameter selects the number of pixel clocks to delay the VDE and sync outputs.  Only use 2 through 9.

parameter [19:0] TXT_PALETTE_ADDR = 19'h4000;	// Position the text palette after the top of the GPU RAM
parameter [19:0] GFX_PALETTE_ADDR = 19'h4200;	// Position the graphics palette after the text palette

wire pc_enable = (pc_ena_in[3:0]==0);

wire host_gfx_data_out;	// host data outputs from the
wire host_txt_data_out;	// palette RAMs

wire host_wrena_txt;		// write enables to each
wire host_wrena_gfx;		// palette RAM
wire txt_addressed;
wire gfx_addressed;

wire [15:0] txt_pixel_out;
wire [3:0]  alpha_blend;
wire [7:0]  text_r;
wire [7:0]  text_g;
wire [7:0]  text_b;

wire [15:0] gfx_pixel_out;
wire [7:0]  graphics_r;
wire [7:0]  graphics_g;
wire [7:0]  graphics_b;

reg [9:0] hde_pipe, vde_pipe, hs_pipe, vs_pipe;	// passthru delay pipes
reg [7:0] pixel_r1, pixel_r2, pixel_g1, pixel_g2, pixel_b1, pixel_b2;
reg [47:0] HV_pipe[9:0];

assign alpha_blend = txt_pixel_out[15:12];
assign text_r[7:4] = txt_pixel_out[11:8];
assign text_r[3:0] = txt_pixel_out[11:8];
assign text_g[7:4] = txt_pixel_out[7:4];
assign text_g[3:0] = txt_pixel_out[7:4];
assign text_b[7:4] = txt_pixel_out[3:0];
assign text_b[3:0] = txt_pixel_out[3:0];

assign graphics_r[7:3] = gfx_pixel_out[15:11];
assign graphics_r[2:0] = gfx_pixel_out[15:13];
assign graphics_g[7:2] = gfx_pixel_out[10:5];
assign graphics_g[1:0] = gfx_pixel_out[10:9];
assign graphics_b[7:3] = gfx_pixel_out[4:0];
assign graphics_b[2:0] = gfx_pixel_out[4:2];

// write enables to either palette RAM only go high if addressed correctly during a write
assign txt_addressed = (host_addr_in[19:10] == TXT_PALETTE_ADDR[19:10]);
assign gfx_addressed = (host_addr_in[19:10] == GFX_PALETTE_ADDR[19:10]);
assign host_wrena_txt = host_wrena & txt_addressed;
assign host_wrena_gfx = host_wrena & gfx_addressed;

// route the palette data out to the host
assign host_data_out = host_txt_data_out | host_gfx_data_out;

// *********************************************************************
// *
// * create a text/sprite palette RAM instance (4444)
// *
// *********************************************************************
dual_port_palette_ram_INTEL text_palette_RAM(

	// inputs
	.clock_a(clk),
	.clock_b(clk),
	.pixel_addr_in(txt_pixel_in),
	.host_address(host_addr_in[8:0]),
	.data_a(2'h00),
	.host_data_in(host_data_in),
	.enable_a(pc_enable),
	.host_enable(1'b1),
	.rden_a(1'b1),
	.rden_b(1'b1),
	.wren_a(1'b0),
	.host_wren(host_wrena_txt),
	.sclr_n_rd_b(txt_addressed),
	
	// outputs
	.pixel_out(txt_pixel_out),
	.host_data_out(host_txt_data_out)

);

defparam text_palette_RAM.INIT_PALETTE = "palette_4444.mif";

// *********************************************************************
// *
// * create a graphics palette RAM instance (565)
// *
// *********************************************************************
dual_port_palette_ram_INTEL graphics_palette_RAM(

	// inputs
	.clock_a(clk),
	.clock_b(clk),
	.pixel_addr_in(gfx_pixel_in),
	.host_address(host_addr_in[8:0]),
	.data_a(2'h00),
	.host_data_in(host_data_in),
	.enable_a(pc_enable),
	.host_enable(1'b1),
	.rden_a(1'b1),
	.rden_b(1'b1),
	.wren_a(1'b0),
	.host_wren(host_wrena_gfx),
	.sclr_n_rd_b(gfx_addressed),
	
	// outputs
	.pixel_out(gfx_pixel_out),
	.host_data_out(host_gfx_data_out)

);

defparam graphics_palette_RAM.INIT_PALETTE = "palette_565.mif";

// *********************************************************************

always @(posedge clk) begin

	if (pc_ena_in[3:0] == 0) begin
		
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
		
		// mix output rgb
		pixel_r1		<= (text_r[7:0] * (15-alpha_blend[3:0])) >> 4;
		pixel_r2		<= (graphics_r[7:0] * alpha_blend[3:0]) >> 4;
		pixel_out_r <= pixel_r1 + pixel_r2;
		
		pixel_g1		<= (text_g[7:0] * (15-alpha_blend[3:0])) >> 4;
		pixel_g2		<= (graphics_g[7:0] * alpha_blend[3:0]) >> 4;
		pixel_out_g <= pixel_g1 + pixel_g2;
		
		pixel_b1		<= (text_b[7:0] * (15-alpha_blend[3:0])) >> 4;
		pixel_b2		<= (graphics_b[7:0] * alpha_blend[3:0]) >> 4;
		pixel_out_b <= pixel_b1 + pixel_b2;
		
	end

end

endmodule
