/*
 * ELEC5566 Assignment 2:
 * Digital Lock Finite State Machine Testbench
 * ------------------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ------------------------------------------
 * Testbench module for 5-state Mealy state machine 
 * defining the function of a 
 * digital lock, operating on the 
 * DE1-SoC Board
 *
 */
                                                      
`timescale 1 ns/100 ps

module DigitalLockFSM_tb;

parameter PASSWORD_LENGTH = 4;
parameter MAX_IDLE = 50;

reg clock, reset;

reg [3:0] key;

wire lock_flag, error_flag, enter_pwd_flag, create_pwd_flag;

DigitalLockFSM #(

	.PASSWORD_LENGTH	( PASSWORD_LENGTH ),
	.MAX_IDLE		( MAX_IDLE )
	
) DigitalLockFSM_dut (

	.clock			( clock ),
	.reset			( reset ),
	
	.key			( key ),
	
	.lock_flag		( lock_flag ),
	.error_flag		( error_flag ),
	.enter_pwd_flag		( enter_pwd_flag ),
	.create_pwd_flag	( create_pwd_flag )
	
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
		
		if (error_flag || lock_flag || create_pwd_flag || enter_pwd_flag) begin
			$display("Error FSM not set to UNLOCKED state when reset button pressed. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
						 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
			num_errors = num_errors + 1;
			
		end
	end
	
	// UNLOCKED STATE
	if (!error_flag && !lock_flag && !create_pwd_flag && !enter_pwd_flag) begin
	
		key = 4'h0;
		repeat(1) @(negedge clock);
		
		if (create_pwd_flag) begin
			$display("Error UNLOCKED state changed when no buttons pressed. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
						 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
			num_errors = num_errors + 1;
		end 
		
		key = 4'h1;
		repeat(1) @(negedge clock);
		
		if (!create_pwd_flag) begin
			$display("Error UNLOCKED state not changed when button pressed. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
						 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
			num_errors = num_errors + 1;
			
		end
	end
	
	// CREATE PASSWORD STATE
	else if (!error_flag && !lock_flag && create_pwd_flag && !enter_pwd_flag) begin
	
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
				
				if (!error_flag) begin
					$display("Error CREATE_PASSWORD state not changed to ERROR when non-identical passwords entered. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
							 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
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
				
				if (create_pwd_flag) begin
					$display("Error CREATE_PASSWORD state not changed when identical passwords entered. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
							 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
					num_errors = num_errors + 1;
				end 
				
				counter = 0;
				alternator = ~alternator;
				
			end
		end
	end
	
	// LOCKED STATE
	else if (!error_flag && lock_flag && !create_pwd_flag && !enter_pwd_flag) begin
	
		key = 4'h0;
		repeat(1) @(negedge clock);
		
		if (enter_pwd_flag) begin
			$display("Error LOCKED state changed when no buttons pressed. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
						 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
			num_errors = num_errors + 1;
		end 
		
		key = 4'h1;
		repeat(1) @(negedge clock);
		
		if (!enter_pwd_flag) begin
			$display("Error LOCKED state not changed when button pressed. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
						 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
			num_errors = num_errors + 1;
		end
	end
	
	// ENTER PASSWORD STATE
	else if (!error_flag && lock_flag && !create_pwd_flag && enter_pwd_flag) begin
	
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
				
				if (!error_flag) begin
					$display("Error ENTER_PASSWORD state not changed to ERROR when incorrect password entered. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
							 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
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

				if (enter_pwd_flag) begin
					$display("Error ENTER_PASSWORD state not changed when correct password entered. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
							 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
					num_errors = num_errors + 1;
				end
				
				counter = 0;
				alternator = ~alternator;
				
			end
		end
	end
	
	// ERROR STATE
	else if (error_flag) begin
	
		key = 4'h0;
		repeat(1) @(negedge clock);
		
		if (!error_flag) begin
			$display("Error ERROR state changed when no buttons pressed. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
						 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
			num_errors = num_errors + 1;
		end 
		
		key = 4'h1;
		repeat(1) @(negedge clock);
		
		if (error_flag) begin
			$display("Error ERROR state not changed when button pressed. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
						 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
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
		
		if (!error_flag) begin
			$display("Error state not changed to ERROR when idle limit exceeded. Inputs: key=%b. Outputs: lock_flag=%b, error_flag=%b, create_pwd_flag=%b, enter_pwd_flag=%b.",
						 key,lock_flag,error_flag,create_pwd_flag,enter_pwd_flag);
			num_errors = num_errors + 1;
		end
			
		$display("TOTAL ERRORS = %d",num_errors);
		$stop;
	end
end

endmodule
	
