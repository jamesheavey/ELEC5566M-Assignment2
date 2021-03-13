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

module KeyPressFilter #(
	
	parameter NUM_KEYS = 4

)(

	input clock,

	input [NUM_KEYS-1:0] key,

	output [NUM_KEYS-1:0] posedge_key
	
); 

reg delay;

always @(posedge clock) begin
	
	delay <= |key;

end

assign posedge_key = key & ~{(4){delay}};	

endmodule
