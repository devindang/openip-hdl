//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2023, devin
//  balddonkey@outlook.com
//
//-------------------------------------------------------------------
// Title       : srt_r4.v
// Author      : Devin
// Editor      : VIM
// Created     : 2023-08-17 11:32:09
// Description :
//
// $Id$
//-------------------------------------------------------------------

`timescale 1ns / 1ps

module srt_r4(
	input			  clk,
	input			  rstn,
	input		[7:0] op1_i,	// dividend
	input 		[7:0] op2_i,	// divisor
	output reg  [7:0] rem_o,
	output reg  [7:0] quo_o
);

//------------------------ SIGNALS ------------------------//

wire [2:0] op1_ld;	// leading digit
wire [2:0] op2_ld;
wire [7:0] op1_n;	// normalized
wire [7:0] op2_n;
reg  [7:0] op2_nr [3:0];
reg  [8:0] rem_r [3:0];	// 1-bit expand
wire [1:0] q [3:0];		// half
wire [3:0] n;			// half
reg  [7:0] Q_reg[3:0];
reg  [7:0] QM_reg[3:0];
reg  [2:0] op1_ld_r[3:0];
reg  [2:0] op2_ld_r[3:0];	// op2 leading digit register
wire [2:0] subs;
wire [2:0] iter;

//------------------------ PROCESS ------------------------//

//**************************** Find Leading 1s or 0s ****************************//
find_ld #(8) u_find_ld1 (.op(op1_i), .pos(op1_ld));
find_ld #(8) u_find_ld2 (.op(op2_i), .pos(op2_ld));
assign op1_n = (op1_ld>2) ? (op1_i << (op1_ld-2)) : op1_i;	// opt
assign op2_n = op2_i << op2_ld;
assign q[0] = 2'b00;
assign n[0] = 1'b0;
genvar i;
generate
	for(i=0; i<7; i=i+1) begin : for_qds
		qds u_qds(
			.r_idx(rem_r[i][6:2]),	// 4r_{i-1}
			.d_idx(op2_nr[i][7:3]),
			.q(q[i+1]),
			.neg(n[i+1])
		);
	end
endgenerate
integer i1;
always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		for(i1=0; i1<4; i1=i1+1) begin
			op1_ld_r[i1] <= 3'd0;
			op2_ld_r[i1] <= 3'd0;
		end
	end else begin
		op1_ld_r[0] <= op1_ld;
		op2_ld_r[0] <= op2_ld;
		for(i1=0; i1<3; i1=i1+1) begin
			op1_ld_r[i1+1] <= op1_ld_r[i1];
			op2_ld_r[i1+1] <= op2_ld_r[i1];
		end
	end
end

//**************************** Residual Remainder ****************************//
always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		rem_r[0] <= 9'd0;
	end else begin
		rem_r[0] <= {op1_n[7],op1_n};
	end
end
genvar j;
generate
	for(j=0; j<3; j=j+1) begin : for_rem
		always @(posedge clk or negedge rstn) begin
			if(!rstn) begin
				rem_r[j+1] <= 9'd0;
			end else begin
				case({n[j+1],q[j+1]})
					3'b000: rem_r[j+1] <= {rem_r[j][6:0],2'b00};
					3'b001: rem_r[j+1] <= {rem_r[j][6:0],2'b00}-{op2_n[7],op2_n};	// -D
					3'b010: rem_r[j+1] <= {rem_r[j][6:0],2'b00}-{op2_n,1'b0};		// -2D
					3'b100: rem_r[j+1] <= {rem_r[j][6:0],2'b00};
					3'b101: rem_r[j+1] <= {rem_r[j][6:0],2'b00}+{op2_n[7],op2_n};	// +D
					3'b110: rem_r[j+1] <= {rem_r[j][6:0],2'b00}+{op2_n,1'b0};		// +2D
					default: ;	// nop
				endcase
			end
		end
	end
endgenerate

//**************************** On the Fly Conversion ****************************//
always @(posedge clk or negedge rstn) begin
	Q_reg[0]  <= 8'd0;
	QM_reg[0] <= 8'd0;
end
genvar k;
generate
	for(k=0; k<3; k=k+1) begin : for_otf
		always @(posedge clk or negedge rstn) begin
			if(!rstn) begin
				Q_reg[k+1]  <= 8'd0;
				QM_reg[k+1] <= 8'd0;
			end else begin
				if(n[k+1]==1'b0) begin	// q>=0
					Q_reg[k+1]  <= {Q_reg[k][5:0],q[k+1]};
				end else begin
					Q_reg[k+1]  <= {QM_reg[k][5:0],q[k+1]};
				end
				if(n[k+1]==1'b0 & (|q[k+1])) begin	// q>0
					QM_reg[k+1] <= {Q_reg[k][5:0],1'b0,q[k+1][1]};
				end else begin
					QM_reg[k+1] <= {QM_reg[k][5:0],~q[k+1]};
				end
			end
		end
	end
endgenerate

//**************************** Post Proccessing ****************************//
integer i2;
always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		for(i2=0; i2<4; i2=i2+1) begin
			op2_nr[i2] <= 8'd0;
		end
	end else begin
		op2_nr[0] <= op2_n;
		for(i2=0; i2<3; i2=i2+1) begin
			op2_nr[i2+1] <= op2_nr[i2];
		end
	end
end
assign subs = op2_ld_r[3] - op1_ld_r[3] + 2;
assign iter = {subs[2]^(subs[1]&subs[0]), subs[1]^subs[0]};	// ceil(subs/2)
always @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		rem_o	<=	'd0;
		quo_o   <=  'd0;
	end else begin
		case(iter)
			3'd0: begin
				if(rem_r[0][7]==1'b1) begin
					rem_o <= (rem_r[0]+op2_nr[0]) >> op2_ld_r[0];
					quo_o <= Q_reg[0]-1;
				end else begin
					rem_o <= rem_r[0] >> op2_ld_r[0];
					quo_o <= Q_reg[0];
				end
			end
			3'd1: begin
				if(rem_r[1][7]==1'b1) begin
					rem_o <= (rem_r[1]+op2_nr[1]) >> op2_ld_r[1];
					quo_o <= Q_reg[1]-1;
				end else begin
					rem_o <= rem_r[1] >> op2_ld_r[1];
					quo_o <= Q_reg[1];
				end
			end
			3'd2: begin
				if(rem_r[2][7]==1'b1) begin
					rem_o <= (rem_r[2]+op2_nr[2]) >> op2_ld_r[2];
					quo_o <= Q_reg[2]-1;
				end else begin
					rem_o <= rem_r[2] >> op2_ld_r[2];
					quo_o <= Q_reg[2];
				end
			end
			3'd3: begin
				if(rem_r[3][7]==1'b1) begin
					rem_o <= (rem_r[3]+op2_nr[3]) >> op2_ld_r[3];
					quo_o <= Q_reg[3]-1;
				end else begin
					rem_o <= rem_r[3] >> op2_ld_r[3];
					quo_o <= Q_reg[3];
				end
			end
			3'd4: begin
				if(rem_r[4][7]==1'b1) begin
					rem_o <= (rem_r[4]+op2_nr[4]) >> op2_ld_r[4];
					quo_o <= Q_reg[4]-1;
				end else begin
					rem_o <= rem_r[4] >> op2_ld_r[4];
					quo_o <= Q_reg[4];
				end
			end
			3'd5: begin
				if(rem_r[5][7]==1'b1) begin
					rem_o <= (rem_r[5]+op2_nr[5]) >> op2_ld_r[5];
					quo_o <= Q_reg[5]-1;
				end else begin
					rem_o <= rem_r[5] >> op2_ld_r[5];
					quo_o <= Q_reg[5];
				end
			end
			3'd6: begin
				if(rem_r[6][7]==1'b1) begin
					rem_o <= (rem_r[6]+op2_nr[6]) >> op2_ld_r[6];
					quo_o <= Q_reg[6]-1;
				end else begin
					rem_o <= rem_r[6] >> op2_ld_r[6];
					quo_o <= Q_reg[6];
				end
			end
			default: begin
				rem_o <= 'd0;
				quo_o <= 'd0;
			end
		endcase
	end
end


endmodule

//------------------------ SUBROUTINE ------------------------//

// find leading 1s or 0s
module find_ld #(parameter WID=8)(op, pos);
input      [WID-1:0] op;
output reg [$clog2(WID)-1:0] pos;
reg  [WID-1:0] op_t;
wire [WID-1:0] pos_oh;	// onehot
integer i;
always @(*) begin
	for(i=0; i<WID; i=i+1) begin
		if(op[WID-1]==1'b0) begin
			op_t[i] <= op[WID-1-i];
		end else begin
			op_t[i] <= ~op[WID-1-i];
		end
	end
end
assign pos_oh = op_t & (~op_t+1);	// ripple carry
integer j;
always @(*) begin
	for(j=0; j<WID; j=j+1) begin
		if(pos_oh[j]==1) begin
			pos <= j-1;
		end
	end
end
// clog2 function
function  integer clog2;
    input integer depth;
    begin
        depth = depth-1;
        for(clog2=0; depth>0; clog2=clog2+1) begin
            depth = depth >> 1;
        end
    end
endfunction
endmodule

// quotien digit selection table
module qds (r_idx, d_idx, q, neg);
input  [4:0] r_idx;		// remainder index
input  [4:0] d_idx;		// divisor index
output [1:0] q;			// quotient digit
output     	 neg;		// negative quotient
wire   [4:0] r_ori;		// original code of remainder
wire r_ge_0010, r_ge_0011, r_ge_0110, r_ge_0111, r_ge_1000,
     r_ge_1001, r_ge_1010, r_ge_1011, r_ge_1100; // greater than
reg  q0, q2;		    // abs(qi) equal to 0,2
assign r_ori = r_idx[4] ? ~r_idx + 1 : r_idx;
assign r_ge_0010 = (r_ori[3:0]>=4'b0010);
assign r_ge_0011 = (r_ori[3:0]>=4'b0011);
assign r_ge_0110 = (r_ori[3:0]>=4'b0110);
assign r_ge_0111 = (r_ori[3:0]>=4'b0111);
assign r_ge_1000 = (r_ori[3:0]>=4'b1000);
assign r_ge_1001 = (r_ori[3:0]>=4'b1001);
assign r_ge_1010 = (r_ori[3:0]>=4'b1010);
assign r_ge_1011 = (r_ori[3:0]>=4'b1011);
assign r_ge_1100 = (r_ori[3:0]>=4'b1100);
always @(*) begin
	case(d_idx[3:0])
		4'b1000: begin
			q0 <= ~r_ge_0010;
			q2 <= r_ge_0110;
		end
		4'b1001: begin
			q0 <= ~r_ge_0010;
			q2 <= r_ge_0111;
		end
		4'b1010: begin
			q0 <= ~r_ge_0010;
			q2 <= r_ge_1000;
		end
		4'b1011: begin
			q0 <= ~r_ge_0010;
			q2 <= r_ge_1001;
		end
		4'b1100: begin
			q0 <= ~r_ge_0011;
			q2 <= r_ge_1010;
		end
		4'b1101: begin
			q0 <= ~r_ge_0011;
			q2 <= r_ge_1010;
		end
		4'b1110: begin
			q0 <= ~r_ge_0011;
			q2 <= r_ge_1011;
		end
		4'b1111: begin
			q0 <= ~r_ge_0011;
			q2 <= r_ge_1100;
		end
		default: begin
			q0 <= 1'b1;
			q2 <= 1'b0;
		end
	endcase
end
assign q = q0 ? 2'b00 : (q2 ? 2'b10 : 2'b01);
assign neg = ~q0 & (d_idx[4]!=r_idx[4]);
endmodule

