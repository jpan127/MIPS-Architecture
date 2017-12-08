module tb_cla4bit;
    reg  [3:0] a, b;
    wire [4:0] sum;

  cla_4bit DUT( 
    .A(a), 
    .B(b), 
    .c_in(1'b0), 
    .c_out(sum[4]), 
    .Sum(sum[3:0]));

integer i = 0; 
integer j = 0;
reg [4:0] correct;

initial begin
    $display("---Simulation Begining---");
    for (i=0; i<16; i=i+1) begin        // Test a 0000-1111
        a = i; 
        for (j=0; j<16; j=j+1) begin    // Test b 0000-1111
            b = j; 
            correct = i+j;
            #2;
            //$display ("a = %d b = %d OUT = %d", a, b, sum);
            if (sum != a+b) begin
                $display ("a = %d b = %d OUT = %d", a, b, sum);
                $stop;
            end
        end
    end
    $display("---Simulation successful---");
end

endmodule


