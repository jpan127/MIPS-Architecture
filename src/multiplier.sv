module cla_generator(
    input  [3:0] G, P,
    input        c_in,
    output [4:0] C);
    
    assign C[0] = c_in;
    assign C[1] = G[0] | (P[0]&C[0]);
    assign C[2] = G[1] | (G[0]&P[1]) | (C[0]&P[0]&P[1]);
    assign C[3] = G[2] | (G[1]&P[2]) | (G[0]&P[1]&P[2]) | (C[0]&P[0]&P[1]&P[2]);
    assign C[4] = G[3] | (G[2]&P[3]) | (G[1]&P[2]&P[3]) | (G[0]&P[1]&P[2]&P[3]) | (C[0]&P[0]&P[1]&P[2]&P[3]);
endmodule

module cla_4bit( 
    input  [3:0] A, B,
    input        c_in,
    output       c_out, //PG, GG,
    output [3:0] Sum);

    wire [3:0] P, G;
    wire [4:0] C;

    assign P = A ^ B;
    assign G = A & B;

    cla_generator cla_gen(
        .G(G),
        .P(P),
        .c_in(c_in),
        .C(C));

    assign Sum    = C[3:0] ^ P;
    assign c_out  = C[4];
endmodule


module cla_16bit (
    input  [15:0] A, B,
    input         c_in,  // PG, GG,
    output        c_out, //PLCU, GLCU,
    output [15:0] Sum);

    wire carry4, carry8, carry12;

    cla_4bit cla4_4(
        .A(A[3:0]), .B(B[3:0]),     .c_in(c_in),
        .Sum(Sum[3:0]),             .c_out(carry4));
    cla_4bit cla4_8(
        .A(A[7:4]), .B(B[7:4]),     .c_in(carry4),
        .Sum(Sum[7:4]),             .c_out(carry8));
    cla_4bit cla4_12(
        .A(A[11:8]), .B(B[11:8]),   .c_in(carry8),
        .Sum(Sum[11:8]),            .c_out(carry12));
    cla_4bit cla4_16(
        .A(A[15:12]), .B(B[15:12]), .c_in(carry12),
        .Sum(Sum[15:12]),           .c_out(c_out));
endmodule

module cla_64bit (
    input  [63:0] A, B,
    input         c_in,  // PLCU, GLCU,
    output        c_out, 
    output [63:0] Sum);

    wire carry16, carry32, carry48;

    cla_16bit cla16_16(
        .A(A[15:0]), .B(B[15:0]),   .c_in(c_in),
        .Sum(Sum[15:0]),            .c_out(carry16));
    cla_16bit cla16_32(
        .A(A[31:16]), .B(B[31:16]), .c_in(carry16),
        .Sum(Sum[31:16]),           .c_out(carry32));
    cla_16bit cla16_48(
        .A(A[47:32]), .B(B[47:32]), .c_in(carry32),
        .Sum(Sum[47:32]),           .c_out(carry48));
    cla_16bit cla16_64(
        .A(A[63:48]), .B(B[63:48]), .c_in(carry48),
        .Sum(Sum[63:48]),           .c_out(c_out));
endmodule

module multiplier32bit_single_stage (
    input  [31:0] A, B,
    output [63:0] product);
    
    // 32-bit Partial Products
    wire [31:0] pp0,  pp1,  pp2,  pp3,  pp4,  pp5,  pp6,  pp7, 
                pp8,  pp9,  pp10, pp11, pp12, pp13, pp14, pp15,
                pp16, pp17, pp18, pp19, pp20, pp21, pp22, pp23, 
                pp24, pp25, pp26, pp27, pp28, pp29, pp30, pp31;

    partial_product pp_32(
        .a    (A),      .b    (B),
        .pp0  (pp0),    .pp1  (pp1),    .pp2  (pp2),    .pp3  (pp3),
        .pp4  (pp4),    .pp5  (pp5),    .pp6  (pp6),    .pp7  (pp7),
        .pp8  (pp8),    .pp9  (pp9),    .pp10 (pp10),   .pp11 (pp11),   
        .pp12 (pp12),   .pp13 (pp13),   .pp14 (pp14),   .pp15 (pp15),   
        .pp16 (pp16),   .pp17 (pp17),   .pp18 (pp18),   .pp19 (pp19),   
        .pp20 (pp20),   .pp21 (pp21),   .pp22 (pp22),   .pp23 (pp23),   
        .pp24 (pp24),   .pp25 (pp25),   .pp26 (pp26),   .pp27 (pp27),
        .pp28 (pp28),   .pp29 (pp29),   .pp30 (pp30),   .pp31 (pp31));

    // 64-bit Padded Partial Products
    wire [63:0] pad0,  pad1,  pad2,  pad3,  pad4,  pad5,  pad6,  pad7, 
                pad8,  pad9,  pad10, pad11, pad12, pad13, pad14, pad15,
                pad16, pad17, pad18, pad19, pad20, pad21, pad22, pad23, 
                pad24, pad25, pad26, pad27, pad28, pad29, pad30, pad31;

    assign pad0  = {32'b0, pp0}  << 5'b00000;
    assign pad1  = {32'b0, pp1}  << 5'b00001;
    assign pad2  = {32'b0, pp2}  << 5'b00010;
    assign pad3  = {32'b0, pp3}  << 5'b00011;
    assign pad4  = {32'b0, pp4}  << 5'b00100;
    assign pad5  = {32'b0, pp5}  << 5'b00101;
    assign pad6  = {32'b0, pp6}  << 5'b00110;
    assign pad7  = {32'b0, pp7}  << 5'b00111;
    assign pad8  = {32'b0, pp8}  << 5'b01000;
    assign pad9  = {32'b0, pp9}  << 5'b01001;
    assign pad10 = {32'b0, pp10} << 5'b01010;
    assign pad11 = {32'b0, pp11} << 5'b01011;
    assign pad12 = {32'b0, pp12} << 5'b01100;
    assign pad13 = {32'b0, pp13} << 5'b01101;
    assign pad14 = {32'b0, pp14} << 5'b01110;
    assign pad15 = {32'b0, pp15} << 5'b01111;
    assign pad16 = {32'b0, pp16} << 5'b10000;
    assign pad17 = {32'b0, pp17} << 5'b10001;
    assign pad18 = {32'b0, pp18} << 5'b10010;
    assign pad19 = {32'b0, pp19} << 5'b10011;
    assign pad20 = {32'b0, pp20} << 5'b10100;
    assign pad21 = {32'b0, pp21} << 5'b10101;
    assign pad22 = {32'b0, pp22} << 5'b10110;
    assign pad23 = {32'b0, pp23} << 5'b10111;
    assign pad24 = {32'b0, pp24} << 5'b11000;
    assign pad25 = {32'b0, pp25} << 5'b11001;
    assign pad26 = {32'b0, pp26} << 5'b11010;
    assign pad27 = {32'b0, pp27} << 5'b11011;
    assign pad28 = {32'b0, pp28} << 5'b11100;
    assign pad29 = {32'b0, pp29} << 5'b11101;
    assign pad30 = {32'b0, pp30} << 5'b11110;
    assign pad31 = {32'b0, pp31} << 5'b11111;
        
    // Padded Partial Product Sums
    // 0th Level Sums
    wire [63:0] sumL0_0, sumL0_1, sumL0_2,  sumL0_3,  sumL0_4,  sumL0_5,  sumL0_6,  sumL0_7,
                sumL0_8, sumL0_9, sumL0_10, sumL0_11, sumL0_12, sumL0_13, sumL0_14, sumL0_15;
    // 1st Level Sums
    wire [63:0] sumL1_0, sumL1_1, sumL1_2,  sumL1_3,  sumL1_4,  sumL1_5,  sumL1_6,  sumL1_7;
    // 2nd Level Sums
    wire [63:0] sumL2_0, sumL2_1, sumL2_2, sumL2_3;
    // 3rd Level Sums
    wire [63:0] sumL3_0, sumL3_1; 
    // 4th Level Sum
    wire [63:0] sumL4_0; // Product

    // CLA Carry Bits (dummy bits - unused)
    wire d0,  d1,  d2,  d3,  d4,  d5,  d6,  d7,  d8,  d9,  d10, d11, d12, d13, d14, d15;
    wire d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31;

    // Oth Level
    cla_64bit cla_64bitL0_0   (.A(pad0[63:0]),  .B(pad1[63:0]),  .c_in(1'b0), .c_out(d0),  .Sum(sumL0_0));
    cla_64bit cla_64bitL0_1   (.A(pad2[63:0]),  .B(pad3[63:0]),  .c_in(1'b0), .c_out(d1),  .Sum(sumL0_1));
    cla_64bit cla_64bitL0_2   (.A(pad4[63:0]),  .B(pad5[63:0]),  .c_in(1'b0), .c_out(d2),  .Sum(sumL0_2));
    cla_64bit cla_64bitL0_3   (.A(pad6[63:0]),  .B(pad7[63:0]),  .c_in(1'b0), .c_out(d3),  .Sum(sumL0_3));
    cla_64bit cla_64bitL0_4   (.A(pad8[63:0]),  .B(pad9[63:0]),  .c_in(1'b0), .c_out(d4),  .Sum(sumL0_4));
    cla_64bit cla_64bitL0_5   (.A(pad10[63:0]), .B(pad11[63:0]), .c_in(1'b0), .c_out(d5),  .Sum(sumL0_5));
    cla_64bit cla_64bitL0_6   (.A(pad12[63:0]), .B(pad13[63:0]), .c_in(1'b0), .c_out(d6),  .Sum(sumL0_6));
    cla_64bit cla_64bitL0_7   (.A(pad14[63:0]), .B(pad15[63:0]), .c_in(1'b0), .c_out(d7),  .Sum(sumL0_7));
    cla_64bit cla_64bitL0_8   (.A(pad16[63:0]), .B(pad17[63:0]), .c_in(1'b0), .c_out(d8),  .Sum(sumL0_8));
    cla_64bit cla_64bitL0_9   (.A(pad18[63:0]), .B(pad19[63:0]), .c_in(1'b0), .c_out(d9),  .Sum(sumL0_9));
    cla_64bit cla_64bitL0_10  (.A(pad20[63:0]), .B(pad21[63:0]), .c_in(1'b0), .c_out(d10), .Sum(sumL0_10));
    cla_64bit cla_64bitL0_11  (.A(pad22[63:0]), .B(pad23[63:0]), .c_in(1'b0), .c_out(d11), .Sum(sumL0_11));
    cla_64bit cla_64bitL0_12  (.A(pad24[63:0]), .B(pad25[63:0]), .c_in(1'b0), .c_out(d12), .Sum(sumL0_12));
    cla_64bit cla_64bitL0_13  (.A(pad26[63:0]), .B(pad27[63:0]), .c_in(1'b0), .c_out(d13), .Sum(sumL0_13));
    cla_64bit cla_64bitL0_14  (.A(pad28[63:0]), .B(pad29[63:0]), .c_in(1'b0), .c_out(d14), .Sum(sumL0_14));
    cla_64bit cla_64bitL0_15  (.A(pad30[63:0]), .B(pad31[63:0]), .c_in(1'b0), .c_out(d15), .Sum(sumL0_15));

    // 1st Level
    cla_64bit cla_64bitL1_0   (.A(sumL0_0[63:0]),  .B(sumL0_1[63:0]),  .c_in(1'b0), .c_out(d16), .Sum(sumL1_0));
    cla_64bit cla_64bitL1_1   (.A(sumL0_2[63:0]),  .B(sumL0_3[63:0]),  .c_in(1'b0), .c_out(d17), .Sum(sumL1_1));
    cla_64bit cla_64bitL1_2   (.A(sumL0_4[63:0]),  .B(sumL0_5[63:0]),  .c_in(1'b0), .c_out(d18), .Sum(sumL1_2));
    cla_64bit cla_64bitL1_3   (.A(sumL0_6[63:0]),  .B(sumL0_7[63:0]),  .c_in(1'b0), .c_out(d19), .Sum(sumL1_3));
    cla_64bit cla_64bitL1_4   (.A(sumL0_8[63:0]),  .B(sumL0_9[63:0]),  .c_in(1'b0), .c_out(d20), .Sum(sumL1_4));
    cla_64bit cla_64bitL1_5   (.A(sumL0_10[63:0]), .B(sumL0_11[63:0]), .c_in(1'b0), .c_out(d21), .Sum(sumL1_5));
    cla_64bit cla_64bitL1_6   (.A(sumL0_12[63:0]), .B(sumL0_13[63:0]), .c_in(1'b0), .c_out(d22), .Sum(sumL1_6));
    cla_64bit cla_64bitL1_7   (.A(sumL0_14[63:0]), .B(sumL0_15[63:0]), .c_in(1'b0), .c_out(d23), .Sum(sumL1_7));

    // 2nd Level
    cla_64bit cla_64bitL2_0   (.A(sumL1_0[63:0]),  .B(sumL1_1[63:0]),  .c_in(1'b0), .c_out(d24), .Sum(sumL2_0));
    cla_64bit cla_64bitL2_1   (.A(sumL1_2[63:0]),  .B(sumL1_3[63:0]),  .c_in(1'b0), .c_out(d25), .Sum(sumL2_1));
    cla_64bit cla_64bitL2_2   (.A(sumL1_4[63:0]),  .B(sumL1_5[63:0]),  .c_in(1'b0), .c_out(d26), .Sum(sumL2_2));
    cla_64bit cla_64bitL2_3   (.A(sumL1_6[63:0]),  .B(sumL1_7[63:0]),  .c_in(1'b0), .c_out(d27), .Sum(sumL2_3));

    // 3rd Level
    cla_64bit cla_64bitL3_0   (.A(sumL2_0[63:0]),  .B(sumL2_1[63:0]),  .c_in(1'b0), .c_out(d28), .Sum(sumL3_0));
    cla_64bit cla_64bitL3_1   (.A(sumL2_2[63:0]),  .B(sumL2_3[63:0]),  .c_in(1'b0), .c_out(d29), .Sum(sumL3_1));

    // 4rd Level
    cla_64bit cla_64bitL4_0   (.A(sumL3_0[63:0]),  .B(sumL3_1[63:0]),  .c_in(1'b0), .c_out(d30), .Sum(sumL4_0));

    assign product = sumL4_0;
endmodule
