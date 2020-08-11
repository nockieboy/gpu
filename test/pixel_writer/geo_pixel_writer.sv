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
    
    output logic [15:0] PX_COPY_COLOUR,
    output logic [15:0] PX_COPY_COLOUR_reg,
    output logic [7:0]  PX_COPY_COLOUR_opt_reg

);

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

bitplane_memory_data_to_pixel_colour get_pixel_colour_1 (
	.ram_data_rdy     ( rd_data_rdy_a        ), // use immediate values when HIGH, latched values when LOW

	.latched_word     ( rd_data_cache[15:0]  ), // 16-bit word from the catch
	.latched_colour   ( rd_cache_col[7:0]    ), // 8-bit cached colour value
	.latched_bpp      ( rd_cache_bpp[3:0]    ), // cached bits-per-pixel value
	.latched_target   ( rd_cache_bit[3:0]    ), // cached target word/byte/nybble/crumb/bit

	.immediate_word   ( rd_data_in[15:0]     ), // 16-bit word from GPU RAM
	.immediate_colour ( colour[7:0]          ), // current colour value
	.immediate_bpp    ( bpp[3:0]             ), // current bits-per-pixel value
	.immediate_target ( target[3:0]          ), // current target word/byte/nybble/crumb/bit

	.colour_eq_0      ( PX_COPY_COLOUR_eq0   ), // HIGH when colour = 0
	.source_colour    ( PX_COPY_COLOUR_opt   ), // fix for low FMAX
	.pixel_colour     ( PX_COPY_COLOUR       )  // current pixel colour value from above parameters
);

memory_pixel_bits_editor set_pixel_colour_1 (
    .ram_data_rdy            ( rd_data_rdy_a       ),
    .latched_word            ( rd_data_cache[15:0] ),
    .latched_colour          ( rd_cache_col[7:0]   ),
    .latched_bpp             ( rd_cache_bpp[3:0]   ),
    .latched_target          ( rd_cache_bit[3:0]   ),
    .immediate_word          ( rd_data_in[15:0]    ),
    .immediate_colour        ( colour[7:0]         ),
    .immediate_bpp           ( bpp[3:0]            ),
    .immediate_target        ( target[3:0]         ),

    .paste_enable            (  ),
    .paste_colour            (  ),
    .transparent_mask_enable (  ),
//outputs    
    .collision_rd_inc        ( collision_rd_inc    ),
    .collision_wr_inc        ( collision_wr_inc    ),
    .output_word             (  )
);

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
    input_cmd_fifo_1.size7_ena            = 0;                    // Set to 0 for 3 words

// FIFO->pixel_writer internal command bus
logic        pixel_cmd_rdy  ;  // HIGH when data is in FIFO for pixel writer
logic [39:0] pixel_cmd_data ;  // internal command data bus
logic        exec_cmd       ;  // HIGH to pick up next command from FIFO
logic        last_exec_cmd  ;
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
logic rd_cache_valid       ;
logic [19:0] rd_cache_addr ;  // last RD address
logic [15:0] rd_data_cache ;  // last RD data from RAM
logic [7:0]  rd_cache_col  ;  // last RD colour data
logic [3:0]  rd_cache_bpp  ;  // last RD bpp setting
logic [3:0]  rd_cache_bit  ;  // last RD target value
//
//logic [15:0] PX_COPY_COLOUR_reg     ;
logic       PX_COPY_COLOUR_eq0     ;
logic [7:0] PX_COPY_COLOUR_opt     ;
//
logic wr_cache_valid       ;
logic [19:0] wr_cache_addr ;  // last WR address
logic [7:0]  wr_cache_col  ;  // last WR colour data
logic [3:0]  wr_cache_bpp  ;  // last WR bpp setting
logic [3:0]  wr_cache_bit  ;  // last WR target value
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

always_comb begin

    // break the pixel_cmd_data down into clear sub-components:
    pixel_cmd[3:0] = pixel_cmd_data[39:36] ;  // command code
    colour[7:0]    = pixel_cmd_data[35:28] ;  // colour data
    bpp[3:0]       = pixel_cmd_data[27:24] ;  // bits per pixel (width)
    target[3:0]    = pixel_cmd_data[23:20] ;  // target bit (sub-word)
    ram_addr[19:0] = pixel_cmd_data[19:0]  ;  // address of 16-bit word in RAM
    
    // logic
    exec_cmd       = ( ( !(rd_wait_a ) && !(rd_wait_b ) ) && pixel_cmd_rdy ) ;
    rd_addr_valid  = ( ram_addr == rd_cache_addr )   ;
    wr_addr_valid  = ( ram_addr == wr_cache_addr )   ;
    rd_cache_hit   = rd_addr_valid && rd_cache_valid ;
    wr_cache_hit   = wr_addr_valid && wr_cache_valid ;
    rd_req_a       = exec_cmd && !rd_cache_hit && ( pixel_cmd[3:0] == CMD_IN_PXCOPY ) && !reset ;
    
end

always_ff @( posedge clk ) begin

    if ( reset ) begin
    
        // reset the collision counters
        rd_px_collision_counter <= 8'b0  ;
        wr_px_collision_counter <= 8'b0  ;
        // reset the cache registers
        rd_cache_addr           <= 20'b0 ;
        rd_cache_col            <= 8'b0  ;
        rd_cache_bpp            <= 4'b0  ;
        rd_cache_bit            <= 4'b0  ;
        //
        wr_cache_addr           <= 20'b0 ;
        wr_cache_col            <= 8'b0  ;
        wr_cache_bpp            <= 4'b0  ;
        wr_cache_bit            <= 4'b0  ;
        //
        rd_cache_valid          <= 1'b0  ;
        wr_cache_valid          <= 1'b0  ;
        //
        rd_req_b                <= 1'b0  ;
        rd_wait_a               <= 1'b0  ;
        rd_wait_b               <= 1'b0  ;
        //

    end else begin // if reset

        if ( collision_rd_rst ) rd_px_collision_counter <= 8'b0 ;   // reset the COPY/READ PIXEL COLLISION counter
        if ( collision_wr_rst ) wr_px_collision_counter <= 8'b0 ;   // reset the WRITE PIXEL COLLISION counter

        if ( exec_cmd ) begin

            case ( pixel_cmd[3:0] )
        
                CMD_IN_NOP : begin
                    // do nothing
                end
                
                CMD_IN_PXWRI : begin
					
					// 1 - Read current CMD address, unless cache hit
					
					rd_cache_col <= colour ;
                    rd_cache_bpp <= bpp    ;
                    rd_cache_bit <= target ;
                
                    if ( !rd_cache_valid || !rd_addr_valid ) begin  // check for cache miss on read address
                        
                        rd_cache_addr  <= ram_addr ; // cache new address
                        rd_wait_a      <= 1'b1     ; // hold everything while we wait for data from RAM
                        rd_cache_valid <= 1'b0     ; // clear cache valid flag in case it wasn't already cleared

                    end
                    
                end
                
                CMD_IN_PXWRI_M : begin
                    
                end
                
                CMD_IN_PXPASTE : begin
                    
                end

                CMD_IN_PXPASTE_M : begin
                    
                end
                
                CMD_IN_PXCOPY : begin
                
                    rd_cache_col   <= colour   ;
                    rd_cache_bpp   <= bpp      ;
                    rd_cache_bit   <= target   ;
                
                    if ( !rd_cache_valid || !rd_addr_valid ) begin  // check for cache miss on read address
                        
                        rd_cache_addr  <= ram_addr ; // cache new address
                        rd_wait_a      <= 1'b1     ; // hold everything while we wait for data from RAM
                        rd_cache_valid <= 1'b0     ; // clear cache valid flag in case it wasn't already cleared
                    
                    end else begin
                    
                    
                    
                    end

                end
                
                CMD_IN_SETARGB : begin
                    
                end
                
                CMD_IN_RST_PXWRI_M : begin
                    
                end
                
                CMD_IN_RST_PXPASTE_M : begin
                    
                end
                
                default : begin
                    // do nothing
                end
                
            endcase // case ( pixel_cmd[3:0] )
            
        end else begin // !exec_cmd
        
            if ( rd_data_rdy_a ) begin  // valid data from RAM

                rd_cache_valid <= 1'b1       ;
                rd_wait_a      <= 1'b0       ;
                rd_data_cache  <= rd_data_in ;
                
            end
        
        end // exec)_cmd
        
        last_exec_cmd <= exec_cmd ;
        
		if ( rd_data_rdy_a || ( exec_cmd && ( pixel_cmd[3:0] == CMD_IN_PXCOPY ) && rd_cache_hit ) ) begin
        
			// if pixel color data came in from RAM or was immediately available when the command came in and there was a cache hit
			PX_COPY_COLOUR_reg      <= PX_COPY_COLOUR     ; // Store pixel color
			PX_COPY_COLOUR_eq0      <= PX_COPY_COLOUR_eq0 ; // store the color =0
			PX_COPY_COLOUR_opt_reg  <= PX_COPY_COLOUR_opt ; // store the CMD_COLOR option
			
		end else if ( rd_data_rdy_a || ( exec_cmd && ( pixel_cmd[3:0] == CMD_IN_PXWRI ) && rd_cache_hit ) ) begin

			// if pixel color data came in from RAM or was immediately available when the command came in and there was a cache hit

			// 2 - Check if target pixel is 0 - if it is, increment 'rd_px_collision_counter' (and 'wr_px_collision_counter' if write colour isn't transparent 0 in '_M' cmd versions
			rd_px_collision_counter <= rd_px_collision_counter + collision_rd_inc ;
			
			// 3 - Change target bits in word cache and send a write req & new write data
			
			// 4 - If copy cache address = write cache address, when write is done, update copy_pixel cache with new data
			
			// 5 - Above steps need to set and clear write_busy flag so that a write may take place without a read
        
        end
        
    end // else reset

end

endmodule

/*
 * bitplane_memory_data_to_pixel_colour
 *
 * Combinational-logic module to provide the pixel colour from a given word of
 * data, based on its bits-per-pixel value and thus its targeted word, byte,
 * nybble, crumb or bit as a result.
 *
 * All combinational logic, no clocking or reset.
 *
 * Returns value based on cache hit (latched values), or a cache miss in which
 * case it uses the immediate values.
 *
 */
 
module bitplane_memory_data_to_pixel_colour (

// *** INPUTS
    input logic         ram_data_rdy,
    input logic  [15:0] latched_word,
    input logic  [7:0]  latched_colour,
    input logic  [3:0]  latched_bpp,
    input logic  [3:0]  latched_target,
    input logic  [15:0] immediate_word,
    input logic  [7:0]  immediate_colour,
    input logic  [3:0]  immediate_bpp,
    input logic  [3:0]  immediate_target,

// *** OUTPUTS
	output logic        colour_eq_0,
	output logic [7:0]  source_colour,
    output logic [15:0] pixel_colour
    
);

// these params are not final - I've just thrown them together for testing
localparam BPP_16bit = 4'd15;
localparam BPP_8bit  = 4'd7;
localparam BPP_4bit  = 4'd3;
localparam BPP_2bit  = 4'd1;
localparam BPP_1bit  = 4'd0;

logic [3:0]  source_bpp       ;
//logic [7:0]  source_colour    ;
logic [3:0]  source_target    ;
logic [15:0] source_word      ;
logic [15:0] int_pixel_colour ;

always_comb begin
    
    colour_eq_0   = ( int_pixel_colour == 0 ) ;
    pixel_colour  = int_pixel_colour ; //* source_colour ; // give the option for the pixel copy command to change the read color to a new larger color
    
    // set source data according to RAM read
    source_bpp    = ( !ram_data_rdy ) ? immediate_bpp    : latched_bpp    ;
    source_colour = ( !ram_data_rdy ) ? immediate_colour : latched_colour ;
    source_target = ( !ram_data_rdy ) ? immediate_target : latched_target ;
    source_word   = (  ram_data_rdy ) ? immediate_word   : latched_word   ;
    
    if ( source_bpp[3:0] == BPP_16bit ) begin
        
        int_pixel_colour = source_word ;  // not interested in source_target as the whole word is being read in 16-bit mode

    end else if ( source_bpp[3:0] == BPP_8bit ) begin
    
        if ( source_target[0] == 0 ) begin // valid source_target values of 0 or 1
        
            int_pixel_colour = source_word[15:8] ;
        
        end else begin // assume source_target = 1
        
            int_pixel_colour = source_word[7:0]  ;
        
        end

    end else if ( source_bpp[3:0] == BPP_4bit ) begin
		
		if ( source_target[1:0] == 0 ) begin // valid source_target values of 0 to 3
        
            int_pixel_colour = source_word[15:12] ;
        
        end else if ( source_target[1:0] == 1 ) begin
        
            int_pixel_colour = source_word[11:8]  ;
        
        end else if ( source_target[1:0] == 2 ) begin
        
            int_pixel_colour = source_word[7:4] ;
        
        end else begin // assume source_target == 3
        
            int_pixel_colour = source_word[3:0]  ;
        
        end
        
    end else if ( source_bpp[3:0] == BPP_2bit ) begin
    
		if ( source_target[2:0] == 0 ) begin // valid source_target values of 0 to 7
        
            int_pixel_colour = source_word[15:14] ;
        
        end else if ( source_target[2:0] == 1 ) begin
        
            int_pixel_colour = source_word[13:12]  ;
        
        end else if ( source_target[2:0] == 2 ) begin
        
            int_pixel_colour = source_word[11:10] ;
        
        end else if ( source_target[2:0] == 3 ) begin
        
            int_pixel_colour = source_word[9:8]  ;
        
        end else if ( source_target[2:0] == 4 ) begin
        
            int_pixel_colour = source_word[7:6] ;
        
        end else if ( source_target[2:0] == 5 ) begin
        
            int_pixel_colour = source_word[5:4]  ;
        
        end else if ( source_target[2:0] == 6 ) begin
        
            int_pixel_colour = source_word[3:2] ;
        
        end else begin // assume source_target == 7
        
            int_pixel_colour = source_word[1:0]  ;
        
        end

    end else begin // assume BPP_1bit
    
		int_pixel_colour = source_word[ ( ~source_target[3:0] ) ] ;  // only need to return 1 bit
    
    end
    
end

endmodule

module memory_pixel_bits_editor (

// inputs
    input logic         ram_data_rdy,
    input logic  [15:0] latched_word,
    input logic  [7:0]  latched_colour,
    input logic  [3:0]  latched_bpp,
    input logic  [3:0]  latched_target,
    input logic  [15:0] immediate_word,
    input logic  [7:0]  immediate_colour,
    input logic  [3:0]  immediate_bpp,
    input logic  [3:0]  immediate_target,

    input logic         paste_enable,
    input logic  [15:0] paste_colour,
    input logic         transparent_mask_enable,
    
// outputs
    output logic        collision_rd_inc,
    output logic        collision_wr_inc,
    output logic [15:0] output_word

);

localparam BPP_16bit = 4'd15;
localparam BPP_8bit  = 4'd7;
localparam BPP_4bit  = 4'd3;
localparam BPP_2bit  = 4'd1;
localparam BPP_1bit  = 4'd0;

logic [3:0]  source_bpp       ;
logic [15:0] source_colour    ;
logic [3:0]  source_target    ;
logic [15:0] source_word      ;
logic [15:0] target_colour    ;
logic        target_colour_0  ;
logic [15:0] edited_word      ;

always_comb

	source_color[15:8] = 0 ; // Assign 0 to the upper 8 bits of the source color.

    // set source data according to RAM read
    source_bpp         = ( !ram_data_rdy ) ? immediate_bpp    : latched_bpp    ;
    source_colour[7:0] = ( !ram_data_rdy ) ? immediate_colour : latched_colour ;
    source_target      = ( !ram_data_rdy ) ? immediate_target : latched_target ;
    source_word        = (  ram_data_rdy ) ? immediate_word   : latched_word   ;

    target_colour      = ( paste_enable )  ? paste_colour : source_colour ;
    target_colour_0    = ( target_colour == 0 ) ;
    collision_wr_inc   = collision_rd_inc && ( !target_colour_0 || !transparent_mask_enable ) ;

    output_word        = ( transparent_mask_enable && target_colour_0 ) ? source_word : edited_word ; // choose output word based on transparency mask.

	if ( source_bpp[3:0] == BPP_16bit ) begin
       
		edited_word      = target_colour              ;
		collision_rd_inc = ( source_word[15:0] != 0 ) ;

    end else if ( source_bpp[3:0] == BPP_8bit ) begin
   
		if (source_target[0]) begin                    // place target color into the first 8 bits and retain the upper 8 bits.
		
			edited_word[15:8] = target_colour[7:0]        ;
			edited_word[7:0]  = source_word[7:0]          ;
			collision_rd_inc  = ( source_word[15:8] !=0 ) ;

		end else begin                                 // place target color into the upper 8 bits and retain the lower 8 bits.
		
			edited_word[7:0]  = target_colour[7:0]        ;
			edited_word[15:8] = source_word[15:8]         ;
			collision_rd_inc  = ( source_word[7:0] != 0 ) ;
			
		end

	end else if ( source_bpp[3:0] == BPP_4bit ) begin
		
		if ( source_target[1:0] == 0 ) begin           // place target color into the first 4 bits and retain the upper 12 bits.
	
			edited_word[15:12] = target_colour[3:0]          ;
			edited_word[11:0]  = source_word[11:0]           ;
			collision_rd_inc   = ( source_word[15:12] != 0 ) ;

		end else if ( source_target[1:0] == 1 ) begin  // place target color into the second 4 bits and retain the upper 8 bits and lower 4 bits.
	
			edited_word[15:12] = source_word[15:12]         ;
			edited_word[11:8]  = target_colour[3:0]         ;
			edited_word[7:0]   = source_word[7:0]           ;
			collision_rd_inc   = ( source_word[11:8] != 0 ) ;
			
		end else if ( source_target[1:0] == 2 ) begin  // place target color into the third 4 bits and retain the upper 4 bits and lower 8 bits.
	
			edited_word[15:8] = source_word[15:8]         ;
			edited_word[7:4]  = target_colour[3:0]        ;
			edited_word[3:0]  = source_word[3:0]          ;
			collision_rd_inc  = ( source_word[7:4] != 0 ) ;
			
		end else begin                                 // place target color into the last 4 bits and retain the lower 12 bits.
	
			edited_word[15:4] = source_word[15:4]         ;
			edited_word[3:0]  = target_colour[3:0]        ;
			collision_rd_inc  = ( source_word[3:0] != 0 ) ;
			
		end
		
	end else if ( source_bpp[3:0] == BPP_2bit ) begin
		
		if ( source_target[2:0] == 0 ) begin           // place target color into the first 2 bits and retain the upper 14 bits.
	
			edited_word[15:14] = target_colour[1:0]          ;
			edited_word[13:0]  = source_word[13:0]           ;
			collision_rd_inc   = ( source_word[15:14] != 0 ) ;

		end else if ( source_target[2:0] == 1 ) begin  // place target color into the second 2 bits and retain the upper 12 bits and lower 2 bits.
	
			edited_word[15:14] = source_word[15:14]          ;
			edited_word[13:12] = target_colour[1:0]          ;
			edited_word[11:0]  = source_word[11:0]           ;
			collision_rd_inc   = ( source_word[13:12] != 0 ) ;
			
		end else if ( source_target[2:0] == 2 ) begin  // place target color into the third 2 bits and retain the upper 10 bits and lower 4 bits.
	
			edited_word[15:12] = source_word[15:12]          ;
			edited_word[11:10] = target_colour[1:0]          ;
			edited_word[9:0]   = source_word[9:0]            ;
			collision_rd_inc   = ( source_word[11:10] != 0 ) ;
			
		end else if ( source_target[2:0] == 3 ) begin  // place target color into the fourth 2 bits and retain the upper 8 bits and lower 6 bits.
	
			edited_word[15:10] = source_word[15:10]        ;
			edited_word[9:8]   = target_colour[1:0]        ;
			edited_word[7:0]   = source_word[7:0]          ;
			collision_rd_inc   = ( source_word[9:8] != 0 ) ;
			
		end else if ( source_target[2:0] == 4 ) begin  // place target color into the fifth 2 bits and retain the upper 6 bits and lower 8 bits.
			
			edited_word[15:8] = source_word[15:8]         ;
			edited_word[7:6]  = target_colour[1:0]        ;
			edited_word[5:0]  = source_word[5:0]          ;
			collision_rd_inc  = ( source_word[7:6] != 0 ) ;

		end else if ( source_target[2:0] == 5 ) begin  // place target color into the sixth 2 bits and retain the upper 4 bits and lower 10 bits.
	
			edited_word[15:6] = source_word[15:6]         ;
			edited_word[5:4]  = target_colour[1:0]        ;
			edited_word[3:0]  = source_word[3:0]          ;
			collision_rd_inc  = ( source_word[5:4] != 0 ) ;
			
		end else if ( source_target[2:0] == 6 ) begin  // place target color into the seventh 2 bits and retain the upper 2 bits and lower 12 bits.
	
			edited_word[15:4] = source_word[15:4]         ;
			edited_word[3:2]  = target_colour[1:0]        ;
			edited_word[1:0]  = source_word[1:0]          ;
			collision_rd_inc  = ( source_word[3:2] != 0 ) ;
			
		end else begin                                 // place target color into the last 2 bits and retain the lower 14 bits.
	
			edited_word[15:2] = source_word[15:2]         ;
			edited_word[1:0]  = target_colour[1:0]        ;
			collision_rd_inc  = ( source_word[1:0] != 0 ) ;
			
		end
		
	end else if ( source_bpp[3:0] == BPP_1bit ) begin
		
		edited_word[ ( ~source_target[3:0] ) ] = target_colour[0] ;
		collision_rd_inc = ( source_word[ ( ~source_target[3:0] ) ] != 0 ) ;
		
		if ( ~source_target[3:0] != 15 ) edited_word[ 15 : ( ~source_target[3:0] + 1 ) ] = source_word[ 15 : ( ~source_target[3:0] + 1 ) ] ;
		if ( ~source_target[3:0] != 0 )  edited_word[ ( ~source_target[3:0] - 1 ) : 0 ]  = source_word[ ( ~source_target[3:0] - 1 ) : 0 ]  ;

	end

end

endmodule
