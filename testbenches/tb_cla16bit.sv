module tb_cla16bit;
  reg  [15:0] a, b;
  wire [16:0] sum;

  cla_16bit DUT( 
    .A(a), 
    .B(b), 
    .c_in(1'b0), 
    .c_out(sum[16]), 
    .Sum(sum[15:0]));
  
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
    a = 65535; b = 0; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 0; b = 65535; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 65535; b = 65535; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 65535; b = 65534; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 65534; b = 65535; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
    a = 65534; b = 65534; #2; 
    if (sum != a+b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);

    // Random Values
    for (i=0; i<1000; i=i+1) begin        
        a=$urandom%65535; 
        b=$urandom%65535;
        #2; 
        // $display("A %d + B: %d = %d",a,b,sum);
        if (sum != a+b) begin
            $display ("ERROR: a = %d b = %d OUT = %d", a, b, sum);
            $stop;
        end
    end
    $display("---Simulation successful---");
end

endmodule


