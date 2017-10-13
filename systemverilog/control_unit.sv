`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    		MIPS Control Unit 											   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module control_unit 

(	input		[5:0] 	opcode, funct,
	input 				zero,
	ControlBus			control_bus);

	import global_types::*;
	import control_signals::*;

	// Control signal sets alu_op which then defines alu control, split I-Type vs R-Type
	wire [1:0] 	  alu_op;
	reg  [10:0]	  ctrl;
	alu_ctrl_t	  alu_ctrl;

	///////////////////////////////////////////////////////////////////////////////////////////////

	assign
	{
		control_bus.rf_we,			// 1 bit
		control_bus.sel_wa,			// 2 bits
		control_bus.sel_alu_b,		// 1 bit
		control_bus.dmem_we,		// 1 bit
		control_bus.sel_result,		// 2 bits
		control_bus.sel_pc,			// 2 bits
		alu_op						// 2 bits
	} = ctrl;

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
			2'b00: control_bus.alu_ctrl = ADDIac;
			2'b01: control_bus.alu_ctrl = SUBIac;
			// R-TYPE
			default: 
				case (funct)
					6'b10_0000: control_bus.alu_ctrl = ADDac;
					6'b10_0010: control_bus.alu_ctrl = SUBac;
					6'b10_0100: control_bus.alu_ctrl = ANDac;
					6'b10_0101: control_bus.alu_ctrl = ORac;
					6'b10_1010: control_bus.alu_ctrl = SLTac;
					6'b01_1001: control_bus.alu_ctrl = MULTUac; // funct 19h = 25
					6'b01_1011: control_bus.alu_ctrl = DIVUac; 	// funct 1bh = 27
					6'b01_0000: control_bus.alu_ctrl = MFHIac;	// funct 10h = 16
					6'b01_0010:	control_bus.alu_ctrl = MFLOac;	// funct 12h = 18
					6'b00_1000: control_bus.alu_ctrl = JRac;	// funct 8h
					default:    control_bus.alu_ctrl = DONT_CAREac; 	// ???
				endcase
		endcase
	end

endmodule
