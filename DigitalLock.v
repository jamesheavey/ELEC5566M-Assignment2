/*
 * ELEC5566 Assignment 2:
 * Digital Lock Finite State Machine
 * ---------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ------------
 * 5-state hybrid state machine 
 * defining the function of a 
 * digital lock, operating on the 
 * DE1-SoC Board
 *
 */

module DigitalLock #(

	parameter LENGTH_PASSWORD = 4
	
)(

	input clock, 
	input reset,

	input [3:0] key,

	output reg locked
	
); 

reg [(4*LENGTH_PASSWORD)-1:0] password, temp_password;

localparam ZERO = {((4*LENGTH_PASSWORD)-1){1'b0}};

reg [2:0] state;

localparam UNLOCKED 				= 3'b000;
localparam LOCKED 				= 3'b001;
localparam CREATE_PASSWORD 	= 3'b010;
localparam ENTER_PASSWORD 		= 3'b011;
localparam ERROR 					= 3'b100;

integer key_presses = 0;


always @(posedge clock or posedge reset) begin

	if (reset) begin
	  
		state <= UNLOCKED;
		locked <= 1'b0;
		  
	end else begin
	 
		case (state)
		  
			UNLOCKED: begin 
		
				if (|key) begin 
					state <= CREATE_PASSWORD;
				end else begin
					state <= UNLOCKED;
				end
				
				locked <= 1'b0;
				
			end
					
			CREATE_PASSWORD: begin 
			
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
					
				end else if ((|key) && (key_presses < LENGTH_PASSWORD)) begin
				
					temp_password <= key << 4*key_presses;
					key_presses = key_presses + 1;
				
				end else if (|key) begin
				
					password <= key << 4*(key_presses - LENGTH_PASSWORD);
					key_presses = key_presses + 1;
					
				end		
			end
			
			LOCKED: begin
				
				if (key_presses >= LENGTH_PASSWORD) begin
				
					key_presses = 0;
					
					if (temp_password == password) begin
						state <= UNLOCKED;
						locked <= 1'b0;
					end else begin
						state <= ERROR;
						locked <= 1'b1;
					end
					
					temp_password <= ZERO;
					password <= ZERO;
					
				end else	if (|key) begin
				
					temp_password <= key << 4*key_presses;
					key_presses = key_presses + 1;
					
				end
			end
			
			ERROR: begin
			
				key_presses = 0;
			
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
