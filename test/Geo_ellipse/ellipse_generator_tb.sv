/*
 * RTL Test Bench ELLIPSE GENERATOR MODULE (ELLIE)
 *
 * v 0.5.001   Jan 13, 2021
 * Now with horizontal fill comand.
 * FMAX = 125.9 MHz compiled balanced optimized with 35 bit integer core.
 *
 * This has been setup for RTL simulation only.
 *
 * From within Modelsim, to reset the simulation, quick re-compile and rerun the simulation type:
 * do ../../ellipse_rerun_rtl.do
 *
 * The text file 'ellipse_commands_in.txt' contains the simulation drawing coordinates.
 * The format is as follows:
 * Filled <0,1>, Quadrant<0,1,2,3>, Xcenter<signed#>, Ycenter<signed#>, Xradius<unsigned#>, Yradius<unsigned#>
 *
 * The testbench will run as many commands you list in in the .txt file.
 * After simulation, all the generated ellipse's coordinates will be stored in:
 * ellipse_generated_results.txt
 *
 * as well as full logic waveform in the wave display.
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

integer fin_pointer,fout_pointer;

task render_ellipse_commands;
 begin

    fin_pointer= $fopen("../../ellipse_commands_in.txt","r");
    if (fin_pointer==0)
    begin
       $display("Could not open file '%s' for reading","ellipse_commands_in.txt");
       $stop;     
    end
    fout_pointer= $fopen("../../ellipse_generated_results.txt","w");
    if (fout_pointer==0)
    begin
       $display("Could not open file '%s'  for writing","ellipse_generated_results.txt");
       $stop;     
    end

    while ((! $feof(fin_pointer)) || busy) begin
 @(negedge clk) begin

      if (!busy && !reset) begin
            #(period*2);
            $fscanf(fin_pointer,"%b,%d,%d,%d,%d,%d\n",ellipse_filled,quadrant,Xc,Yc,Xr,Yr);
            $fwrite(fout_pointer,"Generating Ellipse, filled> %b, Quadrant> %d, Center>(%d,%d), Radius(%d,%d).\n",ellipse_filled,quadrant,Xc,Yc,Xr,Yr);
            run = 1'b1;
            #(period*2);
      end else begin 
      run = 1'b0;

      if (pixel_data_rdy && !reset) $fwrite(fout_pointer,"%d,%d\n",X_coord,Y_coord);
      #(period*2);
    end
  end
end
    run = 1'b0;
    $fwrite(fout_pointer,"Finished.\n");
    $fclose(fin_pointer);
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
always #(period*10) if (!busy) $stop;   // Automatically end the simulation once the end has been reached

endmodule
