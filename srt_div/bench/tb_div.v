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
reg   	    vld;
reg  [63:0] op1;
reg  [63:0] op2;
wire [63:0] rem;
wire [63:0] quo;
wire        ready;

//------------------------ PROCESS ------------------------//

initial begin
    clk     <= 1'b0;
    rstn    <= 1'b0;
	vld     <= 1'b0;
    repeat(4) @(posedge clk);
    rstn    <= 1'b1;
	repeat(1024) @(posedge clk) begin
		#1;
		vld     <= 1'b1;
		op1     <= $random()%15-31;	// 32-bits
		op2     <= $random()%15-31;	// 32-bits
	end
	@(posedge clk);
		#1;
		vld <= 1'b0;
    repeat(10) @(posedge clk);
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
	.vld_i(vld),
	.op1_i(op1),
	.op2_i(op2),
	.rem_o(rem),
	.quo_o(quo),
	.ready_o(ready)
);

endmodule
