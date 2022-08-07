module Sine_1KHz_16b_48ksps (

	input  logic               clk,
    input  logic               clk_ena,
	output logic signed [15:0] audio
    
);

    logic [5:0] sam_pos;

    always_ff @(posedge clk) begin

        if (clk_ena) begin

            if   (sam_pos==6'd47) sam_pos <= 6'd0 ;
            else                  sam_pos <= sam_pos + 1'b1 ;

            // 48 word sine table.
            if (sam_pos==6'd0)  audio <= 16'(0)     ;
            if (sam_pos==6'd1)  audio <= 16'(4276)  ;
            if (sam_pos==6'd2)  audio <= 16'(8480)  ;
            if (sam_pos==6'd3)  audio <= 16'(12539) ;
            if (sam_pos==6'd4)  audio <= 16'(16383) ;
            if (sam_pos==6'd5)  audio <= 16'(19947) ;
            if (sam_pos==6'd6)  audio <= 16'(23169) ;
            if (sam_pos==6'd7)  audio <= 16'(25995) ;
            if (sam_pos==6'd8)  audio <= 16'(28377) ;
            if (sam_pos==6'd9)  audio <= 16'(30272) ;
            if (sam_pos==6'd10) audio <= 16'(31650) ;
            if (sam_pos==6'd11) audio <= 16'(32486) ;
            if (sam_pos==6'd12) audio <= 16'(32767) ;
            if (sam_pos==6'd13) audio <= 16'(32486) ;
            if (sam_pos==6'd14) audio <= 16'(31650) ;
            if (sam_pos==6'd15) audio <= 16'(30272) ;
            if (sam_pos==6'd16) audio <= 16'(28377) ;
            if (sam_pos==6'd17) audio <= 16'(25995) ;
            if (sam_pos==6'd18) audio <= 16'(23169) ;
            if (sam_pos==6'd19) audio <= 16'(19947) ;
            if (sam_pos==6'd20) audio <= 16'(16383) ;
            if (sam_pos==6'd21) audio <= 16'(12539) ;
            if (sam_pos==6'd22) audio <= 16'(8480)  ;
            if (sam_pos==6'd23) audio <= 16'(4276)  ;
            if (sam_pos==6'd24) audio <= 16'(-1)    ;
            if (sam_pos==6'd25) audio <= 16'(-4277) ;
            if (sam_pos==6'd26) audio <= 16'(-8481) ;
            if (sam_pos==6'd27) audio <= 16'(-12540);
            if (sam_pos==6'd28) audio <= 16'(-16384);
            if (sam_pos==6'd29) audio <= 16'(-19948);
            if (sam_pos==6'd30) audio <= 16'(-23170);
            if (sam_pos==6'd31) audio <= 16'(-25996);
            if (sam_pos==6'd32) audio <= 16'(-28378);
            if (sam_pos==6'd33) audio <= 16'(-30273);
            if (sam_pos==6'd34) audio <= 16'(-31651);
            if (sam_pos==6'd35) audio <= 16'(-32487);
            if (sam_pos==6'd36) audio <= 16'(-32767);
            if (sam_pos==6'd37) audio <= 16'(-32487);
            if (sam_pos==6'd38) audio <= 16'(-31651);
            if (sam_pos==6'd39) audio <= 16'(-30273);
            if (sam_pos==6'd40) audio <= 16'(-28378);
            if (sam_pos==6'd41) audio <= 16'(-25996);
            if (sam_pos==6'd42) audio <= 16'(-23170);
            if (sam_pos==6'd43) audio <= 16'(-19948);
            if (sam_pos==6'd44) audio <= 16'(-16384);
            if (sam_pos==6'd45) audio <= 16'(-12540);
            if (sam_pos==6'd46) audio <= 16'(-8481) ;
            if (sam_pos==6'd47) audio <= 16'(-4277) ;

        end

    end

endmodule
