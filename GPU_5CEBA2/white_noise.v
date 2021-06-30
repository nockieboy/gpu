module white_noise ( clk, rst, ena, out, out2, out3,  out4, out5, out6 );


input           clk, rst, ena;

output	[7:0] out,out2,out3,  out4, out5, out6 ;

wire    [7:0] out = number_o[31:24] ;
wire    [7:0] out2 = number_o[31-1:24-1] ;
wire    [7:0] out3 = number_o[31-2:24-2] ;

wire    [7:0] out4 = number_o[21:14] ;
wire    [7:0] out5 = number_o[21-1:14-1] ;
wire    [7:0] out6 = number_o[21-2:14-2] ;


reg [31:0] number_o;
reg [42:0] LFSR_reg;
reg [36:0] CASR_reg;


//CASR:
reg[36:0] CASR_varCASR,CASR_outCASR;
always @(posedge clk )

   begin

   if ( rst )

      begin

      CASR_reg  = (1);

      end

   else 

      begin

      //if (loadseed_i )

        // begin

         //CASR_varCASR [36:32]=0;
         //CASR_varCASR [31:0]=seed_i ;
         //CASR_reg  = (CASR_varCASR );


         //end

      //else 

         if (ena) begin

         CASR_varCASR =CASR_reg ;

         CASR_outCASR [36]=CASR_varCASR [35]^CASR_varCASR [0];
         CASR_outCASR [35]=CASR_varCASR [34]^CASR_varCASR [36];
         CASR_outCASR [34]=CASR_varCASR [33]^CASR_varCASR [35];
         CASR_outCASR [33]=CASR_varCASR [32]^CASR_varCASR [34];
         CASR_outCASR [32]=CASR_varCASR [31]^CASR_varCASR [33];
         CASR_outCASR [31]=CASR_varCASR [30]^CASR_varCASR [32];
         CASR_outCASR [30]=CASR_varCASR [29]^CASR_varCASR [31];
         CASR_outCASR [29]=CASR_varCASR [28]^CASR_varCASR [30];
         CASR_outCASR [28]=CASR_varCASR [27]^CASR_varCASR [29];
         CASR_outCASR [27]=CASR_varCASR [26]^CASR_varCASR [27]^CASR_varCASR [28];
         CASR_outCASR [26]=CASR_varCASR [25]^CASR_varCASR [27];
         CASR_outCASR [25]=CASR_varCASR [24]^CASR_varCASR [26];
         CASR_outCASR [24]=CASR_varCASR [23]^CASR_varCASR [25];
         CASR_outCASR [23]=CASR_varCASR [22]^CASR_varCASR [24];
         CASR_outCASR [22]=CASR_varCASR [21]^CASR_varCASR [23];
         CASR_outCASR [21]=CASR_varCASR [20]^CASR_varCASR [22];
         CASR_outCASR [20]=CASR_varCASR [19]^CASR_varCASR [21];
         CASR_outCASR [19]=CASR_varCASR [18]^CASR_varCASR [20];
         CASR_outCASR [18]=CASR_varCASR [17]^CASR_varCASR [19];
         CASR_outCASR [17]=CASR_varCASR [16]^CASR_varCASR [18];
         CASR_outCASR [16]=CASR_varCASR [15]^CASR_varCASR [17];
         CASR_outCASR [15]=CASR_varCASR [14]^CASR_varCASR [16];
         CASR_outCASR [14]=CASR_varCASR [13]^CASR_varCASR [15];
         CASR_outCASR [13]=CASR_varCASR [12]^CASR_varCASR [14];
         CASR_outCASR [12]=CASR_varCASR [11]^CASR_varCASR [13];
         CASR_outCASR [11]=CASR_varCASR [10]^CASR_varCASR [12];
         CASR_outCASR [10]=CASR_varCASR [9]^CASR_varCASR [11];
         CASR_outCASR [9]=CASR_varCASR [8]^CASR_varCASR [10];
         CASR_outCASR [8]=CASR_varCASR [7]^CASR_varCASR [9];
         CASR_outCASR [7]=CASR_varCASR [6]^CASR_varCASR [8];
         CASR_outCASR [6]=CASR_varCASR [5]^CASR_varCASR [7];
         CASR_outCASR [5]=CASR_varCASR [4]^CASR_varCASR [6];
         CASR_outCASR [4]=CASR_varCASR [3]^CASR_varCASR [5];
         CASR_outCASR [3]=CASR_varCASR [2]^CASR_varCASR [4];
         CASR_outCASR [2]=CASR_varCASR [1]^CASR_varCASR [3];
         CASR_outCASR [1]=CASR_varCASR [0]^CASR_varCASR [2];
         CASR_outCASR [0]=CASR_varCASR [36]^CASR_varCASR [1];

         CASR_reg  = (CASR_outCASR );

         end


      end


   end
//LFSR:
reg[42:0] LFSR_varLFSR;
reg outbitLFSR;
always @(posedge clk)

   begin

   if ( rst )

      begin

      LFSR_reg  = (1);

      end

   else 

      begin

      //if (loadseed_i )

         //begin

         //LFSR_varLFSR [42:32]=0;
         //LFSR_varLFSR [31:0]=seed_i ;
         //LFSR_reg  = (LFSR_varLFSR );


         //end

      //else 

         if (ena) begin

         LFSR_varLFSR =LFSR_reg ;

         outbitLFSR =LFSR_varLFSR [42];
         LFSR_varLFSR [42]=LFSR_varLFSR [41];
         LFSR_varLFSR [41]=LFSR_varLFSR [40]^outbitLFSR ;
         LFSR_varLFSR [40]=LFSR_varLFSR [39];
         LFSR_varLFSR [39]=LFSR_varLFSR [38];
         LFSR_varLFSR [38]=LFSR_varLFSR [37];
         LFSR_varLFSR [37]=LFSR_varLFSR [36];
         LFSR_varLFSR [36]=LFSR_varLFSR [35];
         LFSR_varLFSR [35]=LFSR_varLFSR [34];
         LFSR_varLFSR [34]=LFSR_varLFSR [33];
         LFSR_varLFSR [33]=LFSR_varLFSR [32];
         LFSR_varLFSR [32]=LFSR_varLFSR [31];
         LFSR_varLFSR [31]=LFSR_varLFSR [30];
         LFSR_varLFSR [30]=LFSR_varLFSR [29];
         LFSR_varLFSR [29]=LFSR_varLFSR [28];
         LFSR_varLFSR [28]=LFSR_varLFSR [27];
         LFSR_varLFSR [27]=LFSR_varLFSR [26];
         LFSR_varLFSR [26]=LFSR_varLFSR [25];
         LFSR_varLFSR [25]=LFSR_varLFSR [24];
         LFSR_varLFSR [24]=LFSR_varLFSR [23];
         LFSR_varLFSR [23]=LFSR_varLFSR [22];
         LFSR_varLFSR [22]=LFSR_varLFSR [21];
         LFSR_varLFSR [21]=LFSR_varLFSR [20];
         LFSR_varLFSR [20]=LFSR_varLFSR [19]^outbitLFSR ;
         LFSR_varLFSR [19]=LFSR_varLFSR [18];
         LFSR_varLFSR [18]=LFSR_varLFSR [17];
         LFSR_varLFSR [17]=LFSR_varLFSR [16];
         LFSR_varLFSR [16]=LFSR_varLFSR [15];
         LFSR_varLFSR [15]=LFSR_varLFSR [14];
         LFSR_varLFSR [14]=LFSR_varLFSR [13];
         LFSR_varLFSR [13]=LFSR_varLFSR [12];
         LFSR_varLFSR [12]=LFSR_varLFSR [11];
         LFSR_varLFSR [11]=LFSR_varLFSR [10];
         LFSR_varLFSR [10]=LFSR_varLFSR [9];
         LFSR_varLFSR [9]=LFSR_varLFSR [8];
         LFSR_varLFSR [8]=LFSR_varLFSR [7];
         LFSR_varLFSR [7]=LFSR_varLFSR [6];
         LFSR_varLFSR [6]=LFSR_varLFSR [5];
         LFSR_varLFSR [5]=LFSR_varLFSR [4];
         LFSR_varLFSR [4]=LFSR_varLFSR [3];
         LFSR_varLFSR [3]=LFSR_varLFSR [2];
         LFSR_varLFSR [2]=LFSR_varLFSR [1];
         LFSR_varLFSR [1]=LFSR_varLFSR [0]^outbitLFSR ;
         LFSR_varLFSR [0]=LFSR_varLFSR [42];

         LFSR_reg  = (LFSR_varLFSR );

         end


      end


   end
//combinate:
always @(posedge clk)

   begin

   if ( rst )

      begin

      number_o  = (0);

      end

   else 

      if (ena) begin

      number_o  = (LFSR_reg [31:0]^CASR_reg[31:0]);

      end


   end

endmodule
