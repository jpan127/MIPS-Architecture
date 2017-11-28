`timescale 1ns / 1ps

`define tick1       #10;
`define tick_half   #5;
`define tick5       #50;

// Reset on, clock, reset off
`define reset_system    reset = 1; #10 reset = 0;

module tb_datapath;

    // Packages
    import testbench_globals::*;
    import global_types::*;
    import pipeline_pkg::*;

    // DUT Ports
    ControlBus control_bus();
    logic      clock, reset;
    logic32    instruction, d_instruction;
    logic32    dmem_rd;
    logic      dmem_we, branch;
    logic32    pc, alu_out, dmem_wd;

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

    DebugBus debug_bus();

    // DUT
    datapath DUT
    (
        .debug_bus          (debug_bus),
        .clock              (clock),
        .reset              (reset),
        .instruction        (instruction),
        .d_instruction      (d_instruction),
        .dmem_rd            (dmem_rd),
        .dmem_we            (dmem_we),
        .pc                 (pc),
        .alu_out            (alu_out),
        .dmem_wd            (dmem_wd),
        .branch             (branch),
        .control_bus        (control_bus.Receiver)
    );

    // Control signal
    reg  [11:0] ctrl;
    always_comb begin
        {
            control_bus.rf_we,          // 1 bit
            control_bus.sel_wa,         // 2 bits
            control_bus.sel_alu_b,      // 1 bit
            control_bus.sel_result,     // 2 bits
            control_bus.sel_pc,         // 2 bits
            control_bus.alu_ctrl        // 4 bits
        } = ctrl;
    end

    // Initial State
    initial begin 
        control_bus.Receiver.sel_alu_b   = SEL_ALU_B_DONT_CARE;
        control_bus.Receiver.rf_we       = RF_WE_DONT_CARE;
        control_bus.Receiver.sel_pc      = SEL_PC_DONT_CARE;
        control_bus.Receiver.sel_result  = SEL_RESULT_DONT_CARE;
        control_bus.Receiver.sel_wa      = SEL_WA_DONT_CARE;
        control_bus.Receiver.alu_ctrl    = DONT_CAREac;
        control_bus.Receiver.dmem_we     = DMEM_WE_DISABLE;
        clock               = 0;
        instruction         = 0;
        dmem_rd             = 0;
        ctrl                = 0;
        i                   = 0;
        success_count       = 0;
        fail_count          = 0;
        instructions_tested = 0;
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                        Helper Tasks                                       //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Helper task for assertion
    task assert_equal;
        input logic32 expected;
        input logic32 actual;
        input string  name;
        begin
            assert(expected == actual)
                begin
                    $display("[%s] SUCCESS", name);
                    success_count++;
                end
                else
                begin
                    $error("[%s] FAILED Expected: %d Actual: %d", name, expected, actual);
                    fail_count++;
                end
        end
    endtask

    // Helper task for assert not equal
    task assert_not_equal;
        input logic32 not_value;
        input logic32 actual;
        input string  name;
        begin
            assert(not_value != actual)
                begin
                    $display("[%s] SUCCESS", name);
                    success_count++;
                end
                else
                begin
                    $error("[%s] FAILED ASSERT NOT EQUAL", name);
                    fail_count++;
                end
        end
    endtask

    task assert_less_than;
        input logic32 value;
        input logic32 bound;
        input string  name;
        begin
            assert(value < bound)
                begin
                    $display("[%s] SUCCESS", name);
                    success_count++;
                end
                else
                begin
                    $error("[%s] FAILED ASSERT LESS THAN", name);
                    fail_count++;
                end
        end
    endtask

    task assert_greater_than;
        input logic32 value;
        input logic32 bound;
        input string  name;
        begin
            assert(value > bound)
                begin
                    $display("[%s] SUCCESS", name);
                    success_count++;
                end
                else
                begin
                    $error("[%s] FAILED ASSERT GREATER THAN", name);
                    fail_count++;
                end
        end
    endtask

    // Helper task to put a value into a register
    task load_reg;
        input logic5  reg_num;
        input logic16 value;
        begin
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, reg_num, value);
            `tick1
            ctrl = TB_ADDIc;
            NOP(4);
        end
    endtask

    // Helper task to read a register
    task read_reg;
        input  logic5 reg_num;
        output logic32 value;
        begin
            instruction = set_instruction_i(OPCODE_SW, REG_ZERO, reg_num, 16'd0);
            ctrl = TB_SWc;
            `tick5

            value = dmem_wd;
        end
    endtask

    task NOP(logic5 cycles);
        begin 
            for (i=0; i<cycles; i++) begin 
                instruction = set_instruction_r(OPCODE_R, REG_ZERO, REG_ZERO, REG_ZERO, ignore_shamt, FUNCT_ADD);
                `tick1
                ctrl = TB_ADDc;
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
            `tick1
            ctrl = TB_ADDc;
            NOP(4);

            assert_equal(32'd100, DUT.RF.rf[REG_22], "ADD");

            instructions_tested++;
        end
    endtask

    task test_addi;
        begin
            // R[29] = 0
            load_reg(REG_29, 16'd0);
            assert_equal(32'd0, DUT.RF.rf[REG_29], "ADDI1");

            // R[29] = 256
            load_reg(REG_29, 16'd256);
            assert_equal(32'd256, DUT.RF.rf[REG_29], "ADDI2");

            // R[29] = R[29] + 256 = 512
            instruction = set_instruction_i(OPCODE_ADDI, REG_29, REG_29, 16'd256);
            `tick1
            ctrl = TB_ADDIc;
            NOP(4);
            assert_equal(32'd512, DUT.RF.rf[REG_29], "ADDI3");

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
            `tick1
            ctrl = TB_ANDc;
            NOP(4);

            // R[22] = 0xA & 0xA = 0xA
            assert_equal(32'hA, DUT.RF.rf[REG_22], "AND");

            instructions_tested++;
        end
    endtask

    task test_branch;
        begin
            // +4 for load_reg, + 4*4 for 4 clock cylces, and +4 for (pc+4 + branch)
            automatic logic32 correct_branch1 = pc + ( 4 ) + (4 * 4) + 4 + (16'h7FFF << 2);
            automatic logic32 correct_branch2 = pc + ( 4 ) + (4 * 4) + 4 + (16'h0ABC << 2);

            // Set REG_1 = 0000
            load_reg(REG_1, 16'd0);

            // Test when equal
            instruction = set_instruction_i(OPCODE_BEQ, REG_ZERO, REG_1, 16'h7FFF);
            `tick1
            ctrl = TB_BEQc;

            assert_equal(1, DUT.branch, "BEQY::branch");
            NOP(1);
            assert_equal(correct_branch1, pc, "BEQY::PC");

            // Set REG_1 = 7FFF
            load_reg(REG_1, 16'h7FFF);

            // Test when not equal
            instruction = set_instruction_i(OPCODE_BEQ, REG_ZERO, REG_1, 16'h0ABC);
            `tick1
            ctrl = TB_BEQc;
            NOP(1);

            assert_equal(0, DUT.branch, "BEQN::branch");
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
            `tick1
            ctrl = TB_DIVUc;
            NOP(4);

            // Move from HI
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_13, ignore_shamt, FUNCT_MFHI);
            `tick1
            ctrl = TB_MFHIc;
            NOP(4);
            // Check HI is correct
            assert_equal(16, DUT.RF.rf[REG_13], "DIVU::HI");

            // Move from LO
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_14, ignore_shamt, FUNCT_MFLO);
            `tick1
            ctrl = TB_MFLOc;
            NOP(4);
            // Check LO is correct
            assert_equal(1, DUT.RF.rf[REG_14], "DIVU::LO");

            instructions_tested++;
        end
    endtask

    task test_j;
        begin
            automatic logic26 jump_address = 26'hABCDEF;
            automatic logic32 final_j_addr = { pc[31:28], jump_address, 2'b00 };

            instruction = set_instruction_j(OPCODE_J, jump_address);
            `tick1

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

            instruction = set_instruction_j(OPCODE_JAL, jump_address);
            `tick1
            ctrl = TB_JALc;
            // Assert PC == jump address
            assert_equal(final_j_addr, pc, "JAL::PC");

            // Decode, Execute, Memory, Writeback
            NOP(4);

            // Assert R[31] == PC + 8
            assert_equal(old_pc + 8, DUT.RF.rf[REG_RA], "JAL::R31");

            instructions_tested++;
        end
    endtask

    task test_jr;
        begin
            automatic logic16 jump_address = 16'h7FFF;

            // Load 0xAAAA into R[5]
            load_reg(REG_5, jump_address);

            instruction = set_instruction_r(OPCODE_R, REG_5, ignore_rt, ignore_rd, ignore_shamt, FUNCT_JR);
            `tick1
            ctrl = TB_JRc;
            NOP(1);

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

            instruction = set_instruction_i(OPCODE_LW, REG_ZERO, REG_5, offset_address);
            `tick1
            ctrl = TB_LWc;
            NOP(2);

            // Assert it calculated the correct address = 5
            assert_equal(dmem_address, alu_out, "LW::DMEM_ADDRESS");

            NOP(2);
            
            instruction = set_instruction_i(OPCODE_SW, REG_ZERO, REG_5, offset_address);
            `tick1
            ctrl = TB_SWc;
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
            `tick1
            ctrl = TB_MULTUc;
            NOP(4);

            // Move from HI
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_11, ignore_shamt, FUNCT_MFHI);
            `tick1
            ctrl = TB_MFHIc;
            NOP(4);
            // Check LO is correct
            assert_equal(32'h0, DUT.RF.rf[REG_11], "MULTU1::HI");

            // Move from LO
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_12, ignore_shamt, FUNCT_MFLO);
            `tick1
            ctrl = TB_MFLOc;
            NOP(4);
            // Check LO is correct
            assert_equal(32'h3FFF_0001, DUT.RF.rf[REG_12], "MULTU1::LO");


            // Multiply : HI = 0000_1FFF  LO = 4001_7FFF
            instruction = set_instruction_r(OPCODE_R, REG_10, REG_12, ignore_rd, ignore_shamt, FUNCT_MULTU);
            `tick1
            ctrl = TB_MULTUc;
            NOP(4);

            // Move from HI
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_13, ignore_shamt, FUNCT_MFHI);
            `tick1
            ctrl = TB_MFHIc;
            NOP(4);
            // Check HI is correct
            assert_equal(32'h0000_1FFF, DUT.RF.rf[REG_13], "MULTU2::HI");

            // Move from LO
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_14, ignore_shamt, FUNCT_MFLO);
            `tick1
            ctrl = TB_MFLOc;
            NOP(4);
            // Check LO is correct
            assert_equal(32'h4001_7FFF, DUT.RF.rf[REG_14], "MULTU2::LO");

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
            `tick1
            ctrl = TB_SLTc;
            NOP(4);

            // R[22] = 0xA < 0xA = 0
            assert_equal(32'd0, DUT.RF.rf[REG_22], "SLT::NO");

            // R[20] = 0x9
            load_reg(REG_20, 16'h9);

            instruction = set_instruction_r(OPCODE_R, REG_20, REG_21, REG_22, ignore_shamt, FUNCT_SLT);
            `tick1
            ctrl = TB_SLTc;
            NOP(4);

            // R[22] = 0x9 < 0xA != 0
            assert_equal(32'd1, DUT.RF.rf[REG_22], "SLT::YES");

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
            `tick1
            ctrl = TB_SUBc;
            NOP(4);

            // R[22] = 0xA - 0xA = 0
            assert_equal(32'd0, DUT.RF.rf[REG_22], "SUB");

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
            `tick1
            ctrl = TB_SWc;
            NOP(2);

            // The data was sign extended
            assert_equal(sexted_data, dmem_wd, "SW");

            instructions_tested++;
        end
    endtask

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                    Pipeline Tests                                         //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    localparam logic5 a0 = REG_5;
    localparam logic5 v0 = REG_7;
    localparam logic5 t0 = REG_8;
    localparam logic5 s0 = REG_6;

    task pipeline_test_1;
        begin
            automatic logic16 stack_frame = -16'd8;
            automatic logic32 input_jump_address = 32'b1000_0000;
            automatic logic32 correct_jump_address = input_jump_address << 2;

            // addi $a0, $0, 4
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, a0, 16'd4);
            `tick1
            ctrl = TB_ADDIc;

            // jal  factorial
            instruction = set_instruction_j(OPCODE_JAL, input_jump_address);
            `tick1
            ctrl = TB_JALc;

            assert_equal(correct_jump_address, pc, "PIPELINE_TEST1::PC");

            // If jumped correctly
            if (correct_jump_address == pc) begin 
                // addi $sp, $sp, -8
                instruction = set_instruction_i(OPCODE_ADDI, REG_SP, REG_SP, stack_frame);
                `tick1
                ctrl = TB_ADDIc;
            end
            // If failed to jump
            else begin 
                // add $s0, $v0, $0
                instruction = set_instruction_r(OPCODE_R, s0, v0, REG_ZERO, ignore_shamt, FUNCT_ADD);
                `tick1
                ctrl = TB_ADDc;
            end

            // Decode, Execute, Memory, Writeback
            NOP(4);

            assert_equal(32'h200 - 32'h8, DUT.RF.rf[REG_SP], "PIPELINE_TEST1::REG_SP");
        end
    endtask

    task pipeline_test_2;
        begin
            automatic logic16 branch_else = 16'h0ABC;
            automatic logic32 correct_branch_addr = pc + (branch_else << 2) + (15 * 4);  // 15 Clock cycles since start

            // From pipeline_test_1
            // addi $a0, $0, 4
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, a0, 16'd4);
            `tick1
            ctrl = TB_ADDIc;

            // sw $a0, 4($sp)
            instruction = set_instruction_i(OPCODE_SW, REG_SP, a0, 16'd4);
            `tick1
            ctrl = TB_SWc;
            // sw $ra, 0($sp)
            instruction = set_instruction_i(OPCODE_SW, REG_SP, REG_RA, 16'd0);
            `tick1
            ctrl = TB_SWc;
            // addi $t0, $0, 2
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, t0, 16'd2);
            `tick1
            ctrl = TB_ADDIc;
            NOP(4);
            // slt $t0, $a0, $t0
            instruction = set_instruction_r(OPCODE_R, a0, t0, t0, ignore_shamt, FUNCT_SLT);
            `tick1
            ctrl = TB_SLTc;

            // First iteration t0 = 2, a0 = 4 so (4 < 2) = 0
            NOP(4);
            assert_equal(32'h0, DUT.RF.rf[t0], "PIPELINE_TEST2::SLT");

            // beq $t0, $0, else
            instruction = set_instruction_i(OPCODE_BEQ, t0, REG_ZERO, branch_else);
            `tick1
            ctrl = TB_BEQc;

            // Change branch control signal mid-cycle
            `tick_half 
                ctrl = (branch) ? TB_BEQc : TB_BEQNc; 
            `tick_half

            // Assert branch taken
            NOP(1);
            assert_equal(correct_branch_addr, pc, "PIPELINE_TEST2::BEQ");

            // Branch Taken
            if (pc >= correct_branch_addr) begin 
                // addi $a0, $a0, -1
                instruction = set_instruction_i(OPCODE_ADDI, a0, a0, -16'd1);
                `tick1
                ctrl = TB_ADDIc;
            end
            // Branch Not Taken
            else begin 
                // addi $v0, $0, 1
                instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, v0, 16'd1);
                `tick1
                ctrl = TB_ADDIc;
                // addi $sp, $sp, 8
                instruction = set_instruction_i(OPCODE_ADDI, REG_SP, REG_SP, 16'd8);
                `tick1
                ctrl = TB_ADDIc;
                // jr $ra
                instruction = set_instruction_r(OPCODE_R, REG_RA, REG_ZERO, REG_ZERO, ignore_shamt, FUNCT_JR);
                `tick1
                ctrl = TB_JRc;
            end

            NOP(4);
            assert_greater_than(pc, correct_branch_addr, "PIPELINE_TEST2::FINAL_PC_DID_BRANCH");
            assert_equal(32'd3, DUT.RF.rf[a0], "PIPELINE_TEST2::a0");
            assert_not_equal(32'd1, DUT.RF.rf[v0], "PIPELINE_TEST2::v0");
            assert_not_equal(32'h208, DUT.RF.rf[REG_SP], "PIPELINE_TEST2::REG_SP");
        end
    endtask

    task pipeline_test_3;
        begin
            automatic logic32 factorial_jump_addr = 32'b1000_0000;
            automatic logic32 correct_jump_address = factorial_jump_addr << 2;
            automatic logic32 a0_before_sw = 0;

            // Setup
                // From [main]
                    // addi $a0, $0, 4
                    instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, a0, 16'd4);
                    `tick1
                    ctrl = TB_ADDIc;
                    // Fake a RA of 0x0ABC
                    instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_RA, 16'h0ABC);
                    `tick1
                    ctrl = TB_ADDIc;
                    NOP(4);
                // From [factorial]
                    // addi $v0, $0, 1
                    instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, v0, 16'd1);
                    `tick1
                    ctrl = TB_ADDIc;
                    // sw $ra, 0($sp)
                    instruction = set_instruction_i(OPCODE_SW, REG_SP, REG_RA, 16'd0);
                    `tick1
                    ctrl = TB_SWc;
                    // sw $a0, 4($sp)
                    instruction = set_instruction_i(OPCODE_SW, REG_SP, a0, 16'd4);
                    `tick1
                    ctrl = TB_SWc;
                    NOP(2);

                    // Store contents of $a0 at this point to be fake-loaded from DM later
                    a0_before_sw = DUT.RF.rf[a0];
            // Setup

            // addi $a0, $a0, -1
            instruction = set_instruction_i(OPCODE_ADDI, a0, a0, -16'd1);
            `tick1
            ctrl = TB_ADDIc;

            // jal factorial

            // lw $ra, 0($sp)
            instruction = set_instruction_i(OPCODE_LW, REG_SP, REG_RA, 16'd0);
            `tick1
            ctrl = TB_LWc;

            // lw $a0, 4($sp)
            instruction = set_instruction_i(OPCODE_LW, REG_SP, a0, 16'd4);
            `tick1
            ctrl = TB_LWc;

            // addi $sp, $sp, 8
            instruction = set_instruction_i(OPCODE_ADDI, REG_SP, REG_SP, 16'd8);
            `tick1
            ctrl = TB_ADDIc;

            // Fake LW 0($sp)
            dmem_rd = DUT.RF.rf[REG_RA];

            // Data hazard : a0
            NOP(1);

            // Fake LW 4($sp)
            dmem_rd = a0_before_sw;

            // Data hazard : a0
            NOP(1);

            // multu $a0, $v0
            instruction = set_instruction_r(OPCODE_R, a0, v0, ignore_rd, ignore_shamt, FUNCT_MULTU);
            `tick1
            ctrl = TB_MULTUc;

            // mflo $v0
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, v0, ignore_shamt, FUNCT_MFLO);
            `tick1
            ctrl = TB_MFLOc;

            NOP(4);
            // $a0 starts at 4, stores to DM, decrements, then reloads from DM so = 4
            assert_equal(32'd4,   DUT.RF.rf[a0],     "PIPELINE_TEST3::a0");
            // $ra starts at 0xABC, stores to DM, reloads from DM so = 0xABC
            assert_equal(32'hABC, DUT.RF.rf[REG_RA], "PIPELINE_TEST3::REG_RA");
            assert_equal(32'h208, DUT.RF.rf[REG_SP], "PIPELINE_TEST3::REG_SP");
            assert_equal(32'd4,   DUT.RF.rf[v0],     "PIPELINE_TEST3::v0");
        end
    endtask

    // Generate #10 period clock
    always #5 clock = ~clock;

    // Testbench
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");

        // Reset
        `reset_system

        //////////////////////////// Pipeline Tests

        // main:
        // pipeline_test_1;

        // factorial:
        // pipeline_test_2;

        // else:
        // pipeline_test_3;

        //////////////////////////// Unit Tests

        // // Test ADD
        // test_add;

        // // Test ADDI
        // test_addi;

        // // Test AND
        // test_and;

        // // Test BEQ
        // test_branch;

        // // Test DIVU
        // test_divide;

        // // Test J
        // test_j;

        // // Test JAL
        // test_jal;

        // // Test JR
        // test_jr;

        // // Test LW
        // test_lw;

        // // Test MULTU
        // test_multiply;

        // // Test SLT
        // test_slt;

        // // Test SUB
        // test_sub;

        // // Test SW
        // test_sw;

        // Results
        $display("///////////////////////////////////////////////////////////////////////");
        $display("Instructions Tested: %d | Success Count: %d | Fail Count: %d", 
                  instructions_tested[5:0], success_count[5:0], fail_count[5:0]);
        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end
    
endmodule