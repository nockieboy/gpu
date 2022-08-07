/*

Function: 
	ADV7513 Video and Audio Control 
	
I2C Configuration Requirements:
	Master Mode
	I2S, 16-bits
	
Clock:
	input Clock 1.536MHz (48K*Data_Width*Channel_Num)
	
*/

module audio_i2s (

	input  logic        clk,
	input  logic        reset_n,
  input  logic [15:0] audio_i,
	output logic        sclk,
	output logic        lrclk,
	output logic [ 3:0] i2s

);

parameter DATA_WIDTH = 16 ;
//parameter SIN_SAMPLE_DATA = 48 ;

reg [ 5:0] sclk_Count   ;
reg [ 5:0] Simple_count ;
reg [15:0] data         ;
reg [ 6:0] bit_index    ;
reg	[ 5:0] SIN_Cont     ;

assign sclk = clk       ;

always @( negedge sclk or negedge reset_n ) begin

	if ( !reset_n ) begin
	  lrclk      <= 0 ;
	  sclk_Count <= 0 ;
	end
	else if ( sclk_Count >= DATA_WIDTH - 1 ) begin
	  sclk_Count <= 0      ;
	  lrclk      <= ~lrclk ;
	end
	else sclk_Count <= sclk_Count + 1 ;

end
 
always @( negedge sclk or negedge reset_n ) begin

  if ( !reset_n ) bit_index <= 0 ;
  else begin
    if ( bit_index >= DATA_WIDTH - 1 ) bit_index <= 0 ;
    else bit_index <= bit_index + 1 ;
  end

end

always @( negedge sclk or negedge reset_n ) begin

  if ( !reset_n ) i2s <= 0 ;
  else begin
    i2s[0] <= data[~bit_index] ;
	  i2s[1] <= data[~bit_index] ;
	  i2s[2] <= data[~bit_index] ;
	  i2s[3] <= data[~bit_index] ;
  end

end

always @( negedge lrclk or negedge reset_n ) begin

	if ( !reset_n ) data <= 0       ;
	else            data <= audio_i ;

end

/*
always @( negedge lrclk or negedge reset_n ) begin

	if(!reset_n) SIN_Cont <= 0 ;
	else begin
		if (SIN_Cont < SIN_SAMPLE_DATA - 1 ) SIN_Cont <= SIN_Cont + 1 ;
		else SIN_Cont <= 0 ;
	end

end

always @( SIN_Cont ) begin

	case ( SIN_Cont )

        0  :   data      <=      0       ;
        1  :   data      <=      4276    ;
        2  :   data      <=      8480    ;
        3  :   data      <=      12539   ;
        4  :   data      <=      16383   ;
        5  :   data      <=      19947   ;
        6  :   data      <=      23169   ;
        7  :   data      <=      25995   ;
        8  :   data      <=      28377   ;
        9  :   data      <=      30272   ;
        10  :  data      <=      31650   ;
        11  :  data      <=      32486   ;
        12  :  data      <=      32767   ;
        13  :  data      <=      32486   ;
        14  :  data      <=      31650   ;
        15  :  data      <=      30272   ;
        16  :  data      <=      28377   ;
        17  :  data      <=      25995   ;
        18  :  data      <=      23169   ;
        19  :  data      <=      19947   ;
        20  :  data      <=      16383   ;
        21  :  data      <=      12539   ;
        22  :  data      <=      8480    ;
        23  :  data      <=      4276    ;
        24  :  data      <=      0       ;
        25  :  data      <=      61259   ;
        26  :  data      <=      57056   ;
        27  :  data      <=      52997   ;
        28  :  data      <=      49153   ;
        29  :  data      <=      45589   ;
        30  :  data      <=      42366   ;
        31  :  data      <=      39540   ;
        32  :  data      <=      37159   ;
        33  :  data      <=      35263   ;
        34  :  data      <=      33885   ;
        35  :  data      <=      33049   ;
        36  :  data      <=      32768   ;
        37  :  data      <=      33049   ;
        38  :  data      <=      33885   ;
        39  :  data      <=      35263   ;
        40  :  data      <=      37159   ;
        41  :  data      <=      39540   ;
        42  :  data      <=      42366   ;
        43  :  data      <=      45589   ;
        44  :  data      <=      49152   ;
        45  :  data      <=      52997   ;
        46  :  data      <=      57056   ;
        47  :  data      <=      61259   ;
        default	:
            data		 <=	     0	     ;

	endcase
	
end
*/

endmodule
