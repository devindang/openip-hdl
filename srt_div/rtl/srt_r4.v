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
// Description : Radix-4 SRT division.
//
// $Id$
//-------------------------------------------------------------------

`timescale 1ns / 1ps

module srt_r4(
	input			   clk,
	input			   rstn,
	input 			   vld_i,
	input		[63:0] op1_i,	// dividend
	input 		[63:0] op2_i,	// divisor
	output reg  [63:0] rem_o,
	output reg  [63:0] quo_o,
	output reg   	   ready_o
);

//------------------------ SIGNALS ------------------------//

reg  [4:0]  cnt;
reg  [63:0] op1_r, op2_r;   // registered
wire [5:0]  op1_ld, op2_ld;	// leading digit
reg  [5:0]  op1_s;			// op1 shift bits
wire [63:0] op1_n, op2_n;	// normalized
reg  [64:0] rem_r;   // 1-bit expand
wire [1:0]  q;
wire        n;
reg  [63:0] Q_reg, QM_reg;
reg  [63:0] Q_next, QM_next;
wire [5:0]  subs;
wire [4:0]  iter;

reg  [3:0] state_next;
reg  [3:0] state_reg;
localparam ST_IDLE = 4'b0001;
localparam ST_SAMP = 4'b0010;
localparam ST_DIV  = 4'b0100;
localparam ST_OUT  = 4'b1000;

//------------------------ PROCESS ------------------------//

//**************************** FSM Description ****************************//

always @(*) begin
	case(state_reg)
		ST_IDLE: begin
			if(vld_i & ready_o) begin
				state_next = ST_SAMP;
			end
		end
		ST_SAMP: begin
			state_next = ST_DIV;
		end
		ST_DIV: begin
			if(cnt==iter+1) begin
				state_next = ST_OUT;
			end
		end
		ST_OUT: begin
			state_next = ST_IDLE;
		end
		default: begin
			state_next = ST_IDLE;
		end
	endcase
end

always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		state_reg <= ST_IDLE;
	end else begin
		state_reg <= state_next;
	end
end

//**************************** Find Leading 1s or 0s ****************************//

always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		op1_r <= 'd0;
		op2_r <= 'd0;
	end else begin
		if(state_next==ST_SAMP) begin
			op1_r <= op1_i;
			op2_r <= op2_i;
		end
	end
end
find_ld #(64) u_find_ld1 (.op(op1_r), .pos(op1_ld));
find_ld #(64) u_find_ld2 (.op(op2_r), .pos(op2_ld));
always @(*) begin
	if(op1_ld[0]^op2_ld[0]) begin
		op1_s <= op1_ld-1;	// opt
	end else begin
		if(op1_ld>='d2) begin
			op1_s <= op1_ld-2;
		end else begin
			op1_s <= op1_ld;
		end
	end
end

assign op1_n = op1_r << op1_s;
assign op2_n = op2_r << op2_ld;
generate
	qds u_qds(
		.r_idx(rem_r[62:58]),	// 4r_{i-1}
		.d_idx(op2_n[63:59]),
		.q(q),
		.neg(n)
	);
endgenerate

//**************************** Residual Remainder ****************************//

assign subs = op2_ld - op1_s;
assign iter = subs[5] ? 6'd0 : subs[5:1];
always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		cnt <= 5'd0;
	end else begin
		if(state_next==ST_DIV) begin
			if(cnt==iter+1) begin
				cnt <= 'd0;
			end else begin
				cnt <= cnt + 1'b1;
			end
		end else begin
			cnt <= 'd0;
		end
	end
end
always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		rem_r <= 65'd0;
	end else begin
		if(state_next==ST_SAMP) begin
			rem_r <= 65'd0;
		end else begin
			if(state_next==ST_DIV) begin
				if(cnt=='d0) begin
					rem_r <= {op1_n[63],op1_n};
				end else begin
					case({n,q})
						3'b000: rem_r <= {rem_r[62:0],2'b00};
						3'b001: rem_r <= {rem_r[62:0],2'b00}-{op2_n[63],op2_n};	// -D
						3'b010: rem_r <= {rem_r[62:0],2'b00}-{op2_n,1'b0};		// -2D
						3'b100: rem_r <= {rem_r[62:0],2'b00};
						3'b101: rem_r <= {rem_r[62:0],2'b00}+{op2_n[63],op2_n};	// +D
						3'b110: rem_r <= {rem_r[62:0],2'b00}+{op2_n,1'b0};		// +2D
						default: ;	// nop
					endcase
				end
			end
		end
	end
end

//**************************** On the Fly Conversion ****************************//

always @(*) begin
	if(state_next==ST_DIV) begin
		if(n==1'b0) begin	// q>=0
			Q_next  <= {Q_reg[61:0],q};
		end else begin
			Q_next  <= {QM_reg[61:0],1'b1,q[0]};
		end
		if(n==1'b0 & (|q)) begin	// q>0
			QM_next <= {Q_reg[61:0],1'b0,q[1]};
		end else begin
			QM_next <= {QM_reg[61:0],~q};
		end
	end
end
always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		Q_reg  <= 8'd0;
		QM_reg <= 8'd0;
	end else begin
		if(state_next==ST_SAMP) begin
			Q_reg  <= 64'd0;
			QM_reg <= 64'd0;
		end else begin
			Q_reg  <= Q_next;
			QM_reg <= QM_next;
		end
	end
end

//**************************** Post Proccessing ****************************//

always @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		rem_o	<=	'd0;
		quo_o   <=  'd0;
	end else begin
		if(state_next==ST_OUT) begin
			if(rem_r[63]==1'b1) begin
				if(iter==0) begin
					rem_o <= (rem_r+op2_n) >> (op1_s);	// when dividend smaller than divisor
				end else begin
					rem_o <= (rem_r+op2_n) >> op2_ld;
				end
				quo_o <= Q_reg-1;
			end else begin
				if(iter==0) begin
					rem_o <= rem_r >> (op1_s);
				end else begin
					rem_o <= rem_r >> op2_ld;
				end
				quo_o <= Q_reg;
			end
		end
	end
end

always @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		ready_o <= 1'b0;
	end else begin
		if(state_next==ST_IDLE) begin
			ready_o <= 1'b1;
		end else begin
			ready_o <= 1'b0;
		end
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

