/*
 * RTL Test Bench ELLIPSE GENERATOR MODULE (ELLIE)
 *
 * Features control from a source ascii text file script,
 * and a 256 color .BMP picture file generator.
 * Tested on free Altera ModelSim 10 & 20.  However, it does not contain 
 * any Altera specific code.  It should work on other SystemVerilog simulators.
 *
 * Written by Brian Guralnick.
 *
 * v 0.6.001   Jan 27, 2021
 *
 * To setup simulation, Start Modelsim, The goto 'File - Change Directory' and select this files directory. 
 * Then in the transcript, type:
 * do setup.do
 *
 * To run the simulation, (also does a quick recompile) type:
 * do run.do
 *
 * The text file 'ellipse_commands_in.txt' contains the commands with simulation drawing coordinates.
 * Read the file for instructions.
 *
 * The testbench will run as many commands you list in in the .txt file.
 * After simulation, all the generated ellipse's coordinates will be stored in the log file:
 * ellipse_generated_results.txt
 *
 * as well as full logic waveform in the wave display.
 *
 * An output 1024x1024 bitmap picture will also be generated called:
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

localparam CLK_MHz  = 100 ;
localparam STOP_uS  = 1 ;

localparam period  = 500/CLK_MHz ;    // Calculate the clk toggle rate.
localparam endtime = STOP_uS * 1000;

ellipse_generator #(.BITS_RES(BITS_RES)) DUT(

// inputs
  .clk              ( clk             ),   // 125 MHz pixel clock
  .reset            ( reset           ),   // asynchronous reset
  .enable           ( enable          ),   // global logic / clock enable
  .run              ( run             ),   // HIGH to draw / run the unit
  .quadrant         ( quadrant        ),   // specifies which quadrant of the ellipse to draw
  .ellipse_filled   ( ellipse_filled  ),   // X-filling when drawing an ellipse.
  .Xc               ( Xc              ),   // 12-bit X-coordinate for centre of ellipse
  .Yc               ( Yc              ),   // 12-bit Y-coordinate for centre of ellipse
  .Xr               ( Xr              ),   // 12-bit X-radius - Width of ellipse
  .Yr               ( Yr              ),   // 12-bit Y-radius - height of ellipse
  .ena_pause        ( ena_pause       ),   // set HIGH to pause the ellipse generator while it is drawing

// outputs
  .busy             ( busy             ),  // HIGH when line_generator is running
  .X_coord          ( X_coord          ),  // 12-bit X-coordinate for current pixel
  .Y_coord          ( Y_coord          ),  // 12-bit Y-coordinate for current pixel
  .pixel_data_rdy   ( pixel_data_rdy   ),  // HIGH when coordinate outputs are valid
  .ellipse_complete ( ellipse_complete )   // HIGH when ellipse is completed
);

// ***********************************************************************************************************
// ***********************************************************************************************************
// Setup global bitmap size and logic memory array.
//
localparam BMP_WIDTH  = 1024;
localparam BMP_HEIGHT = 1024;
localparam bit BW_BMP = 0;     // set to 1 for 256 shades of grey BMP.
logic [7:0] bitmap [0:BMP_WIDTH-1][0:BMP_HEIGHT-1];
//
// ***********************************************************************************************************
// ***********************************************************************************************************

logic   [3:0] running = 4'd15; // Wait for 4 clocks or inactivity before forcing a simulation stop.

initial 
begin 
clk            = 1'b1;
reset          = 1'b1;  // apply reset
enable         = 1'b1;
run            = 1'b0;
ena_pause      = 1'b0;
running        = 4'd15; // Set the initial incativity timer to maximum so that the code lateron wont immideately stop the simulation.

ellipse_filled = 1'b0;
quadrant       = 2'b00;
Xc             = (BITS_RES)'(0);
Yc             = (BITS_RES)'(0);
Xr             = (BITS_RES)'(0);
Yr             = (BITS_RES)'(0);

#(period*2);
reset = 1'b0; // clear reset
#(period*2);

execute_ascii_file("ellipse_commands_in.txt");

end 

// Always cycle clk logic at the period speed.
always #period clk = !clk;

// Create a watchdog inactivity countdown timer called running.
// When logic is busy or set to run, reset the timer to 16, otherwise
// decrement every clk cycle.
always @(posedge clk) running = (busy || run) ? 4'd15 : (running-1'b1) ; // Setup a simulation inactivity watchdog countdown timer.
always @(posedge clk) if (running==4'd0) $stop;                          // Automatically stop the simulation if the inactivity timer reaches 0.


// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
//
// End of testbench.
//
// Next, 'task' programs:
//
// save_bmp_256( "bmp_file_name.bmp" , <bw_nocolor> );      // saves a 256 color BMP picture.
// execute_ascii_file("<source file name">);                // Executes the command ascii file, decodes the '@' command string
//
// draw_ellipse(*src, *dest, fill, first quad, end quad);     // reads source file for coordinates, then runs the ellipse generator
// clear_bitmap(integer xs, integer ys, byte unsigned color); // clears the logic array bitmap to byte 'color'
// task send_rst();                                           // pulses the reset line.
//
// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************





// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
// Simple 256 color BMP save algorythm.
// To call task:
//
// save_bmp_256( "bmp_file_name.bmp" , <bw_nocolor> );
//
// If (bw_nocolor=1), the result bitmap will be 256 shades of grey from 0=black to 255=white.
// If (bw_nocolor=0), the result bitmap will have a dummy color palette.
//
// Parameter BMP_WIDTH must be a multiple of 4 and it is used to desing the bitmap width.
// Parameter BMP_HEIGHT defines the height of the bitmap.
// 
// logic array 'bitmap' must be declared at the top of the testbench module like this:
// logic   [7:0] bitmap [0:BMP_WIDTH-1][0:BMP_HEIGHT-1];
//
// When rendering into the array 'bitmap', it is recomended you use range checks such as:
//
// if (X_coord>=0 && Y_coord>=0 && X_coord<BMP_WIDTH && Y_coord<BMP_HEIGHT) bitmap[X_coord][Y_coord] = draw_color;
// 
// ***********************************************************************************************************
//  BMP Header
// 16 bit string "BM", first 2 bytes in file, but ignored everywhere else...
// 32 bit, offset 0002, Full size of BMP file in bytes. = 54(header not including 'BM') + 1024(palette) + (BMP_WIDTH(word padded)*BMP_HEIGHT)
// 32 bit, offset 0006, Dummy 32'h0000
// 32 bit, offset 000A, First byte of where the the bitmap data begins. - 1078 = 54(header)+1024(palette)
// 32 bit, offset 000E, Size of header in bytes.   Must be 40
// 32 bit, offset 0012, BMP_WIDTH
// 32 bit, offset 0016, BMP_HEIGHT
// 16 bit, offset 001A, Number of color planes. Must be     1
// 16 bit, offset 001C, Color depth. Must be 1,4,8,16,24,32 8 = 8 bit per pixel
// 32 bit, offset 001E, Compression method used.            0 = none.
// 32 bit, offset 0022, Image size in bytes.                  = BMP_row_size*BMP_HEIGHT   (Remember 4 byte per line padding) 
// 32 bit, offset 0026, Horizontal res, pixel/meter,     2835 = 72 pixels per inch
// 32 bit, offset 002A, Vertical   res, pixel/meter,     2835 = 72 pixels per inch
// 32 bit, offset 002E, Number of colors in palette.     256.
// 32 bit, offset 0032, Number of important colors used. 256.
// ***********************************************************************************************************
// ***********************************************************************************************************

task save_bmp_256(string bmp_file_name,bit bw_nocolor);
begin

    integer unsigned        fout_bmp_pointer, BMP_file_size,BMP_row_size,r;
    logic   unsigned [31:0] BMP_header[0:12];

                              BMP_row_size  = 32'(BMP_WIDTH) & 32'hFFFC; // When saving a bitmap, the row size/width must be
if ((BMP_WIDTH & 32'd3) !=0)  BMP_row_size  = BMP_row_size + 4;           // padded to chunks of 4 bytes.

    fout_bmp_pointer= $fopen(bmp_file_name,"wb");
    if (fout_bmp_pointer==0)
    begin
       $display("Could not open file '%s' for writing",bmp_file_name);
       $stop;     
    end
    $display(" *************************************************************** ");
    $display(" ****** Saving bitmap '%s'. ********** ",bmp_file_name);
    $display(" *************************************************************** ");


BMP_file_size    = (54+1024+(BMP_row_size*BMP_HEIGHT));

BMP_header[0:12] = '{BMP_file_size,0,1078,40,BMP_WIDTH,BMP_HEIGHT,{16'd8,16'd1},0,(BMP_row_size*BMP_HEIGHT),2835,2835,256,256};

$fwrite(fout_bmp_pointer,"BM%u",BMP_header);


    //  Save 256 color .bmp palette
    if (!bw_nocolor) for (int i=0 ; i<256 ; i++)  $fwrite(fout_bmp_pointer,"%c%c%c%c",8'({i[3:0],i[3:0]}),8'({i[5:2],i[5:2]}),8'({i[7:4],i[7:4]}),8'h00);// Generate a dummy colorized palette
    // This makes the palette go from color 0=black to 255=100% white.
    else             for (int i=0 ; i<256 ; i++)  $fwrite(fout_bmp_pointer,"%u",({8'h00,8'(i),8'(i),8'(i)})); // Generate a monochrome 256 shade grey palette

    //  Save BMP_WIDTHxBMP_HEIGHT .bmp image.
    for (int y=BMP_HEIGHT-1;y>=0;y--) begin
                                      for (int x=0;x<BMP_WIDTH;x+=4)    $fwrite(fout_bmp_pointer,"%u",{bitmap[x+3][y],bitmap[x+2][y],bitmap[x+1][y],bitmap[x][y]}) ;
                                      end

//    r = 0;  // this alternate routine saves a second when saving a 1024x1024 image
//               if it werent for writing character string '0' $fwrite(fout_bmp_pointer,"%c",bitmap[x][y]) runs 20 times faster, otherwise it is 4 times slower than %u if you have a ton of character 0's to write.
//    for (int y=BMP_HEIGHT-1;y>=0;y--) begin
//                                      for (int x=0;x<BMP_WIDTH;x+=4)   output_bitmap[r++] = {bitmap[x+3][y],bitmap[x+2][y],bitmap[x+1][y],bitmap[x][y]} ;
//                                      end
//    $fwrite(fout_bmp_pointer,"%u",output_bitmap);

    $fclose(fout_bmp_pointer);
end

endtask


// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
// task execute_ascii_file(<"source ascii file name">);
// 
// Opens the ascii file and scans for the '@' symbol.
// After each '@' symbol, a string is read as a command function.
// Each function then goes through a 'case(command_in)' which then executes the appropriate function.
//
// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************

task execute_ascii_file(string source_file_name);
 begin
    integer fin_pointer,fout_pointer,fin_running,r;
    string  command_in,message_string,destination_file_name,bmp_file_name;

    byte    unsigned    char        ;
    byte    unsigned    draw_color  ;
    integer unsigned    line_number ;

    line_number  = 1;
    fout_pointer = 0;

    fin_pointer= $fopen(source_file_name, "r");
    if (fin_pointer==0)
    begin
       $display("Could not open file '%s' for reading",source_file_name);
       $stop;     
    end

while (fin_pointer!=0 && ! $feof(fin_pointer)) begin // Continue processing until the end of the source file.

  char = 0;
  while (char != "@" && ! $feof(fin_pointer) && fin_pointer!=0 ) begin // scan for the @ character until end of source file.
  char = $fgetc(fin_pointer);
  if (char==0 || fin_pointer==0 )  $stop;                               // something went wrong
  if (char==10) line_number = line_number + 1;       // increment the internal source file line counter.
  end


if (! $feof(fin_pointer) ) begin  // if not end of source file retrieve command string

  r = $fscanf(fin_pointer,"%s",command_in); // Read in the command string after the @ character.
  if (fout_pointer!=0) $fwrite(fout_pointer,"Line#%d, ",13'(line_number)); // :pg the executed command line number.

  case (command_in) // select command string.

  "DRAW_ELLI"     : draw_ellipse(fin_pointer,fout_pointer);     // draws all quadrants of an ellipse, not filled.

  "RESET"      : begin
                 send_rst();                                          // pulses the reset signal for 1 clock.
                 if (fout_pointer!=0) $fwrite(fout_pointer,"Sending a reset to the ellipse module.\n");
                 end

  "CLR_BMP"    : begin
                 r = $fscanf(fin_pointer,"%d",draw_color);
                 clear_bitmap(BMP_WIDTH,BMP_HEIGHT,draw_color);       // clears the 'bitmap' to a fixed color.
                 if (fout_pointer!=0) $fwrite(fout_pointer,"Clearing bitmap to color %d.\n",draw_color);
                 end

  "SAVE_BMP"   : begin
                 r = $fscanf(fin_pointer,"%s",bmp_file_name);                                          // Read file name for the log file
                   if (destination_file_name != "") begin
                       if (fout_pointer!=0) $fwrite(fout_pointer,"Saving BMP '%s'.\n",bmp_file_name);
                       save_bmp_256(bmp_file_name,BW_BMP);                                                            // Save the BMP image.
                   end else begin
                    $sformat(message_string,"\nInvalid file name for SAVE_BMP command.\n");
                    $display("%s",message_string);
                    $fclose(fin_pointer);
                    if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
                    if (fout_pointer!=0) $fclose(fout_pointer);
                    $stop;
                   end
                 end

  "LOG_FILE"   : begin                                                  // begin logging the results.
                   if (fout_pointer==0) begin
                   r = $fscanf(fin_pointer,"%s",destination_file_name); // Read file name for the log file
                     fout_pointer= $fopen(destination_file_name,"w");   // Open that file name for writing.
                     if (fout_pointer==0) begin
                          $display("\nCould not open log file '%s' for writing.\n",destination_file_name);
                          $stop;
                     end else begin
                     $fwrite(fout_pointer,"Log file requested in '%s' at line#%d.\n\n",source_file_name,13'(line_number));
                     end
                   end else begin
                     $sformat(message_string,"\n*** Error in command script at line #%d.\n    You cannot open a LOG_FILE since the current log file '%s' is already running.\n    You must first '@END_LOG_FILE' if you wish to open a new log file.\n",13'(line_number),destination_file_name);
                     $display("%s",message_string);
                     $fclose(fin_pointer);
                     if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
                     if (fout_pointer!=0) $fclose(fout_pointer);
                     $stop;
                   end
                 end

  "END_LOG_FILE" : if (fout_pointer!=0)begin                           // Stop logging the commands and close the current log file.
                       $sformat(message_string,"@%s command at line number %d.\n",command_in,13'(line_number));
                       $display("%s",message_string);
                       $fwrite(fout_pointer,"%s",message_string);
                       $fclose(fout_pointer);
                       fout_pointer = 0;
                   end

  "STOP"       :  begin // force a temposry stop.
                  $sformat(message_string,"@%s command at line number %d.\nType 'Run -All' to continue.",command_in,13'(line_number));
                  $display("%s",message_string);
                  if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
                  $stop;
                  end

  "END"        :  begin // force seek to the end of the source file.
                  $sformat(message_string,"@%s command at line number %d.\n",command_in,13'(line_number));
                  $display("%s",message_string);
                  $fclose(fin_pointer);
                  if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
                  fin_pointer = 0;
                  end

  default      :  begin // Unknown command
                  $sformat(message_string,"Source ascii file '%s' has an unknown command '@%s' at line number %d.\nProcessign stopped due to error.\n",source_file_name,command_in,13'(line_number));
                  $display("%s",message_string);
                  if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
                  $stop;
                  end
  endcase

end // if !end of source file

end// while not eof


// Finished reading source file.  Close files and stop.

$sformat(message_string,"\nEnd of command source ascii file '%s'.\n%d lines processed.\n",source_file_name,13'(line_number));
$display("%s",message_string);
$fclose(fin_pointer);
if (fout_pointer!=0) $fwrite(fout_pointer,"%s",message_string);
if (fout_pointer!=0) $fclose(fout_pointer);
$stop;
end
endtask



// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
// task draw_ellipse(integer src, integer dest, bit fill, integer q1, integer q2 );
// 
// Reads a string of coordinates from the source file and drives the ellipse generator.
// Then, calls the routine which captures the result coordinates while the ellipse generator is busy.
//
// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************

task draw_ellipse(integer src, integer dest);
 begin
 integer r;
 byte unsigned draw_color,q1,q2;

// align to a negedge clock.  Since the ellipse runs on @posdedge clk, this alignment will setup the input controls so they will be ready at the posedge.
@(negedge clk); 
enable         = 1'b1; // command the ellipse module
run            = 1'b0;
ena_pause      = 1'b0;

while (busy || reset) begin           // if module is busy or reset is high, wait for it to become ready and clr the reset.
                      reset = 0;
                      @(negedge clk); // wait for another negedge clock
                      end


// Retrieve the filled, quadrant, 4 coordinates plus color on the command line.
   r = $fscanf(src,"%d%d%d%d%d%d%d",ellipse_filled,q2,Xc,Yc,Xr,Yr,draw_color);

if (q2>3) begin    // setup for loop to draw all 4 quadrants
          q1=0;
          q2=4;
 end else begin    // setup for loop to draw 1 quadrant
          q1=q2;
          q2=q2+1;
          end

for (int q=q1 ; q<q2 ; q++ ) begin // setup loop to draw the requested quadrants.

     quadrant       = q;

     // Log the received command.
     if (dest!=0) $fwrite(dest,"Run ellipse filled(%b), Quadrant(%d), POSITION(%d,%d), RADIUS(%d,%d), color(%d).\n",ellipse_filled,quadrant,Xc,Yc,Xr,Yr,draw_color);

     // strobe the 'run' signal.
     run = 1;
     @(negedge clk);
     run = 0;
     @(negedge clk);      // Optional delay clock to wait for ellipse module to activate the busy flag.


     while (busy) begin   // While the ellipse module is busy, grab and log valid pixel data.
                if (pixel_data_rdy) begin
                       // Write color into bitmap at coordinates is they are within bitmap size...
                       if (X_coord>=0 && Y_coord>=0 && X_coord<1024 && Y_coord<1024) bitmap[X_coord][Y_coord] = draw_color;
                       // Log the received command.
                       if (dest!=0) $fwrite(dest,"(%d,%d) = %d.\n",X_coord,Y_coord,draw_color);
                       end

                @(negedge clk); // Wait 1 clock cycle before attempting to grab another coordinate.
          end

     if (dest!=0) $fwrite(dest,"\n"); // add a carrige return after an ellipse is drawn.
end // for loop for quadrant

end
endtask




// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
// task clear_bitmap (integer xs, integer ys, byte unsigned color);
// 
// Clears the bitmap logic array with the 'color'
//
// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************

task clear_bitmap (integer xs, integer ys, byte unsigned color);
begin

for(int y=0;y<ys;y++) begin
                      for(int x=0;x<xs;x++) bitmap [x][y]=color; 
                      end
end
endtask

// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
// task send_rst();
// 
// sends a reset.
//
// ***********************************************************************************************************
// ***********************************************************************************************************
// ***********************************************************************************************************
task send_rst();
begin
@(negedge clk); 
reset = 1;
@(negedge clk); 
reset = 0;
@(negedge clk); 
end
endtask


endmodule
