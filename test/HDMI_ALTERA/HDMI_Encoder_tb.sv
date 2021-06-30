
// HDMI_Encoder global testbench

`timescale 1 ps/ 1 ps // 1 picosecond steps, 1 picosecond precision.


module HDMI_test_tb();
logic        clk;
logic        DE;
logic  [3:0] tmds;

localparam real CLK_MHz  = 50.000 ;
localparam real STOP_uS  = 1000000 ;

localparam period  = 500000/CLK_MHz ;
localparam endtime = STOP_uS * 50;

// assign statements (if any)                          
HDMI_Encoder DUT(
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.DE(DE),
	.tmds(tmds)
);


//$add wave -position insertpoint sim:/HDMI_test_tb/DUT/clk_pixel ;

initial 
begin 

clk = 1'b1;
//reset = 1'b1;
#period;

clk = 1'b0;
//reset = 1'b1;
#period;

clk = 1'b1;
//reset = 1'b1;
#period;
end 

// clk
always #period clk = !clk;
always #endtime $stop;   // Pause the simulation

endmodule
