`timescale 1ns / 1ps

module tb_control_unit;

    import testbench_globals::*;
    import control_signals::*;

    // DUT ports
    reg [5:0]   opcode, funct;
    reg         zero;
    ControlBus  control_bus();

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

    task test_instruction;
        input logic [11:0]  instruction;
        input control_t     control;
        input string        name;

        { opcode, funct } = instruction;
        
        // Need to shift the control signals right by 2 bits because we dont account for alu_op
        #10 assert (ctrl == (control >> 2)) 
            $display("[%s] SUCCESS", name);
            else $error("[%s] FAILED Expected: %b Actual: %b", name, LWc, ctrl);
    endtask

    // Testbench
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");
        
        // Load Word
        test_instruction(LW, LWc, "LW");

        // Store Word
        test_instruction(SW, SWc, "SW");

        // Add Immediate
        test_instruction(ADDI, ADDIc, "ADDI");

        // Jump
        test_instruction(J, Jc, "J");

        // Jump and Link
        test_instruction(JAL, JALc, "JAL");

        // Branch if Equal, Not Equal
        zero = 0;
        test_instruction(BEQN, BEQNc, "BEQN");

        // Branch if Equal, Equal
        zero = 1;
        test_instruction(BEQY, BEQYc, "BEQY");

        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end

endmodule
