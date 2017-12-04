`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  MIPS Instruction Memory & Data Memory                                  //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


/// Instruction Memory
module imem 

(   input   [5:0]   addr,
    output  [31:0]  data   );
    
    // 32 x 64
    reg [31:0] rom [63:0];
    integer    i;

    // Initialize
    initial begin
        for (i=0; i<64; i++) begin 
            rom[i] = 0;
        end
        $readmemh("memfile_hazards.dat", rom);
    end
    
    // Read
    assign data = rom[addr];

endmodule

/// Data Memory
module dmem 

(   input           clock, we,
    input   [8:0]   addr, 
    input   [31:0]  wd,
    output  [31:0]  rd          );
    
    // 32 x 4096
    reg [31:0] ram [4095:0];
    integer i;
    
    // Initialize to 0
    initial begin
        for (i=0; i<4096; i=i+1) begin
            ram[i] = 32'b0;
        end
    end

    // Write
    always_ff @(posedge clock) begin
        if (we) ram[addr] <= wd;
    end

    // Read
    assign rd = ram[addr];

endmodule

