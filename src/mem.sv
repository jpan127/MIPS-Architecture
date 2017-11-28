`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  MIPS Instruction Memory & Data Memory                                  //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


/// Instruction Memory
module imem 

(   input   [9:0]   addr,
    output  [31:0]  data   );
    
    // 32 x 1024
    reg [31:0] rom [1023:0];
    integer    i;

    // Initialize
    initial begin
        for (i=0; i<1024; i++) begin 
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
    
    // 32 x 512
    reg [31:0] ram [511:0];
    integer i;
    
    // Initialize to 0
    initial begin
        for (i=0; i<512; i=i+1) begin
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

