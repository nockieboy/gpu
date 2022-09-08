// ***************************************************************************************************************
// ***************************************************************************************************************
// host_IO.sv
//
// Host IO Peripheral Interconnect
//
// v1.0, 8th September 2022
// Written by Jonathan Nock 10103
//
// Interfaces peripheral modules with the host bridge via the WRITE_PORT_DATA and WRITE_PORT_STROBE buses, which
// are produced by Bridgette in the top-level module.
//
// Peripheral IO reads are maintained in the IO_RD_DATA bus managed by the top-level module.
//
// ***************************************************************************************************************
// ***************************************************************************************************************
module host_IO (

    input  logic         clk,
    input  logic         reset,
    input  logic [  7:0] WRITE_PORT_DATA [0:255],
    input  logic [255:0] WRITE_PORT_STROBE,
    input  logic         SD_busy,           // HIGH when SD interface is BUSY
    input  logic [  7:0] psg_data_i,        // data in FROM PSG

    output logic [  7:0] MMU_AREA [0:3],
    output logic [  7:0] MMU_ENABLE,
    output logic [  7:0] GPU_MMU_LO,
    output logic [  7:0] GPU_MMU_HI,
    output logic [  1:0] ARG_PTR,           // 2-bit pointer to current byte in 32-bit SD_SECTOR
    output logic         SD_op_ena,         // strobes to SID that an operation is requested
    output logic [  1:0] SD_wr_ena,         // sets SID to init, read or write mode
    output logic [ 31:0] SD_sector,
    output logic [  7:0] RNG_OUT,
    output logic [  7:0] PSG_DATA_O,        // data out TO PSG
    output logic         PSG_WR_EN          // write enable strobe TO PSG

);

    // Default IO port assignments
    parameter bit [7:0]  MMU_A0     = 'h38 ; // IO address for Bank 0 setting 
    parameter bit [7:0]  MMU_A1     = 'h39 ; // IO address for Bank 1 setting 
    parameter bit [7:0]  MMU_A2     = 'h3A ; // IO address for Bank 2 setting 
    parameter bit [7:0]  MMU_A3     = 'h3B ; // IO address for Bank 3 setting 
    parameter bit [7:0]  MMU_EN     = 'h3C ; // IO address for MMU enable 
    parameter bit [7:0]  PSG_LATCH  = 'hEE ; // IO addr: PSG LATCH register R/W - write latches register, read returns data
    parameter bit [7:0]  PSG_WRITE  = 'hEF ; // IO addr: PSG WRITE port W-only
    parameter bit [7:0]  SD_STATUS  = 'hF0 ; // IO address for SD STATUS register R-only
    parameter bit [7:0]  SD_SECTOR  = 'hF1 ; // IO address for SD SECTOR address pipe - R/W (indexed by ARG_PTR)
    parameter bit [7:0]  SD_MODE    = 'hF2 ; // IO address for SD operation trigger - W-only
    parameter bit [7:0]  SD_ARG_PTR = 'hF3 ; // IO address for SD ARG_PTR - R/W
    parameter bit [7:0]  GPU_RNG    = 'hF5 ; // IO addr: GPU random number generator
    parameter bit [7:0]  GPU_ML     = 'hFC ; // Lower 8-bits of the upper 12-bits of the DDR3 address bus
    parameter bit [7:0]  GPU_MH     = 'hFD ; // Upper 4-bits of the upper 12-bits of the DDR3 address bus

    always_ff @(posedge clk) begin

        if (reset) begin  // set default values on reset

            MMU_AREA[0] <= 8'hFF ; // Default value for Bank 0
            MMU_AREA[1] <= 8'h01 ; // Default value for Bank 1
            MMU_AREA[2] <= 8'h02 ; // Default value for Bank 2
            MMU_AREA[3] <= 8'h03 ; // Default value for Bank 3
            MMU_ENABLE  <= 8'h00 ; // Default value for MMU enable
            GPU_MMU_LO  <= 8'b0  ; // 
            GPU_MMU_HI  <= 8'b0  ; // 
            ARG_PTR     <= 2'b0  ; //
            SD_op_ena   <= 0     ; // Clear any SD interface enable
            SD_wr_ena   <= 2'b0  ; // Clear any SD interface write enable
            SD_sector   <= 32'b0 ; // Reset SD sector address register

        end else begin

            // Host MMU writes
                 if (WRITE_PORT_STROBE[MMU_A0])     MMU_AREA[0]  <= WRITE_PORT_DATA[MMU_A0]          ;
            else if (WRITE_PORT_STROBE[MMU_A1])     MMU_AREA[1]  <= WRITE_PORT_DATA[MMU_A1]          ;
            else if (WRITE_PORT_STROBE[MMU_A2])     MMU_AREA[2]  <= WRITE_PORT_DATA[MMU_A2]          ;
            else if (WRITE_PORT_STROBE[MMU_A3])     MMU_AREA[3]  <= WRITE_PORT_DATA[MMU_A3]          ;
            else if (WRITE_PORT_STROBE[MMU_EN])     MMU_ENABLE   <= WRITE_PORT_DATA[MMU_EN]          ;
            // GPU MMU writes
            else if (WRITE_PORT_STROBE[GPU_ML])     GPU_MMU_LO   <= WRITE_PORT_DATA[GPU_ML]          ;
            else if (WRITE_PORT_STROBE[GPU_MH])     GPU_MMU_HI   <= WRITE_PORT_DATA[GPU_MH]          ;
            // SD interface writes
            else if (WRITE_PORT_STROBE[SD_ARG_PTR]) ARG_PTR[1:0] <= WRITE_PORT_DATA[SD_ARG_PTR][1:0] ;
            else if (WRITE_PORT_STROBE[SD_SECTOR]) begin

                case ( ARG_PTR[1:0] )
                    2'b00 : begin
                        ARG_PTR          <= ARG_PTR + 1'b1             ;
                        SD_sector[ 7: 0] <= WRITE_PORT_DATA[SD_SECTOR] ;
                    end
                    2'b01 : begin
                        ARG_PTR          <= ARG_PTR + 1'b1             ;
                        SD_sector[15: 8] <= WRITE_PORT_DATA[SD_SECTOR] ;
                    end
                    2'b10 : begin
                        ARG_PTR          <= ARG_PTR + 1'b1             ;
                        SD_sector[23:16] <= WRITE_PORT_DATA[SD_SECTOR] ;
                    end
                    2'b11 : begin
                        ARG_PTR          <= 8'b0                       ; // reset ARG_PTR
                        SD_sector[31:24] <= WRITE_PORT_DATA[SD_SECTOR] ;
                    end
                endcase

            end
            else if (WRITE_PORT_STROBE[SD_MODE] && !SD_busy ) begin

                SD_wr_ena <= WRITE_PORT_DATA[SD_MODE][1:0] ; // INIT = 0, RD = 1, WR = 2
                SD_op_ena <= 1                             ; // trigger SD interface op

            end
            else begin

                SD_op_ena <= 0 ;

            end

        end

    end

    // *****************************************************************
    // RANDOM NUMBER GENERATOR
    //
    // Instantiate a linear feedback register to act as a random number
    // generator.
    // *****************************************************************
    LFSR # (

        .NUM_BITS    ( 8 ) // 8-bit RNG

    ) RNG (

        .i_Clk       ( clk                        ),
        .i_Enable    ( 1'b1                       ), // Permanently enabled
        .i_Seed_DV   ( WRITE_PORT_STROBE[GPU_RNG] ), // Optional Seed Value
        .i_Seed_Data ( WRITE_PORT_DATA  [GPU_RNG] ),
        .o_LFSR_Data ( RNG_OUT                    ),
        .o_LFSR_Done (  )

    );

endmodule
