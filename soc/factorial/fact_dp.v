`timescale 1ns / 1ps
module Factorio_DP (
//contorl signal
input clk, reset, sel1, sel2, reg_load, cnt_load, cnt_en,
// external input/output
input [3:0] N, 
output [31:0] OUT,
//flag 
output GT_flag,
output Err
);

wire [31:0] Mul_out, Mux1_out, Reg_out;
wire [3:0] Cnt_out;

MUX A1 (.select(sel1), .in1(Mul_out), .in2(1), .out(Mux1_out)); 
MUX A2 (.select(sel2), .in1(Reg_out), .in2(0), .out(OUT)); 

REG B1 (.clk(clk),.reset(reset),.enable(reg_load),.d(Mux1_out),.q(Reg_out));
MUL C1 (.in1(Reg_out), .in2(Cnt_out), .out(Mul_out));
CNT D1 (.LD(cnt_load), .EN(cnt_en), .RST(1'b0), .CLK(clk), .D(N), .Q(Cnt_out));
// GT_flag = (cnt_out > 1)
CMP E1 (.in1(Cnt_out), .in2(4'b0001), .out(GT_flag));

CMP E2 (.in1(N), .in2(4'b1100), .out(Err));

endmodule
