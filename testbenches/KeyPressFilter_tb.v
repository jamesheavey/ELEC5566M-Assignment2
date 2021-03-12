/*
 * ELEC5566 Assignment 2:
 * Key Press Filter Testbench
 * ------------------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ------------------------------------------
 * Testbench module for posedge detection 
 * of key presses
 *
 */
                                                      
`timescale 1 ns/100 ps

module KeyPressFilter_tb;

reg clock;

reg [3:0] key;

wire [3:0] posedge_key;

KeyPressFilter filter (

	.clock				( clock ),
	
	.key					( key ),
	.posedge_key		( posedge_key )
	
);

// Initialise Clock
initial begin
	clock = 0;
end

// Alternate clock every 10ns
always #10 clock = ~clock;


always begin
	
	key <= 4'h0;
	
	repeat(1) @(posedge clock);
	
	key <= 4'h7;
	
	repeat(2) @(posedge clock);
	
	key <= 4'hF;
	
	repeat(2) @(posedge clock);
	
	key <= 4'h0;
	
	repeat(2) @(posedge clock);
	
	key <= 4'hF;
	
	repeat(2) @(posedge clock);
	
	$stop;
	
end

endmodule
