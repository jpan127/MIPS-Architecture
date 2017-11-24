`timescale 1ns / 1ps
`include "defines.svh"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  MIPS Microarchitecture Building Blocks                                 //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////
// 32x32 Register File              //
// Parameterized No-Enable Register //
// Parameterized Enabled Register   //
// 2-to-1 Mux                       //
// 4-to-1 Mux                       //
// ALU                              //
//////////////////////////////////////

module regfile

(   input           clock,
    input           we,
    input   [4:0]   wa, ra0, ra1,
    input   [31:0]  wd,
    input   [4:0]   ra2,
    output  [31:0]  rd2,
    output  [31:0]  rd0, rd1        );

    import global_types::*;

    reg [31:0] rf [31:0];
    integer i;

    // Initialize to 0
    initial begin
        for (i=0; i<32; i=i+1) begin
            rf[i] = 0;
        end
        rf[REG_SP] = 32'h200;
    end

    // Clock triggered write operation
    always_ff @ (posedge clock) begin
        if (we && wa != 0) rf[wa] <= wd;
    end

    // Combinational read operation
    assign rd0 = (ra0 == 0) ? 0 : rf[ra0];
    assign rd1 = (ra1 == 0) ? 0 : rf[ra1];
    assign rd2 = (ra2 == 0) ? 0 : rf[ra2];

endmodule


module d_reg #(parameter WIDTH=32)

(   input                   clock, reset,
    input       [WIDTH-1:0] d,
    output  reg [WIDTH-1:0] q           );

    always_ff @ (posedge clock, posedge reset) begin
        if (reset)  q <= 0;
        else        q <= d;
    end
    
endmodule


module d_en_reg #(parameter WIDTH=32)

(   input                   clock, reset, enable,
    input       [WIDTH-1:0] d,
    output  reg [WIDTH-1:0] q                   );

    always_ff @ (posedge clock, posedge reset) begin
        if (reset)       q <= 0;
        else if (enable) q <= d;
    end
    
endmodule


module mux2 #(parameter WIDTH=32)

(   input   [WIDTH-1:0]     a, b,
    input                   sel,
    output  [WIDTH-1:0]     y    );

    assign y = sel ? b : a;

endmodule


module mux4 #(parameter WIDTH=32)

(   input       [WIDTH-1:0]     a, b, c, d,
    input       [1:0]           sel,
    output reg  [WIDTH-1:0]     y           );

    always_comb begin
        case(sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            2'b11: y = d;
        endcase
    end
    
endmodule

module mux8 #(parameter WIDTH=32)

(   input       [WIDTH-1:0]     a, b, c, d, e, f, g, h,
    input       [2:0]           sel,
    output reg  [WIDTH-1:0]     y                       );

    always_comb begin
        case(sel)
            3'b000: y = a;
            3'b001: y = b;
            3'b010: y = c;
            3'b011: y = d;
            3'b100: y = e;
            3'b101: y = f;
            3'b110: y = g;
            3'b111: y = h;
        endcase
    end
    
endmodule

module alu

(   input               clock, reset,
    input       [31:0]  a, b,
    input       [3:0]   sel,
    output reg  [31:0]  y,
    output              zero    );

    logic        enable;        // Enables the SPRs
    logic [31:0] d_hi, d_lo;    // Input to SPRs
    logic [31:0] q_hi, q_lo;    // Output of SPRs
    logic [31:0] div;           // Quotient of DIV
    logic [31:0] mod;           // Remainder of DIV

    assign div = (b == 0) ? 0 : a / b;
    assign mod = (b == 0) ? 0 : a - (b * div);

    // D-Reg Enabled Special Purpose Registers : HI and LO
    d_en_reg HI ( .clock(clock), .reset(reset), .enable(enable), .d(d_hi), .q(q_hi) );
    d_en_reg LO ( .clock(clock), .reset(reset), .enable(enable), .d(d_lo), .q(q_lo) );

    // Determines if HI and LO registers are necessary
    always_comb begin
        case (sel)
            4'd7:    enable = 1;
            4'd8:    enable = 1;
            default: enable = 0;
        endcase
    end

    // ALU operations
    always_comb begin
        // Set to known state to prevent latches
        { d_hi, d_lo, y } = 0;

        case (sel)
            4'd0:    y = a + b;                     // ADDI
            4'd1:    y = a - b;                     // SUB
            4'd2:    y = a + b;                     // ADD
            4'd3:    y = a - b;                     // SUB
            4'd4:    y = a & b;                     // AND
            4'd5:    y = a | b;                     // OR
            4'd6:    y = (a < b);                   // SLT, assembler reverses the order when compiling so tricky
            4'd7:    { d_hi, d_lo } = a * b;        // MULT
            4'd8:    { d_hi, d_lo } = { div, mod }; // DIV
            4'd9:    y = q_hi;                      // MFHI
            4'd10:   y = q_lo;                      // MFLO
            4'd11:   y = a;                         // JR, pass through a
            4'd12:   y = a;                         // Pass through
            default: y = 32'dZ;                     // UNDEFINED
        endcase
    end

    // Zero flag
    assign zero = (y == 0);

endmodule

/*

module sign_extend

(   input  [15:0]   a,
    output [31:0]   y    );

    assign y = { {16{a[15]}}, a };
    
endmodule


module adder

(   input  [31:0]   a, b,
    output [31:0]   y       );

    assign y = a + b;
    
endmodule


module sl2

(   input  [31:0]   a,
    output [31:0]   y   );

    assign y = {a[29:0], 2'b00};
    
endmodule

*/