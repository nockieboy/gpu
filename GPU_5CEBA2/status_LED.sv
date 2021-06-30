module status_LED (

	input clk,
	output LED
	
);

// div can only be a maximum of 5, minimum -24
parameter div = 1;

reg [25 + div:0] cnt;
reg [5:0] PWM;

wire [4:0] PWM_input = cnt[25 + div] ? cnt[24 + div:20 + div] : ~cnt[24 + div:20 + div];    // ramp the PWM input up and down

always @(posedge clk) begin

	cnt <= cnt + 1'b1;
	PWM <= PWM[4:0] + PWM_input;

end

assign LED = PWM[5];

endmodule
