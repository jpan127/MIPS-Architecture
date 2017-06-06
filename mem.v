`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//								    MIPS Instruction Memory & Data Memory								   //
//											Author: Jonathan Pan										   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


/***********************************************************************************************************
											Instruction Memory
***********************************************************************************************************/

module imem 

(	input	[5:0]	a,
	output 	[31:0]	y 	);
	
	reg	[31:0] rom [63:0];
	
	initial begin
		$readmemh("memfile.dat", rom);
	end
	
    assign y = rom[a];

endmodule

/***********************************************************************************************************
												Data Memory
***********************************************************************************************************/

module dmem 

(	input			clock, we,
	input	[31:0]	ra, wd,
	output 	[31:0]	rd 			);
	
	reg	[31:0] ram [63:0];
	integer	i;
	
	// initial begin
	// 	for (i=0; i<64; i=i+1) begin
	// 		ram[i] = 8'hFF;
	// 	end
	// end
				
	always @(posedge clock) begin
		if (we) begin
			ram[ra[31:2]] = wd;
		end
	end

	assign rd = ram[ra[31:2]];

endmodule

