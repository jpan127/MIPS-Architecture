`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    		MIPS Control Unit 											   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module control_unit 

(	input	[5:0] 	opcode, funct
	input 			zero,
	output			mem_to_reg, mem_write, pc_src, alu_src, reg_dst, reg_write, jump,
	output 	[3:0]	alu_control															);

	wire [1:0] 	alu_op;
	wire 		branch;

	/* Main Decoder: sets control signals */

	reg  [8:0]  ctrl;
	assign {reg_write, reg_dst, alu_src, branch, mem_write, mem_to_reg, jump, alu_op} = ctrl;

	always @* begin
		case (opcode)
			6'b000000: ctrl = 9'b110000010; 	//Rtype
			6'b100011: ctrl = 9'b101001000; 	//LW
			6'b101011: ctrl = 9'b001010000; 	//SW
			6'b000100: ctrl = 9'b000100001; 	//BEQ
			6'b001000: ctrl = 9'b101000000; 	//ADDI
			6'b000010: ctrl = 9'b000000100; 	//J
			default:   ctrl = 9'bxxxxxxxxx; 	//???
		endcase
	end

	/* ALU Decoder: Takes alu_op and funct and sets alu_control */

	always @* begin
		case (alu_op)
			2'b00: alu_control = 3'b010;  			// add
			2'b01: alu_control = 3'b110;  			// sub
			default: case(funct)          			// RTYPE
				6'b100000: alu_control = 3'b010; 	// ADD
				6'b100010: alu_control = 3'b110; 	// SUB
				6'b100100: alu_control = 3'b000; 	// AND
				6'b100101: alu_control = 3'b001; 	// OR
				6'b101010: alu_control = 3'b111; 	// SLT
				default:   alu_control = 3'bxxx; 	// ???
			endcase
		endcase
	end

	assign pc_src = branch & zero;

endmodule
