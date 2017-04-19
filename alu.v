`timescale 1ns / 1ps

module alu #(parameter WIDTH=32)
(	input 		[WIDTH-1:0] 	in1, in2,
	input 		[3:0] 			sel,
	output reg	[WIDTH-1:0]		out 	);

	always @* begin
		case(sel)
			0: out = in1+in2;										// ADD
			1: out = in1-in2;										// SUB
			2: out = in1&in2;										// AND
			3: out = in1|in2;										// OR
			4: out = in1^in2;										// XOR
			5: out = ~(in1&in2);									// NAND
			6: out = ~(in1|in2);									// NOR
			7: out = (in1 < in2) ? in1 : in2;						// Output smallest
			8: out = ($signed(in1) < $signed(in2)) ? in1 : in2;		// Output smallest, signed
			default: out = 'bZ;
		endcase
	end

endmodule