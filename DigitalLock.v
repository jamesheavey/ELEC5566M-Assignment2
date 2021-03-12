/*
 * ELEC5566 Assignment 2:
 * Digital Lock Top Level
 * ---------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ---------------------------------
 * Top level file defining the function
 * of a digital lock with User interfacing
 *
 */

module DigitalLock #(

	parameter PASSWORD_LENGTH = 4,
	parameter NUM_DISPLAYS = 6
	
)(

	input clock, reset,

	input [3:0] key,
	
	// add 7seg/LED outputs instead of enter and create password flags
	output locked, error, ep_flag, cp_flag,
	
	output [(7*NUM_DISPLAYS)-1:0] SevenSeg
	
); 

wire [3:0] filtered_key;
wire [(4*NUM_DISPLAYS)-1:0] display_digits;

KeyPressFilter Filter (
	
	.clock				( clock ),
	
	.key					( key ),
	
	.posedge_key		( filtered_key )

);


DigitalLockFSM #(

	.PASSWORD_LENGTH	( PASSWORD_LENGTH ),
	.NUM_DISPLAYS		( NUM_DISPLAYS )
	
) FSM (

	.clock				( clock ),
	.reset				( reset ),
	
	.key					( filtered_key ),
	
	.locked				( locked ),
	.error				( error ),
	.ep_flag				( ep_flag ),
	.cp_flag				( cp_flag ),
	
	.display_digits	( display_digits )
);


PasswordTo7Seg #(

	.NUM_DISPLAYS		( NUM_DISPLAYS )
	
) SevenSegments (
	
	.password			( display_digits ),
	
	.SevenSeg			( SevenSeg )

);

endmodule
