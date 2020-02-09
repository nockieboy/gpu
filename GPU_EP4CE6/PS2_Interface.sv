
module PS2_Interface (
	// Inputs
	CLK_50,
	RESET,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	KEYCODE_OUT,
	KEYCODE_RDY
	
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input	wire		CLK_50;
input	wire		RESET;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output [7:0]	KEYCODE_OUT;
output wire		KEYCODE_RDY;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg		[7:0]	last_data_received;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLK_50) begin

	if (RESET)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
	
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

 
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50			(CLK_50),
	.reset				(reset),

	// Bidirectionals
	.PS2_CLK		 		(PS2_CLK),
 	.PS2_DAT				(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

endmodule
