`timescale 1ns / 1ps

module address_decoder

(   input               dmem_we_req, 
    input [31:0]        address,
    output logic        we1, we2, dmem_we,
    output logic [1:0]  sel_rd            );

    always_comb begin
        casex(address[11:8])      
            4'd0:    { we1, we2, dmem_we, sel_rd } = { 1'b0,        1'b0,        dmem_we_req, 2'd0 };
            4'd8:    { we1, we2, dmem_we, sel_rd } = { dmem_we_req, 1'b0,        1'b0,        2'd2 };
            4'd9:    { we1, we2, dmem_we, sel_rd } = { 1'b0,        dmem_we_req, 1'b0,        2'd3 };
            default: { we1, we2, dmem_we, sel_rd } = { 1'b0,        1'b0,        1'b0,        2'b0 };
        endcase
    end

endmodule

/// Top-level module for simulation
module soc

(   input         clock, reset,
    input  [5:0]  gpio_in,
    input  [4:0]  rf_ra2,
    output [31:0] rf_rd2,
    output [31:0] dmem_wd, alu_out,
    output        dmem_we,
    output [31:0] instruction, pc,
    output [15:0] gpio_out          );

    // Packages
    import global_types::*;

    // Factorial / SoC
    logic   dmem_we_req;
    logic32 factorial_rd, gpio_rd, rd, dmem_rd;
    logic2  sel_rd;
    logic   we_factorial, we_gpio;
    logic32 gpio_out1, gpio_out2;

    mips MIPS 
    (
        .rf_ra2      (rf_ra2),
        .rf_rd2      (rf_rd2),
        .clock       (clock),
        .reset       (reset),
        .pc          (pc),
        .instruction (instruction),
        .dmem_we     (dmem_we_req),     // MIPS sets dmem_we_req which gets decoded into dmem_we
        .alu_out     (alu_out),
        .dmem_wd     (dmem_wd),
        .dmem_rd     (rd)               // From SOC_MUX
    );

    imem IMEM 
    ( 
        .addr        (pc[7:2]),
        .data        (instruction) 
    );
    
    dmem DMEM 
    ( 
        .clock       (clock), 
        .we          (dmem_we), 
        .addr        (alu_out[11:0]), 
        .wd          (dmem_wd), 
        .rd          (dmem_rd)          // To SOC_MUX
    );

    address_decoder ADDRESS_DECODER
    (
        .dmem_we_req (dmem_we_req),     // Input
        .address     (alu_out),         // Input
        .we1         (we_factorial),    // Output
        .we2         (we_gpio),         // Output
        .dmem_we     (dmem_we),         // Output
        .sel_rd      (sel_rd)           // Output
    );

    fact_top FACTORIAL
    (
        .Clk         (clock),
        .Rst         (reset),
        .A           (alu_out[3:2]),
        .WE          (we_factorial),    // Has to be SW 0x8XX
        .WD          (dmem_wd[3:0]),    // GPIO -> register -> SW -> factorial
        .RD          (factorial_rd)
    );

    gpio_t GPIO
    (
        .clk         (clock),
        .rst         (reset),
        .we          (we_gpio),
        .addr        (alu_out[3:2]),
        .wd          (dmem_wd),
        .gpi1        ({ 28'b0, gpio_in[3:0] }),
        .gpi2        ({ 28'b0, gpio_in[3:0] }),
        .gpo1        (gpio_out1),
        .gpo2        (gpio_out2),
        .rd          (gpio_rd)
    );

    // Data comes from DMEM, factorial, and gpio, and muxes to the writeback register
    mux4 #(32) SOC_MUX
    (
        .a           (dmem_rd),
        .b           (dmem_rd),
        .c           (factorial_rd),
        .d           (gpio_rd),
        .sel         (sel_rd),
        .y           (rd)               // Final read data
    );

    // GPIO data 1 + 2 are muxed and outputted to the LED display
    mux4 #(16) GPIO_OUT_MUX
    (
        .a           (gpio_out2[15:0]),
        .b           (gpio_out2[31:16]),
        .c           (gpio_out1[15:0]),
        .d           (gpio_out1[31:16]),
        .sel         (gpio_in[5:4]),
        .y           (gpio_out)
    );

endmodule