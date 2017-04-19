`timescale 1ns / 1ps
`include "instructions.v"

module datapath
(	input 			clock,
	input [31:0]	instruction,
	output[31:0]	dp_out 	);

	/* Instruction Splitting */
		reg [5:0]	opcode;
		reg [4:0]	op1, op2, op3;
		reg [4:0]	shifts;
		reg [5:0]	funct;
		reg [15:0]	immediate;		
	/* Register File Ports */
		reg 			WE, RE0, RE1;
		reg  [4:0] 		WA, RA0, RA1;
		reg  [31:0] 	WD;
		wire [31:0] 	RD0, RD1;
	/* Data Memory Ports */
		reg 			DM_WNR;
		reg  [7:0]		DM_address;
	/* Mux Ports : Input from RF and Immediate value : Output to ALU */
		reg 			mux2sel;
		wire [31:0]		mux2out;
	/* ALU Ports */
		reg [3:0] 		ALUSEL;
		reg [31:0] 		ALUOUT;
		assign WD 		= ALUOUT;
		assign dp_out 	= ALUOUT;

	/* Decoding Instruction */
		always @ (instruction) begin
			opcode 		= instruction[31:26];
			op1			= instruction[25:21];
			op2			= instruction[20:16];
			op3			= instruction[15:11];
			shifts		= instruction[10:6];
			funct		= instruction[5:0];
			immediate 	= instruction[15:0];
			DM_address	= instruction[7:0];
		end

	/* Datapath Module Hierarchy */

		regfile RF (
			.clock(clock),
			.WE(WE), .RE0(RE0), .RE1(RE1),
			.WA(WA), .RA0(RA0), .RA1(RA1),
			.WD(WD),
			.RD0(RD0), .RD1(RD1)
		);

		data_memory DM (
			.WNR(DM_WNR),
			.address(DM_address),
			.in(ALUOUT),
			.out(WD)
		);

		mux2 MUX2 (
			.in0(RD1), .in1(immediate),
			.sel(mux2sel), .out(mux2out)
		);

		alu ALU (
			.in1(RD0), .in2(mux2out),
			.sel(ALUSEL), .out(ALUOUT)
		);



	reg [22:0] CTRL;
	always @* begin

		CTRL = 26'b0;

		case(opcode)
			//					<	enables		>	<rs 	rt 		rd>		<alusel mux2sel>
			//										<RA0 	RA1 	WA>
			`NOP: 		CTRL = 26'b0;
			`ADD: 		CTRL = {1'b1, 1'b1, 1'b1, 	op1, 	op2, 	op3, 	4'd0,	1'b0, 1'b0};
			`ADDI:		CTRL = {1'b1, 1'b1, 1'b0, 	op1, 	5'b0, 	op2, 	4'd0,	1'b1, 1'b0};
			`LOAD: 		CTRL = {1'b1, 1'b0, 1'b0,	5'b0,	5'b0,	op1,	4'd0,	1'b0, 1'b0};
			`LOADI:		CTRL = {1'b1, 1'b1, 1'b0,	5'b0,	5'b0,	op1,	4'd3,	1'b1, 1'b0}; // load immediate, load Reg[0], alu OR them
			`STORE:		CTRL = {1'b0, 1'b1, 1'b1,	op1,	op1,	5'b0,	4'd2,	1'b0, 1'b1}; // load Reg[op1], alu AND itself
			default: 	CTRL = 26'b0;
		endcase

	end

	always @ (CTRL) begin
		// 1, 1,	1,   5,   5,  5,	  4,	   1	  1
		{WE, RE0, RE1, RA0, RA1, WA, ALUSEL, MUX2SEL, DM_WNR} = CTRL;
	end



endmodule
