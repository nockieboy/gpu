module Seven_segment_LED_Display_Controller(

    input       clk50,               // 50 Mhz clock source on Basys 3 FPGA
    input       reset,               // reset
    input [7:0] MSB,                 // 1st byte value to display
    input [7:0] LSB,                 // 2nd byte value to display
    
    output reg [3:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [7:0] LED_out         // cathode patterns of the 7-segment LED display (and decimal point)
    
);

reg [3:0]  LED_byte        ;
reg [18:0] refresh_counter ; // 19-bit for creating 10.5ms refresh period or 380Hz refresh rate
                             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
wire [1:0] display_counter ; // count         0   ->  1  ->  2  ->  3
                             // activates    LED1    LED2   LED3   LED4
                             // and repeat

always @( posedge clk50 or negedge reset ) begin
 
   if ( !reset ) begin
   
      refresh_counter <= 20'b0 ;
      
   end
   else begin
   
      refresh_counter <= refresh_counter  + 1'b1 ;
      
   end
         
end
 
assign display_counter = refresh_counter[18:17] ;
 
// anode activating signals for 4 LEDs, digit period of 2.6ms
// decoder to generate anode signals 
always @( posedge clk50 )  begin
 
  case(display_counter)
     
     2'b00: begin // MSB of first value
         Anode_Activate <= 4'b0111 ; 
         // activate LED1 and Deactivate LED2, LED3, LED4
         LED_byte <= MSB[7:4] ;
     end
     
     2'b01: begin // LSB of first value
         Anode_Activate <= 4'b1011 ; 
         // activate LED2 and Deactivate LED1, LED3, LED4
         LED_byte <= MSB[3:0] ;
     end
     2'b10: begin // MSB of second value
         Anode_Activate <= 4'b1101 ; 
         // activate LED3 and Deactivate LED2, LED1, LED4
         LED_byte <= LSB[7:4] ;
     end
     2'b11: begin // LSB of second value
         Anode_Activate <= 4'b1110 ; 
         // activate LED4 and Deactivate LED2, LED3, LED1
         LED_byte <= LSB[3:0] ;
     end
      
  endcase
     
end
 
// Cathode patterns of the 7-segment LED display 
always_comb begin
 
  case(LED_byte)
  
     4'b0000: LED_out = 8'b11000000 ; // "0"     
     4'b0001: LED_out = 8'b11111001 ; // "1" 
     4'b0010: LED_out = 8'b10100100 ; // "2" 
     4'b0011: LED_out = 8'b10110000 ; // "3" 
     4'b0100: LED_out = 8'b10011001 ; // "4" 
     4'b0101: LED_out = 8'b10010010 ; // "5" 
     4'b0110: LED_out = 8'b10000010 ; // "6" 
     4'b0111: LED_out = 8'b11111000 ; // "7" 
     4'b1000: LED_out = 8'b10000000 ; // "8"     
     4'b1001: LED_out = 8'b10010000 ; // "9"
     4'b1010: LED_out = 8'b10001000 ; // "A"
     4'b1011: LED_out = 8'b10000011 ; // "B"
     4'b1100: LED_out = 8'b11000110 ; // "C"
     4'b1101: LED_out = 8'b10100001 ; // "D"
     4'b1110: LED_out = 8'b10000110 ; // "E"
     4'b1111: LED_out = 8'b10001110 ; // "F"
     default: LED_out = 8'b10111111 ; // "-"
   
  endcase
     
end
 
endmodule
 