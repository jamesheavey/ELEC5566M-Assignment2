/*
 * ELEC5566 Assignment 2:
 * Digital Lock Finite State Machine
 * ---------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ---------------------------------
 * 5-state Moore state machine 
 * defining the function of a 
 * digital lock, operating on the 
 * DE1-SoC Board
 *
 */

module DigitalLockFSM #(
	// Parameters
	parameter PASSWORD_LENGTH = 4,
	parameter NUM_DISPLAYS = 6,
	parameter MAX_IDLE = 500000000
	
)(
	// Inputs
	input clock, reset,

	input [3:0] key,
	
	// Outputs
	output reg lock_flag, error_flag, enter_pwd_flag, create_pwd_flag,
	
	output reg [(4*NUM_DISPLAYS)-1:0] display_digits
	
); 

// Registers to store save and input passwords
reg [(4*PASSWORD_LENGTH)-1:0] password, temp_password;

localparam RESET_PASSWORD = {((4*PASSWORD_LENGTH)-1){1'b0}};

// Variables defining state transitions
integer key_presses = 0;
integer idle_counter = 0;
integer num_pwd_entered = 0;

// State registers
reg [2:0] state, prev_state, sub_state;

localparam	UNLOCKED 			= 3'd0,
			LOCKED 			= 3'd1,
			CREATE_PASSWORD 	= 3'd2,
			ENTER_PASSWORD		= 3'd3,
			ERROR 			= 3'd4,
				
			ENTER_DIGIT		= 3'd5,
			CHECK			= 3'd6,
			RETURN_PASSWORD		= 3'd7;

// Asynchronous Combinational block to update 7seg display digits
// whenever the temporary password changes
always @(temp_password or state or reset) begin

	if (reset) begin
		// Display 'rESEt' (assumes NUM_DISPLAYS == 6)
		display_digits <= {4'h5, 4'h3, 4'hD, 4'h3, 4'hE};
	
	end else begin
		case (state) 
			// Display 'ErrOr' (assumes NUM_DISPLAYS == 6)
			ERROR: display_digits <= {4'h3, 4'h5, 4'h5, 4'h6, 4'h5};
			
			// Display 'UnLOCD' (assumes NUM_DISPLAYS == 6)
			UNLOCKED: display_digits <= {4'h7, 4'h9, 4'hA, 4'h6, 4'hB, 4'hC};
			
			// Display 'LOCCED' (assumes NUM_DISPLAYS == 6)
			LOCKED: display_digits <= {4'hA, 4'h6, 4'hB, 4'hB, 4'h3, 4'hC};
			
			// Shift the password so that the current digit aligns with 7Seg[0]
			default: display_digits <= temp_password >> 4*(PASSWORD_LENGTH - key_presses);
		endcase
	end
end

// Asynchronous Combinational block to update state flags
// when the FSM state changes
always @(state) begin

	error_flag = 1'b0;
	enter_pwd_flag = 1'b0;
	create_pwd_flag = 1'b0;

	case (state)

		UNLOCKED: begin 
			lock_flag = 1'b0;
		end
		
		LOCKED: begin 
			lock_flag = 1'b1;
		end
		
		CREATE_PASSWORD: begin 
			create_pwd_flag = 1'b1;
			lock_flag = 1'b0;
		end
		
		ENTER_PASSWORD: begin
			enter_pwd_flag = 1'b1;
			lock_flag = 1'b1;	
		end
		
		ERROR: begin
			error_flag = 1'b1;
		end
		
	endcase
end

// Synchronous Sequential block representingthe state transitions of
// the high level Digitla lock FSM
always @(posedge clock or posedge reset) begin

	if (reset) begin
		// reset all variables and state registers
		state		<= UNLOCKED;
		sub_state	<= ENTER_DIGIT;
		prev_state	<= UNLOCKED;
		password	<= RESET_PASSWORD;
		temp_password	<= RESET_PASSWORD;
		key_presses	<= 0;
		idle_counter	<= 0;
		num_pwd_entered	<= 0;
		  
	end else if (idle_counter == MAX_IDLE) begin
		// if idle count exceeds max, enter error state
		state		<= ERROR;
		idle_counter	<= 0;
		
	end else begin
		case (state)
		  
			UNLOCKED: begin 
				// wait in unlocked until any key is pressed
				if (|key) begin 
					state	<= CREATE_PASSWORD;
				end else begin
					state	<= UNLOCKED;
				end
			end
					
			CREATE_PASSWORD: begin 
				// save previous state to be used in ERROR state logic
				prev_state	<= UNLOCKED;
				
				// enter sub-state machine
				InputPassword();
				
				if (sub_state == RETURN_PASSWORD) begin
					
					if (num_pwd_entered == 0) begin
						// save the first password input
						password <= temp_password;
						num_pwd_entered	<= num_pwd_entered + 1;
						
					end else begin
					
						num_pwd_entered	<= 0;
						
						if (temp_password == password) begin
							// if 1st password matches 2nd, enter LOCKED state
							state		<= LOCKED;
						end else begin
							// else enter ERROR state
							state		<= ERROR;
							password	<= RESET_PASSWORD;
						end
					end 
					
					temp_password	<= RESET_PASSWORD;
					
				end
			end
			
			LOCKED: begin
				// wait in locked until any key is pressed
				if (|key) begin 
					state	<= ENTER_PASSWORD;
				end else begin
					state	<= LOCKED;
				end
			end
			
			ENTER_PASSWORD: begin
				// save previous state to be used in ERROR state logic
				prev_state <= LOCKED;
				
				// enter sub-state machine
				InputPassword();
					
				if (sub_state == RETURN_PASSWORD) begin
				
					if (password == temp_password) begin
						// if entered password matches saved password
						// enter UNLOCKED state
						state		<= UNLOCKED;
						password	<= RESET_PASSWORD;
						temp_password	<= RESET_PASSWORD;
						
					end else begin
						// else enter ERROR state
						state 		<= ERROR;
						temp_password	<= RESET_PASSWORD;
						
					end
				end
			end
			
			ERROR: begin
				// wait in ERROR state until any key is pressed
				if (|key) begin
					// return to state saved in previous state register
					state		<= prev_state;
					
					key_presses	<= 0;
					
				end else begin
				
					state 		<= ERROR;
					
				end
			end
			
					
			default: begin
				state	<= ERROR;
			end
					
		endcase
	end
end

// Second Level FSM to handle password inputs
task InputPassword();
	
	case(sub_state)
	
		ENTER_DIGIT: begin
			
			if (|key) begin
				// if any key is pressed, save key state (4 bits) to
				// temp password register. Key presses are recorded MSB first
				// for easier representation on 7 segments
				temp_password[(4*PASSWORD_LENGTH)-1 - (4*key_presses) -: 4] <= key;

				key_presses	<= key_presses + 1;
				
				// enter CHECK state
				sub_state 	<= CHECK;
				
				// reset idle counter
				idle_counter 	<= 0;
				
			end else begin
				
				sub_state 	<= ENTER_DIGIT;
				
				idle_counter 	<= idle_counter+1;
			
			end
		end
			
		CHECK: begin
			
			if (key_presses >= PASSWORD_LENGTH) begin
				// if user has input a sufficient number of keys
				// return the password
				sub_state 	<= RETURN_PASSWORD;
				key_presses 	<= 0;
				
			end else begin
				// else return to ENTER_DIGIT state
				sub_state 	<= ENTER_DIGIT;
				
			end
		end
			
		RETURN_PASSWORD: begin
			// return to ENTER_DIGIT
			sub_state	<= ENTER_DIGIT;
			
		end
			
		default: begin
			sub_state 	<= ENTER_DIGIT;
		end
		
	endcase

endtask

endmodule
