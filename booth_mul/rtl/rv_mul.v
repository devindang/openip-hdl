//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2023, devin
//  balddonkey@outlook.com
//
//-------------------------------------------------------------------
// Title       : rv_mul.V
// Author      : Devin
// Editor      : code
// Created     : 2023-08-09 20:13:16
// Description : radix4-booth-wallace multiplier.
//
// $Id$
//-------------------------------------------------------------------

`timescale 1ns / 1ps

module rv_mul(
    input               clk,
    input               rstn,
    input       [63:0]  mul_op1_i,  // multiplicand
    input       [63:0]  mul_op2_i,  // multiplier
    output  reg [63:0]  mul_result_o
);

//------------------------ SIGNALS ------------------------//

wire [31:0]  z0;            // abs(z) = 1
wire [31:0]  z1;            // abs(z) = 2, use the shifted one
wire [31:0]  n;             // negative
wire [64:0]  pp   [31:0];   // partial product, consider shift
wire [64:0]  pp2c [31:0];   // partial product with 2's complement
wire [127:0] fpp  [31:0];   // final partial product
wire [127:0] st1  [19:0];
wire [127:0] st2  [13:0];
reg  [127:0] st2r [13:0];   // reg
wire [127:0] st3  [9:0];
wire [127:0] st4  [5:0];
wire [127:0] st5  [3:0];
reg  [127:0] st5r [3:0];    // reg
wire [127:0] st6  [1:0];
wire [127:0] st7  [1:0];
wire [127:0] st8  [1:0];
wire [127:0] result;

//------------------------ PROCESS ------------------------//

//************************* Stage 0: BOOTH ENCODE *************************//

//  Booth Encoding & Partial Product Generation

genvar b, u;    // u for unit, b for bit
generate
    for(u=0; u<32; u=u+1) begin : for_encode
        if(u==0) begin
            booth_encoder be0(
                .y   ({mul_op2_i[1], mul_op2_i[0], 1'b0}),
                .z0  (z0[u]),
                .z1  (z1[u]),
                .neg (n[u])
            );
        end else if(u==31) begin
            booth_encoder be1(
                .y   ({1'b0, 1'b0, mul_op2_i[63]}),
                .z0  (z0[u]),
                .z1  (z1[u]),
                .neg (n[u])
            );
        end else begin
            booth_encoder be2(
                .y   ({mul_op2_i[2*u+1], mul_op2_i[2*u], mul_op2_i[2*u-1]}),
                .z0  (z0[u]),
                .z1  (z1[u]),
                .neg (n[u])
            );
        end
        for(b=0; b<64; b=b+1) begin : for_sel
            if(b==0) begin
                booth_selector bs(     // LSB
                    .z0  (z0[u]),
                    .z1  (z1[u]),
                    .x   (mul_op1_i[b]),
                    .xs  (1'b0),
                    .neg (n[u]),
                    .p   (pp[u][b])
                );
                booth_selector bs0(
                    .z0  (z0[u]),
                    .z1  (z1[u]),
                    .x   (mul_op1_i[b+1]),
                    .xs  (mul_op1_i[b]),
                    .neg (n[u]),
                    .p   (pp[u][b+1])
                );
            end else if(b==63) begin
                booth_selector u_bs(
                    .z0  (z0[u]),
                    .z1  (z1[u]),
                    .x   (1'b0),
                    .xs  (mul_op1_i[b]),
                    .neg (n[u]),
                    .p   (pp[u][b+1])
                );
            end else begin
                booth_selector u_bs(
                    .z0  (z0[u]),
                    .z1  (z1[u]),
                    .x   (mul_op1_i[b+1]),
                    .xs  (mul_op1_i[b]),
                    .neg (n[u]),
                    .p   (pp[u][b+1])
                );
            end
        end
        RCA #(65) u_rca(
            .a    (pp[u]),
            .b    ({64'd0,n[u]}),
            .cin  (1'b0),
            .sum  (pp2c[u]),
            .cout ()
        );
    end
endgenerate

// perform shift
genvar i;
generate
    for(i=0; i<32; i=i+1) begin : for_shift
        if(i==31) begin
            assign fpp[i] = {pp2c[31][63:0], {64{1'b0}}};
        end else begin
            assign fpp[i] = {{(63-2*i){n[i]  & (z0[i]  | z1[i])}} , pp2c[i], {(2*i){1'b0}}} ;
        end
    end
endgenerate


//***************************** Stage 1 *****************************//

genvar i1;
generate
    for(i1=0; i1<10; i1=i1+1) begin : for_st1
        CSA u_csa1(
            .a    (fpp[3*i1]),
            .b    (fpp[3*i1+1]),
            .cin  (fpp[3*i1+2]),
            .sum  (st1[2*i1]),
            .cout (st1[2*i1+1])
        );
    end
endgenerate

//***************************** Stage 2 REG *****************************//

genvar i2;
generate
    for(i2=0; i2<6; i2=i2+1) begin : for_st2
        CSA u_csa2(
            .a    (st1[3*i2]),
            .b    (st1[3*i2+1]),
            .cin  (st1[3*i2+2]),
            .sum  (st2[2*i2]),
            .cout (st2[2*i2+1])
        );
    end
    CSA u_csa2(
        .a    (st1[18]),
        .b    (st1[19]),
        .cin  (fpp[30]),
        .sum  (st2[12]),
        .cout (st2[13])
    );
endgenerate

integer r2;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        for(r2=0; r2<14; r2=r2+1) begin
            st2r[r2] <= 'd0;
        end
    end else begin
        for(r2=0; r2<14; r2=r2+1) begin
            st2r[r2] <= st2[r2];
        end
    end
end

//***************************** Stage 3 *****************************//

genvar i3;
generate
    for(i3=0; i3<4; i3=i3+1) begin : for_st3
        CSA u_csa3(
            .a    (st2r[3*i3]),
            .b    (st2r[3*i3+1]),
            .cin  (st2r[3*i3+2]),
            .sum  (st3[2*i3]),
            .cout (st3[2*i3+1])
        );
    end
    CSA u_csa3(
        .a    (st2r[12]),
        .b    (st2r[13]),
        .cin  (fpp [31]),
        .sum  (st3 [8]),
        .cout (st3 [9])   // remain
    );
endgenerate

//***************************** Stage 4 *****************************//

genvar i4;
generate
    for(i4=0; i4<3; i4=i4+1) begin : for_st4
        CSA u_csa4(
            .a    (st3[3*i4]),
            .b    (st3[3*i4+1]),
            .cin  (st3[3*i4+2]),
            .sum  (st4[2*i4]),
            .cout (st4[2*i4+1])
        );
    end
endgenerate

//***************************** Stage 5 REG *****************************//

genvar i5;
generate
    for(i5=0; i5<2; i5=i5+1) begin : for_st5
        CSA u_csa5(
            .a    (st4[3*i5]),
            .b    (st4[3*i5+1]),
            .cin  (st4[3*i5+2]),
            .sum  (st5[2*i5]),
            .cout (st5[2*i5+1])
        );
    end
endgenerate

integer r5;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        for(r5=0; r5<4; r5=r5+1) begin
            st5r[r5] <= 'd0;
        end
    end else begin
        for(r5=0; r5<4; r5=r5+1) begin
            st5r[r5] <= st5[r5];
        end
    end
end

//***************************** Stage 6 *****************************//

generate
    CSA u_csa6(
        .a    (st5r[0]),
        .b    (st5r[1]),
        .cin  (st5r[2]),
        .sum  (st6 [0]),
        .cout (st6 [1])
    );
endgenerate

//***************************** Stage 7 *****************************//

generate
    CSA u_csa7(
        .a    (st6 [0]),
        .b    (st6 [1]),
        .cin  (st5r[3]),
        .sum  (st7 [0]),
        .cout (st7 [1])
    );
endgenerate

//***************************** Stage 8 REG *****************************//

generate
    CSA u_csa8(
        .a    (st7[0]),
        .b    (st7[1]),
        .cin  (st3[9]),
        .sum  (st8[0]),
        .cout (st8[1])
    );
endgenerate

assign result = st8[0] + st8[1];    // half adder by compiler

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        mul_result_o <= 64'd0;
    end else begin
        mul_result_o <= result[63:0];
    end
end

endmodule

//------------------------ SUBROUTINE ------------------------//

// Booth Encoder
module booth_encoder(y,z0,z1,neg);
input [2:0] y;      // y_{i+1}, y_i, y_{i-1}
output      z0;     // abs(z) = 1
output      z1;     // abs(z) = 2, use the shifted one
output      neg;    // negative
assign z0 = y[0] ^ y[1];
assign z1 = (y[0] & y[1] & ~y[2]) | (~y[0] & ~y[1] &y[2]);
assign neg = y[2] & ~(y[1] & y[0]);
endmodule

// Booth Selector
module booth_selector(z0,z1,x,xs,neg,p);
input   z0;
input   z1;
input   x;
input   xs;     // x shifted
input   neg;
output  p;      // product
assign  p = (neg ^ ((z0 & x) | (z1 & xs)));
endmodule

// Carry Save Adder
module CSA #(
    parameter WID = 128
)(a, b, cin, sum, cout);
input  [WID-1:0] a, b, cin;
output [WID-1:0] sum, cout;
wire   [WID-1:0] c; // shift 1-bit
genvar i;
generate
    for(i=0; i<WID; i=i+1) begin : for_csa
        if(i==WID-1) begin
            FA u_fa(
                .a    (a[i]),
                .b    (b[i]),
                .cin  (cin[i]),
                .sum  (sum[i]),
                .cout ()
            );
        end else begin
            FA u_fa(
                .a    (a[i]),
                .b    (b[i]),
                .cin  (cin[i]),
                .sum  (sum[i]),
                .cout (c[i+1])
            );
        end
    end
endgenerate
assign cout = {c[WID-1:1],1'b0};
endmodule

// Ripple Carry Adder
module RCA #(
    parameter WID = 64
)(a, b, cin, sum, cout);
input  [WID-1:0] a, b;
input  cin;
output [WID-1:0] sum;
output cout;
wire   [WID-1:0] c;
genvar i;
generate
    for(i=0; i<WID; i=i+1) begin : for_rca
        if(i==0) begin
            FA u_fa(
                .a    (a[i]),
                .b    (b[i]),
                .cin  (cin),
                .sum  (sum[i]),
                .cout (c[i])
            );
        end else begin
            FA u_fa(
                .a    (a[i]),
                .b    (b[i]),
                .cin  (c[i-1]),
                .sum  (sum[i]),
                .cout (c[i])
            );
        end
    end
endgenerate
assign cout = c[WID-1];
endmodule

// Full Adder
module FA(a,b,cin,sum,cout);
input  a, b, cin;
output sum, cout;
wire   x, y, z;
xor x1(x,a,b);
xor x2(sum,x,cin);
and a1(y,a,b);
and a2(z,x,cin);
or  o1(cout,y,z);
endmodule