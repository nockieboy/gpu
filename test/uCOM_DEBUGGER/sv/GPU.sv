module GPU(

   // ****** INPUTS ******
   //input logic        clk54m,
   input logic          uart_rxd,
   input logic          Z80_CLK,
   input logic          Z80_M1,
   input logic          Z80_MREQ,
   input logic          Z80_WR,
   input logic          Z80_RD,
   input logic          Z80_IORQ,
   input logic          IEI,
   input logic          Z80_RST,
   input logic          RESET_PIN,
   input logic          clk,
   input logic          clk_2x,
   //input logic          clk_2x_phase,
   input logic          com_clk,
   input logic          Z80_WAIT_IN,
   input logic          gpu_rd_rdy,
   input logic  [7:0]   gpu_rData,
   input logic  [21:0]  Z80_ADDR,
   
   // ****** BIDIR IO ******
   inout logic          PS2_CLK,
   inout logic          PS2_DAT,
   inout logic  [7:0]   Z80_data,


	

   // ****** RS232 Debugger Write data through to GPU FPGA Block Ram  ******
	input logic          DEBUG_WE  ,
	input logic  [21:0]  DEBUG_ADDR,
	input logic  [7:0]   DEBUG_DATA,
	input logic          DEBUG_VIDON,



	
   // ****** OUTPUTS ******
   output reg           hs,
   output reg           vs,
   /*
   output reg           uart_txd,
   output reg           LED_txd,
   output reg           LED_rdx,
   */
   output reg           vde,
   output reg           pixel_clk,
   output logic         Z80_INT_RQ,
   output logic         Z80_WAIT,
   output logic         IEO,
   output logic         SPEAKER,
   output logic         EA_DIR,
   output logic         EA_OE,
   output logic         STATUS_LED,
   output logic         DIR_245,
   output logic         OE_245,
   //output logic        reset_status; // debugging
   output reg   [7:0]   b,
   output reg   [7:0]   g,
   output reg   [7:0]   r,
   output logic [19:0]  gpu_addr,
   output logic [7:0]   gpu_wdata,
   output logic         gpu_wr_ena,
   output logic         gpu_rd_req
   
);

parameter int  GPU_MEM   = 98304 ; // Defines total video RAM in the FPGA, including 1KB palette (98304)
                                   // For EP4CE10, use 41984
parameter int  HW_REGS   = 9     ;
parameter int  MAGGIES   = 9     ; // Number of MAGGIE layers available to GPU

parameter int  GPU_RS232 = 0     ; // 1 = compile internal RS232 debugger, 0 = use one in top-level file

wire  [7:0]    blue;
//wire   clk;
//wire   clk_2x;
wire   clk_2x_phase;
//wire   com_clk;
//wire           clk_2x_ph;
wire  [7:0]    collision_rd;
wire  [7:0]    collision_wr;
wire  [7:0]    dat_to_Z80;
wire           data_en;
wire  [15:0]   frame;
wire  [15:0]   geo_cmd;
wire           geo_port_full;
wire  [15:0]   geo_r_data;
wire  [19:0]   geo_ram_addr;
wire           geo_rd_req_a;
wire           geo_rd_req_b;
wire           geo_rdy_a;
wire           geo_rdy_b;
wire  [7:0]    geo_stat_rd;
wire  [7:0]    geo_stat_wr;
wire  [15:0]   geo_wr_data;
wire           geo_wr_ena;
wire  [7:0]    GPU_HW_REGS_BUS [0:2**HW_REGS-1];
wire  [7:0]    green;
wire           h_16bit;
wire  [19:0]   h_addr;
wire  [15:0]   h_rdat;
wire  [15:0]   h_wdat;
wire           h_wena;
wire           hse;
wire  [7:0]    key_dat;
wire  [7:0]    out0;
wire  [7:0]    out1;
wire  [7:0]    out2;
wire  [7:0]    out3;
wire  [3:0]    pc_ena;
wire           PS2_DAT_RDY = 0;
wire  [7:0]    ps2STAT = 0;
wire           rd_px_ctr_rs;
wire  [7:0]    red;
reg            reset;
wire  [7:0]    rx_code;
wire           send_geo_cmd;
wire  [8:0]    snd_data;
wire           snd_data_tx;
wire           SP_EN;
wire           video_en;
wire           vse;
wire           wr_px_ctr_rs;
wire  [7:0]    Z80_RD_data;
wire           Z80_rd_rdy;
//wire  [7:0]    Z80_WR_data;
wire           osd_hs_out;
wire           osd_vs_out;
wire  [7:0]    SYNTHESIZED_WIRE_2;
wire  [7:0]    SYNTHESIZED_WIRE_3;
wire  [7:0]    SYNTHESIZED_WIRE_4;
reg   [7:0]    DFF_inst33;
//reg            DFF_inst6;
wire           ps2_tx_data_in;
wire  [0:7]    ps2_data_in;
wire           INV_RESET_DFF;
wire           stencil_de_out;
wire           SYNTHESIZED_WIRE_9;
wire           SYNTHESIZED_WIRE_10;
reg            DFF_inst41;
wire           gpu_wr_enable;
wire           gpu_rd_request;
//wire  [19:0] gpu_addr;
//wire  [7:0]  gpu_wdata;
reg            DFF_inst26;
wire           SYNTHESIZED_WIRE_15;
wire           SYNTHESIZED_WIRE_16;
wire           SYNTHESIZED_WIRE_17;
wire           stencil_vs_out;
reg            DFF_inst8;
wire           stencil_hs_out;
wire           stencil_vid_clk;
wire           hde_wire;
wire           vde_wire;
wire           hsync_wire;
wire           vsync_wire;
wire  [47:0]   raster_HV_triggers;
reg            DFF_inst32;

/*
reg            DFF_inst51;
wire           com_rst;
wire  [19:0]   RS232_addr;
wire           RS232_rd_rdy;
wire           RS232_rd_req;
wire  [7:0]    RS232_rDat;
wire  [7:0]    RS232_wDat;
wire           RS232_wr_ena;
wire           RS232_TX;
wire           RS232_LED_TX;
wire           RS232_LED_RX;
*/

// **********************************************
//      Connect wires to GPU_DECA_DDR3_top
// **********************************************
assign gpu_wr_ena = gpu_wr_enable  ;
assign gpu_rd_req = gpu_rd_request ;

// **********************************************


GPU_HW_Control_Regs  HW_CTRL(
   
   // ****** INPUTS *******
   .clk                 ( clk            ), // 125 MHz clock from the DDR3_Controller in GPU_DECA_DDR3_top.
   .rst                 ( reset          ), // reset is a combined signal of the GPU's RESET button, OR'd with Z80_RST
   .we                  ( h_wena         ), // Active HIGH when WRiting to GPU_HW_Control_Regs.
   .addr_in             ( h_addr         ), // 20-bit address bus, from data_mux_geo.
   .data_in             ( h_wdat[7:0]    ), // Lower 8-bits of 16-bit data bus from data_mux_geo.
   
   // ****** OUTPUTS *******
   .GPU_HW_Control_regs ( GPU_HW_REGS_BUS),
   .data_out            (                )
   
);
   defparam HW_CTRL.BASE_WRITE_ADDRESS = 0                                                                                    ;
   defparam HW_CTRL.HW_REGS_SIZE       = HW_REGS                                                                              ;
   defparam HW_CTRL.RST_VALUES0        = '{0,16,0,16,2,143,1,239,0,0,0,0,0,0,0,0,0,16,1,144,0,16,0,16,0,135,0,56,0,16,0,16}   ;
   defparam HW_CTRL.RST_VALUES1        = '{2,68,0,16,0,140,0,134,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16,0,16} ;
   defparam HW_CTRL.RST_VALUES2        = '{0,16,0,16,0,16,0,16,0,16,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}             ;
   defparam HW_CTRL.RST_VALUES3        = '{128,16,0,0,18,0,0,80,2,127,1,223,0,240,0,0,72,0,15,0,2,0,0,0,0,0,0,0,0,1,0,0}      ;
   defparam HW_CTRL.RST_VALUES4        = '{132,16,0,0,28,169,0,80,1,63,0,239,1,241,0,0,76,0,15,0,2,0,0,0,0,0,0,0,0,1,0,0}     ;
   defparam HW_CTRL.RST_VALUES5        = '{9,0,0,0,96,0,0,19,0,75,0,91,0,0,0,0,26,16,0,0,51,0,0,96,0,191,0,119,1,1,0,0}       ;




// ***************************************************************************************************************
// ***************************************************************************************************************
// *** Z80 Bridge ************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
Z80_bridge_v2  Z80_BRIDGE(

   // ***********************************
   // *** Core System Clock and Reset ***
   // ***********************************
   .GPU_CLK           ( clk            ), // 125 MHz clock signal from the DDR3_Controller in GPU_DECA_DDR3_top.
   .reset             ( reset          ), // reset is a combined signal of the GPU's RESET button, OR'd with Z80_RST.
   //.sel_pclk          ( out3[7]        ), // *** THIS SIGNAL IS NOT USED IN Z80_BRIDGE.
   //.sel_nclk          ( out3[6]        ), // *** THIS SIGNAL IS NOT USED IN Z80_BRIDGE.



   // ***********************************
   // *** Z80 bus control connections ***
   // ***********************************
   .Z80_CLK           ( Z80_CLK        ), // Z80 host's clock signal (8 MHz default).
   .Z80_M1n           ( Z80_M1         ), // Z80 M1 goes LOW with MREQ to signal Z80 Machine Cycle 1 (opcode fetch).
                                          // Z80 M1 goes LOW with IORQ to signal an interrupt acknowledge (INTACK).
   .Z80_MREQn         ( Z80_MREQ       ), // Z80 MREQ goes LOW when Z80 is performing a memory operation.
   .Z80_WRn           ( Z80_WR         ), // Z80 WR goes LOW when Z80 is performing a WRite operation.
   .Z80_RDn           ( Z80_RD         ), // Z80 RD goes LOW to signal a Z80 ReaD operation.
   .Z80_IORQn         ( Z80_IORQ       ), // Z80 IORQ goes LOW when Z80 is performing an IO operation.
   .Z80_IEI           ( IEI            ), // NOT USED, Z80 INTerrupt daisy chain input - active LOW, prevents Z80_bridge from raising an INTerrupt request.
   .Z80_addr          ( Z80_ADDR       ), // Z80 address bus (22-bit).

   // *** Z80 bidir data bus and bus steering connections. ***
   .Z80_rData_ena_r   ( data_en        ), // Controls direction of the Z80 data bus bidir IO pins on the FPGA.
   .Z80_wData         ( Z80_data       ), // Data from Z80 to GPU FPGA.
   .Z80_rData_r       ( Z80_RD_data    ), // Data from GPU FPGA to Z80.

   .Z80_245_oe_r      ( OE_245         ), // Enable/disable signal for Z80 data bus buffer.
   .Z80_245data_dir_r ( DIR_245        ), // Controls direction of the Z80 data bus buffer.

   // *** Z80 interrupt and wait controls ***
   .Z80_INT_REQ_r     ( Z80_INT_RQ     ), // Active HIGH, signals to Z80 an INTerrupt request.
   .Z80_WAIT          ( Z80_WAIT       ), // Active HIGH, signals to Z80 to WAIT.
   .Z80_IEO_r         ( IEO            ), // NOT USED, Active LOW, prevents devices further down the daisy chain from requesting INTerrupts.

   // *** Extended Address (EA) bus steering connections ***
   .EA_DIR_r          ( EA_DIR         ), // Controls direction of the EA bus buffer.
   .EA_OE_r           ( EA_OE          ), // Enable/disable signal for EA bus buffer.
                                          // The EA bus direction control should default to Z80 > FPGA direction.
                                          // These controls are present for a future FPGA MMU to replace the hardware MMU on the memory card, or
                                          // for EA bus control by an optional FPGA CPU core.
   

   // ******************************
   // *** Z80 <-> GPU RAM Access ***
   // ******************************
   .gpu_addr          ( gpu_addr       ), // 20-bit memory address pointer.

   .gpu_wr_ena        ( gpu_wr_enable  ), // Write byte request output.
   .gpu_wdata         ( gpu_wdata      ), // 8 bit data byte to be written to GPU RAM.

   .gpu_rd_req        ( gpu_rd_request ), // OUTPUT: Read byte request.
   .gpu_rd_rdy        ( gpu_rd_rdy     ), // INPUT:  Read request data byte is ready / valid input.
   .gpu_rData         ( gpu_rData      ), // INPUT:  Read request GPU RAM returned 8 bit data byte.



   // *******************************
   // *** Z80 peripheral IO ports ***
   // *******************************

   // *** Enable/Disable video output port.
   .VIDEO_EN          ( video_en       ), // Active HIGH, enables video output.

   // *** PS2 keyboard IO.
   .PS2_STATUS        ( DFF_inst33     ), // 8-bit PS/2 STATUS bus.
   .PS2_DAT           ( key_dat        ), // Keycode/ASCII data bus from the PS/2 terminal.
   .PS2_RDY           ( PS2_DAT_RDY    ), // Active HIGH, signals Z80_bridge valid data is available from the PS/2 keyboard interface.

   // *** Speaker
   .SPKR_EN           ( SP_EN          ), // Active HIGH, enables sound output via the sound module.
   .snd_data_tx       ( snd_data_tx    ), // Active HIGH, signals sound module that valid data is available on the snd_data bus.
   .snd_data          ( snd_data       ), // 8-bit data bus to the sound module.

   // 2D accelerated Geometry unit IO access.
   .GEO_STAT_RD       ( geo_stat_rd    ), // 8-bit data_mux_geo STATUS bus.  bit 0 = scfifo-almost-full flag, other bits free for other data.
   //.GEO_STAT_WR       ( geo_stat_wr    ), // Bit 0 is used to soft-reset the geometry unit.

   .GEO_WR_HI_STROBE  ( send_geo_cmd   ), // Active HIGH, signals GEOFF that valid 16-bit data is available on geo_cmd bus.
   .GEO_WR_HI         ( geo_cmd[15:8]  ), // MSB in geo_cmd bus.
   .GEO_WR_LO         ( geo_cmd[7:0]   ), // LSB in geo_cmd bus.

   .RD_PX_CTR         ( collision_rd   ), // COPY READ PIXEL collision counter from pixel_writer.
   .WR_PX_CTR         ( collision_wr   ), // WRITE PIXEL     collision counter from pixel_writer.
   .RD_PX_CTR_STROBE  ( rd_px_ctr_rs   ), // Active HIGH, signals GEOFF to reset READ PIXEL  collision counter.
   .WR_PX_CTR_STROBE  ( wr_px_ctr_rs   )  // Active HIGH, signals GEOFF to reset WRITE PIXEL collision counter.

);
   defparam Z80_BRIDGE.BANK_ID          = '{9,3,71,80,85,32,77,65,88,49,48,0,255,255,255,255} ;  // The BANK_ID data to return ('GPU MAX10')
   defparam Z80_BRIDGE.BANK_ID_ADDR     = 17'b10111111111111111 ; // Address to return BANK_ID data from
   defparam Z80_BRIDGE.BANK_RESPONSE    = 1       ; // 1 - respond to reads at BANK_ID_ADDR with BANK_ID data, 0 - ignore reads to that address
   defparam Z80_BRIDGE.MEM_SIZE_BYTES   = GPU_MEM ; // Specifies size of GPU RAM available to host (anything above this returns $FF)
   defparam Z80_BRIDGE.MEMORY_RANGE     = 3'b010  ; // Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the uCom)
   defparam Z80_BRIDGE.data_in          = 1'b0    ; // Direction controls for 74LVC245 buffers - hardware dependent!
   defparam Z80_BRIDGE.data_out         = 1'b1    ; // Direction controls for 74LVC245 buffers - hardware dependent!
   defparam Z80_BRIDGE.INT_TYP          = 0       ; // 0 = polled (IO), 1 = interrupt.
   defparam Z80_BRIDGE.INT_VEC          = 48      ; // INTerrupt VECtor to be passed to host in event of an interrupt acknowledge.
   defparam Z80_BRIDGE.INV_Z80_CLK      = 0       ; // Invert the source Z80 clk when considering a bus transaction.
   defparam Z80_BRIDGE.USE_Z80_CLK      = 1       ; // use 1 to wait for a Z80 clk input before considering a bus transaction.
   defparam Z80_BRIDGE.IO_DATA          = 240     ; // IO address for keyboard data polling.
   defparam Z80_BRIDGE.IO_STAT          = 241     ; // IO address for keyboard status polling.
   defparam Z80_BRIDGE.SND_OUT          = 242     ; // IO address for speaker/audio output enable.
   defparam Z80_BRIDGE.IO_BLNK          = 243     ; // IO address for BLANK signal to video DAC.
   defparam Z80_BRIDGE.SND_TON          = 244     ; // IO address for TONE register in sound module.
   defparam Z80_BRIDGE.SND_DUR          = 245     ; // IO address for DURATION register in sound module.
   defparam Z80_BRIDGE.GEO_LO           = 246     ; // IO address for GEOFF LOW byte.
   defparam Z80_BRIDGE.GEO_HI           = 247     ; // IO address for GEOFF HIGH byte.
   defparam Z80_BRIDGE.FIFO_STAT        = 248     ; // IO address for GPU FIFO status on bit 0 - remaining bits free for other data.
   defparam Z80_BRIDGE.Z80_CLK_FILTER   = 0       ; // The number of GPU clock cycles to filter the Z80 bus commands, use 0 through 7.
   defparam Z80_BRIDGE.Z80_CLK_FILTER_P = 2       ; // The number of GPU clock cycles to filter the Z80 bus PORT commands, use 0 through 7.


// ***************************************************************************************************************
// ***************************************************************************************************************
// *** Data Mux Geo **********************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
data_mux_geo   DATA_MUX(

   // ***********************************
   // *** Core System Clock and Reset ***
   // ***********************************
   .clk           ( clk            ), // 125 MHz clock signal from the DDR3_Controller in GPU_DECA_DDR3_top.
   .reset         ( reset          ), // reset is a combined signal of the GPU's RESET button, OR'd with Z80_RST.
   
   
   
   // ************************************
   // ***    Z80 INPUTS TO DATA MUX    ***
   // ************************************
   .address_a     ( gpu_addr       ), // 20-bit address bus from Z80_Bridge module.
   .data_in_a     ( gpu_wdata      ), // 8-bit  WRITE data bus from the Z80_Bridge module.
   //.rd_req_a      ( gpu_rd_request ), // When HIGH, Z80_Bridge is signalling a valid address on address_a input and requesting a READ to the Z80.
   .rd_req_a      ( 1'b0           ), // ******** Disconnect Z80_Bridge read requests from data_mux_geo
   .wr_ena_a      ( gpu_wr_enable  ), // When HIGH, Z80_Bridge is signalling valid WRite data on the data_in_a bus.
   // ************************************
   // ***   DATA MUX OUTPUTS TO Z80    ***
   // ************************************
   .gpu_rd_rdy_a  ( Z80_rd_rdy     ), // Active HIGH, connects to gpu_rd_rdy in Z80_Bridge to signal valid data on dat_to_z80 bus.
                                      // and valid address on address_a inputs for WRITE op from host Z80.
   .data_out_a    ( dat_to_Z80     ), // 8-bit data bus,  connects to gpu_rData in Z80_bridge to return READ data to the Z80.
   
   
   
   // ************************************
   // ***   RS232 INPUTS TO DATA MUX   ***
   // ************************************
   .address_b     ( DEBUG_ADDR     ), // 20-bit address bus from RS232_debugger module.
   .data_in_b     ( DEBUG_DATA     ), // 8-bit  WRITE data bus from the RS232_debugger module.
   .rd_req_b      ( 1'b0           ), // When HIGH, RS232 is signalling a valid address on address_b input and requesting a READ to RS232 port.
   .wr_ena_b      ( DEBUG_WE       ), // When HIGH, RS232 is signalling valid WRite data on the data_in_b bus
                                      // and valid address on address_b inputs for WRITE op from RS232 debug port
   // ************************************
   // ***  DATA MUX OUTPUTS TO RS232   ***
   // ************************************
   .gpu_rd_rdy_b  ( 1'b0           ), // Active HIGH, connects to host_rd_rdy in rs232_debugger to signal valid data on RS232_rDat bus.
   .data_out_b    (                ), // 8-bit data bus,  connects to host_rdata in rs232_debugger to return READ data to the Z80.
   
   
   
   // ************************************
   // ***   GEOFF INPUTS TO DATA_MUX   ***
   // ************************************
   .address_geo   ( geo_ram_addr   ), // 20-bit address bus from GEOFF (geometry_processor module).
   .data_in_geo   ( geo_wr_data    ), // 16-bit WRITE data bus from GEOFF.
   .geo_rd_req_a  ( geo_rd_req_a   ), // When HIGH, GEOFF is signalling a valid address on address_geo input and requesting a READ to GEOFF_A.
   .geo_rd_req_b  ( geo_rd_req_b   ), // When HIGH, GEOFF is signalling a valid address on address_geo input and requesting a READ to GEOFF_B.
   .geo_wr_ena    ( geo_wr_ena     ), // When HIGH, GEOFF is signalling valid WRite data on the data_in_geo bus
                                      // and valid address on address_geo inputs for WRITE op from the geometry processor.
   // ************************************
   // ***  DATA MUX OUTPUTS TO GEOFF   ***
   // ************************************
   .geo_rd_rdy_a  ( geo_rdy_a      ), // Active HIGH, connects to rd_data_rdy_a in geometry_processor and signals valid data on data_out_a bus.
   .geo_rd_rdy_b  ( geo_rdy_b      ), // Active HIGH, connects to rd_data_rdy_b in geometry_processor and signals valid data on data_out_b bus.
   .geo_port_full ( geo_port_full  ), // Active HIGH, connects to ram_mux_busy in geometry_processor to signal FIFO full, don't send any more requests.
   .data_out_geo  ( geo_r_data     ), // 16-bit data bus, connects to rd_data_in in geometry_processor to return READ data to GEOFF.
   
   
                                      
   // *************************************
   // *** DATA MUX INPUT FROM BLOCK RAM ***
   // *************************************
   .gpu_data_in   ( h_rdat         ), // 16-bit READ data bus from vid_osd_generator module (where the FPGA's internal block RAM is handled).
   // ************************************
   // *** DATA MUX OUTPUT TO BLOCK RAM ***
   // ************************************
   .gpu_address   ( h_addr         ), // 20-bit address bus, connects to sixteen_port_gpu_ram via host_addr in vid_osd_generator, and GPU_HW_Control_Regs.
   .gpu_data_out  ( h_wdat         ), // 16-bit data bus, connects to sixteen_port_gpu_ram via host_wr_data in vid_osd_generator, and GPU_HW_Control_Regs.
   .gpu_wr_ena    ( h_wena         ), // Active HIGH when WRiting to FPGA block RAM via vid_osd_generator module, and GPU_HW_Control_Regs.
   .gpu_ena_16bit ( h_16bit        )  // Active HIGH, passed-through to sixteen_port_gpu_ram in vid_osd_generator to enable 16-bit transfers.

);
   defparam DATA_MUX.GEO_ENDIAN_SWAP   = 1'b1 ;
   defparam DATA_MUX.READ_CLOCK_CYCLES = 2    ;
   defparam DATA_MUX.REGISTER_GPU_PORT = 1'b1 ;
   defparam DATA_MUX.REGISTER_INA      = 1'b1 ;
   defparam DATA_MUX.REGISTER_INB      = 1'b1 ;


sync_generator SYNC_GEN(

   // ****** INPUTS *******
   .pclk                ( clk                ), // 125 MHz clock signal from the DDR3_Controller in GPU_DECA_DDR3_top.
   .reset               ( reset              ), // reset is a combined signal of the GPU's RESET button, OR'd with Z80_RST.
   .GPU_HW_Control_regs ( GPU_HW_REGS_BUS    ), // Connected to output from GPU_HW_Control_Regs module.
   
   // ****** OUTPUTS ******
   .hde                 ( hde_wire           ), // Horizontal Display Enable - high when in display area (valid drawing area)
   .vde                 ( vde_wire           ), // Vertical Display Enable - high when in display area (valid drawing area)
   .hsync               ( hsync_wire         ), // horizontal sync
   .vsync               ( vsync_wire         ), // vertical sync
   .pc_ena              ( pc_ena             ), // Pixel clock enable (4-bit bus)
   .raster_HV_triggers  ( raster_HV_triggers )  // 48-bit bus containing H&V sync and top left window coordinates,
                                                // passed directly to MAGGIEs in vid_osd_generator.
);
   defparam SYNC_GEN.BASE_OFFSET     = 0   ;
   defparam SYNC_GEN.HW_REGS_SIZE    = 9   ;
   defparam SYNC_GEN.PIX_CLK_DIVIDER = 4   ;

   defparam SYNC_GEN.IMAGE_OFFSET_X  = 16  ;
   defparam SYNC_GEN.IMAGE_OFFSET_Y  = 16  ;
   defparam SYNC_GEN.H_BACK_PORCH    = 48  ;
   defparam SYNC_GEN.H_FRONT_PORCH   = 16  ;
   defparam SYNC_GEN.H_RES           = 640 ;
   defparam SYNC_GEN.HSYNC_WIDTH     = 96  ;
   defparam SYNC_GEN.V_BACK_PORCH    = 33  ;
   defparam SYNC_GEN.V_FRONT_PORCH   = 10  ;
   defparam SYNC_GEN.V_RES           = 480 ;
   defparam SYNC_GEN.VSYNC_HEIGHT    = 2   ;


geometry_processor   GEOFF(

   // ****** INPUTS *******
   .clk              ( clk                ), // 125 MHz clock signal from the DDR3_Controller in GPU_DECA_DDR3_top.
   .reset            ( SYNTHESIZED_WIRE_15), // reset is a combined signal of the GPU's RESET button, OR'd with Z80_RST.
   .fifo_cmd_ready   ( send_geo_cmd       ), // Active HIGH from Z80_BRIDGE when geo_cmd bus has valid 16-bit command.
   .rd_data_rdy_a    ( geo_rdy_a          ), // Active HIGH from DATA_MUX when valid READ data for port A is on geo_r_data bus.
   .rd_data_rdy_b    ( geo_rdy_b          ), // Active HIGH from DATA_MUX when valid READ data for port B is on geo_r_data bus.
   .ram_mux_busy     ( geo_port_full      ), // Active HIGH when DATA_MUX is busy.
   .hse              ( hse                ), // Horizontal sync signal from VIGEN.
   .vse              ( vse                ), // Vertical   sync signal from VIGEN.
   .collision_rd_rst ( rd_px_ctr_rs       ), // Active HIGH signal from Z80_BRIDGE to reset READ  PIXEL COLLISION counter.
   .collision_wr_rst ( wr_px_ctr_rs       ), // Active HIGH signal from Z80_BRIDGE to reset WRITE PIXEL COLLISION counter.
   .fifo_cmd_in      ( geo_cmd            ), // 16-bit command bus from Z80_BRIDGE.
   .rd_data_in       ( geo_r_data         ), // 16-bit data bus from DATA_MUX for memory read data.
   
   // ****** OUTPUTS *******
   .rd_req_a         ( geo_rd_req_a       ), // Active HIGH signal to DATA_MUX with valid address on ram_addr bus for port A read.
   .rd_req_b         ( geo_rd_req_b       ), // Active HIGH signal to DATA_MUX with valid address on ram_addr bus for port B read.
   .wr_ena           ( geo_wr_ena         ), // Active HIGH signal to DATA_MUX for a RAM WRite, with valid address on ram_addr and data on ram_wr_data.
   .fifo_cmd_busy    ( geo_stat_rd[0]     ), // Active HIGH signal when GEOFF's FIFO is full. Connects to Z80_BRIDGE as part of GEO_STAT_RD bus (bit 0).
   .collision_rd     ( collision_rd       ), // READ  PIXEL COLLISION count output.
   .collision_wr     ( collision_wr       ), // WRITE PIXEL COLLISION count output.
   .ram_addr         ( geo_ram_addr       ), // 20-bit address bus to DATA_MUX.
   .ram_wr_data      ( geo_wr_data        )  // 16-bit data bus to DATA_MUX.
   
);
   defparam GEOFF.FIFO_MARGIN = 32;

   
vid_osd_generator VIGEN(

   // ****** INPUTS *******
   .clk                 ( clk                ), // 125 MHz clock signal from the DDR3_Controller in GPU_DECA_DDR3_top.
   .host_clk            ( clk                ), // 125 MHz clock signal from the DDR3_Controller in GPU_DECA_DDR3_top.
   .clk_2x              ( clk_2x             ),
   .clk_2x_phase        ( clk_2x_phase       ),
   .hde_in              ( hde_wire           ),
   .vde_in              ( vde_wire           ),
   .hs_in               ( hsync_wire         ),
   .vs_in               ( vsync_wire         ),
   .host_wr_ena         ( h_wena             ),
   .ena_host_16bit      ( h_16bit            ),
   .GPU_HW_Control_regs ( GPU_HW_REGS_BUS    ),
   .host_addr           ( h_addr             ),
   .host_wr_data        ( h_wdat             ),
   .HV_triggers_in      ( raster_HV_triggers ),
   .pc_ena              ( pc_ena             ),
   
   // ****** OUTPUTS *******
   .hde_out             ( hse                ),
   .vde_out             ( vse                ),
   .hs_out              ( osd_hs_out         ),
   .vs_out              ( osd_vs_out         ),
   .red                 ( SYNTHESIZED_WIRE_4 ),
   .green               ( SYNTHESIZED_WIRE_3 ),
   .blue                ( SYNTHESIZED_WIRE_2 ),
   .host_rd_data        ( h_rdat             )
   
);
   defparam VIGEN.ADDR_SIZE    = 17                     ; // 15 = 32KB, 16 = 64KB etc
   defparam VIGEN.GPU_RAM_MIF  = "GPU_MIF_CE10_10M.mif" ; // Default memory contents
   defparam VIGEN.HW_REGS_SIZE = HW_REGS                ; // Default size for hardware register bus
   defparam VIGEN.NUM_LAYERS   = MAGGIES                ; // Number of MAGGIEs
   defparam VIGEN.NUM_WORDS    = GPU_MEM - 1024         ; // RAM space for HW registers and video memory - doesn't include palette RAM
   defparam VIGEN.PALETTE_ADDR = GPU_MEM - 1024         ; // Base address of palette memory, usually located at end of video graphics RAM
   defparam VIGEN.PIPE_DELAY   = 11                     ; // This parameter selects the number of pixel clocks to delay the VDE and sync outputs.  Only use 2 through 9.

   
vid_out_stencil   STENCIL(

   .pclk       ( clk                ),
   .reset      ( reset              ),
   .hde_in     ( hse                ),
   .vde_in     ( vse                ),
   .hs_in      ( osd_hs_out         ),
   .vs_in      ( osd_vs_out         ),
   .b_in       ( SYNTHESIZED_WIRE_2 ),
   .g_in       ( SYNTHESIZED_WIRE_3 ),
   .pc_ena     ( pc_ena             ),
   .r_in       ( SYNTHESIZED_WIRE_4 ),
   
   .hs_out     ( stencil_hs_out     ),
   .vs_out     ( stencil_vs_out     ),
   .vid_de_out ( stencil_de_out     ),
   .vid_clk    ( stencil_vid_clk    ),
   .b_out      ( blue               ),
   .g_out      ( green              ),
   .r_out      ( red                )
   
);
   defparam STENCIL.HS_invert = 1 ;
   defparam STENCIL.RGB_hbit  = 7 ;
   defparam STENCIL.VS_invert = 1 ;
   

sound AUDIO(

   .clk     ( clk         ),
   .reset   ( reset       ),
   .enable  ( SP_EN       ),
   .data_tx ( snd_data_tx ),
   .data    ( snd_data    ),
   .speaker ( SPEAKER     )
   
);

/*
ps2_keyboard_interface  PS2_INPUT(

   .clk             ( com_clk         ),
   .reset           ( reset           ),
   .rx_read         ( DFF_inst32      ),
   .tx_write        ( ps2_tx_data_in  ),
   .ps2_clk         ( PS2_CLK         ),
   .ps2_data        ( PS2_DAT         ),
   .tx_data         ( ps2_data_in     ),
   .rx_extended     ( ps2STAT[0]      ),
   .rx_released     ( key_dat[7]      ),
   .rx_shift_key_on ( ps2STAT[2]      ),
   .rx_data_ready   ( PS2_DAT_RDY     ),
   .caps_lock       ( ps2STAT[1]      ),
   .rx_ascii        ( key_dat[6:0]    ),
   .rx_scan_code    ( rx_code         )
   
);
   defparam PS2_INPUT.m1_rx_clk_h                 = 1    ;
   defparam PS2_INPUT.m1_rx_clk_l                 = 0    ;
   defparam PS2_INPUT.m1_rx_falling_edge_marker   = 13   ;
   defparam PS2_INPUT.m1_rx_rising_edge_marker    = 14   ;
   defparam PS2_INPUT.m1_tx_clk_h                 = 4    ;
   defparam PS2_INPUT.m1_tx_clk_l                 = 5    ;
   defparam PS2_INPUT.m1_tx_done_recovery         = 7    ;
   defparam PS2_INPUT.m1_tx_error_no_keyboard_ack = 8    ;
   defparam PS2_INPUT.m1_tx_first_wait_clk_h      = 10   ;
   defparam PS2_INPUT.m1_tx_first_wait_clk_l      = 11   ;
   defparam PS2_INPUT.m1_tx_force_clk_l           = 3    ;
   defparam PS2_INPUT.m1_tx_reset_timer           = 12   ;
   defparam PS2_INPUT.m1_tx_rising_edge_marker    = 9    ;
   defparam PS2_INPUT.m1_tx_wait_clk_h            = 2    ;
   defparam PS2_INPUT.m1_tx_wait_keyboard_ack     = 6    ;
   defparam PS2_INPUT.m2_rx_data_ready            = 1    ;
   defparam PS2_INPUT.m2_rx_data_ready_ack        = 0    ;
   defparam PS2_INPUT.TIMER_5USEC_BITS_PP         = 8    ;
   defparam PS2_INPUT.TIMER_5USEC_VALUE_PP        = 186  ;
   defparam PS2_INPUT.TIMER_60USEC_BITS_PP        = 12   ;
   defparam PS2_INPUT.TIMER_60USEC_VALUE_PP       = 2950 ;
   defparam PS2_INPUT.TRAP_SHIFT_KEYS_PP          = 0    ;
*/
   
status_LED  STAT_LED(

   .clk ( clk        ),
   .LED ( STATUS_LED )
   
);
   defparam STAT_LED.div = 2;

   
// 
// Wire assigns
//
assign geo_stat_rd[7:1]    = 7'b0000000 ;
assign ps2STAT[7:4]        = 4'b0000    ;
assign ps2_tx_data_in      = 0          ;
assign ps2_data_in         = 0          ;

assign SYNTHESIZED_WIRE_10 = /*com_rst |*/ INV_RESET_DFF                ;
assign SYNTHESIZED_WIRE_15 = DFF_inst26 /*| geo_stat_wr[0] */           ;
assign SYNTHESIZED_WIRE_16 = (video_en || DEBUG_VIDON) & stencil_de_out ;
assign SYNTHESIZED_WIRE_17 = SYNTHESIZED_WIRE_9 | SYNTHESIZED_WIRE_10   ;
assign Z80_data            = data_en ? Z80_RD_data : 8'bzzzzzzzz        ;
// debugging
//assign reset_status        = !SYNTHESIZED_WIRE_17                     ;

//
// Discrete logic blocks
//
exp   b2v_inst4(
   .in  ( DFF_inst8     ),
   .out ( INV_RESET_DFF )
);

exp   b2v_inst23(
   .in  ( DFF_inst41         ),
   .out ( SYNTHESIZED_WIRE_9 )
);

//
// Clock blocks
//
(*preserve*) logic  clk_dly;
always_ff @(posedge clk_2x) clk_dly      <= !clk    ;
always_ff @(posedge clk_2x) clk_2x_phase <= clk_dly ;


always@(posedge com_clk) begin

	DFF_inst32 <= PS2_DAT_RDY;

end

always@(posedge clk) begin

      DFF_inst26      <= reset;
      DFF_inst33[7:0] <= ps2STAT[7:0];
      r[7:0]          <= red[7:0];
      g[7:0]          <= green[7:0];
      b[7:0]          <= blue[7:0];
      vde             <= SYNTHESIZED_WIRE_16;
      reset           <= SYNTHESIZED_WIRE_17;
      vs              <= stencil_vs_out;
      hs              <= stencil_hs_out;
      DFF_inst41      <= Z80_RST;
      pixel_clk       <= stencil_vid_clk;
      DFF_inst8       <= RESET_PIN;
      
/*
      DFF_inst51      <= uart_rxd;
      uart_txd        <= RS232_TX;
      LED_txd         <= RS232_LED_TX;
      LED_rdx         <= RS232_LED_RX;
*/

end


/*
// Disable PLL due to clock domain crossing with DDR3 - clocks are handled in GPU_DECA_DDR3_top now.
altpll0  b2v_inst17(

   .inclk0 ( clk54m       ),
   .c0     ( clk          ),
   .c1     ( clk_2x       ),
   .c2     ( com_clk      ),
   .c3     ( clk_2x_ph    )
   
);

exp   b2v_inst11(
   .in  ( DFF_inst6    ),
   .out ( clk_2x_phase )
);

always@(posedge clk_2x) begin

   DFF_inst6 <= clk_2x_ph;
   
end
*/


/*
rs232_debugger b2v_inst3(

   .clk         ( clk              ),
   .rxd         ( DFF_inst51       ),
   .host_rd_rdy ( RS232_rd_rdy     ),
   .host_rdata  ( RS232_rDat       ),
   .in0         ( key_dat          ),
   .in1         ( rx_code          ),
   .in2         ( ps2STAT          ),
   
   .cmd_rst     ( com_rst          ),
   .txd         ( RS232_TX         ),
   .LED_txd     ( RS232_LED_TX     ),
   .LED_rxd     ( RS232_LED_RX     ),
   .host_rd_req ( RS232_rd_req     ),
   .host_wr_ena ( RS232_wr_ena     ),
   .host_addr   ( RS232_addr[15:0] ),
   .host_wdata  ( RS232_wDat       ),
   
   .out3(out3)
   
);
   defparam b2v_inst3.ADDR_SIZE     = 16        ;
   defparam b2v_inst3.BAUD_RATE     = 921600    ;
   defparam b2v_inst3.CLK_IN_HZ     = 125000000 ;
   defparam b2v_inst3.READ_REQ_1CLK = 1         ;
*/


endmodule
