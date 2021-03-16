/*
 * ELEC5566 Assignment 2:
 * Password to Seven Segment Testbench
 * ------------------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ------------------------------------------
 * Testbench module for password to 7seg  
 * conversion module
 *
 */
                                                      
`timescale 1 ns/100 ps

module PasswordTo7Seg_tb;

parameter NUM_DISPLAYS = 6;

reg clock;

reg [(4*NUM_DISPLAYS)-1:0] password;

wire [(7*NUM_DISPLAYS)-1:0] SevenSeg;

PasswordTo7Seg #(
	
	.NUM_DISPLAYS	( NUM_DISPLAYS )

) PasswordTo7Seg_dut (
	
	.password	( password ),
	.SevenSeg	( SevenSeg )
	
);

// Initialise Clock
initial begin
	clock = 0;
end

// Alternate clock every 10ns
always #10 clock = ~clock;

integer i;

always begin

	for (i = 0; i < NUM_DISPLAYS; i = i + 1) begin
	
		password <= 4'd1 << 4 * i;
		repeat(2) @(posedge clock);
		
	end

	$stop;
	
end

endmodule
