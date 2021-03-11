/*
 * ELEC5566 Assignment 2:
 * Digital Lock Finite State Machine
 * ---------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ---------------------------------
 * 5-state hybrid state machine 
 * defining the function of a 
 * digital lock, operating on the 
 * DE1-SoC Board
 *
 */

module DigitalLockHybrid #(

	parameter LENGTH_PASSWORD = 4
	
)(

	input clock, reset,

	input [3:0] key,
	
	// add 7seg/LED outputs instead of enter and create password flags
	output reg locked, error, ep_flag, cp_flag
	
); 

reg [(4*LENGTH_PASSWORD)-1:0] password, temp_password;

localparam ZERO = {((4*LENGTH_PASSWORD)-1){1'b0}};

reg [2:0] state;

localparam	UNLOCKED 			= 3'd0,
				LOCKED 				= 3'd1,
				CREATE_PASSWORD 	= 3'd2,	
				ENTER_PASSWORD 	= 3'd3,
				ERROR 				= 3'd4;

integer key_presses = 0;


always @(posedge clock or posedge reset) begin

	if (reset) begin
	  
		state <= UNLOCKED;
		locked <= 1'b0;
		error <= 1'b0;
		  
	end else begin
	 
		case (state)
		  
			UNLOCKED: begin 
			
				error <= 1'b0;
		
				if (|key) begin 
					state <= CREATE_PASSWORD;
				end else begin
					state <= UNLOCKED;
				end
				
				locked <= 1'b0;
				
			end
					
			CREATE_PASSWORD: begin 
			
				cp_flag <= 1'b1;
			
				if (key_presses >= 2*LENGTH_PASSWORD) begin
				
					key_presses = 0;
					
					if (temp_password == password) begin
						state <= LOCKED;
						locked <= 1'b1;
					end else begin
						state <= ERROR;
						locked <= 1'b0;
						password <= ZERO;
		
					end
					
					temp_password <= ZERO;
					cp_flag <= 1'b0;
					
				end else if ((|key) && (key_presses < LENGTH_PASSWORD)) begin
				
					temp_password <= key << 4*key_presses;
					key_presses = key_presses + 1;
				
				end else if (|key) begin
				
					password <= key << 4*(key_presses - LENGTH_PASSWORD);
					key_presses = key_presses + 1;
					
				end	
				
			end
			
			LOCKED: begin
				
				error <= 1'b0;
		
				if (|key) begin 
					state <= ENTER_PASSWORD;
				end else begin
					state <= LOCKED;
				end
				
				locked <= 1'b1;
				
			end
			
			ENTER_PASSWORD: begin
				
				ep_flag <= 1'b1;
				
				if (key_presses >= LENGTH_PASSWORD) begin
				
					key_presses = 0;
					
					if (temp_password == password) begin
						state <= UNLOCKED;
						locked <= 1'b0;
						password <= ZERO;
					end else begin
						state <= ERROR;
						locked <= 1'b1;
					end
					
					temp_password <= ZERO;
					ep_flag <= 1'b1;
					
				end else	if (|key) begin
				
					temp_password <= key << 4*key_presses;
					key_presses = key_presses + 1;
					
				end
				
			end
			
			ERROR: begin
			
				key_presses = 0;
				error = 1'b1;
			
				if (locked) begin
					state <= LOCKED;
				end else begin
					state <= UNLOCKED;
				end
				
			end
					
			default: begin
				state <= UNLOCKED;
			end
					
		endcase
		
	end
	 
end

endmodule
