/*
 *      GEOFF MODULE
 *  (geometry_xy_plotter)
 *
 *       v 0.1.005
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
    output wire fifo_cmd_busy,     // HIGH when FIFO is full/nearly full
    output wire y_stopped // *** TEST PIN
    //  AUX=0  : Do nothing
    //  AUX=1  : Write pixel,                             : 31:24 color         : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=2  : Write pixel with color 0 mask,           : 31:24 color         : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=3  : Write from read pixel,                   : 31:24 ignored       : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=4  : Write from read pixel with color 0 mask, : 31:24 ignored       : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=6  : Read source pixel,                       : 31:24 ignored       : 23:12 Y coordinates : 11:0 X coordinates
    //  AUX=7  : Set Truecolor pixel color                : 31:24 8 bit alpha blend mix value : bits 23:0 hold RGB 24 bit color
    //                                                    Use function Aux3/4 to draw this color, only works if the destination is set to 16 bit true-color mode

    //  AUX=10 ; Resets the Write Pixel collision counter           : 31:24 sets transparent masked out color : bits 23:0 in true color mode, this holds RGB 24 bit mask color, in 8 bit mode, this allows for 3 additional transparent colors
    //  AUX=11 ; Resets the Write from read pixel collision counter : 31:24 sets transparent masked out color : bits 23:0 in true color mode, this holds RGB 24 bit mask color, in 8 bit mode, this allows for 3 additional transparent colors

    //  AUX=12 : Set destination raster width in bytes    : 15:0 holds destination raster image width in #bytes so the proper memory address can be calculated from the X&Y coordinates
    //  AUX=13 : Set source raster width in bytes,        : 15:0 holds source raster image width in #bytes so the proper memory address can be calculated from the X&Y coordinates
    //  AUX=14 : Set destination mem address,             : 31:24 bitplane mode : 23:0 hold destination base memory addres for write pixel
    //  AUX=15 : Set source mem address,                  : 31:24 bitplane mode : 23:0 hold the source base memory address for read source pixel
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

wire [7:0]  command_in     ;
wire [11:0] command_data12 ;
wire [7:0]  command_data8  ;

assign command_in     [7:0] = cmd_data[15:8] ;
assign command_data12[11:0] = cmd_data[11:0] ;
assign command_data8  [7:0] = cmd_data[7:0]  ;

reg [11:0] x[3:0] ; // 2-dimensional 12-bit register for x0-x3
reg [11:0] y[3:0] ; // 2-dimensional 12-bit register for y0-y3
reg [11:0] max_x  ; // this reg will be both in this module and the memory pixel writer
reg [11:0] max_y  ; // this reg will be both in this module and the memory pixel writer

reg [3:0]  draw_cmd_func        ;
reg [7:0]  draw_cmd_data_color  ;
reg [11:0] draw_cmd_data_word_Y ;
reg [11:0] draw_cmd_data_word_X ;
reg        draw_cmd_tx = 1'b0   ;

//************************************************
// Assign output port wires to internal registers
//************************************************
assign draw_cmd[35:32] = draw_cmd_func[3:0]         ;
assign draw_cmd[31:24] = draw_cmd_data_color[7:0]   ;
assign draw_cmd[23:12] = draw_cmd_data_word_Y[11:0] ;
assign draw_cmd[11:0]  = draw_cmd_data_word_X[11:0] ;
assign draw_cmd_rdy    = draw_cmd_tx && !draw_busy  ;

//************************************************
// geometry sequencer controls
//************************************************
reg [3:0]    geo_shape;            // 0 through 7 will draw their assigned shape, 8 through 15 will have different copy algorithms
reg          geo_fill;             // The geometric shape should be filled when set high
reg          geo_mask;             // If high, when drawing, the colors set in the 'collision counter' will not be drawn.
reg          geo_paste;            // If high, when drawing a geometric object, CMD_OUT_PXPASTE/_M will be used instead of CMD_OUT_PXWRI/_M for true color 16bit pixels
reg          geo_run   = 1'b0;     // High when a geometric shape is being drawn
reg [7:0]    geo_color;            // 8 bit pen drawing color

assign       load_cmd = ~geo_run;  // assigns the load_cmd output.  When the geometry unit is not drawing, the load_cmd goes high to load the next command.

//************************************************
// geometry counters
//************************************************
logic signed [11:0]   geo_x          ;
logic signed [11:0]   geo_y          ;
logic signed [11:0]   geo_xdir       ;
logic signed [11:0]   geo_ydir       ;
logic        [3:0]    geo_sub_func1  ; // auxiliary sequence counter
logic        [3:0]    geo_sub_func2  ; // auxiliary sequence counter
logic signed [11:0]   dx             ;
logic signed [11:0]   dy             ;
logic signed [11:0]   errd           ;
logic        [15:0]   cmd_data       ;
logic                 fifo_cmd_rdy_n ;

scfifo  scfifo_component (
    .sclr        (reset),                                     // reset input
    .clock       (clk),                                       // system clock
    .wrreq       (fifo_cmd_ready),                            // connect this to the 'strobe' on the selected high.low Z80 bus output port.
    .data        (fifo_cmd_in),                               // connect this to the 16 bit output port on the Z80 bus.
    .almost_full (fifo_cmd_busy),                             // send to a selected bit on the Z80 status read port

    .empty       (fifo_cmd_rdy_n),                            // remember, when low, the FIFO has commands for the geometry unit to process
    .rdreq       (load_cmd && !draw_busy && !fifo_cmd_rdy_n), // connect to the listed inputs.
    .q           (cmd_data[15:0]),                            // to geometry_xy_plotter cmd_data input.
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

logic linegen_start       ;
logic line_done           ;
logic pass_thru_a         ;
logic pass_thru_b         ;
//logic y_stop              ;
//logic y_stopped           ;
logic [11:0] y_stop_coord ;
logic line_dat_rdy        ;
logic line_gen_running    ;
logic [11:0] gen_x        ;
logic [11:0] gen_y        ;

line_generator linegen_1 (
// inputs
  .clk            ( clk ),              // 125 MHz pixel clock
  .reset          ( reset ),            // asynchronous reset
  .run            ( linegen_start ),    // HIGH during drawing
  .draw_busy      ( draw_busy ),        // draw_busy input from parent module
  .pass_thru_a    ( pass_thru_a ),      // set HIGH to pass through aX/aY coordinates
  .pass_thru_b    ( pass_thru_b ),      // set HIGH to pass through bX/bY coordinates
  .aX             ( x[0] ),             // 12-bit X-coordinate for line start
  .aY             ( y[0] ),             // 12-bit Y-coordinate for line start
  .bX             ( x[1] ),             // 12-bit X-coordinate for line end
  .bY             ( y[1] ),             // 12-bit Y-coordinate for line end
  .ena_stop_y     ( y_stopped ),        // set HIGH to make line generator stop at next Y increment
  //.stop_ypos      ( y_stop_coord ),     // Y_coordinate to stop at
// outputs
  .busy           ( line_gen_running ), // HIGH when line_generator is running
  .X_coord        ( gen_x ),            // 12-bit X-coordinate for current pixel
  .Y_coord        ( gen_y ),            // 12-bit Y-coordinate for current pixel
  .pixel_data_rdy ( line_dat_rdy ),     // HIGH when coordinate outputs are valid
  .ypos_stopped   ( y_stopped ),        // HIGH when stopped on Y-position
  .line_complete  ( line_done )         // HIGH when line is completed

);

always_comb begin

    // Any time any of the linegens or blitter are working, geo_run needs to go immediately high to stop loading new commands
    geo_run       = line_gen_running ;
    // Trigger a linegen if a valid draw command comes in
    linegen_start = !reset && ( !fifo_cmd_rdy_n && ~geo_run ) && ( command_in[7:5] == 3'd0 && command_in[2:0] == 3'd1 ) ;  // for now, only the draw line command

end // always_comb

always @(posedge clk or posedge reset) begin

    if (reset) begin    // reset to defaults
        
        // reset coordinate registers
        for ( integer i = 0; i < 4; i++ ) begin
            x[i]  <= { 12'b0 } ;
            y[i]  <= { 12'b0 } ;
        end
        max_x     <= 12'b0     ;
        max_y     <= 12'b0     ;

        // reset draw command registers
        draw_cmd_func        <= 4'b0  ;
        draw_cmd_data_color  <= 8'b0  ;
        draw_cmd_data_word_Y <= 12'b0 ;
        draw_cmd_data_word_X <= 12'b0 ;
        draw_cmd_tx          <= 1'b0  ;

        // reset geometry sequencer controls
        geo_shape     <= 4'b0  ;
        geo_fill      <= 1'b0  ;
        geo_mask      <= 1'b0  ;
        geo_paste     <= 1'b0  ;
        geo_color     <= 8'b0  ;
        
        // reset geometry counters
        geo_x         <= 12'b0 ;
        geo_y         <= 12'b0 ;
        geo_xdir      <= 12'b0 ;
        geo_ydir      <= 12'b0 ;
        geo_sub_func1 <= 4'b0  ;
        geo_sub_func2 <= 4'b0  ;
        dx            <= 12'b0 ;
        dy            <= 12'b0 ;
        errd          <= 12'b0 ;

    end else if (!draw_busy) begin  // Everything must PAUSE if the incoming draw_busy signal from the pixel_writer is high

// ********************************************************************************************************************************
// This code passes through the pixel draw command and pixel_cmd_ready when the final line_gen or blitter has a ready pixel.
// ********************************************************************************************************************************
       draw_cmd_func        <= CMD_OUT_PXWRI[3:0] ; // Set up command to pixel plotter to write a pixel,
       draw_cmd_data_color  <= geo_color          ; // ... in geo_colour,
       draw_cmd_data_word_Y <= gen_y              ; // ... at Y-coordinate,
       draw_cmd_data_word_X <= gen_x              ; // ... and X-coordinate.

       if ( line_dat_rdy && ( gen_x >= 0 && gen_x <= max_x ) && ( gen_y >=0 && gen_y <= max_y ) )
          draw_cmd_tx       <= 1'b1  ;              // send command if geo_X&Y are within valid drawing area
       else
          draw_cmd_tx       <= 1'b0  ;              // otherwise turn off draw command

// ********************************************************************************************************************************
// This code interprets the incoming commands when the linegens and blitter are not generating pixels.
// ********************************************************************************************************************************
        if ( !fifo_cmd_rdy_n && ~geo_run ) begin  // when the fifo_cmd_rdy_n input is LOW and the geometry unit geo_run is not running, execute the following command input

            casez (command_in)
            
                8'b10?????? : x[command_in[5:4]] <= command_data12 ;
                
                8'b11?????? : y[command_in[5:4]] <= command_data12 ;

                8'b011111?? : begin // set 24-bit destination screen memory pointer for plotting
                    draw_cmd_func        <= CMD_OUT_DSTMADDR[3:0]  ;  // sets the output function
                    draw_cmd_data_color  <= command_data8          ;  // set screen_mode (bits per pixel)
                    draw_cmd_data_word_Y <= y[command_in[1:0]]     ;  // sets the upper 12 bits of the destination address
                    draw_cmd_data_word_X <= x[command_in[1:0]]     ;  // sets the lower 12 bits of the destination address
                    draw_cmd_tx          <= 1'b1                   ;  // transmits the command
                end

                8'b011110?? : begin // set 24-bit source screen memory pointer for blitter copy
                    draw_cmd_func        <= CMD_OUT_SRCMADDR[3:0]  ;  // sets the output function
                    draw_cmd_data_color  <= command_data8          ;  // set screen_mode (bits per pixel)
                    draw_cmd_data_word_Y <= y[command_in[1:0]]     ;  // sets the upper 12 bits of the destination address
                    draw_cmd_data_word_X <= x[command_in[1:0]]     ;  // sets the lower 12 bits of the destination address
                    draw_cmd_tx          <= 1'b1                   ;  // transmits the command
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
                    max_x <= x[2] ;    // set max width & height of screen to x2/y2
                    max_y <= y[2] ;
                    //********************  no command to be set......draw_cmd_tx <= 1'b1;
                end
                
                8'd92 : begin
                    max_x <= x[3];    // set max width & height of screen to x3/y3
                    max_y <= y[3];
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
                
				   // drawing commands begin here.  Keep the convention that:
				   // extend_cmd[3] = fill enable
				   // extend_cmd[4] = use the color in the copy/paste buffer.  This one is for drawing in true color mode.
				   // extend_cmd[5] = mask enable - when drawing, the mask colours will not be plotted as they are transparent
                    geo_shape[3]         <= 1'b0;               // geo shapes 0 through 7, geo shapes 8 through 15 are for copy & paste.
                    geo_shape[2:0]       <= command_in[2:0];    // Set which one of shapes 0 through 7 should be drawn.  Shape 0 means nothing is being drawn
                    geo_fill             <= command_in[3];      // Fill enable bit
                    geo_paste            <= command_in[4];      // Used for drawing in true color 16 bit mode
                    geo_mask             <= 1'b0;               // Mask disables when drawing raw geometry shapes
                    geo_color            <= command_data8;      // set the 8-bit pen color

                 end

                default : begin
                
                    geo_shape   <= 4'b0 ; // turn off the drawing shape
                    
                end

            endcase
            
        end 
    
    end // !draw_busy

end //always @(posedge clk)

endmodule

module tri_comp (

// inputs
   input  logic                    clk,
   input  logic signed [3:0][11:0] in,
// outputs
   output logic        [15:0]      in_a_eq_b,
   output logic        [15:0]      in_a_gt_b,
   output logic        [15:0]      in_a_lt_b

);

parameter bit CLOCK_OUTPUT = 0;

always_comb begin

   if ( ~CLOCK_OUTPUT ) begin
   
      for (int i = 0 ; i<=15 ; i++) begin
      
         in_a_eq_b[i] = ( in[ i[3:2] ] == in[ i[1:0] ] ) ;
         in_a_gt_b[i] = ( in[ i[3:2] ] >  in[ i[1:0] ] ) ;
         in_a_lt_b[i] = ( in[ i[3:2] ] <  in[ i[1:0] ] ) ;
         
      end
      
   end

end

always_ff @( posedge clk ) begin

   if ( CLOCK_OUTPUT ) begin
   
      for (int i = 0 ; i<=15 ; i++) begin
      
         in_a_eq_b[i] <= ( in[ i[3:2] ] == in[ i[1:0] ] ) ;
         in_a_gt_b[i] <= ( in[ i[3:2] ] >  in[ i[1:0] ] ) ;
         in_a_lt_b[i] <= ( in[ i[3:2] ] <  in[ i[1:0] ] ) ;
         
      end
      
   end

end

endmodule
