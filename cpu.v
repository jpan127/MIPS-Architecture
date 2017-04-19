`timescale 1ns / 1ps

module cpu 
(	input 				clock, reset,
	output reg [5:0] 	opcode,
	output reg [4:0] 	op1, op2, op3,
	output reg [4:0]	shifts,
	output reg [5:0]	funct 	);

	/* 32 bit instructions // 16 bit data path */

	// Importing instruction macros
	instructions instr;
	// 32 x 8 registers
	reg [31:0] 	RegFile [7:0];
	// Program Memory
	reg [31:0]  Program [255:0];
	reg [31:0]  instruction;
	reg [7:0]   PC;

	initial begin
		// Load instruction memory (program)
		$readmemb("test.bin", Program);
	end

	always @ (instruction) begin
		// Decode instruction
		{opcode, op1, op2, op3, shifts, funct} = instruction;
	end

	always @ (posedge clock, posedge reset) begin

		if (reset) PC <= 0;

		else begin
			// Fetch instruction
			instruction <= Program[PC];
			// Increment Program Counter
			PC 			<= PC + 4;
		end

	end



endmodule
