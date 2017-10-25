`timescale 1ns / 1ps

// [MACRO] Wait an entire clock cycle
`define tick            #10;
// [MACRO] Reset on, clock, reset off
`define reset_system    reset = 1; #10 reset = 0;

module tb_mips;

    // Packages
    import testbench_globals::*;
    import global_types::*;

    // DUT ports
    logic   clock, reset;
    logic32 instruction, dmem_rd;
    logic   dmem_we;
    logic32 pc, alu_out, dmem_wd;

    // Device Under Testing
    mips DUT(.*);

    // Initial state
    initial begin 
        clock       = 0;
        reset       = 0;
        instruction = 0;
        dmem_rd     = 0;
    end

    // Generate a #10 period clock
    always #5 clock = ~clock;


endmodule