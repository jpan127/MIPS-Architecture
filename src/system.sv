`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          MIPS Top Level Module                                          //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// Top-level FPGA module
module system

(   input         clock_100MHz, button, reset,
    input  [5:0]  gpio_in,
    input  [4:0]  rf_ra,                            // Selects which register from register file to probe
    input  [3:0]  sel_display,                      // Selects which mode to probe
    output        dmem_we,
    output [7:0]  sel_led, led_value          );

    // Packages
    import global_types::*;
    
    // Internal wires
    logic32 alu_out, dmem_wd;
    logic32 pc, instruction, dmem_rd;
    logic   db_button;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                     DEBUG LED DISPLAY                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Debug bus
    logic5  rf_ra2;
    logic32 rf_rd2;

    logic5  gpio_in;
    logic16 gpio_out;

    // Selects what the right 4 LEDs display
    logic16 display_right;
    always_comb begin : DISPLAY_MODE
        case (sel_display)
            0: display_right = rf_rd2[15:0];
            1: display_right = rf_rd2[31:16];
            2: display_right = instruction[15:0];
            3: display_right = instruction[31:16];
            4: display_right = alu_out[15:0];
            5: display_right = alu_out[31:16];
            6: display_right = dmem_wd[15:0];
            7: display_right = dmem_wd[31:16];
            default: display_right = gpio_out;
        endcase
    end

    // Array that passes values to the display module
    logic4 bcds [7:0];
    always_comb begin : LED_VALUES
        // Left 4 LEDS = PC[15:0];
        bcds[7] = pc[15:12];
        bcds[6] = pc[11: 8];
        bcds[5] = pc[ 7: 4];
        bcds[4] = pc[ 3: 0];
        // Right 4 LEDS = Multiplexed display_right
        bcds[3] = display_right[15:12];
        bcds[2] = display_right[11: 8];
        bcds[1] = display_right[ 7: 4];
        bcds[0] = display_right[ 3: 0];
    end

    clock_controller CLOCK_CONTROLLER
    (
        .clock_100MHz   (clock_100MHz),
        .clock_5KHz     (clock_5KHz),
        .reset          (reset),
        .button         (button),
        .db_button      (db_button)
    );

    display_controller DISPLAY_CONTROLLER
    (
        .clock          (clock_5KHz), 
        .reset          (reset),
        .bcds           (bcds),
        .sel_led        (sel_led),
        .led_value      (led_value)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                       MIPS AND MEMORY                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    soc SYSTEM_ON_CHIP
    (
        .clock          (db_button),
        .reset          (reset),
        .gpio_in        (gpio_in),
        .dmem_wd        (dmem_wd),
        .alu_out        (alu_out),
        .dmem_we        (dmem_we),
        .instruction    (instruction),
        .gpio_out       (gpio_out)
    );

endmodule