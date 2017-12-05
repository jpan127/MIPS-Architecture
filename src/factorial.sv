`timescale 1ns / 1ps

module factorial_top(input we, rst, clk, input[1:0] wa, input[3:0] wd, output[31:0] fact_out);
    //module factorial_accel(input we, rst, clk, input[1:0] wa, input[3:0] wd, output[31:0] fact_out);
    factorial_accel accel(we,rst,clk,wa,wd,fact_out);
endmodule

module factorial_accel(input we, rst, clk, input[1:0] wa, input[3:0] wd, output[31:0] fact_out);
    //input[1:0] wa, input we, rst,clk,
    wire GO, we1, we2, we3; 
    wire[1:0] rd_sel;
    wire[3:0] n;
    wire status;
    wire go_pulse;
    wire[31:0] fact_result, result_out;
    wire fact_done, fact_err;
    wire err_latch, done_latch;  
        
    factorial_control CU(wa,we,rst,clk, fact_done, fact_err, GO, we1, we2, we3, rd_sel);
    
    //wd_reg
    dreg #(4) wd_reg(clk, rst, we1, wd, n);
    
    //status reg
    dreg #(1) go_status(clk, rst, we2, GO, status);
 
    //go reg
    dreg #(1) go_reg(clk, rst, we3, GO, go_pulse);
    
    //result reg
    dreg result_reg(clk, rst, fact_done, fact_result, result_out);
    
    //factorial unit
    //need to add error functionality
    fact_accel_top #(32) fact_unit(n, go_pulse, clk, rst, fact_result, fact_done, fact_err);
    
    //4 to 1 mux
    //sel , a, b , c , d, out
    mux4 out_mux({28'b0,n}, {31'b0,status}, {30'b0,done_latch}, result_out, rd_sel, fact_out);
    
    //error and done latches
    //Set, Reset, Clk
    sr_latch Done(clk, fact_done, go_pulse, done_latch);
    sr_latch Error(clk, fact_err, go_pulse, err_latch); 
endmodule

module factorial_control(input[1:0] addr, input we, rst,clk, done, err,
    output GO, we1, we2, we3, output[1:0] rd_sel);
    //Idle state, start state, busy wait state -> finish/idle
    
    reg[1:0] current_state, next_state;
    
    reg[1:0] IDLE = 2'b00, 
             START = 2'b01, 
             BUSY = 2'b10, 
             FINISH = 2'b11;
    
    reg[3:0] ctl;
                  //   GO     we1   we2    we3
    reg[3:0] idle =  4'b0______0_____0_____0,
             start = 4'b1______1_____1_____1,
             busy =  4'b0______0_____0_____1,
             finish =4'b0______0_____1_____0;
    
    assign {GO,we1,we2,we3} = ctl;
    assign rd_sel = addr;
    
    always@(current_state,we, done, err)begin
        case(current_state)
            IDLE:begin
                    ctl = idle;
                    if(we && addr == 0)begin
                        ctl = start;
                        next_state = START;
                    end
                  end
            START:begin
                    ctl = idle;         //need this state for reset to happen, and Accel to start.
                    next_state = BUSY;
                  end
            BUSY:begin
                    ctl = busy;                   
                    if(done || err)begin
                        ctl = finish; 
                        next_state = FINISH;
                    end
                  end
            FINISH:begin
                    ctl = idle;
                    next_state = IDLE;
                   end
        endcase
    end 
        
    always@(posedge clk)begin
        if(!rst)begin
            if(current_state != next_state) current_state = next_state;
        end
        else current_state = IDLE;
    end
endmodule

module fact_accel_top #(parameter WIDTH = 32)(input[3:0] n, input GO, clk, reset, output[WIDTH-1:0] out, output DONE ,output err);

    //instantiate modules and connect necessary wires/control signals together
    wire[WIDTH-1:0] n_load;
    assign n_load = {28'b0, n};
    assign err = 0;
    wire lde_cnt, lde_prd, sel_prd, sel_out, NGT, en_cnt;
    
    CU_TOP CU(.lde_cnt(lde_cnt), .lde_prd(lde_prd), .sel_prd(sel_prd), .sel_out(sel_out), 
        .NGT(NGT), .en_cnt(en_cnt), .clk(clk), .DONE(DONE), .reset(reset), .GO(GO));
    
    DP_TOP #(WIDTH)DP(.lde_cnt(lde_cnt), .lde_prd(lde_prd), .sel_prd(sel_prd), .sel_out(sel_out), 
        .NGT(NGT), .en_cnt(en_cnt), .load_n(n_load), .clk(clk), .reset(reset), .out(out));
    
endmodule

module sr_latch(input clk, S, R, output Q);
    reg value;
    
    always@(posedge clk)begin
        if(S) value = 1; 
        else if(R) value = 0;
    end
    
    assign Q = value;
endmodule

module CU_TOP(output reg sel_prd, sel_out, lde_prd, lde_cnt, en_cnt, DONE, input GO, clk, NGT, reset);

    //sel_prd, sel_out, lde_prd, lde_cnt, en_cnt, DONE
    reg[5:0] IDLE = 6'b0__0__0__0__0__0,
             LOAD = 6'b0__0__1__1__0__0,
             WAIT = 6'b0__0__0__0__0__0,
             PR_LD= 6'b1__0__1__0__0__0,
             DECR = 6'b0__0__0__0__1__0,
             OUTPUT=6'b0__1__0__0__0__1, ctl;
    reg[2:0] current_state, next_state;
    //current state logic
    always@(ctl)begin
        {sel_prd, sel_out, lde_prd, lde_cnt, en_cnt,DONE} = ctl;
    end
    //state transition
    always@(posedge clk)begin
        if(!reset)begin
            current_state = next_state;
        end
        else begin
            current_state = IDLE;
        end
    end
    
    //next state logic
    //YO WHAT HAPPENS IF I MAKE THE N DECREMENT STATE CONDITIONAL
    //SO THE CLOCK TICK WILL BRING IN THE NEW PRODUCT WITH THE OLD VALUE OF N
    //BUT THE N VALUE GETS DECREMENTED IN PARALLEL
    //WHO WINS?
    always@(GO, NGT, current_state)begin
        case(current_state)
            3'b000:begin ctl = IDLE; next_state = GO==1 ? 3'b001:3'b000; end
            3'b001:begin ctl = LOAD; next_state = 3'b010; end 
            3'b010:begin ctl = WAIT;next_state = NGT==1 ? 3'b011: 3'b101; end
            3'b011:begin ctl = PR_LD; next_state = 3'b100; end
            3'b100:begin ctl = DECR; next_state = 3'b010; end
            3'b101:begin ctl = OUTPUT; next_state = 3'b000; end
        endcase
    end
endmodule

module DP_TOP #(parameter WIDTH = 32)(input sel_prd, sel_out, lde_prd, lde_cnt, en_cnt,
    clk, reset, input[WIDTH-1:0] load_n, output[WIDTH-1:0] out, output NGT);
    //these names fucking suck
    wire[WIDTH-1:0] prd_out, n_out, prdmux_out;

    logic [63:0] mult_out;
    
    COMPARATOR CMP(.a(n_out), .b(1'b1), .NGT(NGT)); //TWO inputs 1 output
   
    DC_REG CNT(.lde_cnt(lde_cnt), .en_cnt(en_cnt), .clk(clk), .reset(reset), .load_n(load_n), .out(n_out));   //count enable, load enable, load, clk, output
    
    PRODUCT_REG PR_REG(.in(prdmux_out), .clk(clk), .reset(reset), .lde_prd(lde_prd), .out(prd_out)); //load enable, mux output, clk, output
    
    assign mult_out = prd_out * n_out;

    mux2 PRD_MUX(.a(mult_out), .b(1'b1), .sel(sel_prd), .y(prdmux_out));
   
    mux2 OUT_MUX(.a(prd_out), .b(1'b0), .sel(sel_out), .y(out));
    
endmodule

module COMPARATOR #(parameter WIDTH = 32)(input[WIDTH-1:0] a, b, output NGT);
    assign NGT = a>b ? 1:0;
endmodule

module DC_REG #(parameter WIDTH = 32)(input lde_cnt, en_cnt, clk, reset, input[WIDTH-1:0] load_n, output reg [WIDTH-1:0] out);
    
    always@(posedge clk, posedge reset)begin
        if (reset) begin 
            out <= 0;
        end
        else begin
            if(lde_cnt)begin
                out <= load_n;
            end
            else if(en_cnt)begin
                out <= out - 1;
            end
        end
    end
    
endmodule

module PRODUCT_REG #(parameter WIDTH = 32)(input[WIDTH-1:0] in, input clk, reset, lde_prd, output reg [WIDTH-1:0] out);

    always@(posedge clk, posedge reset)begin
        if (reset) begin 
            out <= 0;
        end
        else if(lde_prd) begin
            out <= in;
        end
    end
    
endmodule