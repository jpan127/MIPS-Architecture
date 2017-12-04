`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2017 05:12:43 PM
// Design Name: 
// Module Name: gpio_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gpio_tb();
    //module gpio_t(input clk, rst, we, input[1:0] addr, input[31:0] wd, gpi1, gpi2,
    //output[31:0] gpo1, gpo2, rd);
    
    reg clk, rst, we;
    reg[1:0] addr;
    reg[31:0] wd, gpi1, gpi2;
    wire[31:0] gpo1, gpo2, rd;
    
    task clk_tick;
        begin
            clk = 0; #5;
            clk = 1; #5;
        end
    endtask;
    
    gpio_t DUT(clk, rst, we, addr, wd, gpi1, gpi2, gpo1, gpo2, rd);
    
    //Check functionality of the GPIO mapping.

    initial
        begin
            rst = 1;
            clk_tick;
            rst = 0;
            
            addr = 2'b10;
            wd  = 5;
            we = 1;
            clk_tick;
            if(wd != gpo1) $display("ERROR AT 10");
            we = 0;
            
            addr = 2'b11;
            we = 1;
            clk_tick;
            if(wd != gpo2) $display("ERROR AT 11");
            we = 0;
            
            addr = 2'b10;
            rst = 1;
            clk_tick;
            if(rd != 0) $display("ERROR at 10 RST");
            
            addr = 2'b11;
            if(rd != 0) $display("ERROR at 11 RST");
            
            rst = 0;
            gpi1 = 5;
            gpi2 = 5;
            addr = 2'b00;
            clk_tick;
            if(rd != gpi1)$display("ERROR at 00 read");
            addr = 2'b01;
            clk_tick;
            if(rd != gpi2)$display("ERROR at 01 read"); 
            $finish;
        end
endmodule
