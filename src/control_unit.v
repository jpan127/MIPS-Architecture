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

	// Control signal sets alu_op which then defines alu control, split I-Type vs R-Type
	wire [1:0] 	alu_op;

	///////////////////////////////////////////////////////////////////////////////////////////////
	// Main Decoder: sets control signals

	reg  [10:0]  ctrl;
	assign
	{
		rf_we,			// 1 bit
		sel_wa,			// 2 bits
		sel_alu_b,		// 1 bit
		dmem_we,		// 1 bit
		sel_result,		// 2 bits
		sel_pc,			// 2 bits
		alu_op			// 2 bits
	} = ctrl;

	// R-TYPE sel_wa chooses 1 because R[rd] is in [15:11]
	// sel_wa: 		00=wa0, 	01=wa1, 	10=5'd31, 		11=5'd0
	// sel_pc: 		00=pc+4, 	01=branch, 	10=jump, 		11=result
	// sel_result: 	00=rd, 		01=alu_out, 10=pc_plus4,	11=32'd0

	// Control signals
	localparam 	LWc 	= 11'b1_00_1_0_00_00_00, 	// I-Type	// mem[rs + sign_imm] -> write to RF
				SWc 	= 11'b0_00_1_1_01_00_00, 	// I-Type	// R[rt] -> mem[rs + sign_imm]
				ADDIc 	= 11'b1_00_1_0_01_00_00, 	// I-Type	// add with sign_imm -> write to RF
				Jc 		= 11'b0_00_0_0_01_10_00, 	// I-Type	// PC = Jump
				JALc 	= 11'b1_10_0_0_10_10_00, 	// I-Type	// R[31] = PC+4, PC = Jump
				// BEQ functions asks the ALU to subtract the two numbers
				BEQYc	= 11'b0_00_0_0_01_01_01,	// I-Type	// Branch if equal -> YES equal
				BEQNc 	= 11'b0_00_0_0_01_00_01,	// I-Type	// Branch if equal -> NOT equal
				// JR will read from rd0, pass through ALU, and go to MUX_PC
				JRc 	= 11'b0_00_0_0_01_11_10,	// R-Type	// PC = R[rs]
				Rc 		= 11'b1_01_0_0_01_00_10; 	// R-Type

	// ALU control signals
	localparam 	ADDIac	= 4'd0,
				SUBIac	= 4'd1,
				ADDac	= 4'd2,
				SUBac	= 4'd3,
				ANDac	= 4'd4,
				ORac	= 4'd5,
				SLTac	= 4'd6,
				MULTUac	= 4'd7,
				DIVUac	= 4'd8,
				MFHIac	= 4'd9,
				MFLOac	= 4'd10,
				JRac	= 4'd11;

	always @* begin
		case (opcode)
			// I-TYPE
			6'b10_0011: ctrl = LWc;
			6'b10_1011: ctrl = SWc;
			6'b00_0100: ctrl = (zero) ? BEQYc : BEQNc;
			6'b00_1000: ctrl = ADDIc;
			// J-TYPE
			6'b00_0010: ctrl = Jc;
			6'b00_0011: ctrl = JALc;
			// R-TYPE
			6'b00_0000: ctrl = (funct == 6'b00_1000) ? (JRc) : (Rc);
			// Not **YET** defined instructions
			default:    ctrl = 11'bx;
		endcase
	end

	// ALU Decoder: Takes alu_op and funct and sets alu_ctrl
	always @* begin
		case (alu_op)
			// I-TYPE
			2'b00: alu_ctrl = ADDIac;
			2'b01: alu_ctrl = SUBIac;
			// R-TYPE
			default: 
				case (funct)
					6'b10_0000: alu_ctrl = ADDac;
					6'b10_0010: alu_ctrl = SUBac;
					6'b10_0100: alu_ctrl = ANDac;
					6'b10_0101: alu_ctrl = ORac;
					6'b10_1010: alu_ctrl = SLTac;
					6'b01_1001: alu_ctrl = MULTUac; // funct 19h = 25
					6'b01_1011: alu_ctrl = DIVUac; 	// funct 1bh = 27
					6'b01_0000: alu_ctrl = MFHIac;	// funct 10h = 16
					6'b01_0010:	alu_ctrl = MFLOac;	// funct 12h = 18
					6'b00_1000: alu_ctrl = JRac;	// funct 8h
					default:    alu_ctrl = 4'dx; 	// ???
				endcase
		endcase
	end

endmodule
