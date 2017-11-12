`timescale 1ns / 1ps
`include "defines.svh"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                              MIPS Datapath                                              //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


module datapath

(   input           clock, reset,
    input   [31:0]  instruction,
    input   [31:0]  dmem_rd,
    output  [31:0]  pc, alu_out, dmem_wd,
    // Decode
    output  [31:0]  d_instruction,                      // Needs to be outputted to the CU so the CU gets the delay too
    // Interfaces
    DebugBus.InputBus       debug_in,
    DebugBus.OutputBus      debug_out,
    ControlBus.Receiver     control_bus     );

    // Packages
    import global_types::*;
    import global_functions::*;
    import pipeline_pkg::*;

    // Buses
    FetchBus     fetch_bus;
    DecodeBus    decode_bus;
    ExecuteBus   execute_bus;
    MemoryBus    memory_bus;
    WritebackBus writeback_bus;

    // Internal wires
    logic5   wa, ra0, ra1, wa0, wa1;                    // Register file
    logic16  imm;                                       // Immediate value before sign extend
    logic32  pc_plus4, pc_plus8, pc_branch;             // PC addresses
    logic32  jump_addr;                                 // Jump address
    logic32  sign_imm, sign_imm_sh;                     // After sign extend
    logic32  alu_a, alu_b, result;                      // ALU

    // Datapath outputs
    assign pc = fetch_bus.f_pc;
    assign d_instruction = decode_bus.d_instruction;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                    PIPELINE : FETCH                                       //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    assign pc_plus4 = add(pc, 32'd4);           // From after fetch stage

    mux4 #(32) MUX_PC
    ( 
        .a          (pc_plus4),                 // From after fetch stage
        .b          (pc_branch),                // From after memory stage
        .c          (jump_addr),                // From after memory stage?????
        .d          (result), 
        .sel        (control_bus.sel_pc), 
        .y          (fetch_bus.w_pc)
    );

    fetch_reg FETCH_REGISTER
    (
        .fetch_bus  (fetch_bus),
        .clock      (clock),
        .reset      (reset)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                    PIPELINE : DECODE                                      //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Bus Inputs
    assign decode_bus.f_instruction = instruction;  // From IMEM
    assign decode_bus.f_pc_plus4    = pc_plus4;

    decode_reg DECODE_REGISTER
    (
        .clock      (clock),
        .reset      (reset),
        .decode_bus (decode_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                  PIPELINE : EXECUTE                                       //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Split instruction
    assign ra0                      = decode_bus.d_instruction[25:21];
    assign execute_bus.d_pc_plus4   = decode_bus.d_pc_plus4;
    assign execute_bus.d_ra1        = decode_bus.d_instruction[20:16];
    assign execute_bus.d_wa0        = decode_bus.d_instruction[20:16];              // I-Type
    assign execute_bus.d_wa1        = decode_bus.d_instruction[15:11];              // R-Type
    assign execute_bus.d_sign_imm   = sign_extend(decode_bus.d_instruction[15: 0]);

    regfile RF  
    ( 
        .clock      (clock),
        .we         (control_bus.rf_we),
        .wa         (wa),
        .ra0        (ra0),
        .ra1        (ra1),
        .ra2        (debug_in.rf_ra),
        .rd2        (debug_out.rf_rd),
        .wd         (result),
        .rd0        (execute_bus.d_rd0), //(alu_a),
        .rd1        (execute_bus.d_rd1), //(dmem_wd)
    );

    execute_reg EXECUTE_REGISTER
    (
        .clock       (clock),
        .reset       (reset),
        .execute_bus (execute_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                    PIPELINE : MEMORY                                      //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    assign sign_imm_sh = shift_left_2(execute_bus.e_sign_imm);
    assign pc_branch   = add(decode_bus.d_pc_plus4, sign_imm_sh);

    // Chooses which is the write address
    mux4 #(5) MUX_WA    
    ( 
        .a          (wa0), 
        .b          (wa1), 
        .c          (REG_RA), 
        .d          (REG_ZERO), 
        .sel        (control_bus.sel_wa), 
        .y          (wa)
    );

    alu ALU
    ( 
        .clock      (clock), 
        .reset      (reset), 
        .a          (execute_bus.e_rd0), 
        .b          (alu_b), 
        .sel        (control_bus.alu_ctrl), 
        .y          (alu_out), 
        .zero       (control_bus.zero)
    );

    // Chooses which signal goes to the ALU port B : RF read port 2 or sign immediate output
    mux2 MUX_ALU_B
    ( 
        .a          (execute_bus.e_rd1), 
        .b          (execute_bus.e_sign_imm), 
        .sel        (control_bus.sel_alu_b), 
        .y          (alu_b) 
    );

    memory_reg MEMORY_REGISTER
    (
        .clock       (clock),
        .reset       (reset),
        .memory_bus  (memory_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                  PIPELINE : WRITEBACK                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    assign jump_addr = { pc_plus8[31:28], decode_bus.d_instruction[25:0], 2'b00 };
    assign pc_plus8  = add(decode_bus.d_pc_plus4, 32'd4);

    mux4 #(32) MUX_RESULT
    ( 
        .a          (dmem_rd), 
        .b          (alu_out), 
        .c          (pc_plus4), 
        .d          (ZERO32), 
        .sel        (control_bus.sel_result), 
        .y          (result) 
    );

    writeback_reg WRITEBACK_REGISTER
    (
        .clock         (clock),
        .reset         (reset),
        .writeback_bus (writeback_bus)
    );

endmodule