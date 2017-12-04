module cla_generator(
    input [3:0] G, P,
    input c_in,
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

    assign Sum = C[3:0] ^ P;
    assign c_out  = C[4];
endmodule


module cla_16bit (
    input  [15:0]  A, B,
    input         c_in,  // PG, GG,
    output        c_out, //PLCU, GLCU,
    output [15:0] Sum);

    wire carry4, carry8, carry12;

    cla_4bit cla4_4(
        .A(A[3:0]),
        .B(B[3:0]),
        .c_in(c_in),
        .Sum(Sum[3:0]),
        .c_out(carry4));
    cla_4bit cla4_8(
        .A(A[7:4]),
        .B(B[7:4]),
        .c_in(carry4),
        .Sum(Sum[7:4]),
        .c_out(carry8));
    cla_4bit cla4_12(
        .A(A[11:8]),
        .B(B[11:8]),
        .c_in(carry8),
        .Sum(Sum[11:8]),
        .c_out(carry12));
    cla_4bit cla4_16(
        .A(A[15:12]),
        .B(B[15:12]),
        .c_in(carry12),
        .Sum(Sum[15:12]),
        .c_out(c_out));
endmodule

module cla_64bit (
    input  [63:0]  A, B,
    input         c_in,  // PLCU, GLCU,
    output        c_out, 
    output [64:0] Sum);

    wire carry16, carry32, carry48;

    cla_16bit cla16_16(
        .A(A[15:0]),
        .B(B[15:0]),
        .c_in(c_in),
        .Sum(Sum[15:0]),
        .c_out(carry16));
    cla_16bit cla16_32(
        .A(A[31:16]),
        .B(B[31:16]),
        .c_in(carry16),
        .Sum(Sum[31:16]),
        .c_out(carry32));
    cla_16bit cla16_48(
        .A(A[47:32]),
        .B(B[47:32]),
        .c_in(carry32),
        .Sum(Sum[47:32]),
        .c_out(carry48));
    cla_16bit cla16_64(
        .A(A[63:48]),
        .B(B[63:48]),
        .c_in(carry48),
        .Sum(Sum[63:48]),
        .c_out(c_out));
endmodule



module multiplier_stage1 #(parameter WIDTH=32) (
    input  [31:0] a, b,
    output [63:0] outA, outB
    );

    wire [310] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8, pp9, pp10, pp11, pp12, pp13, pp14, pp15;                      // 4-bit partial product
    wire [63:0] pad0, pad1, pad2, pad3, pad4, pad5, pa6, pad7, pad8, pad9, pad10, pad11, pad12, pad13, pad14, pad15;  // 8-bit padded pp
    wire [63:0] sum0, sum1, sum2, sum3, sum4, sum5, sum6, sum7;              // pp padded sums
    wire             carry0, carry1, carry2, carry3, carry4, carry5, carry6, carry7, carry8;  // CLA carry bits
    wire             dummy0, dummy2;          // CLA carry out (unused)

    paritial_product partial_prod(
        .a(a),
        .b(b),
        .pp0(pp0),
        .pp1(pp1),
        .pp2(pp2),
        .pp3(pp3),
        .pp4(pp4),
        .pp5(pp5),
        .pp6(pp6),
        .pp7(pp7),
        .pp8(pp8),
        .pp9(pp9),
        .pp10(pp10),
        .pp11(pp11),
        .pp12(pp12),
        .pp13(pp13),
        .pp14(pp14),
        .pp15(pp15)
        );

    assign pad0  = {32'0, pp0}  << 4'b0000;
    assign pad1  = {32'0, pp1}  << 4'b0001;
    assign pad2  = {32'0, pp2}  << 4'b0010;
    assign pad3  = {32'0, pp3}  << 4'b0011;
    assign pad4  = {32'0, pp4}  << 4'b0100;
    assign pad5  = {32'0, pp5}  << 4'b0101;
    assign pad6  = {32'0, pp6}  << 4'b0110;
    assign pad7  = {32'0, pp7}  << 4'b0111;
    assign pad8  = {32'0, pp8}  << 4'b1000;
    assign pad9  = {32'0, pp9}  << 4'b1001;
    assign pad10 = {32'0, pp10} << 4'b1010;
    assign pad11 = {32'0, pp11} << 4'b1011;
    assign pad12 = {32'0, pp12} << 4'b1100;
    assign pad13 = {32'0, pp13} << 4'b1101;
    assign pad14 = {32'0, pp14} << 4'b1110;
    assign pad15 = {32'0, pp15} << 4'b1111;


    // 4 stage Multiplier
    // 2 stage pipepline (2 stages at each pipe)

    // Stage 1
    cla_gen stage0_CLA0( 
        .A(pad0[3:0]), 
        .B(pad1[3:0]), 
        .c_in(1'b0), 
        .Sum(sum0[3:0]), 
        .c_out(carry0));
    cla_gen stage0_CLA1(
        .A(pad0[7:4]), 
        .B(pad1[7:4]), 
        .c_in(carry0), 
        .Sum(sum1[7:4]), 
        .c_out(carry1));
    cla_gen stage0_CLA8(
        .A(pad0[11:8]), 
        .B(pad1[11:8]), 
        .c_in(carry1), 
        .Sum(sum1[7:4]), 
        .c_out(carry1));






    cla_gen stage0_CLA2( 
        .A(pad2[31:0]), 
        .B(pad3[31:0]), 
        .c_in(1'b0), 
        .Sum(sum2[31:0]), 
        .c_out(carry1));
    cla_gen stage0_CLA3(
        .A(pad2[31:32]), 
        .B(pad3[36:32]), 
        .c_in(carry1), 
        .Sum(sum3[63:32]), 
        .c_out(dummy2));
endmodule

module multiplier_stage2 #(parameter WIDTH=32) (
    input  [WIDTH-1:0] sumA, sumB, 
    output [WIDTH-1:0] hi, lo
    );
    
    wire carry_out;  // Carry out of CLA4 -> Carry in CLA5
    wire dummy;      //
    // SUM sum0+sum1=product
    cla_gen cla4( 
        .A(sumA[3:0]), 
        .B(sumB[3:0]), 
        .c_in(1'b0), 
        .Sum(hi[3:0]), 
        .c_out(carry_out));
    cla_gen cla5(
        .A(sumA[7:4]), 
        .B(sumB[7:4]), 
        .c_in(carry_out), 
        .Sum(lo[7:4]), 
        .c_out(dummy));

endmodule

module paritial_product (
    input  [15:0] a, b,   
    output [15:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8, pp9, pp10, pp11, pp12, pp13, pp14, pp15
    );

    integer i;
    always @(*) begin
        for (i = 0; i < 15; i = i+1) begin
            assign pp0[i]   = a[i]  & b[0];
            assign pp1[i]   = a[i]  & b[1];
            assign pp2[i]   = a[i]  & b[2];
            assign pp3[i]   = a[i]  & b[3];
            assign pp4[i]   = a[i]  & b[4];
            assign pp5[i]   = a[i]  & b[5];
            assign pp6[i]   = a[i]  & b[6];
            assign pp7[i]   = a[i]  & b[7];
            assign pp8[i]   = a[i]  & b[8];
            assign pp9[i]   = a[i]  & b[9];
            assign pp10[i]  = a[i]  & b[10];
            assign pp11[i]  = a[i]  & b[11];
            assign pp12[i]  = a[i]  & b[12];
            assign pp13[i]  = a[i]  & b[13];
            assign pp14[i]  = a[i]  & b[14];
            assign pp15[i]  = a[i]  & b[15];
        end // for
    end // always


//     pp0[0]   = a[0]  & b[0];
//     pp1[0]   = a[0]  & b[1];
//     pp2[0]   = a[0]  & b[2];
//     pp3[0]   = a[0]  & b[3];
//     pp4[0]   = a[0]  & b[4];
//     pp5[0]   = a[0]  & b[5];
//     pp6[0]   = a[0]  & b[6];
//     pp7[0]   = a[0]  & b[7];
//     pp8[0]   = a[0]  & b[8];
//     pp9[0]   = a[0]  & b[9];
//     pp10[0]  = a[0]  & b[10];
//     pp11[0]  = a[0]  & b[11];
//     pp12[0]  = a[0]  & b[12];
//     pp13[0]  = a[0]  & b[13];
//     pp14[0]  = a[0]  & b[14];
//     pp15[0]  = a[0]  & b[15];

//     pp0[1]   = a[1]  & b[0];
//     pp1[1]   = a[1]  & b[1];
//     pp2[1]   = a[1]  & b[2];
//     pp3[1]   = a[1]  & b[3];
//     pp4[1]   = a[1]  & b[4];
//     pp5[1]   = a[1]  & b[5];
//     pp6[1]   = a[1]  & b[6];
//     pp7[1]   = a[1]  & b[7];
//     pp8[1]   = a[1]  & b[8];
//     pp9[1]   = a[1]  & b[9];
//     pp10[1]  = a[1]  & b[10];
//     pp11[1]  = a[1]  & b[11];
//     pp12[1]  = a[1]  & b[12];
//     pp13[1]  = a[1]  & b[13];
//     pp14[1]  = a[1]  & b[14];
//     pp15[1]  = a[1]  & b[15];

//     pp0[3]   = a[3]  & b[0];
//     pp1[3]   = a[3]  & b[1];
//     pp2[3]   = a[3]  & b[2];
//     pp3[3]   = a[3]  & b[3];
//     pp4[3]   = a[3]  & b[4];
//     pp5[3]   = a[3]  & b[5];
//     pp6[3]   = a[3]  & b[6];
//     pp7[3]   = a[3]  & b[7];
//     pp8[3]   = a[3]  & b[8];
//     pp9[3]   = a[3]  & b[9];
//     pp10[3]  = a[3]  & b[10];
//     pp11[3]  = a[3]  & b[11];
//     pp12[3]  = a[3]  & b[12];
//     pp13[3]  = a[3]  & b[13];
//     pp14[3]  = a[3]  & b[14];
//     pp15[3]  = a[3]  & b[15];

//     pp0[4]   = a[4]  & b[0];
//     pp1[4]   = a[4]  & b[1];
//     pp2[4]   = a[4]  & b[2];
//     pp3[4]   = a[4]  & b[3];
//     pp4[4]   = a[4]  & b[4];
//     pp5[4]   = a[4]  & b[5];
//     pp6[4]   = a[4]  & b[6];
//     pp7[4]   = a[4]  & b[7];
//     pp8[4]   = a[4]  & b[8];
//     pp9[4]   = a[4]  & b[9];
//     pp10[4]  = a[4]  & b[10];
//     pp11[4]  = a[4]  & b[11];
//     pp12[4]  = a[4]  & b[12];
//     pp13[4]  = a[4]  & b[13];
//     pp14[4]  = a[4]  & b[14];
//     pp15[4]  = a[4]  & b[15];

//     pp0[5]   = a[5]  & b[0];
//     pp1[5]   = a[5]  & b[1];
//     pp2[5]   = a[5]  & b[2];
//     pp3[5]   = a[5]  & b[3];
//     pp4[5]   = a[5]  & b[4];
//     pp5[5]   = a[5]  & b[5];
//     pp6[5]   = a[5]  & b[6];
//     pp7[5]   = a[5]  & b[7];
//     pp8[5]   = a[5]  & b[8];
//     pp9[5]   = a[5]  & b[9];
//     pp10[5]  = a[5]  & b[10];
//     pp11[5]  = a[5]  & b[11];
//     pp12[5]  = a[5]  & b[12];
//     pp13[5]  = a[5]  & b[13];
//     pp14[5]  = a[5]  & b[14];
//     pp15[5]  = a[5]  & b[15];

//     pp0[6]   = a[6]  & b[0];
//     pp1[6]   = a[6]  & b[1];
//     pp2[6]   = a[6]  & b[2];
//     pp3[6]   = a[6]  & b[3];
//     pp4[6]   = a[6]  & b[4];
//     pp5[6]   = a[6]  & b[5];
//     pp6[6]   = a[6]  & b[6];
//     pp7[6]   = a[6]  & b[7];
//     pp8[6]   = a[6]  & b[8];
//     pp9[6]   = a[6]  & b[9];
//     pp10[6]  = a[6]  & b[10];
//     pp11[6]  = a[6]  & b[11];
//     pp12[6]  = a[6]  & b[12];
//     pp13[6]  = a[6]  & b[13];
//     pp14[6]  = a[6]  & b[14];
//     pp15[6]  = a[6]  & b[15];

//     pp0[7]   = a[7]  & b[0];
//     pp1[7]   = a[7]  & b[1];
//     pp2[7]   = a[7]  & b[2];
//     pp3[7]   = a[7]  & b[3];
//     pp4[7]   = a[7]  & b[4];
//     pp5[7]   = a[7]  & b[5];
//     pp6[7]   = a[7]  & b[6];
//     pp7[7]   = a[7]  & b[7];
//     pp8[7]   = a[7]  & b[8];
//     pp9[7]   = a[7]  & b[9];
//     pp10[7]  = a[7]  & b[10];
//     pp11[7]  = a[7]  & b[11];
//     pp12[7]  = a[7]  & b[12];
//     pp13[7]  = a[7]  & b[13];
//     pp14[7]  = a[7]  & b[14];
//     pp15[7]  = a[7]  & b[15];

//     pp0[8]   = a[8]  & b[0];
//     pp1[8]   = a[8]  & b[1];
//     pp2[8]   = a[8]  & b[2];
//     pp3[8]   = a[8]  & b[3];
//     pp4[8]   = a[8]  & b[4];
//     pp5[8]   = a[8]  & b[5];
//     pp6[8]   = a[8]  & b[6];
//     pp7[8]   = a[8]  & b[7];
//     pp8[8]   = a[8]  & b[8];
//     pp9[8]   = a[8]  & b[9];
//     pp10[8]  = a[8]  & b[10];
//     pp11[8]  = a[8]  & b[11];
//     pp12[8]  = a[8]  & b[12];
//     pp13[8]  = a[8]  & b[13];
//     pp14[8]  = a[8]  & b[14];
//     pp15[8]  = a[8]  & b[15];

//     pp0[9]   = a[9]  & b[0];
//     pp1[9]   = a[9]  & b[1];
//     pp2[9]   = a[9]  & b[2];
//     pp3[9]   = a[9]  & b[3];
//     pp4[9]   = a[9]  & b[4];
//     pp5[9]   = a[9]  & b[5];
//     pp6[9]   = a[9]  & b[6];
//     pp7[9]   = a[9]  & b[7];
//     pp8[9]   = a[9]  & b[8];
//     pp9[9]   = a[9]  & b[9];
//     pp10[9]  = a[9]  & b[10];
//     pp11[9]  = a[9]  & b[11];
//     pp12[9]  = a[9]  & b[12];
//     pp13[9]  = a[9]  & b[13];
//     pp14[9]  = a[9]  & b[14];
//     pp15[9]  = a[9]  & b[15];

//     pp0[10]   = a[10]  & b[0];
//     pp1[10]   = a[10]  & b[1];
//     pp2[10]   = a[10]  & b[2];
//     pp3[10]   = a[10]  & b[3];
//     pp4[10]   = a[10]  & b[4];
//     pp5[10]   = a[10]  & b[5];
//     pp6[10]   = a[10]  & b[6];
//     pp7[10]   = a[10]  & b[7];
//     pp8[10]   = a[10]  & b[8];
//     pp9[10]   = a[10]  & b[9];
//     pp10[10]  = a[10]  & b[10];
//     pp11[10]  = a[10]  & b[11];
//     pp12[10]  = a[10]  & b[12];
//     pp13[10]  = a[10]  & b[13];
//     pp14[10]  = a[10]  & b[14];
//     pp15[10]  = a[10]  & b[15];

//     pp0[11]   = a[11]  & b[0];
//     pp1[11]   = a[11]  & b[1];
//     pp2[11]   = a[11]  & b[2];
//     pp3[11]   = a[11]  & b[3];
//     pp4[11]   = a[11]  & b[4];
//     pp5[11]   = a[11]  & b[5];
//     pp6[11]   = a[11]  & b[6];
//     pp7[11]   = a[11]  & b[7];
//     pp8[11]   = a[11]  & b[8];
//     pp9[11]   = a[11]  & b[9];
//     pp10[11]  = a[11]  & b[10];
//     pp11[11]  = a[11]  & b[11];
//     pp12[11]  = a[11]  & b[12];
//     pp13[11]  = a[11]  & b[13];
//     pp14[11]  = a[11]  & b[14];
//     pp15[11]  = a[11]  & b[15];

//     pp0[12]   = a[12]  & b[0];
//     pp1[12]   = a[12]  & b[1];
//     pp2[12]   = a[12]  & b[2];
//     pp3[12]   = a[12]  & b[3];
//     pp4[12]   = a[12]  & b[4];
//     pp5[12]   = a[12]  & b[5];
//     pp6[12]   = a[12]  & b[6];
//     pp7[12]   = a[12]  & b[7];
//     pp8[12]   = a[12]  & b[8];
//     pp9[12]   = a[12]  & b[9];
//     pp10[12]  = a[12]  & b[10];
//     pp11[12]  = a[12]  & b[11];
//     pp12[12]  = a[12]  & b[12];
//     pp13[12]  = a[12]  & b[13];
//     pp14[12]  = a[12]  & b[14];
//     pp15[12]  = a[12]  & b[15];

//     pp0[13]   = a[13]  & b[0];
//     pp1[13]   = a[13]  & b[1];
//     pp2[13]   = a[13]  & b[2];
//     pp3[13]   = a[13]  & b[3];
//     pp4[13]   = a[13]  & b[4];
//     pp5[13]   = a[13]  & b[5];
//     pp6[13]   = a[13]  & b[6];
//     pp7[13]   = a[13]  & b[7];
//     pp8[13]   = a[13]  & b[8];
//     pp9[13]   = a[13]  & b[9];
//     pp10[13]  = a[13]  & b[10];
//     pp11[13]  = a[13]  & b[11];
//     pp12[13]  = a[13]  & b[12];
//     pp13[13]  = a[13]  & b[13];
//     pp14[13]  = a[13]  & b[14];
//     pp15[13]  = a[13]  & b[15];

//     pp0[14]   = a[14]  & b[0];
//     pp1[14]   = a[14]  & b[1];
//     pp2[14]   = a[14]  & b[2];
//     pp3[14]   = a[14]  & b[3];
//     pp4[14]   = a[14]  & b[4];
//     pp5[14]   = a[14]  & b[5];
//     pp6[14]   = a[14]  & b[6];
//     pp7[14]   = a[14]  & b[7];
//     pp8[14]   = a[14]  & b[8];
//     pp9[14]   = a[14]  & b[9];
//     pp10[14]  = a[14]  & b[10];
//     pp11[14]  = a[14]  & b[11];
//     pp12[14]  = a[14]  & b[12];
//     pp13[14]  = a[14]  & b[13];
//     pp14[14]  = a[14]  & b[14];
//     pp15[14]  = a[14]  & b[15];

//     pp0[15]   = a[15]  & b[0];
//     pp1[15]   = a[15]  & b[1];
//     pp2[15]   = a[15]  & b[2];
//     pp3[15]   = a[15]  & b[3];
//     pp4[15]   = a[15]  & b[4];
//     pp5[15]   = a[15]  & b[5];
//     pp6[15]   = a[15]  & b[6];
//     pp7[15]   = a[15]  & b[7];
//     pp8[15]   = a[15]  & b[8];
//     pp9[15]   = a[15]  & b[9];
//     pp10[15]  = a[15]  & b[10];
//     pp11[15]  = a[15]  & b[11];
//     pp12[15]  = a[15]  & b[12];
//     pp13[15]  = a[15]  & b[13];
//     pp14[15]  = a[15]  & b[14];
//     pp15[15]  = a[15]  & b[15];
endmodule 