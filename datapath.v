`timescale 1ns / 1ps
`include "instructions.v"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    			MIPS Datapath 											   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module datapath

(	input 			clock, reset, mem_to_reg, pc_src, alu_src, reg_dst, reg_write, jump,
	input	[2:0]	alu_control,
	input	[31:0]	instruction,
	input	[31:0]	rd,
	input	[4:0]	disp_sel // ?
	output	[31:0]	pc, alu_out, wd, disp_dat // ?
	output			zero																	);

	wire 	[4:0]	write_reg;
	wire 	[31:0]	pc_next, pc_next_br, pc_plus4, pc_branch, sign_imm, sign_imm_sh, src_a, src_b, result;

endmodule