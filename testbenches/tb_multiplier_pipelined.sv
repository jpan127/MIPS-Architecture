`timescale 1ns / 1ps
module tb_multiplier_pipelined;
  reg         clk, rst, inputEn, stageEn, outputEn;
  reg  [31:0] a, b;
  wire [31:0] hi, lo;

    multiplier_pipelined DUT(
      .clk      (clk),
      .rst      (rst),
      .inputEn  (inputEn),
      .stageEn  (stageEn),
      .outputEn (outputEn),
      .A        (a),
      .B        (b),
      .hi       (hi),
      .lo       (lo));
  
task clock; begin
    clk = 0; #5; clk = 1; #5; end
endtask

task reset; begin
    rst = 1; #5; rst = 0; #5; end
endtask

reg [63:0] actual; // Store actual Product to compare
integer i;         // Loop variable for random values

initial begin
  reset;                              
  $display("---Simulation Begining---");

  // Edge Case Verification
  a = 0; b = 0; actual = a*b;
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);
  inputEn = 0; stageEn = 0; outputEn = 0;

  a = 0; b = 1; actual = a*b;
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock; 
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);    
  inputEn = 0; stageEn = 0; outputEn = 0;

  a = 1; b = 0; #2; actual = a*b;
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);   
  inputEn = 0; stageEn = 0; outputEn = 0;

  a = 0; b = 32'hffffffff; actual = a*b;
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);
  inputEn = 0; stageEn = 0; outputEn = 0;

  a = 32'hffffffff; b = 0; actual = a*b;
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);
  inputEn = 0; stageEn = 0; outputEn = 0;

  a = 1; b = 32'hffffffff; actual = a*b; 
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);
  inputEn = 0; stageEn = 0; outputEn = 0;

  a = 32'hffffffff; b = 1; actual = a*b; 
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);
  inputEn = 0; stageEn = 0; outputEn = 0;

  a = 32'hfffffffe; b = 32'hfffffffe; actual = a*b;
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);
  inputEn = 0; stageEn = 0; outputEn = 0;

  a = 32'hfffffffe; b = 32'hffffffff; actual = a*b; 
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);
  inputEn = 0; stageEn = 0; outputEn = 0;

  a = 32'hffffffff; b = 32'hffffffff; actual = a*b; 
  inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
  if (hi != actual[63:32]) $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
  if (lo != actual[31:0])  $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);
    inputEn = 0; stageEn = 0; outputEn = 0;

  // Random Value Verification
  for (i=0; i<1000; i=i+1) begin        
    a= $urandom % 32'hffffffff; 
    b= $urandom % 32'hffffffff;
    actual = a*b;
    inputEn = 1; clock; stageEn = 1; clock; outputEn = 1; clock;
    
    // $display ("a = %d b = %d OUT = %d", a, b, actual);
    if (hi != actual[63:32]) begin
      $display ("ERROR: a = %d b = %d hi = %d", a, b, hi);
      $stop;
    end
    if (lo != actual[31:0]) begin
      $display ("ERROR: a = %d b = %d lo = %d", a, b, lo);
      $stop;
    end

    inputEn = 0; stageEn = 0; outputEn = 0;
  end

  $display("---Simulation successful---");
end
endmodule