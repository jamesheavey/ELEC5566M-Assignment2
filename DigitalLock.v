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
 * of a digital lock with User interfacing.
 * System designed for implementation on
 * DE1-SoC Development Board
 *
 */

module DigitalLock #(

	parameter PASSWORD_LENGTH = 8,
	parameter NUM_DISPLAYS = 6,
	parameter NUM_KEYS = 4
	
)(
	
	(* chip_pin = "AF14" *) 
	input clock, 
	
	(* chip_pin = "AB12" *) 
	input reset,

	(* chip_pin = "Y16, W15, AA15, AA14" *) 
	input [3:0] key,
	
	(* chip_pin = "V16" *) 
	output LED_locked, 
	
	(* chip_pin = "W16" *) 
	output LED_error, 
	
	(* chip_pin = "V17" *) 
	output LED_ep, 
	
	(* chip_pin = "V18" *) 
	output LED_cp, 
	
	(* chip_pin = "W17" *) 
	output LED_unlocked, 
	
	(* chip_pin = "W19" *) 
	output LED_reset,
	
	(* chip_pin = {"AA25, AA26, AB26, AB27, Y27, AA28, V25,",
					   "W25, V23, W24, W22, Y24, Y23, AA24,",
					   "AB22, AB25, AB28, AC25, AD25, AC27, AD26,",
					   "AC30, AC29, AD30, AC28, AD29, AE29, AB23,",
					   "AD27, AF30, AF29, AG30, AH30, AH29, AJ29,",
					   "AH28, AG28, AF28, AG27, AE28, AE27, AE26"} *) 			  
	output [(7*NUM_DISPLAYS)-1:0] SevenSeg
	
); 


wire [NUM_KEYS:0] filtered_key;
wire [(NUM_KEYS*NUM_DISPLAYS)-1:0] display_digits;

KeyPressFilter #(

	.NUM_KEYS			( NUM_KEYS )
	
) Filter (
	
	.clock				( clock ),
	
	.key					( ~key ),
	
	.posedge_key		( filtered_key )

);


DigitalLockFSM #(

	.PASSWORD_LENGTH	( PASSWORD_LENGTH ),
	.NUM_DISPLAYS		( NUM_DISPLAYS )
	
) FSM (

	.clock				( clock ),
	.reset				( reset ),
	
	.key					( filtered_key ),
	
	.lock_flag			( LED_locked ),
	.error_flag			( LED_error ),
	.enter_pwd_flag	( LED_ep ),
	.create_pwd_flag	( LED_cp ),
	
	.display_digits	( display_digits )
);


PasswordTo7Seg #(

	.NUM_DISPLAYS		( NUM_DISPLAYS )
	
) SevenSegments (
	
	.password			( display_digits ),
	
	.SevenSeg			( SevenSeg )

);

assign LED_unlocked = ~ LED_locked;
assign LED_reset = reset;

endmodule
