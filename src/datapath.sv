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
    //                                     PIPELINE : FETCH                                      //
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
    //                                     PIPELINE : DECODE                                     //
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
    //                                    PIPELINE : EXECUTE                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Bus Inputs
    assign execute_bus.d_pc_plus4   = decode_bus.d_pc_plus4;
    // Split instruction
    assign ra0                      = decode_bus.d_instruction[25:21];
    assign execute_bus.d_ra1        = decode_bus.d_instruction[20:16];
    assign execute_bus.d_wa0        = decode_bus.d_instruction[20:16];              // I-Type
    assign execute_bus.d_wa1        = decode_bus.d_instruction[15:11];              // R-Type
    assign execute_bus.d_sign_imm   = sign_extend(decode_bus.d_instruction[15: 0]);
    // Store control signals
    assign execute_bus.d_alu_ctrl   = control_bus.alu_ctrl;
    assign execute_bus.d_rf_we      = control_bus.rf_we;
    assign execute_bus.d_sel_alu_b  = control_bus.sel_alu_b;
    assign execute_bus.d_sel_pc     = control_bus.sel_pc;
    assign execute_bus.d_sel_result = control_bus.sel_result;
    assign execute_bus.d_sel_wa     = control_bus.sel_wa;
    assign execute_bus.d_dmem_we    = control_bus.dmem_we;

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
    //                                     PIPELINE : MEMORY                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Shift sign-extended immediate left by 2
    assign sign_imm_sh = shift_left_2(execute_bus.e_sign_imm);

    // Bus Inputs
    assign memory_bus.e_dmem_wd    = execute_bus.e_rd1;
    assign memory_bus.e_pc_branch  = add(execute_bus.e_pc_plus4, sign_imm_sh);
    assign memory_bus.e_rf_we      = execute_bus.e_rf_we;
    assign memory_bus.e_sel_pc     = execute_bus.e_sel_pc;
    assign memory_bus.e_sel_result = execute_bus.e_sel_result;
    assign memory_bus.e_dmem_we    = execute_bus.e_dmem_we;

    // Selects which is the write address
    mux4 #(5) MUX_WA    
    ( 
        .a          (execute_bus.e_wa0),        // From execute stage
        .b          (execute_bus.e_wa1),        // From execute stage
        .c          (REG_RA), 
        .d          (REG_ZERO), 
        .sel        (execute_bus.e_sel_wa),     // From execute stage
        .y          (memory_bus.e_rf_wa)        // To memory stage
    );

    // Selects which signal goes to the ALU port B : RF read port 2 or sign immediate output
    mux2 MUX_ALU_B
    ( 
        .a          (execute_bus.e_rd1),        // From execute stage
        .b          (execute_bus.e_sign_imm),   // From execute stage
        .sel        (execute_bus.e_sel_alu_b),  // From execute stage
        .y          (alu_b) 
    );

    alu ALU
    ( 
        .clock      (clock), 
        .reset      (reset), 
        .a          (execute_bus.e_rd0),        // From execute stage
        .b          (alu_b), 
        .sel        (execute_bus.e_alu_ctrl),   // From execute stage
        .y          (memory_bus.e_alu_out),     // To memory stage
        .zero       (memory_bus.e_zero)         // To memory stage
    );


    memory_reg MEMORY_REGISTER
    (
        .clock       (clock),
        .reset       (reset),
        .memory_bus  (memory_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                   PIPELINE : WRITEBACK                                    //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Maybe move this to memory stage?????
    assign jump_addr = { pc_plus8[31:28], decode_bus.d_instruction[25:0], 2'b00 };
    assign pc_plus8  = add(memory_bus.m_pc_plus4, 32'd4);

    // Bus Inputs
    assign writeback_bus.m_dmem_rd    = dmem_rd;
    assign writeback_bus.m_alu_out    = memory_bus.m_alu_out;
    assign writeback_bus.m_rf_wa      = memory_bus.m_rf_wa;
    assign writeback_bus.m_rf_we;     = memory_bus.m_rf_we;
    assign writeback_bus.m_sel_result = memory_bus.m_sel_result;
    
    mux4 #(32) MUX_RESULT
    ( 
        .a          (writeback_bus.w_dmem_rd),      // From writeback stage
        .b          (writeback_bus.w_alu_out),      // From writeback stage
        .c          (pc_plus8),                     // From writeback stage
        .d          (ZERO32), 
        .sel        (writeback_bus.w_sel_result),   // From writeback stage
        .y          (result)                        // To fetch + execute stages
    );

    writeback_reg WRITEBACK_REGISTER
    (
        .clock         (clock),
        .reset         (reset),
        .writeback_bus (writeback_bus)
    );

endmodule