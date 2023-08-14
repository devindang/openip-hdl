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
	input		[7:0] op1_i;	// dividend
	input 		[7:0] op2_i;	// divisor
	output reg  [7:0] res_o;
);

//------------------------ SIGNALS ------------------------//

reg	 [2:0] op2_ld;	// leading digit
reg  [7:0] op2_n;	// normalized

//------------------------ PROCESS ------------------------//

// find leading 1s or 0s
find_ld u_find_ld2 #(8) (.operand(op2_i), .pos(op1_ld));
assign op2_n = op2_i << op1_ld;



//------------------------ INST ------------------------//


endmodule


//------------------------ SUBROUTINE ------------------------//

// find leading 1s or 0s
module find_ld #(parameter WID=8)(operand, pos);
input      [WID-1:0] operand;
output reg [$clog2(WID)-1:0] pos;
reg  operand_t;
wire pos_oh;	// onehot
integer i, j;
always @(*) begin
	for(i=0; i<WID; i=i+1) begin
		if(operand[WID]==1'b0] begin
			operand_t[i] <= operand[WID-1-i];
		end else begin
			operand_t[i] <= ~operand[WID-1-i];
		end
	end
end
assign pos_oh = operand_t & (~operand_t+1);	// ripple carry
always @(*) begin
	for(i=0; i<WID; i=i+1) begin
		if(pos_oh[i]==1) begin
			pos <= i-1;
		end
	end
end
endmodule

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
