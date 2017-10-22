`timescale 1ns / 1ps
`define tick            #10;
`define reset_system    reset = 1; #10 reset = 0;

module tb_datapath;

    // Packages
    import testbench_globals::*;
    import global_types::*;

    // DUT Ports
    ControlBus control_bus();
    logic    clock, reset;
    logic32  instruction;
    logic32  rd;
    logic32  pc, alu_out, dmem_wd;

    // Testbench Variables
    integer i;

    // Control signal
    reg  [11:0] ctrl;
    always_comb begin
        {
            control_bus.ControlSignals.rf_we,          // 1 bit
            control_bus.ControlSignals.sel_wa,         // 2 bits
            control_bus.ControlSignals.sel_alu_b,      // 1 bit
            control_bus.ControlSignals.sel_result,     // 2 bits
            control_bus.ControlSignals.sel_pc,         // 2 bits
            control_bus.ControlSignals.alu_ctrl        // 4 bits
        } = ctrl;
    end

    task init_registers;
        begin
            automatic logic5 imm = 'd0;
            // Set registers from 1-9 with values 1-9
            for (i=1; i<10; i++) begin 
                imm = i;
                instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_ZERO + i, imm);
                `tick
            end
        end
    endtask

    task load_registers;
        begin 
            automatic logic5 imm = 'd0;
            // Load words from from data memory address 1-9
            for (i=1; i<10; i++) begin 
                imm = i;
                instruction = set_instruction_i(OPCODE_LW, REG_ZERO, REG_ZERO + i, imm);
                `tick
            end
        end
    endtask

    task save_registers;
        begin
            automatic logic5 imm = 'd0;
            // Store words from registers to data memory address 1-9
            for (i=1; i<10; i++) begin 
                imm = i;
                instruction = set_instruction_i(OPCODE_SW, REG_ZERO, REG_ZERO + i, imm);
                `tick
            end
        end
    endtask

    task branch;
        begin 
            // Set REG_1 = 0000
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_1, 16'h0000);
            ctrl = TB_ADDIc;
            `tick
            // Test when equal
            instruction = set_instruction_i(OPCODE_BEQ, REG_ZERO, REG_1, 16'h0000);
            ctrl = TB_BEQYc;
            `tick
            assert (control_bus.StatusSignals.zero == 1)
                $display("[BEQY] SUCCESS");
                else $error("[BEQY] FAILED");

            // Set REG_1 = FFFF
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_1, 16'hFFFF);
            ctrl = TB_ADDIc;
            `tick
            // Test when not equal
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_1, 16'h0000);
            ctrl = TB_BEQNc;
            `tick
            assert (control_bus.StatusSignals.zero == 0)
                $display("[BEQN] SUCCESS");
                else $error("[BEQN] FAILED");
        end
    endtask

    task divide;
        begin
            automatic logic5 ignore_rs    = 'd0;
            automatic logic5 ignore_rt    = 'd0;
            automatic logic5 ignore_rd    = 'd0;
            automatic logic5 ignore_shamt = 'd0;
            automatic logic5 ignore_funct = 'd0;

            // Set REG_11 = 257
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_11, 16'h0101);
            ctrl = TB_ADDIc;
            `tick
            // Set REG_12 = 16
            instruction = set_instruction_i(OPCODE_ADDI, REG_ZERO, REG_12, 16'h0010);
            ctrl = TB_ADDIc;
            `tick
            // LO = rs/rt  HI = rs%rt
            // Divide 257 / 16
            instruction = set_instruction_r(OPCODE_R, REG_11, REG_12, ignore_rd, ignore_shamt, FUNCT_DIVU);
            ctrl = TB_DIVUc;
            `tick

            // Move from HI
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_13, ignore_shamt, FUNCT_MFHI);
            ctrl = TB_MFHIc;
            `tick
            // Check HI is correct
            assert(alu_out == 16) 
                $display("[DIVU::HI] SUCCESS");
                else $error("[DIVU::HI] FAILED Expected: %d Actual %d", 16, alu_out);

            // Move from LO
            instruction = set_instruction_r(OPCODE_R, ignore_rs, ignore_rt, REG_14, ignore_shamt, FUNCT_MFLO);
            ctrl = TB_MFLOc;
            `tick
            // Check LO is correct
            assert(alu_out == 1) 
                $display("[DIVU::LO] SUCCESS");
                else $error("[DIVU::LO] FAILED Expected: %d Actual %d", 1, alu_out);
        end
    endtask

    // DUT
    datapath DUT
    (
        .clock              (clock),
        .reset              (reset),
        .instruction        (instruction),
        .rd                 (rd),
        .pc                 (pc),
        .alu_out            (alu_out),
        .dmem_wd            (dmem_wd),
        .control_bus_control(control_bus.ControlSignals),
        .control_bus_status (control_bus.StatusSignals)
    );

    // Initial State
    initial begin 
        control_bus.ControlSignals.sel_alu_b   = SEL_ALU_B_DONT_CARE;
        control_bus.ControlSignals.rf_we       = RF_WE_DONT_CARE;
        control_bus.ControlSignals.sel_pc      = SEL_PC_DONT_CARE;
        control_bus.ControlSignals.sel_result  = SEL_RESULT_DONT_CARE;
        control_bus.ControlSignals.sel_wa      = SEL_WA_DONT_CARE;
        control_bus.ControlSignals.alu_ctrl    = DONT_CAREac;
        clock       = 0;
        instruction = 0;
        rd          = 0;
        ctrl        = 0;
        i           = 0;
    end

    // Generate #10 period clock
    always #5 clock = ~clock;

    // Testbench
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");

        // Reset
        `reset_system

        // Test DIVU
        divide;

        // Test BEQ
        branch;

        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end
    
endmodule
