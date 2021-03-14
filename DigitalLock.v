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
	// Parameters
	parameter PASSWORD_LENGTH = 5,
	parameter NUM_DISPLAYS = 6,
	parameter MAX_IDLE = 500000000
	
)(
	// Inputs
	(* chip_pin = "AF14" *) 
	input clock, 
	
	(* chip_pin = "AB12" *) 
	input reset,

	(* chip_pin = "Y16, W15, AA15, AA14" *) 
	input [3:0] key,
	
	// Outputs
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
	output [(7*NUM_DISPLAYS)-1:0] seven_seg
	
); 

// wires to connect instantiated sub-modules
wire [3:0] filtered_key;
wire [(4*NUM_DISPLAYS)-1:0] display_digits;

// Module to filter the raw key input
// outputs positive edge detection
KeyPressFilter Filter (
	
	.clock				( clock ),
	
	.key					( ~key ),
	
	.posedge_key		( filtered_key )

);

// Synchronous Module representing the DigitalLock logic, recieves 
// filtered key output and generates UI LED outputs, 
// aswell as the digits to be displayed on the 7segments
DigitalLockFSM #(

	.PASSWORD_LENGTH	( PASSWORD_LENGTH ),
	.NUM_DISPLAYS		( NUM_DISPLAYS ),
	.MAX_IDLE			( MAX_IDLE )
	
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

// Asynchronous module to convert the output
// hex display_digits from the FSM to 7 segment
// display representation
PasswordTo7Seg #(

	.NUM_DISPLAYS		( NUM_DISPLAYS )
	
) SevenSegments (
	
	.password			( display_digits ),
	
	.seven_seg			( seven_seg )

);

// Final UI LED assignment
assign LED_unlocked = ~LED_locked;
assign LED_reset = reset;

endmodule
