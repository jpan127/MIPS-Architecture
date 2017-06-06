`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    		MIPS Control Unit 											   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module control_unit 

(	input		[5:0] 	opcode, funct,
	input 				zero,
	output				sel_result, dmem_we, sel_pc, sel_alu_b, sel_wa, rf_we, sel_jump,
	output 	reg [2:0]	alu_ctrl														);

	wire [1:0] 	alu_op;
	wire 		branch;

	/* Main Decoder: sets control signals */

	reg  [8:0]  ctrl;
	assign {rf_we, sel_wa, sel_alu_b, branch, dmem_we, sel_result, sel_jump, alu_op} = ctrl;

	always @* begin
		case (opcode)
			6'b000_000: ctrl = 9'b110_000_010; 	// Rtype 	opcode 0h
			6'b100_011: ctrl = 9'b101_001_000; 	// LW 		opcode 23h
			6'b101_011: ctrl = 9'b001_010_000; 	// SW 		opcode 2bh
			6'b000_100: ctrl = 9'b000_100_001; 	// BEQ 		opcode 4h
			6'b001_000: ctrl = 9'b101_000_000; 	// ADDI		opcode 8h
			6'b000_010: ctrl = 9'b000_000_100; 	// J 		opcode 2h
			// add more?
			default:    ctrl = 9'bxxx_xxx_xxx; 	// ???		uninitialized opcode
		endcase
	end

	/* ALU Decoder: Takes alu_op and funct and sets alu_ctrl */

	always @* begin
		case (alu_op)
			2'b00: alu_ctrl = 3'b010;  				// add
			2'b01: alu_ctrl = 3'b110;  				// sub
			default: 
				case (funct)          				// RTYPE
					6'b100000: alu_ctrl = 3'b010; 	// ADD
					6'b100010: alu_ctrl = 3'b110; 	// SUB
					6'b100100: alu_ctrl = 3'b000; 	// AND
					6'b100101: alu_ctrl = 3'b001; 	// OR
					6'b101010: alu_ctrl = 3'b111; 	// SLT
					// add more?
					default:   alu_ctrl = 3'bxxx; 	// ???
				endcase
		endcase
	end

	assign sel_pc = branch & zero;

endmodule
