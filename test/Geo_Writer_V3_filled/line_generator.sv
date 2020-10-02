/*
 * LINE GENERATOR MODULE
 *
 * v 0.1.011
 *
 */

module line_generator (
// inputs
  input logic                clk,              // 125 MHz pixel clock
  input logic                reset,            // asynchronous reset
  input logic                run,              // HIGH to draw / run the unit
  input logic                draw_busy,        // draw_busy input from parent module
  input logic                pass_thru_a,      // set HIGH to pass through aX/aY coordinates
  input logic                pass_thru_b,      // set HIGH to pass through bX/bY coordinates
  input logic signed  [11:0] aX,               // 12-bit X-coordinate for line start
  input logic signed  [11:0] aY,               // 12-bit Y-coordinate for line start
  input logic signed  [11:0] bX,               // 12-bit X-coordinate for line end
  input logic signed  [11:0] bY,               // 12-bit Y-coordinate for line end
  input logic                ena_stop_y,       // set HIGH to make line generator stop at next ypos (raster line)
  input logic                lineIndex,
// outputs
  output logic               busy,             // HIGH when line_generator is running
  output logic signed [11:0] X_coord,          // 12-bit X-coordinate for current pixel
  output logic signed [11:0] Y_coord,          // 12-bit Y-coordinate for current pixel
  output logic               pixel_data_rdy,   // HIGH when coordinate outputs are valid
  output logic               ypos_stopped,     // HIGH when stopped on Y-position
  output logic               line_complete     // HIGH when line is completed
  
);

logic               draw_line     = 1'b0 ;
logic        [3:0]  geo_sub_func1 = 4'b0 ;
logic signed [11:0] geo_xdir             ;
logic signed [11:0] geo_ydir             ;
logic signed [11:0] dx                   ;
logic signed [11:0] dy                   ;
logic signed [11:0] errd                 ;
logic signed [11:0] latch_aX             ;
logic signed [11:0] latch_aY             ;
logic signed [11:0] latch_bX             ;
logic signed [11:0] latch_bY             ;
logic               last_run             ; // register for last clock's 'run' signal
logic               start                ; // edge-detect for new 'run' signals
logic               last_ena_stop_y      ; // register for last clock's 'ena_stop_y' signal
logic               reset_stop_y         ; // edge-detect for 'ena_stop_y' signal
logic               pixel_data_rdy_int   ; // internal pixel data ready register before output
logic               ypos_stopped_int     ; // the internal ypos_stopped state
logic               busy_int             ; // the internal ingine is busy drawing a line

always_comb begin

    start          = ( !last_run && run )                ; // HIGH for one clock when run goes HIGH

    ypos_stopped   = ypos_stopped_int && ena_stop_y      ; // ypos_stopped goes low immediately if ena_stop_y is disabled
    pixel_data_rdy = pixel_data_rdy_int && !ypos_stopped ; // pixel_data_rdy only goes HIGH when y_pos_stopped and ena_stop_y input aren't active
 
 // Create a 1-shot pulse at the same time the last pixel is being drawn.
    //line_complete  = pixel_data_rdy && ( (X_coord == bX && Y_coord == bY) || (run && ( aX == bX && aY == bY )) ) ;
 // Turn off the busy during the final pixel so the next command may be loaded sooner
    busy           = busy_int;// && !line_complete;

end

always @( posedge clk or posedge reset ) begin

    if ( reset ) begin
    
        // reset geometry counters and flags
        geo_xdir           <= 12'b0 ;
        geo_ydir           <= 12'b0 ;
        geo_sub_func1      <= 4'b0  ;
        dx                 <= 12'b0 ;
        dy                 <= 12'b0 ;
        errd               <= 12'b0 ;
        draw_line          <= 1'b0  ;
        pixel_data_rdy_int <= 1'b0  ;
        ypos_stopped_int   <= 1'b0  ;
        busy_int           <= 1'b0  ;
        X_coord            <= 12'b0 ;
        Y_coord            <= 12'b0 ;
        line_complete      <= 0;
        
    end else if ( !draw_busy ) begin // draw_busy must be LOW or the line generator won't run
   
        last_run <= run ;
        
        if ( pass_thru_a /*|| ( run && ( aX == bX && aY == bY ) )*/ )begin

            pixel_data_rdy_int <= 1'b1 ; // valid coordinates at output
            X_coord            <= aX   ; // pass-through aX value
            Y_coord            <= aY   ; // pass-through aY value
            //if ( run && ( aX == bX && aY == bY ) ) line_complete      <= 1; // immediately say the line is complete...
        
        end else
        if ( pass_thru_b ) begin
        
            pixel_data_rdy_int <= 1'b1 ; // valid coordinates at output
            X_coord            <= bX   ; // pass-through bX value
            Y_coord            <= bY   ; // pass-through bY value
            //line_complete      <= 1;
            
        end
        else
        if ( start ) begin  // load values and begin drawing the line
        
            // Set latched registers, phase counters and flags
            geo_sub_func1      <= 4'b0 ; // reset the phase counter
            ypos_stopped_int   <= 1'b0 ; // reset ypos_stopped_int flag
            draw_line          <= 1'b1 ; // start drawing the line on the next clock cycle
            busy_int           <= 1'b1 ; // the line generator is busy_int  from the next cycle
            pixel_data_rdy_int <= 1'b0 ; // no valid coordinates next clock cycle
            line_complete      <= 0;

            // Initialise starting coordinates and direction for immediate plotting
            X_coord            <= aX   ; // initialize starting X pixel location
            Y_coord            <= aY   ; // initialize starting Y pixel location

            // latch the coordinates to check for changes later
            latch_aX           <= aX   ;
            latch_aY           <= aY   ;
            latch_bX           <= bX   ;
            latch_bY           <= bY   ;

            // Set the direction of the counter
            if ( bX < aX )       geo_xdir <= 12'd0 - 12'd1 ; // negative X direction
            else if ( bX == aX ) geo_xdir <= 12'd0         ; // neutral X direction
            else                 geo_xdir <= 12'd1         ; // positive X direction
            if ( bY < aY )       geo_ydir <= 12'd0 - 12'd1 ; // negative Y direction
            else if ( bY == aY ) geo_ydir <= 12'd0         ; // neutral Y direction
            else                 geo_ydir <= 12'd1         ; // positive Y direction

            // Set absolute size of bounding rectangle
            dx <= ( bX > aX ) ? ( bX - aX ) : ( aX - bX ) ; // get absolute size of delta-x
            dy <= ( aY > bY ) ? ( bY - aY ) : ( aY - bY ) ; // get absolute size of delta-y

        end // if start && !ypos_stopped
        else
        if ( draw_line && !ypos_stopped ) begin
        
            case (geo_sub_func1) // during the draw line, we have multiple sub-functions to call 1 at a time

                4'd0 : begin

                    errd               <= dx + dy ; // set errd's starting value
                    geo_sub_func1      <= 4'd1    ; // set line sub-function to plot line
                    pixel_data_rdy_int <= 1'b1    ; // let the parent module know pixel coordinates are incoming

                    // Begin line in stopped state after the first pixel comes out...
                    if ( lineIndex ) ypos_stopped_int   <= 1'b1    ; // PREset ypos_stopped_int flag
                    
                end // geo_sub_func1 = 0 - setup for plot line

                4'd1 : begin

                    if ( X_coord == bX && Y_coord == bY ) begin // reached end of line

                        draw_line          <= 1'b0  ; // last pixel - allow time for this pixel to be written by ending on next clock
                        pixel_data_rdy_int <= 1'b0  ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock
                        busy_int           <= 1'b0  ; // line generator is no longer busy_int 
                        X_coord            <= 12'b0 ; // clear X_coord output to zero
                        Y_coord            <= 12'b0 ; // clear Y_coord output to zero
                        geo_sub_func1      <= 4'b0  ; // reset the phase counter
                        ypos_stopped_int   <= 1'b0  ; // reset ypos_stopped_int flag
                        line_complete      <= 1;
                        
                    //end else if ( ena_stop_y && Y_coord == stop_ypos ) begin // reached Y_coordinate stop position and we want to stop on Y_pos

                        //ypos_stopped_int   <= 1'b1  ; // let the parent module know the line generator has stopped on ypos
                        //draw_line      <= 1'b0  ; // last pixel - allow time for this pixel to be written by ending on next clock
                        //pixel_data_rdy_int <= 1'b0  ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock

                    end else
                    begin  // Bresenham's Line Drawing Algorithm
                        
                        draw_line          <= 1'b1 ; // last pixel - allow time for this pixel to be written by ending on next clock
                        ypos_stopped_int   <= 1'b0 ;
                      
                        if ( ( errd << 1 ) > dy ) begin

                            X_coord <= X_coord + geo_xdir    ; // add increment to X coordinate
                            
                            if ( ( ( errd << 1 ) + dy ) < dx ) begin
                            
                                errd             <= errd + dx + dy     ; // update errd
                                Y_coord          <= Y_coord + geo_ydir ; // add increment to Y coordinate
                                ypos_stopped_int <= 1'b1               ;
                            
                            end else begin
                            
                                errd             <= errd + dy          ; // add Y increment to errd
                            
                            end
                            
                        end else if ( ( errd << 1 ) < dx ) begin

                            errd             <= errd  + dx         ; // add X increment to errd
                            Y_coord          <= Y_coord + geo_ydir ; // add Y increment to Y coordinate
                            ypos_stopped_int <= 1'b1               ;
                        
                        end
                        
                    end // Bresenham's Line Drawing Algorithm
                       
                end // geo_sub_func1 = 1 - plot line
                 
            endcase // case geo_sub_func1
        
        end // if ( draw_line && !ypos_stopped )
        else
        if (!draw_line ) begin
                         pixel_data_rdy_int <= 1'b0 ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock //
                         line_complete      <= 1'b0 ; // make sure line_complete is a single 1 shot clock cycle.
                         end

    end // if !draw_busy

end

endmodule
