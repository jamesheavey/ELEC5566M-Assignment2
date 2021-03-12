/*
 * ELEC5566 Assignment 2:
 * Password to 7 Segment Conversion Submodule
 * ---------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ---------------------------------
 * Module to convert key press outputs 
 * from FSM to seven segment displays
 *
 */

module PasswordTo7Seg #(

	parameter NUM_DISPLAYS = 6

)(

	input [(4*NUM_DISPLAYS)-1:0] password,
	
	output [(7*NUM_DISPLAYS)-1:0] SevenSeg
	
);

genvar i;

generate 

	for (i = 0; i < NUM_DISPLAYS; i = i + 1) begin : SevenSeg_loop

		HexTo7Segment display (
			.hex			( password[(i*4)+:4] ),
			.SevenSeg	( SevenSeg[(i*7)+:7] )
		);
		
	end 

endgenerate

endmodule
	