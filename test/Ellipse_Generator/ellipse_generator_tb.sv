/*
 * RTL Test Bench ELLIPSE GENERATOR MODULE (ELLIE)
 *
 * v 0.5.001   Jan 13, 2021
 * Now with horizontal fill comand.
 * FMAX = 125.9 MHz compiled balanced optimized with 35 bit integer core.
 *
 * To setup simulation,Start Modelsim, The goto 'File - Change Directory' and select this files directory. 
 * Then, for altera users, in the transcript, type:
 * do setup_altera.do
 *
 * For non-altera users, just type:
 * do setup.do
 *
 * To run the simulation, (also does a quick recompile) type:
 * do run.do
 *
 * The text file 'ellipse_commands_in.txt' contains the simulation drawing coordinates.
 * The format is as follows:
 * @ Filled <0,1>, Quadrant<0,1,2,3>, Xcenter<signed#>, Ycenter<signed#>, Xradius<unsigned#>, Yradius<unsigned#>, Color<ubyte>
 * Read the file for instructions.
 *
 * The testbench will run as many commands you list in in the .txt file.
 * After simulation, all the generated ellipse's coordinates will be stored in:
 * ellipse_generated_results.txt
 *
 * as well as full logic waveform in the wave display.
 *
 * *** BONUS *** An output 1024x1024 bitmap picture will also be generated called:
 * ellipse_generated_bitmap.bmp
 *
 */

`timescale 1 ns/ 1 ns // 1 ns steps, 1 ns precision.

module ellipse_generator_tb 
#(
parameter int BITS_RES = 12
)();

// ellipse command logic
logic                        clk,reset,enable,run,ena_pause,ellipse_filled;
logic        [1:0]           quadrant;
logic signed [BITS_RES-1:0]  Xc,Yc,Xr,Yr;
// ellipse output
logic signed [BITS_RES-1:0]  X_coord, Y_coord;
logic                        busy,pixel_data_rdy,ellipse_complete;

localparam real CLK_MHz  = 100.000 ;
localparam real STOP_uS  = 1 ;

localparam period  = 500/CLK_MHz ;    // Calculate the clk toggle rate.
localparam endtime = STOP_uS * 1000;

ellipse_generator #(.BITS_RES(BITS_RES)) DUT(
// inputs
  .clk( clk ),                           // 125 MHz pixel clock
  .reset( reset ),                       // asynchronous reset
  .enable( enable ),                     // logic enable
  .run( run ),                           // HIGH to draw / run the unit
  .quadrant( quadrant ),                 // specifies which quadrant of the ellipse to draw
  .ellipse_filled( ellipse_filled ),     // X-filling when drawing an ellipse.
  .Xc( Xc ),                             // 12-bit X-coordinate for centre of ellipse
  .Yc( Yc ),                             // 12-bit Y-coordinate for centre of ellipse
  .Xr( Xr ),                             // 12-bit X-radius - Width of ellipse
  .Yr( Yr ),                             // 12-bit Y-radius - height of ellipse
  .ena_pause( ena_pause ),               // set HIGH to pause ELLIE while it is drawing
// outputs
  .busy( busy ),                         // HIGH when line_generator is running
  .X_coord( X_coord ),                   // 12-bit X-coordinate for current pixel
  .Y_coord( Y_coord ),                   // 12-bit Y-coordinate for current pixel
  .pixel_data_rdy( pixel_data_rdy ),     // HIGH when coordinate outputs are valid
  .ellipse_complete( ellipse_complete )  // HIGH when ellipse is completed
);

integer fin_pointer,fout_pointer,fin_running;
logic   [7:0] char        = 8'd0;
logic   [7:0] draw_color  = 8'd0;
logic   [3:0] running = 4'b1111; // Wait for 4 clocks or inactivity before forcing a simulation stop.
logic   [7:0] bitmap [0:(1024*1024-1)] ;

// 256 color 8 bit header for an uncompressed .bmp file.
localparam  bmp_header_size = 54;
logic [7:0] bmp_header [0:(bmp_header_size-1)] = '{
8'h42, 8'h4D, 8'h36, 8'h04,   8'h10, 8'h00, 8'h00, 8'h00,   8'h00, 8'h00, 8'h36, 8'h04,   8'h00, 8'h00, 8'h28, 8'h00,
8'h00, 8'h00, 8'h00, 8'h04,   8'h00, 8'h00, 8'h00, 8'h04,   8'h00, 8'h00, 8'h01, 8'h00,   8'h08, 8'h00, 8'h00, 8'h00,
8'h00, 8'h00, 8'h00, 8'h00,   8'h10, 8'h00, 8'h13, 8'h0B,   8'h00, 8'h00, 8'h13, 8'h0B,   8'h00, 8'h00, 8'h00, 8'h01,
8'h00, 8'h00, 8'h00, 8'h01,   8'h00, 8'h00 };

task render_ellipse_commands;
 begin

for (int i = 0 ; i < (1024*1024) ; i++)  bitmap[i] = 8'h00 ;

    fin_pointer= $fopen("ellipse_commands_in.txt", "r");
    if (fin_pointer==0)
    begin
       $display("Could not open file '%s' for reading","ellipse_commands_in.txt");
       $stop;     
    end
    fout_pointer= $fopen("ellipse_generated_results.txt","w");
    if (fout_pointer==0)
    begin
       $display("Could not open file '%s'  for writing","ellipse_generated_results.txt");
       $stop;     
    end

    while ((! $feof(fin_pointer)) || fin_running ) begin
 @(negedge clk) begin

      if (!busy && !reset) begin
            char = 0;
            while (char != "@") begin // scan for the @ character.
            char = $fgetc(fin_pointer);
            if (char==0) $stop; // something went wrong
            end
            if (char== "@") fin_running = 1;

            #(period*2);
            $fscanf(fin_pointer,"%b,%d,%d,%d,%d,%d,%d\n",ellipse_filled,quadrant,Xc,Yc,Xr,Yr,draw_color);
            $fwrite(fout_pointer,"\n Gen Ellipse > fill=%b, Quad=%d, At (%d,%d), Radius (%d,%d), Color=%d <<<\n",ellipse_filled,quadrant,Xc,Yc,Xr,Yr,draw_color);
            run = 1'b1;
            #(period*2);
      end else begin 
      run = 1'b0;

      if (pixel_data_rdy && !reset) begin
                                    $fwrite(fout_pointer,"%d,%d\n",X_coord,Y_coord);
                                    if (X_coord>=0 && Y_coord>=0 && X_coord<1024 && Y_coord<1024) bitmap[(1023-Y_coord)*1024+X_coord] = draw_color;
                                    end
      #(period*2);
      if (!busy) fin_running = 0;
    end
  end
end
    run = 1'b0;
    $fwrite(fout_pointer,"\nFinished.\n");
    $fclose(fin_pointer);
    $fclose(fout_pointer);

    fout_pointer= $fopen("ellipse_generated_bitmap.bmp","w");
    if (fout_pointer==0)
    begin
       $display("Could not open file '%s'  for writing","ellipse_generated_bitmap.bmp");
       $stop;     
    end
    $display(" *************************************************************** ");
    $display(" ****** Saving bitmap 'ellipse_generated_bitmap.bmp'. ********** ");
    $display(" *************************************************************** ");


    //  Save 256 color, .bmp header.
    for (int i=0;i<(bmp_header_size);i++)  $fwrite(fout_pointer,"%c",bmp_header[i]) ; // ******** Remember, we cannot output character 8'h0A

    //  Save 256 color .bmp palette
    // This makes the palette go from color 0=black to 255=100% white.
    for (int i=0 ; i<256 ; i++)           begin
                                          char = 8'({i[3:0],i[3:0]});
                                          if (char==8'h0A)       $fwrite(fout_pointer,"%c",8'(8'h0B)) ; // blue palette
                                          else                   $fwrite(fout_pointer,"%c",8'(char)) ;
                                          char = 8'({i[5:2],i[5:2]});
                                          if (char==8'h0A)       $fwrite(fout_pointer,"%c",8'(8'h0B)) ; // green palette
                                          else                   $fwrite(fout_pointer,"%c",8'(char)) ;
                                          char = 8'({i[7:4],i[7:4]});
                                          if (char==8'h0A)       $fwrite(fout_pointer,"%c",8'(8'h0B)) ; // red palette
                                          else                   $fwrite(fout_pointer,"%c",8'(char)) ;
                                                                 $fwrite(fout_pointer,"%c",8'd0)  ;
                                          end

    //  Save 1024x1024 .bmp image.
    for (int i=0;i<(1024*1024);i++)       begin
                                          if      (bitmap[i]==8'h00)  $fwrite(fout_pointer,"%c",8'(8'h01)) ;  // Printing character 8'h00 runs 10x slower.  It's probably wasn't supposed to work in the first place
                                          else if (bitmap[i]==8'h0A)  $fwrite(fout_pointer,"%c",8'(8'h0B)) ;  // Also, printing 8'h0A inserta an additional 8'h0D in front.
                                          else                        $fwrite(fout_pointer,"%c",bitmap[i]) ;  // 
                                          end
    $fclose(fout_pointer);

    $stop;
end

endtask

initial 
begin 
clk            = 1'b1;
reset          = 1'b1; // apply reset
enable         = 1'b1;
run            = 1'b0;
ena_pause      = 1'b0;
running        = 4'b1111; // Wait for 4 clocks of inactivity before forcing a simulation stop.

ellipse_filled = 1'b0;
quadrant       = 2'b00;
Xc             = (BITS_RES)'(0);
Yc             = (BITS_RES)'(0);
Xr             = (BITS_RES)'(0);
Yr             = (BITS_RES)'(0);

#(period*4);
reset = 1'b0; // clear reset
#(period*1);

render_ellipse_commands();

end 

// clk
always #period clk = !clk;
always @(posedge clk) running = {running[2:0],(run || ena_pause || busy)};
always #(period*2) if (!run && running==0) $stop;   // Automatically end the simulation once the end has been reached

endmodule
