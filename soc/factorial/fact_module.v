`timescale 1ns / 1ps
module fact_mux
(
	input wire [1:0]  RdSel,
	input wire [31:0] Zero,One,Two,Three,
	output reg [31:0] RD	
);

always@ (*)
begin 
	case(RdSel) 
		2'b00:    RD = Zero; 
		2'b01:    RD = One; 
		2'b10:    RD = Two;
		2'b11:    RD = Three; 
		default:  RD = {31{1'bx}};
	endcase   
end 
endmodule


module And
(
    input wire A,B,
    output reg Out
);
always@ (A,B)
begin
    if (A==B) Out=1;
    else Out=0;
end
endmodule

//2-1 MUX: 

module MUX  #(parameter WIDTH = 32)(
input [WIDTH-1:0] in1, in2, 
input select,
output reg [WIDTH-1:0] out);

always @ (in1, in2, select)
begin
	if (select)  out = in2;
else
	out = in1;
end

endmodule //MUX2

//Register File :

module REG #(parameter WIDTH = 32)(
input clk, reset, enable,
input [WIDTH-1:0] d,
output reg [WIDTH-1:0] q);

// asynchronous, active HIGH reset
always @(posedge clk, posedge reset)      
 if (reset) q <= 0;
 else if (enable==1 && reset==0) q <= d;      
 else       q <= q;
endmodule

//Multiplier : 

`timescale 1ns / 1ps
module MUL  (
input [31:0] in1, 
input [3:0]  in2, 
output reg [31:0] out);

always @ (in1, in2)
begin
   out = in1*in2;
end

endmodule

// CNT : 

module CNT (
input [3:0] D, 
input LD, EN, CLK, RST, 
output reg [3:0] Q);  
always @ (posedge CLK, negedge RST) 
   begin 
   if (RST) Q = 4'b0; 
   else 
       begin 
           if (LD && !EN ) Q = D; 
           else if (LD && EN) Q = Q - 4'b0001;  
           else Q = Q ; 
       end  
end  
endmodule 

//CMP : 

`timescale 1ns / 1ps
module CMP(

input [3:0] in1, in2, 
output reg out);

always @ (in1, in2)
begin
   if(in1 > in2) out = 1;
   else out = 0;
end   
endmodule

