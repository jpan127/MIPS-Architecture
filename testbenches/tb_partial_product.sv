
module tb_partial_product;
  reg  [31:0] a, b;
  wire [31:0] pp0,  pp1,  pp2,  pp3,  pp4,  pp5,  pp6,  pp7, 
              pp8,  pp9,  pp10, pp11, pp12, pp13, pp14, pp15,
              pp16, pp17, pp18, pp19, pp20, pp21, pp22, pp23, 
              pp24, pp25, pp26, pp27, pp28, pp29, pp30, pp31;

    partial_product DUT(
            .a    (a),      .b    (b),
            .pp0  (pp0),    .pp1  (pp1),    .pp2  (pp2),    .pp3  (pp3),
            .pp4  (pp4),    .pp5  (pp5),    .pp6  (pp6),    .pp7  (pp7),
            .pp8  (pp8),    .pp9  (pp9),    .pp10 (pp10),   .pp11 (pp11),   
            .pp12 (pp12),   .pp13 (pp13),   .pp14 (pp14),   .pp15 (pp15),   
            .pp16 (pp16),   .pp17 (pp17),   .pp18 (pp18),   .pp19 (pp19),   
            .pp20 (pp20),   .pp21 (pp21),   .pp22 (pp22),   .pp23 (pp23),   
            .pp24 (pp24),   .pp25 (pp25),   .pp26 (pp26),   .pp27 (pp27),
            .pp28 (pp28),   .pp29 (pp29),   .pp30 (pp30),   .pp31 (pp31));

initial begin
    $display("---Simulation Begining---");

    // Eye Ball Testing
    a = 32'h88888888; b = 32'hffffffff; #2; 
    $display ("a    = %b b    = %b", a, b);
    $display ("pp0  = %b pp1  = %b pp2  = %b pp3  = %b",pp0,pp1,pp2,pp3);
    $display ("pp4  = %b pp5  = %b pp6  = %b pp7  = %b",pp4,pp5,pp6,pp7);
    $display ("pp8  = %b pp9  = %b pp10 = %b pp11 = %b",pp8,pp9,pp10,pp11);
    $display ("pp12 = %b pp13 = %b pp14 = %b pp15 = %b",pp12,pp13,pp14,pp15);
    $display ("pp16 = %b pp17 = %b pp18 = %b pp19 = %b",pp16,pp17,pp18,pp19);
    $display ("pp20 = %b pp21 = %b pp22 = %b pp23 = %b",pp20,pp21,pp22,pp23);
    $display ("pp24 = %b pp25 = %b pp26 = %b pp27 = %b",pp24,pp25,pp26,pp28);
    $display ("pp28 = %b pp29 = %b pp30 = %b pp31 = %b",pp28,pp29,pp30,pp31);
    $display("---Simulation successful---");
end
endmodule
