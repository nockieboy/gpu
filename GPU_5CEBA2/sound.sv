module sound (

   // inputs
   input wire clk,
   input wire enable,
   input wire data_tx,     // one-shot for valid data
   input wire [8:0] data,  // bit 8 HIGH for tone, LOW for duration
	input wire reset,
   
   // outputs
   output reg speaker
   
);

logic [20:0] counter;
logic [7:0] tone;
logic last_enable;
logic run;
logic enabled;

always_comb	enabled = enable & ~last_enable;

initial begin
   
   run          <= 1'b0;
   last_enable  <= 1'b0;
   tone[7:0]    <= 8'd16;
	speaker      <= 1'b0;

end

always_ff @( posedge clk ) begin

	/*if (reset) begin
	
		tone[7:0] <= 8'd16;
		run		 <= 1'b0;
		counter   <= 21'b0;
		speaker   <= 1'b0;
		
	end*/

	/* NEW DATA RECEIVED
	
		Transfer data to the tone register or
		stop the current sound from playing.
	*/
   if (data_tx) begin
      case (data[8])
         1'b0 : begin	// STOP flag
				run       <= 1'b0;
         end
         1'b1 : begin	// set NOTE
            tone[7:0] <= data[7:0];
         end
      endcase
		run      <= 1'b0;
   end
   
	// Start playing new sound - reset counters and set run flag
   if ( enabled ) begin
		counter  <= 21'b0;		// reset tone counter for new sound
      run      <= 1'b1;       // set run flag to play sound
   end
	
	if ( run ) begin  // if counter hasn't reached maximum duration
	
		counter  <= counter + 1'b1;
		
		if ( counter[20:0]  == { tone[7:0], 13'b0 } ) begin	// end of count / current cycle
		
			speaker <= ~speaker;		// alternate speaker output (each 'count' for 50% duty cycle)
			counter <= 21'b0;       // reset counter for next cycle
			
		end
		
	end
   
   last_enable <= enable;
   
end

endmodule
