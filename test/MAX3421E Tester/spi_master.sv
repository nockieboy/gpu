////////////////////////////////////////////////////////////////////////////////
////                                                                        ////
//// Project Name: SPI (Verilog)                                            ////
////                                                                        ////
//// Module Name: spi_master                                                ////
////                                                                        ////
////                                                                        ////
////  This file is part of the Ethernet IP core project                     ////
////  http://opencores.com/project,spi_verilog_master_slave                 ////
////                                                                        ////
////  Author(s):                                                            ////
////      Santhosh G (santhg@opencores.org)                                 ////
////                                                                        ////
////  Refer to Readme.txt for more information                              ////
////                                                                        ////
////////////////////////////////////////////////////////////////////////////////
////                                                                        ////
//// Copyright (C) 2014, 2015 Authors                                       ////
////                                                                        ////
//// This source file may be used and distributed without                   ////
//// restriction provided that this copyright statement is not              ////
//// removed from the file and that any derivative work contains            ////
//// the original copyright notice and the associated disclaimer.           ////
////                                                                        ////
//// This source file is free software; you can redistribute it             ////
//// and/or modify it under the terms of the GNU Lesser General             ////
//// Public License as published by the Free Software Foundation;           ////
//// either version 2.1 of the License, or (at your option) any             ////
//// later version.                                                         ////
////                                                                        ////
//// This source is distributed in the hope that it will be                 ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied             ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                ////
//// PURPOSE.  See the GNU Lesser General Public License for more           ////
//// details.                                                               ////
////                                                                        ////
//// You should have received a copy of the GNU Lesser General              ////
//// Public License along with this source; if not, download it             ////
//// from http://www.opencores.org/lgpl.shtml                               ////
////                                                                        ////
////////////////////////////////////////////////////////////////////////////////

/*
   Modified by J.Nock, January 2021, to allow two-byte transfers to work whilst
   SS is held low.  This is required for transactions with a large number of
   slave devices, including the MAX3421E for which this feature was specifically
   added. (nockieboy)
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SPI MODE 3
 write data @negedge
 read data @posedge

 reset - active low asyn reset
 CLK   - clock
 T_RB  - 0-RX
         1-TX
         
 bit_order - 0-LSB 1st
             1-MSB 1st
             
 START - 1 - starts data transmission
 cdiv  - 0 = clk/2
         1 = /4
         2 = /8
         3 = /16
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
module spi_master(

   input logic        reset,
   input logic        clk,
   input logic        start,
   input logic  [7:0] tx_data,  // transmit data, valid when start = 1
   input logic        MISO,     // RX serial stream
   
   output logic       SS,       // TX select
   output logic       SCK,      // TX clock
   output logic       MOSI,     // TX serial stream
   output logic       done,
   output logic [7:0] rx_data   // received data, valid when done = 1
);

parameter  cdiv      = 0      ; // clock divider
parameter  bit_order = 1      ; // endian selector (0 = LSB 1st, 1 = MSB 1st)
parameter  tx_pairs  = 1      ; // 1 = send two bytes before releasing SS, 0 = release SS after each byte sent
parameter  test      = 0      ;

localparam idle      = 3'b000 ;
localparam send      = 3'b001 ;
localparam idle2     = 3'b010 ;
localparam send2     = 3'b011 ;
localparam finish    = 3'b100 ;

logic [2:0] cur = idle ;
logic [2:0] nxt = idle ;
logic [7:0] treg, rreg ;
logic [3:0] nbit       ;
logic [4:0] mid, cnt   ;
logic       shift      ;
logic       clr        ; // SPI active when LOW

generate
	if ( test == 0 )
		// FSM I/O
		always_latch begin // always @(start or cur or nbit or cdiv or rreg) begin
		   
			nxt   = cur ;
			clr   = 0   ;
			shift = 0   ;
		   
			case(cur)
				
				idle : begin // IDLE state
					if ( start == 1 ) begin // start transmission cmd received
						case ( cdiv )     // set clk division factor
							0 : mid = 2  ;
							1 : mid = 4  ;
							2 : mid = 8  ;
							3 : mid = 16 ;
						endcase
						shift = 1'b1 ;
						done  = 1'b0 ;
						nxt   = send ; // set next state to SEND
					end
					else begin // idling - nothing to do
						done  = 1'b0 ;
						shift = 1'b0 ;
						clr   = 1'b1 ;
						SS    = 1'b1 ;
					end
				end //idle
				
				send : begin // SEND state
					SS = 1'b0 ;
					if ( nbit != 8 ) // not last bit
						shift   = 1    ; // keep shifting bits out
					else begin // last bit
						rx_data = rreg ; // set rx_data to received byte
						done    = 1'b1 ; // let the receiver know a valid byte is available
						if ( tx_pairs == 1 )
							nxt = idle2 ; // set next state to SEND2 for second byte
						else
							nxt = idle  ; // return to IDLE
					end
				end//send
				
				idle2 : begin // IDLE2 state
					SS = 0 ;
					if ( start == 1 ) begin // start transmission cmd received
						case ( cdiv ) // set clk division factor
							0 : mid = 2  ;
							1 : mid = 4  ;
							2 : mid = 8  ;
							3 : mid = 16 ;
						endcase
						shift = 1'b1 ;
						done  = 1'b0 ;
						nxt   = send2 ; // set next state to SEND2
					end
					else begin // waiting for next byte to be received
						done  = 1'b0 ;
						shift = 1'b0 ;
						clr   = 1'b1 ;
					end
				end //idle
				
				send2 : begin // SEND2 state
					SS = 1'b0 ;
					if ( nbit != 8 ) // not last bit
						shift   = 1      ; // keep shifting bits out
					else begin // last bit
						rx_data = rreg   ; // set rx_data to received byte
						done    = 1'b1   ; // let the receiver know a valid byte is available
						nxt     = finish ; // set next state to FINISH
					end
				end//send
				
				finish : begin // FINISH state
					shift = 0    ;
					nxt   = idle ; // set next state to IDLE
					SS    = 1'b1 ; // release SS
					clr   = 1'b1 ; // disable SPI transfers
				end
				
				default : nxt = finish ;
				
			endcase
		   
		end //always
	else
		always_comb begin
			
			clr   = 0   ;
			shift = 1   ;
			mid   = 16  ;
			
		end //always
endgenerate

// manage state transitions
always_ff @( negedge clk or negedge reset ) begin
   
   if ( !reset ) 
      cur <= finish ;
   else 
      cur <= nxt    ;
   
end

// manage SCK by alternating it at CLK/mid rate
// keeps SCK high and cnt at zero if not active
always @( negedge clk or posedge clr ) begin
   
   if ( clr == 1 ) begin
      
      cnt = 0 ;
      SCK = 1 ;
      
   end
   else begin
      
      if ( shift == 1 ) begin // bits to transmit on MOSI
         
         cnt = cnt + 1 ; // increment clock division counter
         if ( cnt == mid ) begin // SPI clock event
            
            SCK = ~SCK ; // invert SCK
            cnt = 0    ; // reset clock division counter
            
         end // mid
         
      end // shift
      
   end // rst
 
end // always

// sample @ rising edge (read MISO)
always @( posedge SCK or posedge clr ) begin // or negedge reset

   if ( clr == 1 ) begin
      
      nbit = 0     ;
      rreg = 8'hFF ;
      
   end
   else begin 
      
      if ( bit_order == 0 ) begin // LSB first, MISO@msb -> right shift
         
         rreg = { MISO, rreg[7:1] } ;
         
      end 
      else begin  // MSB first, MISO@lsb -> left shift
         
         rreg = { rreg[6:0], MISO } ;
         
      end
      nbit = nbit + 1 ;
      
   end // rst
 
end //always

// transmit @ falling edge (write MOSI)
always @( negedge SCK or posedge clr ) begin
   
   if ( clr == 1 ) begin
      
      treg = 8'hFF ;
      MOSI = 1     ;
      
   end
   else begin
      
      if ( nbit == 0 ) begin // load data into TREG
         
         treg = tx_data                 ;
         MOSI = bit_order ? treg[7] : treg[0] ;
         
      end // nbit_if
      else begin
         
         if ( bit_order == 0 ) begin // LSB first, shift right
            
            treg = { 1'b1, treg[7:1] } ;
            MOSI = treg[0]             ;
            
         end
         else begin // MSB first shift LEFT
            
            treg = { treg[6:0], 1'b1 } ;
            MOSI = treg[7]             ;
            
         end
         
      end
      
   end //rst
   
end //always


endmodule
