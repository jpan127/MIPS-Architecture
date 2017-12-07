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
    reg ResDone;
    //err_reg
    reg ResErr;
    //result_reg
    wire [31:0] Result;
    
    fact_ad       address_decoder(A, WE, WE1, WE2, GO, RdSel);
    fact_reg      reg1(Clk, Rst, WD, WE1, n); 
    fact_reg      reg2(Clk, Rst, GO, WE2, Go); 
    fact_reg      reg3(Clk, Rst, GoPulseCmb, 1'b1, Gopulse);

    assign GoPulseCmb = GO & WE2;

    // RS Latches
    always @(Clk) begin 
        if (Done)            ResDone = 1;
        else if (GoPulseCmb) ResDone = 0;
    end

    // RS Latches
    always @(Clk) begin 
        if (Err)             ResErr = 1;
        else if (GoPulseCmb) ResErr = 0;
    end    

    Factorio      factorial_accelerator(Gopulse, Clk, Rst, n, nf, Done, Err, CS);
    fact_reg      result_reg(Clk, Rst, nf, Done, Result);
    fact_mux mux(
        RdSel, 
        {{28{1'b0}},n},                 // 0x0
        {{31{1'b0}},Go},                // 0x4
        {{30{1'b0}},ResErr,ResDone},    // 0x8
        Result,                         // 0xC
        RD
    );

endmodule

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

module Factorio_CU(
    input Go, GT_flag,Err_flag, CLK, RST,
    //control unit
    output reg sel1, sel2, reg_load, cnt_load, cnt_en,
    //output flag
    output reg Done,Error,
    output reg [2:0] CS
    );

    parameter Idle = 4'b000;
    parameter Load = 4'b001;
    parameter Wait = 4'b010;
    parameter Mul  = 4'b011;
    parameter Sub  = 4'b100;
    parameter Out  = 4'b101;
    parameter Err  = 4'b110;

    parameter
          S0 = 5'b1_1_0_0_0,
          S1 = 5'b1_1_1_1_0,
          S2 = 5'b1_1_1_1_0,//Wait State
          S3 = 5'b0_1_0_0_0,
          S4 = 5'b0_1_1_1_1,
          S5 = 5'b0_0_0_0_0,
          S6 = 5'b0_0_0_0_0;//ERRORR

    reg [4:0] ctrl;
    reg [2:0] NS = Idle;    // have the unit start at the Idle ctrl

    always@ (posedge CLK,posedge RST) 
    begin
       if(RST==1)CS <= Idle;
       else CS <= NS;    
    end  

    always@ (ctrl) {sel1,sel2,reg_load,cnt_load,cnt_en} = ctrl;

    always@ (Go,CS,GT_flag)
    begin 
    case(CS)
        Idle: begin          
            Done <=0;Error<=0;   
            if(Go) begin ctrl <= S0; NS <= Load; end
            else   begin ctrl <= S0; NS <= Idle; end
        end
        /////////////////////////////////////////////
        Load: begin
           Done <=0;Error<=0;  
           ctrl <= S1; NS <= Wait; 
        end
        ////////////////////////
        Wait: begin
           Done <=0;Error<=0;   
           if(GT_flag) begin ctrl <= S2;  NS <= Err; end
           else         begin ctrl <= S2; NS <= Out; end
        end         
        ///////////////////////
        Mul: begin
           Done <=0;Error<=0;     
           ctrl <= S3; NS <= Sub; 
        end
        //////////////////////
        Sub: begin
           Done <=0;Error<=0;     
           if(GT_flag) begin ctrl <= S4; NS <= Mul; end
           else         begin ctrl <= S4; NS <= Out; end // when count = 1, output
        end
        ///////////////////////
        Out: begin
           Done <= 1; 
           ctrl <= S5; NS <= Idle;
        end
        ///////////////////////
        Err: begin
          Done <= 0;
          if(Err_flag) begin Error <= 1; ctrl <= S6; NS <= Out;  end 
          else         begin Error <= 0; ctrl <= S6; NS <= Mul;  end
        end
    endcase
    end
endmodule

module fact_ad
( 
    input  wire [1:0] A,
    input  wire WE,
    output reg WE1, 
    output reg WE2,
    output reg GO, 
    output wire [1:0] RdSel 
); 

    always@* begin 
        case(A)      
            2'b00:   begin WE1 = WE;   WE2 = 1'b0; GO = 1'b0; end // 0x800
            2'b01:   begin WE1 = 1'b0; WE2 = WE;   GO = 1'b1; end // 0x804
            2'b10:   begin WE1 = 1'b0; WE2 = 1'b0; GO = 1'b0; end
            2'b11:   begin WE1 = 1'b0; WE2 = 1'b0; GO = 1'b0; end
            default: begin WE1 = 1'bx; WE2 = 1'bx; GO = 1'bx; end
        endcase
    end

    assign RdSel = A; 

endmodule

module fact_reg #(parameter w = 32) 
(   
    input wire Clk, Rst, 
    input wire [w - 1 : 0] D, 
    input wire Load_Reg, 
    output reg[w - 1 : 0] Q
);

    always@ (posedge Clk, posedge Rst) 
    begin
        if (Rst)            Q <= 0;
        else if(Load_Reg)   Q <= D;
        else                Q <= Q;
    end

endmodule