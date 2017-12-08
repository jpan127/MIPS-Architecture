module tb_multiplier_single_stage;
  reg  [31:0] a, b;
  wire [63:0] product;

  multiplier32bit_single_stage DUT(.A(a), .B(b), .product(product));

integer i;

initial begin
  $display("---Simulation Begining---");
    // Edge Cases
    a = 0; b = 0; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
    a = 0; b = 1; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
    a = 1; b = 0; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
    a = 0; b = 32'hffffffff; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
    a = 32'hffffffff; b = 0; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
    a = 1; b = 32'hffffffff; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
    a = 32'hffffffff; b = 1; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
    a = 32'hfffffffe; b = 32'hfffffffe; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
    a = 32'hfffffffe; b = 32'hffffffff; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
    a = 32'hffffffff; b = 32'hffffffff; #2; 
    if (product != a*b) $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);

    // Random Values
    for (i=0; i<1000; i=i+1) begin        
        a= $urandom % 32'hffffffff; 
        b= $urandom % 32'hffffffff;
        #2; 
        // $display ("a = %d b = %d OUT = %d", a, b, product);
        if (product != a*b) begin
            $display ("ERROR: a = %d b = %d OUT = %d", a, b, product);
            $stop;
        end
    end

  $display("---Simulation successful---");
end
endmodule