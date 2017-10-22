`timescale 1ns / 1ps

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

	// Internal bus between control unit and datapath
	ControlBus control_bus();
	assign dmem_we = control_bus.ExternalSignals.dmem_we;

	control_unit CU 
	(
		.opcode(opcode),
		.funct(funct),
		.control_bus_external(control_bus.control_bus_external),
		.control_bus_control(control_bus.control_bus_control),
		.control_bus_status(control_bus.control_bus_status)
	);

	datapath DP 
	(
		.clock(clock),
		.reset(reset),
		.instruction(instruction),
		.rd(rd),
		.pc(pc),
		.alu_out(alu_out),
		.dmem_wd(dmem_wd),
		.control_bus_control(control_bus.control_bus_control),
		.control_bus_status(control_bus.control_bus_status)
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
		.addr(pc[11:2]),		// 10 bits for 1024 spots
		.data(instruction) 
	);
	
	dmem DMEM 
	( 
		.clock(clock), 
		.we(dmem_we), 
		.addr(alu_out[9:0]), 
		.wd(dmem_wd), 
		.rd(rd) 
	);

endmodule