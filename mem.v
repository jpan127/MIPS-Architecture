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
		$readmemh("lab7_memfile.dat", rom);
	end
	
    assign y = rom[a];

endmodule

/***********************************************************************************************************
												Data Memory
***********************************************************************************************************/

module dmem 

(	input			clock, we,
	input	[9:0]	ra, 
	input	[31:0]	wd,
	output 	[31:0]	rd 			);
	
	reg	[31:0] ram [1023:0];
	integer	i;
	
	initial begin
		for (i=0; i<1024; i=i+1) begin
			ram[i] = 32'b0;
		end
	end
				
	always @(posedge clock) begin
		if (we) begin
			ram[ra] <= wd;
		end
	end

	assign rd = ram[ra];

endmodule

