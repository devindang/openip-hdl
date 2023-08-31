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
//  Title       : uart_defines.v
//  Dependances : 
//  Editor      : VIM
//  Created     : 
//  Description : 
//
//-------------------------------------------------------------------

`define XO_FREQ   96    // Crystal Frequency, MHz
`define BAUD_RATE 9600  // Baud Rate, Baud/bps
`define WD_SIZE   8     // Word Size, default 8
`define OVER_SAMP 16    // Over Sampling Rate, default 16

`define UART_DIV (`XO_FREQ*(10**6))/(`BAUD_RATE*16) // UART Interface Clock
