`timescale 1ns / 1ps


module data_memory #(parameter WIDTH=32)
(	input						WNR,
	input		[7:0] 			address,
	input		[WIDTH-1:0]		in,
	output reg	[WIDTH-1:0] 	out    );

	reg [WIDTH-1:0] MEM [255:0];
	integer i;

	/* Initialize */
		initial begin
			for (i=0; i<256; i=i+1) begin
				MEM[i] = 0;
			end
		end

	/* Write */
		always @* begin
			if (WNR) MEM[address] = in;
			else 	 out 	 = MEM[address];
		end
	
endmodule
