`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          MIPS Top Level Module                                          //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module mips 

(   input           clock, reset,
    input   [31:0]  instruction, dmem_rd,
    output          dmem_we,
    output  [31:0]  pc, alu_out, dmem_wd    );

    import global_types::*;

    logic [5:0]   opcode, funct;
    logic [3:0]   alu_ctrl;
    logic         zero, sel_alu_b, rf_we;
    logic [1:0]   sel_pc, sel_result, sel_wa;

    assign opcode = instruction[31:26];
    assign funct  = instruction[5:0];

    // Internal bus between control unit and datapath
    ControlBus control_bus();
    assign dmem_we = control_bus.ExternalSignals.dmem_we;

    control_unit CU 
    (
        .opcode                 (opcode),
        .funct                  (funct),
        .control_bus_external   (ControlBus.ExternalSignals),
        .control_bus_control    (ControlBus.ControlSignals ),
        .control_bus_status     (ControlBus.StatusSignals  )
    );

    datapath DP 
    (
        .clock                  (clock),
        .reset                  (reset),
        .instruction            (instruction),
        .dmem_rd                (dmem_rd),
        .pc                     (pc),
        .alu_out                (alu_out),
        .dmem_wd                (dmem_wd),
        .control_bus_control    (ControlBus.ControlSignals),
        .control_bus_status     (ControlBus.StatusSignals )
    );

endmodule

module system

(   input         clock, reset, 
    output [31:0] dmem_wd, alu_out,
    output        dmem_we               );

    wire [31:0] pc, instruction, dmem_rd;

    mips MIPS 
    (
        .clock          (clock), 
        .reset          (reset), 
        .pc             (pc), 
        .instruction    (instruction), 
        .dmem_we        (dmem_we), 
        .alu_out        (alu_out), 
        .dmem_wd        (dmem_wd), 
        .dmem_rd        (dmem_rd)
    );

    imem IMEM 
    ( 
        .addr           (pc[11:2]),        // 10 bits for 1024 spots
        .data           (instruction) 
    );
    
    dmem DMEM 
    ( 
        .clock          (clock), 
        .we             (dmem_we), 
        .addr           (alu_out[9:0]), 
        .wd             (dmem_wd), 
        .rd             (dmem_rd) 
    );

endmodule


module system_debug

(   input         clock, reset, 
    output [31:0] dmem_wd, alu_out,
    output        dmem_we,
    // Extra debug outputs
    output [31:0] instruction,
    output [31:0] pc,
    output [9:0]  dmem_addr,
    output [31:0] dmem_rd            );

    assign dmem_addr = alu_out[9:0];

    mips MIPS 
    (
        .clock          (clock), 
        .reset          (reset), 
        .pc             (pc), 
        .instruction    (instruction), 
        .dmem_we        (dmem_we), 
        .alu_out        (alu_out), 
        .dmem_wd        (dmem_wd), 
        .dmem_rd        (dmem_rd)
    );

    imem IMEM 
    ( 
        .addr           (pc[11:2]),        // 10 bits for 1024 spots
        .data           (instruction) 
    );
    
    dmem DMEM 
    ( 
        .clock          (clock), 
        .we             (dmem_we), 
        .addr           (alu_out[9:0]), 
        .wd             (dmem_wd), 
        .rd             (dmem_rd) 
    );

endmodule