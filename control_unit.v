`timescale 1ns / 1ps
// `include "instructions.v"

module control_unit #(parameter WIDTH=16, DEPTH=8)
(	input 						clock, reset, go,
	input 	[3:0] 				opcode,
	output 						WE, RE1, RE2,
	output 	[$clog2(DEPTH)-1:0] WA, RA1, RA2,
	output  [1:0]				SEL1, SEL2,
	output	[2:0]				state			);

	localparam 	ctrl_bits = 3 + 3*($clog2(DEPTH)) + 4;
	localparam 	IDLE		= 4'd0,
				LOAD1		= 4'd1,
				LOAD2		= 4'd2;


	reg [2:0] 			next_state;
	reg [ctrl_bits-1:0] ctrl;



	always @ (posedge clock, posedge reset) begin
		if (reset)  state <= IDLE;
		else 		state <= next_state;
	end

	always @ (state) begin
		next_state = state;
		case (state)
			IDLE: 		if (go) state = ADD;
			default: 	state = IDLE;
		endcase
	end

	always @ (state) begin
		ctrl = 0;
		case (state)
			default: ctrl = 0;
		endcase
	end

	always @ (ctrl) begin
		{WE, RE1, RE2, WA, RA1, RA2, SEL1, SEL2} = ctrl;
	end

endmodule
