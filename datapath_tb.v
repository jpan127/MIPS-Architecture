`timescale 1ns / 1ps
`include "instructions.v"

module datapath_tb;

	reg 			clock;
	reg 	[31:0]	instruction;
	wire	[31:0]	out;

	datapath DUT_DP (
		.clock(clock), 
		.instruction(instruction),
		.out(out)
	);

	integer i, j, k;

	task toggle; begin clock=0; #5 clock=1; #5; end endtask

	initial begin
		$display("****************************************************************************");

		instruction = 32'b0;
		toggle;

		//				  LOADI  REG[1]				  RAM ADDRESS
		instruction = 32'b001110_00001_00000000000000_00000000;
		toggle;

		//				  LOAD	 REG[1]				  RAM ADDRESS
		instruction = 32'b001101_00001_00000_0000000000000000;
		toggle;


		// for (i=0; i<32; i=i+1) begin
		// 	for (j=0; j<32; j=j+1) begin
		// 		for (k=0; k<3; k=k+1) begin
		// 			opcode = k;
		// 			op1 = i;
		// 			op2 = j;
		// 			toggle;
		// 			$display("out:%b", out);
		// 		end
		// 	end
		// end

		$display("****************************************************************************");
	end
endmodule
