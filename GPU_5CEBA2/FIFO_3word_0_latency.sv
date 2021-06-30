// *****************************************************************
// *** FIFO_3word_0_latency.sv V3.1, July 11, 2020
// ***
// *** This 3 word + 1 reserve word Zero latency FIFO
// *** with look ahead data and status flags outputs was
// *** written by Brian Guralnick.
// ***
// *** See the included 'FIFO_0_latency.png' simulation for functionality.
// ***
// *** Using System Verilog code which only uses synchronous logic.
// *** Well commented for educational purposes.
// *****************************************************************

module FIFO_3word_0_latency (

input  logic clk,                 // CLK input
input  logic reset,               // reset FIFO

input  logic shift_in,            // load a word into the FIFO.
input  logic shift_out,           // shift data out of the FIFO.
input  logic [bits-1:0] data_in,  // data word input.

output logic fifo_not_empty,      // High when there is data available.
output logic fifo_full,           // High when the FIFO is 3 words full.
                                  // *** Note the FIFO has 1 extra word of free space after
                                  // *** the fifo_full flag goes high, so it's actually a 4 word FIFO.

output logic [bits-1:0] data_out  // FIFO data word output
);

//*************************************************************************************************************************************
parameter  int bits = 8 ;                // sets the width of the fifo
parameter  bit zero_latency = 1;         // When set to 1, if the FIFO is empty, the data_out and fifo_empty flag will
                                         // immediately reflect the state of the inputs data_in and shift_in, 0 clock cycle delay.
                                         // When set to 0, like a normal synchronous FIFO, It will take 1 clock cycle before the
                                         // fifo_empty flag goes high and the data_out will have a copy of the data_in after a 'shift_in'.

                                         // Enabling the overflow/underflow protection features may lower top FMAX.
parameter  bit overflow_protection  = 0; // Prevents internal write position and writing if the fifo is full past the 1 extra reserve word
parameter  bit underflow_protection = 0; // Prevents internal position position increment if the fifo is empty
parameter  bit size7_ena            = 0; // Set to 0 for 3 words, set to 1 for 7 words.

localparam int add_words            = size7_ena * 4;
//*************************************************************************************************************************************

logic  [bits-1:0]           fifo_data_reg[(3 + add_words):0] ; // FIFO memory
logic  [(1 + size7_ena):0]  fifo_wr_pos, fifo_rd_pos;          // read and write memory pointers
logic  [(2 + size7_ena):0]  fifo_words ;                       // The number of words in the FIFO
logic                       fifo_not_empty_r = 1'b0 ;          // The fifo is not empty register
logic                       fifo_full_r      = 1'b0 ;          // The fifo is the normal +3 word full register
logic                       fifo_full_exr    = 1'b0 ;          // The fifo is at the true +4 word full register

logic [(2 + size7_ena):0]   read_pointer ;                          // read data mux pointer
logic [bits-1:0]            fifo_data_mux[(7 + (add_words * 2)):0]; // the mux data inputs
logic                       shift_in_protect, shift_out_protect;


always_comb begin

for (int i=0               ; i<(4 + add_words)       ; i++) fifo_data_mux[i] = fifo_data_reg[i]; // mux selection from fifo register data.
for (int i=(4 + add_words) ; i<(8 + (add_words * 2)) ; i++) fifo_data_mux[i] = data_in ;         // mux selection from data input

read_pointer[(1 + size7_ena):0] =  fifo_rd_pos[(1 + size7_ena):0];                 // adress the 4 fifo words
read_pointer[(2 + size7_ena)]   =  !fifo_not_empty_r && zero_latency ;             // when high, address the data_in on the top 4 mux positions.
data_out                        =  fifo_data_mux[read_pointer];                    // mux select the data output.

fifo_not_empty                  =  fifo_not_empty_r || (zero_latency && shift_in); // While the FIFO is empty and zero_latency = 1, directly wire
                                                                                   // 'fifo_not_empty' output to the 'shift_in' input.  Otherwise,
                                                                                   // only set high once there is data in the FIFO.

fifo_full                       =  fifo_full_r && !(shift_out && zero_latency) ;   // Goes high when the FIFO has 3 words in storage and shift_out
                                                                                   // isn't currently being requested while in zero_latency mode.

shift_in_protect  =  shift_in  && ( !(fifo_full_exr && !(shift_out && zero_latency)) || !overflow_protection  ); // Do not allow a shift_in if the FIFO is full past the fourth reserve word
shift_out_protect =  shift_out && (   fifo_not_empty                                 || !underflow_protection ); // Do not allow a shift_out if the FIFO is empty

end // always_comb

always_ff @(posedge clk) begin

if (reset) begin

for (int i=0 ; i<(4 + add_words) ; i++) fifo_data_reg[i] <= 0 ;  // clear the FIFO's memory contents

    fifo_rd_pos      <= 0;  // reset the FIFO memory counter
    fifo_wr_pos      <= 0;  // reset the FIFO memory counter
    fifo_words       <= 0;  // The fifo's number of stored words

    fifo_not_empty_r <= 0 ; // The fifo is not empty register
    fifo_full_r      <= 0 ; // The fifo is the normal +3 word full register
    fifo_full_exr    <= 0 ; // The fifo is at the true +4 word full register

	end else begin

                if (  shift_in_protect && !shift_out_protect ) begin
                                                                                                  fifo_words       <= fifo_words + 1'b1; // increment the fifo's number of stored words
                                                                /*if (fifo_words==0)*/            fifo_not_empty_r <= 1;
                                                                 if (fifo_words==(2 + add_words)) fifo_full_r      <= 1;
                                                                 if (fifo_words==(3 + add_words)) fifo_full_exr    <= 1;
       end else if ( !shift_in_protect &&  shift_out_protect ) begin
                                                                                                  fifo_words       <= fifo_words - 1'b1; // decrement the fifo's number of stored words
                                                                 if (fifo_words==1)               fifo_not_empty_r <= 0;
                                                                 if (fifo_words==(3 + add_words)) fifo_full_r      <= 0;
                                                                 if (fifo_words==(4 + add_words)) fifo_full_exr    <= 0;
       end

                 if ( shift_in_protect  ) begin
                      fifo_wr_pos                                   <= fifo_wr_pos + 1'b1 ;
                      fifo_data_reg[fifo_wr_pos[(1 + size7_ena):0]] <= data_in ;
                      end
                 if ( shift_out_protect ) begin
                      fifo_rd_pos                                   <= fifo_rd_pos + 1'b1 ;
                      end
       
   end // !reset

end // always_ff
endmodule
