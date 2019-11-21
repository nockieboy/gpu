module rs232_debugger (

    input  wire clk,

    input  wire rst,
	output reg  cmd_rst,   // When sent by the debugger utility, this output pulses for 8 clock cycles

    input  wire rxd,
    output wire txd,
	output reg         LED_txd,
	output reg         LED_rxd,

	output reg         host_rd_req,
	output reg         host_wr_ena,
	output wire [23:0] host_addr,
	output reg  [7:0]  host_wdata,
	input  wire [7:0]  host_rdata,
	
	input  wire [7:0]  in0,
	input  wire [7:0]  in1,
	input  wire [7:0]  in2,
	input  wire [7:0]  in3,
	output reg  [7:0]  out0,
	output reg  [7:0]  out1,
	output reg  [7:0]  out2,
	output reg  [7:0]  out3
	
	);


parameter CLK_IN_HZ    = 50000000;
parameter BAUD_RATE    = 921600;
parameter RX_PERIOD    = (CLK_IN_HZ / BAUD_RATE) -1 ;
parameter TX_PERIOD    = (CLK_IN_HZ / BAUD_RATE) -1 ;
parameter DEBUG_RST_ADR = 0;	// sets read/write address after a reset pulse
parameter DEBUG_TIMEOUT = 24;   // Time until a incomming command is flushed due to inactive com. Time in seconds = ( 2^DEBUG_TIMEOUT / CLK_IN Hz )
parameter LED_HOLD_TIME = 24;   // Keep the LED_rxd/txd signal high for this amount of time during a RXD/TXD transaction. Time in seconds = ( 2^LED_HOLD_TIME / CLK_IN Hz )

localparam ECHO_DATA = 1 ;		// For write verify, this features echoing the writen data back out of the RS232 port.


reg [23:0] host_addr_reg    = DEBUG_RST_ADR;       // Used to assign a power-up default
assign     host_addr[23:0]  = host_addr_reg[23:0];
wire [7:0] uart_rbyte;
wire       rxd_rdy;
reg        ena_rxd;
reg        [4:0]    ena_rxd_dly;
reg        timeout, h_lock;
reg        [15*8+7:0]  command;
reg		   [3:0]       command_00_cnt;
reg		   [3:0]       command_FF_cnt;
reg        [1:0]      func;
reg        [DEBUG_TIMEOUT:0]     timeout_cnt;
reg        [LED_HOLD_TIME:0]     led_txd_timeout, led_rxd_timeout;
reg        [3:0]      tx_cyc;
reg        [8:0]      byte_count;
reg                   uart_tx;
wire                  uart_tx_full;
reg        [3:0]      rst_clk;
reg        [7:0]      uart_tbyte;
reg                   rxd_reg;
reg		   [7:0]	  in_reg0,in_reg1,in_reg2,in_reg3;


rs232_transceiver  rs232_io (	.clk(clk),
								.rst(rst),
								.rxd(rxd),
								.txd(txd),

								.rx_data(uart_rbyte),
								.rx_rdy(rxd_rdy),

								.ena_tx(uart_tx),
								.tx_data(uart_tbyte),
								.tx_busy(uart_tx_full) );
	defparam
		rs232_io.CLK_IN_HZ    = CLK_IN_HZ,
		rs232_io.BAUD_RATE    = BAUD_RATE,
		rs232_io.TX_PERIOD    = TX_PERIOD,
		rs232_io.RX_PERIOD    = RX_PERIOD ;


always @ (posedge clk) begin


// ******************************************************************
// ****** Generate a status activity RXD and TXD led driver output.
// ****** This routine keeps the LED outputs on long enough to
// ****** visibly see as the data bursts are too short to be seen.
// ******************************************************************
	if (~txd) led_txd_timeout<=0;
	else if (~led_txd_timeout[LED_HOLD_TIME]) led_txd_timeout<=led_txd_timeout+1;
	LED_txd <= ~led_txd_timeout[LED_HOLD_TIME];

	rxd_reg <= rxd;  // Personal preference, I prefer that a input pin doesn't directly feed combinational logic, so I clock register that input
	if (~rxd_reg) led_rxd_timeout<=0;
	else if (~led_rxd_timeout[LED_HOLD_TIME]) led_rxd_timeout<=led_rxd_timeout+1;
	LED_rxd <= ~led_rxd_timeout[LED_HOLD_TIME];
// ******************************************************************
// ******************************************************************


// *** Generate an 8 clock wide reset pulse
cmd_rst <= ~rst_clk[3] ;
if (~rst_clk[3]) begin 
				rst_clk <= rst_clk + 1;
end else begin

if (rst) begin
		host_addr_reg   <= DEBUG_RST_ADR ;
		host_wr_ena     <= 0 ;
		ena_rxd_dly     <= 0 ;
		command[15*8+7:0]         <= 0 ;
		h_lock          <= 0 ;
		timeout_cnt     <= 0 ;
		tx_cyc  		<= 15 ;
		func            <= 0 ;
		uart_tx			<= 0 ;
		end else begin


// *** setup a delayed pipe for the read strobe ena_rxd allowing the read fifo contents to be made ready
			ena_rxd_dly[0]    <=  rxd_rdy ;
			ena_rxd_dly[4:1]  <=  ena_rxd_dly[3:0] ;


if (func[1:0]==0) begin
			host_rd_req <= 0;
			host_wr_ena <= 0;
			
					if (ena_rxd_dly[4]) uart_tbyte    <= uart_rbyte ;

		if (ena_rxd_dly[3]) begin  // Note we are using the ena_rxd_dly[2] since the write ram function will begin filling the write enable too early if the function comes in before the write pulse
							command[7:0]         <= uart_rbyte;
							command[15*8+7:8]    <= command[14*8+7:0];

							if ( command[15*8+7:15*8]==8'h00 ) 		command_00_cnt <= command_00_cnt + (command_00_cnt!=7);
							else 									command_00_cnt <= 0;
							if ( command[15*8+7:15*8]==8'hFF )		command_FF_cnt <= command_FF_cnt + (command_FF_cnt!=7);
							else if ( command[15*8+7:15*8]!=8'h00 )	command_FF_cnt <= 0;

							end

if ( command_00_cnt==6 && command_FF_cnt==2 &&  command[15*8+7:8*8]==command[7*8+7:0*8]  )begin

				if  ( command[7*8+7:4*8] == 32'h52656164 ) begin  // read host ram and transmit to RS232
													byte_count[8]       <= 0;
													byte_count[7:0]     <= command[7:0];
													host_addr_reg[23:0] <= command[8+23:8];
													func                <= 1;
													tx_cyc			    <= 0;
													command[15*8+7:0]   <= 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

		end else if ( command[7*8+7:4*8] == 32'h57726974 ) begin    // Read RS232 data and write into host ram.
													byte_count[8]       <= 0;
													byte_count[7:0]     <= command[7:0];
													host_addr_reg[23:0] <= command[8+23:8];
													func                <= 2;
													command[15*8+7:0]   <= 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
													timeout_cnt         <= 0;  // clear recieve abort timeout counter

		end else if ( command[7*8+7:0*8] == 64'h52657365744E6F77  ) begin    // Software system wide external reset trigger
													rst_clk             <= 0;
													func                <= 0;
													command[15*8+7:0]   <= 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

		end else if ( command[7*8+7:4*8] == 32'h53657450		  ) begin    // Set the general purpose output ports and read general purpose input ports
													out0				<= command[3*8+7:3*8];
													out1				<= command[2*8+7:2*8];
													out2				<= command[1*8+7:1*8];
													out3				<= command[0*8+7:0*8];
													// *** Parallel register input debug ports.
													in_reg0 <= in0;
													in_reg1 <= in1;
													in_reg2 <= in2;
													in_reg3 <= in3;

													byte_count[8]       <= 0;
													byte_count[7:0]     <= 3;
													func                <= 3;
													tx_cyc			    <= 0;
													command[15*8+7:0]   <= 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;


		end 
	end // Command verification.

end // all of func[1:0]==0


	if (func[1:0]==1) begin   // read host ram and transmit to RS232
			if (~byte_count[8]) begin  //  keep on transmitting until byte counter elapses

			if (~(uart_tx_full && tx_cyc==0)) begin
				tx_cyc <= tx_cyc + 1;
					if (tx_cyc==0) host_rd_req <= 1;		// pulse the host_rd_req with the current valid address
					else           host_rd_req <= 0;
					if (tx_cyc==13) uart_tbyte <= host_rdata; // expect the returned data ready within 12 clock cycles, and latch that data into the RS232 transmitter data input register
					if (tx_cyc==14) uart_tx <= 1;			  // Pulse the RS232 transmitter.
					else            uart_tx <= 0;
					if (tx_cyc==15) host_addr_reg   <= host_addr_reg + 1;
					if (tx_cyc==15) byte_count      <= byte_count - 1;
				end

			end else begin
			func        <= 0;
			uart_tx     <= 0;
			host_rd_req <= 0;
			end
	end

	if (func[1:0]==2) begin  										   // Read RS232 data and write into host ram.
			if (~byte_count[8] && ~timeout_cnt[DEBUG_TIMEOUT] ) begin  //  keep on reading from RS232 until byte counter elapses, or the timeout counter has reached it's end

					if (ena_rxd_dly[0]) timeout_cnt <= 0;              // If a character is received, reset the timeout counter
					else                timeout_cnt <= timeout_cnt +1; // when not receiving characters, increment the timeout counter

					if (ena_rxd_dly[0]) host_wdata    <= uart_rbyte ;
					if (ena_rxd_dly[0]) uart_tbyte    <= uart_rbyte ;

					if (ena_rxd_dly[1])   host_wr_ena <= 1;
					else                  host_wr_ena <= 0;

					if (ena_rxd_dly[1])   uart_tx <= 1;					// echo back received characters
					else                  uart_tx <= 0;

					if (ena_rxd_dly[3]) host_addr_reg   <= host_addr_reg + 1;
					if (ena_rxd_dly[3]) byte_count      <= byte_count - 1;

			end else begin
			func <= 0;
			host_wr_ena   <= 0;
			byte_count[8] <= 1;
			end
	end	



	if (func[1:0]==3) begin   // read general purpose input ports and transmit to RS232
			if (~byte_count[8]) begin  //  keep on transmitting until byte counter elapses

			if (~(uart_tx_full && tx_cyc==0)) begin
				tx_cyc <= tx_cyc + 1;

					if (tx_cyc==13) begin
						if (byte_count==3) uart_tbyte	<= in_reg0;
						else if (byte_count==2) uart_tbyte	<= in_reg1;
						else if (byte_count==1) uart_tbyte	<= in_reg2;
						else if (byte_count==0) uart_tbyte	<= in_reg3;
					end

					if (tx_cyc==14) uart_tx <= 1;			  // Pulse the RS232 transmitter.
					else            uart_tx <= 0;
					if (tx_cyc==15) byte_count      <= byte_count - 1;
				end

			end else begin
			func        <= 0;
			uart_tx     <= 0;
			host_rd_req <= 0;
			end
	end


 end // !rst

end // !soft_rst
end // always

endmodule



// *****************************************************************
// *** Synchronous RS232 Tranceiver.
// *** This transmitter follows slight baud timing errors introduced
// *** by the external host interface's clock making the TDX output
// *** clock timing synchronize to the RXD comming in allowing
// *** high speed synchronous communications.  A requirement
// *** for PC RS232 full duplex synchronous communications.
// ***
// *** Written by Brian Guralnick.
// *** Using generic Verilog code with only uses synchronous logic.
// *** Well comented for educational purposes.
// *****************************************************************

module rs232_transceiver ( 
	input  wire       clk,
	input  wire       rst,
	input  wire       rxd,
	output reg  [7:0] rx_data,
	output reg        rx_rdy,
	
	input  wire       ena_tx,
	input  wire [7:0] tx_data,
	output reg        txd,
	output reg        tx_busy
  ) ;

// Setup parameters
parameter CLK_IN_HZ    = 50000000;
parameter BAUD_RATE    = 921600;
parameter RX_PERIOD    = (CLK_IN_HZ / BAUD_RATE) -1 ;
parameter TX_PERIOD    = (CLK_IN_HZ / BAUD_RATE) -1 ;

// Receiver regs
reg     [15:0]     rx_period ;
reg     [3:0]      rx_position ;
reg     [9:0]      rx_byte;
reg                rxd_reg, last_rxd;
reg				   rx_busy, rx_last_busy;

// Transmitter regs
reg     [15:0]     tx_period   = 16'h0;
reg     [3:0]      tx_position = 4'h0;
reg     [9:0]      tx_byte     = 10'b1111111111;
reg     [7:0]      tx_data_reg = 8'b11111111;
reg                tx_run      = 0;

wire    rx_trigger ; // make the rx_trigger 'WIRE' equal to any new RXD input High to Low transition (IE start bit) when the reciever is not busy receiving a byte
assign  rx_trigger             = (~rxd_reg && last_rxd && ~rx_busy);


always @ (posedge clk) begin

//********************************
// Receiver functions.
//********************************

// register clock the UART RDX input signal.  This is a personal preference as I prefer FPGA inputs which dont directly feed combinational logic
rxd_reg         <= rxd;
last_rxd		<= rxd_reg;  // create a 1 clock delay register of the rxd_reg serial bit

rx_last_busy	<= rx_busy;						// create a 1 clock delay of the rx_busy resister.
rx_rdy			<= rx_last_busy && ~rx_busy;    // create the rx_rdy out pulse for 1 single clock when the rx_busy flag has gone low signifying that rx_data is ready

if ( rx_trigger )	begin						  // if a 'rx_trigger' event has taken place
			rx_period	   <= ( RX_PERIOD >> 1 ) ; // set the period clock to half way inside a serial bit.  This makes the best time to sample incomming
												  // serial bits as the source baud rate may be slightly slow or fast maintaining a good data capture window all the way until the stop bit
			rx_busy        <= 1 ;				  // set the rx_busy flag to signify opperation of the UART serial receiver
			rx_position    <= 9 ;                 // set the serial bit counter to position 9
	end else begin
	
	if ( rx_period==0 ) begin					 // if the receiver period counter has reached it's end
		rx_period		<=  RX_PERIOD  ;		 // reset the period counter
		
				if ( rx_position != 0 ) begin	// if the receiver's bit position counter hasn't reached it's end
					rx_position   <= rx_position - 1 ;	// decrement the position counter
					rx_byte[9]    <= rxd_reg ;			// load the receiver's serial shift regitser with the RXD input pin
					rx_byte[8:0]  <= rx_byte[9:1] ;		// shift the input serial shift register.

				end else begin						// if the receiver's bit position counter reached 0
					rx_data	  	  <= rx_byte[9:2];  // load the output data register with the correct 8 bit contents of the serial input register
					rx_busy		  <= 0;				// turn off the serial receiver busy flag
				end

			end else begin						// if the receiver period counter has not reached it's end
					rx_period <= rx_period - 1; // just decrement the receiver period counter
					end
end // ~rx_trigger



//***********************************************************
// SYNCHRONOUS! Transmitter functions
//              This was the most puzzling to get just right
//              So that both high and low speed intermittent
//              and contineous COM transactions would never
//              cause a byte error when communicating with
//              a PC as fast as possible.
//***********************************************************

		if (ena_tx) begin			        // If a write request comes in
		tx_data_reg    <= tx_data ;			// register a copy of the input dara bus
		tx_busy        <= 1 ;				// Set the busy flag
		end

// ***********************************************************************************************************************
// This section prepares the data, controls and shift register during the middle of the previous transmition bit.
// ***********************************************************************************************************************
if ( tx_period == (TX_PERIOD >> 1) ) begin  // at the center of a sreial transmiter bit
			if ( tx_position==1 ) begin      // during the transmition of a stop bit
					tx_run          <= 0;    // turn off the transmitter running flag.  This point is the beginning of when
											 // a synchronous transmit word alignment to an incommint RXD rx_trigger is permitted

					if (tx_busy) begin					 // before the next start bit, if the busy flag was set,
					tx_byte[8:1]	<= tx_data_reg[7:0]; // load the register copy of the tx_data_reg into the serial shift register
					tx_byte[9]		<= 1;                // Add a stop bit into the shift register's 10th bit
					tx_byte[0]		<= 0;                // Add a start bit into the serial shift register's first bit
					tx_busy			<= 0;                // Turn off the busy flag signifying that another transmit byte may be loaded
					end									 // into the tx_data_reg

			end else begin
					tx_byte[8:0] <= tx_byte[9:1];		// at any other point than the stop-bit period, shift the serial tx_byte shift register
					tx_byte[9]   <= 1;                  // load a default stop bit into bit 10 of the serial shift register
					if ( tx_position == 0 ) begin       // during the 'center of a sreial 'START' transmiter bit'
					tx_run  <= ~txd;					// if the serial UART TXD output pin has a start bit, turn on the transmitter running flag
					end									// which signifies the point where it is no longer permitable to align a transmit word
			end											// to an incomming RXD byte potentially corrupting a serial transmition.
end


// ***********************************************************************************************************************
// This section takes the aboved prepared registers and sends them out during the transition edge of the tx_period clock
// and during inactivity, or during the permitted alignment window, it will re-align the transmition period clock to
// a potential incomming rx_trigger event.
// ***********************************************************************************************************************
// if a RXD start bit transition edge is detected and the transmitter is not running, IE during the safe synchronous transmit word alignment period
if (  rx_trigger && ~tx_run ) begin			// set above halfway between the center of transmitting the stop bit and next start bit 
	tx_period		<= TX_PERIOD ;			// reset the period counter
	tx_position		<= 0;					// force set the transmit reference position to the start bit
	txd				<= tx_byte[0];			// immediately set the UART TXD output to the serial out shift register's start bit.  IE see above if(tx_busy)

	end else if ( tx_period==0  )begin		// if the transmitter period counter has reached it's end
		tx_period		<= TX_PERIOD ;		// reset the period counter
		txd 			<= tx_byte[0];		// set the UART TXD output to the serial shift register's ooutput.

		if ( tx_position == 0 ) tx_position  <= 9 ;				 // if the transmitter reference bit position counter is at the start bit, set it to bit 1.
		else					tx_position  <= tx_position -1 ; // otherwire, count down the position counter towards the stop bit

	end else tx_period <= tx_period - 1;	// if the transmit period has not reached it's end, it should count down.

end // always

endmodule
