/*
 * ELLIPSE ENGINE (ELLIE)
 *
 * v 0.1.003
 *
 */

module ellipse_generator (
// inputs
  input logic                clk,              // 125 MHz pixel clock
  input logic                reset,            // asynchronous reset
  input logic                enable,           // logic enable
  input logic                run,              // HIGH to draw / run the unit
  input logic         [1:0]  quadrant,         // specifies which quadrant of the ellipse to draw
  input logic  signed [11:0] Xc,               // 12-bit X-coordinate for centre of ellipse
  input logic  signed [11:0] Yc,               // 12-bit Y-coordinate for centre of ellipse
  input logic  signed [11:0] A,                // 12-bit X-radius - Width of ellipse
  input logic  signed [11:0] B,                // 12-bit Y-radius - height of ellipse
  input logic                ena_pause,        // set HIGH to pause ELLIE while it is drawing
// outputs
  output logic               busy,             // HIGH when line_generator is running
  output logic signed [11:0] X_coord,          // 12-bit X-coordinate for current pixel
  output logic signed [11:0] Y_coord,          // 12-bit Y-coordinate for current pixel
  output logic               pixel_data_rdy,   // HIGH when coordinate outputs are valid
  output logic               ellipse_complete  // HIGH when ellipse is completed
);

// internal logic
logic               draw_line      = 1'b0 ;
logic        [1:0]  quadrant_latch = 2'b0 ;    // This logic latches which quadrant to draw when run is issued
logic        [2:0]  sub_function   = 3'd0 ;    // This logic defines which step is running, IE first setup for first 45 degrees,
                                               // draw the first 45 degrees if the radius is not 0, finish the ellipse if the remaining
                                               // radius<=1, setup for second 45 degrees (inv), draw the second 45 degrees if the radius
                                               // is not 0, finish the ellipse if the remaining radius<=1, end the busy and await next command
logic signed [11:0] x                     ;    // internal drawing x-coordinate
logic signed [11:0] y                     ;    // internal drawing y-coordinate
logic signed [11:0] af                    ;
logic signed [11:0] bf                    ;
logic signed [23:0] a2                    ;    // Note that the 4* fa2 & fb2 aren't needed as they will just be a logic shift inside the code
logic signed [23:0] b2                    ;
logic signed [23:0] comp_a2y              ;    // This limits the compare size for the while loop
logic signed [23:0] comp_b2x              ;
logic signed [23:0] sigma                 ;

logic signed [23:0] sigma_add_a           ;
logic signed [23:0] sigma_add_areg        ;
logic signed [23:0] sigma_add_b           ;
logic signed [23:0] sigma_add_breg        ;

logic               pixel_data_rdy_int    ;    // HIGH when coordinate outputs are valid
logic               busy_int              ;    // HIGH when coordinate outputs are valid

always_comb begin
    
    pixel_data_rdy = pixel_data_rdy_int && !ena_pause ; // immediately clear the pixel_data_ready output when the pause is high.
    busy           = busy_int || run                  ; // immediately make busy flag high when run is asserted
    
    // Temporary output of internal X/Y variables
    X_coord        = x                                ;
    Y_coord        = y                                ;
    
    //sigma_add_a       = b2 * (((x+1'd1) << 2 ) + 3'd6 ) ;
    sigma_add_a    = b2 * ((x << 2 ) + 4'd10 )        ;
    
end

always_ff @( posedge clk or posedge reset ) begin
    
    if ( reset ) begin
        
        // reset latches, geometry counters and flags
        draw_line          <= 1'b0  ;
        pixel_data_rdy_int <= 1'b0  ;
        busy_int           <= 1'b0  ;
        ellipse_complete   <= 1'b0  ;
        quadrant_latch     <= 2'b0  ;
        sub_function       <= 3'd0  ; // make sure the module is in idle state after reset, awaiting the 'run' command.
        x                  <= 12'b0 ;
        y                  <= 12'b0 ;
        af                 <= 12'b0 ;
        bf                 <= 12'b0 ;
        a2                 <= 24'b0 ;
        b2                 <= 24'b0 ;
        sigma              <= 24'b0 ;
        
    end
    else if ( enable ) begin // draw_busy_int must be LOW or ELLIE won't run
        
        casez ( sub_function )
            
            3'd0 : begin // geo_sub_func==0 is the idle state where we wait for the 'run' to be asserted
                
                if ( run ) begin  // load values and begin drawing the ellipse
                    
                    // Initialise starting coordinates and direction for immediate plotting
                    quadrant_latch <= quadrant ; // latch which of the 4 quadrants will be drawn
                    
                    if ( ( A == 12'b0 ) && ( B == 12'b0 ) ) begin // Drawing only a single centre point
                        
                        x                  <= Xc    ; // initialise starting X pixel location *** Switch to X_coord <=
                        y                  <= Yc    ; // initialise starting Y pixel location *** Switch to Y_coord <=
                        af                 <= 12'b0 ;
                        bf                 <= 12'b0 ;
                        pixel_data_rdy_int <= 1'b1  ; // set pixel_data_rdy_int flag
                        ellipse_complete   <= 1'b1  ; // make sure ellipse_complete is set
                        sub_function       <= 3'd0  ; // reset the phase counter
                        draw_line          <= 1'b0  ; // no line to draw
                        busy_int           <= 1'b0  ; // the line generator is busy_int from the next cycle
                        
                    end
                    else begin //  Draw a full ellipse
                        
                        // Set latched registers, phase counters and flags
                        sub_function       <= sub_function + 1'd1  ; // After completing this setup, advance the sub_funcion to the next step
                        draw_line          <= 1'b1  ; // start drawing the line on the next clock cycle
                        busy_int           <= 1'b1  ; // the line generator is busy_int  from the next cycle
                        pixel_data_rdy_int <= 1'b0  ; // no valid coordinates next clock cycle
                        ellipse_complete   <= 1'b0  ; // reset ellipse_complete flag
                        x                  <= 12'b0 ;
                        
                        af <= A   ;
                        bf <= B   ;
                        a2 <= A*A ;
                        b2 <= B*B ;
                        y  <= B   ;
                        
                    end // if !draw a single point 
                    
                end // if run
                
            end // // geo_sub_func==0 is the idle state where we wait for the 'run' to be asserted
            
            3'd1 : begin // sub_function 1
                
                sigma_add_breg <= (b2 << 1)                 ; //
                sigma_add_areg <= a2 * ( 24'd1 - (y << 1) ) ; // 
                
                sub_function   <= sub_function + 1'd1       ; // advance the sub_function to the next step
                
            end
            
            3'd2 : begin //  sub_function 2
                
                //sigma              <= (b2 << 1) + a2 * ( 24'd1 - (y << 1) ) ; // Force 24 bit for the 1 - #
                sigma              <= sigma + sigma_add_areg + sigma_add_breg ; // Force 24 bit for the 1 - #
                
                pixel_data_rdy_int <= 1'b1                 ; // pixel output starts on next clock
                sub_function       <= sub_function + 1'd1  ; // advance the sub_function to the next step
                
                sigma_add_areg     <= sigma_add_a          ; // b2 * ((x << 2 ) + 4'd10 ) ;
                sigma_add_breg     <= a2 << 2)             ; // default starting offset
                
                comp_b2x           <= b2 * (x + 1'd1)      ;
                comp_a2y           <= a2 * y               ;
                
            end
            
            3'd3 : begin // draw ellipse
                
                if ( comp_b2x < comp_a2y ) begin  // drawing the line  ***** Warning, was originally LESS THAN EQUAL TO <=, but this rendered an extra pixel.
                //if (   x <   y ) begin  // Cheap FMAX check.
                    
                    if ( sigma >= 0 ) begin
                        
                        //sigma          <= sigma + (b2 * (( x << 2 ) + 3'd6 )) + ((a2 << 2) * ( 24'd1 - y )) ; // Force 24 bit for the 1 - #
                        sigma    <= sigma + sigma_add_areg + sigma_add_breg ; // Force 24 bit for the 1 - #
                        y        <= y - 1'd1        ;
                        comp_a2y <= a2 * (y - 1'd1) ;
                        
                    end else begin
                        
                        //sigma          <= sigma + (b2 * (( x << 2 ) + 3'd6 )) ;
                        sigma    <= sigma + sigma_add_areg ;
                        comp_a2y <= a2 * y                 ;
                        
                    end
                    x              <= x + 1'd1                   ;
                    comp_b2x       <= b2 * (x + 1'd1)            ;
                    sigma_add_areg <= sigma_add_a                ; //b2 * (((x+1'd1) << 2 ) + 3'd6 ) ; // Placed at the if (enable) since this function will always run
                    sigma_add_breg <= ((a2 << 2) * ( 1'd1 - y )) ; //b2 * ((x << 2 ) + 4'd10 ) ; // Placed at the if (enable) since this function will always run
                    
                end else begin // end of line has been reached
                    
                    draw_line          <= 1'b0  ; // last pixel - allow time for this pixel to be written by ending on next clock
                    pixel_data_rdy_int <= 1'b0  ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock
                    sub_function       <= 3'b0  ; // reset the phase counter
                    ellipse_complete   <= 1'b1  ;
                    busy_int           <= 1'b0  ; // line generator is no longer busy_int 
                    
                end
                
            end // geo_sub_func1 = 2 - draw ellipse
            
            default : begin // we are in an undefined function state
                
                sub_function <= 3'd0 ;  // so, reset the function state to 0
                draw_line    <= 1'b0 ;  // and make sure we disable the draw_line flag
                
            end
            
        endcase // case sub_function
        
        if (!draw_line && !run ) begin
            
            pixel_data_rdy_int <= 1'b0 ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock //
            ellipse_complete   <= 1'b0 ; // make sure ellipse_complete is a single 1 shot clock cycle.
            busy_int           <= 1'b0 ; // the line generator is busy_int  from the next cycle   
                 
        end
        
    end // if enable
    
end

endmodule
