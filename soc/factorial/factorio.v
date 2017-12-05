
`timescale 1ns / 1ps
module Factorio(
input  Go,clk, reset,
input  [3:0] N,
output [31:0] Out,
output Done,Error,
output [2:0] CS);
wire sel1, sel2, reg_load, cnt_load, cnt_en, GT_flag;
wire Err_flag;
Factorio_DP DP(.N(N),.OUT(Out), .clk(clk), .reset(reset),
              .sel1(sel1), .sel2(sel2), 
              .reg_load(reg_load), 
              .cnt_load(cnt_load), .cnt_en(cnt_en),
              .GT_flag(GT_flag),.Err(Err_flag));
Factorio_CU CU(.Go(Go),.Err_flag(Err_flag), .GT_flag(GT_flag), .CLK(clk), .RST(reset),
              .sel1(sel1), .sel2(sel2), 
              .reg_load(reg_load), 
              .cnt_load(cnt_load), .cnt_en(cnt_en),
              .Done(Done),.Error(Error),.CS(CS) );
endmodule

