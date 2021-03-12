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

module DigitalLock #(

	parameter PASSWORD_LENGTH = 4
	
)(

	input clock, reset,

	input [3:0] key,
	
	// add 7seg/LED outputs instead of enter and create password flags
	output reg locked, error, ep_flag, cp_flag
	
); 

reg [(4*PASSWORD_LENGTH)-1:0] password, temp_password;

localparam RESET_PASSWORD = {((4*PASSWORD_LENGTH)-1){1'b0}};

reg [2:0] state;

localparam	UNLOCKED 			= 3'd0,
				LOCKED 				= 3'd1,
				CREATE_PASSWORD 	= 3'd2,	
				ENTER_PASSWORD 	= 3'd3,
				ERROR 				= 3'd4;

integer key_presses = 0;


always @(state) begin

	error <= 1'b0;
	ep_flag <= 1'b0;
	cp_flag <= 1'b0;

	case (state)
 
		UNLOCKED: begin 
			locked <= 1'b0;
		end
  
		LOCKED: begin 
			locked <= 1'b1;
		end
		  
		CREATE_PASSWORD: begin 
			cp_flag <= 1'b1;
			locked <= 1'b0;
		end
	  
		ENTER_PASSWORD: begin
			ep_flag <= 1'b1;
			locked <= 1'b1;
		end
		  
		ERROR: begin
			error <= 1'b1;
		end
		  
	endcase
	 
end


always @(posedge clock or posedge reset) begin

	if (reset) begin
	  
		state <= UNLOCKED;
		password <= RESET_PASSWORD;
		temp_password <= RESET_PASSWORD;
		key_presses <= 0;
		  
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
			
				if (key_presses >= 2*PASSWORD_LENGTH) begin
					
					if (temp_password == password) begin
						state <= LOCKED;
					end else begin
						state <= ERROR;
						password <= RESET_PASSWORD;
					end
					
					temp_password <= RESET_PASSWORD;
					key_presses <= 0;
					
				end else if ((|key) && (key_presses < PASSWORD_LENGTH)) begin
				
					key_presses <= key_presses + 1;
					temp_password[(4*PASSWORD_LENGTH)-1 - (4*key_presses) -: 4] <= key; // Does Password MSB first (easier to display on 7 Seg)
				
				end else if (|key) begin
					
					key_presses <= key_presses + 1;
					password[(4*PASSWORD_LENGTH)-1 - (4*(key_presses-PASSWORD_LENGTH)) -: 4] <= key;
					
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
				
				if (key_presses >= PASSWORD_LENGTH) begin
					
					if (temp_password == password) begin
						state <= UNLOCKED;
						password <= RESET_PASSWORD;
					end else begin
						state <= ERROR;
					end
					
					temp_password <= RESET_PASSWORD;
					key_presses <= 0;
					
				end else	if (|key) begin
				
					temp_password[(4*PASSWORD_LENGTH)-1 - (4*key_presses) -: 4] <= key;
					key_presses <= key_presses + 1;
					
				end
			end
			
			
			ERROR: begin
			
				if (|key) begin
			
					key_presses <= 0;
				
					if (locked) begin
						state <= LOCKED;
					end else begin
						state <= UNLOCKED;
					end
					
				end else begin
				
					state <= ERROR;
					
				end
			end
			
					
			default: begin
				state <= UNLOCKED;
			end
					
		endcase
		
	end
	 
end

endmodule
