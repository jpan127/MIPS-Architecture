`timescale 1ns / 1ps
module tb_multiplier_pipelined;

    reg         clk, rst, en_in, reg  [31:0] a, b;
    wire [31:0] out_hi, out_lo;

    multiplier_pipelined DUT(
      .clk      (clk),
      .rst      (rst),
      .en_in    (en_in),
      .A        (a),
      .B        (b),
      .out_hi   (out_hi),
      .out_lo   (out_lo));

    task clock(input int n); begin for (int i=0; i<n; i++) begin clk = 0; #5; clk = 1; #5; end end endtask

    task reset; begin rst = 1; #5; rst = 0; #5; end endtask

    task calc_correct; begin actual = a * b; end endtask

    task assert;
        if (out_hi != actual[63:32]) $display ("ERROR: a = %d b = %d out_hi = %d", a, b, out_hi);
        if (out_lo != actual[31:0])  $display ("ERROR: a = %d b = %d out_lo = %d", a, b, out_lo);
    endtask

    reg [63:0] actual; // Store actual Product to compare
    integer i;         // out_loop variable for random values

    initial begin 
        reset;
        clock = 0;
        en_in = 0;
    end

initial begin
  reset;                              
  $display("---Simulation Begining---");

    // Edge Case Verification
    a = 0;              b = 0;              calc_correct;   clock(3); assert;

    a = 0;              b = 1;              calc_correct;   clock(3); assert;   

    a = 1;              b = 0; #2;          calc_correct;   clock(3); assert;

    a = 0;              b = 32'hffffffff;   calc_correct;   clock(3); assert;

    a = 32'hffffffff;   b = 0;              calc_correct;   clock(3); assert;

    a = 1;              b = 32'hffffffff;   calc_correct;   clock(3); assert;

    a = 32'hffffffff;   b = 1;              calc_correct;   clock(3); assert;

    a = 32'hfffffffe;   b = 32'hfffffffe;   calc_correct;   clock(3); assert;

    a = 32'hfffffffe;   b = 32'hffffffff;   calc_correct;   clock(3); assert;

    a = 32'hffffffff;   b = 32'hffffffff;   calc_correct;   clock(3); assert;

    // Random Value Verification
    for (i=0; i<1000; i++) begin        
        a= $urandom % 32'hffffffff; 
        b= $urandom % 32'hffffffff;
        calc_correct;
        clock(3);

        if (out_hi != actual[63:32]) begin
          $display ("ERROR: a = %d b = %d out_hi = %d", a, b, out_hi);
          $stop;
        end
        if (out_lo != actual[31:0]) begin
          $display ("ERROR: a = %d b = %d out_lo = %d", a, b, out_lo);
          $stop;
        end
    end
  $display("---Simulation successful---");
end
endmodule