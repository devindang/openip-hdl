//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2023, devin
//  balddonkey@outlook.com
//
//-------------------------------------------------------------------
// Title       : srt_r2.v
// Author      : Devin
// Editor      : VIM
// Created     : 2023-08-14 10:13:13
// Description :
//
// $Id$
//-------------------------------------------------------------------

`timescale 1ns / 1ps

module srt_r2(
	input			  clk,
	input			  rstn,
	input		[7:0] op1_i,	// dividend
	input 		[7:0] op2_i,	// divisor
	output reg  [7:0] rem_o,
	output reg  [7:0] quo_o
);

//------------------------ SIGNALS ------------------------//

wire [2:0] op2_ld;	// leading digit
wire [7:0] op2_n;	// normalized
reg  [7:0] rem_r [7:0];
wire [7:0] q;
wire [7:0] n;
reg  [7:0] Q_reg[7:0];
reg  [7:0] QM_reg[7:0];
reg  [2:0] op2_ld_r[7:0];	// op2 leading digit register

//------------------------ PROCESS ------------------------//

// find leading 1s or 0s
find_ld #(8) u_find_ld2 (.op(op2_i), .pos(op2_ld));
assign op2_n = op2_i << op2_ld;
assign q[0] = 1'b0;
assign n[0] = 1'b0;
genvar i;
generate
	for(i=0; i<7; i=i+1) begin
		qds u_qds(
			.r(rem_r[i]),
			.sd(op2_n[7]),
			.q(q[i+1]),
			.neg(n[i+1])
		);
	end
endgenerate
integer i1;
always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		for(i1=0; i1<8; i1=i1+1) begin
			op2_ld_r[i1] <= 3'd0;
		end
	end else begin
		op2_ld_r[0] <= op2_ld;
		for(i1=0; i1<7; i1=i1+1) begin
			op2_ld_r[i1+1] <= op2_ld_r[i1];
		end
	end
end

// residual remainder
always @(posedge clk or negedge rstn) begin
	if(!rstn) begin
		rem_r[0] <= 8'd0;
	end else begin
		rem_r[0] <= op1_i;
	end
end
genvar j;
generate
	for(j=0; j<7; j=j+1) begin
		always @(posedge clk or negedge rstn) begin
			if(!rstn) begin
				rem_r[j+1] <= 8'd0;
			end else begin
				case({n[j+1],q[j+1]})
					2'b00: rem_r[j+1] <= {rem_r[j][6:0],1'b0};
					2'b01: rem_r[j+1] <= {rem_r[j][6:0],1'b0}-op2_n;
					2'b10: rem_r[j+1] <= {rem_r[j][6:0],1'b0};
					2'b11: rem_r[j+1] <= {rem_r[j][6:0],1'b0}+op2_n;
					default: ;
				endcase
			end
		end
	end
endgenerate

// on the fly conversion
always @(posedge clk or negedge rstn) begin
	Q_reg[0]  <= 8'd0;
	QM_reg[0] <= 8'd0;
end
genvar k;
generate
	for(k=0; k<7; k=k+1) begin 
		always @(posedge clk or negedge rstn) begin
			if(!rstn) begin
				Q_reg[k+1]  <= 8'd0;
				QM_reg[k+1] <= 8'd0;
			end else begin
				if(n[k+1]==1'b0) begin
					Q_reg[k+1]  <= {Q_reg[k][6:0],q[k+1]};
				end else begin
					Q_reg[k+1]  <= {QM_reg[k][6:0],q[k+1]};
				end
				if(n[k+1]==1'b0 & q[k+1]!=1'b0) begin
					QM_reg[k+1] <= {Q_reg[k][6:0],~q[k+1]};
				end else begin
					QM_reg[k+1] <= {QM_reg[k][6:0],~q[k+1]};
				end
			end
		end
	end
endgenerate

// post proccessing
always @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		rem_o	<=	'd0;
		quo_o   <=  'd0;
	end else begin
		if(rem_r[7][7]==1'b1) begin // if negative
			// rem_o <= (rem_r[7]+op2_n)>>op2_ld_r[7];	// reg required, dd
			rem_o <= (rem_r[7]+op2_n);
			quo_o <= Q_reg[7]-1;
		end else begin
			// rem_o <= rem_r[7]>>op2_ld_r[7];
			rem_o <= rem_r[7];
			quo_o <= Q_reg[7];
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
module qds #(parameter WID=8)(r, sd, q, neg);
input  [WID-1:0] r;
input  sd;				// sign of divisor
output reg q;
output     neg;
always @(*) begin
	if((r[WID-2:WID-4] < 3'b010) | (r[WID-2:WID-4] >= 3'b110)) begin
		q <= 1'b0;
	end else begin
		q <= 1'b1;
	end
end
assign neg = (q==1'b1) & (sd!=r[WID-1]);
endmodule

