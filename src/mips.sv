`timescale 1ns / 1ps

/// Just the CPU
module mips 

(   input          clock, reset,
    input   [31:0] instruction, dmem_rd,
    input   [4:0]  rf_ra2,
    output  [31:0] rf_rd2,
    output         dmem_we,
    output  [31:0] pc, alu_out, dmem_wd    );

    // Packages
    import global_types::*;

    // Internal wires
    logic [5:0]   opcode, funct;
    logic [3:0]   alu_ctrl;
    logic         zero, sel_alu_b, rf_we;
    logic [1:0]   sel_pc, sel_result, sel_wa;

    // Decode
    logic32       d_instruction;

    // Internal bus between control unit and datapath
    ControlBus control_bus();

    // Wiring
    assign opcode  = d_instruction[31:26];
    assign funct   = d_instruction[5:0];

    control_unit CU 
    (
        .opcode         (opcode),
        .funct          (funct),
        .branch         (branch),
        .control_bus    (control_bus.Sender)
    );

    datapath DP 
    (
        .clock          (clock),
        .reset          (reset),
        .instruction    (instruction),
        .dmem_rd        (dmem_rd),
        .dmem_we        (dmem_we),
        .pc             (pc),
        .alu_out        (alu_out),
        .dmem_wd        (dmem_wd),
        .d_instruction  (d_instruction),
        .branch         (branch),
        .rf_ra2         (rf_ra2),
        .rf_rd2         (rf_rd2),
        .control_bus    (control_bus.Receiver)
    );

endmodule