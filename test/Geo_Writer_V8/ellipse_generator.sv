/*
 * ELLIPSE GENERATOR MODULE (ELLIE)
 *
 * v 0.2.003
 *
 */

module ellipse_generator (
// inputs
  input logic                        clk,              // 125 MHz pixel clock
  input logic                        reset,            // asynchronous reset
  input logic                        enable,           // logic enable
  input logic                        run,              // HIGH to draw / run the unit
  input logic         [1:0]          quadrant,         // specifies which quadrant of the ellipse to draw
  input logic  signed [BITS_RES-1:0] Xc,               // 12-bit X-coordinate for centre of ellipse
  input logic  signed [BITS_RES-1:0] Yc,               // 12-bit Y-coordinate for centre of ellipse
  input logic  signed [BITS_RES-1:0] Xr,               // 12-bit X-radius - Width of ellipse
  input logic  signed [BITS_RES-1:0] Yr,               // 12-bit Y-radius - height of ellipse
  input logic                        ena_pause,        // set HIGH to pause ELLIE while it is drawing
// outputs
  output logic                       busy,             // HIGH when line_generator is running
  output logic signed [BITS_RES-1:0] X_coord,          // 12-bit X-coordinate for current pixel
  output logic signed [BITS_RES-1:0] Y_coord,          // 12-bit Y-coordinate for current pixel
  output logic                       pixel_data_rdy,   // HIGH when coordinate outputs are valid
  output logic                       ellipse_complete  // HIGH when ellipse is completed
);

parameter    BITS_CORE = 24 ;
parameter    BITS_RES  = 12 ;

// internal logic
logic              draw_line      = 1'b0 ;
logic        [1:0] quadrant_latch = 2'd0 ; // This logic latches which quadrant to draw when run is issued
logic        [3:0] sub_function   = 4'd0 ; // This logic defines which step is running, IE first setup for first 45 degrees,
logic              inv            = 1'b0 ; // draw the first 45 degrees if the radius is not 0, finish the ellipse if the remaining
logic              draw_flat      = 1'b0 ; // radius<=1, setup for second 45 degrees (inv), draw the second 45 degrees if the radius
                                           // is not 0, finish the ellipse if the remaining radius<=1, end the busy and await next command
logic signed [BITS_RES-1:0]  x           ; // internal drawing x-coordinate
logic signed [BITS_RES-1:0]  y           ; // internal drawing y-coordinate
logic signed [BITS_RES-1:0]  xcr         ; // registered input x center
logic signed [BITS_RES-1:0]  ycr         ; // registered input y center
logic signed [BITS_RES-1:0]  xrr         ; // registered input x radius
logic signed [BITS_RES-1:0]  yrr         ; // registered input y radius
logic signed [BITS_CORE-1:0] p           ; // Arc error offset / sigma
logic signed [BITS_CORE-1:0] px          ; // Arc error offset / sigma
logic signed [BITS_CORE-1:0] py          ; // Arc error offset / sigma
logic signed [BITS_CORE-1:0] rx2         ; // Holds x radius ^2
logic signed [BITS_CORE-1:0] ry2         ; // Holds y radius ^2

logic signed [BITS_CORE-1:0] alu_mult_a  ; // Consolidated single multiplier A-input  for all multiplication in the generator
logic signed [BITS_CORE-1:0] alu_mult_b  ; // Consolidated single multiplier B-input  for all multiplication in the generator
logic signed [BITS_CORE-1:0] alu_mult_y  ; // Consolidated single multiplier Y-output for all multiplication in the generator

logic               pixel_data_rdy_int   ; // HIGH when coordinate outputs are valid
logic               busy_int             ; // HIGH when coordinate outputs are valid

always_comb begin

   pixel_data_rdy = pixel_data_rdy_int && !ena_pause ; // immediately clear the pixel_data_ready output when the pause is high.
   busy           = busy_int || run                  ; // immediately make busy flag high when run is asserted

end

always_ff @( posedge clk or posedge reset ) begin

   if ( reset ) begin
      // reset latches, geometry counters and flags
      draw_line          <= 1'b0 ;
      pixel_data_rdy_int <= 1'b0 ;
      busy_int           <= 1'b0 ;
      ellipse_complete   <= 1'b0 ;
      quadrant_latch     <= 2'b0 ;
      sub_function       <= 4'd0 ; // make sure the module is in idle state after reset, awaiting the 'run' command.
      x                  <= 0    ;
      y                  <= 0    ;
      xcr                <= 0    ;
      ycr                <= 0    ;
      xrr                <= 0    ;
      yrr                <= 0    ;
      p                  <= 0    ;
      rx2                <= 0    ;
      ry2                <= 0    ;
      px                 <= 0    ;
      py                 <= 0    ;
      inv                <= 1'b0 ;       
      draw_flat          <= 1'b0 ;       
   end
// ****** draw_busy_int must be LOW or ELLIE won't run   
// ****** When ready to output valid coordinates, the ena_pause is allowed to pause/stop the rendering process
   else if ( enable && !(ena_pause && pixel_data_rdy_int)  ) begin 
// ****** Consolidated single ALU multiplier with a width of BITS_CORE
// ****** ALU must freeze if enable is low.
// ****** ALU 'may' ignore ena_pause since it is not used during the rendering where it is used.
        alu_mult_y <= alu_mult_a * alu_mult_b ;
        // ****** Output the selected quadrant
        if (inv==0) begin
        case ( quadrant_latch )
            4'd0 : begin
                   X_coord    <=  xcr + x;
                   Y_coord    <=  ycr + y;
                   end
            4'd1 : begin
                   X_coord    <=  xcr - x;
                   Y_coord    <=  ycr + y;
                   end
            4'd2 : begin
                   X_coord    <=  xcr + x;
                   Y_coord    <=  ycr - y;
                   end
            4'd3 : begin
                   X_coord    <=  xcr - x;
                   Y_coord    <=  ycr - y;
                   end
            endcase
        
        end else begin
        case ( quadrant_latch )
            4'd0 : begin
                   Y_coord    <=  xcr + x;
                   X_coord    <=  ycr + y;
                   end
            4'd1 : begin
                   Y_coord    <=  xcr - x;
                   X_coord    <=  ycr + y;
                   end
            4'd2 : begin
                   Y_coord    <=  xcr + x;
                   X_coord    <=  ycr - y;
                   end
            4'd3 : begin
                   Y_coord    <=  xcr - x;
                   X_coord    <=  ycr - y;
                   end
            endcase
        end

        casez ( sub_function )
            4'd0 : begin // geo_sub_func==0 is the idle state where we wait for the 'run' to be asserted
              if ( run ) begin  // load values and begin drawing the ellipse
                 // Initialise starting coordinates and direction for immediate plotting
                 quadrant_latch <= quadrant ; // latch which of the 4 quadrants will be drawn
                 if ( ( Xr == 0 ) && ( Yr == 0 ) ) begin // Drawing only a single centre point
                    x                  <= 0    ; // initialise starting X pixel location *** Switch to X_coord <=
                    y                  <= 0    ; // initialise starting Y pixel location *** Switch to Y_coord <=
                    pixel_data_rdy_int <= 1'b0  ; // set pixel_data_rdy_int flag
                    ellipse_complete   <= 1'b0  ; // make sure ellipse_complete is set
                    sub_function       <= 4'd9  ; // Special case to pass the center coordinates
                    draw_line          <= 1'b1  ; // no line to draw
                    busy_int           <= 1'b1  ; // the line generator is busy_int from the next cycle
                    xcr       <= Xc ; // Register store all coordinate inputs
                    ycr       <= Yc ;
                    xrr       <= 0 ;
                    yrr       <= 0 ;
                    inv       <= 1'b0 ;
                    draw_flat <= 1'b0 ;
                 end
                 else begin //  Draw a full ellipse
                    // Set latched registers, phase counters and flags
                    sub_function       <= sub_function + 1'd1  ; // After completing this setup, advance the sub_funcion to the next step
                    draw_line          <= 1'b1  ; // start drawing the line on the next clock cycle
                    busy_int           <= 1'b1  ; // the line generator is busy_int  from the next cycle
                    pixel_data_rdy_int <= 1'b0  ; // no valid coordinates next clock cycle
                    ellipse_complete   <= 1'b0  ; // reset ellipse_complete flag
                    xcr       <= Xc ; // Register store all coordinate inputs
                    ycr       <= Yc ;
                    xrr       <= Xr ;
                    yrr       <= Yr ;
                    inv       <= 1'b0 ;
                    draw_flat <= 1'b0 ;
                 end // if !draw a single point 
              end // if run
            end // geo_sub_func==0 is the idle state where we wait for the 'run' to be asserted

            4'd1 : begin // Step 1, setup consolidated multiplier to compute Rx^2
                alu_mult_a         <= xrr  ;
                alu_mult_b         <= xrr  ;
                x                  <= 0    ;
                px                 <= 0    ;
                y                  <= yrr  ;
                draw_flat          <= 1'b0 ;
                sub_function       <= sub_function + 1'd1 ; // there is an arc to render
            end

            4'd2 : begin //  Step 2, setup consolidated multiplier to compute Ry^2
                alu_mult_a         <= yrr  ;
                alu_mult_b         <= yrr  ;
                sub_function       <= sub_function + 1'd1 ; // advance the sub_funcion to the next step
            end
            
            4'd3 : begin // Step 3, store computed Rx^2
                rx2                <= alu_mult_y ; // The ALU has a 2 clock delay, 1 clock to send data in, 1 clock for the result to become valid
                // Prepare py = rx2 * y * 2 & make y=ry
                alu_mult_a         <= alu_mult_y ; // Remember, rx2 isn't se until the next clock
                alu_mult_b         <= yrr;
                // Begin the initial preparation of 'p' -> p = ( 0.25 * Rx2) + 0.5 
                p                  <= (alu_mult_y + 2) >> 2 ; // Computes rx2/4 with rounding
                sub_function       <= sub_function + 1'd1   ; // advance the sub_funcion to the next step
            end
            
            4'd4 : begin // Step 4, store computed Ry^2
                ry2                <= alu_mult_y           ; // The ALU has a 2 clock delay, 1 clock to send data in, 1 clock for the result to become valid
                // Setup alu for rx2*ry
                alu_mult_a         <= rx2                  ;
                alu_mult_b         <= yrr                  ;
                sub_function       <= sub_function + 1'd1  ; // advance the sub_funcion to the next step
            end
            
            4'd5 : begin // Step 5, store computed rx2*y (multiplied by 2)
                py                 <= (alu_mult_y) << 1    ; // The ALU has a 2 clock delay, 1 clock to send data in, 1 clock for the result to become valid
                sub_function       <= sub_function + 1'd1  ; // advance the sub_funcion to the next step
            end
            
            4'd6 : begin // Step 6, p=p+ry2 - (rx2*ry)
                p <= p + ry2 - alu_mult_y ; // The ALU has a 2 clock delay, 1 clock to send data in, 1 clock for the result to become valid
                if (xrr<2) sub_function <= sub_function + 2'd2  ; // no radius, skip arc and go straight to finish straight line
                else       sub_function <= sub_function + 1'd1  ; // some radius, draw arc 
            end
                        
            4'd7 : begin // Step 7 - draw ellipse
                if (px <= py) begin  // drawing the line  ***** Warning, was originally LESS THAN EQUAL TO <=, but this rendered an extra pixel.
                    pixel_data_rdy_int <= 1'b1          ; // pixel data ready
                    x                  <= x + 1'd1      ;
                    px                 <= px + (ry2<<1) ;
                    if (p <= 0) begin
                        p  <= p + ry2 + (px + (ry2<<1)) ;
                    end else begin
                        y  <= y - 1'd1;
                        py <= py - (rx2<<1);
                        p  <= p + ry2 + (px + (ry2<<1)) - (py - (rx2<<1)) ;
                    end
                end else begin // end of line has been reached
                    pixel_data_rdy_int <= 1'b0                ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock
                    sub_function       <= sub_function + 1'd1 ; // next function.
                end
            end // step 7 - draw ellipse

            4'd8 : begin // Step 8 - draw remaining flat edge of ellipse
                if (((y<2) || draw_flat) && x <= xrr ) begin // If any line remains to be drawn
                    draw_flat <= 1'b1                  ; // stay in loop until x <= x-radius
                    y         <= 0                     ; // clear the y axis
                    if (draw_flat) begin                 // must wait for y to clear to 0 before drawing the flat portion of the ellipse
                        pixel_data_rdy_int <= 1'b1     ; // pixel data ready
                        x                  <= x + 1'd1 ; // increment x coordinates
                    end
                end else begin
                    if (inv) begin
                        pixel_data_rdy_int <= 1'b0  ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock
                        sub_function       <= 4'd0  ; // reset to idle state
                        inv                <= 1'b0  ; // clear the inv
                        draw_line          <= 1'b0  ; // last pixel - allow time for this pixel to be written by ending on next clock
                        ellipse_complete   <= 1'b1  ;
                        busy_int           <= 1'b0  ; // line generator is no longer busy_int 
                    end else begin
                        pixel_data_rdy_int <= 1'b0  ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock
                        sub_function       <= 4'd1  ; // restart the rendering portion of the program
                        inv                <= 1'b1  ; // with the inv set
                        xcr                <= ycr   ; // swap the X/Y center coordinates
                        ycr                <= xcr   ;
                        xrr                <= yrr   ; // swap the X/Y radius
                        yrr                <= xrr   ;
                    end
                end // No flat ellipse to draw.
            end // step 8 - draw remaining flat edge of ellipse

            4'd9 : begin // Step 9 - ellipse radius of 0, pass through center coordinate data and complete the ellipse
                pixel_data_rdy_int <= 1'b1                 ; // set center coordinates ready
                sub_function       <= sub_function + 1'd1  ; // go to default state
            end

            default : begin                  // we are in an undefines function state,
                sub_function       <= 4'd0 ; // so, reset the function state to 0
                draw_line          <= 1'b0 ; // and make sure we diable the draw_line flag
                pixel_data_rdy_int <= 1'b0 ; // reset pixel_data_rdy_int flag - no more valid coordinates after this clock
                sub_function       <= 4'd0 ; // reset the phase counter
                ellipse_complete   <= 1'b1 ;
                busy_int           <= 1'b0 ; // line generator is no longer busy_int 
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
