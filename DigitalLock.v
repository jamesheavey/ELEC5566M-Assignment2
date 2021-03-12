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

	parameter PASSWORD_LENGTH = 4
	
)(

	input clock, reset,

	input [3:0] key,
	
	// add 7seg/LED outputs instead of enter and create password flags
	output locked, error, ep_flag, cp_flag
	
); 

wire [3:0] filtered_key;

KeyPressFilter Filter (
	
	.clock				( clock ),
	
	.key					( key ),
	
	.posedge_key		( filtered_key )

);


DigitalLockFSM #(

	.PASSWORD_LENGTH	( PASSWORD_LENGTH )
	
) FSM (

	.clock				( clock ),
	.reset				( reset ),
	
	.key					( filtered_key ),
	
	.locked				( locked ),
	.error				( error ),
	.ep_flag				( ep_flag ),
	.cp_flag				( cp_flag )
	
);

endmodule
