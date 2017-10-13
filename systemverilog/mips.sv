`timescale 1ns / 1ps
`include "globals.sv"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    		MIPS Top Level Module										   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module mips 

(	input			clock, reset,
	input 	[31:0]	instruction, rd,
	output 			dmem_we,
	output 	[31:0]	pc, alu_out, dmem_wd 	);

	import global_types::*;

	wire	[5:0] 	opcode, funct;
	wire 	[3:0]	alu_ctrl;
	wire 			zero, sel_alu_b, rf_we;
	wire	[1:0]	sel_pc, sel_result, sel_wa;

	assign opcode = instruction[31:26];
	assign funct  = instruction[5:0];

	ControlBus control_bus();

	control_unit CU 
	(
		.opcode(opcode),
		.funct(funct),
		.zero(zero),
		.control_bus(control_bus.ControlSignals)
	);

	datapath DP 
	(
		.clock(clock),
		.reset(reset),
		.sel_result(sel_result),
		.sel_pc(sel_pc),
		.sel_alu_b(sel_alu_b),
		.sel_wa(sel_wa),
		.rf_we(rf_we),
		.alu_ctrl(alu_ctrl),
		.instruction(instruction),
		.rd(rd),
		.pc(pc),
		.alu_out(alu_out),
		.dmem_wd(dmem_wd),
		.zero(zero)
	);

endmodule

module top

(	input         clock, reset, 
	output [31:0] dmem_wd, alu_out,
	output        dmem_we				);

	wire [31:0] pc, instruction, rd;

	mips MIPS 
	(
		.clock(clock), 
		.reset(reset), 
		.pc(pc), 
		.instruction(instruction), 
		.dmem_we(dmem_we), 
		.alu_out(alu_out), 
		.dmem_wd(dmem_wd), 
		.rd(rd)
	);

	imem IMEM 
	( 
		.a(pc[7:2]), 
		.y(instruction) 
	);
	
	dmem DMEM 
	( 
		.clock(clock), 
		.we(dmem_we), 
		.ra(alu_out[9:0]), 
		.wd(dmem_wd), 
		.rd(rd) 
	);

endmodule