/*
 * ELEC5566 Assignment 2:
 * Key Press Filter
 * ---------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ---------------------------------
 * Module to filter button presses
 * preventing buttons from being held high
 *
 */

module KeyPressFilter (

	input clock,

	input [3:0] key,

	output [3:0] posedge_key
	
); 

reg delay;

// delay the signal by 1 clock cycle
always @(posedge clock) begin
	
	// delay is 1 if any key is pressed, preventing
	// multiple key presses
	delay <= |key;

end

// signal resulting from this operation remains high for 
// one clock cycle when key transitions low -> high, then 
// returns low what the delayed signal also transitions
assign posedge_key = key & ~{(4){delay}};

endmodule
