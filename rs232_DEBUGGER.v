module rs232_debugger (
     input  wire rst,
     input  wire clk,
     input  wire rxd,
     output wire txd,

     input  wire ena_txd,

	output reg        host_wr_ena,
	output wire [19:0] host_addr,
	output wire [7:0] host_wdata,
	input  wire [7:0] host_rdata );


parameter UART_BAUD     = 1084;
parameter UART_RX_FIFO  = 16;
parameter UART_TX_FIFO  = 512;
parameter DEBUG_RST_ADR = 4096;

reg [19:0] host_addr_reg = DEBUG_RST_ADR;
assign    host_addr = host_addr_reg;
wire      rxd_rdy;
reg       ena_rxd;
reg       rxd_rdy_dly, ena_rxd_dly;

rs232_io  rs232_com ( .clk(clk),
					.txd(txd),
					.rxd(rxd),
					.ena_txd(ena_txd),
					.tx_data(host_rdata),
					.tx_full(),
					.rxd_rdy(rxd_rdy),
					.ena_rxd(ena_rxd),
					.rx_data(host_wdata) );
	defparam
		rs232_com.UART_BAUD    = UART_BAUD,
		rs232_com.UART_RX_FIFO = UART_RX_FIFO,
		rs232_com.UART_TX_FIFO = UART_TX_FIFO;


always @ (posedge clk) begin
rxd_rdy_dly <= rxd_rdy;
ena_rxd_dly <= host_wr_ena;

if (rst) begin
		host_wr_ena     <= 0 ;
		host_addr_reg   <= DEBUG_RST_ADR ;
		end else begin

			if (rxd_rdy && ~rxd_rdy_dly ) ena_rxd <= 1;
			else ena_rxd <= 0;
			
			if (ena_rxd)     host_wr_ena <= 1;
			else             host_wr_ena <= 0;
			
			if (ena_rxd_dly) host_addr_reg   <= host_addr_reg + 1;
	
				

		end // !rst
end // always
endmodule



module rs232_io ( 
     input  wire rst,
     input  wire clk,
     input  wire rxd,
     output wire txd,
     
     input  wire ena_txd,
     input  wire [7:0] tx_data,
     output wire tx_full,
     
     output wire rxd_rdy,
     input  wire ena_rxd,
     output wire [7:0] rx_data );

parameter UART_BAUD    = 1084;
parameter UART_RX_FIFO = 16;
parameter UART_TX_FIFO = 512;

wire syncro_in;
wire syncro_out;
wire rxd_empty;
assign syncro_out = syncro_in;
assign rxd_rdy    = ~rxd_empty;

serial_rx   rxd_comp (	.clk(clk),
					.rx(rxd),
					.rd_req(ena_rxd),
					.empty(rxd_empty),
					.data(rx_data[7:0]),
					.tx_sync(syncro_in) );
		defparam
				rxd_comp.RX_FIFO_SIZE = UART_RX_FIFO,
				rxd_comp.RX_BAUD      = UART_BAUD;

//module serial_tx ( clk, ena_tx, data, rx_frame,
//                    tx, full, sync, tick, active ) ;

serial_tx   txd_comp (	.clk(clk),
					.tx(txd),
					.ena_tx(ena_txd),
					.full(tx_full),
					.data(tx_data[7:0]),
					.sync(syncro_out) );
		defparam
				txd_comp.TX_FIFO_SIZE = UART_TX_FIFO,
				txd_comp.TX_BAUD      = UART_BAUD;
				

endmodule

// RS-232 reciever, fixed 8N1, selectable fifo size, 16 bit period.

module serial_rx ( clk, rx, rd_req,
                    empty, data, rx_start, tx_sync, tick, active ) ;

parameter RX_FIFO_SIZE = 16 ;
parameter RX_BAUD      = 1084 ;

input              clk ;
input              rx, rd_req ;

reg                rxd;

output             empty ;

reg                d_rdy ;

output  [7:0]      data ;

output             rx_start, tx_sync, tick, active ;
reg                rx_start ;
wire               tx_sync = rx_start;

reg                tick, active ;

reg     [15:0]     p_counter ;
reg     [4:0]      position ;
reg     [7:0]      rx_byte ;


// ***************************************************************************************
// ***RX Fifo declaration
// ***************************************************************************************
	wire  sub_wire0;
	wire [7:0] sub_wire1;
	wire  sub_wire2;
	wire  empty = sub_wire0;
	wire [7:0] data = sub_wire1[7:0];
	wire  full = sub_wire2;

	scfifo	scfifo_component (
				.rdreq (rd_req),
				.sclr (rst),
				.clock (clk),
				.wrreq (d_rdy),
				.data (rx_byte),
				.empty (sub_wire0),
				.q (sub_wire1),
				.full (sub_wire2)
				// synopsys translate_off
				,
				.aclr (),
				.almost_empty (),
				.almost_full (),
				.usedw ()
				// synopsys translate_on
				);
	defparam
		scfifo_component.add_ram_output_register = "ON",
		scfifo_component.intended_device_family = "Cyclone IV",
		scfifo_component.lpm_numwords = RX_FIFO_SIZE,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = 8,
		//scfifo_component.lpm_widthu = 4,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "OFF";

// ***************************************************************************************


always @ (posedge clk) begin

//if (ena_baud) period <= baud ;

rxd      <= rx;
rx_start <= (rxd & ~rx) & ~active;

if ( rx_start ) begin
						active     <= 1;
						position   <= 0;
						p_counter  <= 2;
				end else if (active) begin
									
									if ( p_counter == 0 ) begin
									p_counter <= RX_BAUD ;
									position  <= position + 1 ;
														
									 if (position == 1) begin
														tick        <= 1 ;
														rx_byte[0]  <= rxd;
							end else if (position == 2) begin
														tick        <= 1 ;
														rx_byte[1]  <= rxd;
							end else if (position == 3) begin
														tick        <= 1 ;
														rx_byte[2]  <= rxd;
							end else if (position == 4) begin
														tick        <= 1 ;
														rx_byte[3]  <= rxd;
							end else if (position == 5) begin
														tick        <= 1 ;
														rx_byte[4]  <= rxd;
							end else if (position == 6) begin
														tick        <= 1 ;
														rx_byte[5]  <= rxd;
							end else if (position == 7) begin
														tick        <= 1 ;
														rx_byte[6]  <= rxd;
							end else if (position == 8) begin
														tick        <= 1 ;
														rx_byte[7]  <= rxd;
														//d_rdy       <= 1;
														//active      <= 0;
							end else if (position == 9) begin
														d_rdy       <= 1;
														active      <= 0;
							end else d_rdy <= 0;

						end else begin //p_counter!=0

						p_counter <= p_counter - 1;
						tick  <= 0;
						d_rdy <= 0;

						end //p_counter!=0

				end else begin // active
						tick  <= 0;
						d_rdy <= 0;
				
				end // !active
				
end // always

endmodule

// RS-232 transmitter, fixed 8N1, selectable fifo size, 16 bit period.

module serial_tx ( clk, ena_tx, data, rx_frame,
                    tx, full, sync, tick, active ) ;

parameter TX_FIFO_SIZE = 16 ;
parameter TX_BAUD      = 1084 ;

input              clk ;
input              ena_tx;
input   [7:0]      data ;
input              rx_frame;

output             tx, full, sync, tick, active ;
reg                tx, sync, tick, active ;

reg     [15:0]     period ;
reg     [15:0]     p_counter ;
reg     [4:0]      position ;
//reg     [7:0]      tx_byte ;



// **********************************************************************
// *** TX Fifo declaration
// **********************************************************************
	wire  sub_wire0;
	wire [7:0] sub_wire1;
	wire  sub_wire2;
	wire  empty = sub_wire0;
	wire [7:0] tx_byte = sub_wire1[7:0];
	wire  full = sub_wire2;

	scfifo	scfifo_component (
				.rdreq (sync),
				.clock (clk),
				.sclr (rst),
				.wrreq (ena_tx),
				.data (data),
				.empty (sub_wire0),
				.q (sub_wire1),
				.full (sub_wire2)
				// synopsys translate_off
				,
				.aclr (),
				.almost_empty (),
				.almost_full (),
				.usedw ()
				// synopsys translate_on
				);
	defparam
		scfifo_component.add_ram_output_register = "ON",
		scfifo_component.intended_device_family = "Cyclone II",
		scfifo_component.lpm_numwords = TX_FIFO_SIZE,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = 8,
		//scfifo_component.lpm_widthu = 4,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";   // use off for small numbers
//************************************************************************

always @ (posedge clk) begin

if ( (p_counter == 0) | (rx_frame & ~active) ) begin
			
			tick      <= 1;
			p_counter <= TX_BAUD ;

							
			if ( (position > 10 ) | (rx_frame & ~active) ) begin
									position <= 0 ;
									tx       <= 1;
									active   <= ~empty ;
									end else begin
									position <= position + 1 ;
									sync     <= 0 ;
									end

			if ( active ) begin
									 if (position == 0) begin
														tx       <= 0;
														sync     <= 1 ;
							end else if (position == 1) begin
														tx       <= tx_byte[0];
							end else if (position == 2) begin
														tx       <= tx_byte[1];
							end else if (position == 3) begin
														tx       <= tx_byte[2];
							end else if (position == 4) begin
														tx       <= tx_byte[3];
							end else if (position == 5) begin
														tx       <= tx_byte[4];
							end else if (position == 6) begin
														tx       <= tx_byte[5];
							end else if (position == 7) begin
														tx       <= tx_byte[6];
							end else if (position == 8) begin
														tx       <= tx_byte[7];
							end else if (position == 9) begin
														tx       <= 1;
							end else if (position == 10) begin
														tx       <= 1;
														active   <= 0;
							end			end // ( ena_tx || active )

		end else begin // (p_counter == 0) | (rx_frame & ~active)

					p_counter <= p_counter - 1;
					tick      <= 0 ;
					sync      <= 0 ;
			end // ~(p_counter == 0) | (rx_frame & ~active)

end // always

endmodule
