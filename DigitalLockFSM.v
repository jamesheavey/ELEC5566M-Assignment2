/*
 * ELEC5566 Assignment 2:
 * Digital Lock Finite State Machine
 * ---------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ---------------------------------
 * 5-state Mealy state machine 
 * defining the function of a 
 * digital lock, operating on the 
 * DE1-SoC Board
 *
 */

module DigitalLockFSM #(

	parameter PASSWORD_LENGTH = 4,
	parameter NUM_DISPLAYS = 6,
	parameter MAX_IDLE = 500000000
	
)(

	input clock, reset,

	input [3:0] key,
	
	output reg lock_flag, error_flag, enter_pwd_flag, create_pwd_flag,
	
	output reg [(4*NUM_DISPLAYS)-1:0] display_digits
	
); 

reg [(4*PASSWORD_LENGTH)-1:0] password, temp_password;

localparam RESET_PASSWORD = {((4*PASSWORD_LENGTH)-1){1'b0}};


integer key_presses = 0;
integer idle_counter = 0;
integer num_pwd_entered = 0;


always @(temp_password) begin

	if (reset) begin
	
		display_digits = {4'h5, 4'h3, 4'hD, 4'h3, 4'hE}; // Display 'rESEt'
	
	end else begin
	
		case (state) 
			
			ERROR: begin
				display_digits = {4'h3, 4'h5, 4'h5, 4'h6, 4'h5}; // Display 'ErrOr'
			end
			
			UNLOCKED: begin
				display_digits <= {4'h7, 4'h9, 4'hA, 4'h6, 4'hB, 4'hC}; // Display 'UnLOCD'
			end
			
			LOCKED: begin
				display_digits <= {4'hA, 4'h6, 4'hB, 4'hB, 4'h3, 4'hC}; // Display 'LOCCED'
			end
			
			default begin
				display_digits <= temp_password >> 4*(PASSWORD_LENGTH - key_presses);
			end
			
		endcase
	end
end


reg [2:0] state, prev_state, sub_state;

localparam	UNLOCKED 			= 3'd0,
				LOCKED 				= 3'd1,
				CREATE_PASSWORD 	= 3'd2,	
				ENTER_PASSWORD 	= 3'd3,
				ERROR 				= 3'd4,
				
				ENTER_DIGIT			= 3'd5,
				CHECK					= 3'd6,
				RETURN_PASSWORD	= 3'd7;
				

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


always @(posedge clock or posedge reset) begin

	if (reset) begin
	  
		state					<= UNLOCKED;
		sub_state			<= ENTER_DIGIT;
		prev_state			<= UNLOCKED;
		password				<= RESET_PASSWORD;
		temp_password		<= RESET_PASSWORD;
		key_presses			<= 0;
		idle_counter		<= 0;
		num_pwd_entered	<= 0;
		  
	end else if (idle_counter == MAX_IDLE) begin
		
		state					<= ERROR;
		idle_counter		<= 0;
		
	end else begin
	 
		case (state)
		  
			UNLOCKED: begin 
		
				if (|key) begin 
					state			<= CREATE_PASSWORD;
				end else begin
					state			<= UNLOCKED;
				end
			end
			
					
			CREATE_PASSWORD: begin 
				
				prev_state <= UNLOCKED;
				
				input_password();
				
				if (sub_state == RETURN_PASSWORD) begin
					
					if (num_pwd_entered == 0) begin
					
						password <= temp_password;
						num_pwd_entered	<= num_pwd_entered + 1;
						
					end else begin
					
						num_pwd_entered	<= 0;
						
						if (temp_password == password) begin
							state 			<= LOCKED;
						end else begin
							state				<= ERROR;
							password			<= RESET_PASSWORD;
						end
						
					end 
					
					temp_password		<= RESET_PASSWORD;
					
				end
		
			end
			
			
			LOCKED: begin
		
				if (|key) begin 
					state			<= ENTER_PASSWORD;
				end else begin
					state			<= LOCKED;
				end
			end
			
			
			ENTER_PASSWORD: begin
				
				prev_state <= LOCKED;
				
				input_password();
					
				if (sub_state == RETURN_PASSWORD) begin
				
					if (password == temp_password) begin
					
						state				<= UNLOCKED;
						password			<= RESET_PASSWORD;
						temp_password	<= RESET_PASSWORD;
						
					end else begin
						
						state 			<= ERROR;
						temp_password	<= RESET_PASSWORD;
						
					end
					
				end

			end
			
			
			ERROR: begin
			
				if (|key) begin
				
					state			<= prev_state;
					
					key_presses	<= 0;
					
				end else begin
				
					state <= ERROR;
					
				end
			end
			
					
			default: begin
				state	<= ERROR;
			end
					
		endcase
		
	end
	 
end


task input_password();
	
	case(sub_state)
	
		ENTER_DIGIT: begin
			
			if (|key) begin
			
				temp_password[(4*PASSWORD_LENGTH)-1 - (4*key_presses) -: 4] <= key;

				key_presses 	<= key_presses + 1;
				
				sub_state 		<= CHECK;
				
				idle_counter 	<= 0;
				
			end else begin
			
				sub_state 		<= ENTER_DIGIT;
				
				idle_counter 	<= idle_counter+1;
			
			end
		end
			
		CHECK: begin
			
			if (key_presses >= PASSWORD_LENGTH) begin
			
				sub_state 		<= RETURN_PASSWORD;
				key_presses 	<= 0;
				
			end else begin
			
				sub_state 		<= ENTER_DIGIT;
				
			end
		end
			
		RETURN_PASSWORD: begin
			
			sub_state	<= ENTER_DIGIT;
			
		end
			
		default: begin
			sub_state 	<= ENTER_DIGIT;
		end
		
	endcase

endtask

endmodule
