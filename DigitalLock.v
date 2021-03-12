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
	
	output LED1, LED2, LED3, LED4,
	
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
	
	.lock_flag			( LED1 ),
	.error_flag			( LED2 ),
	.enter_pwd_flag	( LED3 ),
	.create_pwd_flag	( LED4 ),
	
	.display_digits	( display_digits )
);


PasswordTo7Seg #(

	.NUM_DISPLAYS		( NUM_DISPLAYS )
	
) SevenSegments (
	
	.password			( display_digits ),
	
	.SevenSeg			( SevenSeg )

);

endmodule
