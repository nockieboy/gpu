module ps2_rx 	(

	input wire clk,
	input wire rst, 
	input wire ps2d, ps2c,    // ps2 data and clock inputs, receive enable input
	output reg rx_done_tick,         // ps2 receive done tick
	output wire [7:0] rx_data        // data received 
	
);

parameter nDelay = 500000;				// 10 millisecond Rx timeout
reg [19:0] timeout_counter;
reg timeout = 1'b0;

parameter rxDelay = 500000;			// 10 millisecond delay before next char can be rx'd
reg [19:0] rx_counter;

// FSMD state declaration
localparam 
	idle = 1'b0,
	rx   = 1'b1;

// internal signal declaration
reg state_reg, state_next;          // FSMD state register
reg [7:0] filter_reg;               // shift register filter for ps2c
wire [7:0] filter_next;             // next state value of ps2c filter register
reg f_val_reg;                      // reg for ps2c filter value, either 1 or 0
wire f_val_next;                    // next state for ps2c filter value
reg [3:0] n_reg, n_next;            // register to keep track of bit number 
reg [10:0] d_reg, d_next;           // register to shift in rx data
wire neg_edge;                      // negative edge of ps2c clock filter value

wire reset = rst || timeout;

// register for ps2c filter register and filter value
always @(posedge clk, posedge reset) begin
	
	if (reset) begin
		
		filter_reg 			<= 0;
		f_val_reg  			<= 0;
		timeout				<= 0;
		timeout_counter 	<= 20'b0;
		
	end
	else begin
		
		filter_reg			<= filter_next;
		f_val_reg  			<= f_val_next;
		
		if (neg_edge) begin
			
			timeout_counter<= 20'b0;		// reset timeout counter
			
		end
		else begin
			
			timeout_counter<= timeout_counter + 1;
			
		end
		
		if (timeout_counter == nDelay - 1) begin
			
			timeout 			<= 1'b1;
			
		end
		
	end
	
end

// next state value of ps2c filter: right shift in current ps2c value to register
assign filter_next = {ps2c, filter_reg[7:1]};
	
// filter value next state, 1 if all bits are 1, 0 if all bits are 0, else no change
assign f_val_next = (filter_reg == 8'b11111111) ? 1'b1 : (filter_reg == 8'b00000000) ? 1'b0 : f_val_reg;
	
// negative edge of filter value: if current value is 1, and next state value is 0
assign neg_edge = f_val_reg & ~f_val_next;

// assign data to the output
assign rx_data = d_reg[8:1]; // output data bits
	
// FSMD state, bit number and data registers
always @(posedge clk, posedge reset) begin
	
	if (reset) begin
		
		state_reg 	<= idle;
		n_reg 		<= 0;
		d_reg 		<= 0;
		
	end
	else begin
		
		state_reg 	<= state_next;
		n_reg 		<= n_next;
		d_reg 		<= d_next;
		
	end
	
end

// Rx delay counter
always @(posedge clk) begin

	if (rx_counter > 0)
		rx_counter	<= rx_counter - 1'b1;
	
	if (rx_done_tick == 1'b1 && rx_counter < 1'b1)
		rx_counter	<= rxDelay;

end
	
// FSMD next state logic
always @* begin
	
	// defaults
	state_next 		= state_reg;
	rx_done_tick 	= 1'b0;
	n_next 			= n_reg;
	d_next 			= d_reg;
	
	case (state_reg)
		
		idle:
		begin
			if (neg_edge) begin             // start bit received
				
				n_next 		= 4'b1010;       // set bit count down to 10
				state_next 	= rx;            // go to rx state
				
			end
		end
		
		rx:                                // shift in 8 data, 1 parity, and 1 stop bit
		begin
			if (neg_edge) begin             // if ps2c negative edge...
				
				d_next = {ps2d, d_reg[10:1]};// sample ps2d, right shift into data register
				n_next = n_reg - 1;          // decrement bit count
				
			end
			
			if (n_reg == 0) begin           // after 10 bits shifted in, go to done state
				
				//if (rx_counter == 0)
					rx_done_tick = 1'b1;      // assert dat received done tick
				
				state_next 		= idle;       // go back to idle
				
			end
		end
		
	endcase
	
end
	
endmodule
