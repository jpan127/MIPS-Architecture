`timescale 1ns / 1ps
`include "defines.svh"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          MIPS Top Level Module                                          //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// Just the CPU
module mips 

(   input           clock, reset,
    input   [31:0]  instruction, dmem_rd,
`ifdef VALIDATION
    DebugBus.InputBus  debug_in,
    DebugBus.OutputBus debug_out,
`endif
    output          dmem_we,
    output  [31:0]  pc, alu_out, dmem_wd    );

    // Packages
    import global_types::*;

    // Internal wires
    logic [5:0]   opcode, funct;
    logic [3:0]   alu_ctrl;
    logic         zero, sel_alu_b, rf_we;
    logic [1:0]   sel_pc, sel_result, sel_wa;

    // Internal bus between control unit and datapath
    ControlBus control_bus();

    // Wiring
    assign opcode  = instruction[31:26];
    assign funct   = instruction[5:0];
    assign dmem_we = control_bus.dmem_we;

    control_unit CU 
    (
        .opcode         (opcode),
        .funct          (funct),
        .control_bus    (control_bus.Sender)
    );

    datapath DP 
    (
        .clock          (clock),
        .reset          (reset),
        .instruction    (instruction),
        .dmem_rd        (dmem_rd),
        .pc             (pc),
        .alu_out        (alu_out),
        .dmem_wd        (dmem_wd),
`ifdef VALIDATION
        .debug_in       (debug_in),
        .debug_out      (debug_out),
`endif
        .control_bus    (control_bus.Receiver)
    );

endmodule

/// Top-level FPGA module
module system

(   input         clock_100MHz, clock, reset,
    input  [4:0]  rf_ra,                            // Selects which register from register file to probe
    input  [2:0]  sel_display,                      // Selects which mode to probe
    output        dmem_we,
    output [7:0]  sel_led, led_value          );

    // Packages
    import global_types::*;
    
    // Internal wires
    logic32 alu_out, dmem_wd;
    logic32 pc, instruction, dmem_rd;
    logic   debounced;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                     DEBUG LED DISPLAY                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Debug bus
    DebugBus debug_bus();
    assign debug_bus.rf_ra = rf_ra;

    // Selects what the right 4 LEDs display
    logic16 display_right;
    always_comb begin : DISPLAY_MODE
        case (sel_display)
            0: display_right = debug_bus.rf_rd[15:0];
            1: display_right = debug_bus.rf_rd[31:16];
            2: display_right = instruction[15:0];
            3: display_right = instruction[31:16];
            4: display_right = alu_out[15:0];
            5: display_right = alu_out[31:16];
            6: display_right = dmem_wd[15:0];
            7: display_right = dmem_wd[31:16];
        endcase
    end

    // Array that passes values to the display module
    logic4 bcds [7:0];
    always_comb begin : LED_VALUES
        // Left 4 LEDS = PC[15:0];
        bcds[7] = pc[15:12];
        bcds[6] = pc[11:8];
        bcds[5] = pc[7:4];
        bcds[4] = pc[3:0];
        // Right 4 LEDS = Multiplexed display_right
        bcds[3] = display_right[15:12];
        bcds[2] = display_right[11:8];
        bcds[1] = display_right[7:4];
        bcds[0] = display_right[3:0];
    end

    display DISPLAY
    (
        .clock          (debounced), 
        .reset          (reset),
        .bcds           (bcds),
        .sel_led        (sel_led),
        .led_value      (led_value)
    );

    debouncer DEBOUNCER
    (
        .clock          (clock_100MHz),
        .reset          (reset),
        .button         (clock),
        .debounced      (debounced)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                       MIPS AND MEMORY                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    mips MIPS 
    (
        .debug_in       (debug_bus.InputBus),
        .debug_out      (debug_bus.OutputBus),
        .clock          (debounced), 
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
        .clock          (debounced), 
        .we             (dmem_we), 
        .addr           (alu_out[9:0]), 
        .wd             (dmem_wd), 
        .rd             (dmem_rd) 
    );

endmodule

/// Top-level module for simulation
module system_debug

(   input         clock, reset, 
    output [31:0] dmem_wd, alu_out,
    output        dmem_we,
    // Validation outputs
`ifdef VALIDATION
    input  [4:0]  rf_ra,
    output [31:0] rf_rd,
`endif
    // Extra debug outputs
    output [31:0] instruction,
    output [31:0] pc,
    output [9:0]  dmem_addr,
    output [31:0] dmem_rd            );

    assign dmem_addr = alu_out[9:0];

`ifdef VALIDATION
    // Debug bus
    DebugBus debug_bus();
    assign debug_bus.rf_ra = rf_ra;
    assign rf_rd = debug_bus.rf_rd;
`endif

    mips MIPS 
    (
`ifdef VALIDATION
        .debug_in       (debug_bus.InputBus),
        .debug_out      (debug_bus.OutputBus),
`endif
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