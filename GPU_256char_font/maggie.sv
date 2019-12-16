// **************************************************************
// *                                                            *
// *  Multiple Address Generator & Graphics Instruction Engine  *
// *                                                            *
// **************************************************************

module maggie (

	//inputs
	input wire clk,
	input wire [3:0]  pc_ena_in,
	input wire [7:0]  hw_regs[0:(2**HW_REGS-1)],
	input wire [47:0] HV_trig,
	input wire [31:0] cmd_in,
	input wire [15:0] ram_din,

	//outputs (all wires as we will embed the connected registers inside the module)
	output wire [19:0] read_addr,
	output wire [31:0] cmd_out,
	output wire [23:0] bp_2_rast_cmd

);

// parameters
parameter HW_REGS			= 8;
parameter HW_REG_BASE		= 96;
parameter H_RESET_TRIG		= 8;
parameter H_POS_TRIG		= 10;
parameter RAM_READ_CYCLES	= 3;

// local parameters
localparam V_RESET_TRIG	= H_RESET_TRIG	+  1;
localparam V_POS_TRIG	= H_POS_TRIG	+  1;
localparam BP2RAST_cmd	= HW_REG_BASE	+  0;	// Transfers the video mode setting to the new bitplane_2_raster module
localparam BP2RAST_bgc	= HW_REG_BASE	+  1;	// Transfers the bg_colour setting to the new bitplane_2_raster module
localparam BP2RAST_fgc	= HW_REG_BASE	+  2;	// Transfers the fg_colour setting to the new bitplane_2_raster module
localparam RST_ADDR_H	= HW_REG_BASE	+  3;	// MSB bits of 24 bit base read address
localparam RST_ADDR_M	= HW_REG_BASE	+  4;	// MID bits of 24 bit base read address
localparam RST_ADDR_L	= HW_REG_BASE	+  5;	// LSB bits of 24 bit base read address
localparam YINC_ADDR_H	= HW_REG_BASE	+  6;	// MSB bits of 16 bit Y-Line increment for read address
localparam YINC_ADDR_L	= HW_REG_BASE	+  7;	// LSB bits of 16 bit Y-Line increment for read address
localparam X_SIZE_H		= HW_REG_BASE	+  8;	// MSB bits of 16 bit display width screen pixels
localparam X_SIZE_L		= HW_REG_BASE	+  9;	// LSB bits of 16 bit display width screen pixels
localparam Y_SIZE_H		= HW_REG_BASE	+ 10;	// MSB bits of 16 bit display height screen y lines
localparam Y_SIZE_L		= HW_REG_BASE	+ 11;	// LSB bits of 16 bit display height screen y lines
localparam X_SCALE		= HW_REG_BASE	+ 12;	// Compound of two 4 bit words. Upper 4 bits controls the X increment every period, lower 4 bits is a pixel period counter to define the number of pixels until the upper 4 bits are added to the address-pointer.
localparam Y_SCALE		= HW_REG_BASE	+ 13;	// Compound of two 4 bit words. Upper 4 bits reserved for text tile mode Y size while the lower lower 4 bits is a line period counter to define the number of lines until YINC_ADDR is added to the address-pointer
localparam X_START_SUB	= HW_REG_BASE	+ 14;	// An 8 bit word which defines an odd pixel start position within the period counter and X position within a bitplane's X coordinate position
localparam Y_START_SUB	= HW_REG_BASE	+ 15;	// An 8 bit word which defines an odd line start within within the period counter and Y coordinates inside a font.

// registers
reg [19:0] ram_read_pointer_y;
reg [23:0] ram_read_pointer_x;
reg [4:0] period_x;
reg [4:0] period_y;
reg [7:0] h_trig_delay;
reg [11:0] width;
reg [11:0] height;
wire run_x;
wire run_y;
assign run_x = width[11];
assign run_y = height[11];

// wires
wire h_rst, x_rst, xy_rst;
wire h_trig, v_trig;
wire window_enable;
wire [23:0] reset_addr;
wire [15:0] inc_addr_x;
wire [15:0] inc_addr_y;
wire [3:0]  period_x_rst;
wire [3:0]  period_y_rst;
wire [11:0] x_size;
wire [11:0] y_size;
wire [1:0]  pixel_per_byte;
wire [7:0]  width_count;
wire [7:0]  height_count;

// assignments
assign bp_2_rast_cmd[23:0]	= { hw_regs[BP2RAST_fgc] , hw_regs[BP2RAST_bgc] , hw_regs[BP2RAST_cmd] };
assign text_mode_master		= hw_regs[BP2RAST_cmd][7];

assign x_rst					= HV_trig[H_RESET_TRIG];
assign xy_rst					= HV_trig[V_RESET_TRIG] && x_rst;

assign v_trig					= HV_trig[V_POS_TRIG];
assign h_trig					= HV_trig[H_POS_TRIG];
assign h_rst					= text_mode_master ? h_trig_delay[0] : h_trig_delay[RAM_READ_CYCLES-1];  // When in text mode, push the window left by 'RAM_READ_CYCLES' as it takes a second memory read to get the font image

assign window_enable			= run_x && run_y;
assign cmd_out[7]				= window_enable;	// commands the pixel/by/pixel window enable for the bitplane_2_raster module
assign cmd_out[6]				= 1'b0;				// for now, disables the 2 byte colour mode

assign reset_addr[23:0]		= { hw_regs[RST_ADDR_H] , hw_regs[RST_ADDR_M] , hw_regs[RST_ADDR_L]  };
assign inc_addr_y[15:0]		= { hw_regs[YINC_ADDR_H] , hw_regs[YINC_ADDR_L] };
assign inc_addr_x[3:0]		= hw_regs[X_SCALE][7:4];

assign read_addr[19:0]		= ram_read_pointer_x[22:3];
assign cmd_out[2:0]			= ram_read_pointer_x[2:0];	// commands the sub pixel X position for the bitplane_2_raster module

assign period_x[3:0]			= hw_regs[X_SCALE][3:0];
assign period_y[3:0]			= hw_regs[Y_SCALE][3:0];

assign period_x_rst[3:0]	= hw_regs[X_START_SUB][3:0];
assign period_y_rst[3:0]	= hw_regs[Y_START_SUB][3:0];

assign x_size[11:0]			= { hw_regs[X_SIZE_H][3:0], hw_regs[X_SIZE_L][7:0] };
assign y_size[11:0]			= { hw_regs[Y_SIZE_H][3:0], hw_regs[Y_SIZE_L][7:0] };

assign pixel_per_byte		= bp_2_rast_cmd[1:0]; // bitplane setting equates to pixels per byte (0 = 1, 1 = 2, 2 = 4, or 3 = 8)

always @(posedge clk) begin

   if (pc_ena_in[3:0] == 0) begin
		
      h_trig_delay[7:1] <= h_trig_delay[6:0];
		h_trig_delay[0]	<= h_trig;
		
      if (xy_rst) begin			// equivalent to a vertical sync/reset
			
			height             <= 0;
			width_count			 <= 0;
			height_count		 <= 0;
			
		end
		else if (x_rst) begin	// equivalent to a horizontal sync/increment
			
			width			<= 0;
			width_count	<= 0;
			
			if (v_trig) begin		// V_TRIG is high for the entire first line of video to be displayed.  This is the point in place and time
										// where the read address must be equal to the setting in the reset_addr.
				height[11]   <= 1;// set run_y bit active
				height[10:0] <= y_size[10:0];
				height_count <= 0;// * must reset as well.
				
				ram_read_pointer_y <= reset_addr << 3;			// V_TRIG is high during the first active line of video, set the read pointer, both
				ram_read_pointer_x <= reset_addr << 3;			// the backup and currrent display address to the exact reset base address during this line.
				
			end // V_TRIG
			else begin  // ~V_TRIG
				
				if (run_y) begin										// after the first line, do these functions.
					
					if (period_y[3:0] == height_count) begin	// If the vertical scale period count has reached it's end
						
						height <= height - 1;						// count down the visible window size
						height_count <= 0;							// reset the vertical period
						ram_read_pointer_y <= ram_read_pointer_y + (inc_addr_y[15:0] << 3);  // vertical increment display position in backup buffer
						ram_read_pointer_x <= ram_read_pointer_y + (inc_addr_y[15:0] << 3);  // vertical increment display position in current display address
						
					end // (period_y[3:0] == height_count
					else begin											// if the period count hasn't reached it's end,
						
						height_count	<= height_count + 1;		// increment the period count
						ram_read_pointer_x <= ram_read_pointer_y; // restore the memory read address to the previous backup buffer address
						
					end
					
				end
				
			end // ~V_TRIG
			
      end
		else begin
			
			if (h_rst) begin
				
				width[11]   <= 1;       // set run_x bit active
				width[10:0] <= x_size[10:0];
				width_count	<= 0;
				
			end
			
			if (run_x) begin
				
				if (width_count == period_x[3:0]) begin
					width <= width - 1;
					width_count <= 0;
					ram_read_pointer_x <= ram_read_pointer_x + 2**pixel_per_byte;
				end
				else begin
					width_count	<= width_count + 1;
				end
				
			end
			
         //-------------------------------
         //snap to it....
         //-------------------------------
			
      end // ~x_rst
		
   end // if (pc_ena_in[3:0] == 0)
	
end //@(posedge clk)

endmodule
