module geo_pixel_writer (

// **** INPUTS ****

    input logic clk,
    input logic reset,
    
    // fifo inputs
    input logic cmd_rdy,                // input to fifo_not_empty
    input logic [39:0] cmd_in,          // input to fifo_data_in
    
    // data_mux_geo inputs
    input logic [15:0] rd_data_in,      // input from data_out_geo[15:0]
    input logic rd_data_rdy_a,          // input from geo_rd_rdy_a
    input logic rd_data_rdy_b,          // input from geo_rd_rdy_b
    input logic ram_mux_busy,           // input from geo_port_full
    
    // collision saturation counter inputs
    input logic collision_rd_rst,       // input from associated read port's read strobe
    input logic collision_wr_rst,       // input from associated read port's read strobe
    
// **** OUTPUTS ****

    // fifo outputs
    output logic draw_busy,             // fifo_full output
    
    // data_mux_geo outputs
    output logic rd_req_a,              // output to geo_rd_req_a on data_mux_geo
    output logic rd_req_b,              // output to geo_rd_req_b on data_mux_geo
    output logic wr_ena,                // output to geo_wr_ena on data_mux_geo
    output logic [19:0] ram_addr,       // output to address_geo on data_mux_geo
    output logic [15:0] ram_wr_data,    // output to data_in_geo on data_mux_geo
    
    // collision saturation counter outputs
    output logic [7:0]  collision_rd,   // output to 1st read port on Z80_bridge_v2
    output logic [7:0]  collision_wr,   // output to 2nd read port on Z80_bridge_v2
    
    output logic [15:0] PX_COPY_COLOUR

);

localparam int LUT_shift [256] = '{
15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,  // Shift values for bpp=0, target=0 through 15.
14,12,10, 8, 6, 4, 2, 0,14,12,10, 8, 6, 4, 2, 0,  // Shift values for bpp=1, target=0 through 15.
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=2, invalid bitplane mode, no shift
12, 8, 4, 0,12, 8, 4, 0,12, 8, 4, 0,12, 8, 4, 0,  // Shift values for bpp=3, target=0 through 15.
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=4, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=5, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=6, invalid bitplane mode, no shift
 8, 0, 8, 0, 8, 0, 8, 0, 8, 0, 8, 0, 8, 0, 8, 0,  // Shift values for bpp=7, target=0 through 15.
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=8, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=9, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=10, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=11, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=12, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=13, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=14, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   // Shift values for bpp=15, target=0 through 15.
};
localparam int LUT_mask  [16]  = '{ 1,3,3,15,15,15,15,255,255,255,255,255,255,255,255,65535 };  // mask result bits after shift pixel-1  0=1 bit, 1=2bit, 3=4bit, 7=8bit, 15-16bit.

localparam CMD_IN_NOP              = 0  ;
localparam CMD_IN_PXWRI            = 1  ;
localparam CMD_IN_PXWRI_M          = 2  ;
localparam CMD_IN_PXPASTE          = 3  ;
localparam CMD_IN_PXPASTE_M        = 4  ;
localparam CMD_IN_PXCOPY           = 6  ;
localparam CMD_IN_SETARGB          = 7  ;
localparam CMD_IN_RST_PXWRI_M      = 10 ;
localparam CMD_IN_RST_PXPASTE_M    = 11 ;

parameter bit ZERO_LATENCY         = 1  ; // When set to 1 this will make the read&write commands immediate instead of a clock cycle later
parameter bit overflow_protection  = 1  ; // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
parameter bit underflow_protection = 1  ; // Prevents internal position position increment if the fifo is empty
parameter bit size7_fifo           = 0  ; // sets fifo into 7 word mode.

FIFO_3word_0_latency input_cmd_fifo_1 (  // Zero Latency Command buffer
    .clk              ( clk                  ), // CLK input
    .reset            ( reset                ), // Reset FIFO

    .shift_in         ( cmd_rdy              ), // Load data into the FIFO
    .shift_out        ( exec_cmd             ), // Shift data out of the FIFO
    .data_in          ( cmd_in[39:0]         ), // Data input from PAGET

    .fifo_not_empty   ( pixel_cmd_rdy        ), // High when there is data available for the pixel writer
    .fifo_full        ( draw_busy            ), // High when the FIFO is full - used to tell GEOFF and PAGET to halt until there is room in the FIFO again
    .data_out         ( pixel_cmd_data[39:0] )  // FIFO data output to pixel writer
);

defparam
    input_cmd_fifo_1.bits                 = 40,                   // The number of bits containing the command
    input_cmd_fifo_1.zero_latency         = ZERO_LATENCY,
    input_cmd_fifo_1.overflow_protection  = overflow_protection,  // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
    input_cmd_fifo_1.underflow_protection = underflow_protection, // Prevents internal position position increment if the fifo is empty
    input_cmd_fifo_1.size7_ena            = size7_fifo;           // Set to 0 for 3 words

// FIFO->pixel_writer internal command bus
logic        pixel_cmd_rdy  ;  // HIGH when data is in FIFO for pixel writer
logic [39:0] pixel_cmd_data ;  // internal command data bus
logic        exec_cmd       ;  // HIGH to pick up next command from FIFO
//
// collision saturation counters
logic [7:0]  wr_px_collision_counter ;
logic [7:0]  rd_px_collision_counter ;
//
// pixel_cmd breakouts
logic [7:0]  colour    ;  // colour data
logic [3:0]  pixel_cmd ;  // specifies action to perform
logic [3:0]  bpp       ;  // bits per pixel for the addressed word
logic [3:0]  target    ;  // the byte, nybble, crumb or bit we're trying to read/modify
//
// cache registers
logic        rc_valid      ;
logic [19:0] rc_addr       ;  // last RD address
logic [15:0] rcd           ;  // last RD data from RAM
logic [15:0] rd_pix_c_miss ;  // decoded pixel byte for write cache miss
logic [15:0] rd_pix_c_hit  ;  // decoded pixel byte for write cache hit
logic [7:0]  rc_colour     ;  // last RD colour data
logic [3:0]  rc_bpp        ;  // last RD bpp setting
logic [3:0]  rc_target     ;  // last RD target value
//
//
logic        wc_valid      ;
logic [19:0] wc_addr       ;  // last WR address
logic [15:0] wcd           ;  // last WR data from RAM
logic [15:0] wr_pix_c_miss ;  // decoded pixel byte for write cache miss
logic [15:0] wr_pix_c_hit  ;  // decoded pixel byte for write cache hit
logic [7:0]  wc_colour     ;  // last WR colour data
logic [3:0]  wc_bpp        ;  // last WR bpp setting
logic [3:0]  wc_target     ;  // last WR target value
//
// general logic
logic rd_addr_valid  ;  // HIGH when new address matches cached address
logic wr_addr_valid  ;  // HIGH when new address matches cached address
logic stop_fifo_read ;  // HIGH to stop drawing commands from FIFO
//
logic collision_rd_inc ;
logic collision_wr_inc ;
//
logic rd_wait_a      ;  // HIGH whilst waiting for a_channel RD op to complete
logic rd_wait_b      ;  // HIGH whilst waiting for b_channel RD op to complete
//
logic rd_cache_hit   ;
logic wr_cache_hit   ;
//
logic write_pixel    ; // high when any write pixel command takes place.
logic copy_pixel     ; // high when any write pixel command takes place.
logic wr_ena_ladr    ; // When writing a pixel, this selects whether to use the current command address or the latched write address.

always_comb begin

    // break the pixel_cmd_data down into clear sub-components:
    pixel_cmd[3:0] = pixel_cmd_data[39:36] ;  // command code
    colour[7:0]    = pixel_cmd_data[35:28] ;  // colour data
    bpp[3:0]       = pixel_cmd_data[27:24] ;  // bits per pixel (width)
    target[3:0]    = pixel_cmd_data[23:20] ;  // target bit (sub-word)
    
    ram_addr[19:0] = wr_ena_ladr ? wc_addr[19:0] : pixel_cmd_data[19:0] ;  // select the R/W address.

    write_pixel    = (pixel_cmd[3:0] == CMD_IN_PXWRI) || (pixel_cmd[3:0] == CMD_IN_PXWRI_M) || (pixel_cmd[3:0] == CMD_IN_PXPASTE) || (pixel_cmd[3:0] == CMD_IN_PXPASTE_M) ;
    copy_pixel     = (pixel_cmd[3:0] == CMD_IN_PXCOPY) ;
    
    // logic
    exec_cmd       = ( !(rd_wait_a || rd_wait_b) && pixel_cmd_rdy && !(!wr_cache_hit && wr_ena) ) ;
    rd_addr_valid  = ( pixel_cmd_data[19:0] == rc_addr ) ;
    wr_addr_valid  = ( pixel_cmd_data[19:0] == wc_addr ) ;
    rd_cache_hit   = rd_addr_valid && rc_valid ;
    wr_cache_hit   = wr_addr_valid && wc_valid ;
 
    rd_req_a       = exec_cmd && copy_pixel  && !rd_cache_hit && !reset ;
    rd_req_b       = exec_cmd && write_pixel && !wr_cache_hit && !reset ;

    wr_pix_c_miss  = rd_data_in & (16'hFFFF ^ (LUT_mask[wc_bpp] << LUT_shift[{wc_bpp,wc_target}])) | ( (wc_colour & LUT_mask[wc_bpp]) << LUT_shift[{wc_bpp,wc_target}] ) ; // Separate out the PX_COPY_COLOUR
    wr_pix_c_hit   = wcd        & (16'hFFFF ^ (LUT_mask[bpp   ] << LUT_shift[{bpp   ,target   }])) | ( (colour    & LUT_mask[bpp   ]) << LUT_shift[{bpp   ,target   }] ) ; // Separate out the PX_COPY_COLOUR

    rd_pix_c_miss  = ( rd_data_in >> LUT_shift[{rc_bpp,rc_target}]) & LUT_mask[rc_bpp] ; // Separate out the PX_COPY_COLOUR
    rd_pix_c_hit   = ( rcd        >> LUT_shift[{bpp   ,target   }]) & LUT_mask[bpp   ] ; // Separate out the PX_COPY_COLOUR

end

always_ff @( posedge clk ) begin

    if ( reset ) begin
    
        // reset the collision counters
        rd_px_collision_counter <= 8'b0 ;
        wr_px_collision_counter <= 8'b0 ;
        // reset the cache registers
        rc_addr     <= 20'b0 ;
        rc_colour   <= 8'b0  ;
        rc_bpp      <= 4'b0  ;
        rc_target   <= 4'b0  ;
        //
        wc_addr     <= 20'b0 ;
        wc_colour   <= 8'b0  ;
        wc_bpp      <= 4'b0  ;
        wc_target   <= 4'b0  ;
        //
        rc_valid    <= 1'b0  ;
        wc_valid    <= 1'b0  ;
        //
        rd_wait_a   <= 1'b0  ;
        rd_wait_b   <= 1'b0  ;
        //
        wr_ena_ladr <= 1'b0  ; // end write sequence.
        wr_ena      <= 1'b0  ; // end write sequence.
        
    end else begin // if reset

        if ( collision_rd_rst ) rd_px_collision_counter <= 8'b0 ;   // reset the COPY/READ PIXEL COLLISION counter
        if ( collision_wr_rst ) wr_px_collision_counter <= 8'b0 ;   // reset the WRITE PIXEL COLLISION counter

        if (rd_data_rdy_b) begin   // If a ram read was returned
        
             rd_wait_b    <= 1'b0          ; // Turn off the wait
             wc_valid     <= 1'b1          ; // Make the cache valid
             ram_wr_data  <= wr_pix_c_miss ; 
             wcd          <= wr_pix_c_miss ;
             wr_ena_ladr  <= 1'b1          ; // initiate a write using the latched address.
             wr_ena       <= 1'b1          ; // initiate a write using the latched address.

        end else if (!wr_cache_hit && exec_cmd && write_pixel ) begin  // If there is a read command with a cache miss,
        
             rd_wait_b    <= 1'b1          ; // hold everything while we wait for new data from RAM
             wc_addr      <= ram_addr      ; // cache new address
             wc_valid     <= 1'b0          ; // clear cache valid flag in case it wasn't already cleared 
             wc_colour    <= colour        ; // colour data
             wc_bpp       <= bpp           ; // bits per pixel (width)
             wc_target    <= target        ; // target bit (sub-word)
             wr_ena_ladr  <= 1'b0          ; // end write sequence.
             wr_ena       <= 1'b0          ; // end write sequence.

        end else if (exec_cmd && write_pixel && wr_cache_hit)  begin
        
             ram_wr_data  <= wr_pix_c_hit  ; 
             wcd          <= wr_pix_c_hit  ;

             wr_ena_ladr  <= 1'b1          ; // initiate a write using the immediate address.
             wr_ena       <= 1'b1          ; // initiate a write using the immediate address.
             
        end else begin
        
             wr_ena_ladr  <= 1'b0          ; // end write sequence.
             wr_ena       <= 1'b0          ; // end write sequence.
             
        end

        if (wr_ena && (wc_addr==rc_addr)) begin     // A written pixel has the same address as the read cache
        
             rcd            <= ram_wr_data ; // so, we should copy the new writen pixel data into the read cache

        end else if (rd_data_rdy_a) begin   // If a ram read request was returned
        
             rd_wait_a      <= 1'b0             ; // Turn off the wait
             rc_valid       <= 1'b1             ; // Make the cache valid
             rcd            <= rd_data_in[15:0] ; // store a copy of the returned read data.
             PX_COPY_COLOUR <= rd_pix_c_miss    ;

        end else if (!rd_cache_hit && exec_cmd && copy_pixel) begin  // If there is a read command with a cache miss,
        
             rc_addr        <= ram_addr ; // cache new address
             rd_wait_a      <= 1'b1     ; // hold everything while we wait for new data from RAM
             rc_valid       <= 1'b0     ; // clear cache valid flag in case it wasn't already cleared 
             rc_colour      <= colour   ; // colour data
             rc_bpp         <= bpp      ; // bits per pixel (width)
             rc_target      <= target   ; // target bit (sub-word)

        end else if (exec_cmd && copy_pixel && rd_cache_hit) begin
        
             PX_COPY_COLOUR     <= rd_pix_c_hit ;
             
        end

    end // else reset

end

endmodule
