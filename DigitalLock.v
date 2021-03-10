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

reg [2:0] state;

localparam UNLOCKED 				= 3'b000;
localparam LOCKED 				= 3'b001;
localparam CREATE_PASSWORD 	= 3'b010;
localparam ENTER_PASSWORD 		= 3'b011;
localparam ERROR 					= 3'b100;

reg [3*LENGTH_PASSWORD:0] password;
reg [3*LENGTH_PASSWORD:0] temp_password;


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
					
				integer key_presses = 0;
						
				while (key_presses < 3) begin
					if (|key) begin
						temp_password <= key << 3*key_presses;
						key_presses = key_presses + 1;
					end
				end
						
				key_presses = 0;
						
				while (key_presses < 3) begin
					if (|key) begin
						password = key << 3*key_presses;
						key_presses = key_presses + 1;
					end
				end
						
				if (password == temp_password) begin
					state <= LOCKED;
					locked <= 1'b1;
				end else begin
					state <= ERROR;
					locked <= 1'b0;
				end
								
			end
			
			LOCKED: begin
					
				integer key_presses = 0;
				
				while (key_presses < 3) begin
					if (|key) begin
						temp_password <= key << 3*key_presses;
						key_presses = key_presses + 1;
					end
				end
				
				if (temp_password == password) begin
					state <= UNLOCKED;
					locked <= 1'b0;
				end else begin
					state <= ERROR;
					locked <= 1'b1;
				end
				
			end
			
			ERROR: begin
			
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
