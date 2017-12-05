`timescale 1ns / 1ps
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
reg [2:0] NS = Idle;	// have the unit start at the Idle ctrl

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
