/*
    Hardware Control Registers
    by Jonathan Nock & Brian Guralnick

    V2.0. 30th November, 2021.

    HW_REGS are 16KB of 16-bit values held in RAM at BASE_WRITE_ADDRESS.

    At reset, key registers are set to default RESET_VALUES specified in this module.
*/

module HW_Regs #(

    parameter int         PORT_ADDR_SIZE                  = 19    , // This parameter is passed by the top module
    parameter int         PORT_CACHE_BITS                 = 128   , // This parameter is passed by the top module
    parameter int         ENDIAN                          = 1     , // 0 = non-reversed, 1 = 16-bit reverse endian, 3 = 32-bit reverse endian
    parameter             HW_REGS_SIZE                    = 14    , // 2^14 = 16384 bytes
    parameter int         RST_PARAM_SIZE                  = 2     , // Number of default values
    parameter int         BASE_WRITE_ADDRESS              = 20'h0 , // Where the HW_REGS are held in RAM
    parameter bit [31:0]  RESET_VALUES[1:RST_PARAM_SIZE]  = '{
        {16'h00, 16'h10}, {16'h02, 16'h10}
    }

)(

    input                               RESET,
    input                               CLK,
    input                               WE,
    input          [PORT_ADDR_SIZE-1:0] ADDR_IN,
    input         [PORT_CACHE_BITS-1:0] DATA_IN,
    input       [PORT_CACHE_BITS/8-1:0] WMASK,
    output  reg                 [  7:0] HW_REGS[0:(2**HW_REGS_SIZE-1)],
    output  reg                 [  7:0] DATA_OUT

);

wire enable   = ( ADDR_IN[PORT_ADDR_SIZE-1:HW_REGS_SIZE] == BASE_WRITE_ADDRESS[PORT_ADDR_SIZE-1:HW_REGS_SIZE] ) ;   // upper x-bits of ADDR_IN should equal BASE_WRITE_ADDRESS for a successful read or write
wire valid_wr = WE && enable ;

integer i;
always @( posedge CLK ) begin
    
    if ( RESET ) begin
        // reset registers to initial values
        for (i = 0; i < RST_PARAM_SIZE; i = i + 1) begin
            if (ENDIAN == 1) begin
                HW_REGS['{RESET_VALUES[i][29:17], 1'b0}] <= RESET_VALUES[i][ 7:0] ;
                HW_REGS['{RESET_VALUES[i][29:17], 1'b1}] <= RESET_VALUES[i][15:8] ;
            end else begin
                HW_REGS['{RESET_VALUES[i][29:17], 1'b0}] <= RESET_VALUES[i][15:8] ;
                HW_REGS['{RESET_VALUES[i][29:17], 1'b1}] <= RESET_VALUES[i][ 7:0] ;
            end
        end
    end
    else
    begin
        for (i = 0; i < PORT_CACHE_BITS/8; i = i + 1) if (valid_wr && WMASK[i ^ ENDIAN]) HW_REGS[(ADDR_IN[HW_REGS_SIZE-1:0] | i)] <= DATA_IN[i*8+:8] ;
    end
    
end

endmodule
