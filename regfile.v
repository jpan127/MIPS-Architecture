`timescale 1ns / 1ps

module regfile #(parameter WIDTH=32, DEPTH=32)
(	input 								clock,
	input 								WE, RE0, RE1,
	input  		[$clog2(DEPTH)-1:0] 	WA, RA0, RA1,
	input  		[WIDTH-1:0] 			WD,
	output reg 	[WIDTH-1:0] 			RD0, RD1		);

	localparam [WIDTH-1:0] ZERO = {WIDTH{1'b0}};

	reg [WIDTH-1:0] RAM [DEPTH-1:0];

	always @ (posedge clock) begin

		if (WE) RAM[WA] <= WD;
		
	end

	always @* begin
		if (RE0) RD0 = (RA0 == 0) ? ZERO : RAM[RA0];
		if (RE1) RD1 = (RA1 == 0) ? ZERO : RAM[RA1];
	end

endmodule