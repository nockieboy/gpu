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
    output logic next_cmd,              // output to fifo_shift_out
    output logic draw_busy,             // fifo_full output
    
    // data_mux_geo outputs
    output logic rd_req_a,              // output to geo_rd_req_a on data_mux_geo
    output logic rd_req_b,              // output to geo_rd_req_b on data_mux_geo
    output logic wr_ena,                // output to geo_wr_ena on data_mux_geo
    output logic [19:0] ram_addr,       // output to address_geo on data_mux_geo
    output logic [15:0] ram_wr_data,    // output to data_in_geo on data_mux_geo
    
    // collision saturation counter outputs
    output logic [7:0] collision_rd,    // output to 1st read port on Z80_bridge_v2
    output logic [7:0] collision_wr     // output to 2nd read port on Z80_bridge_v2

);

localparam CMD_IN_NOP           = 0;
localparam CMD_IN_PXWRI         = 1;
localparam CMD_IN_PXWRI_M       = 2;
localparam CMD_IN_PXPASTE       = 3;
localparam CMD_IN_PXPASTE_M     = 4;
localparam CMD_IN_PXCOPY        = 6;
localparam CMD_IN_SETARGB       = 7;
localparam CMD_IN_RST_PXWRI_M   = 10;
localparam CMD_IN_RST_PXPASTE_M = 11;

parameter bit ZERO_LATENCY         = 1; // When set to 1 this will make the read&write commands immediate instead of a clock cycle later
parameter bit overflow_protection  = 1; // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
parameter bit underflow_protection = 1; // Prevents internal position position increment if the fifo is empty

FIFO_3word_0_latency input_cmd_fifo_1 (  // Zero Latency Command buffer
    .clk             ( clk ),                 // CLK input
    .reset           ( reset ),               // Reset FIFO

    .shift_in        ( cmd_rdy ),             // Load data into the FIFO
    .shift_out       ( exec_cmd ),            // Shift data out of the FIFO
    .data_in         ( cmd_in[39:0] ),        // Data input from PAGET

    .fifo_not_empty  ( pixel_cmd_rdy ),       // High when there is data available for the pixel writer
    .fifo_full       ( draw_busy ),           // High when the FIFO is full - used to tell GEOFF and PAGET to halt until there is room in the FIFO again
    .data_out        ( pixel_cmd_data[39:0] ) // FIFO data output to pixel writer
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
logic rd_wait_a      ;  // HIGH whilst waiting for a_channel RD op to complete
logic rd_wait_b      ;  // HIGH whilst waiting for b_channel RD op to complete

always_comb begin

    // break the pixel_cmd_data down into clear sub-components:
    pixel_cmd[3:0] = pixel_cmd_data[39:36] ;  // command code
    colour[7:0]    = pixel_cmd_data[35:28] ;  // colour data
    bpp[3:0]       = pixel_cmd_data[27:24] ;  // bits per pixel (width)
    target[3:0]    = pixel_cmd_data[23:20] ;  // target bit (sub-word)
    ram_addr[19:0] = pixel_cmd_data[19:0]  ;  // address of 16-bit word in RAM
    
    // logic
    exec_cmd       = ( ( !(rd_wait_a && !rd_data_rdy_a) && !(rd_wait_b && !rd_data_rdy_b) ) && pixel_cmd_rdy ) ;
    rd_addr_valid  = ( ram_addr == rd_cache_addr ) ;
    wr_addr_valid  = ( ram_addr == wr_cache_addr ) ;
    
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
        rd_req_a                <= 1'b0  ;
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
						rd_req_a       <= 1'b1     ; // send 'rd_req_a' pulse
						rd_cache_valid <= 1'b0     ; // clear cache valid flag in case it wasn't already cleared
					
					end else begin
					
						// data has been read - do something with it?
					
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
				rd_cache_addr  <= ram_addr   ; // cache new address
				
			end
		
		end
            
    end // else reset

end

endmodule
