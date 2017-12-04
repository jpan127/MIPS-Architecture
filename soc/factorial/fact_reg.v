module fact_reg #(parameter w = 32) 
(	
    input wire Clk, Rst, 
	input wire [w - 1 : 0] D, 
	input wire Load_Reg, 
	output reg[w - 1 : 0] Q
);
always@ (posedge Clk, posedge Rst) 
begin
	if (Rst) 			Q <= 0;
	else if(Load_Reg)	Q <= D;
    else 				Q <= Q;
end
endmodule


module fact_reg_done #(parameter w = 32) 
(	input wire Clk, Rst, 
	input wire Done, 
	input wire GoPulseCmb, 
	output reg ResDone
);
always@ (posedge Clk, posedge Rst) 
begin    
	if (Rst)       		ResDone <= 1'b0;
//	else       			ResDone <= (GoPulseCmb) & (Done | ResDone); 
    else if(GoPulseCmb) ResDone <= Done;
    else                ResDone <= ResDone;
end				

endmodule


module fact_reg_err #(parameter w = 32) 
(	input wire Clk, Rst, 
	input wire Err, 
	input wire GoPulseCmb, 
	output reg ResErr
);
always@ (posedge Clk, posedge Rst) 
begin 
	if (Rst)       		ResErr <= 1'b0;
	//else       	  		ResErr <= (~GoPulseCmb) & (Err | ResErr);
	else if(GoPulseCmb) ResErr <= Err;
    else                ResErr <= ResErr; 
end	

endmodule