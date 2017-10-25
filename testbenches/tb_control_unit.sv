`timescale 1ns / 1ps

module tb_control_unit;

    import global_types::*;
    import testbench_globals::*;
    import control_signals::*;

    // DUT ports
    logic [5:0]  opcode, funct;
    ControlBus control_bus();

    // Testbench variables
    logic        clock;
    logic [8:0]  ctrl;
    integer      success_count;
    integer      fail_count;

    assign ctrl =
    {
        control_bus.ControlSignals.rf_we,          // 1 bit
        control_bus.ControlSignals.sel_wa,         // 2 bits
        control_bus.ControlSignals.sel_alu_b,      // 1 bit
        control_bus.ExternalSignals.dmem_we,       // 1 bit
        control_bus.ControlSignals.sel_result,     // 2 bits
        control_bus.ControlSignals.sel_pc          // 2 bits
    };

    // Instructions
    localparam  NO_FUNCT  = 6'd0;
    localparam  NO_OPCODE = 6'd63;
    localparam  OPCODE_R  = 6'd0;
    // I-Type { opcode, NO_FUNCT }
    localparam  LW      = { 6'h23, NO_FUNCT },
                SW      = { 6'h2B, NO_FUNCT },
                ADDI    = { 6'h08, NO_FUNCT },
                J       = { 6'h02, NO_FUNCT },
                JAL     = { 6'h03, NO_FUNCT },
                BEQ     = { 6'h04, NO_FUNCT };
    // R-Type { NO_OPCODE, funct }
    localparam  JR      = { OPCODE_R, FUNCT_JR },
                ADD     = { OPCODE_R, FUNCT_ADD },
                OR      = { OPCODE_R, FUNCT_OR },
                SLT     = { OPCODE_R, FUNCT_SLT },
                SUB     = { OPCODE_R, FUNCT_SUB },
                MFHI    = { OPCODE_R, FUNCT_MFHI },
                MFLO    = { OPCODE_R, FUNCT_MFLO },
                DIVU    = { OPCODE_R, FUNCT_DIVU },
                MULTU   = { OPCODE_R, FUNCT_MULTU };

    // DUT
    control_unit DUT
    (
        .opcode              (opcode),
        .funct               (funct),
        .control_bus_external(control_bus.ExternalSignals),
        .control_bus_control (control_bus.ControlSignals),
        .control_bus_status  (control_bus.StatusSignals)
    );

    // Set variables to known state
    initial begin
        opcode  = 0;
        funct   = 0;
        clock   = 0;
        control_bus.StatusSignals.zero = 0;
        success_count   = 0;
        fail_count      = 0;
    end

    // Generate #10 period clock
    initial begin forever #5 clock = ~clock; end

    // Asserts the correct control logic is beign set
    logic [8:0] c;
    task test_instruction;
        input logic [11:0]  instruction;
        input control_t     control;
        input string        name;
        begin
            // Sets the instruction
            { opcode, funct } = instruction;

            // Need to shift the control signals right by 2 bits because we dont account for alu_op
            #10 c = control >> 2;
            
            if (ctrl === c) begin 
                $display("[%s] SUCCESS", name);
                success_count += 1;
            end
            else begin 
                $error("[%s] FAILED Expected: %b Actual: %b", name, c, ctrl);
                fail_count += 1;
            end
        end
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
        control_bus.StatusSignals.zero = 0;
        test_instruction(BEQ, BEQc, "BEQN");

        // Branch if Equal, Equal
        control_bus.StatusSignals.zero = 1;
        test_instruction(BEQ, BEQc, "BEQY");

        // Jump Register
        test_instruction(JR, JRc, "JR");

        // Add
        test_instruction(ADD, ADDc, "ADD");

        // Or
        test_instruction(OR, ORc, "OR");

        // Set Less Than
        test_instruction(SLT, SLTc, "SLT");

        // Sub
        test_instruction(SUB, SUBc, "SUB");

        // Divide Unsigned
        test_instruction(DIVU, DIVUc, "DIVU");

        // Move from HI
        test_instruction(MFHI, MFHIc, "MFHI");

        // Move from LO
        test_instruction(MFLO, MFLOc, "MFLO");

        // Multiply Unsigned
        test_instruction(MULTU, MULTUc, "MULTU");

        $display("Success Count: %d | Fail Count: %d", success_count[4:0], fail_count[4:0]);

        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end

endmodule