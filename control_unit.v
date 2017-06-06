`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    		MIPS Control Unit 											   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module control_unit 

(	input		[5:0] 	opcode, funct,
	input 				zero,
	output				dmem_we, sel_alu_b, rf_we,
	output 		[1:0]	sel_pc, sel_result, sel_wa,
	output 	reg [3:0]	alu_ctrl					);

	wire [1:0] 	alu_op;

	/***************************************** Main Decoder: sets control signals ****************************************/

	reg  [10:0]  ctrl;
	assign {rf_we, sel_wa, sel_alu_b,/**/ dmem_we, /**/ sel_result, /**/ sel_pc, /**/ alu_op} = ctrl;
	/* R-TYPE sel_wa chooses 1 because R[rd] is in [15:11] */
	/* sel_pc: 00=pc+4, 01=branch, 10=jump, 11=result */

	always @* begin
		case (opcode)

			/* I-TYPE */
			6'b10_0011: ctrl = 11'b1_00_1_0_00_00_00; 	// LW	// mem[rs + sign_imm] -> write to RF
			6'b10_1011: ctrl = 11'b0_00_1_1_01_00_00; 	// SW	// R[rt] -> mem[rs + sign_imm]
			6'b00_0100: ctrl = (zero) ? 11'b0_00_0_0_01_01_01 : 11'b0_00_0_0_01_00_01; 	
														// BEQ	// if zero, branch, alu sub to get zero flag
			6'b00_1000: ctrl = 11'b1_00_1_0_01_00_00; 	// ADDI	// add with sign_imm -> write to RF

			/* J-TYPE */
			6'b00_0010: ctrl = 11'b0_00_0_0_01_10_00; 	// J 	// PC = Jump
			6'b00_0011: ctrl = 11'b1_10_0_0_10_10_00; 	// JAL	// R[31] = PC+4, PC = Jump
			
			/* R-TYPE */
			6'b00_0000: begin
				case (funct)
					6'b00_1000: ctrl = 11'b0_00_0_0_01_11_10;	// JR	// PC = R[rs]
																// JR will read from rd0, pass through ALU, and go to MUX_PC
					default:	ctrl = 11'b1_01_0_0_01_00_10; 	// Rtype
				endcase
			end
			
			default:    ctrl = 11'bx;
		endcase
	end

	/******************************* ALU Decoder: Takes alu_op and funct and sets alu_ctrl *******************************/

	always @* begin
		case (alu_op)

			/* I-TYPE */
			2'b00: alu_ctrl = 4'd0;  				// ADDI
			2'b01: alu_ctrl = 4'd1;  				// SUB

			/* R TYPE: LOOKS AT FUNCT NOT OPCODE */
			default: 
				case (funct)
					6'b10_0000: alu_ctrl = 4'd2; 	// ADD
					6'b10_0010: alu_ctrl = 4'd3; 	// SUB
					6'b10_0100: alu_ctrl = 4'd4; 	// AND
					6'b10_0101: alu_ctrl = 4'd5; 	// OR
					6'b10_1010: alu_ctrl = 4'd6; 	// SLT


					6'b01_1001: alu_ctrl = 4'd7; 	// MULTU	funct 19h = 25
					6'b01_1011: alu_ctrl = 4'd8; 	// DIVU		funct 1bh = 27
					6'b01_0000: alu_ctrl = 4'd9;	// MFHI		funct 10h = 16
					6'b01_0010:	alu_ctrl = 4'd10;	// MFLO		funct 12h = 18

					6'b00_1000: alu_ctrl = 4'd11;	// JR		funct 8h

					default:    alu_ctrl = 4'dx; 	// ???
				endcase
		endcase
	end

endmodule
