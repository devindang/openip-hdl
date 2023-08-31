//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2023, devin
//  balddonkey@outlook.com
//
//-------------------------------------------------------------------
//
//  Author      : Devin
//  Project		: OPENIP-HDL
//  Repository  : https://github.com/devindang/openip-hdl
//  Title       : tb_uart.v
//  Dependances : 
//  Editor      : VIM
//  Created     : 
//  Description : 
//
//-------------------------------------------------------------------

`timescale 1ns/1ps
`include "uart_defines.v"

module tb_uart(
);

//------------------------ SIGNALS ------------------------//

localparam CLK_PERIOD = 10;
reg         clk;
reg         rstn;
reg  [7:0]  pwdata;
reg         psel;
reg         penable;
wire        pload;

//------------------------ PROCESS ------------------------//

initial begin
    clk     = 1'b0;
    rstn    = 1'b0;
    pwdata  = 8'd0;
    psel    = 1'b0;
    penable = 1'b0;
    repeat(3) @(posedge clk);
    rstn    = 1'b1;
    #1;
    pwdata  = 8'd79;
    psel    = 1'b1;
    @(posedge clk);
    penable = 1'b1;
    @(posedge clk);
    pwdata  = 8'd0;
    psel    = 1'b0;
    penable = 1'b0;
end

always begin
    #(CLK_PERIOD/2) clk <= ~clk;
end

assign pload = psel & ~penable;

//------------------------ INST ------------------------//

uart_xmtr #(
    .WD_SIZE(8)
)(
    .clk         (clk),
    .rstn        (rstn),
    .bus_data_i  (pwdata),
    .load_xmt_i  (pload),
    .seri_data_o (uart_txd)
);

endmodule