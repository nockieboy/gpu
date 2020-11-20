/*
 * LINE GENERATOR MODULE
 *
<<<<<<< HEAD
 * v 0.1.014
=======
 * v 0.1.002
>>>>>>> e95a3e278b115b0ea9f980c63d48b6bfbcc232d1
 *
 */

module line_generator (
// inputs
  input logic                clk,              // 125 MHz pixel clock
  input logic                reset,            // asynchronous reset
<<<<<<< HEAD
  input logic                enable,           // logic enable
  input logic                run,              // HIGH to draw / run the unit
=======
  input logic                run,              // HIGH to draw / run the unit
  input logic                draw_busy,        // draw_busy input from parent module
  input logic                pass_thru_a,      // set HIGH to pass through aX/aY coordinates
  input logic                pass_thru_b,      // set HIGH to pass through bX/bY coordinates
>>>>>>> e95a3e278b115b0ea9f980c63d48b6bfbcc232d1
  input logic signed  [11:0] aX,               // 12-bit X-coordinate for line start
  input logic signed  [11:0] aY,               // 12-bit Y-coordinate for line start
  input logic signed  [11:0] bX,               // 12-bit X-coordinate for line end
  input logic signed  [11:0] bY,               // 12-bit Y-coordinate for line end
<<<<<<< HEAD
  input logic                ena_pause,         // set HIGH to pause line generator while it is drawing
=======
  input logic                ena_stop_y,       // set HIGH to make line generator stop at stop_ypos
  input logic signed  [11:0] stop_ypos,        // Y_coordinate to stop at
>>>>>>> e95a3e278b115b0ea9f980c63d48b6bfbcc232d1
// outputs
  output logic               busy,             // HIGH when line_generator is running
  output logic signed [11:0] X_coord,          // 12-bit X-coordinate for current pixel
  output logic signed [11:0] Y_coord,          // 12-bit Y-coordinate for current pixel
  output logic               pixel_data_rdy,   // HIGH when coordinate outputs are valid
<<<<<<< HEAD
=======
  output logic               ypos_stopped,     // HIGH when stopped on Y-position
>>>>>>> e95a3e278b115b0ea9f980c63d48b6bfbcc232d1
  output logic               line_complete     // HIGH when line is completed
  
);

logic               draw_line     = 1'b0 ;
<<<<<<< HEAD
logic        [1:0]  geo_sub_func1 = 1'b0 ;
=======
logic               stop_ypos_en  = 1'b0 ;
logic        [3:0]  geo_sub_func1 = 4'b0 ;
>>>>>>> e95a3e278b115b0ea9f980c63d48b6bfbcc232d1
logic signed [11:0] geo_xdir             ;
logic signed [11:0] geo_ydir             ;
logic signed [11:0] dx                   ;
logic signed [11:0] dy                   ;
<<<<<<< HEAD
logic signed [11:0] lat_bX               ;
logic signed [11:0] lat_bY               ;
logic signed [11:0] errd                 ;
logic               pixel_data_rdy_int   ;   // HIGH when coordinate outputs are valid
logic               busy_int   ;   // HIGH when coordinate outputs are valid

always_comb begin
pixel_data_rdy = pixel_data_rdy_int && !ena_pause ; // immediately clear the pixel_data_ready output when the pause is high.
busy           = busy_int || run ;                  // immediately make busy flag high when run is asserted
end


always_ff @( posedge clk  or posedge reset) begin

    if ( reset ) begin
    
        // reset geometry counters and flags
        geo_xdir           <= 12'b0 ;
        geo_ydir           <= 12'b0 ;
        geo_sub_func1      <= 1'b0  ;
        dx                 <= 12'b0 ;
        dy                 <= 12'b0 ;
        errd               <= 12'b0 ;
        draw_line          <= 1'b0  ;
        pixel_data_rdy_int <= 1'b0  ;
        busy_int           <= 1'b0  ;
        X_coord            <= 12'b0 ;
        Y_coord            <= 12'b0 ;
        lat_bX             <= 12'b0 ;
        lat_bY             <= 12'b0 ;
        line_complete      <= 0;
        
    end else if ( enable ) begin // draw_busy_int must be LOW or the line generator won't run

        if ( run ) begin  // load values and begin drawing the line

            // Initialise starting coordinates and direction for immediate plotting
            X_coord            <= aX   ; // initialize starting X pixel location
            Y_coord            <= aY   ; // initialize starting Y pixel location
            lat_bX             <= bX   ; // latch the destination coordinates
            lat_bY             <= bY   ; // latch the destination coordinates

                   if ((aX==bX) && (aY==bY)) begin // Drawing only a single point
                         pixel_data_rdy_int <= 1'b1 ; // set pixel_data_rdy_int flag
                         line_complete      <= 1'b1 ; // make sure line_complete is set.
                         geo_sub_func1      <= 1'b0 ; // reset the phase counter
                         draw_line          <= 1'b0 ; // no line to draw
                         busy_int           <= 1'b0 ; // the line generator is busy_int  from the next cycle
						 
       end else begin //  Drawing a full line
       
            // Set latched registers, phase counters and flags
            geo_sub_func1      <= 1'b0 ; // reset the phase counter
            draw_line          <= 1'b1 ; // start drawing the line on the next clock cycle
            busy_int           <= 1'b1 ; // the line generator is busy_int  from the next cycle
            pixel_data_rdy_int <= 1'b0 ; // no valid coordinates next clock cycle
            line_complete      <= 1'b0 ;

=======
logic signed [11:0] errd                 ;
logic signed [11:0] Y_stop               ;
logic signed [11:0] latch_aX             ;
logic signed [11:0] latch_aY             ;
logic signed [11:0] latch_bX             ;
logic signed [11:0] latch_bY             ;
logic               last_run             ; // register for last clock's 'run' signal
logic               start                ; // edge-detect for new 'run' signals

always_comb begin

   start = ( !last_run && run ) ; // start goes HIGH for one clock when run goes HIGH

end

always @( posedge clk ) begin


    if ( !draw_busy ) begin // draw_busy must be LOW or the line generator won't run
   
      last_run <= run ;

        if ( !run && ( latch_aX != aX || latch_aY != aY || latch_bX != bX || latch_bY != bY ) ) begin

            // coordinates have changed
            ypos_stopped   <= 1'b0 ;
    
        end

      if ( run && ( pass_thru_a || ( aX == bX && aY == bY ) ) ) begin

         pixel_data_rdy <= 1'b1 ; // valid coordinates at output
         X_coord        <= aX   ; // pass-through aX value
         Y_coord        <= aY   ; // pass-through aY value
         
         if ( aX == bX && aY == bY ) begin

            line_complete  <= 1'b1 ; // set line_complete flag to let parent module know the line is done

         end
         
      end
        else
        if ( run && pass_thru_b ) begin
        
            pixel_data_rdy <= 1'b1 ; // valid coordinates at output
            X_coord        <= bX   ; // pass-through bX value
            Y_coord        <= bY   ; // pass-through bY value
        
        end
        else
        if ( start ) begin  // load values and begin drawing the line
        
            // Set latched registers, phase counters and flags
            geo_sub_func1  <= 4'b0 ; // reset the phase counter
            ypos_stopped   <= 1'b0 ; // reset ypos_stopped flag
            line_complete  <= 1'b0 ; // reset line_complete flag
            draw_line      <= 1'b1 ; // start drawing the line on the next clock cycle
            busy           <= 1'b1 ; // the line generator is busy from the next cycle
            pixel_data_rdy <= 1'b0 ; // no valid coordinates next clock cycle

            // Initialise starting coordinates and direction for immediate plotting
            X_coord        <= aX   ; // initialize starting X pixel location
            Y_coord        <= aY   ; // initialize starting Y pixel location
            
            // latch the coordinates to check for changes later
            latch_aX       <= aX   ;
            latch_aY       <= aY   ;
            latch_bX       <= bX   ;
            latch_bY       <= bY   ;
            
>>>>>>> e95a3e278b115b0ea9f980c63d48b6bfbcc232d1
            // Set the direction of the counter
            if ( bX < aX )       geo_xdir <= 12'd0 - 12'd1 ; // negative X direction
            else if ( bX == aX ) geo_xdir <= 12'd0         ; // neutral X direction
            else                 geo_xdir <= 12'd1         ; // positive X direction
            if ( bY < aY )       geo_ydir <= 12'd0 - 12'd1 ; // negative Y direction
            else if ( bY == aY ) geo_ydir <= 12'd0         ; // neutral Y direction
            else                 geo_ydir <= 12'd1         ; // positive Y direction
<<<<<<< HEAD

=======
            
>>>>>>> e95a3e278b115b0ea9f980c63d48b6bfbcc232d1
            // Set absolute size of bounding rectangle
            dx <= ( bX > aX ) ? ( bX - aX ) : ( aX - bX ) ; // get absolute size of delta-x
            dy <= ( aY > bY ) ? ( bY - aY ) : ( aY - bY ) ; // get absolute size of delta-y

<<<<<<< HEAD
        end // if !draw a single point 
        end // if start
        else
        if ( draw_line && !ena_pause ) begin
        
            case (geo_sub_func1) // during the draw line, we have multiple sub-functions to call 1 at a time

                1'd0 : begin

                    errd               <= dx + dy   ; // set errd's starting value
                    geo_sub_func1      <= 1'd1      ; // set line sub-function to plot line
                    pixel_data_rdy_int <= 1'b1      ; // let the parent module know pixel coordinates are incoming
                   
                end // geo_sub_func1 = 0 - setup for plot line

                1'd1 : begin

                    if ( X_coord == lat_bX && Y_coord == lat_bY ) begin // reached end of line

                        draw_line          <= 1'b0  ; // last pixel - allow time for this pixel to be written by ending on next clock
                        pixel_data_rdy_int <= 1'b0  ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock
                        geo_sub_func1      <= 1'b0  ; // reset the phase counter
                        line_complete      <= 1;
                        busy_int           <= 1'b0 ; // line generator is no longer busy_int 
                        
                    end else
                    begin  // Bresenham's Line Drawing Algorithm
                        
                        draw_line          <= 1'b1 ; // last pixel - allow time for this pixel to be written by ending on next clock
                     
                        if ( ( errd << 1 ) > dy ) begin

                            X_coord <= X_coord + geo_xdir    ; // add increment to X coordinate
                            
                            if ( ( ( errd << 1 ) + dy ) < dx ) begin
                            
                                errd             <= errd + dx + dy     ; // update errd
                                Y_coord          <= Y_coord + geo_ydir ; // add increment to Y coordinate
                            
                            end else begin
                            
                                errd             <= errd + dy          ; // add Y increment to errd
                            
                            end
                            
                        end else if ( ( errd << 1 ) < dx ) begin

                            errd             <= errd  + dx         ; // add X increment to errd
                            Y_coord          <= Y_coord + geo_ydir ; // add Y increment to Y coordinate
                        
                        end
                        
                    end // Bresenham's Line Drawing Algorithm
                       
                end // geo_sub_func1 = 1 - plot line
                 
            endcase // case geo_sub_func1
        
        end // if ( draw_line  )
        else
        if (!draw_line ) begin
                         pixel_data_rdy_int <= 1'b0 ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock //
                         line_complete      <= 1'b0 ; // make sure line_complete is a single 1 shot clock cycle.
                         busy_int           <= 1'b0 ; // the line generator is busy_int  from the next cycle
                         end


    end // if !draw_busy_int

=======
        end // if reset
        else
        if ( draw_line ) begin
        
            case (geo_sub_func1) // during the draw line, we have multiple sub-functions to call 1 at a time

                 4'd0 : begin
              
                    errd            <= dx + dy  ; // set errd's starting value
                    geo_sub_func1   <= 4'd1     ; // set line sub-function to plot line
                    pixel_data_rdy  <= 1'b1     ; // let the parent module know pixel coordinates are incoming
                        
                 end // geo_sub_func1 = 0 - setup for plot line

                 4'd1 : begin

                    if ( X_coord == bX && Y_coord == bY ) begin // reached end of line
                    
                        line_complete  <= 1'b1  ; // set line_complete flag to let parent module know the line is done
                        draw_line      <= 1'b0  ; // last pixel - allow time for this pixel to be written by ending on next clock
                        pixel_data_rdy <= 1'b0  ; // reset pixel_data_rdy flag - no more valid coordinates after this clock
                        busy           <= 1'b0  ; // line generator is no longer busy
                        X_coord        <= 12'b0 ; // clear X_coord output to zero
                        Y_coord        <= 12'b0 ; // clear Y_coord output to zero
                        geo_sub_func1  <= 4'b0  ; // reset the phase counter
                        
                    end else if ( ena_stop_y && Y_coord == stop_ypos ) begin // reached Y_coordinate stop position and we want to stop on Y_pos
                    
                        ypos_stopped   <= 1'b1  ; // let the parent module know the line generator has stopped on ypos
                        draw_line      <= 1'b0  ; // last pixel - allow time for this pixel to be written by ending on next clock
                        pixel_data_rdy <= 1'b0  ; // reset pixel_data_rdy flag - no more valid coordinates after this clock
                    
                    end else begin  // Bresenham's Line Drawing Algorithm

                        ypos_stopped   <= 1'b0  ; // let the parent module know the line generator has stopped on ypos
                        draw_line      <= 1'b1  ; // last pixel - allow time for this pixel to be written by ending on next clock
                        pixel_data_rdy <= 1'b1  ; // reset pixel_data_rdy flag - no more valid coordinates after this clock

                        if ( ( errd << 1 ) > dy ) begin

                          X_coord <= X_coord + geo_xdir    ; // add increment to X coordinate
                                     
                          if ( ( ( errd << 1 ) + dy ) < dx ) begin
                          
                             errd    <= errd + dx + dy     ; // update errd
									  Y_coord <= Y_coord + geo_ydir ; // add increment to Y coordinate
                             
                          end else errd <= errd + dy       ; // add Y increment to errd
                          
                        end else if ( ( errd << 1 ) < dx ) begin

                          errd    <= errd  + dx            ; // add X increment to errd
                          Y_coord <= Y_coord + geo_ydir    ; // add Y increment to Y coordinate
                          
                        end
                        
                     end // Bresenham's Line Drawing Algorithm
                           
                 end // geo_sub_func1 = 1 - plot line
                 
              endcase // case geo_sub_func1
        
        end // if draw_line
        else
        begin  // Clear phase counters and flags

            pixel_data_rdy <= 1'b0 ; // invalid data at X/Y_coordinate outputs
            geo_sub_func1  <= 4'b0 ; // reset the phase counter
            ypos_stopped   <= 1'b0 ; // reset ypos_stopped flag
            line_complete  <= 1'b0 ; // reset line_complete flag
            busy           <= 1'b0 ; // line generator is not busy
        
        end // else
        
    end // if !draw_busy
    
>>>>>>> e95a3e278b115b0ea9f980c63d48b6bfbcc232d1
end

endmodule
