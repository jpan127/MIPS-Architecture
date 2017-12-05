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