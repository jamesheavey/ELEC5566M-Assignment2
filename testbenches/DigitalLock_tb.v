/*
 * ELEC5566 Assignment 2:
 * Digital Lock Top-level Testbench
 * ------------------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ------------------------------------------
 * Testbench module Top level file 
 * defining the function of a 
 * digital lock, operating on the 
 * DE1-SoC Board
 *
 */
                                                      
`timescale 1 ns/100 ps

module DigitalLock_tb;

parameter PASSWORD_LENGTH = 4;
parameter NUM_DISPLAYS = 6;
parameter MAX_IDLE = 50;

reg clock, reset;

reg [3:0] key;

wire LED_locked, LED_error, LED_ep, LED_cp, LED_unlocked, LED_reset;

wire [(7*NUM_DISPLAYS)-1:0] seven_seg;

DigitalLock #(

	.PASSWORD_LENGTH	( PASSWORD_LENGTH ),
	.NUM_DISPLAYS		( NUM_DISPLAYS ),
	.MAX_IDLE			( MAX_IDLE )
	
) DigitalLock_dut (

	.clock				( clock ),
	.reset				( reset ),
	
	.key					( ~key ),
	
	.LED_locked			( LED_locked ),
	.LED_error			( LED_error ),
	.LED_ep				( LED_ep ),
	.LED_cp				( LED_cp ),
	.LED_unlocked		( LED_unlocked ),
	.LED_reset			( LED_reset ),
	
	.seven_seg			( seven_seg )
	
);

localparam RST_CYCLES = 2;
localparam WAIT_CYCLES = 2;
localparam MAX_CYCLES = 50;

// Initialise Clock
initial begin
	clock = 0;
end

// Alternate clock every 10ns
always #10 clock = ~clock;

// Variables
integer num_cycles = 0;
integer num_errors = 0;
integer counter = 0;
integer alternator = 0;
integer local_reset = 1;


always begin

	// Start in Reset
	if (local_reset) begin
	
		reset = 1;
		repeat(RST_CYCLES) @(posedge clock);
		reset = 0;
		
		local_reset = 0;
		counter = 0;
		alternator = 0;
		
		if (LED_error || LED_locked || LED_cp || LED_ep) begin
			$display("Error FSM not set to UNLOCKED state when reset button pressed. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
						 key,LED_locked,LED_error,LED_cp,LED_ep);
			num_errors = num_errors + 1;
			
		end 
		
		if (!LED_reset) begin
			$display("LED_reset not illuminated when reset high. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
						 key,LED_locked,LED_error,LED_cp,LED_ep);
			num_errors = num_errors + 1;
		end
		
		repeat(1) @(negedge clock);
		
	end
	
	// UNLOCKED STATE
	if (!LED_error && !LED_locked && !LED_cp && !LED_ep) begin
	
		key = 4'h0;
		repeat(1) @(negedge clock);
		
		if (LED_cp) begin
			$display("Error UNLOCKED state changed when no buttons pressed. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
						 key,LED_locked,LED_error,LED_cp,LED_ep);
			num_errors = num_errors + 1;
		end 
		
		key = 4'h1;
		repeat(1) @(negedge clock);
		
		if (!LED_cp) begin
			$display("Error UNLOCKED state not changed when button pressed. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
						 key,LED_locked,LED_error,LED_cp,LED_ep);
			num_errors = num_errors + 1;
			
		end
	end
	
	// CREATE PASSWORD STATE
	else if (!LED_error && !LED_locked && LED_cp && !LED_ep) begin
	
		key = 4'h0;
		repeat(WAIT_CYCLES) @(negedge clock);
	
		if (!alternator) begin
			if (counter < 2*PASSWORD_LENGTH) begin
			
				key = ($urandom % 14) + 1;
				repeat(WAIT_CYCLES) @(negedge clock);
				
				counter = counter + 1;
			end else begin
			
				key = 4'h0;
				repeat(WAIT_CYCLES) @(negedge clock);
				
				if (!LED_error) begin
					$display("Error CREATE_PASSWORD state not changed to ERROR when non-identical passwords entered. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
							 key,LED_locked,LED_error,LED_cp,LED_ep);
					num_errors = num_errors + 1;
				end 
				
				counter = 0;
				alternator = ~alternator;
				
			end
		
		end else begin
		
			if (counter < 2*PASSWORD_LENGTH) begin
			
				key = 4'hF;
				repeat(WAIT_CYCLES) @(negedge clock);
				
				counter = counter + 1;
				
			end else begin
			
				key = 4'h0;
				repeat(WAIT_CYCLES) @(negedge clock);
				
				if (LED_cp) begin
					$display("Error CREATE_PASSWORD state not changed when identical passwords entered. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
							 key,LED_locked,LED_error,LED_cp,LED_ep);
					num_errors = num_errors + 1;
				end 
				
				counter = 0;
				alternator = ~alternator;
				
			end
		end
	end
	
	// LOCKED STATE
	else if (!LED_error && LED_locked && !LED_cp && !LED_ep) begin
	
		key = 4'h0;
		repeat(1) @(negedge clock);
		
		if (LED_ep) begin
			$display("Error LOCKED state changed when no buttons pressed. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
						 key,LED_locked,LED_error,LED_cp,LED_ep);
			num_errors = num_errors + 1;
		end 
		
		key = 4'h1;
		repeat(1) @(negedge clock);
		
		if (!LED_ep) begin
			$display("Error LOCKED state not changed when button pressed. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
						 key,LED_locked,LED_error,LED_cp,LED_ep);
			num_errors = num_errors + 1;
			
		end
	end
	
	// ENTER PASSWORD STATE
	else if (!LED_error && LED_locked && !LED_cp && LED_ep) begin
	
		key = 4'h0;
		repeat(WAIT_CYCLES) @(negedge clock);
	
		if (!alternator) begin
		
			if (counter < PASSWORD_LENGTH) begin
			
				key = ($urandom % 14) + 1;
				repeat(WAIT_CYCLES) @(negedge clock);
				
				counter = counter + 1;
				
			end else begin
				
				key = 4'h0;
				repeat(WAIT_CYCLES) @(negedge clock);
				
				if (!LED_error) begin
					$display("Error ENTER_PASSWORD state not changed to ERROR when incorrect password entered. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
							 key,LED_locked,LED_error,LED_cp,LED_ep);
					num_errors = num_errors + 1;
				end 
				
				counter = 0;
				alternator = ~alternator;
				
			end
		
		end else begin
		
			if (counter < PASSWORD_LENGTH) begin
			
				key = 4'hF;
				repeat(WAIT_CYCLES) @(negedge clock);
				
				counter = counter + 1;
				
			end else begin
				
				key = 4'h0;
				repeat(WAIT_CYCLES) @(negedge clock);

				if (LED_ep) begin
					$display("Error ENTER_PASSWORD state not changed when correct password entered. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
							 key,LED_locked,LED_error,LED_cp,LED_ep);
					num_errors = num_errors + 1;
				end
				
				counter = 0;
				alternator = ~alternator;

			end
		end
	end
	
	// ERROR STATE
	else if (LED_error) begin
	
		key = 4'h0;
		repeat(1) @(negedge clock);
		
		if (!LED_error) begin
			$display("Error ERROR state changed when no buttons pressed. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
						 key,LED_locked,LED_error,LED_cp,LED_ep);
			num_errors = num_errors + 1;
		end 
		
		key = 4'h1;
		repeat(1) @(negedge clock);
		
		if (LED_error) begin
			$display("Error ERROR state not changed when button pressed. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
						 key,LED_locked,LED_error,LED_cp,LED_ep);
			num_errors = num_errors + 1;
		end
	end
	
	if (num_cycles == 63) begin
		local_reset = 1;
	end
	
	num_cycles = num_cycles + 1;
	
	$display("Cycle %d",num_cycles);
		
	if (num_cycles == 2*(MAX_CYCLES)) begin
		
		key = 4'h0;
	
		repeat(2*MAX_IDLE+1) @(posedge clock);
		
		if (!LED_error) begin
			$display("Error state not changed to ERROR when idle limit exceeded. Inputs: key=%b. Outputs: LED_locked=%b, LED_error=%b, LED_cp=%b, LED_ep=%b.",
						 key,LED_locked,LED_error,LED_cp,LED_ep);
			num_errors = num_errors + 1;
		end
			
		$display("TOTAL ERRORS = %d",num_errors);
		$stop;
	end
end

endmodule
