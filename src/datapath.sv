`timescale 1ns / 1ps
`include "defines.svh"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                              MIPS Datapath                                              //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


module datapath

(   input           clock, reset,
    input   [31:0]  instruction,
    // To / From the DMEM
    input   [31:0]  dmem_rd,
    output          dmem_we,
    // To / From memories
    output  [31:0]  pc, alu_out, dmem_wd,
    // After decode, to Control Unit
    output  [31:0]  d_instruction,                      // Needs to be outputted to the CU so the CU gets the delay too
    output          branch,
    // Interfaces
    DebugBus.InputBus       debug_in,
    DebugBus.OutputBus      debug_out,
    ControlBus.Receiver     control_bus     );

    // Packages
    import global_types::*;
    import global_functions::*;
    import pipeline_pkg::*;

    localparam UNUSED_5  = 5'd0;
    localparam UNUSED_32 = 32'd0;

    // Buses
    FetchBus     fetch_bus;
    DecodeBus    decode_bus;
    ExecuteBus   execute_bus;
    MemoryBus    memory_bus;
    WritebackBus writeback_bus;

    // Internal wires
    logic5   ra0, ra1;                       // Register file
    logic32  pc_plus4;                       // PC addresses
    logic32  jump_addr;                      // Jump address
    logic32  sign_imm_sh;                    // After sign extend
    logic32  alu_b, result;                  // ALU
    logic32  branch_addr;

    // Datapath outputs
    assign pc               = fetch_bus.f_pc;
    assign d_instruction    = decode_bus.d_instruction;
    assign control_bus.zero = memory_bus.m_zero;
    assign dmem_we          = memory_bus.m_dmem_we;
    assign alu_out          = memory_bus.e_alu_out;
    assign dmem_wd          = memory_bus.e_dmem_wd;

    // Hazard Controller
    logic f_flush, d_flush, e_flush, m_flush, w_flush;
    flusher FLUSHER
    (
        .clock       (clock),
        .reset       (reset),
        .instruction (instruction),
        .f_flush     (f_flush), 
        .d_flush     (d_flush), 
        .e_flush     (e_flush), 
        .m_flush     (m_flush), 
        .w_flush     (w_flush)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                     PIPELINE : FETCH                                      //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    logic  jump;
    logic2 sel_pc;

    assign pc_plus4  = add(fetch_bus.f_pc, 32'd4);                                  // From fetch

    // If the instruction coming from IMEM is a jump type, set the PC to jump before decode
    // Otherwise sel_pc comes directly from control unit after decode
    assign jump      = (instruction[31:26] == OPCODE_J | instruction[31:26] == OPCODE_JAL); // From fetch
    assign sel_pc    = (jump) ? (logic2'(SEL_PC_JUMP)) : (control_bus.sel_pc);
    assign jump_addr = { pc_plus4[31:28], instruction[25:0], 2'b00 };


    mux4 #(32) MUX_PC
    ( 
        .a          (pc_plus4),                                                     // From fetch
        .b          (branch_addr),                                                  // From memory
        .c          (jump_addr),                                                    // From memory
        .d          (result),                                                       // From writeback
        .sel        (sel_pc),                                                       // From memory
        .y          (fetch_bus.w_pc)
    );

    fetch_reg FETCH_REGISTER
    (
        .clock      (clock),
        .reset      (reset),
        .flush      (f_flush),
        .fetch_bus  (fetch_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                     PIPELINE : DECODE                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Bus Inputs
    assign decode_bus.f_instruction = instruction;                                  // From IMEM
    assign decode_bus.f_pc_plus4    = pc_plus4;                                     // From fetch

    decode_reg DECODE_REGISTER
    (
        .clock      (clock),
        .reset      (reset),
        .flush      (d_flush),
        .decode_bus (decode_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                    PIPELINE : EXECUTE                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    logic32 sign_imm;
    // Branch logic + address
    assign branch      = (execute_bus.d_rd0 == execute_bus.d_rd1) & (decode_bus.d_instruction[31:26] == OPCODE_BEQ);
    assign sign_imm    = sign_extend(decode_bus.d_instruction[15:0]);               // From decode
    assign sign_imm_sh = shift_left_2(sign_imm);
    assign branch_addr = add(decode_bus.d_pc_plus4, sign_imm_sh);                   // From decode

    // Bus Inputs
    assign execute_bus.d_pc_plus4    = decode_bus.d_pc_plus4;                        // From decode
    // Split instruction
    assign ra0                       = decode_bus.d_instruction[25:21];              // From decode
    assign ra1                       = decode_bus.d_instruction[20:16];              // From decode
    assign execute_bus.d_wa0         = decode_bus.d_instruction[20:16];              // From decode (I-Type)
    assign execute_bus.d_wa1         = decode_bus.d_instruction[15:11];              // From decode (R-Type)
    assign execute_bus.d_sign_imm    = sign_imm;
    // Store control signals
    assign execute_bus.d_alu_ctrl    = control_bus.alu_ctrl;                         // From decode (control unit)
    assign execute_bus.d_rf_we       = control_bus.rf_we;                            // From decode (control unit)
    assign execute_bus.d_sel_alu_b   = control_bus.sel_alu_b;                        // From decode (control unit)
    assign execute_bus.d_sel_result  = control_bus.sel_result;                       // From decode (control unit)
    assign execute_bus.d_sel_wa      = control_bus.sel_wa;                           // From decode (control unit)
    assign execute_bus.d_dmem_we     = control_bus.dmem_we;                          // From decode (control unit)

    regfile RF  
    ( 
        .clock      (clock),
        .we         (writeback_bus.w_rf_we),                                        // From writeback
        .wa         (writeback_bus.w_rf_wa),                                        // From writeback
        .ra0        (ra0),                                                          // From decode
        .ra1        (ra1),                                                          // From decode
        .ra2        (debug_in.rf_ra),  
        .rd2        (debug_out.rf_rd), 
        .wd         (result),                                                       // From writeback
        .rd0        (execute_bus.d_rd0),                                            // To execute
        .rd1        (execute_bus.d_rd1)                                             // To execute
    );

    execute_reg EXECUTE_REGISTER
    (
        .clock       (clock),
        .reset       (reset),
        .flush       (e_flush),
        .execute_bus (execute_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                     PIPELINE : MEMORY                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////


    // Bus Inputs
    assign memory_bus.e_dmem_wd    = execute_bus.e_rd1;                             // From execute
    assign memory_bus.e_rf_we      = execute_bus.e_rf_we;                           // From execute
    assign memory_bus.e_sel_result = execute_bus.e_sel_result;                      // From execute
    assign memory_bus.e_dmem_we    = execute_bus.e_dmem_we;                         // From execute
    assign memory_bus.e_pc_plus4   = execute_bus.e_pc_plus4;                        // From execute

    // Selects which is the write address
    mux4 #(5) MUX_WA    
    ( 
        .a          (execute_bus.e_wa0),                                            // From execute
        .b          (execute_bus.e_wa1),                                            // From execute
        .c          (REG_RA), 
        .d          (UNUSED_5),                                                     // UNUSED
        .sel        (execute_bus.e_sel_wa),                                         // From execute
        .y          (memory_bus.e_rf_wa)                                            // To memory
    );

    // Selects which signal goes to the ALU port B : RF read port 2 or sign immediate output
    mux2 MUX_ALU_B
    ( 
        .a          (execute_bus.e_rd1),                                            // From execute
        .b          (execute_bus.e_sign_imm),                                       // From execute
        .sel        (execute_bus.e_sel_alu_b),                                      // From execute
        .y          (alu_b) 
    );

    alu ALU
    ( 
        .clock      (clock), 
        .reset      (reset), 
        .a          (execute_bus.e_rd0),                                            // From execute
        .b          (alu_b), 
        .sel        (execute_bus.e_alu_ctrl),                                       // From execute 
        .y          (memory_bus.e_alu_out),                                         // To memory
        .zero       (memory_bus.e_zero)                                             // To memory
    );


    memory_reg MEMORY_REGISTER
    (
        .clock       (clock),
        .reset       (reset),
        .flush       (m_flush),
        .memory_bus  (memory_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                   PIPELINE : WRITEBACK                                    //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    logic32 pc_plus8;
    assign pc_plus8 = add(writeback_bus.w_pc_plus4, 32'd4);                         // From writeback

    // Bus Inputs
    assign writeback_bus.m_dmem_rd    = dmem_rd;                                    // From DMEM
    assign writeback_bus.m_alu_out    = memory_bus.m_alu_out;                       // From memory
    assign writeback_bus.m_rf_wa      = memory_bus.m_rf_wa;                         // From memory
    assign writeback_bus.m_rf_we      = memory_bus.m_rf_we;                         // From memory
    assign writeback_bus.m_sel_result = memory_bus.m_sel_result;                    // From memory
    assign writeback_bus.m_pc_plus4   = memory_bus.m_pc_plus4;                      // From memory
    
    mux4 #(32) MUX_RESULT
    ( 
        .a          (writeback_bus.w_dmem_rd),                                      // From writeback
        .b          (writeback_bus.w_alu_out),                                      // From writeback
        .c          (pc_plus8),                                                     // From writeback
        .d          (UNUSED_32),                                                    // UNUSED
        .sel        (writeback_bus.w_sel_result),                                   // From writeback 
        .y          (result)                                                        // To fetch + execute
    );

    writeback_reg WRITEBACK_REGISTER
    (
        .clock         (clock),
        .reset         (reset),
        .flush         (w_flush),
        .writeback_bus (writeback_bus)
    );

endmodule