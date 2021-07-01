/*
 *      GEOFF MODULE
 *  (geometry_xy_plotter)
 *
 *       v 0.95. October 3rd, 2020
 * 
 * Geo-plotter/polyplot, sorter and blitter portions written by Brian Guralnick
 * Now inclused 12 bit fractional X&Y zoom and shrink scaling blitter operation.
 *
 */

module geometry_xy_plotter #(
parameter int FIFO_MARGIN         = 32, // The number of extra commands the fifo has room after the 'fifo_cmd_busy' goes high
parameter bit USE_ALTERA_IP       = 1   // Slecets if Altera's SCFIFO should be used, or Brian's FIFO_2word_FWFT.sv
)(
    input logic clk,               // System clock
    input logic reset,             // Force reset
    input logic fifo_cmd_ready,    // 16-bit Data Command Ready signal
    input logic [15:0] fifo_cmd_in,// 16-bit Data Command bus
    input logic draw_busy,         // HIGH when pixel writer is busy, so geometry plotter will pause before sending any new pixels

    input logic hse,                // Usually the HSE signal for H-Wait pause until specific line number.  Internally increments on the falling edge.
    input logic vse,                // Usually the HSE signal for V-Wait pause until specified number of frames.  Internally increments on the falling edge.
    
    output logic load_cmd,         // HIGH when ready to receive next cmd_data[15:0] input
    output logic draw_cmd_rdy,     // Pulsed HIGH when data on draw_cmd[15:0] is ready to send to the pixel writer module
    output logic [35:0] draw_cmd,  // Bits [35:32] hold AUX function number 0-15:
    //  AUX=0  : Do nothing
    //  AUX=1  : Write pixel,                             : 31:24 color         : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=2  : Write pixel with color 0 mask,           : 31:24 color         : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=3  : Write from read pixel,                   : 31:24 ignored       : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=4  : Write from read pixel with color 0 mask, : 31:24 ignored       : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=6  : Read source pixel,                       : 31:24 ignored       : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=7  : Set Truecolor pixel color                : 31:24 8 bit alpha blend mix value : bits 23:0 hold RGB 24 bit color
    //                                                      Use function Aux3/4 to draw this color, only works if the destination is set to 16 bit true-color mode

    //  AUX=10 ; Resets the Write Pixel collision counter           : 31:24 sets transparent masked out color : bits 23:0 in true color mode, this holds RGB 24 bit mask color, in 8 bit mode, this allows for 3 additional transparent colors
    //  AUX=11 ; Resets the Write from read pixel collision counter : 31:24 sets transparent masked out color : bits 23:0 in true color mode, this holds RGB 24 bit mask color, in 8 bit mode, this allows for 3 additional transparent colors

    //  AUX=12 : Set destination raster width in bytes    : 15:0 holds destination raster image width in #bytes so the proper memory address can be calculated from the X&Y coordinates
    //  AUX=13 : Set source raster width in bytes,        : 15:0 holds source raster image width in #bytes so the proper memory address can be calculated from the X&Y coordinates
    //  AUX=14 : Set destination mem address,             : 31:24 bitplane mode : 23:0 hold destination base memory address for write pixel
    //  AUX=15 : Set source mem address,                  : 31:24 bitplane mode : 23:0 hold the source base memory address for read source pixel
    output wire  fifo_cmd_busy,     // HIGH when FIFO is full/nearly full
    output logic processing         // needed for simulatior to know if there is internal pixel drawing.
);

logic plot_busy = 0;

//logic [3:0] CMD_OUT_NOP           = 0  ;
logic [3:0] CMD_OUT_PXWRI         = 1  ;
//logic [3:0] CMD_OUT_PXWRI_M       = 2  ;
logic [3:0] CMD_OUT_PXPASTE       = 3  ;
logic [3:0] CMD_OUT_PXPASTE_M     = 4  ;

logic [3:0] CMD_OUT_PXCOPY        = 6  ;
//logic [3:0] CMD_OUT_SETARGB       = 7  ;

logic [3:0] CMD_OUT_RST_PXWRI_M   = 10 ;
logic [3:0] CMD_OUT_RST_PXPASTE_M = 11 ;

logic [3:0] CMD_OUT_DSTRWDTH      = 12 ;
logic [3:0] CMD_OUT_SRCRWDTH      = 13 ;
logic [3:0] CMD_OUT_DSTMADDR      = 14 ;
logic [3:0] CMD_OUT_SRCMADDR      = 15 ;

logic [7:0]  command_in     = 0 ;
logic [11:0] command_data12 = 0 ;
logic [7:0]  command_data8  = 0 ;

logic signed [11:0] x[0:3]      = '{0,0,0,0} ; // 2-dimensional 12-bit register for x0-x3
logic signed [11:0] y[0:3]      = '{0,0,0,0} ; // 2-dimensional 12-bit register for y0-y3
logic signed [11:0] max_x       = 0 ; // this reg will be both in this module and the memory pixel writer
logic signed [11:0] max_y       = 0 ; // this reg will be both in this module and the memory pixel writer

logic signed [23:0] blit_dest_x       ; // 
logic signed [11:0] blit_dest_x_int   ; // 
logic signed [23:0] blit_dest_rst_x   ; // 
logic signed [23:0] blit_dest_y       ; // 
logic signed [11:0] blit_dest_y_int   ; // 
logic signed [23:0] blit_dest_rst_y   ; // 
logic signed [23:0] blit_source_x     ; // 
logic signed [23:0] blit_source_y     ; // 
logic signed [11:0] blit_source_ofs_x ; // 
logic signed [11:0] blit_source_ofs_y ; // 
logic        [11:0] blit_width        ; // this stores how many pixels wide the blitter will copy
logic        [11:0] blit_height       ; // this stores how many pixels high the blitter will copy
logic               blit_running      ; // high when the blitter is running
logic               blit_paste_phase  ; // high when the blitter is running
logic signed [11:0] blit_dxs[0:3]     ; // Holds all the possible blitter starting paste X coordinates depending on selected paste features
logic signed [11:0] blit_dys[0:3]     ; // Holds all the possible blitter starting paste Y coordinates depending on selected paste features
logic        [12:0] blit_src_scale_x  ; // Holds the X blitter source upscale fraction, IE zoom ratio (4096:blit_src_scale_x), values 4095 through 1, or 4096 for off.
logic        [12:0] blit_src_scale_y  ; // Holds the Y blitter source upscale fraction, IE zoom ratio (4096:blit_src_scale_y), values 4095 through 1, or 4096 for off.
logic        [12:0] blit_dest_scale_x ; // Holds the X blitter destination downscale fraction, IE zoom ratio (blit_dest_scale_x:4096), values 4095 through 1, or 4096 for off.
logic        [12:0] blit_dest_scale_y ; // Holds the Y blitter destination downscale fraction, IE zoom ratio (blit_dest_scale_y:4096), values 4095 through 1, or 4096 for off.

logic [3:0]  draw_cmd_func        = 0 ;
logic [7:0]  draw_cmd_data_color  = 0 ;
logic [11:0] draw_cmd_data_word_Y = 0 ;
logic [11:0] draw_cmd_data_word_X = 0 ;
logic        draw_cmd_tx          = 0 ;


//************************************************************************************************************************************************
// Source command coordinate sorting and interpretation pipe.
//************************************************************************************************************************************************
//logic                sort_cmd_rdy      = 0 ;
//logic [15:0]         sort_data_pipe    = 0 ;         // cmd_data pipeline OUT from poly_sort into geo_xy_plotter
//logic signed  [11:0] sort_coords[0:15] = '{16{0}} ; // array package of sorted coordinates for the linegen
//logic signed  [11:0] sort_y_range[0:1] = '{0,0};     // array package of defining the starting and ending Y coordinates for a filled polygon
//logic [1:0]          lg_seq_size[0:1]  = '{0,0};
//logic                lg_fill           = 0 ;
//logic                draw_shape        = 0 ;
//logic [7:0]          blit_features     = 0 ;
//logic [7:0]          blit_mask_col     = 0 ;


//logic                plot_cmd_rdy       = 0 ;
//logic [15:0]         plot_data_pipe     = 0 ;      // cmd_data pipeline OUT from poly_plot into the blitter
logic signed  [11:0] plot_pixel_xy[0:1]     ; // xy coordinates to plot to
logic                plot_pixel_ena         ;
logic [7:0]          plot_pixel_col         ;
//logic                plot_busy              ;
logic [7:0]          p_blit_features        ;
logic [7:0]          p_blit_mask_col        ;


//************************************************************************************************************************************************
// Source command fifo
//************************************************************************************************************************************************
logic [15:0] cmd_data       ;
logic        fifo_cmd_rdy_n ;

generate
if (USE_ALTERA_IP) begin  // **** USE Altera's IP SCFIFO.


scfifo  scfifo_component (
    .sclr        (reset),                                     // reset input
    .clock       (clk),                                       // system clock
    .wrreq       (fifo_cmd_ready),                            // connect this to the 'strobe' on the selected high.low Z80 bus output port
    .data        (fifo_cmd_in),                               // connect this to the 16 bit output port on the Z80 bus
    .almost_full (fifo_cmd_busy),                             // send to a selected bit on the Z80 status read port

    .empty       (fifo_cmd_rdy_n),                            // when LOW, the FIFO has commands for the geometry unit to process
    .rdreq       (load_cmd && !draw_busy),                    // connect to the listed inputs
    .q           (cmd_data[15:0]),                            // to geometry_xy_plotter cmd_data input
    .full        ()                                           // optional, unused
);

defparam
    scfifo_component.add_ram_output_register = "ON",
    scfifo_component.almost_full_value       = (512 - FIFO_MARGIN),
    scfifo_component.intended_device_family  = "Cyclone IV",
    scfifo_component.lpm_hint                = "RAM_BLOCK_TYPE=M9K",
    scfifo_component.lpm_numwords            = 512,
    scfifo_component.lpm_showahead           = "ON",
    scfifo_component.lpm_type                = "scfifo",
    scfifo_component.lpm_width               = 16,
    scfifo_component.lpm_widthu              = 9,
    scfifo_component.overflow_checking       = "ON",
    scfifo_component.underflow_checking      = "ON",
    scfifo_component.use_eab                 = "ON";

end else begin  
// (USE_ALTERA_IP) is disabled, use Brian G's FIFO_2word_FWFT.sv.

logic fifo_cmd_rdy_p;

//FIFO_3word_0_latency
FIFO_2word_FWFT #(
      .bits                  (16)                   // The number of bits containing the command
//    .zero_latency          (0),
//    .overflow_protection   (1),  // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
//    .underflow_protection  (1),  // Prevents internal position position increment if the fifo is empty
//    .size7_ena             (1)   // Set to 0 for 3 words

) input_cmd_fifo_1 (              // Zero Latency Command buffer

    .clk              ( clk                    ), // CLK input
    .reset            ( reset                  ), // Reset FIFO

    .shift_in         ( fifo_cmd_ready         ), // Load data into the FIFO
    .shift_out        ( load_cmd && !draw_busy ), // Shift data out of the FIFO
    .data_in          ( fifo_cmd_in            ), // Data input from PAGET

    .fifo_not_empty   ( fifo_cmd_rdy_p         ), // High when there is data available for the pixel writer
    .fifo_full        ( fifo_cmd_busy          ), // High when the FIFO is full - used to tell GEOFF and PAGET to halt until there is room in the FIFO again
    .data_out         ( cmd_data[15:0]         )  // FIFO data output to pixel writer
);

assign fifo_cmd_rdy_n = !fifo_cmd_rdy_p;
end

endgenerate

//************************************************************************************************************************************************
// Geometry XY line plotter.
//************************************************************************************************************************************************

poly_plot #(.USE_ALTERA_IP(USE_ALTERA_IP)) plotter (
// inputs
    .clk               ( clk             ),
    .reset             ( reset           ),
    .enable            ( !draw_busy      ), // !pixel_writer busy input
    .blitter_busy      ( blit_running    ),
    .cmd_rdy_in        ( !fifo_cmd_rdy_n ),
    .cmd_in            ( cmd_data        ), // ** cmd_data pipeline input from FIFO
    .x_in              ( x               ), // xy[0,1,2,3] registers
    .y_in              ( y               ), // xy[0,1,2,3] registers
    .hse               ( hse             ), // horizontal video enable
    .vse               ( vse             ), // vertical video enable
//outputs
    .pixel_ena         ( plot_pixel_ena  ),
    .pixel_xy          ( plot_pixel_xy   ),  // array package of sorted coordinates for the linegen 0&1
    .pixel_col         ( plot_pixel_col  ),  // array package of sorted coordinates for the linegen 0&1
    .plotter_busy      ( plot_busy       ),  // array containing the number of line coordinates for each linegen to run
    .blit_features_out ( p_blit_features ),  // Tells the blitter module to copy & paste a rectangle.
    .blit_mask_col_out ( p_blit_mask_col ),  // Tells the blitter copy pixel function how to transpose the source pixel color
    .blit_src_scale_x  ( blit_src_scale_x),  // Holds the X blitter source upscale fraction, IE zoom ratio (4096:blit_src_scale_x), values 4095 through 1, or 4096 for off.
    .blit_src_scale_y  ( blit_src_scale_y),  // Holds the Y blitter source upscale fraction, IE zoom ratio (4096:blit_src_scale_y), values 4095 through 1, or 4096 for off.
    .blit_dest_scale_x ( blit_dest_scale_x), // Holds the X blitter destination downscale fraction, IE zoom ratio (blit_dest_scale_x:4096), values 4095 through 1, or 4096 for off.
    .blit_dest_scale_y ( blit_dest_scale_y)  // Holds the Y blitter destination downscale fraction, IE zoom ratio (blit_dest_scale_y:4096), values 4095 through 1, or 4096 for off.
);


//************************************************************************************************************************************************
// Geometry plotter address & pointers command decoder and registers,
// final pixel blitter & command output to address generator.
//************************************************************************************************************************************************

always_comb begin

    // Assign output port wires to internal registers
    draw_cmd[35:32]      = draw_cmd_func[3:0]         ;
    draw_cmd[31:24]      = draw_cmd_data_color[7:0]   ;
    draw_cmd[23:12]      = draw_cmd_data_word_Y[11:0] ;
    draw_cmd[11:0]       = draw_cmd_data_word_X[11:0] ;
    draw_cmd_rdy         = draw_cmd_tx && !draw_busy  ;

    // Break out cmd_data bus into logical words
    command_in     [7:0] = cmd_data[15:8]        ;
    command_data12[11:0] = cmd_data[11:0]        ;
    command_data8  [7:0] = cmd_data[7:0]         ;

    // Assign the load_cmd output - when the geometry unit is not drawing, the load_cmd goes high to load the next command
    load_cmd             = !plot_busy  && !fifo_cmd_rdy_n  && !blit_running ;

// Setup all the possible blitter starting X&Y coordinates based on which feature are enabled
blit_dxs[3] = plot_pixel_xy[0]+blit_width[10:1]  ; // Beginning paste X coordinates with Mirror enabled  and Center Paste enabled
blit_dxs[2] = plot_pixel_xy[0]                   ; // Beginning paste X coordinates with Mirror enabled  and Center Paste disabled
blit_dxs[1] = plot_pixel_xy[0]-blit_width[10:1]  ; // Beginning paste X coordinates with Mirror disabled and Center Paste enabled
blit_dxs[0] = plot_pixel_xy[0]                   ; // Beginning paste X coordinates with Mirror disabled and Center Paste disabled

blit_dys[3] = plot_pixel_xy[1]+blit_height[10:1] ; // Beginning paste Y coordinates with Flip enabled  and Center Paste enabled
blit_dys[2] = plot_pixel_xy[1]                   ; // Beginning paste Y coordinates with Flip enabled  and Center Paste disabled
blit_dys[1] = plot_pixel_xy[1]-blit_height[10:1] ; // Beginning paste Y coordinates with Flip disabled and Center Paste enabled
blit_dys[0] = plot_pixel_xy[1]                   ; // Beginning paste Y coordinates with Flip disabled and Center Paste disabled

// Assign integer only versions of the destination coordinates for the blitter paste coordinates.
blit_dest_x_int = blit_dest_x[23:12];
blit_dest_y_int = blit_dest_y[23:12];

processing = plot_busy || blit_running ;

end // always_comb

always_ff @(posedge clk or posedge reset) begin

    if (reset) begin    // reset to defaults
        
        // reset coordinate registers
        for ( integer i = 0; i < 4; i++ ) begin
            x[i] <= { 12'b0 } ;
            y[i] <= { 12'b0 } ;
        end
        
        max_x                <= 12'b0 ;
        max_y                <= 12'b0 ;
        
        blit_dest_x         <= 12'b0 ; // 
        blit_dest_rst_x     <= 12'b0 ; // 
        blit_dest_y         <= 12'b0 ; // 
        blit_dest_rst_y     <= 12'b0 ; // 
        blit_source_x       <= 12'b0 ; // 
        blit_source_y       <= 12'b0 ; // 
        blit_source_ofs_x   <= 12'b0 ; // 
        blit_source_ofs_y   <= 12'b0 ; // 
        blit_width          <= 12'b0 ; // this stores how many pixels wide the blitter will copy
        blit_height         <= 12'b0 ; // this stores how many pixels high the blitter will copy
        blit_running        <= 1'b0 ;  // high when the blitter is running
        blit_paste_phase    <= 1'b0 ;  // high when the blitter is pasting, low when copying

        // reset draw command registers
        draw_cmd_func        <= 4'b0  ;
        draw_cmd_data_color  <= 8'b0  ;
        draw_cmd_data_word_Y <= 12'b0 ;
        draw_cmd_data_word_X <= 12'b0 ;
        draw_cmd_tx          <= 1'b0  ;
        
    end else if (!draw_busy) begin  // Everything must PAUSE if the incoming draw_busy signal from the pixel_writer is high
     
        
//************************************************************************************************************************************************
// When the plotter is busy, pass the output coordinates as a draw command.
// If the blitter is enables, use the plot coordinates as the center of a COPY, the PASTE command
// sequence with a box size of blit_width & blit_height.
//************************************************************************************************************************************************
   if (plot_busy || blit_running ) begin

//************************************************************************************************************************************************
// p_blit_features bitmask features:
// 0 = Enable blitter         1 = run biltter copying source to output coordinates, 0 = Simple pixel write command
// 1 = Enable paste mask      1 = Paste pixels with transparency mask, 0 = Always paste pixels even if the source pixel is the selected transparent color
// 2 = Enable H-center paste  1 = Offset the paste to the left by half of blit_width, 0 = Use the paste coordinates as the left margin
// 3 = Enable Mirror paste    1 = Mirror the output on the X axis.
// 4 = Enable V-center paste  1 = Offset the paste up by half of blit_height, 0 = Use the paste coordinates as the first line of the paste
// 5 = Enable Flip paste      1 = Flip the output on the Y axis.
// 6 = Enable Rotate 90 degree paste  1 = Swaps the X&Y coordinates on the paste.
// 7 = Enable Rotate 45 degree paste  1 = Increments/decrements the X&Y coordinates on the paste in unison.
//************************************************************************************************************************************************
if ( !p_blit_features[0] ) begin // ***** Blitter disabled.
        if ( plot_pixel_ena && ( plot_pixel_xy[0] >= 0 && plot_pixel_xy[0] < max_x ) && ( plot_pixel_xy[1] >=0 && plot_pixel_xy[1] < max_y ) ) begin
            blit_running         <= 1'b0;
            draw_cmd_func        <= CMD_OUT_PXWRI    ;
            draw_cmd_data_word_X <= plot_pixel_xy[0] ; // ... at X-coordinate
            draw_cmd_data_word_Y <= plot_pixel_xy[1] ; // ... and Y-coordinate
            draw_cmd_data_color  <= plot_pixel_col   ;    
            draw_cmd_tx          <= 1'b1             ; // let PAGET know valid pixel data is incoming
        end
        else draw_cmd_tx         <= 1'b0 ; // otherwise turn off draw command

end else begin // ***** Blitter enabled.

        if (!blit_running && plot_pixel_ena ) begin   // Blitter isn't yet running, so, initialize it.
            blit_running         <= 1'b1  ;           // Signal blitter running so the poly_plot module knows to wait for the copy/paste.
            blit_source_x        <= 24'd0 ;           // Clear the source coordinates
            blit_source_y        <= 24'd0 ;
            blit_paste_phase     <= 1'b0  ;           // Tells the blitter that a copy pixel has been done and ready for a paste pixel

            // Set the initial destination coordinates based on the Enable center H/V, and mirror/flip blitter features.
            blit_dest_x[23:12]     <= blit_dxs[p_blit_features[3:2]] ; // Set the beginning paste X coordinates.
            blit_dest_rst_x[23:12] <= blit_dxs[p_blit_features[3:2]] ; // tells the copy where to reset X during a Y increment
            blit_dest_y[23:12]     <= blit_dys[p_blit_features[5:4]] ; // Set the beginning paste Y coordinates.
            blit_dest_rst_y[23:12] <= blit_dys[p_blit_features[5:4]] ; // tells the copy where to reset Y during a X increment when copying with a 90 degree rotation
            // clear the floating point locations
            blit_dest_x[11:0]      <= 12'd0                          ; // Set the beginning paste X coordinates.
            blit_dest_rst_x[11:0]  <= 12'd0                          ; // tells the copy where to reset X during a Y increment
            blit_dest_y[11:0]      <= 12'd0                          ; // Set the beginning paste Y coordinates.
            blit_dest_rst_y[11:0]  <= 12'd0                          ; // tells the copy where to reset Y during a X increment when copying with a 90 degree rotation
            
         end else if ( blit_running ) begin // Blitter has been setup, now in running mode

         //  Whether reading or writing a pixel, if the destination pixel is inside the valid screen coordinates, enable the draw command TX
            if ( (blit_dest_x_int >= 0 && blit_dest_x_int < max_x ) && ( blit_dest_y_int >=0 && blit_dest_y_int < max_y ) ) draw_cmd_tx <= 1'b1 ;
         //  Otherwise stop the draw command TX
            else                                                                                                            draw_cmd_tx <= 1'b0 ;

         // During the first blitter phase, set the output command to the copy pixel coordinates and set the next phase to a paste pixel
                        if (!blit_paste_phase) begin
                        draw_cmd_func        <= CMD_OUT_PXCOPY   ;                         // Copy the source pixel command.
                        draw_cmd_data_word_X <= blit_source_x[23:12] + blit_source_ofs_x ; // ... at X-coordinate
                        draw_cmd_data_word_Y <= blit_source_y[23:12] + blit_source_ofs_y ; // ... and Y-coordinate
                        draw_cmd_data_color  <= p_blit_mask_col  ;                         // Copy color pixel transformation  (Read pixel is XORed with this number)   
                        blit_paste_phase     <= 1'b1 ;                                     // signal the next blitter phase, paste the copied pixel
                        end
            
         // During the second blitter phase, (PART 1) set the output command to the paste pixel coordinates.
                        if ( blit_paste_phase) begin
                        draw_cmd_func        <= p_blit_features[1] ? CMD_OUT_PXPASTE_M : CMD_OUT_PXPASTE ; // Write the pixel with the optional paste mask feature
                        draw_cmd_data_word_X <= blit_dest_x_int    ;                                       // ... at X-coordinate
                        draw_cmd_data_word_Y <= blit_dest_y_int    ;                                       // ... and Y-coordinate
                        draw_cmd_data_color  <= plot_pixel_col     ;                                       // Second XORed color transformation   
                        draw_cmd_tx          <= !( blit_source_x[23:12] == blit_width || blit_source_y[23:12] == blit_height ); // Corrects from drawing 1 extra line or pixel during zoomed drawings.  Let PAGET know valid pixel data is incoming
                        end

         // During the second blitter phase, (PART 2), OR when the destination paste pixel coordinates are OUTSIDE the valid screen coordinates,
         // (this step skipps a clock cycle when addressing pixels off the screen area)
         // Increment/decrement all the X&Y pointers/coordinates and set the blitter phase back into copy pixel mode.
         
         if ( blit_paste_phase || !( (blit_dest_x_int >= 0 && blit_dest_x_int < max_x ) && ( blit_dest_y_int >=0 && blit_dest_y_int < max_y ) ) ) begin

              blit_paste_phase     <= 1'b0 ;  // signal the next blitter phase, copy pixel.
         
                        if ( blit_source_x[23:12] == blit_width && blit_source_y[23:12] == blit_height ) begin // the copy has reached the blit_width/height
                        blit_running         <= 1'b0            ; // turn off blitter
                        end else if ( blit_source_x[23:12] != blit_width ) begin // width has not been reached, increment the X coordinates
                                                           blit_source_x <= blit_source_x + blit_src_scale_x ;

                                                      if ( p_blit_features[7]) begin   // Paste with 45 degree rotate begin
                                                        if ( !p_blit_features[6] ) begin // paste with rotate 90 degree off 
                                                           if ( !p_blit_features[3] ) blit_dest_x   <= blit_dest_x + (blit_dest_scale_x>>1) ; // Horizontal mirror off
                                                           else                       blit_dest_x   <= blit_dest_x - (blit_dest_scale_x>>1) ; // Horizontal mirror on
                                                           if ( !p_blit_features[5] ) blit_dest_y   <= blit_dest_y + (blit_dest_scale_y>>1) ; // Vertical flip off
                                                           else                       blit_dest_y   <= blit_dest_y - (blit_dest_scale_y>>1) ; // Vertical flip on
                                                        end else begin                   // paste with rotate 90 degree ON
                                                           if (  p_blit_features[5] ) blit_dest_y   <= blit_dest_y + (blit_dest_scale_y>>1) ; // Horizontal mirror off
                                                           else                       blit_dest_y   <= blit_dest_y - (blit_dest_scale_y>>1) ; // Horizontal mirror on
                                                           if ( !p_blit_features[3] ) blit_dest_x   <= blit_dest_x + (blit_dest_scale_x>>1) ; // Vertical flip off
                                                           else                       blit_dest_x   <= blit_dest_x - (blit_dest_scale_x>>1) ; // Vertical flip on
                                                        end
                                                      end else begin                   // no Paste 45 degree rotate begin
                                                        if ( !p_blit_features[6] ) begin // paste with rotate 90 degree off 
                                                           if ( !p_blit_features[3] ) blit_dest_x   <= blit_dest_x + blit_dest_scale_x ; // Horizontal mirror off
                                                           else                       blit_dest_x   <= blit_dest_x - blit_dest_scale_x ; // Horizontal mirror on
                                                        end else begin                   // paste with rotate 90 degree ON
                                                           if (  p_blit_features[5] ) blit_dest_y   <= blit_dest_y + blit_dest_scale_y ; // Horizontal mirror off
                                                           else                       blit_dest_y   <= blit_dest_y - blit_dest_scale_y ; // Horizontal mirror on
                                                        end
                                                      end  //  no Paste 45 degree rotate end

                        end else begin // width has been reached, increment the Y coordinates and reset the X coordinates
                                                           blit_source_y <= blit_source_y + blit_src_scale_y ;

                                                      if ( p_blit_features[7]) begin  // Paste with 45 degree rotate
                                                        if ( !p_blit_features[6] ) begin // paste with rotate 90 degree off 
                                                           if ( !p_blit_features[3] ) blit_dest_y     <= blit_dest_rst_y + (blit_dest_scale_y>>1) ; // Vertical flip off
                                                           else                       blit_dest_y     <= blit_dest_rst_y - (blit_dest_scale_y>>1) ; // Vertical flip on
                                                           if ( !p_blit_features[3] ) blit_dest_x     <= blit_dest_rst_x - (blit_dest_scale_x>>1) ; // New line return 
                                                           else                       blit_dest_x     <= blit_dest_rst_x + (blit_dest_scale_x>>1) ; // New line return 
                                                           
                                                           if ( !p_blit_features[3] ) blit_dest_rst_x <= blit_dest_rst_x - (blit_dest_scale_x>>1) ; // Modify new line return position 
                                                           else                       blit_dest_rst_x <= blit_dest_rst_x + (blit_dest_scale_x>>1) ; // Modify new line return position 
                                                             
                                                           if ( !p_blit_features[5] ) blit_dest_x     <= blit_dest_rst_x - (blit_dest_scale_x>>1) ; // Horizontal mirror off
                                                           else                       blit_dest_x     <= blit_dest_rst_x + (blit_dest_scale_x>>1) ; // Horizontal mirror on
                                                           if ( !p_blit_features[5] ) blit_dest_y     <= blit_dest_rst_y + (blit_dest_scale_y>>1) ; // New line return 
                                                           else                       blit_dest_y     <= blit_dest_rst_y - (blit_dest_scale_y>>1) ; // New line return 
                                                           
                                                           if ( !p_blit_features[5] ) blit_dest_rst_y <= blit_dest_rst_y + (blit_dest_scale_y>>1) ; // Modify new line return position 
                                                           else                       blit_dest_rst_y <= blit_dest_rst_y - (blit_dest_scale_y>>1) ; // Modify new line return position 
                                                        end else begin                   // paste with rotate 90 degree ON
                                                           if (  p_blit_features[5] ) blit_dest_x     <= blit_dest_rst_x + (blit_dest_scale_x>>1) ; // Vertical flip off
                                                           else                       blit_dest_x     <= blit_dest_rst_x - (blit_dest_scale_x>>1) ; // Vertical flip on
                                                           if (  p_blit_features[5] ) blit_dest_y     <= blit_dest_rst_y - (blit_dest_scale_y>>1) ; // New line return 
                                                           else                       blit_dest_y     <= blit_dest_rst_y + (blit_dest_scale_y>>1) ; // New line return 
                                                           
                                                           if (  p_blit_features[5] ) blit_dest_rst_y <= blit_dest_rst_y - (blit_dest_scale_y>>1) ; // Modify new line return position 
                                                           else                       blit_dest_rst_y <= blit_dest_rst_y + (blit_dest_scale_y>>1) ; // Modify new line return position 
                                                             
                                                           if ( !p_blit_features[3] ) blit_dest_y     <= blit_dest_rst_y - (blit_dest_scale_y>>1) ; // Horizontal mirror off
                                                           else                       blit_dest_y     <= blit_dest_rst_y + (blit_dest_scale_y>>1) ; // Horizontal mirror on
                                                           if ( !p_blit_features[3] ) blit_dest_x     <= blit_dest_rst_x + (blit_dest_scale_x>>1) ; // New line return 
                                                           else                       blit_dest_x     <= blit_dest_rst_x - (blit_dest_scale_x>>1) ; // New line return 
                                                           
                                                           if ( !p_blit_features[3] ) blit_dest_rst_x <= blit_dest_rst_x + (blit_dest_scale_x>>1) ; // Modify new line return position 
                                                           else                       blit_dest_rst_x <= blit_dest_rst_x - (blit_dest_scale_x>>1) ; // Modify new line return position 
                                                        end

                                                      end else begin                     // Paste horizontal or vertical
                                                        if ( !p_blit_features[6] ) begin // paste with rotate 90 degree off 
                                                           if ( !p_blit_features[5] ) blit_dest_y   <= blit_dest_y + blit_dest_scale_y ; // Vertical flip off
                                                           else                       blit_dest_y   <= blit_dest_y - blit_dest_scale_y ; // Vertical flip on
                                                                                      blit_dest_x   <= blit_dest_rst_x                 ; // New line return  
                                                        end else begin                   // paste with rotate 90 degree ON
                                                           if ( !p_blit_features[3] ) blit_dest_x   <= blit_dest_x + blit_dest_scale_x ; // Vertical flip off
                                                           else                       blit_dest_x   <= blit_dest_x - blit_dest_scale_x ; // Vertical flip on
                                                                                      blit_dest_y   <= blit_dest_rst_y                 ; // New line return  
                                                        end 
                                                      end  //  no Paste 45 degree rotate end

                                                           blit_source_x <= 24'd0 ;
                        end
                        
            end // end of paste pixel phase
         end else draw_cmd_tx  <= 1'b0 ; // end of blitter running
     end // end of p_blit_features[0] enable

end else begin // end of plot_busy

        // This code interprets the incoming commands when the linegens and blitter are not generating pixels
        if ( load_cmd ) begin  // when the cmd_rdy input is LOW and the geometry unit geo_run is not running, execute the following command input
         
            casez (command_in)
             
                8'b10?????? : begin
                              x[command_in[5:4]] <= command_data12 ;
                              draw_cmd_tx        <= 1'b0           ; // No command to transmit
                              end
                
                8'b11?????? : begin
                              y[command_in[5:4]] <= command_data12 ;
                              draw_cmd_tx        <= 1'b0           ; // No command to transmit
                              end
                
                8'b011111?? : begin // set 24-bit destination screen memory pointer for plotting
                    draw_cmd_func        <= CMD_OUT_DSTMADDR[3:0]  ; // sets the output function
                    draw_cmd_data_color  <= command_data8          ; // set screen_mode (bits per pixel)
                    draw_cmd_data_word_Y <= y[command_in[1:0]]     ; // sets the upper 12 bits of the destination address
                    draw_cmd_data_word_X <= x[command_in[1:0]]     ; // sets the lower 12 bits of the destination address
                    draw_cmd_tx          <= 1'b1                   ; // transmits the command
                end
             
                8'b011110?? : begin // set 24-bit source screen memory pointer for blitter copy
                    draw_cmd_func        <= CMD_OUT_SRCMADDR[3:0]  ; // sets the output function
                    draw_cmd_data_color  <= command_data8          ; // set screen_mode (bits per pixel)
                    draw_cmd_data_word_Y <= y[command_in[1:0]]     ; // sets the upper 12 bits of the destination address
                    draw_cmd_data_word_X <= x[command_in[1:0]]     ; // sets the lower 12 bits of the destination address
                    draw_cmd_tx          <= 1'b1                   ; // transmits the command
                end
                
                 8'b0111011? : begin  // Sets the blitter source offset X&Y position with x/y[2&3]
                    blit_source_ofs_x    <= x[{1'b1,command_in[0]}]     ; // sets the upper 12 bits of the destination address
                    blit_source_ofs_y    <= y[{1'b1,command_in[0]}]     ; // sets the lower 12 bits of the destination address
                    draw_cmd_tx          <= 1'b0                        ; // do not transmits the command
                end

                 8'b0111010? : begin  // Sets the blitter copy width and height with x/y[2&3]
                    blit_width           <= x[{1'b1,command_in[0]}]     ; // sets the upper 12 bits of the destination address
                    blit_height          <= y[{1'b1,command_in[0]}]     ; // sets the lower 12 bits of the destination address
                    draw_cmd_tx          <= 1'b0                        ; // do not transmits the command
                end
              
                8'd115 : begin  // set the number of bytes per horizontal line in the destination raster
                    draw_cmd_func        <= CMD_OUT_DSTRWDTH[3:0]  ; // sets the output function
                    draw_cmd_data_color  <= command_data8          ; // set bitplane mode (bits per pixel)
                    draw_cmd_data_word_Y <= y[2]                   ; // null
                    draw_cmd_data_word_X <= x[2]                   ; // sets the lower 12 bits of the destination address
                    draw_cmd_tx          <= 1'b1                   ; // transmits the command
                end
                
                8'd114 : begin  // set the number of bytes per horizontal line in the source raster
                    draw_cmd_func        <= CMD_OUT_SRCRWDTH[3:0]  ; // sets the output function
                    draw_cmd_data_color  <= command_data8          ; // set bitplane mode (bits per pixel)
                    draw_cmd_data_word_Y <= y[2]                   ; // sets the lower 12 bits of the destination address
                    draw_cmd_data_word_X <= x[2]                   ; // null
                    draw_cmd_tx          <= 1'b1                   ; // transmits the command
                end
                    
                8'd113 : begin  // set the number of bytes per horizontal line in the destination raster
                    draw_cmd_func        <= CMD_OUT_DSTRWDTH[3:0]  ; // sets the output function
                    draw_cmd_data_color  <= command_data8          ; // set bitplane mode (bits per pixel)
                    draw_cmd_data_word_Y <= y[3]                   ; // null
                    draw_cmd_data_word_X <= x[3]                   ; // sets the lower 12 bits of the destination address
                    draw_cmd_tx          <= 1'b1                   ; // transmits the command
                end
                    
                8'd112 : begin  // set the number of bytes per horizontal line in the source raster
                    draw_cmd_func        <= CMD_OUT_SRCRWDTH[3:0]  ; // sets the output function
                    draw_cmd_data_color  <= command_data8          ; // set bitplane mode (bits per pixel)
                    draw_cmd_data_word_Y <= y[3]                   ; // sets the lower 12 bits of the destination address
                    draw_cmd_data_word_X <= x[3]                   ; // null
                    draw_cmd_tx          <= 1'b1                   ; // transmits the command
                end

                8'd95  : begin
                    max_x <= x[0] ;    // set max width & height of screen to x0/y0
                    max_y <= y[0] ;
                    draw_cmd_tx          <= 1'b0                        ; // do not transmits the command
                    //********************  no command to be set......draw_cmd_tx <= 1'b1;
                end
                
                8'd94  : begin
                    max_x <= x[1] ;    // set max width & height of screen to x1/y1
                    max_y <= y[1] ;
                    draw_cmd_tx          <= 1'b0                        ; // do not transmits the command
                    //********************  no command to be set......draw_cmd_tx <= 1'b1;
                end
                
                8'd93  : begin
                    max_x <= x[2] ; // set max width & height of screen to x2/y2
                    max_y <= y[2] ;
                    draw_cmd_tx          <= 1'b0                        ; // do not transmits the command
                    //********************  no command to be set......draw_cmd_tx <= 1'b1;
                end
                
                8'd92 : begin
                    max_x <= x[3] ; // set max width & height of screen to x3/y3
                    max_y <= y[3] ;
                    draw_cmd_tx          <= 1'b0                        ; // do not transmits the command
                    //********************  no command to be set......draw_cmd_tx <= 1'b1;
                end
                        
                8'd91 : begin               // clear the pixel collision counter and sets all 3 transparent mask colors to 1 8-bit color in the source function data
                    draw_cmd_func        <= CMD_OUT_RST_PXWRI_M[3:0]                   ; // sets the output funtion
                    draw_cmd_data_color  <= command_data8                              ; // sets the mask color
                    draw_cmd_data_word_Y <= { command_data8[7:0], command_data8[7:4] } ; // sets mask color #2 and 1/2 or #3
                    draw_cmd_data_word_X <= { command_data8[3:0], command_data8[7:4] } ; // sets mask color 1/2 or #3 and #4
                    draw_cmd_tx          <= 1'b1                                       ; // transmits the command
                end
                
                8'd90 : begin               // clear the blitter copy pixel collision counter
                    draw_cmd_func        <= CMD_OUT_RST_PXPASTE_M[3:0]                 ; // sets the output funtion
                    draw_cmd_data_color  <= command_data8                              ; // sets the mask color
                    draw_cmd_data_word_Y <= { command_data8[7:0], command_data8[7:4] } ; // sets mask color #2 and 1/2 or #3
                    draw_cmd_data_word_X <= { command_data8[3:0], command_data8[7:4] } ; // sets mask color 1/2 or #3 and #4
                    draw_cmd_tx          <= 1'b1                                       ; // transmits the command
                end

                default : begin
                    draw_cmd_tx          <= 1'b0  ; // no command to transmit
                end

            endcase
            
        end else draw_cmd_tx          <= 1'b0  ; // !load_cmd
      end // !plot_busy
    end // !draw_busy

end //always @(posedge clk)

endmodule



/*
 * poly_plot module
 *
 * renders lines and fills
 *
 */
module poly_plot #(parameter bit USE_ALTERA_IP = 1) (
// inputs
    input logic                 clk              ,
    input logic                 reset            ,
    input logic                 enable           , // !pixel_writer busy input
    input logic                 blitter_busy     , // When high, pause the linegens
    input logic                 cmd_rdy_in       ,
    input logic          [15:0] cmd_in           ,
    input wire    signed [11:0] x_in [0:3]       , // values to plot
    input wire    signed [11:0] y_in [0:3]       , // values to plot
    
    input logic                 hse              , // horizontal video enable
    input logic                 vse              , // vertical video enable
//outputs
    output logic                pixel_ena        ,
    output logic         [7:0]  pixel_col        ,
    output logic  signed [11:0] pixel_xy [0:1]   , // Destination coordinates
    output logic                plotter_busy     , // The linegens are running
    output logic         [7:0]  blit_features_out, // Defines the blitter module features
    output logic         [7:0]  blit_mask_col_out, // Tells the blitter copy pixel function how to transpose the source pixel color
                                                   // Remember when writing a pixel/line/un-filled triangle/box/quad, the set color does a second
                                                   // color transpose from the copy pixel to the destination pixel color.
    output logic        [12:0]  blit_src_scale_x , // Holds the X blitter source upscale fraction, IE zoom ratio (4096:blit_src_scale_x), values 4095 through 1, or 4096 for off.
    output logic        [12:0]  blit_src_scale_y , // Holds the Y blitter source upscale fraction, IE zoom ratio (4096:blit_src_scale_y), values 4095 through 1, or 4096 for off.
    output logic        [12:0]  blit_dest_scale_x, // Holds the X blitter destination downscale fraction, IE zoom ratio (blit_dest_scale_x:4096), values 4095 through 1, or 4096 for off.
    output logic        [12:0]  blit_dest_scale_y  // Holds the Y blitter destination downscale fraction, IE zoom ratio (blit_dest_scale_y:4096), values 4095 through 1, or 4096 for off.
);

logic [1:0] sort_tri     [0:2]  ;
logic [1:0] sort_tri_mm  [0:1]  ;
logic [1:0] sort_quad    [0:2]  ;
logic [1:0] sort_quad_mm [0:1]  ;

logic       draw_ellipse     = 0  ; // When high, line_gen0 will be switched to the ellipse generator.
logic       ellipse_filled   = 0  ; // When high, ellipse generator will do a horizontal raster fill.
logic [1:0] ellipse_quadrant = 0  ; // selects 1 of 4 quadrants for the ellipse to draw.

poly_sort sorter (
// inputs
    .x_in        ( x_in      ), // values to sort
    .y_in        ( y_in      ), // values to sort
//outputs
    .sort_tri     ( sort_tri     ), // Array containing 3 sorted pointers, 1 for linegen 0 and 2 sequences for linegen 1 to generate a filled triangle using xy[0,1,2].
    .sort_tri_mm  ( sort_tri_mm  ), // Array containing 2 sorted pointers for the triangle's min Y coordinate and max Y coordinate when rendering using xy[0,1,2].
    .sort_quad    ( sort_quad    ), // Array containing 3 sorted pointers, 1 for linegen 0 and 2 sequences for linegen 1 to generate a filled triangle using xy[1,2,3].
    .sort_quad_mm ( sort_quad_mm )  // Array containing 2 sorted pointers for the triangle's min Y coordinate and max Y coordinate when rendering using xy[1,2,3].
);

logic signed [11:0] lg_out [0:3]                 ;  // XY output coordinates of all line generators
logic        [1:0]  lg_running                   ;  // Flags stating which linegens are running
logic        [1:0]  lg_pix_rdy                   ;  // Flags which linegens have ready pixels
logic        [1:0]  lg_start          = 0        ;  // Initializes the linegens to begin
logic        [1:0]  lg_pause          = 0        ;  // Freezes the lingen while they are ijn the middle of drawing
logic        [1:0]  lg_seq_cnt [0:1]  = '{2{0}}  ; // Linegen sequence counters
logic        [3:0]  lg_csel    [0:3]  = '{4{0}}  ; // Selects which xy[#] coordinates to use for linegen0 A,B - linegen1 A,B
logic        [3:0]  lg_csel_b  [0:3]  = '{4{0}}  ; // Holds which xy[#] selection will be used for second sequence line to be drawn.

gen_sel_line_ellipse #(.USE_ALTERA_IP(USE_ALTERA_IP)) linegen_0 (
    // inputs
    .clk            ( clk                ), // 125 MHz pixel clock
    .reset          ( reset              ), // asynchronous reset
    .enable         ( enable && !blitter_busy ),  // Allows processing
    .sel_ellipse    ( draw_ellipse       ),       // High = draw ellipse, low = draw line.
    .run            ( lg_start[0]        ),       // HIGH during drawing
    .quadrant       ( ellipse_quadrant   ),       // Select 1 of 4 ellipse quadrants to draw
    .ellipse_filled ( ellipse_filled     ),       // Horizontal fill in ellipse.
    .aX             ( x_in[lg_csel[2'd0][3:2]] ), // 12-bit X-coordinate for line start
    .aY             ( y_in[lg_csel[2'd0][1:0]] ), // 12-bit Y-coordinate for line start
    .bX             ( x_in[lg_csel[2'd1][3:2]] ), // 12-bit X-coordinate for line end
    .bY             ( y_in[lg_csel[2'd1][1:0]] ), // 12-bit Y-coordinate for line end
    .ena_pause      ( lg_pause[0]        ), // set HIGH to pause line generator while it is drawing
    // outputs
    .busy           ( lg_running[0]      ), // HIGH when line_generator is running
    .X_coord        ( lg_out[2'b00]      ), // 12-bit X-coordinate for current pixel
    .Y_coord        ( lg_out[2'b01]      ), // 12-bit Y-coordinate for current pixel
    .pixel_data_rdy ( lg_pix_rdy[0]      ), // HIGH when coordinate outputs are valid
    .line_complete  (                    )  // HIGH when line is completed
);

line_generator linegen_1 (
    // inputs
    .clk            ( clk                ), // 125 MHz pixel clock
    .reset          ( reset              ), // asynchronous reset
    .enable         ( enable && !blitter_busy ),  // Allows processing
    .run            ( lg_start[1]        ),       // HIGH during drawing
    .aX             ( x_in[lg_csel[2'd2][3:2]] ), // 12-bit X-coordinate for line start
    .aY             ( y_in[lg_csel[2'd2][1:0]] ), // 12-bit Y-coordinate for line start
    .bX             ( x_in[lg_csel[2'd3][3:2]] ), // 12-bit X-coordinate for line end
    .bY             ( y_in[lg_csel[2'd3][1:0]] ), // 12-bit Y-coordinate for line end
    .ena_pause      ( lg_pause[1]        ), // set HIGH to pause line generator
    // outputs
    .busy           ( lg_running[1]      ), // HIGH when line_generator is running
    .X_coord        ( lg_out[2'b10]      ), // 12-bit X-coordinate for current pixel
    .Y_coord        ( lg_out[2'b11]      ), // 12-bit Y-coordinate for current pixel
    .pixel_data_rdy ( lg_pix_rdy[1]      ), // HIGH when coordinate outputs are valid
    .line_complete  (                    )  // HIGH when line is completed
);

logic               execute_next_draw = 0 ; // goes high only when ready to accept a new command
logic               linegen_busy      = 0 ; // 
logic               fill_ena          = 0 ; // 

logic signed [11:0] y_pos             = 0 ; // Current raster Y position counter
logic signed [11:0] y_end             = 0 ; // Y raster fill ending position
logic signed [11:0] x_pos             = 0 ; // Current raster X position counter
logic signed [11:0] x_pos_bk          = 0 ; // Restore raster X position after a Y increment.
logic signed [11:0] x_end             = 0 ; // X raster fill ending coordinates
logic               rast_fill_pix_rdy = 0 ;

// Wait for frame or video line logic regs
logic         wait_int             = 1'b0  ;
logic [1:0]   hse_reg              = 2'b0  ;
logic [1:0]   vse_reg              = 2'b0  ;
logic         hs_dec1              = 1'b0  ;
logic [3:0]   vw_counter           = 4'd0  ;
logic [10:0]  hw_position          = 11'd0 ;
logic [10:0]  v_position           = 11'd0 ;
logic [7:0]   hw_pos_lat           = 8'd0  ;
logic [1:0]   int_kill             = 2'd0  ;


always_comb begin
// generate drawing processing busy flags
linegen_busy      = lg_running[0] || lg_running[1] ;
execute_next_draw = cmd_rdy_in && !blitter_busy && !plotter_busy && !fill_ena ;//&& !wait_int;

// generate selection of the output write pixel port
pixel_xy[0]       = rast_fill_pix_rdy ? x_pos : (lg_out[{lg_pix_rdy[1],1'b0}]); // select between linegen0&1 X coordinates or the y_pos raster fill coordinates
pixel_xy[1]       = rast_fill_pix_rdy ? y_pos : (lg_out[{lg_pix_rdy[1],1'b1}]); // select between linegen0&1 Y coordinates or the y_pos raster fill coordinates
pixel_ena         = lg_pix_rdy[0] || lg_pix_rdy[1] || rast_fill_pix_rdy ;       // output pixel enable

end

always_ff @(posedge clk /* or posedge reset */) begin

    if ( reset ) begin  // Reset only the key controls in the command pipe.
         blit_features_out   <= 0;
         blit_mask_col_out   <= 0;
         lg_seq_cnt[0]       <= 0;
         lg_seq_cnt[1]       <= 0;
         lg_start[0]         <= 1'b0 ;              // clear the 1-shot line start
         lg_start[1]         <= 1'b0 ;              // clear the 1-shot line start
         fill_ena            <= 1'b0 ;              // clear the 1-shot line start
         rast_fill_pix_rdy   <= 1'd0 ;
         blit_src_scale_x    <= 13'd4096 ; // Holds the X blitter source upscale fraction, 4096 = 1:1, IE disable.
         blit_src_scale_y    <= 13'd4096 ; // Holds the Y blitter source upscale fraction, 4096 = 1:1, IE disable.
         blit_dest_scale_x   <= 13'd4096 ; // Holds the X blitter destination downscale fraction, 4096 = 1:1, IE disable.
         blit_dest_scale_y   <= 13'd4096 ; // Holds the Y blitter destination downscale fraction, 4096 = 1:1, IE disable.
         draw_ellipse        <= 1'b0     ; // Select between line_generator and ellipse_generator.
         ellipse_quadrant    <= 2'd0     ; // Select which quadrant the ellipse will draw.

        wait_int             <= 1'b0 ;
        hse_reg              <= 2'd0 ;
        vse_reg              <= 2'd0 ;
        hs_dec1              <= 1'b0 ;
        vw_counter[3:0]      <= 4'd0 ;
        hw_position[10:0]    <= 11'd0 ;
        v_position[10:0]     <= 11'd0 ;
        hw_pos_lat[7:0]      <= 8'd0 ;
        int_kill             <= 2'd0;
        plotter_busy         <= 1'd0 ;
        pixel_col            <= 0;
        blit_features_out    <= 0;


    end // reset
    else

// Wait for any set horizontal line number hw_position after set number of vw_counter.
// If hw_position is never reached for 2 consecutive vertical syncs, int_kill is decremented to 0.
hse_reg[1:0] <= {hse_reg[0],hse};
vse_reg[1:0] <= {vse_reg[0],vse};

     if          (vse_reg == 2'b10)  begin
                                     v_position  <= 11'd0 ;                           // clear the vertical position
                                     if (int_kill!=2'd0) int_kill <= int_kill - 1'd1; // decrement the wait killer
     end else if (hse_reg == 2'b10)  begin
                                                                                v_position  <= v_position + 1'b1 ;  // increment the vertical position
                                          if (hw_position != v_position)        hs_dec1     <= 1'b0;                // clear the single incrementr
                                     else if (hw_position == v_position && !hs_dec1) begin
                                                                                if (vw_counter != 4'd0) vw_counter <= vw_counter - 1'b1 ; // decrement the vertical wait counter at end of display frame
                                                                                hs_dec1  <= 1'b1;
                                                                                int_kill <= 2'd2; // reset the wait timer killer
                                                                                end
                                     end

if (wait_int) begin // When waiting

  if ( (vw_counter == 4'd0) || (int_kill == 2'd0) ) begin // if vw_counter has reached 0 or int_kill has reached 0
                          wait_int     <= 1'b0 ; // End vertical or horizontal wait
                          plotter_busy <= 1'd0 ; // Tell the rest of the geometry processor that the plotter ready
                          end
end else
  if ( enable && !blitter_busy ) begin

if (lg_start[0]) begin
  lg_seq_cnt[0] <= lg_seq_cnt[0]-1'b1; // subtract counter after linegen has been executed
  lg_start[0]   <= 1'b0 ;              // clear the 1-shot line start
  lg_csel[0]    <= lg_csel_b[0] ;      // Switch over the xy[#] selection index to the second line's coordinates
  lg_csel[1]    <= lg_csel_b[1] ;      // Switch over the xy[#] selection index to the second line's coordinates
  end
if (lg_start[1]) begin
  lg_seq_cnt[1] <= lg_seq_cnt[1]-1'b1; // subtract counter after linegen has been executed
  lg_start[1]   <= 1'b0 ;              // clear the 1-shot line start
  lg_csel[2]    <= lg_csel_b[2] ;      // Switch over the xy[#] selection index to the second line's coordinates
  lg_csel[3]    <= lg_csel_b[3] ;      // Switch over the xy[#] selection index to the second line's coordinates
  end


// ***************************************************************************************************
// Decode drawing commands and prep linegens for drawing.
// ***************************************************************************************************

if (execute_next_draw) begin

        if (cmd_in[15:8]  == 8'd0)  blit_features_out <= cmd_in[7:0]; // Just set the blitter features
   else if (cmd_in[15:8]  == 8'd7)  begin
                                              if (cmd_in[7:2]==6'd0) ellipse_quadrant  <= cmd_in[1:0]; // Set which ellipse quadrant to render.
                                              if (cmd_in[7]) begin
                                                             vw_counter[3:0]   <= cmd_in[3:0]; // Set the number of vertical frames to wait for.
                                                             if (cmd_in[3:0]!=4'd0) begin
                                                                                    wait_int           <= 1'd1 ; // Turn on the wait for vertical frames
                                                                                    plotter_busy       <= 1'd1 ; // Tell the rest of the geometry processor that the plotter is just busy
                                                                                    int_kill           <= 2'd2; // reset the wait timer killer
                                                                                    hw_position[10:0]  <= hw_pos_lat[7:0] << cmd_in[5:4] ;
                                                                                    end
                                                             end
                                    end
   else if (cmd_in[15:8]  == 8'd15) hw_pos_lat[7:0]   <= cmd_in[7:0]; // Set the wait for horizontal lines after display ends.
   else if (cmd_in[15:8]  == 8'd8)  blit_mask_col_out <= cmd_in[7:0]; // Just set the blitter transparency mask color
   else if (cmd_in[15:8]  == 8'd9)  begin                             // Set blitter scale
      if (cmd_in[0]) begin // enable setting of source scale
        if ( x_in[0]==0 )  blit_src_scale_x    <= 13'd4096        ; // If the register is 0, turn off scale factor by using 4096
        else               blit_src_scale_x    <= {1'b0,x_in[0]}  ; // Otherwize, set the scale factor to 1 through 4095.
        if ( y_in[0]==0 )  blit_src_scale_y    <= 13'd4096        ; // If the register is 0, turn off scale factor by using 4096
        else               blit_src_scale_y    <= {1'b0,y_in[0]}  ; // Otherwize, set the scale factor to 1 through 4095.
      end
      if (cmd_in[1]) begin // enable setting of source scale
        if ( x_in[1]==0 )  blit_dest_scale_x   <= 13'd4096        ; // If the register is 0, turn off scale factor by using 4096
        else               blit_dest_scale_x   <= {1'b0,x_in[1]}  ; // Otherwize, set the scale factor to 1 through 4095.
        if ( y_in[1]==0 )  blit_dest_scale_y   <= 13'd4096        ; // If the register is 0, turn off scale factor by using 4096
        else               blit_dest_scale_y   <= {1'b0,y_in[1]}  ; // Otherwize, set the scale factor to 1 through 4095.
      end
   end
   else if (cmd_in[15:12] == 4'd0) begin                             // Any other valid plotting draw command
    
        plotter_busy      <= 1 ;           // Tell the rest of the geometry processor that the plotter is going to draw
        pixel_col         <= cmd_in[7:0];  // set the output drawing color

   if ( cmd_in[10:8] == 3'd1 ) begin                 // Draw a dot
                       lg_seq_cnt[0]     <= 2'd1          ; // Linegen 0 has 1 line to draw
                       lg_csel[2'd0]     <= {2'd0,2'd0}   ; // Linegen 0's first  line's A coordinate = xy[0]
                       lg_csel[2'd1]     <= {2'd0,2'd0}   ; // Linegen 0's first  line's B coordinate = xy[0]
                       lg_csel_b[2'd0]   <= {2'd0,2'd0}   ; // Linegen 0's second line's A coordinate = xy[0]   *un-used
                       lg_csel_b[2'd1]   <= {2'd0,2'd0}   ; // Linegen 0's second line's B coordinate = xy[0]   *un-used

                       lg_seq_cnt[1]     <= 2'd0          ; // Linegen 1 has no line to draw
                       lg_csel[2'd2]     <= {2'd0,2'd0}   ; // Linegen 1's first  line's A coordinate = xy[0]   *un-used
                       lg_csel[2'd2]     <= {2'd0,2'd0}   ; // Linegen 1's first  line's B coordinate = xy[0]   *un-used
                       lg_csel_b[2'd3]   <= {2'd0,2'd0}   ; // Linegen 1's second line's A coordinate = xy[0]   *un-used
                       lg_csel_b[2'd3]   <= {2'd0,2'd0}   ; // Linegen 1's second line's B coordinate = xy[0]   *un-used

                       fill_ena          <= 1'b0   ; // turn off the filled flag

                       lg_start[0]       <= 1'b1;   // Start linegen 0 immediately.
                       lg_pause[0]       <= 1'b0;
                       lg_pause[1]       <= 1'b1;
                       draw_ellipse      <= 1'b0;   // Select between line_generator instead of ellipse_generator.
                       end

   else if ( cmd_in[10:8] == 3'd2 ) begin                   // Draw a line
                       lg_seq_cnt[0]     <= 2'd1          ; // Linegen 0 has 1 line to draw
                       lg_csel[2'd0]     <= {2'd0,2'd0}   ; // Linegen 0's first  line's A coordinate = xy[0]
                       lg_csel[2'd1]     <= {2'd1,2'd1}   ; // Linegen 0's first  line's B coordinate = xy[1]
                       lg_csel_b[2'd0]   <= {2'd0,2'd0}   ; // Linegen 0's second line's A coordinate = xy[0]   *un-used
                       lg_csel_b[2'd1]   <= {2'd0,2'd0}   ; // Linegen 0's second line's B coordinate = xy[0]   *un-used

                       lg_seq_cnt[1]     <= 2'd0          ; // Linegen 1 has no line to draw
                       lg_csel[2'd2]     <= {2'd0,2'd0}   ; // Linegen 1's first  line's A coordinate = xy[0]   *un-used
                       lg_csel[2'd2]     <= {2'd0,2'd0}   ; // Linegen 1's first  line's B coordinate = xy[0]   *un-used
                       lg_csel_b[2'd3]   <= {2'd0,2'd0}   ; // Linegen 1's second line's A coordinate = xy[0]   *un-used
                       lg_csel_b[2'd3]   <= {2'd0,2'd0}   ; // Linegen 1's second line's B coordinate = xy[0]   *un-used

                       fill_ena          <= 1'b0   ; // turn off the filled flag
                       lg_start[0]       <= 1'b1;    // Start linegen 0 immediately.
                       lg_pause[0]       <= 1'b0;
                       lg_pause[1]       <= 1'b1;
                       draw_ellipse      <= 1'b0;    // Select between line_generator instead of ellipse_generator.
                       end

// Vertex order of a filled triangle.
//
// xy[0]----xy[1]
//   |      /  
//   |     /       
//   |    /         
//   |   /     
//   |  /     
//   | /     
// xy[2]    xy[3] N/A
//
   else if ( cmd_in[10:8] == 3'd3 ) begin                               // Draw a triangle   *** See sorter which organizes the linegen selection
                       lg_seq_cnt[0]     <= 2'd1                      ; // Linegen 0 has 1 line to draw
                       lg_csel[2'd0]     <= {sort_tri[0],sort_tri[0]} ; // Linegen 0's first  line's A coordinate = sorted xy[0]
                       lg_csel[2'd1]     <= {sort_tri[2],sort_tri[2]} ; // Linegen 0's first  line's B coordinate = sorted xy[2]
                       lg_csel_b[2'd0]   <= {2'd0,2'd0}               ; // Linegen 0's second line's A coordinate = xy[0]   *un-used
                       lg_csel_b[2'd1]   <= {2'd0,2'd0}               ; // Linegen 0's second line's B coordinate = xy[0]   *un-used

                       lg_seq_cnt[1]     <= 2'd2                      ; // Linegen 1 has 2 lines to draw
                       lg_csel[2'd2]     <= {sort_tri[0],sort_tri[0]} ; // Linegen 1's first  line's A coordinate = sorted xy[0]
                       lg_csel[2'd3]     <= {sort_tri[1],sort_tri[1]} ; // Linegen 1's first  line's B coordinate = sorted xy[1]
                       lg_csel_b[2'd2]   <= {sort_tri[1],sort_tri[1]} ; // Linegen 1's second line's A coordinate = sorted xy[1]
                       lg_csel_b[2'd3]   <= {sort_tri[2],sort_tri[2]} ; // Linegen 1's second line's B coordinate = sorted xy[2]

                       fill_ena          <= cmd_in[11]           ; // Set the filled flag
                       y_pos             <= y_in[sort_tri_mm[0]] ; // Set the fill Y raster position starting coordinate
                       y_end             <= y_in[sort_tri_mm[1]] ; // Set the fill Y raster position ending coordinate
                       x_pos             <= x_in[sort_tri_mm[0]] ; // Set the X raster position starting coordinate
                       x_pos_bk          <= x_in[sort_tri_mm[0]] ; // Set the X raster position starting coordinate
                       x_end             <= x_in[sort_tri_mm[0]] ; // Set the X raster position ending coordinate

                       lg_start[0]       <= 1'b1;   // Start linegen 0 immediately.
                       lg_pause[0]       <= 1'b0;
                       lg_pause[1]       <= 1'b1;
                       draw_ellipse      <= 1'b0; // Select between line_generator instead of ellipse_generator.
                       end  // triangle

   else if ( cmd_in[10:8] == 3'd4 ) begin                 // Draw a box

// Vertex order of a non filled & filled box
//
// xy[00] -L0f- xy[10]
//   |            |       L#f means the linegen# running the first lg_csel coordinates
//  L1s          L0s
//   |            |       L#s means the linegen# running the second lg_csel_b coordinates
// xy[01] -l1f- xy[11]
//
            if (!cmd_in[11]) begin                          // A non-filled box, draw all 4 lines
                       lg_seq_cnt[0]     <= 2'd2          ; // Linegen 0 has 2 lines to draw
                       lg_csel[2'd0]     <= {2'd0,2'd0}   ; // Linegen 0's first  line's A coordinate = xy[00]
                       lg_csel[2'd1]     <= {2'd1,2'd0}   ; // Linegen 0's first  line's B coordinate = xy[10]
                       lg_csel_b[2'd0]   <= {2'd1,2'd0}   ; // Linegen 0's second line's A coordinate = xy[10]
                       lg_csel_b[2'd1]   <= {2'd1,2'd1}   ; // Linegen 0's second line's B coordinate = xy[11]

                       lg_seq_cnt[1]     <= 2'd2          ; // Linegen 1 has 2 lines to draw
                       lg_csel[2'd2]     <= {2'd1,2'd1}   ; // Linegen 1's first  line's A coordinate = xy[11]
                       lg_csel[2'd3]     <= {2'd0,2'd1}   ; // Linegen 1's first  line's B coordinate = xy[01]
                       lg_csel_b[2'd2]   <= {2'd0,2'd1}   ; // Linegen 1's second line's A coordinate = xy[01]
                       lg_csel_b[2'd3]   <= {2'd0,2'd0}   ; // Linegen 1's second line's B coordinate = xy[00]
                       end // non-filled box

// Vertex order of a filled box
//
// xy[00] **** xy[10]
//   |    ****    |
//  L0f   ****   L1f       L#f means the linegen# running the first lg_csel coordinates only
//   |    ****    |        **** is the area filled by the raster fill.
// xy[01] **** xy[11]
//
                       else begin                          // Draw the second half of a filled quadrilateral, coordinates xy[3,2,1] instead of xy[0,1,2]
                       lg_seq_cnt[0]     <= 2'd1         ; // Linegen 0 has 1 line to draw
                       lg_csel[2'd0]     <= {2'd0,2'd0}   ; // Linegen 0's first  line's A coordinate = xy[00]
                       lg_csel[2'd1]     <= {2'd0,2'd1}   ; // Linegen 0's first  line's B coordinate = xy[01]
                       lg_csel_b[2'd0]   <= {2'd0,2'd0}   ; // Linegen 0's second line's A coordinate = xy[00]   *un-used
                       lg_csel_b[2'd1]   <= {2'd0,2'd0}   ; // Linegen 0's second line's B coordinate = xy[00]   *un-used

                       lg_seq_cnt[1]     <= 2'd1          ; // Linegen 1 has 2 lines to draw
                       lg_csel[2'd2]     <= {2'd1,2'd0}   ; // Linegen 1's first  line's A coordinate = xy[10]
                       lg_csel[2'd3]     <= {2'd1,2'd1}   ; // Linegen 1's first  line's B coordinate = xy[11]
                       lg_csel_b[2'd2]   <= {2'd0,2'd0}   ; // Linegen 1's second line's A coordinate = xy[00]   *un-used
                       lg_csel_b[2'd3]   <= {2'd0,2'd0}   ; // Linegen 1's second line's B coordinate = xy[00]   *un-used
                       end  // filled box

                       fill_ena          <= cmd_in[11]  ; // Set the filled flag
                       y_pos             <= y_in[0]     ; // Set the fill Y raster position starting coordinate
                       y_end             <= y_in[1]     ; // Set the fill Y raster position ending coordinate
                       x_pos             <= x_in[0]     ; // Set the X raster position starting coordinate
                       x_pos_bk          <= x_in[0]     ; // Set the X raster position starting coordinate
                       x_end             <= x_in[1]     ; // Set the X raster position ending coordinate

                       lg_start[0]       <= 1'b1;   // Start linegen 0 immediately.
                       lg_pause[0]       <= 1'b0;
                       lg_pause[1]       <= 1'b1;
                       draw_ellipse      <= 1'b0;    // Select between line_generator instead of ellipse_generator.
                       end // Any box

   else if ( cmd_in[10:8] == 3'd5 ) begin                 // Draw a quadrilateral

// Vertex order of a non filled quadrilateral
//
// xy[0] -L0f- xy[1]
//   |           |       L#f means the linegen# running the first lg_csel coordinates
//  L1s         L0s
//   |           |       L#s means the linegen# running the second lg_csel_b coordinates
// xy[2] -l1f- xy[3]
//
            if (!cmd_in[11]) begin                          // A non-filled quadrilateral, draw all 4 lines
                       lg_seq_cnt[0]     <= 2'd2          ; // Linegen 0 has 2 lines to draw

                       if ( y_in[0] > y_in[1] ) begin     ; // Check to see what direction line 1 of 4 would be drawn if it were drawn as a sorted quad and match it
                       lg_csel[2'd0]     <= {2'd1,2'd1}   ; // Linegen 0's first  line's A coordinate = xy[1]
                       lg_csel[2'd1]     <= {2'd0,2'd0}   ; // Linegen 0's first  line's B coordinate = xy[0]
                       end else begin                     ; // Reverse the line drawing direction for line 1 of 4.
                       lg_csel[2'd0]     <= {2'd0,2'd0}   ; // Linegen 0's first  line's A coordinate = xy[0]
                       lg_csel[2'd1]     <= {2'd1,2'd1}   ; // Linegen 0's first  line's B coordinate = xy[1]
                       end

                       if ( y_in[1] > y_in[3] ) begin     ; // Check to see what direction line 2 of 4 would be drawn if it were drawn as a sorted quad and match it
                       lg_csel_b[2'd0]   <= {2'd3,2'd3}   ; // Linegen 0's second line's A coordinate = xy[3]
                       lg_csel_b[2'd1]   <= {2'd1,2'd1}   ; // Linegen 0's second line's B coordinate = xy[1]
                       end else begin                     ; // Reverse the line drawing direction for line 2 of 4.
                       lg_csel_b[2'd0]   <= {2'd1,2'd1}   ; // Linegen 0's second line's A coordinate = xy[1]
                       lg_csel_b[2'd1]   <= {2'd3,2'd3}   ; // Linegen 0's second line's B coordinate = xy[3]
                       end

                       lg_seq_cnt[1]     <= 2'd2          ; // Linegen 1 has 2 lines to draw

                       if ( y_in[2] > y_in[3] ) begin     ; // Check to see what direction line 3 of 4 would be drawn if it were drawn as a sorted quad and match it
                       lg_csel[2'd2]     <= {2'd3,2'd3}   ; // Linegen 1's first  line's A coordinate = xy[3]
                       lg_csel[2'd3]     <= {2'd2,2'd2}   ; // Linegen 1's first  line's B coordinate = xy[2]
                       end else begin                     ; // Reverse the line drawing direction for line 3 of 4.
                       lg_csel[2'd2]     <= {2'd2,2'd2}   ; // Linegen 1's first  line's A coordinate = xy[2]
                       lg_csel[2'd3]     <= {2'd3,2'd3}   ; // Linegen 1's first  line's B coordinate = xy[3]
                       end

                       if ( y_in[0] > y_in[2] ) begin     ; // Check to see what direction line 4 of 4 would be drawn if it were drawn as a sorted quad and match it
                       lg_csel_b[2'd2]   <= {2'd2,2'd2}   ; // Linegen 1's second line's A coordinate = xy[2]
                       lg_csel_b[2'd3]   <= {2'd0,2'd0}   ; // Linegen 1's second line's B coordinate = xy[0]
                       end else begin                     ; // Reverse the line drawing direction for line 4 of 4.
                       lg_csel_b[2'd2]   <= {2'd0,2'd0}   ; // Linegen 1's second line's A coordinate = xy[0]
                       lg_csel_b[2'd3]   <= {2'd2,2'd2}   ; // Linegen 1's second line's B coordinate = xy[2]
                       end

                       end // non-filled quadrilateral

// Vertex order of a filled quadrilateral, command sent after filled triangle.
// *** xy[0,1,2] was drawn with a filled triangle
//
// xy[0]    xy[1]
//  N/A     / |
//         /  |    *** See sorter which organizes the linegen selection
//        /   |        Subtract 1 for each position
//       /    |
// xy[2] -- xy[3]
//
                       else begin                                         // Draw the second half of a filled quadrilateral, coordinates xy[1,2,3] instead of xy[0,1,2]
                       lg_seq_cnt[0]     <= 2'd1                        ; // Linegen 0 has 1 line to draw
                       lg_csel[2'd0]     <= {sort_quad[0],sort_quad[0]} ; // Linegen 0's first  line's A coordinate = sorted xy[0]
                       lg_csel[2'd1]     <= {sort_quad[2],sort_quad[2]} ; // Linegen 0's first  line's B coordinate = sorted xy[2]
                       lg_csel_b[2'd0]   <= {2'd0,2'd0}                 ; // Linegen 0's second line's A coordinate = xy[0]   *un-used
                       lg_csel_b[2'd1]   <= {2'd0,2'd0}                 ; // Linegen 0's second line's B coordinate = xy[0]   *un-used

                       lg_seq_cnt[1]     <= 2'd2                        ; // Linegen 1 has 2 lines to draw
                       lg_csel[2'd2]     <= {sort_quad[0],sort_quad[0]} ; // Linegen 1's first  line's A coordinate = sorted xy[0]
                       lg_csel[2'd3]     <= {sort_quad[1],sort_quad[1]} ; // Linegen 1's first  line's B coordinate = sorted xy[1]
                       lg_csel_b[2'd2]   <= {sort_quad[1],sort_quad[1]} ; // Linegen 1's second line's A coordinate = sorted xy[1]
                       lg_csel_b[2'd3]   <= {sort_quad[2],sort_quad[2]} ; // Linegen 1's second line's B coordinate = sorted xy[2]
                       end  // filled quadrilateral

                       fill_ena          <= cmd_in[11]            ; // Set the filled flag
                       y_pos             <= y_in[sort_quad_mm[0]] ; // Set the Y raster position starting coordinate
                       y_end             <= y_in[sort_quad_mm[1]] ; // Set the Y raster position ending coordinate
                       x_pos             <= x_in[sort_quad_mm[0]] ; // Set the X raster position starting coordinate
                       x_pos_bk          <= x_in[sort_quad_mm[0]] ; // Set the X raster position starting coordinate
                       x_end             <= x_in[sort_quad_mm[0]] ; // Set the X raster position ending coordinate

                       lg_start[0]       <= 1'b1;   // Start linegen 0 immediately.
                       lg_pause[0]       <= 1'b0;
                       lg_pause[1]       <= 1'b1;
                       draw_ellipse      <= 1'b0;    // Select between line_generator instead of ellipse_generator.
                       end // Any Quadrilateral

   else if ( cmd_in[10:8] == 3'd6 ) begin                   // Draw an ellipse
                       lg_seq_cnt[0]     <= 2'd1          ; // Linegen 0 has 1 line to draw
                       lg_csel[2'd0]     <= {2'd0,2'd0}   ; // Linegen 0's first  line's A coordinate = xy[0]
                       lg_csel[2'd1]     <= {2'd1,2'd1}   ; // Linegen 0's first  line's B coordinate = xy[1]
                       lg_csel_b[2'd0]   <= {2'd0,2'd0}   ; // Linegen 0's second line's A coordinate = xy[0]   *un-used
                       lg_csel_b[2'd1]   <= {2'd0,2'd0}   ; // Linegen 0's second line's B coordinate = xy[0]   *un-used

                       lg_seq_cnt[1]     <= 2'd0          ; // Linegen 1 has no line to draw
                       lg_csel[2'd2]     <= {2'd0,2'd0}   ; // Linegen 1's first  line's A coordinate = xy[0]   *un-used
                       lg_csel[2'd2]     <= {2'd0,2'd0}   ; // Linegen 1's first  line's B coordinate = xy[0]   *un-used
                       lg_csel_b[2'd3]   <= {2'd0,2'd0}   ; // Linegen 1's second line's A coordinate = xy[0]   *un-used
                       lg_csel_b[2'd3]   <= {2'd0,2'd0}   ; // Linegen 1's second line's B coordinate = xy[0]   *un-used

                       fill_ena          <= 1'b0   ;      // turn off the filled flag
                       lg_start[0]       <= 1'b1;         // Start linegen 0 immediately.
                       lg_pause[0]       <= 1'b0;
                       lg_pause[1]       <= 1'b1;
                       draw_ellipse      <= 1'b1;         // Select between line_generator instead of ellipse_generator.
                       ellipse_filled    <= cmd_in[11]  ; // Specialized fill command for a filled ellipse.
                       end // Any ellipse

   end // Any other valid plotting draw command
end // if (execute_next_draw)

   else if (plotter_busy) begin // A draw plot command is to be run

  if ( !fill_ena  ) begin // run the 2 linegens in a sequential manner, 1 after the other.

if (!linegen_busy) begin
      if ( lg_seq_cnt[0]!=0 ) begin      // If there are sequences, first run linegen 0
      lg_start[0]   <= 1'b1;
      lg_pause[0]   <= 1'b0;
      lg_pause[1]   <= 1'b1;
      end 
      else if ( lg_seq_cnt[1]!=0 ) begin // Then, if there are sequences for linegen 1, cycle them.
      lg_start[1]   <= 1'b1;
      lg_pause[0]   <= 1'b1;
      lg_pause[1]   <= 1'b0;
      end
       // Nothing left to draw, so, exit plotter_busy
       else if (!linegen_busy && lg_seq_cnt[0]==0 && lg_seq_cnt[1]==0 ) plotter_busy  <= 0 ;
    end
       // If linegen1 is finished and linegen0 isn't but it is paused, un-pause it.
       else if (!lg_running[1] && lg_seq_cnt[1]==0 && lg_running[0] && lg_pause[0] ) lg_pause[0] <= 0;
       // If linegen0 is finished and linegen1 isn't but it is paused, un-pause it.
       else if (!lg_running[0] && lg_seq_cnt[0]==0 && lg_running[1] && lg_pause[1] ) lg_pause[1] <= 0;

   end else begin // run the 2 linegens in a parallel fashion aligning them to a Y raster counter & fill a horizontal line between the X coordinates

if (fill_ena)
   if (!lg_running[0] && lg_seq_cnt[0]!=0 && !lg_start[1] && !lg_pause[0]) begin
         lg_start[0]       <= 1'b1;
         lg_pause[0]       <= 1'b0;
         lg_pause[1]       <= 1'b1;
   end else if (!lg_running[1] && lg_seq_cnt[1]!=0 && !lg_start[0] && !lg_pause[1]) begin
         lg_start[1]       <= 1'b1;
         lg_pause[0]       <= 1'b1;
         lg_pause[1]       <= 1'b0;
   end else begin

    if (lg_pause==2'd3) begin                              // If both linegens as paused simultaneously because both of their output Y coordinates
                                                           // sent a coordinate matching the current raster fill coordinate y_pos.
         
          if (x_pos != x_end) begin                        // if there is a void in-between the 2 linegen's X coordinates
               rast_fill_pix_rdy <= 1'b1;                  // Switch output draw pixel coordinates from linegens to fill x&y_pos coordinates
               if (x_pos > x_end ) x_pos <= x_pos - 1'b1;  // inc/dec X fill coordinate.
               else                x_pos <= x_pos + 1'b1;

           end else begin                               // if the fill is finished or there was nothing to fill

           rast_fill_pix_rdy <= 1'b0;                   // Switch output draw pixel coordinates from raster fill x&y_pos back to linegen outputs.

           if (y_pos == y_end) fill_ena <= 1'b0 ;       // if we have filled the last line, then end the flodd fill.

               if (y_pos > y_end ) y_pos <= y_pos - 1'b1;  // inc/dec X fill coordinate.
               else                y_pos <= y_pos + 1'b1;
                                   x_pos <= x_pos_bk ;     // restore X position after Y increment.

           if (lg_running[0] || lg_seq_cnt[0]!=0) lg_pause <= 2'd2; // if linegen 0 still has work to do, re-start linegen 0, freeze linegen 1
           else                                   lg_pause <= 2'd1; // Otherwise, continue linegen 1 if it has any remaining pixels.
           
           end

    end else begin

           if (lg_out[2'b01][1:0] == y_pos[1:0] && lg_pix_rdy[0] ) begin        // if linegen 0 outputs a valid Y coordinate matching the y_pos[0]
                                                 lg_pause[0] <= 1'b1;           // pause linegen 0
                                                 lg_pause[1] <= 1'b0;           // un-pause linegen 1
                                                 x_pos       <= lg_out[2'b00] ; // set the initial X fill coordinate counter
                                                 x_pos_bk    <= lg_out[2'b00] ; // set the initial X fill coordinate counter backup return position
                                                 end

           if (lg_out[2'b11][1:0] == y_pos[1:0] && lg_pix_rdy[1] ) begin        // if linegen 1 outputs a valid Y coordinate matching the y_pos[0]
                                                 lg_pause[1] <= 1'b1;           // pause linegen 1
                                                 
                                                 // This trick eliminates the linegen1's last written pixel from the raster fill by incrementing the x_end position once in the
                                                 // correct direction only if needed before the fill algorithm begins which checks to see if x_pos & x_end are equal before beginning
                                                          if (x_pos_bk == lg_out[2'b10] ) x_end       <= lg_out[2'b10]       ;  // Keep equal coordinate
                                                     else if (x_pos_bk <  lg_out[2'b10] ) x_end       <= lg_out[2'b10] - 1'b1;  // inc/dec X fill final coordinate.
                                                     else                                 x_end       <= lg_out[2'b10] + 1'b1;
                                                 end

         end
         
   end
   
end
   
   end // plotter busy loop
 end // enable
end // always_ff

endmodule

/*
 * gen_sel_line_ellipse module
 *
 * Recieved the original line_generator's module's controls
 * with the added 'sel_ellipse' and 'quadrant',
 * and then drives both the line_generator and ellipse_generator
 * and then returns the results from the selected module.
 *
 */

module gen_sel_line_ellipse #(parameter bit USE_ALTERA_IP = 1) (
// inputs
  input logic                clk,              // 125 MHz pixel clock
  input logic                reset,            // asynchronous reset
  input logic                enable,           // logic enable
  input logic                sel_ellipse,      // High = draw ellipse, low = draw line 
  input logic                run,              // HIGH to draw / run the unit
  input logic         [1:0]  quadrant,         // Select 1 of 4 ellipse quadrants to draw
  input logic                ellipse_filled,   // Draw a filled ellipse
  input logic signed  [11:0] aX,               // 12-bit X-coordinate for line start
  input logic signed  [11:0] aY,               // 12-bit Y-coordinate for line start
  input logic signed  [11:0] bX,               // 12-bit X-coordinate for line end
  input logic signed  [11:0] bY,               // 12-bit Y-coordinate for line end
  input logic                ena_pause,         // set HIGH to pause line generator while it is drawing
// outputs
  output logic               busy,             // HIGH when line_generator is running
  output logic signed [11:0] X_coord,          // 12-bit X-coordinate for current pixel
  output logic signed [11:0] Y_coord,          // 12-bit Y-coordinate for current pixel
  output logic               pixel_data_rdy,   // HIGH when coordinate outputs are valid
  output logic               line_complete     // HIGH when line is completed
);

logic               b [0:1]        ;
logic               rdy [0:1]      ;
logic               complete [0:1] ;
logic signed [11:0] xc [0:1]       ;
logic signed [11:0] yc [0:1]       ;


line_generator sel_linegen  (
    // inputs
    .clk              ( clk                ), // 125 MHz pixel clock
    .reset            ( reset              ), // asynchronous reset
    .enable           ( enable             ), // Allows processing
    .run              ( run && !sel_ellipse ), // HIGH during drawing
    .aX               ( aX                 ), // 12-bit X-coordinate for line start
    .aY               ( aY                 ), // 12-bit Y-coordinate for line start
    .bX               ( bX                 ), // 12-bit X-coordinate for line end
    .bY               ( bY                 ), // 12-bit Y-coordinate for line end
    .ena_pause        ( ena_pause          ), // set HIGH to pause line generator while it is drawing
    // outputs
    .busy             ( b[0]               ), // HIGH when line_generator is running
    .X_coord          ( xc[0]              ), // 12-bit X-coordinate for current pixel
    .Y_coord          ( yc[0]              ), // 12-bit Y-coordinate for current pixel
    .pixel_data_rdy   ( rdy[0]             ), // HIGH when coordinate outputs are valid
    .line_complete    ( complete[0]        )  // HIGH when line is completed
);


ellipse_generator #(.USE_ALTERA_IP(USE_ALTERA_IP)) sel_ellipsegen (
    // inputs
    .clk              ( clk                ), // 125 MHz pixel clock
    .reset            ( reset              ), // asynchronous reset
    .enable           ( enable             ), // Allows processing
    .run              ( run && sel_ellipse ), // HIGH during drawing
    .quadrant         ( quadrant           ), // Select 1 of 4 ellipse quadrants to draw
    .ellipse_filled   ( ellipse_filled     ), // Draw a filled ellipse
    .Xc               ( aX                 ), // 12-bit X-coordinate for line start
    .Yc               ( aY                 ), // 12-bit Y-coordinate for line start
    .Xr               ( bX                 ), // 12-bit X-coordinate for line end
    .Yr               ( bY                 ), // 12-bit Y-coordinate for line end
    .ena_pause        ( ena_pause          ), // set HIGH to pause line generator while it is drawing
    // outputs
    .busy             ( b[1]               ), // HIGH when line_generator is running
    .X_coord          ( xc[1]              ), // 12-bit X-coordinate for current pixel
    .Y_coord          ( yc[1]              ), // 12-bit Y-coordinate for current pixel
    .pixel_data_rdy   ( rdy[1]             ), // HIGH when coordinate outputs are valid
    .ellipse_complete ( complete[1]        )  // HIGH when line is completed
);


always_comb begin
    busy            = b[0]        || b[1]        ; //  high when either module is busy
    pixel_data_rdy  = rdy[0]      || rdy[1]      ; //  high when either generator is creating output 
    line_complete   = complete[0] || complete[1] ; //  Single complete pulse from either generator
    X_coord         = xc[sel_ellipse]            ; // Select the chosen generator's output coordinates
    Y_coord         = yc[sel_ellipse]            ; // Select the chosen generator's output coordinates
  end
endmodule


/*
 * poly_sort module
 *
 * Outputs pointer which control the selection of xy[#'s]
 * each linegen 0&1 will use to draf a filled tri and filled quad
 * Also outputs pointers to the min and max Y coords in
 * the filled triangle and filled quad
 *
 */

module poly_sort (
// inputs
    input  wire  signed [11:0] x_in [0:3]         , // values to sort
    input  wire  signed [11:0] y_in [0:3]         , // values to sort
//outputs
    output logic        [1:0]  sort_tri     [0:2] , // Array containing 3 sorted pointers, 1 for linegen 0 and 2 sequences for linegen 1 to generate a filled triangle using xy[0,1,2].
    output logic        [1:0]  sort_tri_mm  [0:1] , // Array containing 2 sorted pointers for the triangle's min Y coordinate and max Y coordinate when rendering using xy[0,1,2].
    output logic        [1:0]  sort_quad    [0:2] , // Array containing 3 sorted pointers, 1 for linegen 0 and 2 sequences for linegen 1 to generate a filled triangle using xy[1,2,3].
    output logic        [1:0]  sort_quad_mm [0:1]   // Array containing 2 sorted pointers for the triangle's min Y coordinate and max Y coordinate when rendering using xy[3,2,1].
);

always_comb begin


// ***************************************************
// Generate the Y order for the sorted triangle
// ***************************************************

            if ( ( y_in[0] >=  y_in[1] ) && ( y_in[1] >= y_in[2] ) ) begin
                sort_tri[0] = 2'd2 ;
                sort_tri[1] = 2'd1 ;
                sort_tri[2] = 2'd0 ;
            end else
            if ( ( y_in[1] >=  y_in[2] ) && ( y_in[2] >= y_in[0] ) ) begin
                sort_tri[0] = 2'd0 ;
                sort_tri[1] = 2'd2 ;
                sort_tri[2] = 2'd1 ;
            end else
            if ( ( y_in[2] >=  y_in[0] ) && ( y_in[0] >= y_in[1] ) ) begin
                sort_tri[0] = 2'd1 ;
                sort_tri[1] = 2'd0 ;
                sort_tri[2] = 2'd2 ;
            end else
            if ( ( y_in[0] >=  y_in[2] ) && ( y_in[2] >= y_in[1] ) ) begin
                sort_tri[0] = 2'd1 ;
                sort_tri[1] = 2'd2 ;
                sort_tri[2] = 2'd0 ;
            end else
            if ( ( y_in[2] >=  y_in[1] ) && ( y_in[1] >= y_in[0] ) ) begin
                sort_tri[0] = 2'd0 ;
                sort_tri[1] = 2'd1 ;
                sort_tri[2] = 2'd2 ;
            end else
            if ( ( y_in[1] >=  y_in[0] ) && ( y_in[0] >= y_in[2] ) ) begin
                sort_tri[0] = 2'd2 ;
                sort_tri[1] = 2'd0 ;
                sort_tri[2] = 2'd1 ;
            end
// ***************************************************        
// Generate the Y order for the sorted quad
// *************************************************** 
       
            if ( ( y_in[1] >=  y_in[2] ) && ( y_in[2] >= y_in[3] ) ) begin
                sort_quad[0] = 2'd3 ;
                sort_quad[1] = 2'd2 ;
                sort_quad[2] = 2'd1 ;
            end else
            if ( ( y_in[2] >=  y_in[3] ) && ( y_in[3] >= y_in[1] ) ) begin
                sort_quad[0] = 2'd1 ;
                sort_quad[1] = 2'd3 ;
                sort_quad[2] = 2'd2 ;
            end else
            if ( ( y_in[3] >=  y_in[1] ) && ( y_in[1] >= y_in[2] ) ) begin
                sort_quad[0] = 2'd2 ;
                sort_quad[1] = 2'd1 ;
                sort_quad[2] = 2'd3 ;
            end else
            if ( ( y_in[1] >=  y_in[3] ) && ( y_in[3] >= y_in[2] ) ) begin
                sort_quad[0] = 2'd2 ;
                sort_quad[1] = 2'd3 ;
                sort_quad[2] = 2'd1 ;
            end else
            if ( ( y_in[3] >=  y_in[2] ) && ( y_in[2] >= y_in[1] ) ) begin
                sort_quad[0] = 2'd1 ;
                sort_quad[1] = 2'd2 ;
                sort_quad[2] = 2'd3 ;
            end else
            if ( ( y_in[2] >=  y_in[1] ) && ( y_in[1] >= y_in[3] ) ) begin
                sort_quad[0] = 2'd3 ;
                sort_quad[1] = 2'd1 ;
                sort_quad[2] = 2'd2 ;
            end


// *********************************************************************
// Copy the Y sort to the correct line generators for a filled triangle
// *********************************************************************
//   xy[0]
//    ***
//    *  LG1f        f = first of 2 lines to draw
//    *    ** 
//   LG0f   xy[1]
//    *    **
//    *  LG1s        s = second of 2 lines to draw
//    ***
//   xy[2]           LG0 only draws 1 line
//
sort_tri_mm[1'b0] = sort_tri[0] ; // Triangle minimum Y coordinate
sort_tri_mm[1'b1] = sort_tri[2] ; // Triangle minimum Y coordinate

// *********************************************************************
// Copy the Y sort to the correct line generators for a filled quad
// *********************************************************************
//   xy[1]
//    ***
//    *  LG1f        f = first of 2 lines to draw
//    *    ** 
//   LG0f   xy[2]
//    *    **
//    *  LG1s        s = second of 2 lines to draw
//    ***
//   xy[3]           LG0 only draws 1 line
//
sort_quad_mm[1'b0] = sort_quad[0] ; // Quad minimum Y coordinate
sort_quad_mm[1'b1] = sort_quad[2] ; // Quad minimum Y coordinate

end
endmodule
