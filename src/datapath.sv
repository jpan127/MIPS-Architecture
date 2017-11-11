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
    // Interfaces
`ifdef VALIDATION
    DebugBus.InputBus       debug_in,
    DebugBus.OutputBus      debug_out,
`endif
    ControlBus.Receiver     control_bus     );

    // Packages
    import global_types::*;
    import global_functions::*;
    import pipeline_pkg::*;

    // Internal wires
    logic5   wa, ra0, ra1, wa0, wa1;                    // Register file
    logic16  imm;                                       // Immediate value before sign extend
    logic32  pc_next, pc_plus4, pc_branch;              // PC addresses
    logic32  jump_addr;                                 // Jump address
    logic32  sign_imm, sign_imm_sh;                     // After sign extend
    logic32  alu_a, alu_b, result;                      // ALU

    // Split instruction
    assign ra0          = d_instruction[25:21];
    assign ra1          = d_instruction[20:16];
    assign wa0          = d_instruction[20:16];           // I-Type
    assign wa1          = d_instruction[15:11];           // R-Type
    assign imm          = d_instruction[15:0];
    // MIPS instructions always have lower 2 bits zero, word aligned
    assign jump_addr    = { d_pc_plus4[31:28], d_instruction[25:0], 2'b00 };

    // Helper functions instead of modules
    assign sign_imm     = sign_extend(imm);
    assign sign_imm_sh  = shift_left_2(sign_imm);
    assign pc_plus4     = add(pc, 32'd4);
    assign pc_branch    = add(d_pc_plus4, sign_imm_sh);

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                    PIPELINE : DECODE                                      //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    logic32 d_pc_plus4, d_instruction;

    // Bus
    DecodeBus decode_bus;
    // Bus Inputs
    assign decode_bus.f_instruction = instruction;
    assign decode_bus.f_pc_plus4    = pc_plus4;
    // Bus Outputs
    assign d_pc_plus4    = decode_bus.d_pc_plus4;
    assign d_instruction = decode_bus.d_instruction;

    decode_reg DECODE_REGISTER
    (
        .clock      (clock),
        .reset      (reset),
        .decode_bus (decode_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                  REGFILE LOGIC BLOCKS                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    regfile RF  
    ( 
        .clock      (clock),
        .we         (control_bus.rf_we),
        .wa         (wa),
        .ra0        (ra0),
        .ra1        (ra1),
`ifdef VALIDATION
        .ra2        (debug_in.rf_ra),
        .rd2        (debug_out.rf_rd),
`endif
        .wd         (result),
        .rd0        (alu_a),
        .rd1        (dmem_wd)
    );

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

    // Final mux which either writebacks or changes PC
    mux4 #(32) MUX_RESULT
    ( 
        .a          (dmem_rd), 
        .b          (alu_out), 
        .c          (d_pc_plus4), 
        .d          (ZERO32), 
        .sel        (control_bus.sel_result), 
        .y          (result) 
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                  PC LOGIC BLOCKS                                          //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    mux4 #(32) MUX_PC
    ( 
        .a          (d_pc_plus4), 
        .b          (pc_branch), 
        .c          (jump_addr), 
        .d          (result), 
        .sel        (control_bus.sel_pc), 
        .y          (pc_next)
    );

    // Bus
    FetchBus fetch_bus;
    // Bus Inputs
    assign fetch_bus.w_pc = pc_next;
    // Bus Outputs
    assign pc = fetch_bus.f_pc;
    
    fetch_reg FETCH_REGISTER
    (
        .fetch_bus  (fetch_bus),
        .clock      (clock),
        .reset      (reset)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                  ALU LOGIC BLOCKS                                         //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    alu ALU
    ( 
        .clock      (clock), 
        .reset      (reset), 
        .a          (alu_a), 
        .b          (alu_b), 
        .sel        (control_bus.alu_ctrl), 
        .y          (alu_out), 
        .zero       (control_bus.zero)
    );

    // Chooses which signal goes to the ALU port B : RF read port 2 or sign immediate output
    mux2 MUX_ALU_B
    ( 
        .a          (dmem_wd), 
        .b          (sign_imm), 
        .sel        (control_bus.sel_alu_b), 
        .y          (alu_b) 
    );

endmodule