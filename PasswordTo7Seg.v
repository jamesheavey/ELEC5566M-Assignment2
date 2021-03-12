//// Move all this to different 7seg handler module, chnage thsi module to DigitalLockFSM
//// Create a top level module that runs both the fsm, the 7 seg and other submodules
//// make only pos edge button module then use that to connect into the finite state machine buttons

//PasswordTo7Seg #(
//
//	.LENGTH		( length )
//	
//) displays (
//	
//	.password	( display ),
//	.SevenSegs	( )
//
//);

//integer length;
//reg [(6*4)-1:0] display;
//
//always @(posedge clock) begin
//
//	length = key_presses;
//
//	case (state)
//		  
//		CREATE_PASSWORD: begin 
//			if (key_presses < PASSWORD_LENGTH) begin
//				length = key_presses + 1;
//				display = temp_password >> 4*(PASSWORD_LENGTH - key_presses);
//			end else begin
//				length = key_presses - PASSWORD_LENGTH;
//				display = password >> 4*(key_presses);
//			end
//		end
//	  
//		ENTER_PASSWORD: begin
//			length = key_presses + 1;
//			display = password >> 4*key_presses;
//		end
//		  
//		default: begin
//			display = {((6*4)-1){1'bx}};
//		end
//		  
//	endcase
//	
//end
//
//endmodule