`timescale 1ns / 1ps

module address_decoder

(   input               rf_we, 
    input [31:0]        address,
    output logic        we1, we2, mem_we,
    output logic [1:0]  sel_rd            );

    always_comb begin
        casex(address[11:8])      
            4'd0:    { we1, we2, mem_we, sel_rd } = { 1'b0,  1'b0,  rf_we, 2'd0 };
            4'd8:    { we1, we2, mem_we, sel_rd } = { rf_we, 1'b0,  1'b0,  2'd2 };
            4'd9:    { we1, we2, mem_we, sel_rd } = { 1'b0,  rf_we, 1'b0,  2'd3 };
            default: { we1, we2, mem_we, sel_rd } = { 1'b0,  1'b0,  1'b0,  2'b0 };
        endcase
    end

endmodule

module SoC

(   input         clock, reset,
    input [4:0]   gpi1,
    output        we_dm, 
    output [31:0] pc_current, instr, alu_out, wd_dm, rd_dm, gpo1, gpo2);

    wire [31:0] DONT_USE;
    //address_decoder
    wire MemWrite;
    wire we1,we2,mem_we;
    wire [1:0] RdSel;
    //d_mem
    wire [31:0] DmemData;
    //fact_mem
    wire [31:0] FactData;
    //gpio_mem
    //wire [31:0] gpi2,gpo1;
    wire [31:0] GpioData;
    
    // //module
    // imem imem (pc_current[7:2], instr);
    // mips mips (clock, reset, 0, instr, rd_dm, MemWrite, pc_current, alu_out, wd_dm, DONT_USE);
    // dmem dmem (clock, mem_we, alu_out[7:2], wd_dm, DmemData); 

    address_decoder address_decoder(MemWrite,alu_out,we1,we2,mem_we,RdSel);
    fact_top fact_mem(clock, reset, alu_out[3:2],we1,wd_dm[3:0],FactData);
    gpio_t gpio_mem(clock, reset, we2, alu_out[3:2], wd_dm, gpi1, gpo1, gpo1, gpo2, GpioData); 
    
    Soc_mux mux(RdSel,DmemData,DmemData,FactData,GpioData,rd_dm);
                        
endmodule
