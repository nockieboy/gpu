module geometry_processor (

   // inputs
   input logic clk,                    // System clock
   input logic reset,                  // Force reset
   input logic fifo_cmd_ready,         // 16-bit Data Command Ready signal    - connects to the 'strobe' on the selected high.low Z80 bus output port
   input logic [15:0] fifo_cmd_in,     // 16-bit Data Command bus             - connects to the 16-bit output port on the Z80 bus

   // data_mux_geo inputs
   input logic [15:0] rd_data_in,      // GEO read data for the read/modify/write pixel channel.
   input logic [15:0] rd_data_in_C,    // GEO read data for the COPY pixel channel.
   input logic rd_data_rdy_C,          // GEO read data ready for the COPY pixel channel.
   input logic rd_data_rdy,            // GEO read data ready for the read/modify/write pixel channel.
   input logic ram_mux_busy,           // input from geo_port_full
    
    // H&V video enable/sync input for WAIT_interupt command
    input logic hse,
    input logic vse,
    
   // data_mux_geo outputs
   output logic rd_req_C,              // GEO read request for the COPY pixel channel.
   output logic rd_req,                // GEO read request for the read/modify/write pixel channel.
   output logic wr_ena,                // output to geo_wr_ena   on data_mux_geo
   output logic [19:0] ram_addr,       // output to address_geo  on data_mux_geo
   output logic [19:0] ram_addr_C,     // output to address_geo  on data_mux_geo
   output logic [15:0] ram_wr_data,    // output to data_in_geo  on data_mux_geo
    
   // collision saturation counter outputs
   input  logic        collision_rd_rst,   // output to 1st read port on Z80_bridge_v2
   input  logic        collision_wr_rst,   // output to 2nd read port on Z80_bridge_v2
   output logic [7:0]  collision_rd,       // output to 1st read port on Z80_bridge_v2
   output logic [7:0]  collision_wr,       // output to 2nd read port on Z80_bridge_v2

   output logic        fifo_cmd_busy        // high when input comand fifo is full
);

parameter int FIFO_MARGIN         = 32 ; // The number of extra commadns the fifo has room after the 'fifo_cmd_busy' goes high

// wire interconnects for the sub-modules
logic pix_writer_busy     ;  
logic [35:0] draw_cmd     ;
logic draw_cmd_rdy        ;
logic [35:0] draw_cmd_r   ;
logic draw_cmd_rdy_r      ;
logic [35:0] draw_cmd_r2  ;
logic draw_cmd_rdy_r2     ;
logic [39:0] pixel_cmd    ;
logic pixel_cmd_rdy       ;
logic [39:0] pixel_cmd_r  ;
logic pixel_cmd_rdy_r     ;
logic [39:0] pixel_cmd_r2 ;
logic pixel_cmd_rdy_r2    ;

geometry_xy_plotter geoff (

   // inputs
   .clk            ( clk             ),
   .reset          ( reset           ),
   .fifo_cmd_ready ( fifo_cmd_ready  ),
   .fifo_cmd_in    ( fifo_cmd_in     ),
   .draw_busy      ( pix_writer_busy ),
   .hse            ( hse             ),
   .vse            ( vse             ),
   //outputs
    .load_cmd       (                 ),        // HIGH when ready to receive next cmd_data[15:0] input
   .draw_cmd_rdy   ( draw_cmd_rdy    ),
   .draw_cmd       ( draw_cmd        ),
   .fifo_cmd_busy  ( fifo_cmd_busy   )
   
);
defparam geoff.FIFO_MARGIN   = FIFO_MARGIN,  // The number of extra commadns the fifo has room after the 'fifo_cmd_busy' goes high
         geoff.USE_ALTERA_IP = 1 ;

pixel_address_generator paget (

    // inputs
    .clk           ( clk              ),
    .reset         ( reset            ),
    .draw_cmd_rdy  ( draw_cmd_rdy_r2   ),  // use _r, or _r2 to add a D-Clocked buffer between this section and the plotter.
    .draw_cmd      ( draw_cmd_r2       ),  // use _r, or _r2 to add a D-Clocked buffer between this section and the plotter.
    .draw_busy     ( pix_writer_busy  ),
    // outputs
    .pixel_cmd_rdy ( pixel_cmd_rdy    ),
    .pixel_cmd     ( pixel_cmd        )
);
defparam paget.USE_ALTERA_IP = 1 ;

 geo_pixel_writer pixie (

    // inputs
    .clk              ( clk              ),
    .reset            ( reset            ),
    .cmd_rdy          ( pixel_cmd_rdy_r2 && !pix_writer_busy   ),
    .cmd_in           ( pixel_cmd_r2     ),
    .rd_data_in       ( rd_data_in       ),
    .rd_data_in_C     ( rd_data_in_C     ),
    .rd_data_rdy_C    ( rd_data_rdy_C    ),
    .rd_data_rdy      ( rd_data_rdy      ),
    .ram_mux_busy     ( ram_mux_busy     ),
    .collision_rd_rst ( collision_rd_rst ),
    .collision_wr_rst ( collision_wr_rst ),
    // outputs
    .draw_busy        ( pix_writer_busy  ),
    .rd_req_C         ( rd_req_C         ),
    .rd_req           ( rd_req           ),
    .wr_ena           ( wr_ena           ),
    .ram_addr         ( ram_addr         ),
    .ram_addr_C       ( ram_addr_C       ),
    .ram_wr_data      ( ram_wr_data      ),
    .collision_rd     ( collision_rd     ),
    .collision_wr     ( collision_wr     ),
    .PX_COPY_COLOUR   (                  )

);


always @ (posedge clk ) begin

    if (!pix_writer_busy) begin

        draw_cmd_rdy_r   <= draw_cmd_rdy    ;
        draw_cmd_r       <= draw_cmd        ;
        draw_cmd_rdy_r2  <= draw_cmd_rdy_r  ;
        draw_cmd_r2      <= draw_cmd_r      ;
        pixel_cmd_rdy_r  <= pixel_cmd_rdy   ;
        pixel_cmd_r      <= pixel_cmd       ;
        pixel_cmd_rdy_r2 <= pixel_cmd_rdy_r ;
        pixel_cmd_r2     <= pixel_cmd_r     ;

    end

end

endmodule
