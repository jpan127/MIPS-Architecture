`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    			MIPS Datapath 											   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


module datapath

(	input 			clock, reset,
	input 			sel_result, sel_pc, sel_alu_b, sel_wa, we, sel_jump,
	input	[2:0]	alu_ctrl,
	input	[31:0]	instruction,
	input	[31:0]	rd,
	input	[4:0]	disp_sel,
	output	[31:0]	pc, alu_out, dmem_wd, disp_dat,
	output			zero												);

	wire 	[4:0]	wa, ra0, ra1, wa0, wa1;
	wire 	[31:0]	pc_next, pc_next_br, pc_plus4, pc_branch, sign, sign_imm, sign_imm_sh, alu_a, alu_b, rf_wd;

	assign ra0  = instruction[25:21];
	assign ra1  = instruction[20:16];
	assign wa0  = instruction[20:16];
	assign wa1  = instruction[15:11];
	assign sign = instruction[15:0];

	wire 	[31:0]	jump_addr;
	assign jump_addr = {pc_plus4[31:28], instruction[25:0], 2'b00};

	/* REGFILE LOGIC BLOCKS */

	regfile 	RF 			( .clock(clock), .we(we), .wa(wa), .ra0(ra0), .ra1(ra1), .wd(rf_wd), .rd0(alu_a), .rd1(dmem_wd) );
	sign_extend S_EXT 		( .a(sign), .y(sign_imm) );
	mux2 		MUX_WA 		( .a(wa0), .b(wa1), .sel(sel_wa), .y(wa) ); // chooses which is the write address
	mux2 		MUX_ALU_B 	( .a(dmem_wd), .b(sign_imm), .sel(sel_alu_b), .y(alu_b) ); // chooses which is alu_b


	/* PC LOGIC BLOCKS */

	d_reg 		PC  		( .clock(clock), .reset(reset), .d(pc_next), .q(pc) );
	sl2 		SL2 		( .a(sign_imm), .y(sign_imm_sh) ); 						// why is it called sign_imm?
	adder 		ADD4 		( .a(pc), .b(32'd4), .y(pc_plus4) );
	adder 		ADD_BRANCH	( .a(pc_plus4), .b(sign_imm_sh), .y(pc_branch) 	);
	mux2 		MUX_PC 		( .a(pc_plus4), .b(pc_branch), .sel(sel_pc), .y(pc_next_br) ); // chooses branch or pc+4
	mux2 		MUX_PC 		( .a(pc_next_br), .b(jump_addr), .sel(sel_jump), .y(pc_next) ); // choose branch or jump

	/* ALU LOGIC BLOCKS */

	alu 		ALU 		( .a(alu_a), .b(alu_b), .sel(alu_ctrl), .y(alu_out), .zero(zero) );
	mux2 		MUX_RESULT	( .a(alu_out), .b(rd), .sel(sel_result), .y(rf_wd) ); // chooses alu or dmem to rf_wd

endmodule

/***********************************************************************************************************
												Ports Explanation

sel_result: 	mux select to choose whether the ALU output or the dmem output goes back to RF
sel_pc: 		mux select to choose whether pc+4 or pc+branch goes back to the PC register
sel_alu_b: 		mux select to choose whether rd2 or sign_imm goes into port2(src_b) of the ALU
sel_wa: 		mux select to choose whether instruction[20:16] or instruction[15:11] is the write register address
				depending on instruction type the end register could be in either position
we: 			write enable for register file
sel_jump: 		mux select to choose whether pc jumps or branches
alu_ctrl:		control signal for the ALU
instruction:	output from the imem, gets decoded and goes into the CU, RF, and sign_extend
rd:				wire from dmem output to mux to RF
disp_sel:		display select for the RF for debugging

pc:				program counter
alu_out:		wire from ALU output
dmem_wd:		data to be written from RF to dmem
disp_dat:		display data from the RF for debugging

zero:			zero flag from the ALU
write_reg:		write register address, mux output (sel_wa?)
pc_next:		actual next pc
pc_next_br:		next branch pc address (either branch or +4)
pc_plus4:		pc+4 address
pc_branch:		pc branch address --> pc_next_br
sign_imm:		sign extend instruction[15:0]
sign_imm_sh:	sign_imm shift left by 2
alu_a:			ALU port 1
alu_b:			ALU port 2
rf_wd:			data to be written back to RF
***********************************************************************************************************/
