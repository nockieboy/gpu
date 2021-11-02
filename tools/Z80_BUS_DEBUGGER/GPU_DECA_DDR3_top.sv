// *********************************************************************
//
// uCOM Z80 BUS DEBUGGER
// Version 1.00, 22 October, 2021.
//
//
// Written by Jonathan Nock.
//
//************************************************************************************************************************************************************
//************************************************************************************************************************************************************
//************************************************************************************************************************************************************
`timescale 1 ps/ 1 ps // 1 picosecond steps, 1 picosecond precision.

module GPU_DECA_DDR3_top #(

// ****************  8 bit GPU Parameters.
parameter int        HW_REGS_BITS            = 9,                // Sets the address size of the GPU's hardware register bits.
parameter int        GPU_MEMORY              = 32768,            // Defines total video RAM in the FPGA, including 1KB palette (132096)
                                                                 // For EP4CE10, use 41984
parameter int        NUM_MAGGIES             = 3,                // Number of MAGGIE layers available to GPU

// ****************  DDR3 Parameters.

parameter string     FPGA_VENDOR             = "Altera",         // (Only Altera for now) Use ALTERA, INTEL, LATTICE or XILINX.
parameter            FPGA_FAMILY             = "MAX 10",         // With Altera, use Cyclone III, Cyclone IV, Cyclone V, MAX 10,....
parameter bit        BHG_OPTIMIZE_SPEED      = 1,                // Use '1' for better FMAX performance, this will increase logic cell usage in the BrianHG_DDR3_PHY_SEQ module.
                                                                 // It is recommended that you use '1' when running slowest -8 Altera fabric FPGA above 300MHz or Altera -6 fabric above 350MHz.
parameter bit        BHG_EXTRA_SPEED         = 1,                // Use '1' for even better FMAX performance or when overclocking the core.  This will increase logic cell usage.

// ****************  System clock generation and operation.
parameter int        CLK_KHZ_IN              = 50000,            // PLL source input clock frequency in KHz.
parameter int        CLK_IN_MULT             = 40,               // Multiply factor to generate the DDR MTPS speed divided by 2.
parameter int        CLK_IN_DIV              = 4,                // Divide factor.  When CLK_KHZ_IN is 25000,50000,75000,100000,125000,150000, use 2,4,6,8,10,12.
parameter int        DDR_TRICK_MTPS_CAP      = 600,              // 0=off, Set a false PLL DDR data rate for the compiler to allow FPGA overclocking.  ***DO NOT USE.
                                                                
parameter string     INTERFACE_SPEED         = "Quarter",        // Either "Full", "Half", or "Quarter" speed for the user interface clock.
                                                                 // This will effect the controller's interface CMD_CLK output port frequency.

// ****************  DDR3 ram chip configuration settings
parameter int        DDR3_CK_MHZ             = ((CLK_KHZ_IN*CLK_IN_MULT/CLK_IN_DIV)/1000), // DDR3 CK clock speed in MHz.
parameter string     DDR3_SPEED_GRADE        = "-15E",           // Use 1066 / 187E, 1333 / -15E, 1600 / -125, 1866 / -107, or 2133 MHz / 093.
parameter int        DDR3_SIZE_GB            = 4,                // Use 0,1,2,4 or 8.  (0=512mb) Caution: Must be correct as ram chip size affects the tRFC REFRESH period.
parameter int        DDR3_WIDTH_DQ           = 16,               // Use 8 or 16.  The width of each DDR3 ram chip.

parameter int        DDR3_NUM_CHIPS          = 1,                // 1, 2, or 4 for the number of DDR3 RAM chips.
parameter int        DDR3_NUM_CK             = 1,                // Select the number of DDR3_CK & DDR3_CK# output pairs.
                                                                 // Optionally use 2 for 4 ram chips, if not 1 for each ram chip for best timing..
                                                                 // These are placed on a DDR DQ or DDR CK# IO output pins.

parameter int        DDR3_WIDTH_ADDR         = 15,               // Use for the number of bits to address each row.
parameter int        DDR3_WIDTH_BANK         = 3,                // Use for the number of bits to address each bank.
parameter int        DDR3_WIDTH_CAS          = 10,               // Use for the number of bits to address each column.

parameter int        DDR3_WIDTH_DM           = (DDR3_WIDTH_DQ*DDR3_NUM_CHIPS/8), // The width of the write data mask. (***Double when using multiple 4 bit DDR3 ram chips.)
parameter int        DDR3_WIDTH_DQS          = (DDR3_WIDTH_DQ*DDR3_NUM_CHIPS/8), // The number of DQS pairs.          (***Double when using multiple 4 bit DDR3 ram chips.)
parameter int        DDR3_RWDQ_BITS          = (DDR3_WIDTH_DQ*DDR3_NUM_CHIPS*8), // Must equal to total bus width across all DDR3 ram chips *8.

parameter int        DDR3_ODT_RTT            = 40,               // use 120, 60, 40, 30, 20 Ohm. or 0 to disable ODT.  (On Die Termination during write operation.)
parameter int        DDR3_RZQ                = 40,               // use 34 or 40 Ohm. (Output Drive Strength during read operation.)
parameter int        DDR3_TEMP               = 85,               // use 85,95,105. (Peak operating temperature in degrees Celsius.)

parameter int        DDR3_WDQ_PHASE          = 270,              // 270, Select the write and write DQS output clock phase relative to the DDR3_CK/CK#
parameter int        DDR3_RDQ_PHASE          = 0,                // 0,   Select the read latch clock for the read data and DQS input relative to the DDR3_CK.

parameter bit [3:0]  DDR3_MAX_REF_QUEUE      = 8,                // Defines the size of the refresh queue where refreshes will have a higher priority than incoming SEQ_CMD_ENA command requests.
                                                                 // *** Do not go above 8, doing so may break the data sheet's maximum ACTIVATE-to-PRECHARGE command period.
parameter bit [6:0]  IDLE_TIME_uSx10         = 10,               // Defines the time in 1/10uS until the command IDLE counter will allow low priority REFRESH cycles.
                                                                 // Use 10 for 1uS.  0=disable, 2 for a minimum effect, 127 maximum.

parameter bit        SKIP_PUP_TIMER          = 0,                // Skip timer during and after reset. ***ONLY use 1 for quick simulations.

parameter string     BANK_ROW_ORDER          = "BANK_ROW_COL",   // Only supports "ROW_BANK_COL" or "BANK_ROW_COL".  Choose to optimize your memory access.

parameter int        PORT_ADDR_SIZE          = (DDR3_WIDTH_ADDR + DDR3_WIDTH_BANK + DDR3_WIDTH_CAS + (DDR3_WIDTH_DM-1)),

// ************************************************************************************************************************************
// ****************  BrianHG_DDR3_COMMANDER configuration parameter settings for GPU project ******************************************
// ************************************************************************************************************************************
parameter int        PORT_R_TOTAL            = 4,                // Set the total number of DDR3 controller read ports, 1 to 16 max.
parameter int        PORT_W_TOTAL            = 3,                // Set the total number of DDR3 controller write ports, 1 to 16 max.
parameter int        PORT_VECTOR_SIZE        = 16,               // Sets the width of each port's VECTOR input and output.

// ************************************************************************************************************************************
// ***** DO NOT CHANGE THE NEXT 4 PARAMETERS FOR THIS VERSION OF THE BrianHG_DDR3_COMMANDER.sv... *************************************
parameter int        PORT_CACHE_BITS         = (8*DDR3_WIDTH_DM*8),                  // Note that this value must be a multiple of ' (8*DDR3_WIDTH_DQ*DDR3_NUM_CHIPS)* burst 8 '.
parameter int        CACHE_ADDR_WIDTH        = $clog2(PORT_CACHE_BITS/8),            // This is the number of LSB address bits which address all the available 8 bit bytes inside the cache word.
parameter int        DDR3_VECTOR_SIZE        = (PORT_ADDR_SIZE+4),                   // Sets the width of the VECTOR for the DDR3_PHY_SEQ controller.  4 bits for 16 possible read ports.
parameter int        CACHE_ROW_BASE          = (DDR3_WIDTH_CAS + (DDR3_WIDTH_DM-1)), // Sets the starting address bit where a new row & bank begins.
// ************************************************************************************************************************************

// PORT_'feature' = '{array a,b,c,d,..} Sets the feature for each DDR3 ram controller interface port 0 to port 15.
// The array is configured as: { port 1, port 2, port 3, port 4.... }
//
parameter bit [8:0]  PORT_R_DATA_WIDTH    [0:15] = '{  8,  8, 16, 16,128,128,128,128,128,128,128,128,128,128,128,128 }, 
parameter bit [8:0]  PORT_W_DATA_WIDTH    [0:15] = '{  8,  8, 16,128,128,128,128,128,128,128,128,128,128,128,128,128 }, 
                                                            // Use 8,16,32,64,128, or 256 bits, maximum = 'PORT_CACHE_BITS'
                                                            // As a precaution, this will prune/ignore unused data bits and write masks bits, however,
                                                            // all the data ports will still be 'PORT_CACHE_BITS' bits and the write masks will be 'PORT_CACHE_WMASK' bits.
                                                            // (a 'PORT_CACHE_BITS' bit wide data bus has 32 individual mask-able bytes (8 bit words))
                                                            // For ports sizes below 'PORT_CACHE_BITS', the data is stored and received in Big Endian.  

parameter bit [2:0]  PORT_R_PRIORITY      [0:15] = '{  1,  7,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 },
parameter bit [2:0]  PORT_W_PRIORITY      [0:15] = '{  2,  7,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 },
                                                            // Use 1 through 6 for normal operation.  Use 7 for above refresh priority.  Use 0 for bottom
                                                            // priority, only during free cycles once every other operation has been completed.
                                                            // Open row policy/smart row access only works between ports with identical
                                                            // priority.  If a port with a higher priority receives a request, even if another
                                                            // port's request matches the current page, the higher priority port will take
                                                            // precedence and force the ram controller to leave the current page.
                                                            // *(Only use 7 for small occasional access bursts which must take precedence above
                                                            //   all else, yet not consume memory access beyond the extended refresh requirements.)

parameter bit        PORT_R_CMD_STACK     [0:15] = '{  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 },
                                                            // Sets the size of the intermediate read command request stack.
                                                            // 0=4 level deep.  1=8 level deep.
                                                            // The size of the number of read commands built up in advance while the read channel waits
                                                            // for the DDR3_PHY_SEQ to return the read request data.  (Stored in logic cells)
                                                            // Multiple reads must be accumulated to allow an efficient continuous read burst.
                                                            // IE: Use 8 level deep when running a small data port width like 8 or 16 so sequential read cache
                                                            // hits continue through the command input allowing cache miss read req later-on in the req stream to be
                                                            // immediately be sent to the DDR3_PHY_SEQ before the DDR3 even returns the first read req data.

parameter bit [8:0]  PORT_W_CACHE_TOUT    [0:15] = '{256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256 },
                                                            // A timeout for the write cache to dump it's contents to ram.
                                                            // 0   = immediate writes, or no write cache.
                                                            // 256 = Wait up to 256 CMD_CLK clock cycles since the previous write req.
                                                            //       to the same 'PORT_CACHE_BITS' bit block before writing to ram.  Write reqs outside
                                                            //       the current 'PORT_CACHE_BITS' bit cache block clears the timer and forces an immediate write.

parameter bit        PORT_CACHE_SMART     [0:15] = '{  0,  1,  1,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 },
                                                            // When enabled, if an existing read cache exists at the same write request address,
                                                            // that read's cache will immediately be updated with the new write data.  (Only on the same port number...)
                                                            // This function may impact the FMAX for the system clock and increase LUT usage.
                                                            // *** Disable when designing a memory read/write testing algorithm.

parameter bit [8:0]  PORT_R_MAX_BURST     [0:15] = '{256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256 },
parameter bit [8:0]  PORT_W_MAX_BURST     [0:15] = '{256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256 },
                                                            // 1 through 256, 0=No sequential burst priority.
                                                            // Defines the maximum consecutive read or write burst commands from a single
                                                            // port if another read/write port requests exists with the same priority level,
                                                            // but their memory request exist in a different row.  * Every 1 counts for a BL8 burst.
                                                            // This will prevent a single continuous stream port from hogging up all the ram access time.
                                                            // IE: If set to 0, commander will seek if other read/write requests are ready before
                                                            // continuing access to the same port DDR3 access.

parameter bit        SMART_BANK                  = 0        // 1=ON, 0=OFF, With SMART_BANK enabled, the BrianHG_DDR3_COMMANDER will remember which
                                                            // ROW# has been activated in each DDR3 BANK# so that when prioritizing read and write
                                                            // ports of equal priority, multiple commands across multiple banks whose ROWs have
                                                            // matching existing activation will be prioritized/coalesced as if they were part of
                                                            // the sequential burst as PRECHARGE and ACTIVATE commands are not needed when bursting
                                                            // between active banks maintaining an unbroken read/write stream.
                                                            // (Of course the BrianHG_DDR3_PHY_SEQ is able to handle smart banking as well...)
                                                            // Note that enabling this feature uses additional logic cells and may impact FMAX.
                                                            // Disabling this feature will only coalesce commands in the current access ROW.
                                                            // Parameter 'BANK_ROW_ORDER' will define which address bits define the accessed BANK number.
)
(
// *****************************************************************************************************************
// ********** DECA Board's IOs.
// *****************************************************************************************************************

    //////////// CLOCK //////////
    input                           ADC_CLK_10,
    input                           MAX10_CLK1_50,
    input                           MAX10_CLK2_50,

    //////////// KEY //////////
    input              [1:0]     KEY,

    //////////// LED //////////
    output logic     [7:0]     LED,

    //////////// CapSense Button //////////
    inout                           CAP_SENSE_I2C_SCL,
    inout                           CAP_SENSE_I2C_SDA,

    //////////// Audio //////////
    inout                           AUDIO_BCLK,
    output                          AUDIO_DIN_MFP1,
    input                           AUDIO_DOUT_MFP2,
    inout                           AUDIO_GPIO_MFP5,
    output                          AUDIO_MCLK,
    input                           AUDIO_MISO_MFP4,
    inout                           AUDIO_RESET_n,
    output                          AUDIO_SCL_SS_n,
    output                          AUDIO_SCLK_MFP3,
    inout                           AUDIO_SDA_MOSI,
    output                          AUDIO_SPI_SELECT,
    inout                           AUDIO_WCLK,

    //////////// Flash //////////
    inout              [3:0]        FLASH_DATA,
    output                          FLASH_DCLK,
    output                          FLASH_NCSO,
    output                          FLASH_RESET_n,

    //////////// G-Sensor //////////
    output                          G_SENSOR_CS_n,
    input                           G_SENSOR_INT1,
    input                           G_SENSOR_INT2,
    inout                           G_SENSOR_SCLK,
    inout                           G_SENSOR_SDI,
    inout                           G_SENSOR_SDO,

    //////////// HDMI-TX //////////
    inout                           HDMI_I2C_SCL,
    inout                           HDMI_I2C_SDA,
    inout              [3:0]        HDMI_I2S,
    inout                           HDMI_LRCLK,
    inout                           HDMI_MCLK,
    inout                           HDMI_SCLK,
    output                          HDMI_TX_CLK,
    output            [23:0]        HDMI_TX_D,
    output                          HDMI_TX_DE,
    output                          HDMI_TX_HS,
    input                           HDMI_TX_INT,
    output                          HDMI_TX_VS,

    //////////// Light Sensor //////////
    output                          LIGHT_I2C_SCL,
    inout                           LIGHT_I2C_SDA,
    inout                           LIGHT_INT,

    //////////// MIPI //////////
    output                          MIPI_CORE_EN,
    output                          MIPI_I2C_SCL,
    inout                           MIPI_I2C_SDA,
    input                           MIPI_LP_MC_n,
    input                           MIPI_LP_MC_p,
    input              [3:0]        MIPI_LP_MD_n,
    input              [3:0]        MIPI_LP_MD_p,
    input                           MIPI_MC_p,
    output                          MIPI_MCLK,
    input              [3:0]        MIPI_MD_p,
    output                          MIPI_RESET_n,
    output                          MIPI_WP,

    //////////// Ethernet //////////
    input                           NET_COL,
    input                           NET_CRS,
    output                          NET_MDC,
    inout                           NET_MDIO,
    output                          NET_PCF_EN,
    output                          NET_RESET_n,
    input                           NET_RX_CLK,
    input                           NET_RX_DV,
    input                           NET_RX_ER,
    input              [3:0]        NET_RXD,
    input                           NET_TX_CLK,
    output                          NET_TX_EN,
    output             [3:0]        NET_TXD,

    //////////// Power Monitor //////////
    input                           PMONITOR_ALERT,
    output                          PMONITOR_I2C_SCL,
    inout                           PMONITOR_I2C_SDA,

    //////////// Humidity and Temperature Sensor //////////
    input                           RH_TEMP_DRDY_n,
    output                          RH_TEMP_I2C_SCL,
    inout                           RH_TEMP_I2C_SDA,

    //////////// MicroSD Card //////////
    output                          SD_CLK,
    inout                           SD_CMD,
    output                          SD_CMD_DIR,
    output                          SD_D0_DIR,
    inout                           SD_D123_DIR,
    inout              [3:0]        SD_DAT,
    input                           SD_FB_CLK,
    output                          SD_SEL,

    //////////// SW //////////
    input              [1:0]        SW,

    //////////// Board Temperature Sensor //////////
    output                          TEMP_CS_n,
    output                          TEMP_SC,
    inout                           TEMP_SIO,

    //////////// USB //////////
    input                           USB_CLKIN,
    output                          USB_CS,
    inout              [7:0]        USB_DATA,
    input                           USB_DIR,
    input                           USB_FAULT_n,
    input                           USB_NXT,
    output                          USB_RESET_n,
    output                          USB_STP,

    //////////// BBB Conector //////////
    input                           BBB_PWR_BUT,
    input                           BBB_SYS_RESET_n,
    inout             [43:0]        GPIO0_D,
    inout             [22:0]        GPIO1_D,


// *****************************************************************************************************************
// ********** Results from DDR3_PHY_SEQ, IO Names happen to match DECA Board's IO assignment pin names.
// *****************************************************************************************************************
output                       DDR3_RESET_n,  // DDR3 RESET# input pin.
output [DDR3_NUM_CK-1:0]     DDR3_CK_p,     // DDR3_CK ****************** YOU MUST SET THIS IO TO A DIFFERENTIAL LVDS or LVDS_E_3R
output [DDR3_NUM_CK-1:0]     DDR3_CK_n,     // DDR3_CK ****************** YOU MUST SET THIS IO TO A DIFFERENTIAL LVDS or LVDS_E_3R
                                            // ************************** port to generate the negative DDR3_CK# output.
                                            // ************************** Generate an additional DDR_CK_p pair for every DDR3 ram chip. 

output                       DDR3_CKE,      // DDR3 CKE

output                       DDR3_CS_n,     // DDR3 CS#
output                       DDR3_RAS_n,    // DDR3 RAS#
output                       DDR3_CAS_n,    // DDR3 CAS#
output                       DDR3_WE_n,     // DDR3 WE#
output                       DDR3_ODT,      // DDR3 ODT

output [DDR3_WIDTH_ADDR-1:0] DDR3_A,        // DDR3 multiplexed address input bus
output [DDR3_WIDTH_BANK-1:0] DDR3_BA,       // DDR3 Bank select

output [DDR3_WIDTH_DM-1:0]   DDR3_DM,       // DDR3 Write data mask. DDR3_DM[0] drives write DQ[7:0], DDR3_DM[1] drives write DQ[15:8]...
inout  [DDR3_WIDTH_DQ-1:0]   DDR3_DQ,       // DDR3 DQ data IO bus.
inout  [DDR3_WIDTH_DQS-1:0]  DDR3_DQS_p,    // DDR3 DQS ********* IOs. DQS[0] drives DQ[7:0], DQS[1] drives DQ[15:8], DQS[2] drives DQ[23:16]...
inout  [DDR3_WIDTH_DQS-1:0]  DDR3_DQS_n     // DDR3 DQS ********* IOs. DQS[0] drives DQ[7:0], DQS[1] drives DQ[15:8], DQS[2] drives DQ[23:16]...
                                            // ****************** YOU MUST SET THIS IO TO A DIFFERENTIAL LVDS or LVDS_E_3R
                                            // ****************** port to generate the negative DDR3_DQS# IO.
);


// *****************************************************
// ********* BrianHG_DDR3_PHY_SEQ logic / wires.
// *****************************************************
logic RST_IN,CLK_IN,RST_OUT,PLL_LOCKED,DDR3_CLK,CMD_CLK,DDR3_CLK_50,DDR3_CLK_25;
logic SEQ_CAL_PASS, DDR3_READY;
logic [7:0] RDCAL_data ;

// ****************************************
// DDR3 Controller Interface Logic.
// ****************************************
logic                         CMD_R_busy          [0:PORT_R_TOTAL-1];  // For each port, when high, the DDR3 controller will not accept an incoming command on that port.
logic                         CMD_W_busy          [0:PORT_W_TOTAL-1];  // For each port, when high, the DDR3 controller will not accept an incoming command on that port.

logic                         CMD_write_req       [0:PORT_W_TOTAL-1];  // Write request for each port.

logic [PORT_ADDR_SIZE-1:0]    CMD_waddr           [0:PORT_W_TOTAL-1];  // Address pointer for each write memory port.
logic [PORT_CACHE_BITS-1:0]   CMD_wdata           [0:PORT_W_TOTAL-1];  // During a 'CMD_write_req', this data will be written into the DDR3 at address 'CMD_addr'.
                                                                       // Each port's 'PORT_DATA_WIDTH' setting will prune the unused write data bits.
logic [PORT_CACHE_BITS/8-1:0] CMD_wmask           [0:PORT_W_TOTAL-1];  // Write mask for the individual bytes within the 256 bit data bus.
                                                                       // When low, the associated byte will not be written.
                                                                       // Each port's 'PORT_DATA_WIDTH' setting will prune the unused mask bits.

logic [PORT_ADDR_SIZE-1:0]    CMD_raddr           [0:PORT_R_TOTAL-1];  // Address pointer for each read memory port.
logic                         CMD_read_req        [0:PORT_R_TOTAL-1];  // Performs a read request for each port.
logic [PORT_VECTOR_SIZE-1:0]  CMD_read_vector_in  [0:PORT_R_TOTAL-1];  // The contents of the 'CMD_read_vector_in' during a 'CMD_read_req' will be sent to the
                                                                       // 'CMD_read_vector_out' in parallel with the 'CMD_read_data' during the 'CMD_read_ready' pulse.

logic                         CMD_read_ready      [0:PORT_R_TOTAL-1];  // Goes high for 1 clock when the read command data is valid.
logic [PORT_CACHE_BITS-1:0]   CMD_read_data       [0:PORT_R_TOTAL-1];  // Valid read data when 'CMD_read_ready' is high.
logic [PORT_VECTOR_SIZE-1:0]  CMD_read_vector_out [0:PORT_R_TOTAL-1];  // Returns the 'CMD_read_vector_in' which was sampled during the 'CMD_read_req' in parallel
                                                                       // with the 'CMD_read_data'.  This allows for multiple post reads where the output
                                                                       // has a destination pointer. 
logic [PORT_ADDR_SIZE-1:0]    CMD_read_addr_out   [0:PORT_R_TOTAL-1];  // A return of the address which was sent in with the read request.

logic                         CMD_R_priority_boost [0:PORT_R_TOTAL-1]; // Boosts the port's 'PORT_R_PRIORITY' parameter by a weight of 8 when set.
logic                         CMD_W_priority_boost [0:PORT_W_TOTAL-1]; // Boosts the port's 'PORT_W_PRIORITY' parameter by a weight of 8 when set.



// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
// This module is the complete BrianHG_DDR3_CONTROLLER system assembled initiating:
//
//   - BrianHG_DDR3_COMMANDER.sv         -> Handles the multi-port read and write requests and cache, commands the BrianHG_DDR3_PHY_SEQ.sv sequencer.
//   - BrianHG_DDR3_CMD_SEQUENCER.sv     -> Takes in the read and write requests, generates a stream of DDR3 commands to execute the read and writes.
//   - BrianHG_DDR3_PHY_SEQ.sv           -> DDR3 PHY sequencer.          (If you want just a compact DDR3 controller, skip the DDR3_CONTROLLER_top & DDR3_COMMANDER and just use this module alone.)
//   - BrianHG_DDR3_PLL.sv               -> Generates the system clocks. (*** Currently Altera/Intel only ***)
//   - BrianHG_DDR3_GEN_tCK.sv           -> Generates all the tCK count clock cycles for the DDR3_PHY_SEQ so that the DDR3 clock cycle requirements are met.
//   - BrianHG_DDR3_FIFOs.sv             -> Serial shifting logic FIFOs.
//   - BrianHG_DDR3_IO_PORT_ALTERA.sv    -> Physical DDR IO pin driver specifically for Altera/Intel Cyclone III/IV/V and MAX10.
//   - BrianHG_DDR3_IO_PORT_LATTICE.sv   -> Physical DDR IO pin driver specifically for Lattice ECP5/LFE5U series. (*** Coming soon ***)
//   - BrianHG_DDR3_IO_PORT_XILINX.sv    -> Physical DDR IO pin driver specifically for Xilinx Artix 7 series.     (*** Coming soon ***)
//
// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
BrianHG_DDR3_CONTROLLER_top #(.FPGA_VENDOR         (FPGA_VENDOR       ),   .FPGA_FAMILY        (FPGA_FAMILY       ),   .INTERFACE_SPEED    (INTERFACE_SPEED ),
                              .BHG_OPTIMIZE_SPEED  (BHG_OPTIMIZE_SPEED),   .BHG_EXTRA_SPEED    (BHG_EXTRA_SPEED   ),
                              .CLK_KHZ_IN          (CLK_KHZ_IN        ),   .CLK_IN_MULT        (CLK_IN_MULT       ),   .CLK_IN_DIV         (CLK_IN_DIV      ),

                              .DDR3_CK_MHZ         (DDR3_CK_MHZ       ),   .DDR3_SPEED_GRADE   (DDR3_SPEED_GRADE  ),   .DDR3_SIZE_GB       (DDR3_SIZE_GB    ),
                              .DDR3_WIDTH_DQ       (DDR3_WIDTH_DQ     ),   .DDR3_NUM_CHIPS     (DDR3_NUM_CHIPS    ),   .DDR3_NUM_CK        (DDR3_NUM_CK     ),
                              .DDR3_WIDTH_ADDR     (DDR3_WIDTH_ADDR   ),   .DDR3_WIDTH_BANK    (DDR3_WIDTH_BANK   ),   .DDR3_WIDTH_CAS     (DDR3_WIDTH_CAS  ),
                              .DDR3_WIDTH_DM       (DDR3_WIDTH_DM     ),   .DDR3_WIDTH_DQS     (DDR3_WIDTH_DQS    ),   .DDR3_ODT_RTT       (DDR3_ODT_RTT    ),
                              .DDR3_RZQ            (DDR3_RZQ          ),   .DDR3_TEMP          (DDR3_TEMP         ),   .DDR3_WDQ_PHASE     (DDR3_WDQ_PHASE  ), 
                              .DDR3_RDQ_PHASE      (DDR3_RDQ_PHASE    ),   .DDR3_MAX_REF_QUEUE (DDR3_MAX_REF_QUEUE),   .IDLE_TIME_uSx10    (IDLE_TIME_uSx10 ),
                              .SKIP_PUP_TIMER      (SKIP_PUP_TIMER    ),   .BANK_ROW_ORDER     (BANK_ROW_ORDER    ),   .DDR_TRICK_MTPS_CAP (DDR_TRICK_MTPS_CAP),

                              .PORT_ADDR_SIZE      (PORT_ADDR_SIZE    ),

                              .PORT_R_TOTAL        (PORT_R_TOTAL      ),   .PORT_W_TOTAL       (PORT_W_TOTAL      ),   .PORT_VECTOR_SIZE   (PORT_VECTOR_SIZE ),
                              .PORT_R_DATA_WIDTH   (PORT_R_DATA_WIDTH ),   .PORT_W_DATA_WIDTH  (PORT_W_DATA_WIDTH ),
                              .PORT_R_PRIORITY     (PORT_R_PRIORITY   ),   .PORT_W_PRIORITY    (PORT_W_PRIORITY   ),   .PORT_R_CMD_STACK   (PORT_R_CMD_STACK ),
                              .PORT_CACHE_SMART    (PORT_CACHE_SMART  ),   .PORT_W_CACHE_TOUT  (PORT_W_CACHE_TOUT ),
                              .PORT_R_MAX_BURST    (PORT_R_MAX_BURST  ),   .PORT_W_MAX_BURST   (PORT_W_MAX_BURST  ),   .SMART_BANK         (SMART_BANK       )

) BHG_DDR3_CONTROLLER_top (             

                              // *** Interface Reset, Clocks & Status. ***
                              .RST_IN               (RST_IN               ),                   .RST_OUT              (RST_OUT              ),
                              .CLK_IN               (CLK_IN               ),                   .CMD_CLK              (CMD_CLK              ),
                              .DDR3_READY           (DDR3_READY           ),                   .SEQ_CAL_PASS         (SEQ_CAL_PASS         ),
                              .PLL_LOCKED           (PLL_LOCKED           ),                   .DDR3_CLK             (DDR3_CLK             ),
                              .DDR3_CLK_50          (DDR3_CLK_50          ),                   .DDR3_CLK_25          (DDR3_CLK_25          ),

                              // *** DDR3 Controller Write functions ***
                              .CMD_W_busy           (CMD_W_busy           ),                   .CMD_write_req        (CMD_write_req        ),
                              .CMD_waddr            (CMD_waddr            ),                   .CMD_wdata            (CMD_wdata            ),
                              .CMD_wmask            (CMD_wmask            ),                   .CMD_W_priority_boost (CMD_W_priority_boost ),
                              
                              // *** DDR3 Controller Read functions ***
                              .CMD_R_busy           (CMD_R_busy           ),                   .CMD_read_req         (CMD_read_req         ),
                              .CMD_raddr            (CMD_raddr            ),                   .CMD_read_vector_in   (CMD_read_vector_in   ),
                              .CMD_read_ready       (CMD_read_ready       ),                   .CMD_read_data        (CMD_read_data        ),
                              .CMD_read_vector_out  (CMD_read_vector_out  ),                   .CMD_read_addr_out    (CMD_read_addr_out    ),
                              .CMD_R_priority_boost (CMD_R_priority_boost ),


                              // *** DDR3 Ram Chip IO Pins ***           
                              .DDR3_CK_p  (DDR3_CK_p  ),    .DDR3_CK_n  (DDR3_CK_n  ),     .DDR3_CKE     (DDR3_CKE     ),     .DDR3_CS_n (DDR3_CS_n ),
                              .DDR3_RAS_n (DDR3_RAS_n ),    .DDR3_CAS_n (DDR3_CAS_n ),     .DDR3_WE_n    (DDR3_WE_n    ),     .DDR3_ODT  (DDR3_ODT  ),
                              .DDR3_A     (DDR3_A     ),    .DDR3_BA    (DDR3_BA    ),     .DDR3_DM      (DDR3_DM      ),     .DDR3_DQ   (DDR3_DQ   ),
                              .DDR3_DQS_p (DDR3_DQS_p ),    .DDR3_DQS_n (DDR3_DQS_n ),     .DDR3_RESET_n (DDR3_RESET_n ),
                                        
                              // debug IO
                              .RDCAL_data (RDCAL_data ),    .reset_phy (DB232_rx3[7]),     .reset_cmd    (DB232_rx3[6])  );

// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************


// Set default address buffer values for those not normally controlled by the GPU
assign   GPIO0_D[32]      = 0 ; // HI_OE - LOW to enable
assign   GPIO0_D[33]      = 1 ; // HI_DIR - HIGH for A>B direction (to FPGA)
assign   GPIO0_D[42]      = 0 ; // LO_OE - LOW to enable
assign   GPIO0_D[43]      = 1 ; // LO_DIR - HIGH for A>B direction (to FPGA)
// Set default values for unused Control Bus Outputs
assign   GPIO0_D[9]       = 0 ; // WR output
assign   GPIO0_D[10]      = 0 ; // M_REQ output
assign   GPIO0_D[11]      = 0 ; // RD output
assign   GPIO0_D[12]      = 0 ; // BUS_REQ output
assign   GPIO0_D[13]      = 0 ; // IO_REQ output


// ***********************************************************************************************************************************************************
// ****  GPU instance.  **************************************************************************************************************************************
// ***********************************************************************************************************************************************************
GPU #(

   .HW_REGS     ( HW_REGS_BITS  ),
   .GPU_MEM     ( GPU_MEMORY    ),
   .MAGGIES     ( NUM_MAGGIES   )
   
) GPU_CORE (

   //.clk54m      ( MAX10_CLK1_50 ),
   .clk         ( DDR3_CLK_25   ),
   .clk_2x      ( DDR3_CLK_50   ),
   //.clk         ( DDR3_CLK_50   ),
   //.clk_2x      ( DDR3_CLK      ),
   //.clk_2x_phase( DDR3_CLK_25   ),
   .com_clk     ( CLK_IN        ),
   
   .Z80_CLK     ( GPIO1_D[3]    ),
   .Z80_M1      ( GPIO1_D[8]    ),
   .Z80_MREQ    ( GPIO1_D[6]    ),
   .Z80_WR      ( GPIO1_D[5]    ),
   .Z80_RD      ( GPIO1_D[4]    ),
   .Z80_IORQ    ( GPIO1_D[7]    ),
   .Z80_WAIT    ( GPIO0_D[8]    ),
   .Z80_WAIT_IN ( GPIO1_D[21]   ),
   .IEI         (    ),
   .Z80_RST     ( GPIO1_D[10]   ),
   .RESET_PIN   ( KEY[0]        ), // enables button 0 to reset system (MUST be wired to something, or GPU sits in reset permanently)
   
   .Z80_ADDR    ({ GPIO0_D[14], GPIO0_D[15], GPIO0_D[16], GPIO0_D[17], GPIO0_D[18], GPIO0_D[19], GPIO0_D[20], GPIO0_D[21],
                   GPIO0_D[26], GPIO0_D[27], GPIO0_D[28], GPIO0_D[29], GPIO0_D[30], GPIO0_D[31], GPIO0_D[34], GPIO0_D[35],
                   GPIO0_D[36], GPIO0_D[37], GPIO0_D[38], GPIO0_D[39], GPIO0_D[40], GPIO0_D[41]
                }),
   
   .Z80_DATA    ({ GPIO1_D[11], GPIO1_D[12], GPIO1_D[13], GPIO1_D[14], GPIO1_D[15], GPIO1_D[16], GPIO1_D[17], GPIO1_D[18] }),

   
   .EA_DIR      ( GPIO0_D[23]      ),
   .EA_OE       ( GPIO0_D[22]      ),
   .DIR_245     ( GPIO1_D[20]      ),
   .OE_245      ( GPIO1_D[19]      ),
   
   .pixel_clk   ( HDMI_TX_CLK      ),
   .hs          ( HDMI_TX_HS       ),
   .vs          ( HDMI_TX_VS       ),
   .vde         ( HDMI_TX_DE       ),
   .b           ( HDMI_TX_D[7:0]   ),
   .g           ( HDMI_TX_D[15:8]  ),
   .r           ( HDMI_TX_D[23:16] ),
   
   .uart_txd    (    ),
   .uart_rxd    (    ),
   .LED_txd     (    ),
   .LED_rdx     (    ),
   
   .PS2_CLK     (    ),
   .PS2_DAT     (    ),
   
   .STATUS_LED  ( /*LED[7]*/ ),
   
   .Z80_INT_RQ  (    ),
   .IEO         (    ),
   .SPEAKER     (    ),
   

   // ****** RS232 Debugger Write data through to GPU FPGA Block Ram  ******
	.DEBUG_WE    ( DB232_wreq_dly ), // RS232 debugger write byte to GPU's FPGA core memory
	.DEBUG_ADDR  ( DB232_addr     ), // RS232 debugger write byte to GPU's FPGA core memory
	.DEBUG_DATA  ( DB232_wdat     ), // RS232 debugger write byte to GPU's FPGA core memory
	.DEBUG_VIDON ( 1'b1           ), // Force video output on even though Z80 software switch has it off.



   // *********************************
   // *** Z80 <-> System RAM Access ***
   // *********************************
   .CMD_W_busy      (                       CMD_W_busy     [1]   ), // High when a write req is not allowed to take place.
   .CMD_waddr       (    (PORT_ADDR_SIZE)'( CMD_waddr      [1] ) ), // Z80 requested write address.
   .CMD_write_req   (                       CMD_write_req  [1]   ), // Flag HIGH for 1 CMD_CLK when writing to RAM
   .CMD_write_data  (   (PORT_CACHE_BITS)'( CMD_wdata      [1] ) ), // Data from Z80 to be written into RAM.
   .CMD_write_mask  ( (PORT_CACHE_BITS/8)'( CMD_wmask      [1] ) ), // Write data enable mask to RAM.
   .CMD_R_busy      (                       CMD_R_busy     [1]   ), // High when a read req is not allowed to take place.
   .CMD_raddr       (    (PORT_ADDR_SIZE)'( CMD_raddr      [1] ) ), // Z80 requested read address.
   .CMD_read_req    (                       CMD_read_req   [1]   ), // Flag HIGH for at least 1 clock when reading from DDR3 RAM
   .CMD_read_ready  (                       CMD_read_ready [1]   ), // One-shot signal from mux or DDR3_Controller that data is ready
   .CMD_read_data   (                 (8)'( CMD_read_data  [1] ) ), // Read Data from RAM to be sent to Z80.

   // **************************************
   // *** GEOMETRY <-> System RAM Access ***
   // **************************************
   .GEO_CMD_W_busy       (                       CMD_W_busy     [2]   ), // Geometry write pixel data
   .GEO_CMD_waddr        (    (PORT_ADDR_SIZE)'( CMD_waddr      [2] ) ), // 
   .GEO_CMD_write_req    (                       CMD_write_req  [2]   ), // 
   .GEO_CMD_write_data   (   (PORT_CACHE_BITS)'( CMD_wdata      [2] ) ), // 
   .GEO_CMD_write_mask   ( (PORT_CACHE_BITS/8)'( CMD_wmask      [2] ) ), // 
   .GEO_CMD_R_busy       (                       CMD_R_busy     [2]   ), // Geometry read pixel data on the read/modify write port.
   .GEO_CMD_raddr        (    (PORT_ADDR_SIZE)'( CMD_raddr      [2] ) ), // To optimize DDR3 performance, this read channel must be on the same port
   .GEO_CMD_read_req     (                       CMD_read_req   [2]   ), // number as the write data channel to use and share the SMART_CACHE feature.
   .GEO_CMD_read_ready   (                       CMD_read_ready [2]   ), // 
   .GEO_CMD_read_data    (                (16)'( CMD_read_data  [2] ) ), // 
   .GEO_CMD_R_busy_C     (                       CMD_R_busy     [3]   ), // Geometry "COPY" read pixel channel.
   .GEO_CMD_raddr_C      (    (PORT_ADDR_SIZE)'( CMD_raddr      [3] ) ), // To optimize DDR3 performance, this read channel must be separate of
   .GEO_CMD_read_req_C   (                       CMD_read_req   [3]   ), // the write pixel data channel so it will have it's own read cache
   .GEO_CMD_read_ready_C (                       CMD_read_ready [3]   ), // which will usually be separate of the destination bitmap.
   .GEO_CMD_read_data_C  (                (16)'( CMD_read_data  [3] ) )  // 

);

assign   CMD_read_vector_in  [1] = 0 ; // When not in use, just set to 0.
assign   CMD_R_priority_boost[1] = 0 ; // When not in use, just set to 0.
assign   CMD_W_priority_boost[1] = 0 ; // When not in use, just set to 0.

assign   CMD_read_vector_in  [2] = 0 ; // When not in use, just set to 0.
assign   CMD_R_priority_boost[2] = 0 ; // When not in use, just set to 0.
assign   CMD_W_priority_boost[2] = 0 ; // When not in use, just set to 0.

assign   CMD_read_vector_in  [3] = 0 ; // When not in use, just set to 0.
assign   CMD_R_priority_boost[3] = 0 ; // When not in use, just set to 0.



logic  RS232_RXD      ;
logic  RS232_TXD      ;
assign GPIO0_D[6] = RS232_TXD  ; // Assign the RS232 debugger TXD output pin.
assign GPIO0_D[7] = 1'bz       ; // Make this IO into a tri-state input.
assign RS232_RXD  = GPIO0_D[7] ; // Assign the RS232 debugger RXD input pin.


// HDMI I2C configuration.
I2C_HDMI_Config u_I2C_HDMI_Config (
   .iCLK        ( MAX10_CLK1_50 ),
   .iRST_N      ( !RST_IN       ),
   .I2C_SCLK    ( HDMI_I2C_SCL  ),
   .I2C_SDAT    ( HDMI_I2C_SDA  ),
   .HDMI_TX_INT ( HDMI_TX_INT   )
);



// ********************************************************************************************
// ********************************************************************************************
// ********* Simple hard wiring of read and write port 0 to the RS232-Debugger module.
// ********************************************************************************************
// ********************************************************************************************
localparam   RS232_MEM_ADR_SIZE = 20 ; // Maximum = 20, IE 15 seconds to transfer the entire 1 megabyte by RS232...

logic                          RS232_RST_OUT  ;
logic                          RS232_TXD_LED  ;
logic                          RS232_RXD_LED  ;
logic                          DB232_rreq     ;
logic                          DB232_rrdy     ;
logic                          DB232_rrdy_dly ; // The DB232_rrdy_dly is for a single low to high transition.
logic                          DB232_wreq     ;
logic [RS232_MEM_ADR_SIZE-1:0] DB232_addr     ;
logic [7:0]                    DB232_wdat     ;
logic [7:0]                    DB232_rdat     ;
logic [7:0]                    DB232_tx0      ;
logic [7:0]                    DB232_tx1      ;
logic [7:0]                    DB232_tx2      ;
logic [7:0]                    DB232_tx3      ;
logic [7:0]                    DB232_rx0      ;
logic [7:0]                    DB232_rx1      ;
logic [7:0]                    DB232_rx2      ;
logic [7:0]                    DB232_rx3      ;

logic                          Z80_rreq       ;
logic                          Z80_rrdy       ;
logic                          Z80_rrdy_dly   ;
//logic                          Z80_wreq       ; // These probably aren't needed as control signals already exist for the Z80_Bridge
//logic [RS232_MEM_ADR_SIZE-1:0] Z80_addr       ;
//logic [7:0]                    Z80_wdat       ;
//logic [7:0]                    Z80_rdat       ;

// ******************************************************************************************************
// This module is a test RS232 bridge which uses BrianHG's RS232_Debugger.exe Windows app.
// ******************************************************************************************************
rs232_debugger #(

   .CLK_IN_HZ     ( CLK_KHZ_IN*CLK_IN_MULT/CLK_IN_DIV*250 ),
   .BAUD_RATE     ( 921600                                ),
   .ADDR_SIZE     ( RS232_MEM_ADR_SIZE                    ),
   .READ_REQ_1CLK ( 0                                     )
   
) rs232_debug (

   .clk         ( DDR3_CLK_25   ), // System clock.  Recommend at least 20MHz for the 921600 baud rate.
   .cmd_rst     ( RS232_RST_OUT ), // When sent by the PC RS232_Debugger utility this outputs a high signal for 8 clock cycles.
   .rxd         ( RS232_RXD     ), // Connect this to the RS232 RXD input pin.
   .txd         ( RS232_TXD     ), // Connect this to the RS232 TXD output pin.
   .LED_txd     ( RS232_TXD_LED ), // Optionally wire this to a LED it will go high whenever the RS232 TXD is active.
   .LED_rxd     ( RS232_RXD_LED ), // Optionally wire this to a LED it will go high whenever the RS232 RXD is active.
   .host_rd_req ( DB232_rreq    ), // This output will pulse high for 1 clock when a read request is taking place.
   .host_rd_rdy ( DB232_rrdy    ), // This input should be set high once the 'host_rdata[7:0]' input contains valid data.
   .host_wr_ena ( DB232_wreq    ), // This output will pulse high for 1 clock when a write request is taking place.
   .host_addr   ( DB232_addr    ), // This output contains the requested read and write address.
   .host_wdata  ( DB232_wdat    ), // This output contains the source RS232 8bit data to be written.
   .host_rdata  ( DB232_rdat    ), // This input receives the 8 bit ram data to be sent to the RS232.
   .in0         ( DB232_tx0     ),
   .in1         ( DB232_tx1     ),
   .in2         ( DB232_tx2     ),
   .in3         ( DB232_tx3     ),
   .out0        ( DB232_rx0     ),
   .out1        ( DB232_rx1     ),
   .out2        ( DB232_rx2     ),
   .out3        ( DB232_rx3     )
   
);

logic [15:0] cnt_read ;

assign RST_IN = RS232_RST_OUT  ; // The BrianHG_DDR3_PLL module has a reset generator.  This external one is optional.
assign CLK_IN = MAX10_CLK1_50  ; // Assign the reference 50MHz pll.

logic [7:0] p0_data ;
logic       p0_drdy ;

// cross clock domain delay pipes.
logic       DB232_wreq_dly ,
            DB232_rreq_dly ,
            p0_drdy_dly    ; 

// Latch the read data from port 0 on the CMD_CLK clock.
always_ff @(posedge CMD_CLK) begin 

   if (RST_OUT) begin // RST_OUT is clocked on the CMD_CLK source.
      
      CMD_read_req[0]         <= 0 ;
      CMD_raddr[0]            <= 0 ;
      CMD_read_vector_in[0]   <= 0 ;
      CMD_R_priority_boost[0] <= 0 ;
      CMD_write_req[0]        <= 0 ;
      CMD_waddr[0]            <= 0 ;
      CMD_wdata[0]            <= 0 ;
      CMD_wmask[0]            <= 0 ;
      CMD_W_priority_boost[0] <= 0 ;

   end else begin
                                                 
      // Wire the 8 bit write port.  We can get away with crossing a clock boundary with the write port.
      // Since there is no busy for the RS232 debugger write command, write port[0]'s priority was made 7 so it overrides everything else.

      CMD_waddr[0]     <= (PORT_ADDR_SIZE)'(DB232_addr)     ; // Set the RS232 write address.
      CMD_wdata[0]     <= (PORT_CACHE_BITS)'(DB232_wdat)    ; // Set the RS232 write data.
      CMD_wmask[0]     <= (PORT_CACHE_BITS/8)'(1)           ; // 8 bit write data has only 1 write mask bit.

      DB232_wreq_dly   <=  DB232_wreq                       ; // Delay the write request as we are crossing clock boundaries and we want the
                                                              // address and data setup 1 clock early.  We know this can work as the RS232 debugger module
                                                              // holds the data and address for at least 1 clock.
      CMD_write_req[0] <=  DB232_wreq_dly && !CMD_W_busy[0] ; // 1 clock delays write request.

      // Wire the 8 bit read port address.  When changing clock domains, we rely on a trick where the RS232 debugger keeps the
      // DB232_rreq high until it receives a result from the CMD_read_ready.  BrianHG_DDR3_CONTROLLER_top will see this as
      // many continuous requests at the same address and provide a continuous CMD_read_ready result as the internal
      // smart cache has only a clock cycle delay once the initial DDR Ram has been read.

      DB232_rreq_dly   <=  DB232_rreq                       ; // Create a delayed read request.  Same idea as above...
      CMD_read_req[0]  <=  DB232_rreq_dly && !CMD_R_busy[0] ; // Read request.
      CMD_raddr[0]     <= (PORT_ADDR_SIZE)'(DB232_addr)     ; // Set the RS232 read address.

      if (CMD_read_ready[0]) begin // If the read data is ready
      
         p0_data <= 8'(CMD_read_data[0]) ; // Clean latch the read data.
         p0_drdy <= 1                    ; // Set the data ready flag
         
      end else begin
      
         p0_drdy <= 0                    ;
         
      end

   end // !reset

end // @CMD_CLK


// *********  These functions operate on the 50MHz CLK_IN with the RS232 Debugger.
always_ff @(posedge DDR3_CLK_25) begin 

   if (RS232_RST_OUT) begin                 // RS232_RST_OUT is clocked on the CLK_IN source.
       
      DB232_rrdy     <= 0 ;
      DB232_rdat     <= 0 ;
      DB232_rrdy_dly <= 0 ;
      cnt_read       <= 0 ;
        
   end else begin
         
      // Transfer the read data from the CMD_CLK domain to the CLK_IN domain.
      p0_drdy_dly    <= p0_drdy    ;                                    // Delay the read ready from the other clock domain.
      DB232_rrdy     <= p0_drdy    ;// CMD_read_ready[0]              ; // Return the read data ready flag.
      DB232_rdat     <= p0_data    ;// 8'(CMD_read_data[0])           ; // Return the read data.

      // Detect the toggle Create a read command counter.
      DB232_rrdy_dly <= DB232_rrdy ;
      if (DB232_rrdy && !DB232_rrdy_dly) cnt_read <= cnt_read + 1'b1 ;

   end // !reset

   DB232_tx3[7:0] <= RDCAL_data[7:0] ; // Send out read calibration data.
   DB232_tx1[7:0] <= cnt_read[7:0]   ;
   DB232_tx2[7:0] <= cnt_read[15:8]  ;

end // @CLK_IN


// Show LEDs and send them to one of the DB232 debugger display ports.
always_ff @(posedge DDR3_CLK_25) begin         // Make sure the signals driving LED's aren't route optimized for the LED's IO pin location.

    DB232_tx0[0]   <= RS232_TXD_LED ; // RS232 Debugger TXD status LED
    DB232_tx0[1]   <= 1'b0          ; // Turn off LED.
    DB232_tx0[2]   <= PLL_LOCKED    ;
    DB232_tx0[3]   <= SEQ_CAL_PASS  ; // Turn off LED.
    DB232_tx0[4]   <= DDR3_READY    ;
    DB232_tx0[5]   <= 1'b0          ;
    DB232_tx0[6]   <= 1'b0          ; // Turn off LED.
    DB232_tx0[7]   <= RS232_RXD_LED ; // RS232 Debugger RXD status LED

    LED            <= 8'hff ^ RDCAL_data ^  8'((RS232_TXD_LED || RS232_RXD_LED)<<7); // Pass the calibration data to the LEDs.
    
end


// ******************************************************************************************************
// This clears up the 'output port has no driver' warnings.
// ******************************************************************************************************
assign NET_TXD          = 0 ;
assign AUDIO_DIN_MFP1   = 0 ;
assign AUDIO_MCLK       = 0 ;
assign AUDIO_SCL_SS_n   = 0 ;
assign AUDIO_SCLK_MFP3  = 0 ;
assign AUDIO_SPI_SELECT = 0 ;
assign FLASH_DCLK       = 0 ;
assign FLASH_NCSO       = 0 ;
assign FLASH_RESET_n    = 0 ;
assign G_SENSOR_CS_n    = 1 ;
assign LIGHT_I2C_SCL    = 0 ;
assign MIPI_CORE_EN     = 0 ;
assign MIPI_I2C_SCL     = 0 ;
assign MIPI_MCLK        = 0 ;
assign MIPI_RESET_n     = 0 ;
assign MIPI_WP          = 0 ;
assign NET_MDC          = 0 ;
assign NET_PCF_EN       = 0 ;
assign NET_RESET_n      = 0 ;
assign NET_TX_EN        = 0 ;
assign PMONITOR_I2C_SCL = 0 ;
assign RH_TEMP_I2C_SCL  = 0 ;
assign SD_CLK           = 0 ;
assign SD_CMD_DIR       = 0 ;
assign SD_D0_DIR        = 0 ;
assign SD_SEL           = 0 ;
assign TEMP_CS_n        = 1 ;
assign TEMP_SC          = 0 ;
assign USB_CS           = 0 ;
assign USB_RESET_n      = 0 ;
assign USB_STP          = 0 ;


endmodule
