module tb_cla64bit;
  reg  [63:0] a, b;
  wire [64:0] sum;

  cla_64bit DUT( 
    .A(a), 
    .B(b), 
    .c_in(1'b0), 
    .c_out(sum[64]), 
    .Sum(sum[63:0]));
  
integer i = 0; 

initial begin
    $display("---Simulation Begining---");

    // Edge Cases
    a = 0; b = 0; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 0; b = 1; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 1; b = 0; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 0; b = 9223372036854775807; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 9223372036854775807; b = 0; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 1; b = 9223372036854775807; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 9223372036854775807; b = 1; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 9223372036854775806; b = 9223372036854775806; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 9223372036854775806; b = 9223372036854775807; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 9223372036854775807; b = 9223372036854775806; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 9223372036854775807; b = 9223372036854775807; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);

    // Random Values
    for (i=0; i<1000; i=i+1) begin        
        a=$urandom % 9223372036854775807; 
        b=$urandom % 9223372036854775807;
        #2; 
        // $display ("a = %d b = %d OUT = %d", a, b, sum);
        if (sum != a+b) begin
            $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
            $stop;
        end
    end
    $display("---Simulation successful---");
end
endmodule
