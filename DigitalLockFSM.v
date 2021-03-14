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


reg [2:0] state, prev_state;

localparam	UNLOCKED 			= 3'd0,
				LOCKED 				= 3'd1,
				CREATE_PASSWORD 	= 3'd2,	
				ENTER_PASSWORD 	= 3'd3,
				ERROR 				= 3'd4;


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
	  
		state <= UNLOCKED;
		prev_state <= UNLOCKED;
		password <= RESET_PASSWORD;
		temp_password <= RESET_PASSWORD;
		key_presses <= 0;
		idle_counter <= 0;
		  
	end else if (idle_counter == MAX_IDLE) begin
		
		state <= ERROR;
		idle_counter <= 0;
		
	end else begin
	 
		case (state)
		  
			UNLOCKED: begin 
		
				if (|key) begin 
					state <= CREATE_PASSWORD;
				end else begin
					state <= UNLOCKED;
				end
			end
			
					
			CREATE_PASSWORD: begin 
				
				prev_state <= UNLOCKED;
			
				if (key_presses >= 2*PASSWORD_LENGTH) begin
					
					if (temp_password == password) begin
						state <= LOCKED;
					end else begin
						state <= ERROR;
						password <= RESET_PASSWORD;
					end
					
					temp_password <= RESET_PASSWORD;
					key_presses <= 0;
					idle_counter <= 0;
					
				end else if ((|key) && (key_presses < PASSWORD_LENGTH)) begin
				
					temp_password[(4*PASSWORD_LENGTH)-1 - (4*key_presses) -: 4] <= key; // Does Password MSB first (easier to display on 7 Seg)
					
					key_presses <= key_presses + 1;
					idle_counter <= 0;
				
				end else if (|key) begin
					
					password[(4*PASSWORD_LENGTH)-1 - (4*(key_presses-PASSWORD_LENGTH)) -: 4] <= key;
					
					key_presses <= key_presses + 1;
					idle_counter <= 0;
					
				end else begin
					idle_counter <= idle_counter + 1;
				end	
			end
			
			
			LOCKED: begin
		
				if (|key) begin 
					state <= ENTER_PASSWORD;
				end else begin
					state <= LOCKED;
				end
			end
			
			
			ENTER_PASSWORD: begin
				
				prev_state <= LOCKED;
				
				if (key_presses >= PASSWORD_LENGTH) begin
					
					if (temp_password == password) begin
						state <= UNLOCKED;
						password <= RESET_PASSWORD;
					end else begin
						state <= ERROR;
					end
					
					temp_password <= RESET_PASSWORD;
					key_presses <= 0;
					idle_counter <= 0;
					
				end else	if (|key) begin
				
					temp_password[(4*PASSWORD_LENGTH)-1 - (4*key_presses) -: 4] <= key;
					
					key_presses <= key_presses + 1;
					idle_counter <= 0;
					
				end else begin
					idle_counter <= idle_counter + 1;
				end
			end
			
			
			ERROR: begin
			
				if (|key) begin
				
					state <= prev_state;
					
					key_presses <= 0;
					
				end else begin
				
					state <= ERROR;
					
				end
			end
			
					
			default: begin
				state <= ERROR;
			end
					
		endcase
		
	end
	 
end


always @(password or temp_password) begin

	if (reset) begin
	
		display_digits = {4'h5, 4'h3, 4'hD, 4'h3, 4'hE}; // Display 'rESEt'
	
	end else if (error_flag) begin
		
		display_digits = {4'h3, 4'h5, 4'h5, 4'h6, 4'h5}; // Display 'ErrOr'
		
	end else if (create_pwd_flag) begin

		if (key_presses < PASSWORD_LENGTH) begin
			display_digits <= temp_password >> 4*(PASSWORD_LENGTH - key_presses);
		end else begin
			display_digits <= password >> 4*(2*PASSWORD_LENGTH - key_presses);
		end
	
	end else if (enter_pwd_flag) begin
		
		display_digits <= temp_password >> 4*(PASSWORD_LENGTH - key_presses);
	
	end else if (lock_flag) begin
		
		display_digits <= {4'hA, 4'h6, 4'hB, 4'hB, 4'h3, 4'hC}; // Display 'LOCCED'
	
	end else if (!lock_flag) begin
		
		display_digits <= {4'h7, 4'h9, 4'hA, 4'h6, 4'hB, 4'hC}; // Display 'UnLOCD'
	
	end

end

endmodule
