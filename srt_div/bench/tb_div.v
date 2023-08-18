//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2023, devin
//  balddonkey@outlook.com
//
//-------------------------------------------------------------------
// Title       : tb_div.v
// Author      : Devin
// Editor      : VIM
// Created     :
// Description :
//
// $Id$
//-------------------------------------------------------------------

`timescale 1ns / 1ps

module tb_div(

);

//------------------------ SIGNALS ------------------------//

localparam CLK_PERIOD = 10;
reg  clk;
reg  rstn;
reg  [7:0] op1;
reg  [7:0] op2;
wire [7:0] rem;
wire [7:0] quo;

//------------------------ PROCESS ------------------------//

initial begin
    clk     <= 1'b0;
    rstn    <= 1'b0;
    repeat(4) @(posedge clk);
    rstn    <= 1'b1;
	op1		<= 23;
	op2		<= 7;
    repeat(32) @(posedge clk);
	$display("-------------------------------------------------------------------------------");
	$display("SUCCESS!");
    $finish();
end

always begin
    #(CLK_PERIOD/2) clk <= ~clk;
end

initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0);
end

//------------------------ INST ------------------------//

srt_r4 u_srt(
	.clk(clk),
	.rstn(rstn),
	.op1_i(op1),
	.op2_i(op2),
	.rem_o(rem),
	.quo_o(quo)
);

endmodule
