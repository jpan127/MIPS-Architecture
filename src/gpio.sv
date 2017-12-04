`timescale 1ns / 1ps

module dreg
(input clk, rst, en, [31:0] d, output reg [31:0] q);
    always @ (posedge clk, posedge rst)
    begin
        if (rst)    q <= 0;
        else if(en) q <= d;
    end
endmodule

module gpio_t(input clk, rst, we, input[1:0] addr, input[31:0] wd, gpi1, gpi2,
    output[31:0] gpo1, gpo2, rd);
    wire[1:0] rd_sel;
    wire we1, we2;
    gpio_decoder addr_decoder(we, addr, we1, we2, rd_sel);
    
    dreg gpo1_r(clk, rst, we1, wd, gpo1);
    dreg gpo2_r(clk, rst, we2, wd, gpo2);
    
    mux4 #(32) gpio_mux
    (
        .sel (rd_sel), 
        .a   (gpi1), 
        .b   (gpi2), 
        .c   (gpo1), 
        .d   (gpo2), 
        .y   (rd)
    );

endmodule

module gpio_decoder(input we, input[1:0] addr, output reg we1, we2, output[1:0] rd_sel);
    //Based on the addr, write, or read registers.
    //If an adddress is selected and no we, just rd
    //if an address is selected for the reg's, and we then write.
    
    assign rd_sel = addr;
    
    always_comb begin
        case(addr)
            2'b00: { we1, we2 } = 2'b00;
            2'b01: { we1, we2 } = 2'b00;
            2'b10: { we1, we2 } = { we, 1'b0 };
            2'b11: { we1, we2 } = { 1'b0, we };
        endcase
    end  
    
endmodule
