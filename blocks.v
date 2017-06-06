`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    MIPS Microarchitecture Building Blocks 								   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


/***********************************************************************************************************
											32x32 Register File
***********************************************************************************************************/
module regfile

(	input 			clock,
	input 			we,
	input  	[4:0] 	wa, ra0, ra1,
	input  	[31:0] 	wd,
	output 	[31:0] 	rd0, rd1		);

	reg [31:0] rf [31:0];

	integer i;
	initial begin
		for (i=0; i<32; i=i+1) begin
			rf[i] = 0;
		end
	end

	always @ (posedge clock) begin
		if (we) rf[wa] <= wd;
	end

	assign rd0 = (ra0 == 0) ? 0 : rf[ra0];
	assign rd1 = (ra1 == 0) ? 0 : rf[ra1];

endmodule

/***********************************************************************************************************
										Parameterized No-Enable Register
***********************************************************************************************************/

module d_reg #(parameter WIDTH=8)

(	input 					clock, reset,
	input  		[WIDTH-1:0] d
	output  reg [WIDTH-1:0]	q    		);

	always @ (posedge clock, posedge reset) begin
		if (reset)  q <= 0;
		else 		q <= d;
	end
	
endmodule

/***********************************************************************************************************
												2-to-1 Mux
***********************************************************************************************************/

module mux2 #(parameter WIDTH=32)

(	input 	[WIDTH-1:0] 	a, b,
	input 					sel,
	output 	[WIDTH-1:0]		y    );

	assign y = sel ? a : b;

endmodule

/***********************************************************************************************************
												4-to-1 Mux
***********************************************************************************************************/

module mux4 #(parameter WIDTH=32)

(	input 		[WIDTH-1:0] 	a, b, c, d,
	input 		[1:0]			sel,
	output reg	[WIDTH-1:0]		y    				);

	always @* begin
		case(sel)
			0: y = a;
			1: y = b;
			2: y = c;
			3: y = d;
		endcase
	end
	
endmodule

/***********************************************************************************************************
													ALU
								Operations: ADD, SUB, AND, OR, XOR, NAND, NOR
												Need to change
***********************************************************************************************************/

module alu

(	input 		[31:0] 	a, b,
	input 		[2:0] 	sel,
	output reg	[31:0]	y
	output 				zero 	);

	wire [31:0]	b2, sum, slt;

	assign b2 = sel[2] ? ~b:b; 
	assign sum = a + b2 + sel[2];		// this basically says if sel[2] then a-b otherwise a+b
	assign slt = sum[31];				// but why not just do sum = sel[2] ? a-b : a+b; 

	always @* begin
		case(sel[1:0])
			2'b00: y = a & b;
			2'b01: y = a | b;
			2'b10: y = sum;
			2'b11: y = slt;
		endcase
	end

	assign zero = (y==0) ? 1 : 0;

endmodule

/***********************************************************************************************************
												Sign Extender
***********************************************************************************************************/

module sign_extend

(	input  [15:0]	a,
	output [31:0]	y    );

	assign y = { {16{a[15]}}, a };
	
endmodule

/***********************************************************************************************************
													Adder
***********************************************************************************************************/

module adder

(	input  [31:0] 	a, b,
	output [31:0]	y    	);

	assign y = a + b;
	
endmodule

/***********************************************************************************************************
											Two-Bit Left Shifter
***********************************************************************************************************/

module sl2

(	input  [31:0] 	a,
	output [31:0]	y    	);

	assign y = {a[29:0], 2'b00};
	
endmodule