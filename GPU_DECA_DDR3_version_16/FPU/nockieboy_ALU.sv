/* ***********************************************************************************************************************************************************

nockieboy_ALU.sv

My First ALU, complete with crayon marks, excess glue and fingerprints.

Version 0.3, 20th October   2022  - FP divider & add/subber added
Version 0.2, 13th October   2022  - handles two FP number formats with additional IO switch
Version 0.1, 8th  September 2022  - basic 32-bit FP multiplier implementation

Written by Jonathan Nock.

Leave questions related to the project in https://www.eevblog.com/forum/fpga/fpga-vga-controller-for-8-bit-computer/

FORMAT byte consists of the following flags:

   7 6 5 4 3 2    1       0
  +-+-+-+-+-+-+--------+------+
  | | | | | | |FUNCTION|FORMAT|
  +-+-+-+-+-+-+--------+------+

  FORMAT      0 = 40-bit BBCBASIC float format
              1 = IEEE-754 32-bit format

  FUNCTION    0 = MULTIPLY
              1 = DIVIDE

***********************************************************************************************************************************************************/

module nockieboy_ALU #(

  parameter int SIZE = 32         // bit width of FPU

)(

  input  logic            clk,    // clk
  input  logic            areset, // reset
  input  logic            en,     // enable strobe
  input  logic [7:0]      format, // FP number format
  input  logic [SIZE-1:0] a,      // input  a
  input  logic [SIZE-1:0] b,      // input  b
  output logic [SIZE-1:0] q       // output q

);

  logic [SIZE-1:0] factor_A ;
  logic [SIZE-1:0] factor_B ;
  logic [SIZE-1:0] output_Q ;
  // outputs from the math modules
  logic [SIZE-1:0] MUL_Q ;
  logic [SIZE-1:0] DIV_Q ;
  logic [SIZE-1:0] ADD_Q ;
  logic [SIZE-1:0] SUB_Q ;

  always_ff @( posedge clk ) begin

    if ( format[0] == 1'b0 ) begin
      // Format is 0, default to converting from/to Z80 BBCBASIC 40-bit format:
      /*
       7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
      +---------------+-+-------------------------------------------------------------+
      |exp. with bias |S|       positive mantissa, MSB = 2^-1                         |
      +---------------+-+-------------------------------------------------------------+
      */
      factor_A <= { a[SIZE-9], a[SIZE-1:SIZE-8], a[SIZE-10:0] }                            ;
      factor_B <= { b[SIZE-9], b[SIZE-1:SIZE-8], b[SIZE-10:0] }                            ;

      case (format[2:1])

        2'b00   : q <= { (output_Q[SIZE-2:SIZE-9] - 1), output_Q[SIZE-1], output_Q[SIZE-10:0] } ;
        2'b01   : q <= { (output_Q[SIZE-2:SIZE-9] + 1), output_Q[SIZE-1], output_Q[SIZE-10:0] } ;
        2'b10   : q <= { (output_Q[SIZE-2:SIZE-9]    ), output_Q[SIZE-1], output_Q[SIZE-10:0] } ;
        2'b11   : q <= { (output_Q[SIZE-2:SIZE-9]    ), output_Q[SIZE-1], output_Q[SIZE-10:0] } ;

      endcase

    end else begin // Format[0] is 1, no conversion is done

      factor_A <= a        ;
      factor_B <= b        ;
      q        <= output_Q ;

    end

  end

  always_comb begin

    case (format[2:1])

      2'b00   : output_Q = MUL_Q ;
      2'b01   : output_Q = DIV_Q ;
      2'b10   : output_Q = ADD_Q ;
      2'b11   : output_Q = SUB_Q ;
      default : output_Q = MUL_Q ;

    endcase

  end

  ADD40 addsubber (

    .clk    ( clk      ), // clk
    .areset ( areset   ), // reset
    .a      ( factor_A ), // a
    .b      ( factor_B ), // b
    .q      ( ADD_Q    ), // output
    .s      ( SUB_Q    )  // output

  );

  DIV40 divider (

    .clk    ( clk      ), // clk
    .areset ( areset   ), // reset
    .a      ( factor_A ), // a
    .b      ( factor_B ), // b
    .q      ( DIV_Q    )  // output

  );

  MULT40 multiplier (

    .clk    ( clk      ), // clk
    .areset ( areset   ), // reset
    .a      ( factor_A ), // a
    .b      ( factor_B ), // b
    .q      ( MUL_Q    )  // output

  );

endmodule
