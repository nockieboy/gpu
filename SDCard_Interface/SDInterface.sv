// SD Interface v0.1
//
// by J.H.NOCK, November 2021
//
// Connects the SD modules to the rest of the GPU and manages the
// 4KB dual-port M9K block RAM read/write buffer.
//
// TODO: Get reads working with direction controls.
// TODO: Copy completed cache to DDR3 block buffer.
// TODO: Handle write requests to the SD card.

module SDInterface #(

    parameter bit   [11:0]  DDR3_BUFFER_ADDR = 'd256   // default DDR3 buffer location to page 2

)(

    input   logic           CLK_100,        // 100MHz system clock
    input   logic           RESET,          // reset active HIGH
    // SD read parameters
    input   logic           RD_REQ,         // HIGH for read request
    input   logic   [ 31:0] SECTOR,         // sector number to read/write
    // SD phy connections
    inout   logic   [  3:0] SD_DATA,        // data from SDReader.sv
    inout                   SD_CMD,         // CMD signal to SDReader.sv
    output  logic           SD_CLK,         // clock signal to SD card
    // SD status flags & data
    output  logic           RD_RDY,         // HIGH when read is complete from SD card
    output  logic           SD_BUSY,        // HIGH when interface is busy
    output  logic   [  3:0] SIDSTATE,       // current state machine value
    output  logic   [  1:0] CARDTYPE,       // SD card type
    // SD bus direction controls
    output  logic           SD_CMD_DIR,     // HIGH = TO SD card, LOW = FROM SD card
    output  logic           SD_D0_DIR,      // HIGH = TO SD card, LOW = FROM SD card
    output  logic           SD_D123_DIR,    // HIGH = TO SD card, LOW = FROM SD card
    output  logic           SD_SEL,         // SD select
    // DDR3 input connections
    input   logic           DDR3_BUSY,      // HIGH when DDR3 is busy
    input   logic           DDR3_RD_RDY,    // data from DDR3 is ready
    input   logic   [127:0] DDR3_RD_DATA,   // read data from DDR3
    // DDR3 output connections
    output  logic           DDR3_WR_REQ,    // HIGH signals write request to DDR3 Controller
    output  logic   [  8:0] DDR3_WR_ADDR,   // 9-bit address bus for *cache RAM* address - this is aligned to final DDR3 address by top-level module
    output  logic   [127:0] DDR3_WR_DATA    // 128-bit data bus

);

// data IO for read and write data, to connect to buffer
wire          cache_wren ;

logic         rEna       ; // HIGH whilst rData is being sent
logic [  7:0] SD_rData   ; // Data read from cache
logic [  8:0] readAddr   ; // 512-byte buffer address being read to
logic [  8:0] writeAddr  ; // 512-byte buffer address being written to
logic [ 12:0] cacheAddr  ; // Cache block RAM address bus
logic [127:0] DDR3_wData ; // data from SD cache to DDR3 block buffer

// cacheAddr is either the lowest 512-bytes of cache RAM for writing data from the SD card to,
// or the next 512 bytes for reading data from before writing to the SD card.
assign cacheAddr = cache_wren ? { 4'b0, readAddr[8:0] } : { 4'b0001, writeAddr[8:0] } ;

// *********************************************************************************************
// ************************************ SD Block Cache *****************************************
// *********************************************************************************************
//
// The SD Block Cache provides 8KB of M9K dual-port RAM to store multiple blocks of data as it
// is read from, or written to, the SD card.
//
// In the case of a read, data from the SD card is written to the first 512 bytes of the cache
// (the Read Buffer) and once the read transaction is completed (RD_RDY goes HIGH), the Read
// Buffer in the block cache is then burst-written to the block buffer in DDR3 memory via a
// 128-bit bus, where the host can then access it.
//
// For a write, the data to be written is transferred from the DDR3 block buffer via burst-read
// across the 128-bit bus to the Write Buffer (upper 512 bytes) in the SD block cache.  Once this
// is complete, WR_RDY is asserted to indicate to the host that the DDR3 block buffer is free to
// be written to again, the write transaction is initiated and the data written to the SD card.
//
// A-side is 8 bits wide with a 9-bit address bus (512 bytes) and connects to the SD interface.
// B-side is 128 bits wide with a 5-bit address bus (512 bytes), connects to the DDR3 Controller.
//
dual_port_block_cache	SD_Block_Cache (

	.address_a  ( cacheAddr  ),
	.address_b  (            ),
	.clock_a    ( CLK_100    ),
	.clock_b    ( CLK_100    ),
	.data_a     ( SD_rData   ),
	.data_b     (            ),
	.enable_a   ( 1'b1       ),
	.enable_b   ( 1'b0       ),
	.rden_a     ( 1'b0       ),
	.rden_b     ( 1'b0       ),
	.wren_a     ( cache_wren ),
	.wren_b     ( 1'b0       ),
	.q_a        (            ),
	.q_b        ( DDR3_wData )

);

// For more detail, see SDReader.sv
SDReader #(

    .CLK_DIV         ( 2           )  // because clk=100MHz, CLK_DIV is set to 2 - see SDReader.sv for detail

) SDReader_inst(

    .clk             ( CLK_100     ),
    .rst_n           ( !RESET      ), // rst_n is active low, so RESET must be inverted
    
    // signals connect to SD bus
    .sdclk           ( SD_CLK      ),
    .sdcmd           ( SD_CMD      ),
    .sddat           ( SD_DATA     ),
    
    // bus direction controls
    .SD_CMD_DIR      ( SD_CMD_DIR  ), // HIGH = TO SD card, LOW = FROM SD card
    .SD_D0_DIR       ( SD_D0_DIR   ), // HIGH = TO SD card, LOW = FROM SD card
    .SD_D123_DIR     ( SD_D123_DIR ), // HIGH = TO SD card, LOW = FROM SD card
    .SD_SEL          ( SD_SEL      ), // SD socket select

    // status and information
    .card_type       ( CARDTYPE    ), // 0=Unknown, 1=SDv1.1 , 2=SDv2 , 3=SDHCv2
    .card_stat       ( SIDSTATE    ), // current state of SDReader's state machine
    
    // user read sector command interface
    .rstart          ( RD_REQ      ), // rstart HIGH starts read operation
    .rsector_no      ( SECTOR      ), // target sector to read in SDcard
    .rbusy           ( SD_BUSY     ), // signals read is ongoing or complete
    .rdone           ( RD_RDY      ), // signals read is complete
    
    // sector data output interface
    .outreq          ( cache_wren  ), // HIGH whilst data is received from SD card
    .outaddr         ( readAddr    ), // cache address to be written to
    .outbyte         ( SD_rData    )  // data read from SD card

);

always @( posedge CLK_100 or posedge RD_RDY ) begin

    if ( RD_RDY ) begin // End of SD Read; transfer to cache is complete

        // TODO: Write cache to DDR3 buffer, starting at DDR3_BUFFER_ADDR

    end

end

endmodule
