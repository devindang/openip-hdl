//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2023, devin
//  balddonkey@outlook.com
//
//-------------------------------------------------------------------
//
//  Author      : Devin
//  Project		: project
//  Repository  : https://github.com/devindang/
//  Title       : tb.v
//  Dependances : 
//  Editor      : VIM
//  Created     : 
//  Description : 
//
//-------------------------------------------------------------------

`timescale 1ns/1ps

module tb(

);


//------------------------ SIGNALS ------------------------//

localparam CLK_PERIOD = 10;
reg  clk;
reg  rstn;

//------------------------ PROCESS ------------------------//

initial begin
	clk  = 1'b0;
	rstn = 1'b0;
	repeat(10) @(posedge clk);
	rstn = 1'b1;
	$finish();
end

always begin
	#(CLK_PERIOD/2) clk <= ~clk;
end

//------------------------ INST ------------------------//


endmodule
