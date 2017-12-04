`timescale 1ns / 1ps


module fact_top_tb;
reg  Clk, Rst; 
reg [1:0] A;
reg WE;
reg [3:0] WD; 
wire [31:0] RD;

fact_top DUT(Clk, Rst, A, WE, WD, RD);

//Task module
task tick;
begin
   Clk = 0;#5;Clk = 1;#5;
end
endtask

//testbench
initial
begin
//Normal test
Rst=0;WE=1;WD=7;
A=0;tick;A=0;tick;A=1;tick;A=2;tick;
while(RD[0:0] == 0) tick;
A=3;tick;
//Err test
WD=13;
A=0;tick;A=0;tick;A=1;tick;A=2;tick;
while(RD[1:1] == 0) tick;


$finish;
end
endmodule
