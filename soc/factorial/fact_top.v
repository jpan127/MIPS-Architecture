`timescale 1ns / 1ps
module fact_top
(
    input wire Clk, Rst, 
    input  wire [1:0] A,
	input  wire WE,
	input  wire [3:0] WD, 
	output wire [31:0] RD
);

    //address_decoder
    wire WE1,WE2;
    wire [1:0] RdSel;
    wire GO;
    //reg1
    wire [3:0] n;
    //reg2
    wire Go;
    //reg3
    wire Gopulse;
    //Gocheck
    wire GoPulseCmb;
    //factorial_acelerator
    wire [31:0] nf;
    wire Done,Err;
    wire [2:0] CS;
    //done_reg
    wire ResDone;
    //err_reg
    wire ResErr;
    //result_reg
    wire [31:0] Result;
    
    fact_ad       address_decoder(A, WE, WE1, WE2, GO, RdSel);
    fact_reg      reg1(Clk, Rst, WD, WE1, n); 
    fact_reg      reg2(Clk, Rst, GO, WE2, Go); 
    fact_reg      reg3(Clk, Rst, GoPulseCmb, 1'b1, Gopulse);
    And           Gocheck(WE2,GO,GoPulseCmb);

    Factorio      factorial_accelerator(Gopulse, Clk, n, nf, Done, Err, CS);

    fact_reg_done done_reg(Clk, Rst, Done, GoPulseCmb, ResDone);
    fact_reg_err  err_reg (Clk, Rst, Err, GoPulseCmb, ResErr);
    fact_reg      result_reg(Clk, Rst, nf, Done, Result);
    fact_mux      mux(RdSel, {{28{1'b0}},n}, {{31{1'b0}},Go}, {{30{1'b0}},ResErr,ResDone} , Result, RD);

endmodule
