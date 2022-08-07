// fpga4student.com: FPGA projects, VHDL projects, Verilog projects
// Verilog project: Verilog code for clock divider on FPGA
//
// Frequency of clk_o = clk_i / DIVISOR

module clock_divider (

    input  wire  clk_i, // input clock on FPGA
    output logic clk_o  // output clock after dividing the input clock by divisor

);

parameter DIVISOR = 28'd2 ; // clock divisor value
reg[27:0] counter = 28'd0 ;

always @( posedge clock_i ) begin

 counter <= counter + 28'd1 ;
 if ( counter >= ( DIVISOR - 1 ) ) counter <= 28'd0 ;
 clock_o <= ( counter < DIVISOR / 2 ) ? 1'b1 : 1'b0 ;

end

endmodule
