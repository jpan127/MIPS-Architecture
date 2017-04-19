
`ifndef instructions_v
`define instructions_v

	/* 							rs 			= register source
								rt 			= register source 2
								rd 			= register destination
								immediate 	= 16 bit value
								opcode 		= macro value							*/

	`define NOP 	6'd0	// [31		26		21		16		11		6	   0]

	`define ADD 	6'd1 	// |	op 	| 	rs 	| 	rt 	| 	rd 	|	x	|	x 	|		[R]
	`define ADDI	6'd2 	// |	op 	| 	rs 	| 	rt 	| 		immediate		|		[I]

	`define SUB 	6'd3 	// |	op 	| 	rs 	| 	rt 	| 	rd 	|	x	|	x 	|		[R]
	`define SUBI	6'd4	// |	op 	| 	rs 	| 	rt 	| 		immediate		|		[I]

	`define AND 	6'd5 	// |	op 	| 	rs 	| 	rt 	| 	rd 	|	x	|	x 	|		[R]
	`define ANDI 	6'd6 	// |	op 	| 	rs 	| 	rt 	| 		immediate		|		[I]

	`define OR	 	6'd7 	// |	op 	| 	rs 	| 	rt 	| 	rd 	|	x	|	x 	|		[R]
	`define ORI 	6'd8 	// |	op 	| 	rs 	| 	rt 	| 		immediate		|		[I]

	`define INV 	6'd9 	// |	op 	| 	rs 	| 	rt 	| 	rd 	|	x	|	x 	|		[R]
	`define INVI 	6'd10 	// |	op 	| 	rs 	| 	rt 	| 		immediate		|		[I]

	`define XOR 	6'd11 	// |	op 	| 	rs 	| 	rt 	| 	rd 	|	x	|	x 	|		[R]
	`define XORI 	6'd12 	// |	op 	| 	rs 	| 	rt 	| 		immediate		|		[I]

	`define LOAD 	6'd13 	// |	op 	| 	rd 	| 	x	|	x	|  ram address	|		[R]
	`define LOADI 	6'd14 	// |	op 	| 	rd 	| 	 	| 		immediate		|		[I]

	`define STORE 	6'd15 	// |	op 	| 	rs 	| 	x	|	x	|  ram address	|		[R]

	`define SET 	6'd16 	// |	op 	| 	rs 	| 	rt 	| 	rd 	|	x	|	x 	|		[R]
	`define SETI 	6'd17 	// |	op 	| 	rs 	| 	rt 	| 		immediate		|		[I]


`endif