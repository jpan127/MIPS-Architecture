`timescale 1ns / 1ps

`define tick1       #10;
`define tick_half   #5;
`define tick5       #50;

// Reset on, clock, reset off
`define reset_system    reset = 1; #10 reset = 0;

module tb_mips;

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

    // Generate a #10 period clock
    always #5 clock = ~clock;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                      Helper Functions                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Just sets dmem_rd, function for clarity
    function void set_dmem_rd(input logic32 data);
        begin 
            dmem_rd = data;
        end
    endfunction

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

    // Asserts two values are not equal, returns 1 for yes, 0 for no
    function logic assert_not_equal;
        input logic32 not_value;
        input logic32 actual;
        input string  name;
        begin
            assert(not_value != actual)
            begin
                $display("[%s] SUCCESS", name);
                success_count++;
                return 1;
            end
            else
            begin
                $error("[%s] FAILED NOT EQUAL Expected: %d Actual: %d", name, not_value, actual);
                fail_count++;
                return 0;
            end
        end
    endfunction

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Helper Tasks                                       //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Helper task to put a value into a register
    task load_reg;
        input logic5  reg_num;
        input logic16 value;
        begin
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, reg_num, value);
            NOP(5);
        end
    endtask

    // Helper task to read a register
    task read_reg;
        input  logic5 reg_num;
        output logic32 value;
        begin
            instruction = set_instruction_i(OPCODE_SW, REG_ZERO, reg_num, 16'd0);
            NOP(5);

            value = dmem_wd;
        end
    endtask

    task NOP(logic5 cycles);
        begin 
            for (i=0; i<cycles; i++) begin 
                `tick1
                instruction = set_instruction_r(OPCODE_R, REG_ZERO, REG_ZERO, REG_ZERO, ignore_shamt, FUNCT_ADD);
            end
        end
    endtask

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Unit Tests                                         //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    task test_add;
        begin
            // R[20] = 55
            load_reg(REG_20, 16'd55);
            // R[21] = 45
            load_reg(REG_21, 16'd45);

            // R[22] = R[20] + R[21] = 100
            instruction = set_instruction_r(OPCODE_R, REG_20, REG_21, REG_22, ignore_shamt, FUNCT_ADD);
            NOP(5);

            assert_equal(32'd100, DUT.DP.RF.rf[REG_22], "ADD");

            instructions_tested++;
        end
    endtask

    task test_addi;
        begin
            // R[29] = 0
            load_reg(REG_29, 16'd0);
            assert_equal(32'd0, DUT.DP.RF.rf[REG_29], "ADDI1");

            // R[29] = 256
            load_reg(REG_29, 16'd256);
            assert_equal(32'd256, DUT.DP.RF.rf[REG_29], "ADDI2");

            // R[29] = R[29] + 256 = 512
            instruction = set_instruction_i(OPCODE_ADDI, REG_29, REG_29, 16'd256);
            NOP(5);
            assert_equal(32'd512, DUT.DP.RF.rf[REG_29], "ADDI3");

            instructions_tested++;
        end
    endtask

    task test_and;
        begin
            // R[20] = 0xA
            load_reg(REG_20, 16'hA);
            // R[21] = 0xA
            load_reg(REG_21, 16'hA);

            instruction = set_instruction_r(OPCODE_R, REG_20, REG_21, REG_22, ignore_shamt, FUNCT_AND);
            NOP(5);

            // R[22] = 0xA & 0xA = 0xA
            assert_equal(32'hA, DUT.DP.RF.rf[REG_22], "AND");

            instructions_tested++;
        end
    endtask

    task test_branch;
        begin
            // Extra +4 because there is an ADDI instruction (load_reg) before BEQ
            automatic logic32 correct_branch1 = (16'h7FFF << 2);
            automatic logic32 correct_branch2 = (16'h0ABC << 2);

            // Set REG_1 = 0000
            load_reg(REG_1, 16'd0);

            correct_branch1 += pc;
            // Test when equal
            instruction = set_instruction_i(OPCODE_BEQ, REG_ZERO, REG_1, 16'h7FFF);
            NOP(2);
            correct_branch1 += 4;

            assert_equal(correct_branch1, pc, "BEQY::PC");

            // Set REG_1 = 7FFF
            load_reg(REG_1, 16'h7FFF);

            correct_branch2 += pc;
            // Test when not equal
            instruction = set_instruction_i(OPCODE_BEQ, REG_ZERO, REG_1, 16'h0ABC);
            NOP(2);
            correct_branch2 += 4;

            assert_not_equal(correct_branch2, pc, "BEQN::PC");

            instructions_tested++;
        end
    endtask

    task test_divide;
        begin
            // Set REG_11 = 257
            load_reg(REG_11, 16'd257);
            // Set REG_12 = 16
            load_reg(REG_12, 16'd16);
            // LO = rs/rt  HI = rs%rt
            // Divide 257 / 16
            instruction = set_instruction_r(OPCODE_R, REG_11, REG_12, ignore_rd, ignore_shamt, FUNCT_DIVU);
            NOP(5);

            // Move from HI
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_13, ignore_shamt, FUNCT_MFHI);
            NOP(5);
            // Check HI is correct
            assert_equal(16, DUT.DP.RF.rf[REG_13], "DIVU::HI");

            // Move from LO
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_14, ignore_shamt, FUNCT_MFLO);
            NOP(5);
            // Check LO is correct
            assert_equal(1, DUT.DP.RF.rf[REG_14], "DIVU::LO");

            instructions_tested++;
        end
    endtask

    task test_j;
        begin
            automatic logic26 jump_address = 26'hABCDEF;
            automatic logic32 final_j_addr = { pc[31:28], jump_address, 2'b00 };

            instruction = set_instruction_j(OPCODE_J, jump_address);
            NOP(1);

            // Assert PC == jump address
            assert_equal(final_j_addr, pc, "J");

            instructions_tested++;
        end
    endtask

    task test_jal;
        begin
            automatic logic26 jump_address = 26'hABCDEF;
            automatic logic32 final_j_addr = { pc[31:28], jump_address, 2'b00 };
            automatic logic32 r31_value    = 0;
            automatic logic32 old_pc       = pc;

            // J / JAL takes 1 cycle
            instruction = set_instruction_j(OPCODE_JAL, jump_address);
            NOP(1);

            // Assert PC == jump address
            assert_equal(final_j_addr, pc, "JAL::PC");

            NOP(4);
            // Assert R[31] == PC + 8
            assert_equal(old_pc + 8, DUT.DP.RF.rf[REG_RA], "JAL::R31");

            instructions_tested++;
        end
    endtask

    task test_jr;
        begin
            automatic logic16 jump_address = 16'h7FFF;

            // Load 0xAAAA into R[5]
            load_reg(REG_5, jump_address);

            // JR / BEQ takes 2 cycles
            instruction = set_instruction_r(OPCODE_R, REG_5, ignore_rt, ignore_rd, ignore_shamt, FUNCT_JR);
            NOP(2);

            // Assert PC changed to R[5]
            assert_equal(jump_address, pc, "JR");

            instructions_tested++;
        end
    endtask

    task test_lw;
        begin
            automatic logic16 offset_address = 16'd5;
            automatic logic32 dmem_address   = 0 + offset_address;

            // Pretend the DMEM returned this number
            dmem_rd = 32'hFFFF_FFFF;

            // Write FFFF_FFFF into R[5]
            instruction = set_instruction_i(OPCODE_LW, REG_ZERO, REG_5, offset_address);
            NOP(2);

            // Assert it calculated the correct address = 5
            assert_equal(dmem_address, alu_out, "LW::DMEM_ADDRESS");
            NOP(2);
            
            instruction = set_instruction_i(OPCODE_SW, REG_ZERO, REG_5, offset_address);
            NOP(2);

            // Assert the correct value was loaded into R[5] by using SW and looking at dmem_wd
            assert_equal(32'hFFFF_FFFF, dmem_wd, "LW::DMEM_WD");

            instructions_tested++;
        end
    endtask

    task test_multiply;
        // Load h7FFF
        // Multiply them to get a 32-bit value
        // Multiply the result with h7FFF to get a 64-bit value
        // MFHI and MFLO to check results
        begin
            // Set REG_10 = 7FFF (Largest unsigned number)
            load_reg(REG_10, 16'h7FFF);
            // Multiply : HI = 0    LO = 3FFF_0001
            instruction = set_instruction_r(OPCODE_R, REG_10, REG_10, ignore_rd, ignore_shamt, FUNCT_MULTU);
            NOP(5);

            // Move from HI
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_11, ignore_shamt, FUNCT_MFHI);
            NOP(5);
            // Check LO is correct
            assert_equal(32'h0, DUT.DP.RF.rf[REG_11], "MULTU1::HI");

            // Move from LO
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_12, ignore_shamt, FUNCT_MFLO);
            NOP(5);
            // Check LO is correct
            assert_equal(32'h3FFF_0001, DUT.DP.RF.rf[REG_12], "MULTU1::LO");

            // Multiply : HI = 0000_1FFF  LO = 4001_7FFF
            instruction = set_instruction_r(OPCODE_R, REG_10, REG_12, ignore_rd, ignore_shamt, FUNCT_MULTU);
            NOP(5);

            // Move from HI
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_13, ignore_shamt, FUNCT_MFHI);
            NOP(5);
            // Check HI is correct
            assert_equal(32'h0000_1FFF, DUT.DP.RF.rf[REG_13], "MULTU2::HI");

            // Move from LO
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_14, ignore_shamt, FUNCT_MFLO);
            NOP(5);
            // Check LO is correct
            assert_equal(32'h4001_7FFF, DUT.DP.RF.rf[REG_14], "MULTU2::LO");

            instructions_tested++;
        end
    endtask

    task test_slt;
        begin
            // R[20] = 0xA
            load_reg(REG_20, 16'hA);
            // R[21] = 0xA
            load_reg(REG_21, 16'hA);

            instruction = set_instruction_r(OPCODE_R, REG_20, REG_21, REG_22, ignore_shamt, FUNCT_SLT);
            NOP(5);

            // R[22] = 0xA < 0xA = 0
            assert_equal(32'd0, DUT.DP.RF.rf[REG_22], "SLT::NO");

            // R[20] = 0x9
            load_reg(REG_20, 16'h9);

            instruction = set_instruction_r(OPCODE_R, REG_21, REG_20, REG_22, ignore_shamt, FUNCT_SLT);
            NOP(5);

            // R[22] = 0x9 < 0xA != 0
            assert_equal(32'd1, DUT.DP.RF.rf[REG_22], "SLT::YES");

            instructions_tested++;
        end
    endtask

    task test_sub;
        begin
            // R[20] = 0xA
            load_reg(REG_20, 16'hA);
            // R[21] = 0xA
            load_reg(REG_21, 16'hA);

            instruction = set_instruction_r(OPCODE_R, REG_20, REG_21, REG_22, ignore_shamt, FUNCT_SUB);
            NOP(5);

            // R[22] = 0xA - 0xA = 0
            assert_equal(32'd0, DUT.DP.RF.rf[REG_22], "SUB");

            instructions_tested++;
        end
    endtask

    task test_sw;
        begin
            automatic logic16 offset_address = 16'd5;
            automatic logic16 store_data     = 16'hFFFF;
            automatic logic32 sexted_data    = { { 16{store_data[15]} }, store_data[15:0] };

            // Put 0xFFFF_FFFF into R[5]
            load_reg(REG_5, store_data);

            // Store R[5] into 0x5
            instruction = set_instruction_i(OPCODE_SW, REG_ZERO, REG_5, offset_address);
            NOP(2);

            // The data was sign extended
            assert_equal(sexted_data, dmem_wd, "SW");

            instructions_tested++;
        end
    endtask

    // Testbench
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");

        // Reset
        `reset_system

        // Test ADD
        test_add;

        // Test ADDI
        test_addi;

        // Test AND
        test_and;

        // Test BEQ
        test_branch;

        // Test DIVU
        test_divide;

        // Test J
        test_j;

        // Test JAL
        test_jal;

        // Test JR
        test_jr;

        // Test LW
        test_lw;

        // Test MULTU
        test_multiply;

        // Test SLT
        test_slt;

        // Test SUB
        test_sub;

        // Test SW
        test_sw;

        // Results
        $display("///////////////////////////////////////////////////////////////////////");
        $display("Instructions Tested: %d | Success Count: %d | Fail Count: %d", 
                  instructions_tested[5:0], success_count[5:0], fail_count[5:0]);
        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end
endmodule