// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
// CREATED		"Thu Jul 02 15:51:25 2020"

module GPU(
	clk54m,
	uart_rxd,
	Z80_CLK,
	Z80_M1,
	Z80_MREQ,
	Z80_WR,
	Z80_RD,
	Z80_IORQ,
	IEI,
	Z80_RST,
	RESET_PIN,
	PS2_CLK,
	PS2_DAT,
	Z80_ADDR,
	hs,
	vs,
	uart_txd,
	LED_txd,
	LED_rdx,
	vde,
	245_OE,
	245_DIR,
	pixel_clk,
	Z80_INT_RQ,
	IEO,
	SPEAKER,
	EA_DIR,
	EA_OE,
	STATUS_LED,
	b,
	g,
	r,
	Z80_data
);

parameter	HW_REGS = 9;

input wire	clk54m;
input wire	uart_rxd;
input wire	Z80_CLK;
input wire	Z80_M1;
input wire	Z80_MREQ;
input wire	Z80_WR;
input wire	Z80_RD;
input wire	Z80_IORQ;
input wire	IEI;
input wire	Z80_RST;
input wire	RESET_PIN;
input wire	PS2_CLK;
input wire	PS2_DAT;
input wire	[21:0] Z80_ADDR;
output wire	hs;
output wire	vs;
output wire	uart_txd;
output wire	LED_txd;
output wire	LED_rdx;
output wire	vde;
output wire	245_OE;
output wire	245_DIR;
output wire	pixel_clk;
output wire	Z80_INT_RQ;
output wire	IEO;
output wire	SPEAKER;
output wire	EA_DIR;
output wire	EA_OE;
output wire	STATUS_LED;
output wire	[5:0] b;
output wire	[5:0] g;
output wire	[5:0] r;
inout wire	[7:0] Z80_data;

wire	[7:0] blue;
wire	clk;
wire	clk_2x;
wire	clk_2x_phase;
wire	com_clk;
wire	com_rst;
wire	[7:0] dat_to_Z80;
wire	data_en;
wire	[15:0] frame;
wire	GPU_HW_REGS_BUS;
wire	[7:0] green;
wire	[19:0] h_addr;
wire	[7:0] h_rdat;
wire	[7:0] h_wdat;
wire	h_wena;
wire	[7:0] key_dat;
wire	key_rdy;
wire	[7:0] out0;
wire	[7:0] out1;
wire	[7:0] out2;
wire	[7:0] out3;
wire	[3:0] pc_ena;
wire	[7:0] red;
reg	reset;
wire	[19:0] RS232_addr;
wire	RS232_rd_rdy;
wire	RS232_rd_req;
wire	[7:0] RS232_rDat;
wire	[7:0] RS232_wDat;
wire	RS232_wr_ena;
wire	SP_EN;
wire	video_en;
wire	[7:0] Z80_RD_data;
wire	Z80_rd_rdy;
wire	[7:0] Z80_WR_data;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	[7:0] SYNTHESIZED_WIRE_4;
wire	[7:0] SYNTHESIZED_WIRE_5;
wire	[7:0] SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	[19:0] SYNTHESIZED_WIRE_9;
wire	[7:0] SYNTHESIZED_WIRE_10;
reg	DFF_inst6;
wire	SYNTHESIZED_WIRE_11;
wire	[14:0] SYNTHESIZED_WIRE_12;
wire	[7:0] SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_23;
wire	SYNTHESIZED_WIRE_24;
wire	[47:0] SYNTHESIZED_WIRE_25;





vid_out_stencil	b2v_inst(
	.pclk(clk),
	.reset(reset),
	.hde_in(SYNTHESIZED_WIRE_0),
	.vde_in(SYNTHESIZED_WIRE_1),
	.hs_in(SYNTHESIZED_WIRE_2),
	.vs_in(SYNTHESIZED_WIRE_3),
	.b_in(SYNTHESIZED_WIRE_4),
	.g_in(SYNTHESIZED_WIRE_5),
	.pc_ena(pc_ena),
	.r_in(SYNTHESIZED_WIRE_6),
	
	
	.hs_out(hs),
	.vs_out(vs),
	.vid_de_out(SYNTHESIZED_WIRE_15),
	.b_out(blue),
	.g_out(green),
	.r_out(red));
	defparam	b2v_inst.HS_invert = 1;
	defparam	b2v_inst.RGB_hbit = 7;
	defparam	b2v_inst.VS_invert = 1;


GPU_HW_Control_Regs	b2v_inst1(
	.rst(reset),
	.clk(clk),
	.we(h_wena),
	.addr_in(h_addr),
	.data_in(h_wdat),
	
	.GPU_HW_Control_regs(GPU_HW_REGS_BUS));
	defparam	b2v_inst1.BASE_WRITE_ADDRESS = 0;
	defparam	b2v_inst1.HW_REGS_SIZE = 9;
	defparam	b2v_inst1.RST_VALUES0 = A(0,16,0,16,2,143,1,239,0,0,0,0,0,0,0,0,0,16,1,144,0,16,0,16,0,135,0,56,0,16,0,16);
	defparam	b2v_inst1.RST_VALUES1 = A(2,68,0,16,0,140,0,134,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16);
	defparam	b2v_inst1.RST_VALUES2 = A(0,16,0,16,0,16,0,16,0,16,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	defparam	b2v_inst1.RST_VALUES3 = A(128,16,0,0,18,0,0,80,2,127,1,223,0,240,0,0,72,0,15,0,2,0,0,0,0,0,0,0,0,1,0,0);
	defparam	b2v_inst1.RST_VALUES4 = A(132,16,0,0,28,169,0,80,1,63,0,239,1,241,0,0,76,0,15,0,2,0,0,0,0,0,0,0,0,1,0,0);
	defparam	b2v_inst1.RST_VALUES5 = A(9,0,0,0,96,0,0,19,0,75,0,91,0,0,0,0,26,16,0,0,51,0,0,96,0,191,0,119,1,1,0,0);


data_mux	b2v_inst10(
	.clk(clk),
	.reset(reset),
	.wr_ena_a(SYNTHESIZED_WIRE_7),
	.rd_req_a(SYNTHESIZED_WIRE_8),
	.wr_ena_b(RS232_wr_ena),
	.rd_req_b(RS232_rd_req),
	.address_a(SYNTHESIZED_WIRE_9),
	.address_b(RS232_addr),
	.data_in_a(SYNTHESIZED_WIRE_10),
	.data_in_b(RS232_wDat),
	.gpu_data_in(h_rdat),
	.gpu_wr_ena(h_wena),
	.gpu_rd_rdy_a(Z80_rd_rdy),
	.gpu_rd_rdy_b(RS232_rd_rdy),
	.data_out_a(dat_to_Z80),
	.data_out_b(RS232_rDat),
	.gpu_address(h_addr),
	.gpu_data_out(h_wdat));
	defparam	b2v_inst10.READ_CLOCK_CYCLES = 2;


exp	b2v_inst11(
	.in(DFF_inst6),
	.out(clk_2x_phase));

assign	Z80_WR_data[7] = data_en ? Z80_RD_data[7] : 1'bz;
assign	Z80_WR_data[6] = data_en ? Z80_RD_data[6] : 1'bz;
assign	Z80_WR_data[5] = data_en ? Z80_RD_data[5] : 1'bz;
assign	Z80_WR_data[4] = data_en ? Z80_RD_data[4] : 1'bz;
assign	Z80_WR_data[3] = data_en ? Z80_RD_data[3] : 1'bz;
assign	Z80_WR_data[2] = data_en ? Z80_RD_data[2] : 1'bz;
assign	Z80_WR_data[1] = data_en ? Z80_RD_data[1] : 1'bz;
assign	Z80_WR_data[0] = data_en ? Z80_RD_data[0] : 1'bz;

assign	RS232_wr_ena = SYNTHESIZED_WIRE_11;


assign	RS232_addr[14:0] = SYNTHESIZED_WIRE_12;


assign	RS232_wDat = SYNTHESIZED_WIRE_13;



sound	b2v_inst16(
	.clk(clk),
	.enable(SP_EN),
	.speaker(SPEAKER));


altpll0	b2v_inst17(
	.inclk0(clk54m),
	.c0(clk),
	.c1(clk_2x),
	.c2(com_clk),
	.c3(SYNTHESIZED_WIRE_19));


Z80_bridge	b2v_inst18(
	.reset(reset),
	.GPU_CLK(clk),
	.Z80_CLK(Z80_CLK),
	.Z80_M1n(Z80_M1),
	.Z80_MREQn(Z80_MREQ),
	.Z80_WRn(Z80_WR),
	.Z80_RDn(Z80_RD),
	.gpu_rd_rdy(Z80_rd_rdy),
	.sel_pclk(out3[7]),
	.sel_nclk(out3[6]),
	.PS2_RDY(key_rdy),
	.Z80_IORQn(Z80_IORQ),
	.Z80_IEI(IEI),
	.gpu_rData(dat_to_Z80),
	.PS2_DAT(key_dat),
	.Z80_addr(Z80_ADDR),
	.Z80_wData(Z80_WR_data),
	.Z80_245data_dir(245_DIR),
	.Z80_rData_ena(data_en),
	.Z80_245_oe(245_OE),
	.gpu_wr_ena(SYNTHESIZED_WIRE_7),
	.gpu_rd_req(SYNTHESIZED_WIRE_8),
	.Z80_INT_REQ(Z80_INT_RQ),
	.Z80_IEO(IEO),
	.EA_DIR(EA_DIR),
	.EA_OE(EA_OE),
	.SPKR_EN(SP_EN),
	.VIDEO_EN(video_en),
	.gpu_addr(SYNTHESIZED_WIRE_9),
	.gpu_wdata(SYNTHESIZED_WIRE_10),
	.Z80_rData(Z80_RD_data));
	defparam	b2v_inst18.BANK_ID = A(9,3,71,80,85,32,69,80,52,67,69,49,48,0,255,255);
	defparam	b2v_inst18.BANK_ID_ADDR = 17'b10111111111111111;
	defparam	b2v_inst18.BANK_RESPONSE = 1;
	defparam	b2v_inst18.data_in = 0;
	defparam	b2v_inst18.data_out = 1;
	defparam	b2v_inst18.GPU_SOCKET = 3'b010;
	defparam	b2v_inst18.INT_TYP = 0;
	defparam	b2v_inst18.INT_VEC = 8'b00110000;
	defparam	b2v_inst18.IO_BLNK = 243;
	defparam	b2v_inst18.IO_DATA = 240;
	defparam	b2v_inst18.IO_SPKR = 242;
	defparam	b2v_inst18.KEY_DELAY = 25000000;
	defparam	b2v_inst18.MEM_SIZE_BITS = 15;
	defparam	b2v_inst18.MEMORY_RANGE = 3'b010;

assign	SYNTHESIZED_WIRE_17 = com_rst | SYNTHESIZED_WIRE_14;


sync_generator	b2v_inst2(
	.pclk(clk),
	.reset(reset),
	.GPU_HW_Control_regs(GPU_HW_REGS_BUS),
	.hde(SYNTHESIZED_WIRE_21),
	.vde(SYNTHESIZED_WIRE_22),
	.hsync(SYNTHESIZED_WIRE_23),
	.vsync(SYNTHESIZED_WIRE_24),
	.frame_ctr(frame),
	.pc_ena(pc_ena),
	.raster_HV_triggers(SYNTHESIZED_WIRE_25));
	defparam	b2v_inst2.BASE_OFFSET = 0;
	defparam	b2v_inst2.H_BACK_PORCH = 48;
	defparam	b2v_inst2.H_FRONT_PORCH = 16;
	defparam	b2v_inst2.H_RES = 640;
	defparam	b2v_inst2.HSYNC_WIDTH = 96;
	defparam	b2v_inst2.HW_REGS_SIZE = 9;
	defparam	b2v_inst2.IMAGE_OFFSET_X = 16;
	defparam	b2v_inst2.IMAGE_OFFSET_Y = 16;
	defparam	b2v_inst2.PIX_CLK_DIVIDER = 4;
	defparam	b2v_inst2.V_BACK_PORCH = 33;
	defparam	b2v_inst2.V_FRONT_PORCH = 10;
	defparam	b2v_inst2.V_RES = 480;
	defparam	b2v_inst2.VSYNC_HEIGHT = 2;

assign	vde = SYNTHESIZED_WIRE_15 & video_en;

assign	SYNTHESIZED_WIRE_20 = SYNTHESIZED_WIRE_16 | SYNTHESIZED_WIRE_17;


status_LED	b2v_inst22(
	.clk(clk),
	.LED(STATUS_LED));
	defparam	b2v_inst22.div = 2;


exp	b2v_inst23(
	.in(Z80_RST),
	.out(SYNTHESIZED_WIRE_16));



rs232_debugger	b2v_inst3(
	.clk(clk),
	.rxd(uart_rxd),
	.host_rd_rdy(RS232_rd_rdy),
	.host_rdata(RS232_rDat),
	.in0(frame[15:8]),
	.in1(frame[7:0]),
	.in2(key_dat),
	
	.cmd_rst(com_rst),
	.txd(uart_txd),
	.LED_txd(LED_txd),
	.LED_rxd(LED_rdx),
	.host_rd_req(SYNTHESIZED_WIRE_18),
	.host_wr_ena(SYNTHESIZED_WIRE_11),
	.host_addr(SYNTHESIZED_WIRE_12),
	.host_wdata(SYNTHESIZED_WIRE_13),
	
	
	
	.out3(out3));
	defparam	b2v_inst3.ADDR_SIZE = 15;
	defparam	b2v_inst3.BAUD_RATE = 921600;
	defparam	b2v_inst3.CLK_IN_HZ = 125000000;


exp	b2v_inst4(
	.in(RESET_PIN),
	.out(SYNTHESIZED_WIRE_14));

assign	RS232_rd_req = SYNTHESIZED_WIRE_18;



always@(posedge clk_2x)
begin
	begin
	DFF_inst6 <= SYNTHESIZED_WIRE_19;
	end
end


ps2_keyboard_to_ascii	b2v_inst7(
	.clk(com_clk),
	.ps2_clk(PS2_CLK),
	.ps2_data(PS2_DAT),
	.ascii_new(key_rdy),
	.ascii_code(key_dat[6:0]));
	defparam	b2v_inst7.clk_freq = 50000000;
	defparam	b2v_inst7.ps2_debounce_counter_size = 11;


always@(posedge clk)
begin
	begin
	reset <= SYNTHESIZED_WIRE_20;
	end
end


vid_osd_generator	b2v_inst9(
	.clk_2x(clk_2x),
	.clk_2x_phase(clk_2x_phase),
	.clk(clk),
	.hde_in(SYNTHESIZED_WIRE_21),
	.vde_in(SYNTHESIZED_WIRE_22),
	.hs_in(SYNTHESIZED_WIRE_23),
	.vs_in(SYNTHESIZED_WIRE_24),
	.host_clk(clk),
	.host_wr_ena(h_wena),
	.GPU_HW_Control_regs(GPU_HW_REGS_BUS),
	.host_addr(h_addr),
	.host_wr_data(h_wdat),
	.HV_triggers_in(SYNTHESIZED_WIRE_25),
	.pc_ena(pc_ena),
	.hde_out(SYNTHESIZED_WIRE_0),
	.vde_out(SYNTHESIZED_WIRE_1),
	.hs_out(SYNTHESIZED_WIRE_2),
	.vs_out(SYNTHESIZED_WIRE_3),
	.blue(SYNTHESIZED_WIRE_4),
	.green(SYNTHESIZED_WIRE_5),
	.host_rd_data(h_rdat),
	
	.red(SYNTHESIZED_WIRE_6));
	defparam	b2v_inst9.ADDR_SIZE = 15;
	defparam	b2v_inst9.GPU_RAM_MIF = "GPU_MIF_CE10_10M.mif";
	defparam	b2v_inst9.HW_REGS_SIZE = 9;
	defparam	b2v_inst9.NUM_LAYERS = 9;
	defparam	b2v_inst9.NUM_WORDS = 31743;
	defparam	b2v_inst9.PALETTE_ADDR = 31744;
	defparam	b2v_inst9.PIPE_DELAY = 11;

assign	Z80_data = Z80_WR_data;
assign	pixel_clk = clk;
assign	b[5:0] = blue[7:2];
assign	g[5:0] = green[7:2];
assign	r[5:0] = red[7:2];
assign	key_dat[7] = 0;

endmodule
