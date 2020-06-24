// Music demo verilog file
// (c) fpga4fun.com 2003-2015

// Plays a little tune on a speaker
// Use a 25MHz clock if possible (other frequencies will 
// change the pitch/speed of the song)

module music(

	input clk,
	input enable,
	
	output reg speaker
	
);

	reg [30:0] tone;
	always @(posedge clk) tone <= tone+31'd1;

	wire [7:0] fullnote;
	music_ROM get_fullnote(.clk(clk), .address(tone[29:22]), .note(fullnote));

	wire [2:0] octave;
	wire [3:0] note;
	divide_by12 get_octave_and_note(.numerator(fullnote[5:0]), .quotient(octave), .remainder(note));

	reg [8:0] clkdivider;
	always @*
	case(note)
		 0: clkdivider = 9'd511*2;//A
		 1: clkdivider = 9'd482*2;// A#/Bb
		 2: clkdivider = 9'd455*2;//B
		 3: clkdivider = 9'd430*2;//C
		 4: clkdivider = 9'd405*2;// C#/Db
		 5: clkdivider = 9'd383*2;//D
		 6: clkdivider = 9'd361*2;// D#/Eb
		 7: clkdivider = 9'd341*2;//E
		 8: clkdivider = 9'd322*2;//F
		 9: clkdivider = 9'd303*2;// F#/Gb
		10: clkdivider = 9'd286*2;//G
		11: clkdivider = 9'd270*2;// G#/Ab
		default: clkdivider = 9'd0;
	endcase

	reg [8:0] counter_note;
	reg [7:0] counter_octave;
	always @(posedge clk) counter_note <= counter_note==0 ? clkdivider : counter_note-9'd1;
	always @(posedge clk) if(counter_note==0) counter_octave <= counter_octave==0 ? 8'd255 >> octave : counter_octave-8'd1;
	
	always @(posedge clk) begin

		if (enable)
			if(counter_note==0 && counter_octave==0 && fullnote!=0 && tone[21:18]!=0) speaker <= ~speaker;
		else
			speaker <= 1'b0;

	end
	
endmodule
