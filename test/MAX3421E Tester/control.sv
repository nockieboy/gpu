/*
 * Simple USB interface control module to test the MAX3421E USB HOST chip
 *
 * J.Nock 2021
 *
 * KEY1 = Check connection status of USB device, displays HRSL byte
 * KEY2 = Display HIRQ & HRSL bytes on 7-segments
 * KEY3 = RESETS int_req & IRQ_err, displays HIEN byte on first 7-segment display, shows event flags on second 7-seg display:
 *
 *   VALUE   80       40        20        10         8         4         2        1  (HEX)
 *    BIT    7         6        5         4          3         2         1        0
 *        HXFRDNIR, FRAMEIR, CONDETIR, SUSPDNIR, SNDBAVIR, RCVDATIR, RSMREQIR, BUSEVTIR
 *
 * KEY4 = Sets int_req
 *
 *	LED1 = conn_LED - illuminates if USB device is connected
 *	LED2 = IRQ_err  - illuminates if unrecognised IRQ event
 *	LED3 = ~int_req - illuminates if int_req is HIGH
 *	LED4 = ~m_int   - illuminates if an INTerrupt is requested by MAX3421E
 *
 * MAX3421E Registers in HOST mode. Pre-shifted left three places to account
 * for the 3421E command byte format: rrrrr0wa where 'r' is register number ,
 * 'w' is HIGH for write, LOW for read, 'a' is ignored and should always be 0.
 */

module control (

   input logic        clk,
   input logic        reset,     // active LOW
   input logic        gpx,
   input logic        m_int,
   input logic  [7:0] rx_data,
   input logic        done,
   input logic        KEY1,      // user buttons, active LOW
   input logic        KEY2,
   input logic        KEY3,
   input logic        KEY4,
   
   output logic       start,
   output logic [7:0] tx_data,
   
   output logic [7:0] SEG_1,     // EasyFPGA-specific 7-segment display to
   output logic [7:0] SEG_2,     // show read values from SPI
   output logic       LED_1,     // USB connection detection LED
	output logic       LED_2,     // not used
	output logic       LED_3,     // LOW when int_req is HIGH
	output logic       LED_4      // LOW when m_int is HIGH (shows if the MAX3421E is INTerrupting)

);
//
parameter int      MAX_CMDS                 = 32                ; // maximum command_queue length
parameter int      NUM_INIT_CMDS            = 2                 ; // no. of initial commands in queue
parameter int      INIT_CMDS[NUM_INIT_CMDS] = '{ 8'h00, 8'h00 } ;
parameter shortint NAK_LIMIT                = 200               ;
parameter byte     RETRY_LIMIT              = 3                 ;
//
// SPI command queue command values
localparam rHRSL      = 8'hF8 ; // Read  R31 HRSL register
localparam wHFXR      = 8'hF2 ; // Write R30 HFXR register
localparam rHFXR      = 8'hF0 ; // Read  R30 HFXR register
localparam rHCTL      = 8'hE8 ; // Read  R29 HCTL register
localparam rPERA      = 8'hE0 ; // Read  R28 PERADDR register
localparam wMODE      = 8'hDA ; // Write R27 MODE register
localparam rMODE      = 8'hD8 ; // Read  R27 MODE register
localparam rHIEN      = 8'hD0 ; // Read  R26 HIEN register
localparam wHIRQ      = 8'hCA ; // Write R25 HIRQ register
localparam rHIRQ      = 8'hC8 ; // Read  R25 HIRQ register
localparam wIOP2      = 8'hAA ; // Write R21 IOPINS2 register
localparam rIOP2      = 8'hA8 ; // Read  R21 IOPINS2 register
localparam wIOP1      = 8'hA2 ; // Write R20 IOPINS1 register
localparam rIOP1      = 8'hA0 ; // Read  R20 IOPINS1 register
localparam rREVISION  = 8'h90 ; // Read  R18 REVISION register
localparam wUSBCTL    = 8'h7A ; // Write R15 USBCTL register
localparam rUSBCTL    = 8'h78 ; // Read  R15 USBCTL register
localparam wUSBIEN    = 8'h72 ; // Write R14 USBIEN register
localparam rUSBIEN    = 8'h70 ; // Read  R14 USBIEN register
localparam wUSBIRQ    = 8'h6A ; // Write R13 USBIRQ register
localparam rUSBIRQ    = 8'h68 ; // Read  R13 USBIRQ register
localparam wSNDFIFO   = 8'h12 ; // Write R2 SNDFIFO register
localparam rRCVFIFO   = 8'h08 ; // Read  R1 RCVFIFO register
//
// Host error result codes, the 4 LSB's in the HRSL register.
localparam hrSUCCESS  = 8'h00 ;
localparam hrBUSY     = 8'h01 ;
localparam hrBADREQ   = 8'h02 ;
localparam hrUNDEF    = 8'h03 ;
localparam hrNAK      = 8'h04 ;
localparam hrSTALL    = 8'h05 ;
localparam hrTOGERR   = 8'h06 ;
localparam hrWRONGPID = 8'h07 ;
localparam hrBADBC    = 8'h08 ;
localparam hrPIDERR   = 8'h09 ;
localparam hrPKTERR   = 8'h0A ;
localparam hrCRCERR   = 8'h0B ;
localparam hrKERR     = 8'h0C ;
localparam hrJERR     = 8'h0D ;
localparam hrTIMEOUT  = 8'h0E ;
localparam hrBABBLE   = 8'h0F ;
//
// Host XFR token values for writing the HXFR register (R30).
// OR this bit field with the endpoint number in bits 3:0
localparam tokSETUP   = 8'h10 ; // HS=0, ISO=0, OUTNIN=0, SETUP=1
localparam tokIN      = 8'h00 ; // HS=0, ISO=0, OUTNIN=0, SETUP=0
localparam tokOUT     = 8'h20 ; // HS=0, ISO=0, OUTNIN=1, SETUP=0
localparam tokINHS    = 8'h80 ; // HS=1, ISO=0, OUTNIN=0, SETUP=0
localparam tokOUTHS   = 8'hA0 ; // HS=1, ISO=0, OUTNIN=1, SETUP=0 
localparam tokISOIN   = 8'h40 ; // HS=0, ISO=1, OUTNIN=0, SETUP=0
localparam tokISOOUT  = 8'h60 ; // HS=0, ISO=1, OUTNIN=1, SETUP=0
//
logic [7:0] rx_buff1  = 8'b0 ;
logic [7:0] rx_buff2  = 8'b0 ;
logic       buff_ff   = 1'b0 ; // when buff_ff is HIGH, record Rx'd data - this ignores data Rx'd (STATUS) during CMD transmission
logic [5:0] cur_cmd   = 6'b0 ; // current command in pipeline
logic       old_done  = 1'b0 ; // edge-detect for done signal
logic       tx_done   = 1'b1 ; // tx_done flag so commands are only sent once
//
logic [7:0]  maxPktSiz    = 8'b0  ; // filled in by Get_Descriptor request during enumeration
logic [15:0] VID          = 16'b0 ;
logic [15:0] PID          = 16'b0 ;
logic [15:0] nak_count    = 16'b0 ;
logic [15:0] IN_nak_count = 16'b0 ;
logic [15:0] HS_nak_count = 16'b0 ;
//
logic       old_int   = 1'b0 ;
logic       old_K1    = 1'b0 ;
logic       old_K2    = 1'b0 ;
logic       old_K3    = 1'b0 ;
logic       old_K4    = 1'b0 ;
//
logic [7:0] cmd_queue[0:(MAX_CMDS-1)] ;
logic [5:0] num_queue = 6'b0 ; // maximum 64 commands in num_queue (may be more restricted by MAX_CMDS)
//
logic       int_req   = 1'b0 ;
logic       conn_LED  = 1'b1 ; // LOW to light LED for connection events
logic       IRQ_err   = 1'b1 ; // HIGH when unrecognised IRQ event
logic       rd_req    = 1'b0 ; // Read Request flag - HIGH when waiting for a value from SPI in multi-stage process
logic       SPI_BUSY  = 1'b0 ; // HIGH when SPI is transmitting
logic       CHK_USB   = 1'b0 ; // HIGH when waiting for HRSL result to see if USB device is plugged in
logic       INIT_DONE = 1'b0 ; // HIGH once initialisation is complete
//
logic       KEY1_flag = 1'b0 ; // Set HIGH to service Key1 press
logic       KEY2_flag = 1'b0 ; // Set HIGH to service Key2 press
logic       KEY3_flag = 1'b0 ; // Set HIGH to service Key3 press
logic       KEY4_flag = 1'b0 ; // Set HIGH to service Key4 press
//
// INTERRUPT REQUEST FLAGS
//
logic       HXFRDNIR  = 1'b0 ; // Host Transfer Done IRQ
logic       FRAMEIR   = 1'b0 ; // Frame Generator IRQ
logic       SUSPDNIR  = 1'b0 ; // SUSPend operation DoNe IRQ
logic       CONDETIR  = 1'b0 ; // CONnection DETection IRQ
logic       SNDBAVIR  = 1'b0 ; // Send Buffer Available IRQ
logic       RCVDATIR  = 1'b0 ; // Receive FIFO Data Available IRQ
logic       RSMREQIR  = 1'b0 ; // Remote Wakeup IRQ
logic       BUSEVTIR  = 1'b0 ; // Bus Event IRQ
//
wire        int_edge  = ~old_int && m_int ; // int_req goes HIGH on posedge of m_int
wire        KEY1_edge = old_K1 && !KEY1   ;
wire        KEY2_edge = old_K2 && !KEY2   ;
wire        KEY3_edge = old_K3 && !KEY3   ;
wire        KEY4_edge = old_K4 && !KEY4   ;
//
integer i ;
//
always @( posedge clk ) begin

	// dual 7-segment value display
	SEG_1   <= rx_buff1 ;
	SEG_2   <= rx_buff2 ;
	// debug LEDS
	LED_1   <= conn_LED ; // Devboard LED1 - illuminates if USB device is connected
	LED_2   <= IRQ_err  ; // Devboard LED2 - illuminates if unrecognised IRQ event
	LED_3   <= ~int_req ; // Devboard LED3 - illuminates if int_req is HIGH
	LED_4   <= ~m_int   ; // Devboard LED4 - illuminates if an INTerrupt is requested by MAX3421E
	// edge detectors
	old_int <= m_int    ; // update m_int edge detector
	old_K1  <= KEY1     ; // KEY1 edge detector
	old_K2  <= KEY2     ; // KEY2 edge detector
	old_K3  <= KEY3     ; // KEY3 edge detector
	old_K4  <= KEY4     ; // KEY4 edge detector
 
	if ( !reset || !gpx ) begin
	
		old_done    <= 1'b0 ;
      rx_buff1    <= 8'b0 ;
      rx_buff2    <= 8'b0 ;
      cur_cmd     <= 6'b0 ;
      tx_done     <= 1'b0 ;
      tx_data     <= 8'b0 ;
      start       <= 1'b0 ;
		KEY1_flag   <= 1'b0 ;
		KEY2_flag   <= 1'b0 ;
		KEY3_flag   <= 1'b0 ;
		KEY4_flag   <= 1'b0 ;
		int_req     <= 1'b0 ;
		CONDETIR    <= 1'b0 ;
		conn_LED    <= 1'b1 ;
		rd_req      <= 1'b0 ;
		IRQ_err 		<= 1'b1 ;
		INIT_DONE   <= 1'b0 ;
		CHK_USB     <= 1'b0 ;
		SPI_BUSY    <= 1'b0 ;
	
	end else if ( int_edge ) int_req <= 1'b1 ; // interrupt posedge detected
	//
	else if ( KEY1_edge ) KEY1_flag <= 1'b1 ;
	else if ( KEY2_edge ) KEY2_flag <= 1'b1 ;
	else if ( KEY3_edge ) KEY3_flag <= 1'b1 ;
	else if ( KEY4_edge ) KEY4_flag <= 1'b1 ;
	//
	else if ( !INIT_DONE && gpx) begin	
	
		// copy INIT_CMDS into the command queue
		for (i = 0; i < NUM_INIT_CMDS; i = i + 1) begin
			cmd_queue[i] <= INIT_CMDS[i][7:0];
		end
      num_queue   <= NUM_INIT_CMDS ; // set num_queue to INIT_CMDS array length
      cur_cmd     <= 6'b0 ;
      tx_done     <= 1'b0 ; // reset tx_done to allow cmd_queue to be transmitted
      SPI_BUSY    <= 1'b1 ; // SPI is busy sending the init_cmds queue
		INIT_DONE   <= 1'b1 ;
		CHK_USB     <= 1'b1 ; // Set CHK_USB flag to process result
	
   end else if ( KEY1_flag && !SPI_BUSY ) begin // KEY1 CHECK FOR USB DEVICE PRESENCE
		
		cmd_queue[0] <= rHRSL ; // Read R31 to get HRSL bits (result will end up in rx_buff1)
		cmd_queue[1] <= 8'h00 ;
		num_queue    <= 2     ; // # commands in the queue
      cur_cmd      <= 6'b0  ;
      tx_done      <= 1'b0  ;
		SPI_BUSY     <= 1'b1  ;
		CHK_USB      <= 1'b1  ; // Set CHK_USB flag to process result
		//
		KEY1_flag    <= 1'b0  ;
      
   end else if ( KEY2_flag && !SPI_BUSY ) begin // KEY2 READS HIRQ and HRSL
	
		cmd_queue[0] <= rHRSL ; // Read R31 to get HRSL bits (result will end up in rx_buff2)
		cmd_queue[1] <= 8'h00 ; // 
		cmd_queue[2] <= rHIRQ ; // Read R25 to get HIRQ bits (result will end up in rx_buff1)
      cmd_queue[3] <= 8'h00 ; // 
      num_queue    <= 4     ; // 4 commands in the queue
      cur_cmd      <= 6'b0  ;
      tx_done      <= 1'b0  ;
		SPI_BUSY     <= 1'b1  ; // SPI is busy sending cmd_queue
		//
		KEY2_flag    <= 1'b0  ;
	
	end else if ( KEY3_flag && !SPI_BUSY ) begin // KEY3 READS HIEN, DISPLAYS EVENT FLAGS, RESETS int_req & IRQ_err

		// aggregate event flags into rx_buff1 - these will end up in rx_buff2 after HIEN is retrieved below
		rx_buff1[7:0] <= { HXFRDNIR, FRAMEIR, CONDETIR, SUSPDNIR, SNDBAVIR, RCVDATIR, RSMREQIR, BUSEVTIR } ;
		cmd_queue[0]  <= rHIEN ; // Read R26 to get IE bits (result will end up in rx_buff1)
      cmd_queue[1]  <= 8'h00 ; // 
      num_queue     <= 2     ; // 2 commands in the queue
      cur_cmd       <= 6'b0  ;
      tx_done       <= 1'b0  ;
		int_req       <= 1'b0  ;
		IRQ_err 		  <= 1'b1  ;
		SPI_BUSY      <= 1'b1  ; // SPI is busy sending cmd_queue
		//
		KEY3_flag     <= 1'b0  ;
	
	end else if ( KEY4_flag && !SPI_BUSY ) begin // KEY4 Sets int_req
	 
		int_req      <= 1'b1  ;
		//
		KEY4_flag    <= 1'b0  ;
	
	end else if ( CHK_USB && !SPI_BUSY ) begin // result returned for CHK_USB in rx_buff1
	
		// Determine if a USB device is connected by checking JSTATUS & KSTATUS bits in the HRSL register
		if ( rx_buff1[7:6] == 2'b00 ) begin
			conn_LED  <= 1'b1  ; // Switch off the LED to show USB device was disconnected
		end
		else begin
			conn_LED  <= 1'b0  ; // Switch on the LED to show USB device was connected
		end
		CHK_USB <= 1'b0 ;
	
	end else if ( int_req && !SPI_BUSY ) begin // MAX3421E is requesting our attention and we're not transmitting on SPI
	
		// get HIRQ byte to work out type of interrupt,
		// and HRSL to decode connect/disconnect event		
		cmd_queue[0] <= rHRSL ; // Read R31 to get HRSL bits - result will end up in rx_buff2
		cmd_queue[1] <= 8'h00 ; // and be displayed on SEG_2
		cmd_queue[2] <= rHIRQ ; // Read R25 to get HIRQ bits - result will end up in rx_buff1
		cmd_queue[3] <= 8'h00 ; // and be displayed on SEG_1
		num_queue    <= 4     ; // 4 commands in the queue
		cur_cmd      <= 6'b0  ;
		tx_done      <= 1'b0  ; // send commands to SPI master module
		SPI_BUSY     <= 1'b1  ; // SPI is busy sending cmd_queue
		rd_req		 <= 1'b1  ; // set rd_req flag as we're waiting for a result
		int_req      <= 1'b0  ; // reset internal int_req flag
	
	end else if ( rd_req && !SPI_BUSY ) begin
		// rd_req is HIGH - HIRQ and HRSL have been returned in rx_buff1 and rx_buff2 respectively
		
		rd_req <= 1'b0 ; // reset rd_req flag
		
		if (rx_buff1[7]) begin // HXFRDNIRQ is set
			// Determine the result of the host transfer by
			//	reading the HSRLT bits in the HRSL register.
			HXFRDNIR <= 1'b1 ;
			IRQ_err  <= 1'b1 ;
		end
		
		if (rx_buff1[6]) begin // FRAMEIRQ is set
			// NOT SUPPORTED
			FRAMEIR  <= 1'b1 ;
			IRQ_err  <= 1'b0 ;
		end
		
		if (rx_buff1[5]) begin // CONDETIRQ is set
			// Set after a connection event is detected.
			CONDETIR <= 1'b1 ;
			IRQ_err  <= 1'b1 ;
		end
		
		if (rx_buff1[4]) begin // SUSDNIRQ is set
			// Set after 3ms of bus inactivity.
			SUSPDNIR <= 1'b1 ;
			IRQ_err  <= 1'b1 ;
		end
		
		if (rx_buff1[3]) begin // SNDBAVIRQ is set
			// Set when SNDFIFO tx'd and cleared, ACK received
			//	and no low-level errors detected in HRSLT bits.
			// DO NOT DIRECTLY CLEAR THIS BIT. Write to SNDBC
			// register instead to clear it.
			SNDBAVIR <= 1'b1 ;
			IRQ_err  <= 1'b1 ;
		end
		
		if (rx_buff1[2]) begin // RCVDAVIRQ is set
			// New peripheral data received in RCVFIFO as result
			// of a host IN request.  Need to read byte count in
			// RCVBC register, then do successive reads to the
			// RCVFIFO register (R1) to retrieve the data. Finally
			// clear the IRQ by writing a 1 to RCVDAVIRQ.
			RCVDATIR <= 1'b1 ;
			IRQ_err  <= 1'b1 ;
		end
		
		if (rx_buff1[1]) begin // RSMREQIRQ is set
			// Set when remote wakeup signal received from peripheral,
			// probably because it has data to send to the host.
			// (Think mouse, for example).
			RSMREQIR <= 1'b1 ;
			IRQ_err  <= 1'b1 ;
		end
		
		if (rx_buff1[0]) begin // BUSEVENTIRQ is set
			// Set when signalling BUSRST or BUSRSM is complete.
			BUSEVTIR <= 1'b1 ;
			IRQ_err  <= 1'b1 ;
		end
		 
	end else if ( CONDETIR && !SPI_BUSY ) begin // CONNection event and we're not transmitting on SPI

      CONDETIR     <= 1'b0  ; // reset CONDETIR flag
		// Determine if a connect or disconnect event by checking JSTATUS & KSTATUS bits in the HRSL register
		if ( rx_buff2[7:6] == 2'b00 ) begin
			conn_LED  <= 1'b1  ; // Switch off the LED to show USB device was disconnected
		end
		else begin
			conn_LED  <= 1'b0  ; // Switch on the LED to show USB device was connected
		end
      cmd_queue[0] <= wHIRQ ; // Write to R25
      cmd_queue[1] <= 8'h20 ; // Set CONDETIRQ HIGH to reset it
		cmd_queue[2] <= rHRSL ; // Read R31 to get HRSL bits (result will end up in rx_buff2)
		cmd_queue[3] <= 8'h00 ; // 
		cmd_queue[4] <= rHIRQ ; // Read R25 to get HIRQ bits (result will end up in rx_buff1)
		cmd_queue[5] <= 8'h00 ; // 
      num_queue    <= 6     ; // # cmnds to Tx
      cur_cmd      <= 6'b0  ;
      tx_done      <= 1'b0  ;
		SPI_BUSY     <= 1'b1  ; // SPI is busy sending cmd_queue
		
   end else begin // reset & gpx HIGH
	
      if ( old_done && !done ) begin // negedge detected for done signal - valid data on rx_data
			// Buffer RX'd data if done goes HIGH and buff_ff is HIGH
         if ( buff_ff ) begin
            rx_buff1 <= rx_data  ; // buffer the received data
            rx_buff2 <= rx_buff1 ;
         end
         buff_ff  <= !buff_ff ; // flip buff_ff for next rx'd byte
         if ( cur_cmd < num_queue ) begin
            tx_done <= 1'b0 ; // more cmds left, reset tx_done to send next byte
         end
         else begin // EOL
            tx_data  <= 8'b0 ; // end of transmission - last byte sent
            tx_done  <= 1'b1 ; // tx-done goes high to prevent more bytes being
            cur_cmd  <= 6'b0 ; // transmitted but everything else is reset
            start    <= 1'b0 ;
				SPI_BUSY <= 1'b0 ; // SPI is idle
         end
      end
      old_done <= done ;
		
      if ( !tx_done && ( cur_cmd < num_queue ) ) begin // if cmd hasn't been sent already and end of queue isn't reached
         tx_data[7:0] <= cmd_queue[cur_cmd][7:0] ;
         start        <= 1'b1                    ;
         tx_done      <= 1'b1                    ;
         cur_cmd      <= cur_cmd + 1'b1          ;
      end
      else if ( !tx_done && ( cur_cmd == num_queue ) ) begin // reached end of commands array
         tx_data <= 8'b0 ;
         start   <= 1'b0 ;
         cur_cmd <= 6'b0 ;
			tx_done <= 1'b1 ; // tx_done goes high to stop further bytes being sent
      end
      else begin
         start   <= 1'b0 ; // make start a one-clk pulse
      end
		
   end // reset & gpx HIGH
	
end

endmodule
