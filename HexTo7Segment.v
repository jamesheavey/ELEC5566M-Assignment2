/*
 * Hex to 7-Seg
 * ----------------
 * By: James Heavey
 * For: University of Leeds
 * Date: 2/12/2021
 *
 * Description
 * -----------
 * The module takes a 4 bit hex value and
 * outputs 7 bit binary
 *
 */
 
module HexTo7Segment ( 

	input			[3:0] hex, 
	output reg	[6:0] SevenSeg
	
);

always @(*) begin

	case(hex)
	
		4'h0: SevenSeg = ~7'b0000000;  // no need to represent 0
		4'h1: SevenSeg = ~7'b0000110;
		4'h2: SevenSeg = ~7'b1011011;
		4'h3: SevenSeg = ~7'b1001111;
		4'h4: SevenSeg = ~7'b1100110;
		4'h5: SevenSeg = ~7'b1101101;
		4'h6: SevenSeg = ~7'b1111101;
		4'h7: SevenSeg = ~7'b0000111;
		4'h8: SevenSeg = ~7'b1111111;
		4'h9: SevenSeg = ~7'b1100111;
		4'hA: SevenSeg = ~7'b1110111;
		4'hB: SevenSeg = ~7'b1111100;
		4'hC: SevenSeg = ~7'b0111001;
		4'hD: SevenSeg = ~7'b1011110;
		4'hE: SevenSeg = ~7'b1111001;
		4'hF: SevenSeg = ~7'b1110001;
		
		default: SevenSeg = 7'b0000000;
		
	endcase
end

endmodule
