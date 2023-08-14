//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2023, devin
//  balddonkey@outlook.com
//
//-------------------------------------------------------------------
// Title       : tb_mul.V
// Author      : Devin
// Editor      : VIM
// Created     : 2023-08-11 11:21:34
// Description :
//
// $Id$
//-------------------------------------------------------------------

`timescale 1ns / 1ps

module tb_mul(

);


//------------------------ SIGNALS ------------------------//

localparam CLK_PERIOD = 10;
reg			clk;
reg  		rstn;
reg  [63:0] op1;
reg  [63:0] op2;
wire [63:0] result;
wire [63:0] res_tmp;
reg  [63:0] res_tmp_d1;
reg  [63:0] res_tmp_d2;
reg  [63:0] res_ref;
reg			comp_en;
integer		fptr;

//------------------------ PROCESS ------------------------//

initial begin
    clk     <= 1'b0;
    rstn    <= 1'b0;
    repeat(4) @(posedge clk);
    rstn    <= 1'b1;
	repeat(1024) @(posedge clk) begin
		#1;
		op1        <= $random(); // 32-bits
		op2        <= $random();
	end
    repeat(10) @(posedge clk);
	$fdisplay(fptr, "-------------------------------------------------------------------------------");
	$fdisplay(fptr, "SUCCESS!");
    $finish();
end

assign res_tmp = $signed(op1)*$signed(op2);

always @(posedge clk) begin
	res_tmp_d1 <= res_tmp;
	res_tmp_d2 <= res_tmp_d1;
	res_ref    <= res_tmp_d2;
end

always begin
    #(CLK_PERIOD/2) clk <= ~clk;
end

initial begin
	fptr = $fopen("log.txt", "w+");
	comp_en <= 0;
	#75;
	comp_en <= 1;
end

always @(posedge clk) begin
	if(comp_en) begin
		if(res_ref != result) begin
			$fdisplay(fptr, "-------------------------------------------------------------------------------");
			$fdisplay(fptr, "ERROR!");
			$fdisplay(fptr, "Result not match, res_ref = %d, res_sim = %d, at time = %t",res_ref,result,$time);
			$finish();
		end
	end
end

initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0);
end

//------------------------ INST ------------------------//

rv_mul u_mul(
    .clk          (clk),
    .rstn         (rstn),
    .mul_op1_i    (op1),
    .mul_op2_i    (op2),
    .mul_result_o (result)
);

endmodule
