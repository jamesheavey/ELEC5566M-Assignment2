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

always @(posedge clock) begin
	
	delay <= |key;

end

assign posedge_key = key & ~{(4){delay}};	

endmodule
