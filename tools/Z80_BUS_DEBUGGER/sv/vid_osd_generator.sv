module vid_osd_generator (

   // inputs
   input clk_2x,       // DDR clock for internal multiport ram to run at double speed
   input clk_2x_phase,
   input clk,
   input [3:0] pc_ena,
   input hde_in,
   input vde_in,
   input hs_in,
   input vs_in,
   input wire host_clk,
   input wire host_wr_ena,
   input wire [19:0] host_addr,
   input wire [15:0] host_wr_data,
	input wire        ena_host_16bit,
   input wire [7:0]  GPU_HW_Control_regs[0:(2**HW_REGS_SIZE-1)],
   input wire [47:0] HV_triggers_in,
   
   // outputs
   output reg hde_out,
   output reg vde_out,
   output reg hs_out,
   output reg vs_out,
   output wire [7:0]  red,
   output wire [7:0]  green,
   output wire [7:0]  blue,
   output wire [15:0] host_rd_data,
   output reg  [47:0] HV_triggers_out
);

reg [PIPE_DELAY:0] hde_pipe, vde_pipe, hs_pipe, vs_pipe;
reg [47:0] HV_pipe[PIPE_DELAY:0];

parameter PIPE_DELAY = 11;                // This parameter selects the number of pixel clocks to delay the VDE and sync outputs.  Only use 2 through 9.
parameter HW_REGS_SIZE  = 9;              // default size for hardware register bus - set by HW_REGS parameter in design view
parameter ADDR_SIZE     = 17;					// 15 = 32KB, 16 = 64KB, 17=128KB, 18=256KB etc
parameter NUM_WORDS     = 24576;				// Video RAM up to 5FFFh (24576 default for EP4CE6)
parameter NUM_LAYERS    = 7;              // This parameter defines the number of MAGGIE graphics layers.
parameter PALETTE_ADDR  = (2 ** ADDR_SIZE) - 1024 ;   // Base address where host Z80 may access the palette memory, usually located in the last 1024 bytes of addressable memory
parameter GPU_RAM_MIF   = "GPU_MIF.mif" ; // MIF file for the main GPU ram.

wire   [15:0] host_rd_data_main,host_rd_data_pal;
assign        host_rd_data_pal[15:8] = 8'd0;
assign        host_rd_data           = host_rd_data_main | host_rd_data_pal; // merge the read data outputs of all internal rams.

wire [23:0] maggie_to_bp2r[14:0];
wire [19:0] GPU_ram_addr_in[14:0];
wire [31:0] GPU_ram_cmd_in[14:0];
wire [19:0] GPU_ram_cmd_out[14:0];
wire [15:0] GPU_ram_data_out[14:0];
wire [17:0] BART_to_PAL_MIXER[14:0];

// **** Create the HV trigger test cursors at output ****
wire [7:0] red_pc,green_pc,blue_pc;
wire [7:0] test_cursors;
assign test_cursors[6:0] = 7'h0;
assign test_cursors[7]   = HV_triggers_out[0] | HV_triggers_out[1] | HV_triggers_out[2] | HV_triggers_out[3];

// set cursor colour
assign red   = red_pc   | test_cursors;
assign green = green_pc | test_cursors;
assign blue  = blue_pc  ; //| test_cursors;
// *************************************************************

integer i;

// ****************************************************************************************************************************
// *
// * create a multiport GPU RAM handler instance
// *
// ****************************************************************************************************************************
sixteen_port_gpu_ram gpu_RAM(

   .clk_2x         ( clk_2x ),
   .clk_2x_phase   ( clk_2x_phase ),
   .clk            ( clk ),
   .pc_ena_in      ( pc_ena[3:0] ),
   
   .addr_in        ( GPU_ram_addr_in   ),
   .cmd_in         ( GPU_ram_cmd_in    ),
   .cmd_out        ( GPU_ram_cmd_out   ),
   .data_out       ( GPU_ram_data_out  ),
   
   .write_ena_host ( host_wr_ena             ),
   .ena_host_16bit ( ena_host_16bit          ),
   .addr_host_in   ( host_addr[19:0]         ),
   .data_host_in   ( host_wr_data[15:0]      ),
   .data_host_out  ( host_rd_data_main[15:0] )
);

defparam gpu_RAM.ADDR_SIZE          = ADDR_SIZE,   // pass ADDR_SIZE into the gpu_RAM instance
         gpu_RAM.NUM_WORDS          = NUM_WORDS,
         gpu_RAM.HOST_BASE_ADDRESS  = 20'h0,
         gpu_RAM.PIXEL_PIPE         = 3,          // set the length of the pixel pipe to offset multi-read port sequencing
         gpu_RAM.MIF_FILE           = GPU_RAM_MIF;

// ****************************************************************************************************************************
// ****************************************************************************************************************************
// Generate First initial MAGGIE module
// ****************************************************************************************************************************
maggie maggie_0(
   .clk           (clk),
   .pc_ena_in     (pc_ena[3:0]),          // Synchronous sub-pixel clock divider
   .hw_regs       (GPU_HW_Control_regs),  // MAGGIE controls
   .HV_trig       (HV_triggers_in),       // H&V sync and top left window coordinates going into MAGGIE

   .cmd_in        (),// GPU_ram_cmd_out[NUM_LAYERS-1]  ), // comand coming in from previous MAGGIE channel
   .ram_din       (),// GPU_ram_data_out[NUM_LAYERS-1] ), // GPU ram read data comand coming in from previous MAGGIE channel

   .read_addr     (GPU_ram_addr_in[0]),   // current MAGGIE directed pixel/pixel or tile/tile read address going out
   .cmd_out       (GPU_ram_cmd_in[0]),    // current MAGGIE directed real time pixel/pixel command  going out

   .bp_2_rast_cmd (maggie_to_bp2r[0])     // once per frame BART controls going out
);

defparam maggie_0.HW_REGS           = HW_REGS_SIZE,
         maggie_0.H_RESET_TRIG      = 6,  // H&V trigger which defines when the MAGGIE resets and increments it's internal registers
         maggie_0.H_POS_TRIG        = 8,  // H&V trigger which defines the beginning top left coordinate of the MAGGIE's open window
         maggie_0.HW_REG_BASE       = 96+16*0,  // Base address for the 16 bytes which controls the MAGGIE and paired BART modules.
         maggie_0.RAM_READ_CYCLES   = 3;  // Defines the GPU_ram module's read pixel clock cycles.
// ****************************************************************************************************************************
// Generate all the additional MAGGIE modules above the first one
// ****************************************************************************************************************************
genvar x;
generate
   for (x=1 ; x<NUM_LAYERS ; x=x+1) begin : maggie_inst
      maggie maggie_inst (
         .clk           ( clk ),
         .pc_ena_in     ( pc_ena[3:0] ),         // Synchronous sub-pixel clock divider
         .hw_regs       ( GPU_HW_Control_regs ), // MAGGIE controls
         .HV_trig       ( HV_triggers_in ),      // H&V sync and top left window coordinates going into MAGGIE
         
         .cmd_in        ( GPU_ram_cmd_out[x-1]  ), // comand coming in from previous MAGGIE channel
         .ram_din       ( GPU_ram_data_out[x-1] ), // GPU ram read data comand coming in from previous MAGGIE channel
         
         .read_addr     ( GPU_ram_addr_in[x] ),  // current MAGGIE directed pixel/pixel or tile/tile read address going out
         .cmd_out       ( GPU_ram_cmd_in[x]  ),  // current MAGGIE directed real time pixel/pixel command  going out
         
         .bp_2_rast_cmd ( maggie_to_bp2r[x]  ) ); // once per frame BART controls going out
         
defparam maggie_inst.HW_REGS           = HW_REGS_SIZE,
         maggie_inst.H_RESET_TRIG      = 6  ,  // H&V trigger which defines when the MAGGIE resets and increments it's internal registers
         maggie_inst.H_POS_TRIG        = 8+2*x,  // H&V trigger which defines the beginning top left coordinate of the MAGGIE's open window
         maggie_inst.HW_REG_BASE       = 96+16*x,  // Base address for the 16 bytes which controls the MAGGIE and paired BART modules.
         maggie_inst.RAM_READ_CYCLES   = 3  ;  // Defines the GPU_ram module's read pixel clock cycles.
   end
endgenerate
// ****************************************************************************************************************************


// ****************************************************************************************************************************
//  Generate all the bart modules
// ****************************************************************************************************************************
generate
   for (x=0 ; x<NUM_LAYERS ; x=x+1) begin : bart_inst
		bart bart_inst(
			.clk            ( clk ),
			.pc_ena         ( pc_ena[3:0] ),
			.bp_2_rast_cmd  ( maggie_to_bp2r[x] ),
			.cmd_in         ( GPU_ram_cmd_out[x]  ),
			.ram_byte_in    ( GPU_ram_data_out[x] ),
			.pixel_out      ( BART_to_PAL_MIXER[x] )
		);
   end
endgenerate
// ****************************************************************************************************************************

// ****************************************************************************************************************************
// Palette mixer
// ****************************************************************************************************************************
palette_mixer  pmixer (
   // inputs
   .clk_2x        ( clk_2x            ),
   .clk_2x_phase  ( clk_2x_phase      ),
   .clk           ( clk               ),
   .pc_ena_in     ( pc_ena[3:0]       ),
   .pixel_in      ( BART_to_PAL_MIXER ),
   
   // outputs
   .pixel_out_r   ( red_pc   ),
   .pixel_out_g   ( green_pc ),
   .pixel_out_b   ( blue_pc  ),

   // host port
   .host_wrena    ( host_wr_ena            ),
   .host_addr_in  ( host_addr[19:0]        ),
   .host_data_in  ( host_wr_data[7:0]      ),
   .host_data_out ( host_rd_data_pal[7:0]  )
);

defparam pmixer.PALETTE_ADDR = PALETTE_ADDR,  // Base address where host Z80 may access the palette memory
         pmixer.NUM_LAYERS   = NUM_LAYERS ;
// ****************************************************************************************************************************


always @ ( posedge clk ) begin

   if (NUM_LAYERS < 15) begin // Zero out all unused layers so compiler simplifies out unused ram and palette mixer channels.
      for (i = NUM_LAYERS ; i < 15; i = i + 1) begin 
         maggie_to_bp2r[i]    = 24'h0;
         GPU_ram_addr_in[i]   = 20'h0;
         GPU_ram_cmd_in[i]    = 32'h0;
         BART_to_PAL_MIXER[i] = 18'h0;
      end
   end

   if (pc_ena[3:0] == 0) begin
      
      // **************************************************************************************************************************
      // *** Create a serial pipe where the PIPE_DELAY parameter selects the pixel count delay for the xxx_in to the xxx_out ports
      // **************************************************************************************************************************
      hde_pipe[0]             <= hde_in;
      hde_pipe[PIPE_DELAY:1]  <= hde_pipe[PIPE_DELAY-1:0];
      hde_out                 <= hde_pipe[PIPE_DELAY-1];
      
      vde_pipe[0]             <= vde_in;
      vde_pipe[PIPE_DELAY:1]  <= vde_pipe[PIPE_DELAY-1:0];
      vde_out                 <= vde_pipe[PIPE_DELAY-1];
      
      hs_pipe[0]              <= hs_in;
      hs_pipe[PIPE_DELAY:1]   <= hs_pipe[PIPE_DELAY-1:0];
      hs_out                  <= hs_pipe[PIPE_DELAY-1];
      
      vs_pipe[0]              <= vs_in;
      vs_pipe[PIPE_DELAY:1]   <= vs_pipe[PIPE_DELAY-1:0];
      vs_out                  <= vs_pipe[PIPE_DELAY-1];
      
      HV_pipe[0]              <= HV_triggers_in;
      HV_pipe[PIPE_DELAY:1]   <= HV_pipe[PIPE_DELAY-1:0];
      HV_triggers_out         <= HV_pipe[PIPE_DELAY-1];
      
   end // ena
   
end // always@clk

endmodule
