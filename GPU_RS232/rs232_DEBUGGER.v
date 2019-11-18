module rs232_debugger (
     input  wire rst,
     input  wire clk,
     input  wire rxd,
     output wire txd,

	output reg         host_wr_ena,
	output wire [19:0] host_addr,
	output reg  [7:0] host_wdata,
	input  wire [7:0] host_rdata,
	output reg        soft_rst

/*// *******************************************debug ports
	output wire db_rxd,
	output wire [1:0] db_func,
	output wire [7:0] db_cm3,
	output wire [7:0] db_cm2,
	output wire [7:0] db_cm1,
	output wire [7:0] db_cm0,
	output wire [8:0] db_bc,
	output wire db_utx,
	output wire db_txfull,
	output wire db_rtimeout
// *******************************************debug ports
*/
	 );


parameter UART_BAUD     = 433;  // To calculate caud rate -> UART_BAUD =  ( CLK_IN Hz / BAUDRATE ) - 1
parameter UART_RX_FIFO  = 512;
parameter UART_TX_FIFO  = 512;
parameter DEBUG_RST_ADR = 4096; // sets read/write address after a reset pulse
parameter DEBUG_TIMEOUT = 24;   // Time until a incomming command is flushed due to inactive com. Time in seconds = ( 2^DEBUG_TIMEOUT / CLK_IN Hz )
parameter ECHO_DATA     = 1;    // Echo all received characters back out the RS-232.

/*// *******************************************debug ports
assign db_rxd = ena_rxd_dly[0];//ena_rxd;
assign db_func = func;
assign db_cm3 = command[3*8+7:3*8];
assign db_cm2 = command[2*8+7:2*8];
assign db_cm1 = command[1*8+7:1*8];
assign db_cm0 = command[0*8+7:0*8];
assign db_bc  = byte_count;
assign db_utx = uart_tx;
assign db_txfull = uart_tx_full;
assign db_rtimeout = timeout_cnt[DEBUG_TIMEOUT];
// *******************************************debug ports
*/

reg [23:0] host_addr_reg = DEBUG_RST_ADR;
assign    host_addr[19:0]  = host_addr_reg[19:0];
wire [7:0] uart_rbyte;
wire      rxd_rdy;
reg       ena_rxd;
reg       [7:0]    ena_rxd_dly;
reg       timeout, h_lock;
reg       [31*8+7:0]  command;
reg       [1:0]      func;
reg       [28:0]     timeout_cnt;
reg       [2:0]      rd_cyc, tx_cyc;
reg       [8:0]      byte_count;
reg                  uart_tx;
wire                 uart_tx_full;
reg       [3:0]      rst_clk;
reg       [7:0]      uart_tbyte;

rs232_io  rs232_com ( .rst(rst),
					.clk(clk),
					.txd(txd),
					.rxd(rxd),
					.ena_txd(uart_tx),
					.tx_data(uart_tbyte),
					.tx_full(uart_tx_full),
					.rxd_rdy(rxd_rdy),
					.ena_rxd(ena_rxd),
					.rx_data(uart_rbyte) );
	defparam
		rs232_com.UART_BAUD    = UART_BAUD,
		rs232_com.UART_RX_FIFO = UART_RX_FIFO,
		rs232_com.UART_TX_FIFO = UART_TX_FIFO;


always @ (posedge clk) begin

soft_rst <= ~rst_clk[3] ;
if (~rst_clk[3]) begin 
				rst_clk <= rst_clk + 1;
end else begin

if (rst) begin
		host_addr_reg   <= DEBUG_RST_ADR ;
		host_wr_ena     <= 0 ;
		ena_rxd_dly     <= 0 ;
		command[31*8+7:0]         <= 0 ;
		h_lock          <= 0 ;
		timeout_cnt     <= 0 ;
		rd_cyc  		<= 7 ;
		tx_cyc  		<= 7 ;
		func            <= 0 ;
		uart_tx			<= 0 ;
		end else begin


// ***********  generate a single character ena_rxd pulse for the read fifo, once only every 8 clocks
			if (rxd_rdy && rd_cyc[2:0]==0 && func[1:0]!=1) begin
			ena_rxd <= 1;
			rd_cyc  <= 7;
			end else begin
			ena_rxd <= 0;
			if ( rd_cyc[2:0]!=0 ) rd_cyc <= rd_cyc - 1;
			end

// *** setup a delayed pipe for the read strobe ena_rxd allowing the read fifo contents to be made ready
			ena_rxd_dly[0]    <=  ena_rxd ;
			ena_rxd_dly[7:1]  <=  ena_rxd_dly[6:0] ;


if (func[1:0]==0) begin

					if (ena_rxd_dly[2]) uart_tbyte    <= uart_rbyte ;

						//if (ECHO_CMD) begin
						//if (ena_rxd_dly[3])   uart_tx <= 1;    // echo back received characters
						//else                  uart_tx <= 0;
						//end // if ECHO

		if (ena_rxd_dly[7]) begin  // fill the incomming command pipe.
							command[7:0]         <= uart_rbyte;
							command[31*8+7:8]    <= command[30*8+7:0];
							end

if (command[31*8+7:24*8] == 64'h0 && command[23*8+7:16*8]==command[15*8+7:8*8]  &&  command[15*8+7:8*8]==command[7*8+7:0*8]  )begin

				if  ( command[7*8+7:4*8] == 32'h52656164 ) begin  // read host ram and transmit to RS232
													byte_count[8]       <= 0;
													byte_count[7:0]     <= command[7:0];
													host_addr_reg[23:0] <= command[8+23:8];
													func                <= 1;
													tx_cyc			    <= 0;
													command[31*8+7:0]   <= 0;

		end else if ( command[7*8+7:4*8] == 32'h57726974 ) begin    // Read RS232 data and write into host ram.
													byte_count[8]       <= 0;
													byte_count[7:0]     <= command[7:0];
													host_addr_reg[23:0] <= command[8+23:8];
													func                <= 2;
													command[31*8+7:0]   <= 0;
													timeout_cnt         <= 0;  // clear recieve abort timeout counter

		end else if ( command[7*8+7:0*8] == 64'h52657365744E6F77  ) begin    // Software system wide external reset trigger
													rst_clk             <= 0;
													func                <= 0;
													command[31*8+7:0]   <= 0;

		end 
	end // Command verification.

end // all of func[1:0]==0


	if (func[1:0]==1) begin   // read host ram and transmit to RS232
			if (~byte_count[8]) begin  //  keep on transmitting until byte counter elapses

			if (~(uart_tx_full && tx_cyc==0)) begin
				tx_cyc <= tx_cyc + 1;
					if (tx_cyc==2) uart_tbyte <= host_rdata;
					if (tx_cyc==3) uart_tx <= 1;
					else           uart_tx <= 0;
					if (tx_cyc==5) host_addr_reg   <= host_addr_reg + 1;
					if (tx_cyc==5) byte_count      <= byte_count - 1;
				end

			end else begin
			func    <= 0;
			uart_tx <= 0;
			end
	end

	if (func[1:0]==2) begin  // Read RS232 data and write into host ram.
			if (~byte_count[8] && ~timeout_cnt[DEBUG_TIMEOUT] ) begin  //  keep on transmitting until byte counter elapses, or the timeout counter has reached it's end

					if (ena_rxd_dly[2]) timeout_cnt <= 0; // If a character is received, reset the timeout counter
					else timeout_cnt <=timeout_cnt +1;    // when not receiving characters, increment the timeout counter

					if (ena_rxd_dly[2]) host_wdata    <= uart_rbyte ;
					if (ena_rxd_dly[2]) uart_tbyte    <= uart_rbyte ;
					if (ena_rxd_dly[3])   host_wr_ena <= 1;
					else                  host_wr_ena <= 0;
						if (ECHO_DATA) begin
						if (ena_rxd_dly[3])   uart_tx <= 1;    // echo back received characters
						else                  uart_tx <= 0;
						end // if ECHO
					if (ena_rxd_dly[6]) host_addr_reg   <= host_addr_reg + 1;
					if (ena_rxd_dly[6]) byte_count      <= byte_count - 1;

			end else begin
			func <= 0;
			host_wr_ena   <= 0;
			byte_count[8] <= 1;
			end
	end	



 end // !rst

end // !soft_rst
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

serial_rx   rxd_comp (	.rst(rst),
					.clk(clk),
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

serial_tx   txd_comp (	.rst(rst),
					.clk(clk),
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

module serial_rx ( clk, rst, rx, rd_req,
                    empty, data, rx_start, tx_sync, tick, active ) ;

parameter RX_FIFO_SIZE = 16 ;
parameter RX_BAUD      = 1084 ;

input              clk, rst ;
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
		scfifo_component.intended_device_family = "Cyclone II",
		scfifo_component.lpm_numwords = RX_FIFO_SIZE,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = 8,
		//scfifo_component.lpm_widthu = 4,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";   // use off for small numbers

// ***************************************************************************************


always @ (posedge clk) begin

//if (ena_baud) period <= baud ;

rxd      <= rx;
rx_start <= (rxd & ~rx) & ~active;

if ( rx_start ) begin
						active     <= 1;
						position   <= 0;
						p_counter  <= (RX_BAUD/2); // 2; corrects reading alignment
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

module serial_tx ( clk, rst, ena_tx, data, rx_frame,
                    tx, full, sync, tick, active ) ;

parameter TX_FIFO_SIZE = 16 ;
parameter TX_BAUD      = 1084 ;

input              clk, rst ;
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
