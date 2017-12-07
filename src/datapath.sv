`timescale 1ns / 1ps
`include "defines.svh"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                              MIPS Datapath                                              //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


module datapath

(   input           clock, reset,
    input   [31:0]  instruction,
    // Read registers from switches
    input   [4:0]   rf_ra2,
    output  [31:0]  rf_rd2,
    // To / From the DMEM
    input   [31:0]  dmem_rd,
    output          dmem_we,
    // To / From memories
    output  [31:0]  pc, alu_out, dmem_wd,
    // After decode, to Control Unit
    output  [31:0]  d_instruction,          // Needs to be outputted to the CU so the CU gets the delay too
    output          branch,
    // Interfaces
    ControlBus.Receiver control_bus     );

    // Packages
    import global_types::*;
    import global_functions::*;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                      Internal Wires                                       //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    localparam UNUSED_5  = 5'd0;
    localparam UNUSED_32 = 32'd0;

    // Buses
    FetchBus     fetch_bus();
    DecodeBus    decode_bus();
    ExecuteBus   execute_bus();
    MemoryBus    memory_bus();
    WritebackBus writeback_bus();

    // Fetch
    logic   jump;
    logic32 jump_addr, pc_plus4;
    logic2  sel_pc;

    // Decode
    logic32 branch_addr, sign_imm, sign_imm_sh;
    logic5  ra0, ra1;

    // Execute
    logic32 alu_a, alu_b, forward_alu_b;

    // Writeback
    logic32 pc_plus8;
    logic32 result;

    // Datapath outputs
    assign pc               = fetch_bus.f_pc;
    assign d_instruction    = decode_bus.d_instruction;
    assign dmem_we          = memory_bus.m_dmem_we;
    assign alu_out          = memory_bus.m_alu_out;
    assign dmem_wd          = memory_bus.m_dmem_wd;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                     HAZARD CONTROLLER                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    logic  f_stall, d_stall, e_flush;
    logic2 sel_forward_alu_a, sel_forward_alu_b;
    hazard_controller HAZARD_CONTROLLER
    (
        .reset             (reset),
        .d_rs              (ra0),
        .d_rt              (ra1),
        .e_rs              (execute_bus.e_rs),
        .e_rt              (execute_bus.e_wa0),
        .m_rf_wa           (memory_bus.m_rf_wa),
        .w_rf_wa           (writeback_bus.w_rf_wa),
        .m_rf_we           (memory_bus.m_rf_we),
        .w_rf_we           (writeback_bus.w_rf_we),
        .e_sel_result      (execute_bus.e_sel_result),
        .sel_forward_alu_a (sel_forward_alu_a),
        .sel_forward_alu_b (sel_forward_alu_b),
        .f_stall           (f_stall),
        .d_stall           (d_stall),
        .e_flush           (e_flush)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                  PIPELINED MULTIPLIER                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    logic   en_mult, done;
    logic32 product_hi, product_lo;
    logic64 product;

    assign product = alu_a * alu_b;

    // Special Purpose Registers : HI and LO
    d_en_reg REG_HI ( .clock(clock), .reset(reset), .enable(en_mult), .d(product[63:32]), .q(product_hi) );
    d_en_reg REG_LO ( .clock(clock), .reset(reset), .enable(en_mult), .d(product[31: 0]), .q(product_lo) );

    // logic   en_mult, done;
    // logic32 product_hi, product_lo;
    // logic64 product;
    // assign en_mult = (execute_bus.e_alu_ctrl == MULTUac);
    // multiplier_pipelined PIPELINED_MULTIPLIER
    // (
    //     .clk      (clock),
    //     .rst      (reset),
    //     .en_in    (en_mult),    // From execute
    //     .A        (alu_a),
    //     .B        (alu_b),
    //     .product  (product),
    //     .done     (done)
    // );

    // d_en_reg REG_HI 
    // (
    //     .clock    (clock),
    //     .reset    (reset),
    //     .enable   (done),
    //     .d        (product[63:32]),
    //     .q        (product_hi)
    // );

    // d_en_reg REG_LO
    // (
    //     .clock    (clock),
    //     .reset    (reset),
    //     .enable   (done),
    //     .d        (product[31: 0]),
    //     .q        (product_lo)
    // );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                     PIPELINE : FETCH                                      //
    ///////////////////////////////////////////////////////////////////////////////////////////////


    assign pc_plus4 = add(fetch_bus.f_pc, 32'd4);                                   // From fetch

    // If the instruction coming from IMEM is a jump type, set the PC to jump before decode
    // Otherwise sel_pc comes directly from control unit after decode
    assign jump      = (instruction[31:26] == OPCODE_J | instruction[31:26] == OPCODE_JAL);
    assign jump_addr = { pc_plus4[31:28], instruction[25:0], 2'b00 };
    assign sel_pc    = (jump) ? (logic2'(SEL_PC_JUMP)) : (control_bus.sel_pc);

    mux4 #(32) MUX_PC
    ( 
        .a          (pc_plus4),                                                     // From fetch
        .b          (branch_addr),                                                  // From memory
        .c          (jump_addr),                                                    // From memory
        .d          (execute_bus.d_rd0),                                            // From decode
        .sel        (sel_pc),                                                       // From memory
        .y          (fetch_bus.w_pc)
    );

    fetch_reg FETCH_REGISTER
    (
        .clock      (clock),
        .reset      (reset),
        .stall      (f_stall),
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
        .stall      (d_stall),
        .decode_bus (decode_bus)
    );

    // Branch logic + address
    // If hazard between branch and instruction before, there is no forwarding or stalling
    assign branch      = (execute_bus.d_rd0 == execute_bus.d_rd1) & (decode_bus.d_instruction[31:26] == OPCODE_BEQ);
    assign sign_imm    = sign_extend(decode_bus.d_instruction[15:0]);               // From decode
    assign sign_imm_sh = shift_left_2(sign_imm);
    assign branch_addr = add(decode_bus.d_pc_plus4, sign_imm_sh);                   // From decode

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                    PIPELINE : EXECUTE                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Bus Inputs
    assign execute_bus.d_pc_plus4    = decode_bus.d_pc_plus4;                        // From decode
    // Split instruction
    assign ra0                       = decode_bus.d_instruction[25:21];              // From decode
    assign ra1                       = decode_bus.d_instruction[20:16];              // From decode
    assign execute_bus.d_wa0         = decode_bus.d_instruction[20:16];              // From decode (I-Type)
    assign execute_bus.d_wa1         = decode_bus.d_instruction[15:11];              // From decode (R-Type)
    assign execute_bus.d_rs          = ra0;
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
        .reset      (reset),
        .we         (writeback_bus.w_rf_we),                                        // From writeback
        .wa         (writeback_bus.w_rf_wa),                                        // From writeback
        .ra0        (ra0),                                                          // From decode
        .ra1        (ra1),                                                          // From decode
        .ra2        (rf_ra2),                                                       // From switches
        .rd2        (rf_rd2),                                                       // To 7seg
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
    assign memory_bus.e_dmem_wd    = forward_alu_b;                                 // From execute
    assign memory_bus.e_rf_we      = execute_bus.e_rf_we;                           // From execute
    assign memory_bus.e_sel_result = execute_bus.e_sel_result;                      // From execute
    assign memory_bus.e_dmem_we    = execute_bus.e_dmem_we;                         // From execute
    assign memory_bus.e_pc_plus4   = execute_bus.e_pc_plus4;                        // From execute

    mux4 #(32) MUX_FORWARD_A
    (
        .a          (execute_bus.e_rd0),                                            // From execute
        .b          (result),                                                       // From writeback
        .c          (memory_bus.m_alu_out),                                         // From memory
        .d          (UNUSED_32),
        .sel        (sel_forward_alu_a),                                            // From hazard
        .y          (alu_a)
    );

    mux4 #(32) MUX_FORWARD_B
    (
        .a          (execute_bus.e_rd1),                                            // From execute
        .b          (result),                                                       // From writeback
        .c          (memory_bus.m_alu_out),                                         // From memory
        .d          (UNUSED_32),
        .sel        (sel_forward_alu_b),                                            // From hazard
        .y          (forward_alu_b)
    );

    // Selects which signal goes to the ALU port B : RF read port 2 or sign immediate output
    mux2 MUX_ALU_B
    ( 
        .a          (forward_alu_b),                                                // From execute
        .b          (execute_bus.e_sign_imm),                                       // From execute
        .sel        (execute_bus.e_sel_alu_b),                                      // From execute
        .y          (alu_b) 
    );

    alu ALU
    ( 
        .clock      (clock), 
        .reset      (reset), 
        .a          (alu_a),                                                        // From execute / forward
        .b          (alu_b), 
        .sel        (execute_bus.e_alu_ctrl),                                       // From execute 
        .y          (memory_bus.e_alu_out),                                         // To memory
        .en_mult    (en_mult),                                                      // To REG_HI, REG_LO
        .product_hi (product_hi),                                                   // From REG_HI
        .product_lo (product_lo)                                                    // From REG_LO
    );

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

    memory_reg MEMORY_REGISTER
    (
        .clock       (clock),
        .reset       (reset),
        .memory_bus  (memory_bus)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                   PIPELINE : WRITEBACK                                    //
    ///////////////////////////////////////////////////////////////////////////////////////////////

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
        .writeback_bus (writeback_bus)
    );

endmodule