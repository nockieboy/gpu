// Music demo verilog file
// (c) fpga4fun.com 2003-2015

// Plays a little tune on a speaker
// Use a 25MHz clock if possible (other frequencies will 
// change the pitch/speed of the song)

module music(
	input wire clk,
	input wire mode,
	output reg speaker,
	output wire led
);

	reg [30:0] tone;
	always @(posedge clk) tone <= tone+31'd1;

	wire [7:0] fullnote;
	music_ROM get_fullnote(.clk(clk), .address(tone[29:22]), .note(fullnote));

	wire [2:0] octave;
	wire [3:0] note;
	divide_by12 get_octave_and_note(.numerator(fullnote[5:0]), .quotient(octave), .remainder(note));
	
	assign led = mode ? 1'b0 : 1'bz;

	reg [11:0] clkdivider;
	
	always @* begin
		
		case(note)
			 0: clkdivider = 12'd511 * (2 + mode); //A - 440Hz
			 1: clkdivider = 12'd482 * (2 + mode); //A#/Bb
			 2: clkdivider = 12'd455 * (2 + mode); //B
			 3: clkdivider = 12'd430 * (2 + mode); //C
			 4: clkdivider = 12'd405 * (2 + mode); //C#/Db
			 5: clkdivider = 12'd383 * (2 + mode); //D
			 6: clkdivider = 12'd361 * (2 + mode); //D#/Eb
			 7: clkdivider = 12'd341 * (2 + mode); //E
			 8: clkdivider = 12'd322 * (2 + mode); //F
			 9: clkdivider = 12'd303 * (2 + mode); //F#/Gb
			10: clkdivider = 12'd286 * (2 + mode); //G
			11: clkdivider = 12'd270 * (2 + mode); //G#/Ab
			default: clkdivider = 12'd0;
		endcase
		
	end

	reg [11:0] counter_note;
	reg [7:0] counter_octave;
	
	always @(posedge clk) begin

		counter_note <= counter_note==0 ? clkdivider : counter_note-12'd1;
		
		if (counter_note==0) counter_octave <= counter_octave==0 ? 8'd255 >> octave : counter_octave-8'd1;
		
		if (counter_note==0 && counter_octave==0 && fullnote!=0 && tone[21:18]!=0) speaker <= ~speaker;
		
	end

endmodule
