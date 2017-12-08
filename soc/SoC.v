`timescale 1ns / 1ps

module SoC
(input clk, rst,[4:0] gpi1,output we_dm, [31:0] pc_current, instr, alu_out, wd_dm, rd_dm, gpo1, gpo2);
    wire [31:0] DONT_USE;
    //address_decoder
    wire MemWrite;
    wire WE1,WE2,WEM;
    wire [1:0] RdSel;
    //d_mem
    wire [31:0] DmemData;
    //fact_mem
    wire [31:0] FactData;
    //gpio_mem
    //wire [31:0] gpi2,gpo1;
    wire [31:0] GpioData;
    
    //module
    imem imem (pc_current[7:2], instr);

    mips mips (clk, rst, 0, instr, rd_dm, MemWrite, pc_current, alu_out, wd_dm, DONT_USE);
    
    address_decoder address_decoder(MemWrite,alu_out,WE1,WE2,WEM,RdSel);
    
    dmem dmem (clk, WEM, alu_out[7:2], wd_dm, DmemData); 
    fact_top fact_mem(clk, rst, alu_out[3:2],WE1,wd_dm[3:0],FactData);
    gpio_t gpio_mem(clk, rst, WE2, alu_out[3:2], wd_dm, gpi1, gpi1, gpo1, gpo2, GpioData); 
    
    Soc_mux mux(RdSel,DmemData,DmemData,FactData,GpioData,rd_dm);
                        
endmodule
