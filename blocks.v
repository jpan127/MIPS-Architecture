`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    MIPS Microarchitecture Building Blocks 								   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


/***********************************************************************************************************
											32x32 Register File
								Hung's has 3rd read port, ommitting that for now
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
		rf[29] = 32'h200; // R[$sp], not sure why
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

module d_reg #(parameter WIDTH=32)

(	input 					clock, reset,
	input  		[WIDTH-1:0] d,
	output  reg [WIDTH-1:0]	q    		);

	always @ (posedge clock, posedge reset) begin
		if (reset)  q <= 0;
		else 		q <= d;
	end
	
endmodule

/***********************************************************************************************************
										Parameterized Enabled Register
***********************************************************************************************************/

module d_en_reg #(parameter WIDTH=32)

(	input 					clock, reset, enable,
	input  		[WIDTH-1:0] d,
	output  reg [WIDTH-1:0]	q    		);

	always @ (posedge clock, posedge reset) begin
		if (reset)  	 q <= 0;
		else if (enable) q <= d;
	end
	
endmodule

/***********************************************************************************************************
												2-to-1 Mux
***********************************************************************************************************/

module mux2 #(parameter WIDTH=32)

(	input 	[WIDTH-1:0] 	a, b,
	input 					sel,
	output 	[WIDTH-1:0]		y    );

	assign y = sel ? b : a;

endmodule

/***********************************************************************************************************
												4-to-1 Mux
***********************************************************************************************************/

module mux4 #(parameter WIDTH=32)

(	input 		[WIDTH-1:0] 	a, b, c, d,
	input 		[1:0]			sel,
	output reg	[WIDTH-1:0]		y    		);

	always @* begin
		case(sel)
			2'b00: y = a;
			2'b01: y = b;
			2'b10: y = c;
			2'b11: y = d;
		endcase
	end
	
endmodule

/***********************************************************************************************************
													ALU
***********************************************************************************************************/

module alu

(	input 				clock, reset,
	input 		[31:0] 	a, b,
	input 		[3:0] 	sel,
	output reg	[31:0]	y,
	output 				zero 	);

	// wire [31:0]	b2, sum, slt;

	// assign b2  = sel[2] ? ~b:b; 
	// assign sum = a + b2 + sel[2];
	// assign slt = sum[31];

	reg  [31:0] d_hi, d_lo;
	wire [31:0] q_hi, q_lo;
	reg enable;

	d_en_reg HI ( .clock(clock), .reset(reset), .enable(enable), .d(d_hi), .q(q_hi) );
	d_en_reg LO ( .clock(clock), .reset(reset), .enable(enable), .d(d_lo), .q(q_lo) );

	always @* begin

		case(sel)
			4'd7: enable = 1;
			4'd8: enable = 1;
			default: enable = 0;
		endcase

		case (sel)
			4'd0: y = a + b;
			4'd1: y = a - b;
			4'd2: y = a + b;
			4'd3: y = a - b;
			4'd4: y = a & b;
			4'd5: y = a | b;
			4'd6: y = (a < b) ? 1 : 0;

			4'd7: {d_hi, d_lo} = a * b;
			4'd8: begin
				d_hi = a / b;
				d_lo = a - (b * d_hi);
			end
			4'd9:  y = q_hi;
			4'd10: y = q_lo;
			4'd11: y = a;		// JR, pass through a
			default: y = 32'dZ;
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