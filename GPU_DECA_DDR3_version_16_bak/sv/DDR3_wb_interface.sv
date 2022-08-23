/*
    DDR3_wb_interface
    by Nockieboy

    v0.1, March 2022.

    Provides a Wishbone-compatible interface to BrianHG's DDR3 memory controller
    by creating a Wishbone Slave endpoint for the Wishbone bus from SID.

    Requests are translated and passed through to the DDR3 Controller.
*/ 

module DDR3_wb_interface (

    // ports
    input  logic        CLK,            // System clock - shared between WB and DDR3, so no clock-domain X-ing.
    input  logic        RST,            // Global reset signal
    // Wishbone inputs
    input  logic [31:0] adr_i,          // Address input [31:0]
    input  logic [1:0]  bte_i,          // Burst Type Extension.  Always 2'b00.  * Ignored by this module.
    input  logic [2:0]  cti_i,          // Cycle Type Identifier. Always 3'b000. * Ignored by this module.
    input  logic        cyc_i,          // Cycle input - asserted when valid bus cycle is in progress
    input  logic [31:0] dat_i,          // Data input [31:0]
    input  logic [3:0]  sel_i,          // Select input [3:0] (indicates where valid data is on the dat_i or dat_o bus)
    input  logic        stb_i,          // Strobe input - indicates valid data transfer cycle
    input  logic         we_i,          // Write enable input - asserted if current local bus cycle is a WRITE
    // Wishbone outputs
    output logic        ack_o,          // Acknowledge output - indicates normal termination of a bus cycle
    output logic [31:0] dat_o,          // Data output [31:0]
    // DDR3 inputs
    input  logic        CMD_busy,       // High when DDR3 is busy.
    input  logic        CMD_read_ready, // One-shot signal from mux or DDR3_Controller that data is ready.
    input  logic [31:0] CMD_read_data,  // Read Data from RAM to be sent to WB.
    // DDR3 outputs
    output logic [31:0] CMD_addr,       // WB requested address.
    output logic        CMD_ena,        // Flag HIGH for 1 CMD_CLK when sending a DDR3 command.
    output logic        CMD_write_ena,  // Write enable to DDR3 RAM.
    output logic [31:0] CMD_write_data, // Data from WB to be written into RAM.
    output logic [3:0]  CMD_write_mask  // Write data enable mask to RAM.

);

// Latches for WRITE data to DDR3
reg  [31:0] RAM_addr ;
reg  [31:0] RAM_data ;
// Simple state machine counter
reg  cycle_cnt = 1'b0 ; // HIGH after first valid clock of a transaction

// Connect common buses through the interface
//          OUT       |      IN
assign CMD_addr       = RAM_addr      ; // this is latched as per Wishbone B3 specification
assign CMD_write_data = RAM_data      ; // this is latched as per Wishbone B3 specification
assign CMD_write_mask = sel_i         ; // might need to modify this if the masks aren't compatible
assign dat_o          = CMD_read_data ;


always @( posedge CLK ) begin

    if (RST) begin // Reset interface

        ack_o          <= 1'b0  ;
        CMD_ena        <= 1'b0  ;
        CMD_write_ena  <= 1'b0  ;
        cycle_cnt      <= 1'b0  ;
        RAM_addr       <= 32'b0 ;
        RAM_data       <= 32'b0 ;

    end
    else begin // Manage Wishbone <-> DDR3 control signals

        if ( stb_i ) begin // ***** VALID CYCLE *****

            if ( !CMD_busy && !cycle_cnt ) begin // SETUP EDGE 1

                ack_o         <= we_i  ; // Assert ACK_O if this is a WR cycle (end of cycle)
                CMD_ena       <= 1'b1  ; // Signal transaction request to DDR3 Controller
                CMD_write_ena <= we_i  ; // Set RD/WR according to we_i
                cycle_cnt     <= 1'b1  ; // Increment cycle counter
                RAM_addr      <= adr_i ; // Latch address
                RAM_data      <= dat_i ; // Latch data

            end
            else begin // CLOCK EDGE 1 OR DDR3 BUSY

                CMD_ena       <= 1'b0  ; // Ensure one-shot CMD_ena signal
                CMD_write_ena <= 1'b0  ; // Ensure one-shot WR signal
                if ( !we_i && CMD_read_ready ) ack_o <= 1'b1 ; // Signal Wishbone Master data is ready

            end

        end
        else begin // ***** IDLE *****

            ack_o     <= 1'b0 ;
            CMD_ena   <= 1'b0 ;
            cycle_cnt <= 1'b0 ;

        end

    end

end

endmodule
