`timescale 1ns / 1ps
// `include "globals.svh"

module tb_control_unit;

    import control_signals::*;

    // DUT ports
    reg [5:0]   opcode, funct;
    reg         zero;
    ControlBus  control_bus;

    // Testbench variables
    reg         clock;
    wire [8:0]  ctrl;

    assign ctrl =
    {
        control_bus.rf_we,          // 1 bit
        control_bus.sel_wa,         // 2 bits
        control_bus.sel_alu_b,      // 1 bit
        control_bus.dmem_we,        // 1 bit
        control_bus.sel_result,     // 2 bits
        control_bus.sel_pc          // 2 bits
    };

    // Instructions
    localparam  NO_FUNCT = 6'd0;
    localparam  NO_OP    = 6'd63;
    // I-Type { opcode, funct }
    localparam  LW      = { 6'h23, NO_FUNCT },
                SW      = { 6'h2B, NO_FUNCT },
                ADDI    = { 6'h08, NO_FUNCT },
                J       = { 6'h02, NO_FUNCT },
                JAL     = { 6'h03, NO_FUNCT },
                BEQY    = { 6'h04, NO_FUNCT },
                BEQN    = { 6'h04, NO_FUNCT };

    // DUT
    control_unit DUT(.*);

    // Set variables to known state
    initial begin
        opcode  = 0;
        funct   = 0;
        zero    = 0;
        clock   = 0;
    end

    // Generate #10 period clock
    initial begin forever #5 clock = ~clock; end

    // Testbench
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");
        
        // Load Word
        #10 { opcode, funct } = LW;
        #10 if (ctrl != LWc) 
            $display("[LW] Expected: %b Actual: %b", LWc, ctrl);

        // Store Word
        #10 { opcode, funct } = SW;
        #10 if (ctrl != SWc) 
            $display("[SW] Expected: %b Actual: %b", SWc, ctrl);

        // Add Immediate
        #10 { opcode, funct } = ADDI;
        #10 if (ctrl != ADDIc) 
            $display("[ADDI] Expected: %b Actual: %b", ADDIc, ctrl);

        // Jump
        #10 { opcode, funct } = J;
        #10 if (ctrl != Jc) 
            $display("[J] Expected: %b Actual: %b", Jc, ctrl);

        // Jump and Link
        #10 { opcode, funct } = JAL;
        #10 if (ctrl != JALc) 
            $display("[JAL] Expected: %b Actual: %b", JALc, ctrl);

        // Branch if Equal, Not Equal
        zero = 0;
        #10 { opcode, funct } = BEQN;
        #10 if (ctrl != BEQNc) 
            $display("[BEQN] Expected: %b Actual: %b", BEQNc, ctrl);
        // Branch if Equal, Equal
        zero = 1;
        #10 { opcode, funct } = BEQY;
        #10 if (ctrl != BEQYc) 
            $display("[BEQY] Expected: %b Actual: %b", BEQYc, ctrl);

        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end

endmodule
