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
	// Parameter
	parameter NUM_DISPLAYS = 6

)(
	// Input
	input [(4*NUM_DISPLAYS)-1:0] password,
	
	// Output
	output [(7*NUM_DISPLAYS)-1:0] seven_seg

);

genvar i;

generate 

// generate a HexTo7Seg converter for each available display
	for (i = 0; i < NUM_DISPLAYS; i = i + 1) begin : SevenSeg_loop

		HexTo7Seg display (
			.hex			( password[(i*4)+:4] ),
			.SevenSeg	( seven_seg[(i*7)+:7] )
		);
		
	end 

endgenerate

endmodule
	