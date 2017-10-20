`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    			MIPS Datapath 											   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


module datapath

(	input 			clock, reset,
	input	[31:0]	instruction,
	input	[31:0]	rd,
	output	[31:0]	pc, alu_out, dmem_wd,
	ControlBus.ControlSignals control_bus_control,
	ControlBus.StatusSignals control_bus_status		);

	import global_types::*;
	import global_functions::*;

	wire 	[4:0]	wa, ra0, ra1, wa0, wa1;
	wire 	[15:0]	sign;
	wire 	[31:0]	pc_next, pc_next_br, pc_plus4, pc_branch, sign_imm, sign_imm_sh, alu_a, alu_b, result;
	wire 	[31:0]	jump_addr;

	assign ra0  = instruction[25:21];
	assign ra1  = instruction[20:16];
	assign wa0  = instruction[20:16];
	assign wa1  = instruction[15:11];
	assign sign = instruction[15:0];
	// mips instructions always have lower 2 bits zero, word aligned
	assign jump_addr = { pc_plus4[31:28], instruction[25:0], 2'b00 };

	///////////////////////////////////////////////////////////////////////////////////////////////
	// REGFILE LOGIC BLOCKS

	regfile RF 	
	( 
		.clock(clock), 
		.we(rf_we), 
		.wa(wa), 
		.ra0(ra0), 
		.ra1(ra1), 
		.wd(result), 
		.rd0(alu_a), 
		.rd1(dmem_wd)
	);

	assign sign_imm = sign_extend(sign);

	// sign_extend S_EXT 
	// ( 
	// 	.a(sign), 
	// 	.y(sign_imm) 
	// );

	// chooses which is the write address
	mux4 #(5) MUX_WA	
	( 
		.a(wa0), 
		.b(wa1), 
		.c(REG_RA), 
		.d(REG_ZERO), 
		.sel(sel_wa), 
		.y(wa)
	);

	mux4 #(32) MUX_RESULT
	( 
		.a(rd), 
		.b(alu_out), 
		.c(pc_plus4), 
		.d(ZERO32), 
		.sel(sel_result), 
		.y(result) 
	);

	///////////////////////////////////////////////////////////////////////////////////////////////
	// PC LOGIC BLOCKS

	d_reg PC
	( 
		.clock(clock), 
		.reset(reset), 
		.d(pc_next), 
		.q(pc)
	);

	assign sign_imm_sh = shift_left_2(sign_imm);

	// sl2 SL_2
	// ( 
	// 	.a(sign_imm), 
	// 	.y(sign_imm_sh)
	// );

	assign pc_plus4 = add(pc, 32'h256);

	// adder ADD_4
	// ( 
	// 	.a(pc), 
	// 	.b(32'b100),	// Forgot why...256
	// 	.y(pc_plus4)
	// );

	assign pc_branch = add(pc_plus4, sign_imm_sh);

	// adder ADD_BRANCH
	// ( 
	// 	.a(pc_plus4), 
	// 	.b(sign_imm_sh), 
	// 	.y(pc_branch)
	// );
	
	mux4 #(32) MUX_PC
	( 
		.a(pc_plus4), 
		.b(pc_branch), 
		.c(jump_addr), 
		.d(result), 
		.sel(sel_pc), 
		.y(pc_next)
	);

	///////////////////////////////////////////////////////////////////////////////////////////////
	// ALU LOGIC BLOCKS

	alu ALU
	( 
		.clock(clock), 
		.reset(reset), 
		.a(alu_a), 
		.b(alu_b), 
		.sel(alu_ctrl), 
		.y(alu_out), 
		.zero(zero)
	);

	// Chooses which signal goes to the ALU port B : RF read port 2 or sign immediate output
	mux2 MUX_ALU_B
	( 
		.a(dmem_wd), 
		.b(sign_imm), 
		.sel(sel_alu_b), 
		.y(alu_b) 
	);

endmodule

/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									Ports Explanation (NEEDS TO BE UPDATED)

sel_result: 	mux select to choose whether the ALU output or the dmem output goes back to RF
sel_pc: 		mux select to choose whether pc+4 or pc+branch goes back to the PC register
sel_alu_b: 		mux select to choose whether rd2 or sign_imm goes into port2(src_b) of the ALU
sel_wa: 		mux select to choose whether instruction[20:16] or instruction[15:11] is the write register address
				depending on instruction type the end register could be in either position
rf_we: 			write enable for register file
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
result:			data to be written back to RF
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
