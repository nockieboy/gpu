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

logic [3:0] LUT_shift [0:255] = '{
15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,  // Shift values for bpp=0,  target=0 through 15.
14,12,10, 8, 6, 4, 2, 0,14,12,10, 8, 6, 4, 2, 0,  // Shift values for bpp=1,  target=0 through 15.
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=2,  invalid bitplane mode, no shift
12, 8, 4, 0,12, 8, 4, 0,12, 8, 4, 0,12, 8, 4, 0,  // Shift values for bpp=3,  target=0 through 15.
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=4,  invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=5,  invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=6,  invalid bitplane mode, no shift
 8, 0, 8, 0, 8, 0, 8, 0, 8, 0, 8, 0, 8, 0, 8, 0,  // Shift values for bpp=7,  target=0 through 15.
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=8,  invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=9,  invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=10, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=11, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=12, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=13, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // Shift values for bpp=14, invalid bitplane mode, no shift
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   // Shift values for bpp=15, target=0 through 15.
};
logic [15:0] LUT_mask  [0:15]  = '{ 1,3,3,15,15,15,15,255,255,255,255,255,255,255,255,65535 };  // mask result bits after shift pixel-1  0=1 bit, 1=2bit, 3=4bit, 7=8bit, 15-16bit.
//logic [15:0] LUT_nmask [0:255] ;
//logic [15:0] LUT_pmask [0:255] ;


//logic [3:0] CMD_IN_NOP              = 0  ;
logic [3:0] CMD_IN_PXWRI            = 1  ;
logic [3:0] CMD_IN_PXWRI_M          = 2  ;
logic [3:0] CMD_IN_PXPASTE          = 3  ;
logic [3:0] CMD_IN_PXPASTE_M        = 4  ;
logic [3:0] CMD_IN_PXCOPY           = 6  ;
logic [3:0] CMD_IN_SETARGB          = 7  ;
logic [3:0] CMD_IN_RST_PXWRI_M      = 10 ;
//logic [3:0] CMD_IN_RST_PXPASTE_M    = 11 ;


// FIFO->pixel_writer internal command bus
logic        pixel_cmd_rdy        ;  // HIGH when data is in FIFO for pixel writer
logic [39:0] pixel_cmd_data       ;  // internal command data bus
logic        exec_cmd         = 0 ;  // HIGH to pick up next command from FIFO
// pixel_cmd breakouts
logic [7:0]  colour           = 0 ;  // colour data
logic [3:0]  pixel_cmd        = 0 ;  // specifies action to perform
logic [3:0]  bpp              = 0 ;  // bits per pixel for the addressed word
logic [3:0]  target           = 0 ;  // the byte, nybble, crumb or bit we're trying to read/modify
// cache registers
logic rc_valid                = 0 ;
logic [19:0] rc_addr          = 0 ;  // last RD address
logic [15:0] rcd              = 0 ;  // last RD data from RAM
logic [15:0] rd_pix_c_miss    = 0 ;  // decoded pixel byte for write cache miss
logic [15:0] rd_pix_c_hit     = 0 ;  // decoded pixel byte for write cache hit
logic [7:0]  rc_colour        = 0 ;  // last RD colour data
logic [3:0]  rc_bpp           = 0 ;  // last RD bpp setting
logic [3:0]  rc_target        = 0 ;  // last RD target value
logic        PX_COPY_COLOUR_z = 0 ;  // read pixel is = 0
logic        set_rgb          = 0 ;  // high when the 'CMD_IN_SETARGB' comes in.
//
logic wc_valid                = 0 ;
logic [19:0] wc_addr          = 0 ; // last WR address
logic [15:0] wcd              = 0 ; // last WR data from RAM
logic [15:0] wr_pix_c_miss    = 0 ; // decoded pixel byte for write cache miss
logic [15:0] wr_pix_c_hit     = 0 ; // decoded pixel byte for write cache hit
logic [15:0] wr_pix_c_miss_m  = 0 ; // decoded pixel byte for write cache miss after transparency has been applied
logic [15:0] wr_pix_c_hit_m   = 0 ; // decoded pixel byte for write cache hit after transparency has been applied
logic        wr_pix_cz_miss   = 0 ; // check if writent pixel = 0 during a write cache miss
logic        wr_pix_cz_hit    = 0 ; // check if writent pixel = 0 during a write cache hit
logic [7:0]  wc_colour        = 0 ; // last WR colour data
logic [15:0] colour_sel_miss  = 0 ; // When writing pixel, this selects between pixel write latched color, or, pixel paste color.
logic [15:0] colour_sel_hit   = 0 ; // When writing pixel, this selects between pixel write immediate color, or, pixel paste color.
logic [3:0]  wc_bpp           = 0 ; // last WR bpp setting
logic [3:0]  wc_target        = 0 ; // last WR target value
logic        paste_pixel      = 0 ; // high when a paste style write pixel command is sent.
logic        mask_enable      = 0 ; // high when a write pixel with a mask enable is sent.
logic        wc_paste_pixel   = 0 ; // high when a paste style write pixel command is sent.
logic        wc_mask_enable   = 0 ; // high when a write pixel with a mask enable is sent.
logic        mask_pixel_miss  = 0 ; // High when the pixel to be writen is 0.  Used when the transparency mask is enabled.
logic        mask_pixel_hit   = 0 ; // High when the pixel to be writen is 0.  Used when the transparency mask is enabled.
logic        wr_ena_ladr      = 0 ; // When writing a pixel, this selects whether to use the current command address or the latched write address.
// general logic
logic rd_addr_valid           = 0 ;  // HIGH when new address matches cached address
logic wr_addr_valid           = 0 ;  // HIGH when new address matches cached address
//logic stop_fifo_read          = 0 ;  // HIGH to stop drawing commands from FIFO
//
logic collision_rd_inc        = 0 ;
logic collision_wr_inc        = 0 ;
//
logic rd_wait_a               = 0 ;  // HIGH whilst waiting for a_channel RD op to complete
logic rd_wait_b               = 0 ;  // HIGH whilst waiting for b_channel RD op to complete
//
logic rd_cache_hit            = 0 ;
logic wr_cache_hit            = 0 ;

logic write_pixel             = 0 ; // high when any write pixel command takes place.
logic copy_pixel              = 0 ; // high when any write pixel command takes place.

FIFO_2word_FWFT input_cmd_fifo_1 (              // Zero Latency Command buffer
//FIFO_3word_0_latency input_cmd_fifo_1 (  // Zero Latency Command buffer
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
    input_cmd_fifo_1.bits  = 40 ;              // The number of bits containing the command
//    input_cmd_fifo_1.zero_latency         = 0,
//    input_cmd_fifo_1.overflow_protection  = 0,  // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
//    input_cmd_fifo_1.underflow_protection = 0,  // Prevents internal position position increment if the fifo is empty
//    input_cmd_fifo_1.size7_ena            = 0;  // Set to 0 for 3 words

always_comb begin

//for (logic [7:0] i = 0 ; i < 255 ; i++) begin
// LUT_nmask[i] = (16'hFFFF ^ (LUT_mask[i[7:4]] << LUT_shift[i[7:0]])) ;
// LUT_pmask[i] = (           (LUT_mask[i[7:4]] << LUT_shift[i[7:0]])) ;
//end

	// break the pixel_cmd_data down into clear sub-components:
	pixel_cmd[3:0] = pixel_cmd_data[39:36] ;  // command code
	colour[7:0]    = pixel_cmd_data[35:28] ;  // colour data
	bpp[3:0]       = pixel_cmd_data[27:24] ;  // bits per pixel (width)
	target[3:0]    = pixel_cmd_data[23:20] ;  // target bit (sub-word)

	ram_addr[19:0] = wr_ena_ladr ? wc_addr[19:0] : pixel_cmd_data[19:0] ; // select the R/W address.

	write_pixel    = (pixel_cmd[3:0] == CMD_IN_PXWRI) || (pixel_cmd[3:0] == CMD_IN_PXWRI_M) || (pixel_cmd[3:0] == CMD_IN_PXPASTE) || (pixel_cmd[3:0] == CMD_IN_PXPASTE_M) ;
	copy_pixel     = (pixel_cmd[3:0] == CMD_IN_PXCOPY) ;
	paste_pixel    = (pixel_cmd[3:0] == CMD_IN_PXPASTE) || (pixel_cmd[3:0] == CMD_IN_PXPASTE_M) ;
	mask_enable    = (pixel_cmd[3:0] == CMD_IN_PXWRI_M) || (pixel_cmd[3:0] == CMD_IN_PXPASTE_M) ;
	set_rgb        = (pixel_cmd[3:0] == CMD_IN_SETARGB) && pixel_cmd_rdy ; // used to set a 16 bit color inside the paste command.

	// logic
	rd_addr_valid  = ( pixel_cmd_data[19:0] == rc_addr ) ;
	wr_addr_valid  = ( pixel_cmd_data[19:0] == wc_addr ) ;
	rd_cache_hit   = rd_addr_valid && rc_valid ;
	wr_cache_hit   = wr_addr_valid && wc_valid ;
	exec_cmd       = ( !(rd_wait_a || rd_wait_b) && pixel_cmd_rdy && !(!wr_cache_hit && wr_ena) ) && !ram_mux_busy ;

	rd_req_a       = exec_cmd && copy_pixel  && !rd_cache_hit && !reset ;
	rd_req_b       = exec_cmd && write_pixel && !wr_cache_hit && !reset ;

	rd_pix_c_miss  = ( rd_data_in >> LUT_shift[{rc_bpp,rc_target}]) & LUT_mask[rc_bpp] ; // Separate out the PX_COPY_COLOUR
	rd_pix_c_hit   = ( rcd        >> LUT_shift[{bpp   ,target   }]) & LUT_mask[bpp   ] ; // Separate out the PX_COPY_COLOUR

	colour_sel_miss = 16'(wc_paste_pixel ? (PX_COPY_COLOUR ^ {8'd0,wc_colour}) : {8'd0,(wc_colour & LUT_mask[wc_bpp])}) ; // select between copy buffer color for paste XORed with immediate color, or immediate color 
	colour_sel_hit  = 16'(paste_pixel    ? (PX_COPY_COLOUR ^ {8'd0,colour   }) : {8'd0,(colour    & LUT_mask[bpp   ])}) ; // select between copy buffer color for paste XORed with immediate color, or immediate color 
	//colour_sel_miss  = 16'(wc_paste_pixel ? (PX_COPY_COLOUR + {8'd0,wc_colour}) : {8'd0,(wc_colour & LUT_mask[wc_bpp])}) ; // select between copy buffer color for paste XORed with immediate color, or immediate color
	//colour_sel_hit   = 16'(paste_pixel    ? (PX_COPY_COLOUR + {8'd0,colour   }) : {8'd0,(colour    & LUT_mask[bpp   ])}) ; // select between copy buffer color for paste XORed with immediate color, or immediate color
	//colour_sel_miss  = 16'(wc_paste_pixel ? (PX_COPY_COLOUR + {8'd0,wc_colour}) : {8'd0,(wc_colour)})  & LUT_mask[wc_bpp]; // select between copy buffer color for paste XORed with immediate color, or immediate color
	//colour_sel_hit   = 16'(paste_pixel    ? (PX_COPY_COLOUR + {8'd0,colour   }) : {8'd0,(colour)})     & LUT_mask[bpp   ]; // select between copy buffer color for paste XORed with immediate color, or immediate color

	wr_pix_c_miss  = rd_data_in & (16'hFFFF ^ (LUT_mask[wc_bpp] << LUT_shift[{wc_bpp,wc_target}])) | ( colour_sel_miss << LUT_shift[{wc_bpp,wc_target}] ) ; // Separate out the PX_COPY_COLOUR
	wr_pix_c_hit   = wcd        & (16'hFFFF ^ (LUT_mask[bpp   ] << LUT_shift[{bpp   ,target   }])) | ( colour_sel_hit  << LUT_shift[{bpp   ,target   }] ) ; // Separate out the PX_COPY_COLOUR
	//wr_pix_c_miss  = (rd_data_in & LUT_nmask[{wc_bpp,wc_target}]) | ( colour_sel_miss << LUT_shift[{wc_bpp,wc_target}] ) ; // Separate out the PX_COPY_COLOUR
	//wr_pix_c_hit   = (wcd        & LUT_nmask[{bpp   ,target   }]) | ( colour_sel_hit  << LUT_shift[{bpp   ,target   }] ) ; // Separate out the PX_COPY_COLOUR

	wr_pix_cz_miss = ( ((rd_data_in >> LUT_shift[{wc_bpp,wc_target}]) & LUT_mask[wc_bpp]) == 0 ) ; // Determine if the pixel being written to is a 0
	wr_pix_cz_hit  = ( ((wcd        >> LUT_shift[{bpp   ,target   }]) & LUT_mask[bpp   ]) == 0 ) ; // Determine if the pixel being written to is a 0
	//wr_pix_cz_miss = ( (rd_data_in & LUT_pmask[{wc_bpp,wc_target}]) == 0 ) ; // Determine if the pixel being written to is a 0
	//wr_pix_cz_hit =  ( (wcd        & LUT_pmask[{bpp   ,target   }]) == 0 ) ; // Determine if the pixel being written to is a 0

	mask_pixel_miss  = (wc_paste_pixel ? PX_COPY_COLOUR_z : (wc_colour ==0)) && wc_mask_enable ; // determine if the chosen color of pixel to write is = 0 and mask is not enabled
	mask_pixel_hit   = (paste_pixel    ? PX_COPY_COLOUR_z : (colour    ==0)) && mask_enable    ; // determine if the chosen color of pixel to write is = 0 and mask is not enabled

	wr_pix_c_miss_m  = mask_pixel_miss ? rd_data_in : wr_pix_c_miss ; // select pixel write color, or, transparent color
	wr_pix_c_hit_m   = mask_pixel_hit  ? wcd        : wr_pix_c_hit  ; // select pixel write color, or, transparent color

end

always_ff @( posedge clk or posedge reset) begin

    if ( reset ) begin
	 
        // reset the collision counters
        collision_rd      <= 8'b0  ;
        collision_wr      <= 8'b0  ;
        // reset the cache registers
        rc_addr           <= 20'b0 ;
        rc_colour         <= 8'b0  ;
        rc_bpp            <= 4'b0  ;
        rc_target         <= 4'b0  ;
        //
        wc_addr           <= 20'b0 ;
        wc_colour         <= 8'b0  ;
        wc_bpp            <= 4'b0  ;
        wc_target         <= 4'b0  ;
        //
        rc_valid          <= 1'b0  ;
        wc_valid          <= 1'b0  ;
        //
        rd_wait_a         <= 1'b0  ;
        rd_wait_b         <= 1'b0  ;
        //
        wr_ena_ladr       <= 1'b0  ; // end write sequence.
        wr_ena            <= 1'b0  ; // end write sequence.

        ram_wr_data       <= 0;

        
    end else begin // if reset


      if ( collision_rd_rst || (pixel_cmd == CMD_IN_RST_PXWRI_M && exec_cmd) ) collision_rd <= 8'b0 ;                 // reset the write pixel READ collision_rd counter
 else if ((collision_rd != 255) && (collision_rd_inc) )            collision_rd <= collision_rd + 1'b1 ;  // increment collision_rd counter
      if ( collision_wr_rst || (pixel_cmd == CMD_IN_RST_PXWRI_M && exec_cmd) ) collision_wr <= 8'b0 ;                 // reset the write pixel WRITE collision_wr counter
 else if ((collision_wr != 255) && (collision_wr_inc) )            collision_wr <= collision_wr + 1'b1 ;  // increment collision_wr counter


	if (rd_data_rdy_b) begin                                        // If a ram read was returned
	
		rd_wait_b          <= 1'b0            ; // Turn off the wait
		wc_valid           <= 1'b1            ; // Make the cache valid
		ram_wr_data        <= wr_pix_c_miss_m ; 
		wcd                <= wr_pix_c_miss_m ;
		collision_wr_inc   <= !mask_pixel_miss && !wr_pix_cz_miss ; // Detect a write collision
		collision_rd_inc   <= !wr_pix_cz_miss                     ; // Detect if a destination pixel already has any other color than 0
		wr_ena_ladr        <= 1'b1            ; // initiate a write using the latched address.
		wr_ena             <= 1'b1            ; // initiate a write using the latched address.

	end else if (!wr_cache_hit && exec_cmd && write_pixel ) begin   // If there is a read command with a cache miss,
	
		rd_wait_b          <= 1'b1            ; // hold everything while we wait for new data from RAM
		wc_addr            <= ram_addr        ; // cache new address
		wc_valid           <= 1'b0            ; // clear cache valid flag in case it wasn't already cleared 
		wc_colour          <= colour          ; // colour data
		wc_bpp             <= bpp             ; // bits per pixel (width)
		wc_target          <= target          ; // target bit (sub-word)
		wc_paste_pixel     <= paste_pixel     ; // write pixel using the copy read color
		wc_mask_enable     <= mask_enable     ; // write pixel with the transparent mask enabled.
		wr_ena_ladr        <= 1'b0            ; // end write sequence.
		wr_ena             <= 1'b0            ; // end write sequence.
		collision_wr_inc   <= 1'b0            ; // end write sequence.
		collision_rd_inc   <= 1'b0            ; // end write sequence.

	end else if (exec_cmd && write_pixel && wr_cache_hit)  begin
	
		ram_wr_data        <= wr_pix_c_hit_m  ; 
		wcd                <= wr_pix_c_hit_m  ;
		collision_wr_inc   <= !mask_pixel_hit && !wr_pix_cz_hit ; // Detect a write collision
		collision_rd_inc   <= !wr_pix_cz_hit                    ; // Detect if a destination pixel already has any other color than 0
		wr_ena_ladr        <= 1'b1            ; // initiate a write using the immediate address.
		wr_ena             <= 1'b1            ; // initiate a write using the immediate address.
			  
	end else begin
	
		wr_ena_ladr        <= 1'b0            ; // end write sequence.
		wr_ena             <= 1'b0            ; // end write sequence.
		collision_wr_inc   <= 1'b0            ; // end write sequence.
		collision_rd_inc   <= 1'b0            ; // end write sequence.
		
	end


	if (set_rgb) begin // manually set a 16 bit RGB color
	
		rc_valid           <= 1'b0                 ; // cache is no longer valid.
		PX_COPY_COLOUR     <= pixel_cmd_data[15:0] ; // Set the 16 bit RGB color value
		PX_COPY_COLOUR_z   <= 0 ;//(pixel_cmd_data[15:0] ==0)  ; // Set the 16 bit RGB color value  Disable, paint black black

	end else if (wr_ena && (wc_addr==rc_addr) && rc_valid ) begin   // A written pixel has the same address as the read cache
	
		rcd                <= ram_wr_data ;     // so, we should copy the new writen pixel data into the read cache

	end else if (rd_data_rdy_a) begin                                                       // If a ram read request was returned
	
		rd_wait_a          <= 1'b0                                     ; // Turn off the wait
		rc_valid           <= 1'b1                                     ; // Make the cache valid
		rcd                <= rd_data_in[15:0]                         ; // store a copy of the returned read data.
		PX_COPY_COLOUR     <=   rd_pix_c_miss ^ {8'd0,rc_colour}       ; // XOR the read pixel with the PXCOPY cmd's 8 bit color setting.
		PX_COPY_COLOUR_z   <= ((rd_pix_c_miss ^ {8'd0,rc_colour}) ==0) ; // Check for a transparent color 0 pixel.

	end else if (!rd_cache_hit && exec_cmd && copy_pixel) begin    // If there is a read command with a cache miss,
	
		rc_addr            <= ram_addr  ;      // cache new address
		rd_wait_a          <= 1'b1      ;      // hold everything while we wait for new data from RAM
		rc_valid           <= 1'b0      ;      // clear cache valid flag in case it wasn't already cleared 
		rc_colour          <= colour    ;      // colour data
		rc_bpp             <= bpp       ;      // bits per pixel (width)
		rc_target          <= target    ;      // target bit (sub-word)

	end else if (exec_cmd && copy_pixel && rd_cache_hit) begin
	
		PX_COPY_COLOUR     <=   rd_pix_c_hit ^ {8'd0,colour    }        ;  // XOR the read pixel with the PXCOPY cmd's 8 bit color setting.
		PX_COPY_COLOUR_z   <= ((rd_pix_c_hit ^ {8'd0,colour    }) == 0) ;  // Check for a transparent color 0 pixel.
		
	end

 end // else reset

end

endmodule
