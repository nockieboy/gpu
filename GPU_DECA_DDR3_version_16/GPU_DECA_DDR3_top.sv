// ***********************************************************************************************************************************************************
//
// GPU_DECA_DDR3_top.sv
//
// Implements a GPU v16 core with the BrianHG_DDR3_CONTROLLER_top DDR3 controller.
//
// Version 1.70, 7th March, 2022.
//
// 400MHz, Quarter rate build.
//
// NEW -> SD Card interface.
//
// Written by Brian Guralnick and Jonathan Nock.
//
// For public use.
//
// Leave questions related to: the DDR3 controller in https://www.eevblog.com/forum/fpga/brianhg_ddr3_controller-open-source-ddr3-controller/
//                             the general project in https://www.eevblog.com/forum/fpga/fpga-vga-controller-for-8-bit-computer/
//
//************************************************************************************************************************************************************
//************************************************************************************************************************************************************
//************************************************************************************************************************************************************
`timescale 1 ps/ 1 ps // 1 picosecond steps, 1 picosecond precision.

module GPU_DECA_DDR3_top #(

// ************************************************************************************************************************************
// ****************  GPU controls.
// ************************************************************************************************************************************
parameter int        GPU_MEM                 = 524288,           // Defines total video RAM, including 1KB palette

parameter string     ENDIAN                  = "Little",            // Endian for 8bit addressing access.
parameter bit [3:0]  PDI_LAYERS              = 4,                   // Number of parallel window layers.
parameter bit [3:0]  SDI_LAYERS              = 4,                   // Number of sequential window layers.
parameter bit        ENABLE_TILE_MODE  [0:7] = '{1,0,0,0,0,0,0,0},  // Enable tile mode for each PDI_LAYER from 0 to 7.
                                                                    // TILES are available to all SDI_LAYERS of an enabled PDI_LAYER.
                                                                    // Each tile enabled PDI_LAYER will use it's own dedicated FPGA blockram.
parameter bit        SKIP_TILE_DELAY         = 0,                   // Skip horizontal compensation delay due to disabled tile mode features.  Only necessary for multiple PDI_LAYERS with mixed tile enable options.

parameter bit        ENABLE_PALETTE    [0:7] = '{1,1,1,1,1,1,1,1},  // Enable a palette blockram for each PDI_LAYER from 0 to 7.
                                                                    // Each palette enabled PDI_LAYER will use it's own dedicated FPGA blockram.
parameter bit        SKIP_PALETTE_DELAY      = 0,                   // Skip horizontal compensation delay due to disabled palette.  Only necessary for multiple PDI_LAYERS with mixed palette enable options.


parameter int        HWREG_BASE_ADDRESS      = 32'h00000100,     // The first address where the HW REG controls are located for window layer 0.  The first 256 bytes are reserved for general purpose use.
                                                                 // Each window uses 32 bytes for their controls, IE assuming 32 windows, we need 1024 bytes worth of address space.
parameter int        HWREG_BASE_ADDR_LSWAP   = 32'h000000F0,     // The first address where the 16 byte control to swap the SDI & PDI layer order.

parameter int        PAL_BASE_ADDR           = 32'h00001000,     // Assuming 32 layers where each palette is 1024 bytes, we will use 32768 bytes for the palette.
parameter int        TILE_BYTES              = 65536,            // Number of bytes reserved for the TILE/FONT memory.  We will use 64k, IE it is possible to make a 16x16x8bpp 256 character font.
parameter int        TILE_BASE_ADDR          = 32'h00004000,     // 

// ************************************************************************************************************************************
// ****************  BrianHG_DDR3 setup.
// ************************************************************************************************************************************
parameter string     FPGA_VENDOR             = "Altera",         // (Only Altera for now) Use ALTERA, INTEL, LATTICE or XILINX.
parameter            FPGA_FAMILY             = "MAX 10",         // With Altera, use Cyclone III, Cyclone IV, Cyclone V, MAX 10,....
parameter bit        BHG_OPTIMIZE_SPEED      = 1,                // Use '1' for better FMAX performance, this will increase logic cell usage in the BrianHG_DDR3_PHY_SEQ module.
                                                                 // It is recommended that you use '1' when running slowest -8 Altera fabric FPGA above 300MHz or Altera -6 fabric above 350MHz.
parameter bit        BHG_EXTRA_SPEED         = 1,                // Use '1' for even better FMAX performance or when overclocking the core.  This will increase logic cell usage.

// ************************************************************************************************************************************
// ****************  System clock generation and operation.
// ************************************************************************************************************************************
parameter int        CLK_KHZ_IN              = 50000,            // PLL source input clock frequency in KHz.
parameter int        CLK_IN_MULT             = 24,               // Multiply factor to generate the DDR MTPS speed divided by 2.
parameter int        CLK_IN_DIV              = 4,                // Divide factor.  When CLK_KHZ_IN is 25000,50000,75000,100000,125000,150000, use 2,4,6,8,10,12.
parameter int        DDR_TRICK_MTPS_CAP      = 600,              // 0=off, Set a false PLL DDR data rate for the compiler to allow FPGA overclocking.  ***DO NOT USE.
                                                                
parameter string     INTERFACE_SPEED         = "Half",           // Either "Full", "Half", or "Quarter" speed for the user interface clock.
                                                                 // This will effect the controller's interface CMD_CLK output port frequency.

// ************************************************************************************************************************************
// ****************  DDR3 ram chip configuration settings
// ************************************************************************************************************************************
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

parameter string     BANK_ROW_ORDER          = "ROW_BANK_COL",   // Only supports "ROW_BANK_COL" or "BANK_ROW_COL".  Choose to optimize your memory access.

parameter int        PORT_ADDR_SIZE          = (DDR3_WIDTH_ADDR + DDR3_WIDTH_BANK + DDR3_WIDTH_CAS + (DDR3_WIDTH_DM-1)),

// ************************************************************************************************************************************
// ****************  BrianHG_DDR3_COMMANDER_2x1 configuration parameter settings.
// ************************************************************************************************************************************
//
// Current port assignments:
//    0 - rs232_debugger
//    1 - BRIDGETTE
//    2 - GEOFF (R/W)
//    3 - GEOFF (R only)
//    4 - HW_REGS
//    5 - SID
//
parameter int        PORT_TOTAL              = 6,                // Set the total number of DDR3 controller write ports, 1 to 4 max.
parameter int        PORT_MLAYER_WIDTH [0:3] = '{2,2,2,2},       // Use 2 through 16.  This sets the width of each MUX join from the top PORT
                                                                 // inputs down to the final SEQ output.  2 offers the greatest possible FMAX while
                                                                 // making the first layer width = to PORT_TOTAL will minimize MUX layers to 1,
                                                                 // but with a large number of ports, FMAX may take a beating.
// ************************************************************************************************************************************
// PORT_MLAYER_WIDTH illustration
// ************************************************************************************************************************************
//  PORT_TOTAL = 16
//  PORT_MLAYER_WIDTH [0:3]  = {4,4,x,x}
//
// (PORT_MLAYER_WIDTH[0]=4)    (PORT_MLAYER_WIDTH[1]=4)     (PORT_MLAYER_WIDTH[2]=N/A) (not used)          (PORT_MLAYER_WIDTH[3]=N/A) (not used)
//                                                          These layers are not used since we already
//  PORT_xxxx[ 0] ----------\                               reached one single port to drive the DDR3 SEQ.
//  PORT_xxxx[ 1] -----------==== ML10_xxxx[0] --------\
//  PORT_xxxx[ 2] ----------/                           \
//  PORT_xxxx[ 3] ---------/                             \
//                                                        \
//  PORT_xxxx[ 4] ----------\                              \
//  PORT_xxxx[ 5] -----------==== ML10_xxxx[1] -------------==== SEQ_xxxx wires to DDR3_PHY controller.
//  PORT_xxxx[ 6] ----------/                              /
//  PORT_xxxx[ 7] ---------/                              /
//                                                       /
//  PORT_xxxx[ 8] ----------\                           /
//  PORT_xxxx[ 9] -----------==== ML10_xxxx[2] --------/
//  PORT_xxxx[10] ----------/                         /
//  PORT_xxxx[11] ---------/                         /
//                                                  /
//  PORT_xxxx[12] ----------\                      /
//  PORT_xxxx[13] -----------==== ML10_xxxx[3] ---/
//  PORT_xxxx[14] ----------/
//  PORT_xxxx[15] ---------/
//
//
//  PORT_TOTAL = 16
//  PORT_MLAYER_WIDTH [0:3]  = {3,3,3,x}
//  This will offer a better FMAX compared to {4,4,x,x}, but the final DDR3 SEQ command has 1 additional clock cycle pipe delay.
//
// (PORT_MLAYER_WIDTH[0]=3)    (PORT_MLAYER_WIDTH[1]=3)    (PORT_MLAYER_WIDTH[2]=3)                   (PORT_MLAYER_WIDTH[3]=N/A)
//                                                         It would make no difference if             (not used, we made it down to 1 port)
//                                                         this layer width was set to [2].
//  PORT_xxxx[ 0] ----------\
//  PORT_xxxx[ 1] -----------=== ML10_xxxx[0] -------\
//  PORT_xxxx[ 2] ----------/                         \
//                                                     \
//  PORT_xxxx[ 3] ----------\                           \
//  PORT_xxxx[ 4] -----------=== ML10_xxxx[1] -----------==== ML20_xxxx[0] ---\
//  PORT_xxxx[ 5] ----------/                           /                      \
//                                                     /                        \
//  PORT_xxxx[ 6] ----------\                         /                          \
//  PORT_xxxx[ 7] -----------=== ML10_xxxx[2] -------/                            \
//  PORT_xxxx[ 8] ----------/                                                      \
//                                                                                  \
//  PORT_xxxx[ 9] ----------\                                                        \
//  PORT_xxxx[10] -----------=== ML11_xxxx[0] -------\                                \
//  PORT_xxxx[11] ----------/                         \                                \
//                                                     \                                \
//  PORT_xxxx[12] ----------\                           \                                \
//  PORT_xxxx[13] -----------=== ML11_xxxx[1] -----------==== ML20_xxxx[1] ---------------====  SEQ_xxxx wires to DDR3_PHY controller.
//  PORT_xxxx[14] ----------/                           /                                /
//                                                     /                                /
//  PORT_xxxx[15] ----------\                         /                                /
//         0=[16] -----------=== ML11_xxxx[2] -------/                                /
//         0=[17] ----------/                                                        /
//                                                                                  /
//                                                                                 /
//                                                                                /
//                                                       0 = ML20_xxxx[2] -------/
//
// ************************************************************************************************************************************

parameter int        PORT_VECTOR_SIZE   = 16,   // Sets the width of each port's VECTOR input and output.

// ************************************************************************************************************************************
// ***** DO NOT CHANGE THE NEXT 4 PARAMETERS FOR THIS VERSION OF THE BrianHG_DDR3_COMMANDER.sv... *************************************
parameter int        READ_ID_SIZE       = 4,                                    // The number of bits available for the read ID.  This will limit the maximum possible read/write cache modules.
parameter int        DDR3_VECTOR_SIZE   = READ_ID_SIZE + 1,                     // Sets the width of the VECTOR for the DDR3_PHY_SEQ controller.  4 bits for 16 possible read ports.
parameter int        PORT_CACHE_BITS    = (8*DDR3_WIDTH_DM*8),                  // Note that this value must be a multiple of ' (8*DDR3_WIDTH_DQ*DDR3_NUM_CHIPS)* burst 8 '.
parameter int        CACHE_ADDR_WIDTH   = $clog2(PORT_CACHE_BITS/8),            // This is the number of LSB address bits which address all the available 8 bit bytes inside the cache word.
parameter int        BYTE_INDEX_BITS    = (DDR3_WIDTH_CAS + (DDR3_WIDTH_DM-1)), // Sets the starting address bit where a new row & bank begins.
// ************************************************************************************************************************************

// PORT_'feature' = '{port# 0,1,2,3,4,5,,,} Sets the feature for each DDR3 ram controller interface port 0 to port 15.

parameter bit        PORT_TOGGLE_INPUT [0:15] = '{  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0},
                                                // When enabled, the associated port's 'CMD_busy' and 'CMD_ena' ports will operate in
                                                // toggle mode where each toggle of the 'CMD_ena' will represent a new command input
                                                // and the port is busy whenever the 'CMD_busy' output is not equal to the 'CMD_ena' input.
                                                // This is an advanced  feature used to communicate with the input channel when your source
                                                // control is operating at 2x this module's CMD_CLK frequency, or 1/2 CMD_CLK frequency
                                                // if you have disabled the port's PORT_W_CACHE_TOUT.

parameter bit [8:0]  PORT_R_DATA_WIDTH [0:15] = '{  8,  8, 16, 16,128,128,128,128,128,128,128,128,128,128,128,128},
parameter bit [8:0]  PORT_W_DATA_WIDTH [0:15] = '{  8,  8, 16, 16,128,128,128,128,128,128,128,128,128,128,128,128},
                                                // Use 8,16,32,64,128, or 256 bits, maximum = 'PORT_CACHE_BITS'
                                                // As a precaution, this will prune/ignore unused data bits and write masks bits, however,
                                                // all the data ports will still be 'PORT_CACHE_BITS' bits and the write masks will be 'PORT_CACHE_WMASK' bits.
                                                // (a 'PORT_CACHE_BITS' bit wide data bus has 32 individual mask-able bytes (8 bit words))
                                                // For ports sizes below 'PORT_CACHE_BITS', the data is stored and received in Big Endian.  

parameter bit [1:0]  PORT_PRIORITY     [0:15] = '{  3,  2,  0,  0,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0},
                                                // Use 0 to 3.  If a port with a higher priority receives a request, even if another
                                                // port's request matches the current page, the higher priority port will take
                                                // precedence and force the RAM controller to leave the current page.

parameter int        PORT_READ_STACK   [0:15] = '{ 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16},
                                                // Sets the size of the intermediate read command request stack.
                                                // 16 through 32, default = 20
                                                // The size of the number of read commands built up in advance while the read channel waits
                                                // for the DDR3_PHY_SEQ to return the read request data.
                                                // Multiple reads must be accumulated to allow an efficient continuous read burst.
                                                // IE: Use 16 level deep when running a small data port width like 16 or 32 so sequential read cache
                                                // hits continue through the command input allowing cache miss read req later-on in the req stream to be
                                                // immediately be sent to the DDR3_PHY_SEQ before the DDR3 even returns the first read req data.

parameter bit [8:0]  PORT_W_CACHE_TOUT [0:15] = '{256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256},
                                                // A timeout for the write cache to dump it's contents to ram.
                                                // 0   = immediate writes, or no write cache.
                                                // 256 = Wait up to 256 CMD_CLK clock cycles since the previous write req.
                                                //       to the same 'PORT_CACHE_BITS' bit block before writing to ram.  Write reqs outside
                                                //       the current 'PORT_CACHE_BITS' bit cache block clears the timer and forces an immediate write.

parameter bit        PORT_CACHE_SMART  [0:15] = '{  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1},  
                                                // When enabled, if an existing read cache exists at the same write request address,
                                                // that read's cache will immediately be updated with the new write data.
                                                // This function may impact the FMAX for the system clock and increase LUT usage.
                                                // *** Disable when designing a memory read/write testing algorithm.

parameter bit        PORT_DREG_READ    [0:15] = '{  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1},  
                                                // When enabled, an additional register is placed at the read data out to help improve FMAX.

parameter bit [8:0]  PORT_MAX_BURST    [0:15] = '{256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256},
                                                // 1 through 256, 0=No sequential burst priority.
                                                // Defines the maximum consecutive read or write burst commands from a single
                                                // port if another read/write port requests exists with the same priority level,
                                                // but their memory request exist in a different row.  * Every 1 counts for a BL8 burst.
                                                // This will prevent a single continuous stream port from hogging up all the ram access time.
                                                // IE: If set to 0, commander will seek if other read/write requests are ready before
                                                // continuing access to the same port DDR3 access.

parameter bit        SMART_BANK         = 0     // 1=ON, 0=OFF, With SMART_BANK enabled, the BrianHG_DDR3_COMMANDER will remember which
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
    input              [1:0]        KEY,

    //////////// LED //////////
    output logic       [7:0]        LED,

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
    output                          SD_D123_DIR,
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
// DDR3 controller interface.
// ****************************************
logic                         CMD_busy            [0:PORT_TOTAL-1];  // For each port, when high, the DDR3 controller will not accept an incoming command on that port.

logic                         CMD_ena             [0:PORT_TOTAL-1];  // Send a command.
logic                         CMD_write_ena       [0:PORT_TOTAL-1];  // Set high when you want to write data, low when you want to read data.

logic [PORT_ADDR_SIZE-1:0]    CMD_addr            [0:PORT_TOTAL-1];  // Command Address pointer.
logic [PORT_CACHE_BITS-1:0]   CMD_wdata           [0:PORT_TOTAL-1];  // During a 'CMD_write_req', this data will be written into the DDR3 at address 'CMD_addr'.
                                                                     // Each port's 'PORT_DATA_WIDTH' setting will prune the unused write data bits.
                                                                     // *** All channels of the 'CMD_wdata' will always be PORT_CACHE_BITS wide, however,
                                                                     // only the bottom 'PORT_W_DATA_WIDTH' bits will be active.

logic [PORT_CACHE_BITS/8-1:0] CMD_wmask           [0:PORT_TOTAL-1];  // Write enable byte mask for the individual bytes within the 256 bit data bus.
                                                                     // When low, the associated byte will not be written.
                                                                     // Each port's 'PORT_DATA_WIDTH' setting will prune the unused mask bits.
                                                                     // *** All channels of the 'CMD_wmask' will always be 'PORT_CACHE_BITS/8' wide, however,
                                                                     // only the bottom 'PORT_W_DATA_WIDTH/8' bits will be active.

logic [PORT_VECTOR_SIZE-1:0]  CMD_read_vector_in  [0:PORT_TOTAL-1];  // The contents of the 'CMD_read_vector_in' during a read req will be sent to the
                                                                     // 'CMD_read_vector_out' in parallel with the 'CMD_read_data' during the 'CMD_read_ready' pulse.
                                                                     // *** All channels of the 'CMD_read_vector_in' will always be 'PORT_VECTOR_SIZE' wide,
                                                                     // it is up to the user to '0' the unused input bits on each individual channel.

logic                         CMD_read_ready      [0:PORT_TOTAL-1];  // Goes high for 1 clock when the read command data is valid.
logic [PORT_CACHE_BITS-1:0]   CMD_read_data       [0:PORT_TOTAL-1];  // Valid read data when 'CMD_read_ready' is high.
                                                                     // *** All channels of the 'CMD_read_data will' always be 'PORT_CACHE_BITS' wide, however,
                                                                     // only the bottom 'PORT_R_DATA_WIDTH' bits will be active.

logic [PORT_VECTOR_SIZE-1:0]  CMD_read_vector_out [0:PORT_TOTAL-1];  // Returns the 'CMD_read_vector_in' which was sampled during the 'CMD_read_req' in parallel
                                                                     // with the 'CMD_read_data'.  This allows for multiple post reads where the output
                                                                     // has a destination pointer.

logic                         CMD_priority_boost  [0:PORT_TOTAL-1];  // Boosts the port's 'PORT_PRIORITY' parameter by a weight of 4 when set.


// **************************************************************************************
// This Write Data TAP port passes a copy of all the writes going to the DDR3 memory.
// This will allow to 'shadow' selected write addresses to other peripherals
// which may be accessed by all the multiple write ports.
// This port is synchronous to the CMD_CLK.
// **************************************************************************************
logic                         TAP_WRITE_ENA ;
logic [PORT_ADDR_SIZE-1:0]    TAP_ADDR      ;
logic [PORT_CACHE_BITS-1:0]   TAP_WDATA     ;
logic [PORT_CACHE_BITS/8-1:0] TAP_WMASK     ;

// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
// This module is the complete BrianHG_DDR3_CONTROLLER_v15 system assembled initiating:
//
//   - BrianHG_DDR3_CONTROLLER_v15_top.sv -> v1.5 TOP entry to the complete project which wires the DDR3_COMMANDER_v15 to the DDR3_PHY_SEQ giving you access to all the read/write ports + access to the DDR3 IO pins.
//   - BrianHG_DDR3_COMMANDER_v15.sv      -> v1.5 High FMAX speed multi-port read and write requests and cache, commands the BrianHG_DDR3_PHY_SEQ.sv sequencer.
//   - BrianHG_DDR3_CMD_SEQUENCER.sv      -> Takes in the read and write requests, generates a stream of DDR3 commands to execute the read and writes.
//   - BrianHG_DDR3_PHY_SEQ.sv            -> DDR3 PHY sequencer.          (If you want just a compact DDR3 controller, skip the DDR3_CONTROLLER_top & DDR3_COMMANDER and just use this module alone.)
//   - BrianHG_DDR3_PLL.sv                -> Generates the system clocks. (*** Currently Altera/Intel only ***)
//   - BrianHG_DDR3_GEN_tCK.sv            -> Generates all the tCK count clock cycles for the DDR3_PHY_SEQ so that the DDR3 clock cycle requirements are met.
//   - BrianHG_DDR3_FIFOs.sv              -> Serial shifting logic FIFOs.
//
// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
BrianHG_DDR3_CONTROLLER_v15_top #(.FPGA_VENDOR         (FPGA_VENDOR       ),   .FPGA_FAMILY        (FPGA_FAMILY       ),   .INTERFACE_SPEED    (INTERFACE_SPEED ),
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
                                  .PORT_MLAYER_WIDTH   (PORT_MLAYER_WIDTH ),
                                  .PORT_TOTAL          (PORT_TOTAL        ),   .PORT_VECTOR_SIZE   (PORT_VECTOR_SIZE  ),   .PORT_TOGGLE_INPUT  (PORT_TOGGLE_INPUT),
                                  .PORT_R_DATA_WIDTH   (PORT_R_DATA_WIDTH ),   .PORT_W_DATA_WIDTH  (PORT_W_DATA_WIDTH ),
                                  .PORT_PRIORITY       (PORT_PRIORITY     ),   .PORT_READ_STACK    (PORT_READ_STACK   ),
                                  .PORT_CACHE_SMART    (PORT_CACHE_SMART  ),   .PORT_W_CACHE_TOUT  (PORT_W_CACHE_TOUT ),
                                  .PORT_MAX_BURST      (PORT_MAX_BURST    ),   .PORT_DREG_READ     (PORT_DREG_READ    ),   .SMART_BANK         (SMART_BANK       )

) DDR3 (

                                  // *** Interface Reset, Clocks & Status. ***
                                  .RST_IN               (RST_IN               ),                   .RST_OUT              (RST_OUT              ),
                                  .CLK_IN               (CLK_IN               ),                   .CMD_CLK              (CMD_CLK              ),
                                  .DDR3_READY           (DDR3_READY           ),                   .SEQ_CAL_PASS         (SEQ_CAL_PASS         ),
                                  .PLL_LOCKED           (PLL_LOCKED           ),                   .DDR3_CLK             (DDR3_CLK             ),
                                  .DDR3_CLK_50          (DDR3_CLK_50          ),                   .DDR3_CLK_25          (DDR3_CLK_25          ),

                                  // *** DDR3 Commander functions ***
                                  .CMD_busy             (CMD_busy            ),                    .CMD_ena              (CMD_ena             ),
                                  .CMD_write_ena        (CMD_write_ena       ),                    .CMD_addr             (CMD_addr            ),
                                  .CMD_wdata            (CMD_wdata           ),                    .CMD_wmask            (CMD_wmask           ),
                                  .CMD_read_vector_in   (CMD_read_vector_in  ),                    .CMD_priority_boost   (CMD_priority_boost  ),

                                  .CMD_read_ready       (CMD_read_ready      ),                    .CMD_read_data        (CMD_read_data       ),
                                  .CMD_read_vector_out  (CMD_read_vector_out ),

                                  // *** DDR3 Ram Chip IO Pins ***           
                                  .DDR3_CK_p  (DDR3_CK_p  ),    .DDR3_CK_n  (DDR3_CK_n  ),     .DDR3_CKE     (DDR3_CKE     ),     .DDR3_CS_n (DDR3_CS_n ),
                                  .DDR3_RAS_n (DDR3_RAS_n ),    .DDR3_CAS_n (DDR3_CAS_n ),     .DDR3_WE_n    (DDR3_WE_n    ),     .DDR3_ODT  (DDR3_ODT  ),
                                  .DDR3_A     (DDR3_A     ),    .DDR3_BA    (DDR3_BA    ),     .DDR3_DM      (DDR3_DM      ),     .DDR3_DQ   (DDR3_DQ   ),
                                  .DDR3_DQS_p (DDR3_DQS_p ),    .DDR3_DQS_n (DDR3_DQS_n ),     .DDR3_RESET_n (DDR3_RESET_n ),

                                  // debug IO
                                  .RDCAL_data (RDCAL_data ),    .reset_phy (DB232_rx3[7]),     .reset_cmd    (DB232_rx3[6]),

                                  // Write data TAP port.
                                  .TAP_WRITE_ENA (TAP_WRITE_ENA ), .TAP_ADDR      (TAP_ADDR      ),
                                  .TAP_WDATA     (TAP_WDATA     ), .TAP_WMASK     (TAP_WMASK     ) );

// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************
// ***********************************************************************************************************************************************************

wire        send_geo_cmd ;
wire        rd_px_ctr_rs ;
wire        wr_px_ctr_rs ;
wire [15:0] geo_cmd      ;
wire [7:0]  geo_stat_rd  ;
wire [7:0]  collision_rd ;
wire [7:0]  collision_wr ;

// ***************************************************************************************************************
// *** Set default address buffer values for those not normally controlled by the GPU ****************************
// ***************************************************************************************************************
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

// ***************************************************************************************************************
// *** RESET CIRCUIT *********************************************************************************************
// ***************************************************************************************************************
reg reset      ;
reg DFF_inst8  ;
reg DFF_inst26 ;
reg DFF_inst41 ;

wire geo_reset     ;
wire reset_line    ;
wire RESET_Z80     ;
wire INV_RESET_DFF ;

exp   b2v_inst4(

   .in  ( DFF_inst8     ),
   .out ( INV_RESET_DFF )
   
);

exp   b2v_inst23(

   .in  ( DFF_inst41 ),
   .out ( RESET_Z80  )
   
);

assign geo_reset  = DFF_inst26 ;
assign reset_line = RESET_Z80 | INV_RESET_DFF ;

always@(posedge DDR3_CLK_25) begin

   DFF_inst26 <= reset       ;
   reset      <= reset_line  ;
   DFF_inst41 <= GPIO1_D[10] ;
   DFF_inst8  <= KEY[0]      ;

end

// Set default DDR3 bus signals for Bridgette
assign CMD_read_vector_in  [1] = 0 ;
assign CMD_priority_boost  [1] = 0 ;

// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// *** BRIDGETTE *************************************************************************************************
// *** Z80 Bridge ************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
Z80_Bus_Interface #(

// ************** Z80 bus timing settings. **************
   .READ_PORT_CLK_sPOS    ( 0       ), // Number of Z80_CLK cycles before the bus interface responds to a Read Port command.
   .READ_PORT_CLK_aPOS    ( 2       ), // Number of Z80_CLK cycles before the bus interface responds to a Read Port command.
   .WRITE_PORT_CLK_POS    ( 2       ), // Number of Z80_CLK cycles before the bus interface samples the Write Port command's data.

// 0 to 7, Number of CMD_CLK cycles to wait for DDR3 read before asserting the WAIT during a Read Memory cycle.
// Use 0 for an instant guaranteed 'WAIT' every read.  (Safest for Read Instruction Opcode cycle.)
// Use 2 for compatibility with waiting for a BrianHG_DDR3 read cache hit before asserting the 'WAIT'.
   .Z80_DELAY_WAIT_RI     ( 3       ), // 0 to 7, Number of CMD_CLK cycles to wait for DDR3 read_ready before asserting the WAIT during a Read Instruction Opcode cycle.
   .Z80_DELAY_WAIT_RM     ( 3       ), // 0 to 7, Number of CMD_CLK cycles to wait for DDR3 read_ready before asserting the WAIT during a Read Memory cycle.
   .Z80_WAIT_QUICK_OFF    ( 1       ), // 0 (Default) = WAIT is turned off only during a low Z80_CLK.  1 = WAIT is turned off as soon as a read_ready is received.

// ************** Direction control for DATA BUS level converter **************
   .data_in               ( 1'b0    ), // Direction controls for 74LVC245 buffers - hardware dependent!
   .data_out              ( 1'b1    ), // Direction controls for 74LVC245 buffers - hardware dependent!

// ************** Parameters specific to the uCOM host **************
   .BANK_ID               ( '{9,3,71,80,85,32,77,65,88,49,48,0,255,255,255,255} ),  // The BANK_ID data to return ('GPU MAX10')
   .BANK_ID_ADDR          ( GPU_MEM-16 ),  // Address to return BANK_ID data from
   .BANK_RESPONSE         ( 1       ), // 1 - respond to reads at BANK_ID_ADDR with BANK_ID data, 0 - ignore reads to that address
   .MEM_SIZE_BYTES        ( GPU_MEM ), // Specifies size of GPU RAM available to host (anything above this returns $FF or $7E)
   .MEMORY_RANGE          ( 3'b010  ), // Z80_addr[21:19] == 3'b010 targets the 512KB 'window' at 0x100000-0x17FFFF (Socket 3 on the uCom)

// ************** Interrupts are not currently used **************
   .INT_TYP               ( 0       ), // 0 = polled (IO), 1 = interrupt.
   .INT_VEC               ( 48      ), // INTerrupt VECtor to be passed to host in event of an interrupt acknowledge.

// ************** Read IO port addresses range. **************
   .READ_PORT_BEGIN       ( 240     ), // Sets the beginning port number which can be read.
   .READ_PORT_END         ( 251     ), // Sets the ending    port number which can be read.

// ************** Legacy IO port addresses. *********** Move outside Z80 bus interface with the new port bus.
   .SD_SECTOR             ( 241     ), // IO address for SD interface's 32-bit Sector Address pipe.
   .SD_RDWR               ( 242     ), // IO address to initiate SD RD/WR.
   .SD_ARG_PTR            ( 243     ), // IO address to set/read ARG_PTR value.
   .IO_BLNK               ( 244     ), // IO address for BLANK signal to video DAC.
   .GEO_LO                ( 246     ), // IO address for GEOFF LOW byte.
   .GEO_HI                ( 247     ), // IO address for GEOFF HIGH byte.
   .FIFO_STAT             ( 248     ), // IO address for GPU FIFO status on bit 0 - remaining bits free for other data.
   .GPU_MMU_L             ( 250     ), // IO address for the GPU MMU's lower 8-bits of the upper 12-bits of the DDR3 address bus.
   .GPU_MMU_H             ( 251     )  // IO address for the GPU MMU's upper 4-bits of the upper 12-bits of the DDR3 address bus.
// ************** Legacy IO port addresses. *********** Move outside Z80 bus interface with the new port bus.

) BRIDGETTE (

   // ***********************************
   // *** Core System Clock and Reset ***
   // ***********************************
   .CMD_CLK           ( CMD_CLK        ), // System clock (75-200 MHz)
   .reset             ( reset          ), // System reset signal

   // ***********************************
   // *** Z80 bus control connections ***
   // ***********************************
   .Z80_CLK           ( GPIO1_D[3]     ), // Z80 host's clock signal (8 MHz default).
   
   // Z80 address bus (22-bit)
   .Z80_ADDR          ({ GPIO0_D[14], GPIO0_D[15], GPIO0_D[16], GPIO0_D[17], GPIO0_D[18], GPIO0_D[19], GPIO0_D[20], GPIO0_D[21],
                         GPIO0_D[26], GPIO0_D[27], GPIO0_D[28], GPIO0_D[29], GPIO0_D[30], GPIO0_D[31], GPIO0_D[34], GPIO0_D[35],
                         GPIO0_D[36], GPIO0_D[37], GPIO0_D[38], GPIO0_D[39], GPIO0_D[40], GPIO0_D[41]
                      }),

   // Control bus
   .Z80_M1n           ( GPIO1_D[8]     ), // Z80 M1 goes LOW with MREQ to signal Z80 Machine Cycle 1 (opcode fetch).
                                          // Z80 M1 goes LOW with IORQ to signal an interrupt acknowledge (INTACK).
   .Z80_IORQn         ( GPIO1_D[7]     ), // Z80 IORQ goes LOW when Z80 is performing an IO operation.
   .Z80_MREQn         ( GPIO1_D[6]     ), // Z80 MREQ goes LOW when Z80 is performing a memory operation.
   .Z80_WAIT          ( GPIO0_D[8]     ), // Active HIGH, signals to Z80 to WAIT.
   .Z80_RDn           ( GPIO1_D[4]     ), // Z80 RD goes LOW to signal a Z80 ReaD operation.
   .Z80_WRn           ( GPIO1_D[5]     ), // Z80 WR goes LOW when Z80 is performing a WRite operation.

   // Data bus (8-bit)
   .Z80_DATA          ({ GPIO1_D[11], GPIO1_D[12], GPIO1_D[13], GPIO1_D[14], GPIO1_D[15], GPIO1_D[16], GPIO1_D[17], GPIO1_D[18] }),

   // Interrupts
   .Z80_IEI           (                ), // NOT USED, Z80 INTerrupt daisy chain input - active LOW, prevents Z80_bridge from raising an INTerrupt request.
   .Z80_INT_REQ       (                ), // NOT USED, Active HIGH (signal is inverted in the FPGA interface), signals to Z80 an INTerrupt request.
   .Z80_IEO           (                ), // NOT USED, Active LOW, prevents devices further down the daisy chain from requesting INTerrupts.


   // *** Z80 bidir data bus and bus steering connections. ***
   .Z80_245data_dir   ( GPIO1_D[20]    ), // Controls direction of the Z80 data bus buffer.
   .Z80_245_oe        ( GPIO1_D[19]    ), // Enable/disable signal for Z80 data bus buffer.

   // *** Extended Address (EA) bus steering connections ***
   .EA_DIR            ( GPIO0_D[23]    ), // Controls direction of the EA bus buffer.
   .EA_OE             ( GPIO0_D[22]    ), // Enable/disable signal for EA bus buffer.
                                          // The EA bus direction control should default to Z80 > FPGA direction.
                                          // These controls are present for a future FPGA MMU to replace the hardware MMU on the memory card, or
                                          // for EA bus control by an optional FPGA CPU core.
   

   // *********************************
   // *** Z80 <-> System RAM Access ***
   // *********************************
   .CMD_busy        (                       CMD_busy       [1]   ), // High when a DDR3 read/write req is not allowed to take place.
   .CMD_ena         (                       CMD_ena        [1]   ), // Flag HIGH for at least 1 clock when reading/writing to DDR3 RAM
   .CMD_addr        (    (PORT_ADDR_SIZE)'( CMD_addr       [1] ) ), // Z80 requested address.
   .CMD_write_ena   (                       CMD_write_ena  [1]   ), // Flag HIGH for 1 CMD_CLK when writing to RAM
   .CMD_write_data  (   (PORT_CACHE_BITS)'( CMD_wdata      [1] ) ), // Data from Z80 to be written into RAM.
   .CMD_write_mask  ( (PORT_CACHE_BITS/8)'( CMD_wmask      [1] ) ), // Write data enable mask to RAM.
   .CMD_read_ready  (                       CMD_read_ready [1]   ), // One-shot signal from mux or DDR3_Controller that data is ready
   .CMD_read_data   (                 (8)'( CMD_read_data  [1] ) ), // Read Data from RAM to be sent to Z80.


   // *******************************
   // *** Z80 peripheral IO ports ***
   // *******************************
   .WRITE_PORT_STROBE (               ), // The bit   [port_number] in this 256 bit bus will pulse when the Z80 writes to that port number.
   .WRITE_PORT_DATA   (               ), // The array [port_number] will hold the last written data to that port number.
   .READ_PORT_STROBE  (               ), // The bit   [port_number] in this 256 bit bus will pulse when the Z80 reads from that port number.

// until the legacy ports are moved out, this port needs cannot be used.
//   .READ_PORT_DATA     (               ), // The array [port_number] will be sent to the Z80 during a port read so long as the read port
                                          // number is within parameter READ_PORT_BEGIN and READ_PORT_END.

// ***************************************************************************************************
// **** Wishbone Master Interface ********************************************************************
// ***************************************************************************************************
/*
   .m_wb_adr_o       ( h_wb_adr   ), // 8-bit address
   .m_wb_dat_o       ( h_wb_dat_o ), // 32-bit data out
   .m_wb_dat_i       ( h_wb_dat_i ), // 32-bit data in
   .m_wb_sel_o       ( h_sel_o    ), // WISHBONE byte select input [3:0] (indicates where valid data is expected on the dat_i or dat_o bus)
   .m_wb_we_o        ( h_we_o     ), // WISHBONE write enable output
   .m_wb_cyc_o       ( h_cyc_o    ), // WISHBONE cycle output
   .m_wb_stb_o       ( h_stb_o    ), // WISHBONE strobe output
   .m_wb_ack_i       ( h_ack_i    ), // WISHBONE acknowledge input
/**/
   .SD_sector        ( sd_sector   ), // 32-bit sector address
   .SD_op_ena        ( sd_op_req   ), // SD transaction request signal
   .SD_wr_ena        ( sd_wr_ena   ), // read/write signal (LOW - read, HIGH - write)
   .SD_status        ( sd_RD_sta   ), // 8-bit SD interface status data
   .SD_busy          ( sdi_busy    ),
/**/
// ***************************************************************************************************
// ***************************************************************************************************
// ***************************************************************************************************
// **** Legacy Peripheral IO ports. ******************************************************************
// ***************************************************************************************************
// ***************************************************************************************************
// ***************************************************************************************************

   // *** Enable/Disable video output port.
   .VIDEO_EN          (      ), // Active HIGH, enables video output.

   // 2D accelerated Geometry unit IO access.
   .GEO_STAT_RD       ( geo_stat_rd   ), // 8-bit data_mux_geo STATUS bus.  bit 0 = scfifo-almost-full flag, other bits free for other data.
   //.GEO_STAT_WR       ( geo_stat_wr    ), // Bit 0 is used to soft-reset the geometry unit.

   .GEO_WR_HI_STROBE  ( send_geo_cmd  ), // Active HIGH, signals GEOFF that valid 16-bit data is available on geo_cmd bus.
   .GEO_WR_HI         ( geo_cmd[15:8] ), // MSB in geo_cmd bus.
   .GEO_WR_LO         ( geo_cmd[7:0]  ), // LSB in geo_cmd bus.

   .RD_PX_CTR         ( collision_rd  ), // COPY READ PIXEL collision counter from pixel_writer.
   .WR_PX_CTR         ( collision_wr  ), // WRITE PIXEL     collision counter from pixel_writer.
   .RD_PX_CTR_STROBE  ( rd_px_ctr_rs  ), // Active HIGH, signals GEOFF to reset READ PIXEL  collision counter.
   .WR_PX_CTR_STROBE  ( wr_px_ctr_rs  )  // Active HIGH, signals GEOFF to reset WRITE PIXEL collision counter.

);

// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// *** SID *******************************************************************************************************
// *** SD Card Interface *****************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
wire        sd_op_req   ; // enable request from Bridgette
wire  [1:0] sd_wr_ena   ; // SD op mode from Bridgette
wire  [7:0] sd_RD_sta   ; // SD status
wire [31:0] sd_sector   ;
wire        sdi_busy    ;

//wire [3:0]  sd_data_in  ; // data FROM SD card
//wire [3:0]  sd_data_out ; // data TO SD card

// Set default signals for SD <-> DDR3 bus
assign CMD_read_vector_in  [5] = 0 ;
assign CMD_priority_boost  [5] = 0 ;

SDInterface #(

   .CLK_DIV      ( 3           ),
   .BUFFER_ADDR  ( 'h5000      )

) SID (

   .CLK          ( CMD_CLK     ), // 125MHz system clock
   .RESET        ( reset       ), // reset active HIGH
   // interface <-> Bridgette
   //    input from Bridgette
   .ENABLE       ( sd_op_req   ), // HIGH to start RD/WR op
   .MODE         ( sd_wr_ena   ), // HIGH for write request
   .SECTOR       ( sd_sector ), // sector number to read/write
   //    output to Bridgette
   .SD_BUSY      (             ),
   .SIDSTATE     (             ),
   .CARDTYPE     (             ),
   .BUSY         ( sdi_busy    ), // HIGH when interface is busy read/writing
   .SD_STATUS    ( sd_RD_sta   ), // aggregated SD status byte
   // SD phy connections
   .SD_DATA      ( SD_DAT      ), // data to/from SD card
   .SD_CMD       ( SD_CMD      ), // bidir CMD signal
   .SD_CLK       ( SD_CLK      ), // clock signal to SD card
   .SD_CMD_DIR   ( SD_CMD_DIR  ), // HIGH = TO SD card, LOW = FROM SD card
   .SD_D0_DIR    ( SD_D0_DIR   ), // HIGH = TO SD card, LOW = FROM SD card
   .SD_D123_DIR  ( SD_D123_DIR ), // HIGH = TO SD card, LOW = FROM SD card
   .SD_SEL       ( SD_SEL      ), // SD select
   // DDR3 connections
   //    input  (DDR3 -> SD WR ops)
   .DDR3_busy    ( CMD_busy       [5] ), // HIGH when DDR3 is busy
   .DDR3_rd_rdy  ( CMD_read_ready [5] ), // data from DDR3 is ready
   .DDR3_rd_data ( CMD_read_data  [5] ), // read data from DDR3
   //    output (SD -> DDR3 RD ops)
   .DDR3_addr_o  ( CMD_addr       [5] ),
   .DDR3_ena     ( CMD_ena        [5] ), // Flag HIGH for 1 CMD_CLK when sending a DDR3 command
   .DDR3_wr_ena  ( CMD_write_ena  [5] ), // HIGH signals write request to DDR3 Controller
   .DDR3_wr_data ( CMD_wdata      [5] ), // 128-bit data bus
   .DDR3_wr_mask ( CMD_wmask      [5] )  // Write data enable mask

);

/*
wire        sd_clk      ;
wire        sd_dat_oe_o ;
wire [3:0]  sd_data_in  ; // data FROM SD card
wire [3:0]  sd_data_out ; // data TO SD card
wire        sd_cmd_oe_o ;
wire        sd_cmd_in   ; // command FROM SD card
wire        sd_cmd_out  ; // command TO SD card
wire        int_cmd     ;
wire        int_data    ;

// Host/SID WISHBONE interconnects
wire [7:0]  h_wb_adr    ; // Wishbone addr interconnect - Bridgette TO Sid
wire [31:0] h_wb_dat_o  ; // Wishbone data interconnect - Bridgette TO Sid
wire [3:0]  h_sel_o     ; // Wishbone sel interconnect  - Bridgette TO Sid
wire        h_we_o      ; // Wishbone wire interconnect - Bridgette TO Sid
wire        h_cyc_o     ; // Wishbone wire interconnect - Bridgette TO Sid
wire        h_stb_o     ; // Wishbone wire interconnect - Bridgette TO Sid
wire [31:0] h_wb_dat_i  ; // Wishbone data interconnect - Sid TO Bridgette
wire        h_ack_i     ; // Wishbone wire interconnect - Sid TO Bridgette

// SID/DDR3 WISHBONE interconnects
wire [31:0] d_wb_adr    ; // Wishbone addr interconnect - Sid TO DDR3
wire [31:0] d_wb_dat_o  ; // Wishbone data interconnect - Sid TO DDR3
wire [3:0]  d_sel_o     ; // Wishbone sel interconnect  - Sid TO DDR3
wire [2:0]  d_cti_o     ; // Wishbone sel interconnect  - Sid TO DDR3
wire [1:0]  d_bte_o     ; // Wishbone sel interconnect  - Sid TO DDR3
wire        d_we_o      ; // Wishbone wire interconnect - Sid TO DDR3
wire        d_cyc_o     ; // Wishbone wire interconnect - Sid TO DDR3
wire        d_stb_o     ; // Wishbone wire interconnect - Sid TO DDR3
wire [31:0] d_wb_dat_i  ; // Wishbone data interconnect - DDR3 TO Sid
wire        d_ack_i     ; // Wishbone wire interconnect - DDR3 TO Sid


// Clock signal to SD card
assign SD_CLK      = sd_clk ;

// Infer tri-states for SD_DAT & SD_CMD
assign SD_DAT      = sd_dat_oe_o ? sd_data_out : 4'bZZZZ ; // Bidir IO bus for SD data
assign SD_CMD      = sd_cmd_oe_o ? sd_cmd_out  : 1'bZ    ; // Bidir IO bus for SD data
assign sd_data_in  = SD_DAT ;
assign sd_cmd_in   = SD_CMD ;

// DECA SD direction controls - HIGH for writes to SD card, LOW for reads from SD card
assign SD_D0_DIR   = sd_dat_oe_o ; 
assign SD_D123_DIR = sd_dat_oe_o ; 
assign SD_CMD_DIR  = sd_cmd_oe_o ;

// SD interface voltage - DECA-specific ******* THIS CAN BE MODIFIED SO 1.8V CARDS ARE SUPPORTED ********
assign SD_SEL      = 1'b0 ; // LOW = 3.3V, HIGH = 1.8V

sdc_controller SID (

   // WISHBONE common
   .wb_clk_i     ( CMD_CLK    ), // WISHBONE clock input
   .wb_rst_i     ( reset      ), // WISHBONE reset input
    // WISHBONE slave <- FROM BRIDGETTE
   .wb_dat_i     ( h_wb_dat_o ), // WISHBONE data input [31:0]
   .wb_dat_o     ( h_wb_dat_i ), // WISHBONE data output [31:0]
   .wb_adr_i     ( h_wb_adr   ), // WISHBONE address input [7:0] (only r/w registers, so only 8 bits needed)
   .wb_sel_i     ( h_sel_o    ), // WISHBONE byte select input [3:0] (indicates where valid data is expected on the dat_i or dat_o bus)
   .wb_we_i      ( h_we_o     ), // WISHBONE write enable input
   .wb_cyc_i     ( h_cyc_o    ), // WISHBONE cycle input
   .wb_stb_i     ( h_stb_o    ), // WISHBONE strobe input
   .wb_ack_o     ( h_ack_i    ), // WISHBONE acknowledge output
   // WISHBONE master -> TO DDR3_wb_interface
   .m_wb_adr_o   ( d_wb_adr   ), // Address output [31:0]
   .m_wb_sel_o   ( d_sel_o    ), // Select output [3:0] (indicates where valid data is on the dat_i or dat_o bus)
   .m_wb_we_o    ( d_we_o     ), // Write enable output - asserted if current local bus cycle is a WRITE
   .m_wb_dat_i   ( d_wb_dat_i ), // Data input [31:0] from DDR3_wb_interface
   .m_wb_dat_o   ( d_wb_dat_o ), // Data output [31:0] to DDR3_wb_interface
   .m_wb_cyc_o   ( d_cyc_o    ), // Cycle output - asserted when valid bus cycle is in progress
   .m_wb_stb_o   ( d_stb_o    ), // Strobe output - indicates valid data transfer cycle
   .m_wb_ack_i   ( d_ack_i    ), // Acknowledge input - indicates normal termination of a bus cycle
   .m_wb_cti_o   ( d_cti_o    ), // Cycle Type Identifier. Always 3'b000
   .m_wb_bte_o   ( d_bte_o    ), // Burst Type Extension. Always 2'b00.
    //SD BUS
   .sd_cmd_dat_i ( sd_cmd_in   ), // Command in from SDcard 
   .sd_cmd_out_o ( sd_cmd_out  ), // Command out to SDcard
   .sd_cmd_oe_o  ( sd_cmd_oe_o ), // SD Card tristate CMD Output enable (Connects on the SoC TopLevel)
    //card_detect,
   .sd_dat_dat_i ( sd_data_in  ), // Data in from SDcard [3:0]
   .sd_dat_out_o ( sd_data_out ), // Data out to SDcard [3:0]
   .sd_dat_oe_o  ( sd_dat_oe_o ), // SD Card tristate Data Output enable (Connects on the SoC TopLevel)
   .sd_clk_o_pad ( sd_clk      ), // Divided CLK output from SD interface to SD card
   .sd_clk_i_pad ( CMD_CLK     ), // 125 MHz clock signal from FPGA (requires a /5 clock divider setting)
   .int_cmd      ( int_cmd     ), // Interrupt - CMD transaction finished
   .int_data     ( int_data    )  // Interrupt - DATA transaction finished

);

// Set default DDR3 bus signals for DDR3_WB_Interface
assign CMD_read_vector_in  [5] = 0 ;
assign CMD_priority_boost  [5] = 0 ;

// ***************************************************************************************************************
// ***************************************************************************************************************
// ***** SID Wishbone <-> DDR3 interface *************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
DDR3_wb_interface DDR3_WB_Interface (

    .CLK             ( CMD_CLK    ), // System clock - shared between WB and DDR3, so no clock-domain X-ing.
    .RST             ( reset      ), // Global reset signal
    // Wishbone ports to/from SID
    .adr_i           ( d_wb_adr   ), // Address input [31:0]
    .sel_i           ( d_sel_o    ), // Select input [3:0] (indicates where valid data is on the dat_i or dat_o bus)
    .we_i            ( d_we_o     ), // Write enable input - asserted if current local bus cycle is a WRITE
    .dat_i           ( d_wb_dat_o ), // Data input [31:0]
    .cyc_i           ( d_cyc_o    ), // Cycle input - asserted when valid bus cycle is in progress
    .stb_i           ( d_stb_o    ), // Strobe input - indicates valid data transfer cycle
    .cti_i           ( d_cti_o    ), // Cycle Type Identifier. Always 3'b000
    .bte_i           ( d_bte_o    ), // Burst Type Extension. Always 2'b00.
    .dat_o           ( d_wb_dat_i ), // Data output [31:0]
    .ack_o           ( d_ack_i    ), // Acknowledge output - indicates normal termination of a bus cycle
    // Connections to DDR3
    .CMD_busy        ( CMD_busy       [5] ), // High when DDR3 RD/WR req is not allowed to take place.
    .CMD_ena         ( CMD_ena        [5] ), // Flag HIGH for at least 1 clock when reading/writing to DDR3 RAM.
    .CMD_addr        ( CMD_addr       [5] ), // WB requested address.
    .CMD_write_ena   ( CMD_write_ena  [5] ), // Flag HIGH for 1 CMD_CLK when writing to RAM.
    .CMD_write_data  ( CMD_wdata      [5] ), // Data from WB to be written into RAM.
    .CMD_write_mask  ( CMD_wmask      [5] ), // Write data enable mask to RAM.
    .CMD_read_ready  ( CMD_read_ready [5] ), // One-shot signal from mux or DDR3_Controller that data is ready.
    .CMD_read_data   ( CMD_read_data  [5] )  // Read Data from RAM to be sent to WB.

);
*/

wire CMD_VID_hena,CMD_VID_vena;

// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// *** GEOFF *****************************************************************************************************
// *** Geometry Processor ****************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
assign geo_stat_rd[7:1] = 7'b0000000 ;
wire   CMD_read_ena2 ;

geometry_processor   GEOFF(

   // ****** INPUTS *******
   .clk              ( CMD_CLK      ), // 125 MHz clock signal from the DDR3_Controller in GPU_DECA_DDR3_top.
   .reset            ( geo_reset    ), // reset is a combined signal of the GPU's RESET button, OR'd with Z80_RST.
   .fifo_cmd_ready   ( send_geo_cmd ), // Active HIGH from Z80_BRIDGE when geo_cmd bus has valid 16-bit command.
   .hse              ( CMD_VID_hena ), // Horizontal sync signal from VIGEN.
   .vse              ( CMD_VID_vena ), // Vertical   sync signal from VIGEN.
   .collision_rd_rst ( rd_px_ctr_rs ), // Active HIGH signal from Z80_BRIDGE to reset READ  PIXEL COLLISION counter.
   .collision_wr_rst ( wr_px_ctr_rs ), // Active HIGH signal from Z80_BRIDGE to reset WRITE PIXEL COLLISION counter.
   .fifo_cmd_in      ( geo_cmd      ), // 16-bit command bus from Z80_BRIDGE.
   
   // ****** OUTPUTS *******
   .fifo_cmd_busy    ( geo_stat_rd[0] ), // Active HIGH signal when GEOFF's FIFO is full. Connects to Z80_BRIDGE as part of GEO_STAT_RD bus (bit 0).
   .collision_rd     ( collision_rd   ), // READ  PIXEL COLLISION count output.
   .collision_wr     ( collision_wr   ), // WRITE PIXEL COLLISION count output.

//**********************************************
// GEO DDR3 Memory access
//**********************************************
   .wr_ena           (                    CMD_write_ena  [2]           ), // output to geo_wr_ena on data_mux_geo
   .ram_addr         (  (PORT_ADDR_SIZE)'(CMD_addr       [2])          ), // output to address_geo on data_mux_geo
   .ram_wr_data      ( (PORT_CACHE_BITS)'(CMD_wdata      [2])          ), // output to data_in_geo on data_mux_geo

   .rd_req           (                    CMD_read_ena2                ), // GEO read request for the read/modify/write pixel channel.
   .rd_data_rdy      (                    CMD_read_ready [2]           ), // GEO read data ready for the read/modify/write pixel channel.
   .rd_data_in       (              (16)'(CMD_read_data  [2])          ), // GEO read data for the read/modify/write pixel channel.

   .rd_req_C         (                    CMD_ena        [3]           ), // GEO read request for the COPY pixel channel.
   .ram_addr_C       (  (PORT_ADDR_SIZE)'(CMD_addr       [3])          ), // GEO read address for the COPY pixel channel.
   .rd_data_rdy_C    (                    CMD_read_ready [3]           ), // GEO read data ready for the COPY pixel channel.
   .rd_data_in_C     (              (16)'(CMD_read_data  [3])          ), // GEO read data for the COPY pixel channel.

   .ram_mux_busy     ( CMD_busy[2] || CMD_busy[3] )  // || geo_port_full ), // input from geo_port_full

);
   defparam GEOFF.FIFO_MARGIN = 32;

assign CMD_ena             [2] = CMD_write_ena[2] || CMD_read_ena2 ; // Temporary trick for backwards compatibility.
assign CMD_wmask           [2] = 3 ;                                 // Make sure write enable is there for the first 16 bits.
assign CMD_read_vector_in  [2] = 0 ;
assign CMD_priority_boost  [2] = 0 ;

assign CMD_write_ena       [3] = 0;
assign CMD_wdata           [3] = 0;
assign CMD_wmask           [3] = 0;
assign CMD_read_vector_in  [3] = 0;
assign CMD_priority_boost  [3] = 0;


// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// *** BrianHG_GFX_VGA_Window_System_DDR3_REGS *******************************************************************
// *** Multi-window BrianHG_DDR3 Video Graphics Adapter. *********************************************************
// *** BEGIN...  *************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************

wire VID_CLK,VID_CLK_2x ;

BrianHG_GFX_PLL_i50_o216_o297  VGA_PLL (
.CLK_IN_50      ( CLK_IN        ),
.RESET          ( RST_IN        ),
.SEL_297        (               ),         // For the switched output, low = 216MHz or high = 297MHz.
.CLK_SWITCH     ( VID_CLK_2x    ),         // 216.0/297.0 MHz out.
.CLK_SWITCH_50  ( VID_CLK       ),         // 108.0/148.5 MHz out.
.CLK_54         (               ),         // 54 MHz out. - Used to generate an exact 48KHz I2S audio as it can divide evenly into that frequency.
.CLK_7425       (               ),         // 74.25 MHz out.
.LOCKED         (               )
);

wire [31:0] VOUT_RGBA  ;
wire        VOUT_CLK   ;
wire        VOUT_DE    ;
wire        VOUT_HS    ;
wire        VOUT_VS    ;

BrianHG_GFX_VGA_Window_System_DDR3_REGS #(

.HWREG_BASE_ADDRESS     ( HWREG_BASE_ADDRESS          ), // The first address where the HW REG controls are located for window layer 0
.HWREG_BASE_ADDR_LSWAP  ( HWREG_BASE_ADDR_LSWAP       ),
.ENDIAN                 ( ENDIAN                      ), // **** Read source code for parameter definitions.
.PORT_ADDR_SIZE         ( PORT_ADDR_SIZE              ),
.PORT_VECTOR_SIZE       ( PORT_VECTOR_SIZE            ),
.PORT_CACHE_BITS        ( PORT_CACHE_BITS             ),
.PDI_LAYERS             ( PDI_LAYERS                  ),
.SDI_LAYERS             ( SDI_LAYERS                  ),
.LBUF_WORDS             ( 256                         ),
.ENABLE_TILE_MODE       ( ENABLE_TILE_MODE            ),
.SKIP_TILE_DELAY        ( SKIP_TILE_DELAY             ),   // Skip horizontal compensation delay due to disabled tile mode features.  Only necessary for multiple PDI_LAYERS with mixed tile enable options.
.TILE_BASE_ADDR         ( TILE_BASE_ADDR              ),
.TILE_WORDS             ( TILE_BYTES/PORT_CACHE_BITS*8),
//.TILE_MIF_FILE          ( TILE_MIF_FILE               ),  = "VGA_FONT_8x16_mono32.mif", //*******DAMN ALTERA STRING BUG!!!! 
.ENABLE_PALETTE         ( ENABLE_PALETTE              ),
.SKIP_PALETTE_DELAY     ( SKIP_PALETTE_DELAY          ),   // Skip horizontal compensation delay due to disabled palette.  Only necessary for multiple PDI_LAYERS with mixed palette enable options.
.PAL_BASE_ADDR          ( PAL_BASE_ADDR               ),
.PAL_ADR_SHIFT          ( 0                           ),
//.PAL_MIF_FILE           ( PAL_MIF_FILE                ),   = "VGA_PALETTE_RGBA32.mif", //*******DAMN ALTERA STRING BUG!!!!
.OPTIMIZE_TW_FMAX       ( BHG_EXTRA_SPEED             ),
.OPTIMIZE_PW_FMAX       ( BHG_EXTRA_SPEED             )

) BHG_VGASYS_HWREGS (

.CMD_RST                ( RST_OUT                 ), // CMD section reset.
.CMD_CLK                ( CMD_CLK                 ), // System CMD RAM clock.
.CMD_DDR3_ready         ( DDR3_READY              ), // Enables display and DDR3 reading of data.

.CMD_busy               ( CMD_busy            [4] ), // Only send out commands when DDR3 is not busy.
.CMD_ena                ( CMD_ena             [4] ), // Transmit a DDR3 command.
.CMD_write_ena          ( CMD_write_ena       [4] ), // Send a write data command. *** Not in use.
.CMD_wdata              ( CMD_wdata           [4] ), // Write data.                *** Not in use.
.CMD_wmask              ( CMD_wmask           [4] ), // Write mask.                *** Not in use.
.CMD_addr               ( CMD_addr            [4] ), // DDR3 memory address in byte form.
.CMD_read_vector_tx     ( CMD_read_vector_in  [4] ), // Contains the destination line buffer address.  ***_tx to avoid confusion, IE: Send this port to the DDR3's read vector input.
.CMD_priority_boost     ( CMD_priority_boost  [4] ), // Boost the read command above everything else including DDR3 refresh. *** Not in use.
.CMD_read_ready         ( CMD_read_ready      [4] ),
.CMD_rdata              ( CMD_read_data       [4] ), 
.CMD_read_vector_rx     ( CMD_read_vector_out [4] ), // Contains the destination line buffer address.  ***_rx to avoid confusion, IE: the DDR3's read vector results drives this port.
.TAP_wena               ( TAP_WRITE_ENA           ),
.TAP_waddr              ( TAP_ADDR                ),
.TAP_wdata              ( TAP_WDATA               ),
.TAP_wmask              ( TAP_WMASK               ),

.CMD_VID_hena           ( CMD_VID_hena            ), // Horizontal Video Enable in the CMD_CLK domain.
.CMD_VID_vena           ( CMD_VID_vena            ), // Vertical   Video Enable in the CMD_CLK domain.

.VID_RST                ( RST_IN                  ), // Video output pixel clock's reset.
.VID_CLK                ( VID_CLK                 ), // Reference PLL clock.
.VID_CLK_2x             ( VID_CLK_2x              ), // Reference PLL clock.
.PIXEL_CLK              ( VOUT_CLK                ), // Pixel output clock.
.RGBA                   ( VOUT_RGBA               ), // 32 bit Video picture data output: Reg, Green, Blue, Alpha-Blend
.VENA_out               ( VOUT_DE                 ), // High during active video.
.HS_out                 ( VOUT_HS                 ), // Horizontal sync output.
.VS_out                 ( VOUT_VS                 )  // Vertical sync output.
);

assign HDMI_TX_CLK      = VOUT_CLK;
assign HDMI_TX_DE       = VOUT_DE ;
assign HDMI_TX_HS       = VOUT_HS ;
assign HDMI_TX_VS       = VOUT_VS ;
assign HDMI_TX_D[23:16] = VOUT_RGBA[31:24]  ;// DB232_rx0[0] ? VOUT_RGBA[31:24] : VOUT_RGBA[23:16] ;
assign HDMI_TX_D[15:8]  = VOUT_RGBA[23:16]  ;// DB232_rx0[0] ? VOUT_RGBA[23:16] : VOUT_RGBA[15:8] ;
assign HDMI_TX_D[7:0]   = VOUT_RGBA[15:8]   ;// DB232_rx0[0] ? VOUT_RGBA[15:8]  : VOUT_RGBA[7:0]  ;

// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// *** BrianHG_GFX_VGA_Window_System_DDR3_REGS *******************************************************************
// *** Multi-window BrianHG_DDR3 Video Graphics Adapter. *********************************************************
// *** END...  ***************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************
// ***************************************************************************************************************

// HDMI I2C configuration.
logic RST_IN_c50 = 0 ;
always @(posedge CLK_IN) RST_IN_c50 <= RST_IN;

I2C_HDMI_Config u_I2C_HDMI_Config (

   .iCLK(CLK_IN),
   .iRST_N(!RST_IN_c50),
   .I2C_SCLK(HDMI_I2C_SCL),
   .I2C_SDAT(HDMI_I2C_SDA),
   .HDMI_TX_INT(HDMI_TX_INT)
   
);

/*
// Audio PLL clock generator.
sys_pll u_sys_pll (
   .inclk0(CLK_IN),
   .areset(RST_IN),
   .c0(pll_1536k) );

// HDMI Audio test tone generator.
AUDIO_IF u_AVG(
   .clk(pll_1536k),
   .reset_n(!RST_IN),
   .sclk(HDMI_SCLK),
   .lrclk(HDMI_LRCLK),
   .i2s(HDMI_I2S) );
*/


// ********************************************************************************************
// ********************************************************************************************
// ********* Simple hard wiring of read and write port 0 to the RS232-Debugger module.
// ********************************************************************************************
// ********************************************************************************************
localparam   RS232_MEM_ADR_SIZE = 24 ; // Maximum = 20, IE 15 seconds to transfer the entire 1 megabyte by RS232...

logic                          RS232_RST_OUT  ;
logic                          RS232_RXD      ;
logic                          RS232_TXD      ;
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

// ******************************************************************************************************
// This module is a test RS232 bridge which uses BrianHG's RS232_Debugger.exe Windows app.
// ******************************************************************************************************
rs232_debugger #(

   .CLK_IN_HZ(CLK_KHZ_IN*CLK_IN_MULT/CLK_IN_DIV*250),
   .BAUD_RATE(921600),
   .ADDR_SIZE(RS232_MEM_ADR_SIZE),
   .READ_REQ_1CLK(0)
   
) rs232_debug (

   .clk         ( DDR3_CLK_25   ),    // System clock.  Recommend at least 20MHz for the 921600 baud rate.
   .cmd_rst     ( RS232_RST_OUT ),    // When sent by the PC RS232_Debugger utility this outputs a high signal for 8 clock cycles.
   .rxd         ( RS232_RXD     ),    // Connect this to the RS232 RXD input pin.
   .txd         ( RS232_TXD     ),    // Connect this to the RS232 TXD output pin.
   .LED_txd     ( RS232_TXD_LED ),    // Optionally wire this to a LED it will go high whenever the RS232 TXD is active.
   .LED_rxd     ( RS232_RXD_LED ),    // Optionally wire this to a LED it will go high whenever the RS232 RXD is active.
   .host_rd_req ( DB232_rreq    ),    // This output will pulse high for 1 clock when a read request is taking place.
   .host_rd_rdy ( DB232_rrdy    ),    // This input should be set high once the 'host_rdata[7:0]' input contains valid data.
   .host_wr_ena ( DB232_wreq    ),    // This output will pulse high for 1 clock when a write request is taking place.
   .host_addr   ( DB232_addr    ),    // This output contains the requested read and write address.
   .host_wdata  ( DB232_wdat    ),    // This output contains the source RS232 8bit data to be written.
   .host_rdata  ( DB232_rdat    ),    // This input receives the 8 bit ram data to be sent to the RS232.
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

assign RST_IN = RS232_RST_OUT  ;   // The BrianHG_DDR3_PLL module has a reset generator.  This external one is optional.
assign CLK_IN = MAX10_CLK1_50  ;   // Assign the reference 50MHz pll.

// Nockieboy GPU debug RS232 pins.
assign GPIO0_D[6] = RS232_TXD  ;   // Assign the RS232 debugger TXD output pin.
assign GPIO0_D[7] = 1'bz       ;   // Make this IO into a tri-state input.
assign RS232_RXD  = GPIO0_D[7] ;   // Assign the RS232 debugger RXD input pin.

// BG RS232 debug pins.
//assign GPIO0_D[1] = RS232_TXD ;     // Assign the RS232 debugger TXD output pin.
//assign GPIO0_D[3] = 1'bz       ;    // Make this IO into a tri-state input.
//assign RS232_RXD  = GPIO0_D[3] ;    // Assign the RS232 debugger RXD input pin.

logic [7:0] p0_data;
logic       p0_drdy;
logic       DB232_wreq_dly,DB232_rreq_dly,p0_drdy_dly; // cross clock domain delay pipes.

// Latch the read data from port 0 on the CMD_CLK clock.
assign     CMD_priority_boost  [0]  = 0 ; // Make sure the priority boost is disabled.
assign     CMD_read_vector_in  [0]  = 0 ; // Make sure the read vector is disabled.
assign     CMD_wmask           [0]  = (PORT_CACHE_BITS/8)'(1)            ; // 8 bit write data has only 1 write mask bit.     

always_ff @(posedge CMD_CLK) begin 

   if (RST_OUT) begin              // RST_OUT is clocked on the CMD_CLK source.

      cnt_read       <= 0 ;
      CMD_ena             [0]  <= 0 ; // Clear all the read requests.
      CMD_addr            [0]  <= 0 ; // Clear all the read requests.
      CMD_write_ena       [0]  <= 0 ; // Clear all the write requests.
      CMD_wdata           [0]  <= 0 ; // Clear all the write requests.

   end else begin
                                                
      // Wire the 8 bit write port.  We can get away with crossing a clock boundary with the write port.
      // Since there is no busy for the RS232 debugger write command, write port[0]'s priority was made 7 so it overrides everything else.
      CMD_addr           [0] <= (PORT_ADDR_SIZE)'(DB232_addr)      ; // Set the RS232 write address.
      CMD_wdata          [0] <= (PORT_CACHE_BITS)'(DB232_wdat)     ; // Set the RS232 write data.
      CMD_write_ena      [0] <=  DB232_wreq                        ;
      CMD_ena            [0] <=  DB232_wreq || DB232_rreq          ;
      DB232_rrdy             <=  CMD_read_ready              [0]   ;
      DB232_rdat             <=  8'(CMD_read_data            [0] ) ;

      // Detect the toggle Create a read command counter.
      DB232_rrdy_dly <= DB232_rrdy ;
      if (DB232_rrdy && !DB232_rrdy_dly) cnt_read <= cnt_read + 1'b1;

   end // !reset

   DB232_tx3[7:0] <= RDCAL_data[7:0] ; // Send out read calibration data.
   DB232_tx1[7:0] <= cnt_read[7:0]   ;
   DB232_tx2[7:0] <= cnt_read[15:8]  ;

end // @CMD_CLK


// Show LEDs and send them to one of the RD232 debugger display ports.
always_ff @(posedge CMD_CLK) begin    // Make sure the signals driving LED's aren't route optimized for the LED's IO pin location.

    DB232_tx0[0]   <= RS232_TXD_LED ;     // RS232 Debugger TXD status LED
    DB232_tx0[1]   <= 1'b0 ;              // Turn off LED.
    DB232_tx0[2]   <= PLL_LOCKED   ;
    DB232_tx0[3]   <= SEQ_CAL_PASS ;              // Turn off LED.
    DB232_tx0[4]   <= DDR3_READY ;
    DB232_tx0[5]   <= 1'b0 ;
    DB232_tx0[6]   <= 1'b0 ;              // Turn off LED.
    DB232_tx0[7]   <= RS232_RXD_LED ;     // RS232 Debugger RXD status LED
    LED            <= 8'hff ^ RDCAL_data ^  8'((RS232_TXD_LED || RS232_RXD_LED)<<7); // Pass the calibration data to the LEDs.

end

// ******************************************************************************************************
// This clears up the 'output port has no driver' warnings.
// ******************************************************************************************************

//assign HDMI_TX_D        = 0 ;
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
//assign SD_CLK           = 0 ;
//assign SD_CMD_DIR       = 0 ;
//assign SD_D0_DIR        = 0 ;
//assign SD_SEL           = 0 ;
assign TEMP_CS_n        = 1 ;
assign TEMP_SC          = 0 ;
assign USB_CS           = 0 ;
assign USB_RESET_n      = 0 ;
assign USB_STP          = 0 ;


endmodule
