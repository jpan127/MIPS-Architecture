`timescale 1ns / 1ps

`define tick1       #10;
`define tick_half   #5;
`define tick5       #50;

// Reset on, clock, reset off
`define reset_system    reset = 1; #10 reset = 0;

module tb_hazards;

    // Packages
    import testbench_globals::*;
    import global_types::*;

    // DUT ports
    logic    clock, reset;           // Input
    logic32  instruction, dmem_rd;   // Input
    logic    dmem_we;                // Output
    logic32  pc, alu_out, dmem_wd;   // Output
    DebugBus debug_bus();

    // Testbench Variables
    localparam  logic5 ignore_rs    = 'd0,
                       ignore_rt    = 'd0,
                       ignore_rd    = 'd0,
                       ignore_shamt = 'd0,
                       ignore_funct = 'd0;
    integer i;
    integer success_count;
    integer fail_count;
    integer instructions_tested;

    // Device Under Testing
    mips DUT(.*);

    // Initial state
    initial begin 
        clock               = 0;
        reset               = 0;
        instruction         = 0;
        dmem_rd             = 0;
        i                   = 0;
        success_count       = 0;
        fail_count          = 0;
        instructions_tested = 0;
    end

    // Asserts two values are equal, returns 1 for yes, 0 for no
    function logic assert_equal;
        input logic32 expected;
        input logic32 actual;
        input string  name;
        begin 
            assert(expected == actual)
            begin
                $display("[%s] SUCCESS", name);
                success_count++;
                return 1;
            end
            else
            begin
                $error("[%s] FAILED EQUAL Expected: %d Actual: %d", name, expected, actual);
                fail_count++;
                return 0;
            end
        end
    endfunction

    task NOP(logic5 cycles);
        begin 
            for (i=0; i<cycles; i++) begin 
                `tick1
                instruction = set_instruction_r(OPCODE_R, REG_ZERO, REG_ZERO, REG_ZERO, ignore_shamt, FUNCT_ADD);
            end
        end
    endtask

    // Generate a #10 period clock
    always #5 clock = ~clock;

    // Testbench
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");

        // Load a value into R[5] and R[6]
        instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_5, 16'b1111_0000);
        `tick1
        instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_6, 16'b1010_0000);
        `tick1
        instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_7, 16'b0000_1111);
        `tick1
        instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_8, 16'b1);
        NOP(4);
        // Load the value into DMEM
        instruction = set_instruction_i(OPCODE_SW, REG_ZERO, REG_5, 16'd0);
        NOP(4);
        // Load word
        instruction = set_instruction_i(OPCODE_LW, REG_ZERO, REG_5, 16'd0);
        `tick1
        // AND it with R[6]
        instruction = set_instruction_r(OPCODE_R, REG_5, REG_6, REG_10, ignore_shamt, FUNCT_ADD);
        `tick1
        // OR it with R[7]
        instruction = set_instruction_r(OPCODE_R, REG_5, REG_7, REG_11, ignore_shamt, FUNCT_OR);
        `tick1
        // SUB it with R[9]
        instruction = set_instruction_r(OPCODE_R, REG_5, REG_8, REG_12, ignore_shamt, FUNCT_SUB);
        `tick1

        NOP(4);

        assert_equal(32'b1010_0000, DUT.DP.RF.rf[REG_10], "R[10]");
        assert_equal(32'b1111_1111, DUT.DP.RF.rf[REG_11], "R[11]");
        assert_equal(32'b1110_1111, DUT.DP.RF.rf[REG_12], "R[12]");

        // Results
        $display("///////////////////////////////////////////////////////////////////////");
        $display("Instructions Tested: %d | Success Count: %d | Fail Count: %d", 
                  instructions_tested[5:0], success_count[5:0], fail_count[5:0]);
        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end

endmodule