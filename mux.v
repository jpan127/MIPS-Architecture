`timescale 1ns / 1ps

module mux2 #(parameter WIDTH=32)
(	input 		[WIDTH-1:0] 	in0, in1,
	input 						sel,
	output reg 	[WIDTH-1:0]		out    );

	always @* begin
		out = sel ? in0 : in1;
	end

endmodule





module mux4 #(parameter WIDTH=32)
(	input 		[WIDTH-1:0] 	in0, in1, in2, in3,
	input 		[1:0]			sel,
	output reg	[WIDTH-1:0]		out    );

	always @* begin
		case(sel)
			0: out = in0;
			1: out = in1;
			2: out = in2;
			3: out = in3;
		endcase
	end
	
endmodule