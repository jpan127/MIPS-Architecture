module fact_ad
( 
	input  wire [1:0] A,
	input  wire WE,
	output reg WE1, 
	output reg WE2,
	output reg GO, 
	output wire [1:0] RdSel 
); 

always @ (*) 
begin 
	case(A)      
		2'b00: 
		begin
			WE1 = WE; 
			WE2 = 1'b0;
			GO  = 1'b0;
		end      
		2'b01: 
		begin
			WE1 = 1'b0;
			WE2 = WE;
			GO  = 1'b1;
		end
		2'b10: 
		begin
			WE1 = 1'b0;
			WE2 = 1'b0;
			GO  = 1'b0;
		end      
		2'b11: 
		begin
			WE1 = 1'b0;
			WE2 = 1'b0;
			GO  = 1'b0;
		end
		default: 
		begin
			WE1 = 1'bx;
			WE2 = 1'bx;
			GO  = 1'bx;
		end
	endcase
end
assign RdSel = A; endmodule