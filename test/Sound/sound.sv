module sound (

   // inputs
   input wire clk,
   input wire enable,
   input wire data_tx,     // one-shot for valid data
   input wire [8:0] data,  // bit 8 HIGH for tone, LOW for duration
   
   // outputs
   output reg speaker
   
);

reg [31:0] counter;
reg [31:0] duration;
reg [7:0] tone;
reg [7:0] dur;
reg last_enable;
reg run;

wire enabled;

assign enabled = enable & ~last_enable;

initial begin
   
   run            <= 1'b0;
   last_enable    <= 1'b0;
   tone[7:0]      <= 8'd16;
   dur[7:0]       <= 8'd8;

end

always @(posedge clk) begin

   if (data_tx) begin
      case (data[8])
         1'b0 : begin
            // set DURATION
            dur[7:0]  <= data[7:0];
         end
         1'b1 : begin
            // set NOTE
            tone[7:0] <= data[7:0];
         end
      endcase
		//counter  <= 31'b0;
		run      <= 1'b0;
   end
   
   if ( enabled ) begin
      //duration <= 31'b0;      // reset duration counter as new sound is starting
		counter  <= 31'b0;
      run      <= 1'b1;       // set run flag to play sound
   end
   
   /*if ( run && duration[31:0] == { 5'b0, dur[7:0], 19'b0 } ) begin
   
      run     <= 1'b0;             // duration expired, clear run flag
      speaker <= 1'b0;             // shut down speaker output
      
   end else if ( run ) begin
   
      duration <= duration + 1'b1; // update duration counter while running
      counter  <= counter  + 1'b1;
      
   end
   
   if ( run && counter[31:0]  == { 11'b0, tone[7:0], 13'b0 } ) speaker <= ~speaker;*/
	
	if ( counter[31:0] == { 3'b0, dur[7:0], 21'b0 } ) run <= 1'b0;
	
	if ( run ) begin  // if counter hasn't reached maximum duration
		counter <= counter + 1'b1;
		speaker <= counter[tone[4:0]];
	end
   
   last_enable <= enable;
   
end

endmodule
