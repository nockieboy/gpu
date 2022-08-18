//`define  ENABLE_RS232_EDITOR                  // Enable this line to include the I2C RS232 terminal editor/monitor.
// ***************************************************************************************************************
// BHG_I2C_init_RS232_debugger.v   V1.0, August 2022.
// Create and debug an I2C startup sequence with an integrated RS232 terminal editor,
// then, optionally disable the RS232 leaving a minimal initialization HDL.
//
//
// Written by Brian Guralnick.
// https://github.com/BrianHGinc / or / https://www.eevblog.com/forum/fpga/ User BrianHG.
//
//
// For public use.  Just be fair and give credit where it is due.
// ***************************************************************************************************************

`ifdef ENABLE_RS232_EDITOR
`include "sync_rs232_uart.v" // Include the sync_rs232_uart.v source only if the ENABLE_RS232_EDITOR feature is enabled.
`endif

module BHG_I2C_init_RS232_debugger #(

      parameter            CLK_IN_KHZ   = 10000   , // Source  clk_in  frequency in KHz, typically at least 8x the desired I2C rate.  Recommend 25000-100000KHz.
      parameter            I2C_KHZ      = 100     , // Desired clk_out frequency in KHz, use 100, 400, or 1000.
      parameter            RS232_BAUD   = 921600  , // Desired RS232 baud rate.
      parameter bit        TRI_I2C_scl  = 0       , // 0=I2C_scl & data output is tri-stated when inactive. 1=I2C_scl is always output enabled.

      parameter            TX_TABLE_len                     = 1,              // Number of entries in table.
      parameter bit [16:0] TX_TABLE_data [0:TX_TABLE_len-1] = '{ 17'h1_0000 } // Contents of table.

  )(  input                clk_in                 , // System source clock.
      input                rst_in                 , // Synchronous reset.
      output reg           rst_out       = 0      , // I2C sequencer generated reset output option.
      output reg  [2:0]    I2C_ack_error = 3'd0   , // Goes high when the I2C slave device does not return an ACK.
      inout  wire          I2C_scl                , // I2C clock, bidirectional pin.
      inout  wire          I2C_sda                , // I2C data, bidirectional pin.
      input  wire          RS232_rxd              , // RS232 input, receive from terminal.
      output wire          RS232_txd                // RS232 output, transmit to terminal.
      );


reg                        I2C_scl_q  = 1'b1, I2C_sda_q  = 1'b1, I2C_sda_d = 1'b0 ;  // Generate 3-state IObuffers for the 2x I2C cmd lines.
reg                        I2C_scl_oe = TRI_I2C_scl, I2C_sda_oe = TRI_I2C_scl ;
assign                     I2C_scl    = I2C_scl_oe   ? I2C_scl_q   : 1'bz ;
assign                     I2C_sda   = I2C_sda_oe  ? I2C_sda_q  : 1'bz ;

localparam                 I2C_per_len_x10 = (CLK_IN_KHZ*10 / (I2C_KHZ*4))            ; // Calculate the desired period to achieve a 40x clock rate.
localparam                 plb             = $clog2((((I2C_per_len_x10+9) / 10) - 1)) ;
localparam       [plb-1:0] I2C_per_len     = (plb)'(((I2C_per_len_x10+9) / 10) - 1)    ; // We add the 9 then divide by 10 to make sure the fractional speed of the clock doesn't bleed slightly above the requested frequency.
reg              [plb-1:0] I2C_period      = I2C_per_len                              ; // Divider counter for I2C clock and sequencer program counter.
reg                        per_pulse       = 1'b0                                     ;

`ifdef ENABLE_RS232_EDITOR
localparam                 pcl             = 7 ; // Number of bits for the program counter when the RS232 port is enabled.
`else
localparam                 pcl             = 6 ; // Number of bits for the program counter.
`endif
reg              [pcl-1:0] seq_pc          = (pcl)'(0), seq_ret=(pcl)'(0), seq_ret2=(pcl)'(0) ;

localparam                 mst_bits        = $clog2(I2C_KHZ * 4)      ;
localparam  [mst_bits-1:0] mst_per         = (mst_bits)'(I2C_KHZ * 4) ; // Set the counter size for the microsecond delay timer.
reg                        mst_hold        = 1'b0                     ;
reg         [mst_bits-1:0] mst_cnt         = (mst_bits)'(0)           ;

localparam                 tpos_bits       = $clog2(TX_TABLE_len+1) ;
reg        [tpos_bits-1:0] tpos            = (tpos_bits)'(0)        ; // Set the counter size for the microsecond delay timer.



reg [7:0] I2C_da=8'h00,I2C_ra=8'h00,I2C_wd=8'h00,I2C_rd=8'h00,sr=8'h00,ms_cnt_len=8'd00,rr=8'd0;
reg       oe  = 1'd0;
reg [2:0] txl = 3'd0;

// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// Instantiate the BHG_I2C_RS232_handler HDL only if the ENABLE_RS232_EDITOR feature is enabled.
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************

`ifdef ENABLE_RS232_EDITOR

reg [pcl-1:0] seq_ret3   = (pcl)'(0) ;
reg           uart_tx    = 1'b0;
reg     [7:0] uart_tbyte = 8'd0;
wire          uart_rxd_rdy,uart_tx_full ; 
wire    [7:0] uart_rbyte ;
reg     [7:0] uart_rx = 8'd0 ;

sync_rs232_uart  # (.CLK_IN_HZ(CLK_IN_KHZ*1000),.BAUD_RATE(RS232_BAUD)
                )rs232_uart (   .clk(clk_in),
                                .rxd(RS232_rxd),        // Goes to RXD Input Pin
                                .txd(RS232_txd),        // Goes to TXD output pin

                                .rx_data(uart_rbyte),   // Received data byte
                                .rx_rdy(uart_rxd_rdy),  // 1 clock pulse high when the received data bit is ready

                                .ena_tx(uart_tx && !uart_tx_full),       // Pulsed high for 1 clock when tx_data byte is ready to be sent
                                .tx_data(uart_tbyte),   // The byte which will be transmitted
                                .tx_busy(uart_tx_full), // High when the 1 word FIFO in the UART's transmit buffer is full
                                .rx_sample_pulse ());


wire [7:0] msg_rom ;
reg  [7:0] msg_pos = 0 ;
message_rom mrom (.clk(clk_in),.addr(msg_pos),.q(msg_rom));
reg  [2:0] epos  = 0; // Editor position.
reg        eposb = 0;

localparam string hex_rom = "0123456789ABCDEF" ;
localparam string wr_rom  = "WR" ;

wire [3:0] pwire [0:10] = '{ I2C_da[7:4],
                             I2C_da[3:0],
                             I2C_ra[7:4],
                             I2C_ra[3:0],
                             I2C_wd[7:4],
                             I2C_wd[3:0],
                             I2C_rd[7:4],
                             I2C_rd[3:0],
                             {3'd0,I2C_ack_error[2]},
                             {3'd0,I2C_ack_error[1]},
                             {3'd0,I2C_ack_error[0]}  };

// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************

`else  assign RS232_txd = 1 ; // Without the editor enabled, make the TXD output default high.
`endif
// ***************************************************************************************************************

  always @(posedge clk_in) begin

                I2C_sda_d     <= I2C_sda ; // Dumb register sampling incoming data from tristate I2C data input pin.

    if (rst_in) begin
                I2C_scl_q      <= 1'b1  ; I2C_sda_q   <= 1'b1        ; I2C_scl_oe <= TRI_I2C_scl ; I2C_sda_oe <= TRI_I2C_scl ; I2C_ack_error <= 3'd0 ; // reset IOs
                seq_pc         <= (pcl)'(0)  ;
                per_pulse      <= 1'b0  ; I2C_period   <= I2C_per_len ; rst_out    <= 1'b0        ;  // The rst_out is a optional sequence generate general purpose output.
                mst_cnt<=(mst_bits)'(0) ; ms_cnt_len   <= 8'd00       ; mst_hold   <= 1'b0        ; //  Reset the millisecond pause timer.

                I2C_da <= 8'h00 ; I2C_ra <= 8'h00 ; I2C_wd  <= 8'h00 ; I2C_rd  <= 8'h00        ;  // Reset I2C bus.
                tpos   <= (tpos_bits)'(0) ;
    end else begin

        if (I2C_period==0) begin I2C_period <= I2C_per_len       ; per_pulse  <= 1'b1 ; end  // Generate clock divider with a buffered enable output reg.
                      else begin I2C_period <= I2C_period - 1'b1 ; per_pulse  <= 1'b0 ; end


`ifdef ENABLE_RS232_EDITOR
      if ((per_pulse || seq_pc[6]) && !uart_tx_full) begin // *** When the RS232 is enabled, the RS232 portion of the program sequence counter should run at full speed.
`else
      if (per_pulse) begin
`endif
        if (!mst_hold) begin

                          seq_pc <= seq_pc + 1'b1 ;  // Sequence program counter increment speed -= 4x I2C_KHZ.  DELAY_MS changes the inc speed to 0.001 sec for 1 cycle.
            case (seq_pc)
                default : seq_pc <= seq_pc + 1'b1 ;  // Sequence program counter increment speed -= 4x I2C_KHZ.  DELAY_MS changes the inc speed to 0.001 sec for 1 cycle.


// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// User customization startup sequence.
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************

`ifdef ENABLE_RS232_EDITOR
                0     : begin rst_out <= 1'b0; tpos <= (tpos_bits)'(0); seq_ret3<=seq_pc+1'b1;msg_pos=8'd0;seq_pc<=(pcl)'(64); end // call rs232 routines.
`else
                0     : begin rst_out <= 1'b0; tpos <= (tpos_bits)'(0); end
`endif
                1     : I2C_WRITE_table() ; // Transmit the lookup table.

`ifdef ENABLE_RS232_EDITOR
                3     : seq_pc<=(pcl)'(75)     ; // Run rs232 editor
`else
                3     : seq_pc        <= seq_pc     ; // Stop sequencer here.
`endif
// ***************************************************************************************************************
// Write I2C_wd to address I2C_ra at device I2C_da.
// ***************************************************************************************************************
                16    : I2C_ON();
                17    : begin I2C_sda_q  <= 1'b0; end
                                                                                // Exaggerate the timing of the 'start' condition
                19    : begin              I2C_tx_byte({I2C_da[7:1],1'b0}); end // start condition and begin tx
                20    : begin sbit()     ; I2C_rx_bit ()                  ; end // sample LSB input just at the fall of the 'scl' which is inside 'I2C_rx_bit()'
                21    : begin sack(2)    ; I2C_tx_byte( I2C_ra           ); end // sample ACK input just at the fall of the 'scl' which is inside 'I2C_tx_byte()'
                22    : begin sbit()     ; I2C_rx_bit ()                  ; end
                23    : begin sack(1)    ; I2C_tx_byte( I2C_wd           ); end
                24    : begin sbit()     ; I2C_rx_bit ()                  ; end
                25    : begin sack(0)    ; I2C_scl_q <= 1'b0              ; end
                26    : begin I2C_sda_oe <= 1'b1 ;I2C_sda_q<=1'b0         ; end  // Generate stop condition
                                                                                 // Exaggerate the timing of the 'start' condition
                28    :       I2C_scl_q <= 1'b1 ;

                30    :       I2C_sda_q <= 1'b1 ;


`ifdef ENABLE_RS232_EDITOR
                31    : begin I2C_OFF();epos<=3'd5;seq_pc<=(pcl)'(68) ; end
`else
                31    : begin I2C_OFF();SEQ_RETURN();I2C_ra    <= I2C_ra + 1'b1 ; end
`endif

// ***************************************************************************************************************
// Transmit byte 'sr', receive byte rr,
// ***************************************************************************************************************
                32    : begin I2C_scl_q  <=1'b0;I2C_sda_q<=sr[7];sr<=sr<<1'b1;I2C_sda_oe<=oe;end
                33    : begin I2C_scl_q  <=1'b1;                                             end
                34    : begin I2C_scl_q  <=1'b1;if (txl==0) seq_pc<=seq_ret2;                end
                35    : begin I2C_scl_q  <=1'b0;sbit();seq_pc<=(pcl)'(32);txl<=txl-1'b1;     end
// ***************************************************************************************************************

// ***************************************************************************************************************
// Read I2C_rd from address I2C_ra at device I2C_da.
// ***************************************************************************************************************
`ifdef ENABLE_RS232_EDITOR
                36    : I2C_ON();
                37    : begin I2C_sda_q  <= 1'b0; end
                                                                                // Exaggerate the timing of the 'start' condition
                39    : begin               I2C_tx_byte({I2C_da[7:1],1'b0} ); end // start condition and begin tx
                40    : begin sbit()      ; I2C_rx_bit ()                  ; end // sample LSB input just at the fall of the 'scl' which is inside 'I2C_rx_bit()'
                41    : begin sack(2)     ; I2C_tx_byte( I2C_ra           ); end // sample ACK input just at the fall of the 'scl' which is inside 'I2C_tx_byte()'
                42    : begin sbit()      ; I2C_rx_bit ()                  ; end
                
                43    : begin sack(1)     ; I2C_scl_q <= 1'b0 ; end
                44    : begin               I2C_sda_q <= 1'b1 ; I2C_sda_oe <= 1'b1 ; end // new start
                45    :                     I2C_scl_q <= 1'b1 ;
                46    :                     I2C_sda_q <= 1'b0 ;

                47    : begin                I2C_tx_byte({I2C_da[7:1],1'b1} ); end // start condition and begin tx
                48    : begin sbit()       ; I2C_rx_bit ()                  ; end // sample LSB input just at the fall of the 'scl' which is inside 'I2C_rx_bit()'

                49    : begin sack(0)      ; I2C_rx_byte(                  ); end
                50    : begin sbit()       ; I2C_rx_bit ()                  ; end
                51    : begin I2C_rd <= rr ; I2C_scl_q <= 1'b0              ; end
                52    : begin I2C_sda_oe <= 1'b1 ;I2C_sda_q<=1'b0         ; end  // Generate stop condition
                                                                                 // Exaggerate the timing of the 'start' condition
                54    :       I2C_scl_q <= 1'b1 ;

                56    :       I2C_sda_q <= 1'b1 ;

                57    : begin I2C_OFF();seq_pc<=(pcl)'(64);if (I2C_ack_error[0]) msg_pos<=81;else msg_pos<=154; end
`endif
// ***************************************************************************************************************

// ***************************************************************************************************************
// RS232 routines.
// ***************************************************************************************************************
`ifdef ENABLE_RS232_EDITOR

//                64    : // Delay for the 2 clk rom updating.
//                65    : 
                66    : begin if (msg_rom == 0) seq_pc <= seq_ret3; else begin
                                  uart_tx<=1'b1;
                             if (!msg_rom[7])      uart_tbyte<= msg_rom;
                        else if (!msg_rom[4])      uart_tbyte<= hex_rom[pwire[msg_rom[3:0]]];
                        else                       uart_tbyte<= I2C_da[0]? "R" : "W";
                        
                        end ; end

                67    : begin uart_tx<=1'b0;msg_pos<=msg_pos+1'b1;seq_pc<=(pcl)'(64); end

                // Show I2C transaction
                68    :               begin seq_ret3<=(pcl)'(69); msg_pos<= 98;seq_pc<=(pcl)'(64);end // Show W/R
                69    : if (epos > 0) begin seq_ret3<=(pcl)'(70); msg_pos<=113;seq_pc<=(pcl)'(64);end // Show DA
                70    : if (epos > 1) begin seq_ret3<=(pcl)'(71); msg_pos<=117;seq_pc<=(pcl)'(64);end // Show RA
                71    : if (epos > 2) begin seq_ret3<=(pcl)'(72); msg_pos<=121;seq_pc<=(pcl)'(64);end // Show WD
                72    : if (epos > 3) begin seq_ret3<=(pcl)'(73); msg_pos<=129;seq_pc<=(pcl)'(64);end // Show ACK
                73    : if (epos > 4) begin seq_ret3<=seq_ret; if (I2C_ack_error==0) msg_pos<=78;else msg_pos<=81;seq_pc<=(pcl)'(64);end // Show No ACK error.
                74    : seq_pc <= seq_ret;

// $0D=CR/enter, $0A=LF,  $7F & $08=bs, $1B=Esc
// 0=$30, a=$61, A=$41

                        // Show Init Done.
                75    : begin uart_tx<=1'b0;seq_ret3<=(pcl)'(76);seq_pc<=(pcl)'(64); msg_pos<=137;end

                        // Test read command.
                //75    : begin seq_ret<=(pcl)'(76);seq_pc<=(pcl)'(36); end

                        // Set default edit line position after init.
                76    : begin eposb<=0;epos<=3'd3;if (I2C_da[0]==1) epos<=3'd2;end

                        // Show editor line
                77    : begin seq_ret<=(pcl)'(78);seq_pc<=(pcl)'(68);end 


                        // wait for incoming character
                78    : begin if (!uart_rxd_rdy) seq_pc <= seq_pc ;end
                
                        // Process ESC key. ***** Reset sequencer.
                79    : if (uart_rbyte==8'h1B) seq_pc<=(pcl)'(0);

                        // UCASE algorithm
                80    : begin uart_rx <= uart_rbyte; if (uart_rbyte>="a" && uart_rbyte<="z") uart_rx <= uart_rbyte & 8'b11011111; end

                        // Swap between read and write.
                81    : if (uart_rx == "R" || uart_rx == "W") begin
                            if (uart_rx == "W") I2C_da[0]<=0;
                            else begin I2C_da[0]<=1;if (epos>2) epos<=3'd2;end
                            seq_pc<=(pcl)'(77); // back to editor line
                        end

                        // process backspace.
                82    : if (uart_rx==8'h08 || uart_rx==8'h7f) begin 
                            if (epos>0 && !eposb) epos<=epos-1'b1;
                            eposb <=1'b0;
                            seq_pc<=(pcl)'(77); // back to editor line
                        end

                        // Proceed to an I2C an actual read or write.
                83    : if (uart_rx==8'h0D) begin
                        if (I2C_da[0]==0 && epos==3) begin seq_ret<=(pcl)'(76);seq_pc<=(pcl)'(16); end
                        if (I2C_da[0]==1 && epos==2) begin seq_ret<=(pcl)'(76);seq_pc<=(pcl)'(36); end
                        end

                        // Do not allow additional hex entry if we have reached the maximum edit position
                84    : if ((epos>2 && !I2C_da[0]) || (epos>1 && I2C_da[0])) seq_pc<=(pcl)'(78);
                        

                        // Filter and translate HEX entry.
                85    : begin
                             if (uart_rx>="0" && uart_rx<="9") uart_rx<=uart_rx-8'h30;
                        else if (uart_rx>="A" && uart_rx<="F") uart_rx<=uart_rx-8'h37;
                        else seq_pc<=(pcl)'(78); // not a hex entry, so, return to wait for next character.
                        end

                        
                        // Print and accept first character.
                86    : begin uart_tbyte<=hex_rom[uart_rx[3:0]] ;uart_tx<=1'b1;end
                87    : uart_tx<=1'b0;
                88    : begin I2C_wd[3:0]<=uart_rx[3:0];if (!eposb) I2C_wd[7:4]<=uart_rx[3:0];end
                89    : if (eposb) begin
                                 if (epos==0) I2C_da<=I2C_wd;
                            else if (epos==1) I2C_ra<=I2C_wd;
                            epos <=epos+1'b1;
                            eposb<=1'b0;
                            seq_pc<=(pcl)'(77);
                            end
                90     : begin eposb<=1'b1;seq_pc<=(pcl)'(78);end



`endif
// ***************************************************************************************************************
// END RS232 routines.
// ***************************************************************************************************************


            endcase

        end else if (mst_cnt==(mst_bits)'(0) && ms_cnt_len==8'd1) mst_hold<=1'b0;
                 else if (mst_cnt==(mst_bits)'(0)) begin ms_cnt_len<=ms_cnt_len-1'b1;mst_cnt<=mst_per; end
                 else if (mst_hold) mst_cnt<=mst_cnt-1'b1; // !mst_hold millisecond delay countdown timer.

      end // per_pulse
    end // !rst_in
  end // clk_in

// ***************************************************************************************************************
// Associated tasks.
// ***************************************************************************************************************
task I2C_ON    ();begin I2C_scl_q <=1'b1;I2C_sda_q<=1'b1;I2C_scl_oe<=1'b1       ;I2C_sda_oe<=1'b1       ;I2C_ack_error<=3'd0; end;endtask
task I2C_OFF   ();begin I2C_scl_q <=1'b1;I2C_sda_q<=1'b1;I2C_scl_oe<=TRI_I2C_scl;I2C_sda_oe<=TRI_I2C_scl;                     end;endtask
task SEQ_RETURN();begin seq_pc    <=seq_ret;                                                                                  end;endtask

task WAIT_MS   ([7:0] a);begin mst_hold<=1'b1;mst_cnt<=mst_per;ms_cnt_len<=a;                                                 end;endtask // Wait for 'a' milliseconds.

task sbit()       ;begin rr<={rr[6:0],I2C_sda_d}       ;end;endtask // Sample 1 bit towards generating a read byte.
task sack([1:0] a);begin I2C_ack_error[a] <= I2C_sda_d ;end;endtask // Sample the ACK bit status.

task I2C_tx_byte([7:0] tx); begin
 I2C_scl_q        <= 1'b0 ;
    oe            <= 1'b1 ;
    sr            <= tx   ;
    txl           <= 3'd7 ;
    seq_ret2      <= seq_pc + 1'b1 ; // set second return address from call routine.
    seq_pc        <= (pcl)'(32);     // goto the I2C tx byte sub-routine.
end; endtask
task I2C_tx_bit(bit tx); begin
 I2C_scl_q        <= 1'b0 ;
    oe            <= 1'b1 ;
    sr[7]         <= tx   ;
    txl           <= 3'd0 ;
    seq_ret2      <= seq_pc + 1'b1 ; // set second return address from call routine.
    seq_pc        <= (pcl)'(32);     // goto the I2C tx byte sub-routine.
end; endtask
task I2C_rx_byte(); begin
 I2C_scl_q        <= 1'b0 ;
    oe            <= 1'b0 ;
    txl           <= 3'd7 ;
    seq_ret2      <= seq_pc + 1'b1 ; // set second return address from call routine.
    seq_pc        <= (pcl)'(32);     // goto the I2C tx byte sub-routine.
end; endtask
task I2C_rx_bit(); begin
 I2C_scl_q        <= 1'b0 ;
    oe            <= 1'b0 ;
    txl           <= 3'd0 ;
    seq_ret2      <= seq_pc + 1'b1 ; // set second return address from call routine.
    seq_pc        <= (pcl)'(32);     // goto the I2C tx byte sub-routine.
end; endtask

task I2C_WRITE_table();begin

if (tpos==TX_TABLE_len) seq_pc<=seq_pc+1'b1;

else begin
    tpos          <= tpos + 1'b1;
    seq_ret       <= seq_pc;

    if (~TX_TABLE_data[tpos][16]) begin // Normal sending of ra,wd
                                    I2C_ra <= TX_TABLE_data[tpos][15:8] ; I2C_wd<=TX_TABLE_data[tpos][7:0] ;
                                    seq_pc <= (pcl)'(16);                         // goto Write I2C_wd to address I2C_ra at device I2C_da.
    
    end else if (TX_TABLE_data[tpos][9:8]==2'h0) begin I2C_da  <=  TX_TABLE_data[tpos][7:0]   ;seq_pc<=seq_pc; end
        else if (TX_TABLE_data[tpos][9:8]==2'h1) begin rst_out <=  TX_TABLE_data[tpos][0]     ;seq_pc<=seq_pc; end
        else if (TX_TABLE_data[tpos][9:8]==2'h2) begin WAIT_MS   ( TX_TABLE_data[tpos][7:0] ) ;seq_pc<=seq_pc; end

end

end; endtask

endmodule


// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// Ascii message rom.
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
`ifdef ENABLE_RS232_EDITOR

module message_rom (clk, addr, q);

                       input wire       clk ;
                       input wire [7:0] addr ;
(* romstyle = "M9K" *) output reg [7:0] q ;

reg [7:0] addr_reg ;


//wire [7:0] msg_lut [  0:255];

var bit [7:0] msg_lut [0:255];

initial begin msg_lut [0:161] = '{

// 0
8'h0d,8'h0a,
"B","H","G","_","I","2","C","_","i","n","i","t","_","R","S","2","3","2","_","d","e","b","u","g","g","e","r"," ","V","1",".","0",","," ","A","u","g"," ","2","0","2","2",".",
8'h0d,8'h0a,
"h","t","t","p","s",":","/","/","g","i","t","h","u","b",".","c","o","m","/","B","r","i","a","n","H","G","i","n","c",
8'h0d,8'h0a,8'h0d,8'h0a,8'h00,

// 81
" ","n","o"," ","A","C","K"," ","E","r","r","o","r",".",8'h0d,8'h0a,8'h00,

// 98
8'h7f,8'h7f,8'h7f,8'h7f,8'h7f,8'h7f,8'h7f,8'h7f,8'h7f,8'h7f,8'h7f,8'h7f,8'h90," ",8'h00,

// 113
8'h80,8'h81," ",8'h00,

// 117
8'h82,8'h83," ",8'h00,

// 121
8'h84,8'h85," ",8'h00,

// 125
8'h86,8'h87," ",8'h00,

// 129
"A","C","K","=",8'h88,8'h89,8'h8A,8'h00,

// 137
8'h0d,8'h0a,"I","n","i","t"," ","D","o","n","e",".",8'h0d,8'h0a,8'h0d,8'h0a,8'h00,

// 154
" ","="," ",8'h86,8'h87,8'h0d,8'h0a,8'h00
};
msg_lut [162:255] = '{default:8'h00}; // clear the remaining contents to '8'h00'.
end


always @(posedge clk) begin
    addr_reg <= addr          ;
    q        <= msg_lut[addr_reg]; // registered read of rom.
end

endmodule

`endif
