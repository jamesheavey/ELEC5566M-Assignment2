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
 
module HexTo7Seg ( 

	input			[3:0] hex, 
	output reg	[6:0] SevenSeg
	
);

always @(*) begin

	case(hex)
	
		4'h0: SevenSeg = ~7'b0000000;  // no need to represent 0
		
		4'h1: SevenSeg = ~7'b0000110; // 1
		4'h2: SevenSeg = ~7'b1011011; // 2
		4'h4: SevenSeg = ~7'b1001111; // 3
		4'h8: SevenSeg = ~7'b1100110; // 4
		
		4'h3: SevenSeg = ~7'b1111001; // E
		4'h5: SevenSeg = ~7'b1010000; // r
		4'h6: SevenSeg = ~7'b0111111; // O
		
		4'h7: SevenSeg = ~7'b0111110; // U
		4'h9: SevenSeg = ~7'b1010100; // n
		4'hA: SevenSeg = ~7'b0111000; // L
		4'hB: SevenSeg = ~7'b0111001; // C
		4'hC: SevenSeg = ~7'b1011110; // d
		
		4'hD: SevenSeg = ~7'b1101101; // S
		4'hE: SevenSeg = ~7'b1111000; // t
		
		default: SevenSeg = 7'b0000000;
		
	endcase
end

endmodule
