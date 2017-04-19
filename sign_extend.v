`timescale 1ns / 1ps


module sign_extend #(parameter WIDTH_IN=16, WIDTH_OUT=32)
(	input 		[WIDTH_IN-1:0] 		IN,
	input 							sign,
	output reg 	[WIDTH_OUT-1:0] 	OUT    );

	always @* begin
		OUT = { {(WIDTH_OUT-WIDTH_IN){sign}}, IN };
	end
	
endmodule
