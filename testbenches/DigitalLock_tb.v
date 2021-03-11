/*
 * ELEC5566 Assignment 2:
 * Digital Lock Finite State Machine Testbench
 * ------------------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ------------------------------------------
 * Testbench module for 5-state hybrid state machine 
 * defining the function of a 
 * digital lock, operating on the 
 * DE1-SoC Board
 *
 */
                                                      
`timescale 1 ns/100 ps

module DigitalLock_tb;

parameter PASSWORD_LENGTH = 4;

reg clock, reset;

reg [3:0] key;

wire locked, error, ep_flag, cp_flag;

DigitalLock #(

	.PASSWORD_LENGTH	( PASSWORD_LENGTH )
	
) DigitalLock_dut (

	.clock				( clock ),
	.reset				( reset ),
	
	.key					( key ),
	.locked				( locked ),
	.error				( error ),
	.ep_flag				( ep_flag ),
	.cp_flag				( cp_flag )
	
);

localparam RST_CYCLES = 2;
localparam MAX_CYCLES = 50;

initial begin
	clock = 1'b0;
end

initial begin
	reset = 1'b1; //Start in reset.
	repeat(RST_CYCLES) @(posedge clock); //Wait for a couple of clocks
	reset = 1'b0;
	
end

always #10 clock = ~clock;

integer num_cycles = 0;
integer counter = 0;
integer alternator = 0;

always begin

	num_cycles = num_cycles + 1;
	
	key = 4'd0;
		
	repeat(1) @(posedge clock);
	
	if (!locked && !cp_flag) begin
	
		key = 4'd0;
		
		repeat(1) @(posedge clock);
		
		if (cp_flag) begin
			$display("Error UNLOCKED state changed when no buttons pressed. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
						 key,locked,error,cp_flag,ep_flag);
		end 
		
		key = 4'd1;
		repeat(1) @(posedge clock);
		
		if (!cp_flag) begin
			$display("Error UNLOCKED state not changed when button pressed. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
						 key,locked,error,cp_flag,ep_flag);
		end
		
	end
	
	if (!locked && cp_flag) begin
	
		
		if (!alternator) begin
			if (counter < 2*PASSWORD_LENGTH) begin
			
				key = counter;
				repeat(1) @(posedge clock);
				
				counter = counter + 1;
			end else begin
			
				key = 4'd0;
				repeat(1) @(posedge clock);
				
				if (!cp_flag) begin
					$display("Error CREATE_PASSWORD state changed when non-identical passwords entered. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
							 key,locked,error,cp_flag,ep_flag);
				end 
				
				counter = 0;
				alternator = ~alternator;
				
			end
		
		end else begin
		
			if (counter < 2*PASSWORD_LENGTH) begin
			
				key = 4'd1;
				repeat(1) @(posedge clock);
				counter = counter + 1;
				
			end else begin
			
				key = 4'd0;
				repeat(1) @(posedge clock);
				
				if (cp_flag) begin
					$display("Error CREATE_PASSWORD state not changed when identical passwords entered. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
							 key,locked,error,cp_flag,ep_flag);
				end 
				
				counter = 0;
				alternator = ~alternator;
				
			end
		end
	end
	
	else if (locked && !ep_flag) begin
	
		key = 4'd0;
		repeat(1) @(posedge clock);
		
		if (cp_flag) begin
			$display("Error LOCKED state changed when no buttons pressed. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
						 key,locked,error,cp_flag,ep_flag);
		end 
		
		key = 4'd1;
		repeat(1) @(posedge clock);
		
		if (!cp_flag) begin
			$display("Error LOCKED state not changed when button pressed. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
						 key,locked,error,cp_flag,ep_flag);
		end
	end
	
	else if (locked && ep_flag) begin
	
		if (!alternator) begin
		
			if (counter < PASSWORD_LENGTH) begin
				key = 4'd7;
				repeat(1) @(posedge clock);
				
				counter = counter + 1;
				
			end else begin
			
				key = 4'd0;
				repeat(1) @(posedge clock);
				
				if (!cp_flag) begin
					$display("Error ENTER_PASSWORD state changed when incorrect password entered. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
							 key,locked,error,cp_flag,ep_flag);
				end 
				
				counter = 0;
				alternator = ~alternator;
				
			end
		
		end else begin
		
			if (counter < PASSWORD_LENGTH) begin
			
				key = 4'd1;
				repeat(1) @(posedge clock);
				
				counter = counter + 1;
				
			end else begin
			
				key = 4'd0;
				repeat(1) @(posedge clock);
				
				if (cp_flag) begin
					$display("Error ENTER_PASSWORD state not changed when correct password entered. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
							 key,locked,error,cp_flag,ep_flag);
				end
				
				counter = 0;
				alternator = ~alternator;
				
			end
		end
	end
	
	else if (error) begin
	
		key = 4'd0;
		repeat(1) @(posedge clock);
		
		if (!error) begin
			$display("Error ERROR state changed when no buttons pressed. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
						 key,locked,error,cp_flag,ep_flag);
		end 
		
		key = 4'd1;
		repeat(1) @(posedge clock);
		
		if (error) begin
			$display("Error ERROR state not changed when button pressed. Inputs: key=%b. Outputs: locked=%b, error=%b, cp_flag=%b, ep_flag=%b.",
						 key,locked,error,cp_flag,ep_flag);
		end
	end
	
	if (num_cycles == 43) begin
	
		reset = 1;
		repeat(RST_CYCLES) @(posedge clock);
		reset = 0;
		
	end
	
	$display("Cycle %d",num_cycles);
		
	if (num_cycles == 2*(MAX_CYCLES)) begin
		$stop;
	end
end
	
endmodule
	