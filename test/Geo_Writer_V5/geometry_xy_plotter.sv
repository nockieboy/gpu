/*
 *      GEOFF MODULE
 *  (geometry_xy_plotter)
 *
 *       v 0.1.019
 *
 */

module geometry_xy_plotter (
    input wire clk,               // System clock
    input wire reset,             // Force reset
    input wire fifo_cmd_ready,    // 16-bit Data Command Ready signal
    input wire [15:0] fifo_cmd_in,// 16-bit Data Command bus
    input wire draw_busy,         // HIGH when pixel writer is busy, so geometry plotter will pause before sending any new pixels
    
    output wire load_cmd,         // HIGH when ready to receive next cmd_data[15:0] input
    output wire draw_cmd_rdy,     // Pulsed HIGH when data on draw_cmd[15:0] is ready to send to the pixel writer module
    output wire [35:0] draw_cmd,  // Bits [35:32] hold AUX function number 0-15:
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
    //  AUX=14 : Set destination mem address,             : 31:24 bitplane mode : 23:0 hold destination base memory addres for write pixel
    //  AUX=15 : Set source mem address,                  : 31:24 bitplane mode : 23:0 hold the source base memory address for read source pixel
    output wire fifo_cmd_busy     // HIGH when FIFO is full/nearly full
);

parameter int FIFO_MARGIN         = 32 ; // The number of extra commands the fifo has room after the 'fifo_cmd_busy' goes high

logic [3:0] CMD_OUT_NOP           = 0  ;
logic [3:0] CMD_OUT_PXWRI         = 1  ;
logic [3:0] CMD_OUT_PXWRI_M       = 2  ;
logic [3:0] CMD_OUT_PXPASTE       = 3  ;
logic [3:0] CMD_OUT_PXPASTE_M     = 4  ;

logic [3:0] CMD_OUT_PXCOPY        = 6  ;
logic [3:0] CMD_OUT_SETARGB       = 7  ;

logic [3:0] CMD_OUT_RST_PXWRI_M   = 10 ;
logic [3:0] CMD_OUT_RST_PXPASTE_M = 11 ;
logic [3:0] CMD_OUT_DSTRWDTH      = 12 ;
logic [3:0] CMD_OUT_SRCRWDTH      = 13 ;
logic [3:0] CMD_OUT_DSTMADDR      = 14 ;
logic [3:0] CMD_OUT_SRCMADDR      = 15 ;

logic [7:0]  command_in     ;
logic [11:0] command_data12 ;
logic [7:0]  command_data8  ;

logic signed [11:0] x[0:3] ; // 2-dimensional 12-bit register for x0-x3
logic signed [11:0] y[0:3] ; // 2-dimensional 12-bit register for y0-y3
logic signed [11:0] max_x  ; // this reg will be both in this module and the memory pixel writer
logic signed [11:0] max_y  ; // this reg will be both in this module and the memory pixel writer

logic [3:0]  draw_cmd_func        ;
logic [7:0]  draw_cmd_data_color  ;
logic [11:0] draw_cmd_data_word_Y ;
logic [11:0] draw_cmd_data_word_X ;
logic        draw_cmd_tx = 1'b0   ;

//************************************************
logic [15:0] cmd_data       ;
logic        fifo_cmd_rdy_n ;

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





logic                sort_cmd_rdy      ;
logic [15:0]         sort_data_pipe    ; // cmd_data pipeline OUT from poly_sort into geo_xy_plotter
logic signed  [11:0] sort_coords[0:15] ; // array package of sorted coordinates for the linegen
logic signed  [11:0] sort_y_range[0:1] ; // array package of defining the starting and ending Y coordinates for a filled polygon
logic [1:0]          lg_seq_size[0:1]  ;
logic                lg_fill           ;
logic                draw_shape        ;
logic [7:0]          blit_features     ;
logic [7:0]          blit_mask_col     ;

poly_sort sorter (
// inputs
    .clk           ( clk            ),
    .reset         ( reset          ),
    .enable        ( !draw_busy && !plot_busy ), // !pixel_writer busy input
    .cmd_rdy_in    ( load_cmd       ),
    .cmd_in        ( cmd_data       ), // ** cmd_data pipeline input from FIFO
    .x_in          ( x              ), // values to sort
    .y_in          ( y              ), // values to sort
//outputs
    .cmd_rdy_out   ( sort_cmd_rdy   ),
    .cmd_out       ( sort_data_pipe ), // ** cmd_data pipeline output
    .lg_coords     ( sort_coords    ), // array package of sorted coordinates for the linegen 0&1
    .lg_seq_size   ( lg_seq_size    ), // array containing the number of line coordinates for each linegen to run
    .lg_fill       ( lg_fill        ),
    .draw_shape    ( draw_shape     ),
    .blit_features ( blit_features  ), // Tells the blitter module to use the transparency color mask
    .blit_mask_col ( blit_mask_col  ), // Tells the blitter copy pixel function how to transpose the source pixel color
                                       // Remember when writing a pixel/line/un-filled triangle/box/quad, the set color does a second
                                       // color transpose from the copy pixel to the destination pixel color.
    .y_range       ( sort_y_range   )  // defines the starting and ending Y coordinates for a filled polygon
);

logic                plot_cmd_rdy       ;
logic [15:0]         plot_data_pipe     ; // cmd_data pipeline OUT from poly_plot into the blitter
logic signed  [11:0] plot_pixel_xy[0:1] ; // xy coordinater to plot to
logic                plot_pixel_ena     ;
logic [7:0]          plot_pixel_col     ;
logic                plot_busy          ;
logic [7:0]          p_blit_features    ;
logic [7:0]          p_blit_mask_col    ;

poly_plot plotter (
// inputs
    .clk               ( clk             ),
    .reset             ( reset           ),
    .enable            ( !draw_busy      ), // !pixel_writer busy input
    .cmd_rdy_in        ( sort_cmd_rdy    ),
    .cmd_in            ( sort_data_pipe  ), // ** cmd_data pipeline input from FIFO
    .lg_coords         ( sort_coords     ), // values to plot
    .lg_seq_size       ( lg_seq_size     ), // array containing the number of line coordinates for each linegen to run
    .lg_fill           ( lg_fill         ),
    .draw_shape        ( draw_shape      ),
    .blit_features_in  ( blit_features   ), // Tells the blitter module to copy & paste a rectangle.
    .blit_mask_col_in  ( blit_mask_col   ), // Tells the blitter copy pixel function how to transpose the source pixel color
    .y_range           ( sort_y_range    ), // defines the starting and ending Y coordinates for a filled polygon

//outputs
    .cmd_rdy_out       ( plot_cmd_rdy    ),
    .cmd_out           ( plot_data_pipe  ), // ** cmd_data pipeline output
    .pixel_ena         ( plot_pixel_ena  ),
    .pixel_xy          ( plot_pixel_xy   ), // array package of sorted coordinates for the linegen 0&1
    .pixel_col         ( plot_pixel_col  ), // array package of sorted coordinates for the linegen 0&1
    .plotter_busy      ( plot_busy       ), // array containing the number of line coordinates for each linegen to run
    .blit_features_out ( p_blit_features ), // Tells the blitter module to copy & paste a rectangle.
    .blit_mask_col_out ( p_blit_mask_col )  // Tells the blitter copy pixel function how to transpose the source pixel color
);

/*
blitter_processor blitter (
// inputs
    .clk               ( clk             ),
    .reset             ( reset           ),
    .enable            ( !draw_busy      ), // !pixel_writer busy input
    .cmd_rdy_in        ( new_cmd_rdy     ),
    .cmd_in            ( cmd_data_pipe   ), // ** cmd_data pipeline input from FIFO    


    .src_function      ( p_blit_func     ), // contains the 8 bit feature settings for the blitter,  bit0 = blitter enable, bit1=mask enable, bit2=paste center offset
    .src_maks_color    ( p_blit_mask_col ), // contains the 8 bit color mask used in the pixel copy command
    .src_size          (                 ), // x&y size of raster to copy.
    
    .pixel_ena         ( lg_pixel_ena    ),
    .dest_coords       ( lg_pixel_xy     ), // values to sort

//outputs
    .blit_busy         ( blit_busy       ), // Tells the linegens to wait as the blitter is copying a box of graphics
    .draw_cmd_tx       ( b_cmd_tx        ), // outputs the draw command
    .draw_cmd          ( b_cmd_func      ),
    .draw_cmd_col      ( b_cmd_data_color),
    .draw_cmd_x        ( b_cmd_data_word_x),
    .draw_cmd_y        ( b_cmd_data_word_Y)
);
*/

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
    load_cmd             = !plot_busy  && !fifo_cmd_rdy_n ;
    
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
        
        // reset draw command registers
        draw_cmd_func        <= 4'b0  ;
        draw_cmd_data_color  <= 8'b0  ;
        draw_cmd_data_word_Y <= 12'b0 ;
        draw_cmd_data_word_X <= 12'b0 ;
        draw_cmd_tx          <= 1'b0  ;
        
        
    end else if (!draw_busy) begin  // Everything must PAUSE if the incoming draw_busy signal from the pixel_writer is high
     
        
        // Pass through the pixel draw command and pixel_cmd_ready when the final line_gen or blitter has a ready pixel
   if (plot_busy) begin
        if ( plot_pixel_ena && ( plot_pixel_xy[0] >= 0 && plot_pixel_xy[0] < max_x ) && ( plot_pixel_xy[1] >=0 && plot_pixel_xy[1] < max_y ) ) begin
           // blitter has valid pixel data ready
            draw_cmd_func        <= CMD_OUT_PXWRI    ;
            draw_cmd_data_word_X <= plot_pixel_xy[0] ; // ... at X-coordinate
            draw_cmd_data_word_Y <= plot_pixel_xy[1] ; // ... and Y-coordinate
            draw_cmd_data_color  <= plot_pixel_col   ;    
            draw_cmd_tx          <= 1'b1             ; // let PAGET know valid pixel data is incoming
        end
        else draw_cmd_tx         <= 1'b0 ; // otherwise turn off draw command

   end else begin

        // This code interprets the incoming commands when the linegens and blitter are not generating pixels
        if ( load_cmd ) begin  // when the cmd_rdy input is LOW and the geometry unit geo_run is not running, execute the following command input
         
            casez (command_in)
             
                8'b10?????? : x[command_in[5:4]] <= command_data12 ;
                
                8'b11?????? : y[command_in[5:4]] <= command_data12 ;
                
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
                
                8'd119 : begin  //Ignore for now
                    //destmem <= x[11:0][0] * 4096 + y[11:0][0];  // set both source & destination pointers for blitter copy
                    //srcmem  <= x[11:0][1] * 4096 + y[11:0][1];
                end
                
                8'd118 : begin //Ignore for now
                    //destmem <= x[11:0][1] * 4096 + y[11:0][1];  // set both source & destination pointers for blitter copy
                    //srcmem  <= x[11:0][0] * 4096 + y[11:0][0];
                end
                
                8'd117 : begin //Ignore for now
                    //destmem <= x[11:0][2] * 4096 + y[11:0][2];  // set both source & destination pointers for blitter copy
                    //srcmem  <= x[11:0][3] * 4096 + y[11:0][3];
                end
                
                8'd116 : begin //Ignore for now
                    //destmem <= x[11:0][3] * 4096 + y[11:0][3];  // set both source & destination pointers for blitter copy
                    //srcmem  <= x[11:0][2] * 4096 + y[11:0][2];
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
                    //********************  no command to be set......draw_cmd_tx <= 1'b1;
                end
                
                8'd94  : begin
                    max_x <= x[1] ;    // set max width & height of screen to x1/y1
                    max_y <= y[1] ;
                    //********************  no command to be set......draw_cmd_tx <= 1'b1;
                end
                
                8'd93  : begin
                    max_x <= x[2] ; // set max width & height of screen to x2/y2
                    max_y <= y[2] ;
                    //********************  no command to be set......draw_cmd_tx <= 1'b1;
                end
                
                8'd92 : begin
                    max_x <= x[3] ; // set max width & height of screen to x3/y3
                    max_y <= y[3] ;
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

                8'b000????? : begin // this range of commands all begin drawing a shape
                   // This case is needed so that the default draw_cmd_tx wont be cleared
                   // drawing commands begin here.  Keep the convention that:
                   // extend_cmd[3] = fill enable
                   // extend_cmd[4] = use the color in the copy/paste buffer.  This one is for drawing in true color mode.
                   // extend_cmd[5] = mask enable - when drawing, the mask colours will not be plotted as they are transparent
                   // geo_shape[3]   <= 1'b0            ; // geo shapes 0 through 7, geo shapes 8 through 15 are for copy & paste.
                   // geo_shape[2:0] <= command_in[2:0] ; // Set which one of shapes 0 through 7 should be drawn.  Shape 0 means nothing is being drawn
                   // geo_fill       <= command_in[3]   ; // Fill enable bit
                   // geo_paste      <= command_in[4]   ; // Used for drawing in true color 16 bit mode
                   // geo_mask       <= 1'b0            ; // Mask disables when drawing raw geometry shapes
                   // geo_color      <= command_data8   ; // set the 8-bit pen color                    
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
 * poly_sort module
 *
 * Outputs array lg_coords [0:15]
 * forted for 2 line generators
 * running 2 sets of connected coordinates.
 * Structured output coordinates for linegens 0&1 
 * {lgen#,lg_seq#.lg_ab,lg_xy} = 4 bits = 16 coordinates
 *
 * Also defines the number of linegen sequences each
 * line gen needs to run to finish the shape stored in
 * lg_seq_size[0:1].
 *
 * and defines whether the linegens needs to do a lg_fill
 *
 * Also sets the blit_ena, blit_mask enable and blit_mask_col
 *
 */
module poly_sort (
// inputs
    input logic                 clk            ,
    input logic                 reset          ,
    input logic                 enable         , // !pixel_writer busy input
    input logic                 cmd_rdy_in     ,
    input logic          [15:0] cmd_in         ,
    input logic   signed [11:0] x_in [0:3]     , // values to sort
    input logic   signed [11:0] y_in [0:3]     , // values to sort
//outputs
    output logic                cmd_rdy_out    ,
    output logic         [15:0] cmd_out        ,
    output logic  signed [11:0] lg_coords [0:15] , // Structured output coordinates for linegens 0 & 1   {lgen#,lg_seq#.lg_ab,lg_xy} = 4 bits = 16 coordinates
    output logic         [1:0]  lg_seq_size[0:1] , // The number of lines each linegen needs to draw
    output logic                lg_fill        , // when low, run the linegens 1&2 in serial fashion.
                                                 // when high, run the linegens 1&2 in parallel and fill a line between them.
    output logic                draw_shape     , // High when a valid drawing command has been decoded
    output logic         [7:0]  blit_features  , // Tells the blitter module to use the transparency color mask
    output logic         [7:0]  blit_mask_col  , // Tells the blitter copy pixel function how to transpose the source pixel color
                                                 // Remember when writing a pixel/line/un-filled triangle/box/quad, the set color does a second
                                                 // color transpose from the copy pixel to the destination pixel color.
    output logic  signed [11:0] y_range [0:1]    // Defines the starting & ending of a Y raster fill.
);


localparam  PIPE_LEN = 3;  // 3 stages, sort triangle, sort quad, decode instructions & final sort coordinates -> linegens based on shape

logic [PIPE_LEN:0] cmd_rdy_pipe    ;
logic [15:0] cmd_pipe      [0:PIPE_LEN] ;
logic signed [11:0] x_pipe [0:PIPE_LEN][0:3] ;
logic signed [11:0] y_pipe [0:PIPE_LEN][0:3] ;

integer      PIPE_POS ; // Used to define which section inside the pipe of the following code will be working on

// assign input and output ports to a common pipe array where [0] is the beginning of the array and [PIPE_LEN] is the final output array
always_comb begin
cmd_rdy_out     = cmd_rdy_pipe[PIPE_LEN] ; // assign output port to final stage in sequence pipe
cmd_out         = cmd_pipe[PIPE_LEN];     // assign output port to final stage in sequence pipe
x_pipe[0][0:3]  = x_in[0:3] ;             // assign immediate input stage of sequence pipe to input port
y_pipe[0][0:3]  = y_in[0:3] ;             // assign immediate input stage of sequence pipe to input port
end

always_ff @(posedge clk) begin

    if ( reset ) begin  // Reset only the key controls in the command pipe.
         for (int i=1 ; i<=PIPE_LEN ; i++) begin
         cmd_rdy_pipe[i] <= 0;             // Without the cmd_rdy_out, no functions after this module will be executed.
         end

         lg_seq_size[0]  <= 0;
         lg_seq_size[1]  <= 0;
         draw_shape      <= 0;
         blit_features   <= 0;
         blit_mask_col   <= 0;

    end // reset
    else
    if ( enable ) begin

        // cmd_pipe must be passed through
        cmd_rdy_pipe[PIPE_LEN:1] <= {cmd_rdy_pipe[PIPE_LEN-1:1],cmd_rdy_in}; // Shift the cmd_rdy through the pipe.


// *******************************************************************************************
PIPE_POS = 0 ; // The following section of code will be placed in the first pipe position
// This section begins the sort used when a filled triangle is selected.
// *******************************************************************************************
        cmd_pipe[PIPE_POS+1] <= cmd_in; // pass through the cmd untouched to the next stage

        if ( cmd_in[10:8] != 3 && cmd_in[10:8] != 5 ) begin // if not a triangle/quadrilateral 
                x_pipe[PIPE_POS+1] <= x_pipe[PIPE_POS] ; // pass coordinate array to next stage untouched
                y_pipe[PIPE_POS+1] <= y_pipe[PIPE_POS] ; // pass coordinate array to next stage untouched
        end 
        else begin // Begin coordinate sorting for triangle
            x_pipe[PIPE_POS+1][3] <= x_pipe[PIPE_POS][3] ; // pass-through x&y_pipe[PIPE_POS][3] as we're only sorting the first 3 values (initially)
            y_pipe[PIPE_POS+1][3] <= y_pipe[PIPE_POS][3] ; // pass-through x&y_pipe[PIPE_POS][3] as we're only sorting the first 3 values (initially)

            if ( ( y_pipe[PIPE_POS][0] >=  y_pipe[PIPE_POS][1] ) && ( y_pipe[PIPE_POS][1] >= y_pipe[PIPE_POS][2] ) ) begin
                x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][2] ;
                y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][2] ;
                x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][1] ;
                y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][1] ;
                x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][0] ;
                y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][0] ;
            end else
            if ( ( y_pipe[PIPE_POS][1] >=  y_pipe[PIPE_POS][2] ) && ( y_pipe[PIPE_POS][2] >= y_pipe[PIPE_POS][0] ) ) begin
                x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][0] ;
                y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][0] ;
                x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][2] ;
                y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][2] ;
                x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][1] ;
                y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][1] ;
            end else
            if ( ( y_pipe[PIPE_POS][2] >=  y_pipe[PIPE_POS][0] ) && ( y_pipe[PIPE_POS][0] >= y_pipe[PIPE_POS][1] ) ) begin
                x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][1] ;
                y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][1] ;
                x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][0] ;
                y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][0] ;
                x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][2] ;
                y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][2] ;
            end else
            if ( ( y_pipe[PIPE_POS][0] >=  y_pipe[PIPE_POS][2] ) && ( y_pipe[PIPE_POS][2] >= y_pipe[PIPE_POS][1] ) ) begin
                x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][1] ;
                y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][1] ;
                x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][2] ;
                y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][2] ;
                x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][0] ;
                y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][0] ;
            end else
            if ( ( y_pipe[PIPE_POS][2] >=  y_pipe[PIPE_POS][1] ) && ( y_pipe[PIPE_POS][1] >= y_pipe[PIPE_POS][0] ) ) begin
                x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][0] ;
                y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][0] ;
                x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][1] ;
                y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][1] ;
                x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][2] ;
                y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][2] ;
            end else
            if ( ( y_pipe[PIPE_POS][1] >=  y_pipe[PIPE_POS][0] ) && ( y_pipe[PIPE_POS][0] >= y_pipe[PIPE_POS][2] ) ) begin
                x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][2] ;
                y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][2] ;
                x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][0] ;
                y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][0] ;
                x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][1] ;
                y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][1] ;
            end
                else begin // Triangle sort already has done enough to sort a quad, just copy through the results
                    x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][0] ; // pass coordinate array to next stage untouched
                    y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][0] ; // pass coordinate array to next stage untouched
                    x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][1] ; // pass coordinate array to next stage untouched
                    y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][1] ; // pass coordinate array to next stage untouched
                    x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][2] ; // pass coordinate array to next stage untouched
                    y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][2] ; // pass coordinate array to next stage untouched
                end
            
        end // Finished filled triangle/quad sort stage 1


// *******************************************************************************************
PIPE_POS = 1 ; // The following section of code will be placed in the second pipe position
// this stage continues the sort if a filled quadrilateral has been selected.
// *******************************************************************************************
        cmd_pipe[PIPE_POS+1] <= cmd_pipe[PIPE_POS]; // pass through the cmd untouched to the next stage
        
       if ( cmd_pipe[PIPE_POS][10:8] != 5 ) begin // If the shape is not a quad
           x_pipe[PIPE_POS+1] <= x_pipe[PIPE_POS] ; // pass coordinate array to next stage untouched
           y_pipe[PIPE_POS+1] <= y_pipe[PIPE_POS] ; // pass coordinate array to next stage untouched
        end 
        else begin // Begin coordinate sorting for filled quads
                if ( y_pipe[PIPE_POS][3] <= y_pipe[PIPE_POS][0] ) begin
                    x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][3] ;
                    y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][3] ;
                    x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][0] ;
                    y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][0] ;
                    x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][1] ;
                    y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][1] ;
                    x_pipe[PIPE_POS+1][3] <= x_pipe[PIPE_POS][2] ;
                    y_pipe[PIPE_POS+1][3] <= y_pipe[PIPE_POS][2] ;
                end else
                if ( y_pipe[PIPE_POS][3] <= y_pipe[PIPE_POS][1] ) begin
                    x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][0] ;
                    y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][0] ;
                    x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][3] ;
                    y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][3] ;
                    x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][1] ;
                    y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][1] ;
                    x_pipe[PIPE_POS+1][3] <= x_pipe[PIPE_POS][2] ;
                    y_pipe[PIPE_POS+1][3] <= y_pipe[PIPE_POS][2] ;
                end else
                if ( y_pipe[PIPE_POS][3] <= y_pipe[PIPE_POS][2] ) begin
                    x_pipe[PIPE_POS+1][0] <= x_pipe[PIPE_POS][0] ;
                    y_pipe[PIPE_POS+1][0] <= y_pipe[PIPE_POS][0] ;
                    x_pipe[PIPE_POS+1][1] <= x_pipe[PIPE_POS][1] ;
                    y_pipe[PIPE_POS+1][1] <= y_pipe[PIPE_POS][1] ;
                    x_pipe[PIPE_POS+1][2] <= x_pipe[PIPE_POS][3] ;
                    y_pipe[PIPE_POS+1][2] <= y_pipe[PIPE_POS][3] ;
                    x_pipe[PIPE_POS+1][3] <= x_pipe[PIPE_POS][2] ;
                    y_pipe[PIPE_POS+1][3] <= y_pipe[PIPE_POS][2] ;
                end
                else begin // Triangle sort already has done enough to sort a quad, just copy through the results
                    x_pipe[PIPE_POS+1] <= x_pipe[PIPE_POS] ; // pass coordinate array to next stage untouched
                    y_pipe[PIPE_POS+1] <= y_pipe[PIPE_POS] ; // pass coordinate array to next stage untouched
                end

            end // quad sort

// *******************************************************************************************
PIPE_POS = 2 ; // The following section of code will be placed in the third pipe position
// This stage sets the number of coordinate sets for each linegen to run lg_coords[{lgen#,lg_seq#.lg_a/b,lg_x/y}].
// and performs a final sort and selection for the 2 possible sets of coordinates for each linegen
// This simplifies the MUX going into the linegens down to 2 possibilities.
// This section also sets the filled flag which tells whether the linegens run in series 1 after the other
// or in parallel with a line-fill between them.
// *******************************************************************************************


           cmd_pipe[PIPE_POS+1][7:0]  <= cmd_pipe[PIPE_POS][7:0];  // pass through the color untouched

// Shape    0  = NOTHING
// Shape    1  = Pixel
// Shape    2  = Line
// Shape    3  = Triangle
// Shape    4  = Box
// Shape    5  = Quadrilateral
// Shape    6  = Ellipse
// Shape    7  = Bezier Curve
// Shape f0 8  = NOTHING
// Shape f1 9  = Pixel
// Shape f2 10 = Line
// Shape f3 11 = Triangle Filled
// Shape f4 12 = Box Filled
// Shape f5 13 = Quadrilateral Filled
// Shape f6 14 = Ellipse Filled
// Shape f7 15 = Bezier Curve Filled
if (cmd_rdy_pipe[PIPE_POS]) begin
            casez (cmd_pipe[PIPE_POS][15:8])
             
                8'b00000000 : begin // Set blit_ena & mask flags with cmd_pipe[PIPE_POS][0&1]  IE-color setting for draw shape 0
                              cmd_pipe[PIPE_POS+1][15:8] <= cmd_pipe[PIPE_POS][15:8]; // pass untouched
                              lg_seq_size[0]             <= 0 ;                   // sets the number of coordinate pairs linegen1 needs to draw
                              lg_seq_size[1]             <= 0 ;                   // sets the number of coordinate pairs linegen2 needs to draw
                              draw_shape                 <= 0 ;                   // Tell the next module that no draw command has come in
                              lg_fill                    <= 0 ;                   // Disable the fill command
                              blit_features              <= cmd_pipe[PIPE_POS][7:0] ; // Set enable feature
                              end
                8'b00001000 : begin //  Set copy pixel color transformation mask
                              cmd_pipe[PIPE_POS+1][15:8] <= cmd_pipe[PIPE_POS][15:8]; // pass untouched
                              lg_seq_size[0]             <= 0 ;                   // sets the number of coordinate pairs linegen1 needs to draw
                              lg_seq_size[1]             <= 0 ;                   // sets the number of coordinate pairs linegen2 needs to draw
                              draw_shape                 <= 0 ;                   // Tell the next module that no draw command has come in
                              lg_fill                    <= 0 ;                   // Disable the fill command
                              blit_mask_col              <= cmd_pipe[PIPE_POS][7:0] ; // Set copy pixel color transform mask
                              end

                8'b000?0001 : begin // Shape    1  = Pixel
                              cmd_pipe[PIPE_POS+1][15:8] <= cmd_pipe[PIPE_POS][15:8]; // pass untouched
                              lg_seq_size[0]             <= 1 ;                   // sets the number of coordinate pairs linegen1 needs to draw
                              lg_seq_size[1]             <= 0 ;                   // sets the number of coordinate pairs linegen2 needs to draw
                              draw_shape                 <= 1 ;                   // Tell the next module that a draw command has come in
                              lg_fill                    <= 0 ;                   // Disable the fill command

                              lg_coords[4'b0000]          <= x_pipe[PIPE_POS][0] ; // set lg0's first A coordinate.
                              lg_coords[4'b0001]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b0010]          <= x_pipe[PIPE_POS][0] ; // set lg0's first B coordinate.
                              lg_coords[4'b0011]          <= y_pipe[PIPE_POS][0] ;
                              //lg_coords[4'b0100]          <= x_pipe[PIPE_POS][0] ; // set lg0's second A coordinate.
                              //lg_coords[4'b0101]          <= y_pipe[PIPE_POS][0] ;
                              //lg_coords[4'b0110]          <= x_pipe[PIPE_POS][1] ; // set lg0's second B coordinate.
                              //lg_coords[4'b0111]          <= y_pipe[PIPE_POS][1] ;

                              //lg_coords[4'b1000]          <= x_pipe[PIPE_POS][0] ; // set lg1's first A coordinate.
                              //lg_coords[4'b1001]          <= y_pipe[PIPE_POS][0] ;
                              //lg_coords[4'b1010]          <= x_pipe[PIPE_POS][1] ; // set lg1's first B coordinate.
                              //lg_coords[4'b1011]          <= y_pipe[PIPE_POS][1] ;
                              //lg_coords[4'b1100]          <= x_pipe[PIPE_POS][0] ; // set lg1's second A coordinate.
                              //lg_coords[4'b1101]          <= y_pipe[PIPE_POS][0] ;
                              //lg_coords[4'b1110]          <= x_pipe[PIPE_POS][1] ; // set lg1's second B coordinate.
                              //lg_coords[4'b1111]          <= y_pipe[PIPE_POS][1] ;
                              end

                8'b000?0010 : begin // Shape    2  = Line
                              cmd_pipe[PIPE_POS+1][15:8] <= cmd_pipe[PIPE_POS][15:8]; // pass untouched
                              lg_seq_size[0]             <= 1 ;                   // sets the number of coordinate pairs linegen1 needs to draw
                              lg_seq_size[1]             <= 0 ;                   // sets the number of coordinate pairs linegen2 needs to draw
                              draw_shape                 <= 1 ;                    // Tell the next module that a draw command has come in
                              lg_fill                    <= 0 ;                   // Disable the fill command

                              lg_coords[4'b0000]          <= x_pipe[PIPE_POS][0] ; // set lg0's first A coordinate.
                              lg_coords[4'b0001]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b0010]          <= x_pipe[PIPE_POS][1] ; // set lg0's first B coordinate.
                              lg_coords[4'b0011]          <= y_pipe[PIPE_POS][1] ;
                              //lg_coords[4'b0100]          <= x_pipe[PIPE_POS][0] ; // set lg0's second A coordinate.
                              //lg_coords[4'b0101]          <= y_pipe[PIPE_POS][0] ;
                              //lg_coords[4'b0110]          <= x_pipe[PIPE_POS][1] ; // set lg0's second B coordinate.
                              //lg_coords[4'b0111]          <= y_pipe[PIPE_POS][1] ;

                              //lg_coords[4'b1000]          <= x_pipe[PIPE_POS][0] ; // set lg1's first A coordinate.
                              //lg_coords[4'b1001]          <= y_pipe[PIPE_POS][0] ;
                              //lg_coords[4'b1010]          <= x_pipe[PIPE_POS][1] ; // set lg1's first B coordinate.
                              //lg_coords[4'b1011]          <= y_pipe[PIPE_POS][1] ;
                              //lg_coords[4'b1100]          <= x_pipe[PIPE_POS][0] ; // set lg1's second A coordinate.
                              //lg_coords[4'b1101]          <= y_pipe[PIPE_POS][0] ;
                              //lg_coords[4'b1110]          <= x_pipe[PIPE_POS][1] ; // set lg1's second B coordinate.
                              //lg_coords[4'b1111]          <= y_pipe[PIPE_POS][1] ;
                              end

                8'b000??011 : begin // Shape    3  = Triangle
                              cmd_pipe[PIPE_POS+1][15:8] <= cmd_pipe[PIPE_POS][15:8]; // pass untouched
                              lg_seq_size[0]             <= 1 ;                   // sets the number of coordinate pairs linegen1 needs to draw
                              lg_seq_size[1]             <= 2 ;                   // sets the number of coordinate pairs linegen2 needs to draw
                              draw_shape                 <= 1 ;                    // Tell the next module that a draw command has come in
                              if (cmd_pipe[PIPE_POS][11] ) lg_fill <= 1 ; // sets the fill flag
                                                     else  lg_fill <= 0 ; // clears the fill flag


                              lg_coords[4'b0000]          <= x_pipe[PIPE_POS][0] ; // set lg0's first A coordinate.
                              lg_coords[4'b0001]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b0010]          <= x_pipe[PIPE_POS][2] ; // set lg0's first B coordinate.
                              lg_coords[4'b0011]          <= y_pipe[PIPE_POS][2] ;
                              //lg_coords[4'b0100]          <= x_pipe[PIPE_POS][1] ; // set lg0's second A coordinate.
                              //lg_coords[4'b0101]          <= y_pipe[PIPE_POS][1] ;
                              //lg_coords[4'b0110]          <= x_pipe[PIPE_POS][2] ; // set lg0's second B coordinate.
                              //lg_coords[4'b0111]          <= y_pipe[PIPE_POS][2] ;

                              lg_coords[4'b1100]          <= x_pipe[PIPE_POS][0] ; // set lg1's first A coordinate.
                              lg_coords[4'b1101]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b1110]          <= x_pipe[PIPE_POS][1] ; // set lg1's first B coordinate.
                              lg_coords[4'b1111]          <= y_pipe[PIPE_POS][1] ;
                              lg_coords[4'b1000]          <= x_pipe[PIPE_POS][1] ; // set lg1's second A coordinate.
                              lg_coords[4'b1001]          <= y_pipe[PIPE_POS][1] ;
                              lg_coords[4'b1010]          <= x_pipe[PIPE_POS][2] ; // set lg1's second B coordinate.
                              lg_coords[4'b1011]          <= y_pipe[PIPE_POS][2] ;
                              
                              y_range[0]                  <= y_pipe[PIPE_POS][0] ; // Set the beginning of the Y raster fill
                              y_range[1]                  <= y_pipe[PIPE_POS][2] ; // Set the ending of the Y raster fill
                              end

                8'b000??100 : begin // Shape    4  = Box
                              cmd_pipe[PIPE_POS+1][15:8] <= cmd_pipe[PIPE_POS][15:8]; // pass untouched
                              draw_shape                 <= 1 ;                    // Tell the next module that a draw command has come in
                              if (cmd_pipe[PIPE_POS][11] ) begin
                                                           lg_fill        <= 1 ; // sets the fill between each X position of linegen 0 & 1
                                                           lg_seq_size[0] <= 1 ; // only draw the left edge
                                                           lg_seq_size[1] <= 1 ; // only draw the right edge
                                                 end else begin
                                                           lg_fill        <= 0 ; // clears the fill flag
                                                           lg_seq_size[0] <= 2 ; // draw top line and left edge
                                                           lg_seq_size[1] <= 2 ; // draw bottom line and right edge
                                                 end

                              lg_coords[4'b0100]          <= x_pipe[PIPE_POS][0] ; // set lg0's first A coordinate.
                              lg_coords[4'b0101]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b0110]          <= x_pipe[PIPE_POS][1] ; // set lg0's first B coordinate.
                              lg_coords[4'b0111]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b0000]          <= x_pipe[PIPE_POS][0] ; // set lg0's second A coordinate.  During a box-fill, this is the only line being drawn
                              lg_coords[4'b0001]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b0010]          <= x_pipe[PIPE_POS][0] ; // set lg0's second B coordinate.
                              lg_coords[4'b0011]          <= y_pipe[PIPE_POS][1] ;

                              lg_coords[4'b1100]          <= x_pipe[PIPE_POS][0] ; // set lg1's first A coordinate.
                              lg_coords[4'b1101]          <= y_pipe[PIPE_POS][1] ;
                              lg_coords[4'b1110]          <= x_pipe[PIPE_POS][1] ; // set lg1's first B coordinate.
                              lg_coords[4'b1111]          <= y_pipe[PIPE_POS][1] ;
                              lg_coords[4'b1000]          <= x_pipe[PIPE_POS][1] ; // set lg1's second A coordinate.  During a box-fill, this is the only line being drawn
                              lg_coords[4'b1001]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b1010]          <= x_pipe[PIPE_POS][1] ; // set lg1's second B coordinate.
                              lg_coords[4'b1011]          <= y_pipe[PIPE_POS][1] ;

                              y_range[0]                  <= y_pipe[PIPE_POS][0] ; // Set the beginning of the Y raster fill
                              y_range[1]                  <= y_pipe[PIPE_POS][1] ; // Set the ending of the Y raster fill
                              end

                8'b000??101 : begin // Shape    5  = Quadrilateral
                              cmd_pipe[PIPE_POS+1][15:8] <= cmd_pipe[PIPE_POS][15:8]; // pass untouched
                              lg_seq_size[0]             <= 2 ;                   // sets the number of coordinate pairs linegen1 needs to draw
                              lg_seq_size[1]             <= 2 ;                   // sets the number of coordinate pairs linegen2 needs to draw
                              draw_shape                 <= 1 ;                    // Tell the next module that a draw command has come in
                              if (cmd_pipe[PIPE_POS][11] ) lg_fill <= 1 ; // sets the fill flag
                                                     else  lg_fill <= 0 ; // clears the fill flag

                              if (x_pipe[PIPE_POS][1] <= x_pipe[PIPE_POS][2]) begin // Sort the X coordinates in the quadrilateral
                              lg_coords[4'b0100]          <= x_pipe[PIPE_POS][0] ; // set lg0's first A coordinate.
                              lg_coords[4'b0101]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b0110]          <= x_pipe[PIPE_POS][1] ; // set lg0's first B coordinate.
                              lg_coords[4'b0111]          <= y_pipe[PIPE_POS][1] ;
                              lg_coords[4'b0000]          <= x_pipe[PIPE_POS][1] ; // set lg0's second A coordinate.
                              lg_coords[4'b0001]          <= y_pipe[PIPE_POS][1] ;
                              lg_coords[4'b0010]          <= x_pipe[PIPE_POS][3] ; // set lg0's second B coordinate.   **** We keept y[2] as the maximum Y-coordinate
                              lg_coords[4'b0011]          <= y_pipe[PIPE_POS][3] ;

                              lg_coords[4'b1100]          <= x_pipe[PIPE_POS][0] ; // set lg1's first A coordinate.
                              lg_coords[4'b1101]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b1110]          <= x_pipe[PIPE_POS][2] ; // set lg1's first B coordinate.
                              lg_coords[4'b1111]          <= y_pipe[PIPE_POS][2] ;
                              lg_coords[4'b1000]          <= x_pipe[PIPE_POS][2] ; // set lg1's second A coordinate.
                              lg_coords[4'b1001]          <= y_pipe[PIPE_POS][2] ;
                              lg_coords[4'b1010]          <= x_pipe[PIPE_POS][3] ; // set lg1's second B coordinate.   **** We keept y[2] as the maximum Y-coordinate
                              lg_coords[4'b1011]          <= y_pipe[PIPE_POS][3] ;
                              end else begin                                       // Swap the X left and right sides
                              lg_coords[4'b0100]          <= x_pipe[PIPE_POS][0] ; // set lg0's first A coordinate.
                              lg_coords[4'b0101]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b0110]          <= x_pipe[PIPE_POS][2] ; // set lg0's first B coordinate.
                              lg_coords[4'b0111]          <= y_pipe[PIPE_POS][2] ;
                              lg_coords[4'b0000]          <= x_pipe[PIPE_POS][2] ; // set lg0's second A coordinate.
                              lg_coords[4'b0001]          <= y_pipe[PIPE_POS][2] ;
                              lg_coords[4'b0010]          <= x_pipe[PIPE_POS][3] ; // set lg0's second B coordinate.   **** We keept y[2] as the maximum Y-coordinate
                              lg_coords[4'b0011]          <= y_pipe[PIPE_POS][3] ;

                              lg_coords[4'b1100]          <= x_pipe[PIPE_POS][0] ; // set lg1's first A coordinate.
                              lg_coords[4'b1101]          <= y_pipe[PIPE_POS][0] ;
                              lg_coords[4'b1110]          <= x_pipe[PIPE_POS][1] ; // set lg1's first B coordinate.
                              lg_coords[4'b1111]          <= y_pipe[PIPE_POS][1] ;
                              lg_coords[4'b1000]          <= x_pipe[PIPE_POS][1] ; // set lg1's second A coordinate.
                              lg_coords[4'b1001]          <= y_pipe[PIPE_POS][1] ;
                              lg_coords[4'b1010]          <= x_pipe[PIPE_POS][3] ; // set lg1's second B coordinate.   **** We keept y[2] as the maximum Y-coordinate
                              lg_coords[4'b1011]          <= y_pipe[PIPE_POS][3] ;
                              end

                              y_range[0]                  <= y_pipe[PIPE_POS][0] ; // Set the beginning of the Y raster fill
                              y_range[1]                  <= y_pipe[PIPE_POS][3] ; // Set the ending of the Y raster fill
                              end

                default     : begin // no valid drawing shape
                              cmd_pipe[PIPE_POS+1][15:8] <= cmd_pipe[PIPE_POS][15:8]; // for now, pass untouched, however once we simplify flat filled shapes down to a line, this will need adjusting
                              draw_shape                 <= 0 ;                    // No draw command for the next module
                              lg_seq_size[0]             <= 0 ;                   // sets the number of coordinate pairs linegen1 needs to draw
                              lg_seq_size[1]             <= 0 ;                   // sets the number of coordinate pairs linegen2 needs to draw
                              lg_fill                    <= 0 ;                   // Disable the fill command
                              end
            endcase
     end else begin // no valid command
          cmd_pipe[PIPE_POS+1][15:8] <= cmd_pipe[PIPE_POS][15:8]; // for now, pass untouched, however once we simplify flat filled shapes down to a line, this will need adjusting
          draw_shape                 <= 0 ;                    // No draw command for the next module
          lg_seq_size[0]             <= 0 ;                   // sets the number of coordinate pairs linegen1 needs to draw
          lg_seq_size[1]             <= 0 ;                   // sets the number of coordinate pairs linegen2 needs to draw
          lg_fill                    <= 0 ;                   // Disable the fill command
     end



    end // enable
end // always_ff

endmodule



/*
 * poly_plot module
 *
 * Outputs array xy_coords ti plot
 * forted for 2 line generators
 * running 2 sets of connected coordinates.
 * Structured output coordinates for linegens 0&1 
 * {lgen#,lg_seq#.lg_ab,lg_xy} = 4 bits = 16 coordinates
 *
 * Also defines the number of linegen sequences each
 * line gen needs to run to finish the shape stored in
 * lg_seq_size[0:1].
 *
 * and defines whether the linegens needs to do a lg_fill
 *
 * Also sets the blit_ena, blit_mask enable and blit_mask_col
 *
 */
module poly_plot (
// inputs
    input logic                 clk              ,
    input logic                 reset            ,
    input logic                 enable           , // !pixel_writer busy input
    input logic                 cmd_rdy_in       ,
    input logic          [15:0] cmd_in           ,
    input logic   signed [11:0] lg_coords [0:15] , // values to plot
    input logic          [1:0]  lg_seq_size [0:1], // array containing the number of line coordinates for each linegen to run
    input logic                 lg_fill          ,
    input logic                 draw_shape       ,
    input logic                 blit_features_in ,
    input logic                 blit_mask_col_in , 
    input logic   signed [11:0] y_range [0:1]    ,
//outputs
    output logic                cmd_rdy_out      ,
    output logic         [15:0] cmd_out          ,
    output logic                pixel_ena        ,
    output logic         [7:0]  pixel_col        ,
    output logic  signed [11:0] pixel_xy [0:1]   , // Destination coordinates
    output logic                plotter_busy     , // The linegens are running
    output logic         [7:0]  blit_features_out, // Defines the blitter module features
    output logic         [7:0]  blit_mask_col_out  // Tells the blitter copy pixel function how to transpose the source pixel color
                                                   // Remember when writing a pixel/line/un-filled triangle/box/quad, the set color does a second
                                                   // color transpose from the copy pixel to the destination pixel color.
);

line_generator linegen_0 (
    // inputs
    .clk            ( clk                ), // 125 MHz pixel clock
    .reset          ( reset              ), // asynchronous reset
    .enable         ( enable             ), // Allows processing
    .run            ( lg_start[0]        ), // HIGH during drawing
    .aX             ( lg_coords[{1'b0,lg_csel[0],2'b00}] ), // 12-bit X-coordinate for line start
    .aY             ( lg_coords[{1'b0,lg_csel[0],2'b01}] ), // 12-bit Y-coordinate for line start
    .bX             ( lg_coords[{1'b0,lg_csel[0],2'b10}] ), // 12-bit X-coordinate for line end
    .bY             ( lg_coords[{1'b0,lg_csel[0],2'b11}] ), // 12-bit Y-coordinate for line end
    .ena_pause      ( lg_pause[0]        ), // set HIGH to pause line generator while it is drawing
    // outputs
    .busy           ( lg_running[0]      ), // HIGH when line_generator is running
    .X_coord        ( lg_out[2'b00]      ), // 12-bit X-coordinate for current pixel
    .Y_coord        ( lg_out[2'b01]      ), // 12-bit Y-coordinate for current pixel
    .pixel_data_rdy ( lg_pix_rdy[0]      ), // HIGH when coordinate outputs are valid
    .line_complete  ( lg_done[0]         )  // HIGH when line is completed
);

line_generator linegen_1 (
    // inputs
    .clk            ( clk                ), // 125 MHz pixel clock
    .reset          ( reset              ), // asynchronous reset
    .enable         ( enable             ), // Allows processing
    .run            ( lg_start[1]        ), // HIGH during drawing
    .aX             ( lg_coords[{1'b1,lg_csel[1],2'b00}] ), // 12-bit X-coordinate for line start
    .aY             ( lg_coords[{1'b1,lg_csel[1],2'b01}] ), // 12-bit Y-coordinate for line start
    .bX             ( lg_coords[{1'b1,lg_csel[1],2'b10}] ), // 12-bit X-coordinate for line end
    .bY             ( lg_coords[{1'b1,lg_csel[1],2'b11}] ), // 12-bit Y-coordinate for line end
    .ena_pause      ( lg_pause[1]        ), // set HIGH to pause line generator
    // outputs
    .busy           ( lg_running[1]      ), // HIGH when line_generator is running
    .X_coord        ( lg_out[2'b10]      ), // 12-bit X-coordinate for current pixel
    .Y_coord        ( lg_out[2'b11]      ), // 12-bit Y-coordinate for current pixel
    .pixel_data_rdy ( lg_pix_rdy[1]      ), // HIGH when coordinate outputs are valid
    .line_complete  ( lg_done[1]         )  // HIGH when line is completed
);

logic signed [11:0] lg_out [0:3] ;  // XY output coordinates of all line generators
logic        [1:0]  lg_running   ;  // Flags stating which linegens are running
logic        [1:0]  lg_pix_rdy   ;  // Flags which linegens have ready pixels
logic        [1:0]  lg_done      ;  // Flags which linegens have completed a line
logic        [1:0]  lg_start     ;  // Initializes the linegens to begin
logic        [1:0]  lg_pause     ;  // Freezes the lingen while they are ijn the middle of drawing
logic        [1:0]  lg_seq_cnt [0:1]  ;  // Linegen sequence counters
logic               execute_next_draw ; // goes high only when ready to accept a new command
logic               linegen_busy      ; // 
logic               fill_ena          ; // 
logic        [1:0]  lg_csel           ; // 
logic        [1:0]  lg_pause_int      ; // 
logic        [1:0]  lg_priority       ; // 

logic signed [11:0] y_pos             ; // Current raster Y position counter
logic signed [11:0] x_pos             ; // Current raster X position counter
logic signed [11:0] x_end             ; // X raster fill starting and ending coordinates
logic               x_dir             ; // X raster fill starting and ending coordinates
logic               rast_fill_pix_rdy ;

always_comb begin
// generate drawing processing busy flags
linegen_busy      = lg_running[0] || lg_running[1] ;
plotter_busy      = (lg_seq_cnt[0] != 0) || (lg_seq_cnt[1] != 0) || linegen_busy ; // The plotter module is busy there are any remaining linegen sequences to be run
execute_next_draw = draw_shape && !plotter_busy && cmd_rdy_in ;

// generate selection of the output write pixel port
pixel_xy[0]       = rast_fill_pix_rdy ? x_pos : (lg_out[{lg_pix_rdy[1],1'b0}]); // select between linegen X coordinates and the x_pos raster fill coordinates
pixel_xy[1]       = lg_out[{lg_pix_rdy[1],1'b1}];
pixel_ena         = lg_pix_rdy[0] || lg_pix_rdy[1] || rast_fill_pix_rdy ;       // output pixel enable

// Tell each linegen when to pause it's output drawing
// Comparing only the last 2 bits of the Y position is a dirty trick
// Which will improve FMAX and FPGA routing as the linegens follor the
// Y position within +/- 1 step at a time anyways, we dont need a 12 bit comparator here.
lg_pause_int[0]  = fill_ena && (lg_out[2'b01][1:0] == y_pos[1:0]) ; // Pause linegen 0, pause if the output Y coordinate equals the current y_pos.
lg_pause_int[1]  = fill_ena && (lg_out[2'b11][1:0] == y_pos[1:0]) ; // Pause linegen 1, pause if the output Y coordinate equals the current y_pos.
lg_pause[0]      = (lg_priority==2'd1) || lg_pause_int[0]         ; // Pause linegen 0, pause if the output Y coordinate equals the current y_pos.
lg_pause[1]      = (lg_priority==2'd0) || lg_pause_int[1]         ; // Pause linegen 1, pause if the output Y coordinate equals the current y_pos.

end

always_ff @(posedge clk) begin

    if ( reset ) begin  // Reset only the key controls in the command pipe.
         blit_features_out   <= 0;
         blit_mask_col_out   <= 0;
         lg_seq_cnt[0]       <= 0;
         lg_seq_cnt[1]       <= 0;
         lg_start[0]         <= 1'b0 ;              // clear the 1-shot linestart
         lg_start[1]         <= 1'b0 ;              // clear the 1-shot linestart
         lg_priority         <= 2'd0 ;              // clear the 1-shot linestart
         rast_fill_pix_rdy   <= 1'd0 ;
    end // reset
    else
    if ( enable ) begin

cmd_out           <= cmd_in;
cmd_rdy_out       <= cmd_rdy_in;


if (lg_start[0]) begin
  lg_seq_cnt[0] <= lg_seq_cnt[0]-1'b1; // subtract counter after linegen has been executed
  lg_start[0]   <= 1'b0 ;              // clear the 1-shot linestart
  end
if (lg_start[1]) begin
  lg_seq_cnt[1] <= lg_seq_cnt[1]-1'b1; // subtract counter after linegen has been executed
  lg_start[1]   <= 1'b0 ;              // clear the 1-shot linestart
  end

if (execute_next_draw) begin
                       lg_seq_cnt        <= lg_seq_size ; // load the number of sequences each linegen needs to cycle through.
                       pixel_col         <= cmd_in[7:0];
                       blit_features_out <= blit_features_in;
                       blit_mask_col_out <= blit_mask_col_in;
                       lg_priority       <= 2'd0;

                       if (lg_fill) begin
                                    y_pos             <= y_range[0] ; // set the starting fill position Y coordinate
                                    fill_ena          <= 1'b1 ;
                                    end else begin
                                    y_pos             <= y_range[1] ; // set the starting fill position Y coordinate
                                    fill_ena          <= 1'b0 ;
                                    end
                        
   end else begin
  if ( !fill_ena ) begin // run the 2 linegens in a sequential manner, 1 after the other.

if (!linegen_busy) begin
      if ( lg_seq_cnt[0]!=0 ) begin  // If there are sequences, first run linegen 0
      lg_start[0]   <= 1'b1;
      lg_csel[0]    <= !lg_seq_cnt[0][0] ; // keep coordinate order
      lg_priority   <= 2'd0;
      end else if ( lg_seq_cnt[1]!=0 ) begin // Then, if there are sequences for linegen 1, cycle them.
      lg_start[1]   <= 1'b1;
      lg_csel[1]    <= !lg_seq_cnt[1][0] ; // keep coordinate order
      lg_priority   <= 2'd1;
      end
end

   end else begin // run the 2 linegens in a parallel fashion aligning them to a Y raster counter & fill a horizontal line between the X coordinates

if (plotter_busy)
   if (!lg_running[0] && lg_seq_cnt[0]!=0 && !lg_start[1]) begin
         lg_start[0]       <= 1'b1;
         lg_csel[0]        <= !lg_seq_cnt[0][0] ; // keep coordinate order
         lg_priority       <= 2'd0;
   end else if (!lg_running[1] && lg_seq_cnt[1]!=0 && !lg_start[0]) begin
         lg_start[1]       <= 1'b1;
         lg_csel[1]        <= !lg_seq_cnt[1][0] ; // keep coordinate order
         lg_priority       <= 2'd1;
   end else begin

 // increment y_position if both linegens are paused because their Y output = the current y_position
    if (lg_pause_int==2'd3) begin
         
           if (x_pos != lg_out[2'b10]) begin      // if there is a void inbetween the 2 linegen's X coordinates
               rast_fill_pix_rdy <= 1'b1;         // begin filling in the void with a line
               if (x_pos > lg_out[2'b10] ) x_pos <= x_pos - 1'b1;
               else                        x_pos <= x_pos + 1'b1;

           end else begin                         // if the fill is finished, increment the y position

           rast_fill_pix_rdy <= 1'b0;
           y_pos             <= y_pos + 1'b1;

                if (lg_running[0])  lg_priority <= 2'd0; // linegen 0 completely finished, make sure linegen 1 will now finish last pixels
           else                     lg_priority <= 2'd1; // linegen 1 completely finished, make sure linegen 0 will now finish last pixels

           end

    end else begin
         
                   x_pos <=  lg_out[2'b00] ; // set the initial fill counter

                  if (lg_seq_cnt[0]==0 && !lg_running[0])  lg_priority <= 2'd1; // linegen 0 completely finished, make sure linegen 1 will now finish last pixels
             else if (lg_seq_cnt[1]==0 && !lg_running[1])  lg_priority <= 2'd0; // linegen 1 completely finished, make sure linegen 0 will now finish last pixels
             else if (lg_pause_int==2'd1)                  lg_priority <= 2'd1; // linegen 1 paused, give priority to linegen 0
         end
   end
   
end
   
   end // plotter busy loop
 end // enable
end // always_ff

endmodule
