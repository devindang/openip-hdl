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
//  Title       : uart_rcvr.v
//  Dependances : 
//  Editor      : VIM
//  Created     : 
//  Description : UART receiver.
//
//-------------------------------------------------------------------

`include "uart_defines.v"

module uart_rcvr#(
    parameter   WD_SIZE = `WD_SIZE  // default: 8
)(
    input                clk         ,
    input                rstn        ,
    input                seri_data_i ,
    output [WD_SIZE-1:0] bus_data_o  ,
    output               vld_data_o
);

//------------------------ SIGNALS ------------------------//

wire    data_samp_last;
wire    data_seri_last;
wire    data_start_half;
wire    ctrl_clr_samp;
wire    ctrl_inc_samp;
wire    ctrl_clr_bit;
wire    ctrl_inc_bit;
wire    ctrl_shift;
wire    ctrl_load;

//------------------------ INST ------------------------//

uart_rcvr_ctrl_path u_rcvr_ctrl(
    .clk             (clk),
    .rstn            (rstn),
    .seri_data_i     (seri_data_i),
    .start_half_i    (data_start_half),
    .samp_last_i     (data_samp_last),
    .seri_last_i     (data_seri_last),
    .clr_samp_cnt_o  (ctrl_clr_samp),
    .inc_samp_cnt_o  (ctrl_inc_samp),
    .clr_bit_cnt_o   (ctrl_clr_bit),
    .inc_bit_cnt_o   (ctrl_inc_bit),
    .shift_o         (ctrl_shift),
    .load_o          (ctrl_load)
);

uart_rcvr_data_path#(
    .WD_SIZE (`WD_SIZE)
)u_rcvr_data(
    .clk            (clk),
    .rstn           (rstn),
    .seri_data_i    (seri_data_i),
    .clr_samp_cnt_i (ctrl_clr_samp),
    .inc_samp_cnt_i (ctrl_inc_samp),
    .clr_bit_cnt_i  (ctrl_clr_bit),
    .inc_bit_cnt_i  (ctrl_inc_bit),
    .shift_i        (ctrl_shift),
    .load_i         (ctrl_load),
    .samp_last_o    (data_samp_last),
    .seri_last_o    (data_seri_last),
    .start_half_o   (data_start_half),
    .bus_data_o     (bus_data_o),
    .vld_data_o     (vld_data_o)
);

endmodule

//------------------------ SUBROUTINE ------------------------//

module uart_rcvr_ctrl_path(
    input       clk             ,
    input       rstn            ,
    input       seri_data_i     ,
    input       start_half_i    ,
    input       samp_last_i     ,
    input       seri_last_i     ,
    output  reg clr_samp_cnt_o  ,
    output  reg inc_samp_cnt_o  ,
    output  reg clr_bit_cnt_o   ,
    output  reg inc_bit_cnt_o   ,
    output  reg shift_o         ,
    output  reg load_o
);

localparam IDLE    = 3'b001;
localparam START   = 3'b010;
localparam RECEIVE = 3'b100;
reg [2:0] state_reg, state_next;

always @(*) begin
    state_next      = IDLE;
    clr_samp_cnt_o  = 1'b0;
    inc_samp_cnt_o  = 1'b0;
    inc_bit_cnt_o   = 1'b0;
    clr_bit_cnt_o   = 1'b0;
    shift_o         = 1'b0;
    load_o          = 1'b0;
    case(state_reg)
        IDLE: begin
            if(seri_data_i==1'b0) begin
                state_next = START;
            end else begin
                state_next = IDLE;
            end
        end
        START: begin
            if(seri_data_i==1'b1) begin
                state_next     = IDLE;
                clr_samp_cnt_o = 1'b1;
            end else begin
                if(start_half_i) begin
                    state_next     = RECEIVE;
                    clr_samp_cnt_o = 1'b1;
                end else begin
                    state_next     = START;
                    inc_samp_cnt_o = 1'b1;
                end
            end
        end
        RECEIVE: begin
            if(samp_last_i) begin
                clr_samp_cnt_o = 1'b1;
                if(!seri_last_i) begin
                    state_next    = RECEIVE;
                    shift_o       = 1'b1;
                    inc_bit_cnt_o = 1'b1;
                end else begin
                    state_next    = IDLE;
                    load_o        = 1'b1;
                    clr_bit_cnt_o = 1'b1;
                end
            end else begin
                inc_samp_cnt_o = 1'b1;
                state_next     = RECEIVE;
            end
        end
        default: state_next = IDLE;
    endcase
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        state_reg <= IDLE;
    end else begin
        state_reg <= state_next;
    end
end

endmodule


module uart_rcvr_data_path#(
    parameter   WD_SIZE = `WD_SIZE  // default: 8
)(
    input                    clk            ,
    input                    rstn           ,
    input                    seri_data_i    ,
    input                    clr_samp_cnt_i ,
    input                    inc_samp_cnt_i ,
    input                    clr_bit_cnt_i  ,
    input                    inc_bit_cnt_i  ,
    input                    shift_i        ,
    input                    load_i         ,
    output                   samp_last_o    ,
    output                   seri_last_o    ,
    output                   start_half_o   ,
    output reg [WD_SIZE-1:0] bus_data_o     ,
    output reg               vld_data_o
);

localparam [4:0]            HALF_SAMP = `OVER_SAMP/2;
reg [WD_SIZE-1:0]           rcv_datareg; // Transmitter Data Register
reg [clog2(`OVER_SAMP)-1:0] cnt_samp;    // oversamp, default: 16
reg [4:0]                   cnt_bit;     // bit counter in Word.

assign start_half_o = (cnt_samp==HALF_SAMP-1);
assign seri_last_o  = (cnt_bit==WD_SIZE);
assign samp_last_o  = (cnt_samp==`OVER_SAMP-1);

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        cnt_samp <= 'd0;
        cnt_bit  <= 'd0;
    end else begin
        if(clr_samp_cnt_i) begin
            cnt_samp  <= 'd0;
        end else if(inc_samp_cnt_i) begin
            cnt_samp  <= cnt_samp + 1;
        end
        if(clr_bit_cnt_i) begin
            cnt_bit  <= 'd0;
        end else if(inc_bit_cnt_i) begin
            cnt_bit  <= cnt_bit + 1;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        rcv_datareg <= 'd0;
        bus_data_o  <= 'd0;
        vld_data_o  <= 1'b0;
    end else begin
        if(shift_i) begin
            rcv_datareg <= {seri_data_i,rcv_datareg[WD_SIZE-1:1]};
        end
        if(load_i) begin
            bus_data_o <= rcv_datareg;
        end
        vld_data_o <= load_i;
    end
end

function    integer clog2;
    input   integer depth;
    begin
        depth = depth-1;
        for(clog2=0; depth>0; clog2=clog2+1) begin
            depth = depth >> 1;
        end
    end
endfunction

endmodule
