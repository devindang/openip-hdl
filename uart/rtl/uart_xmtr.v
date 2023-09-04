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
//  Title       : uart_xmtr.v
//  Dependances : 
//  Editor      : VIM
//  Created     : 
//  Description : UART transmitter.
//
//-------------------------------------------------------------------

`include "uart_defines.v"

module uart_xmtr #(
    parameter   WD_SIZE = `WD_SIZE  // default: 8
)(
    input               clk         ,
    input               rstn        ,
    input [WD_SIZE-1:0] bus_data_i  ,
    input               load_xmt_i  ,
    output              seri_data_o
);

//------------------------ SIGNALS ------------------------//

wire data_seri_last;
wire data_samp_last;
wire ctrl_shift;
wire ctrl_clear;
wire ctrl_load;
wire ctrl_inc_samp_cnt;

//------------------------ INST ------------------------//

uart_xmtr_ctrl_path u_xmtr_ctrl(
    .clk            (clk),
    .rstn           (rstn),
    .load_xmt_i     (load_xmt_i),
    .seri_last_i    (data_seri_last),
    .samp_last_i    (data_samp_last),
    .shift_o        (ctrl_shift),
    .clear_o        (ctrl_clear),
    .load_o         (ctrl_load),
    .inc_samp_cnt_o (ctrl_inc_samp_cnt)
);

uart_xmtr_data_path #(
    .WD_SIZE(WD_SIZE)
)u_xmtr_data(
    .clk            (clk),
    .rstn           (rstn),
    .load_i         (ctrl_load),
    .shift_i        (ctrl_shift),
    .clear_i        (ctrl_clear),
    .inc_samp_cnt_i (ctrl_inc_samp_cnt),
    .bus_data_i     (bus_data_i),
    .seri_data_o    (seri_data_o),
    .seri_last_o    (data_seri_last),
    .samp_last_o    (data_samp_last)
);

endmodule

//------------------------ SUBROUTINE ------------------------//

module uart_xmtr_ctrl_path(
    input       clk            ,
    input       rstn           ,
    input       load_xmt_i     ,
    input       seri_last_i    ,
    input       samp_last_i    ,
    output reg  shift_o        ,
    output reg  clear_o        ,
    output reg  load_o         ,
    output reg  inc_samp_cnt_o
);

localparam IDLE = 2'b01;
localparam SEND = 2'b10;
reg [1:0] state_reg, state_next;

always @(*) begin
    state_next     = IDLE;
    load_o         = 1'b0;
    shift_o        = 1'b0;
    clear_o        = 1'b0;
    inc_samp_cnt_o = 1'b0;
    case(state_reg)
        IDLE: begin
            if(load_xmt_i) begin
                load_o      = 1'b1;
                state_next  = SEND;
            end
        end
        SEND: begin
            inc_samp_cnt_o <= 1'b1;
            if(samp_last_i) begin
                if(!seri_last_i) begin
                    shift_o     = 1'b1;
                    state_next  = SEND;
                end else begin
                    clear_o     = 1'b1;
                    if(load_xmt_i) begin
                        load_o     = 1'b1;
                        state_next = SEND;
                    end else begin
                        state_next = IDLE;
                    end
                end
            end else begin
                state_next = SEND;
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


module uart_xmtr_data_path #(
    parameter   WD_SIZE = `WD_SIZE  // default: 8
)(
    input               clk            ,
    input               rstn           ,
    input               load_i         ,
    input               shift_i        ,
    input               clear_i        ,
    input               inc_samp_cnt_i ,
    input [WD_SIZE-1:0] bus_data_i     ,
    output              seri_data_o    ,
    output              seri_last_o    ,
    output              samp_last_o
);
reg [WD_SIZE:0]             xmt_datareg;  // Transmitter Data Register
reg [clog2(`OVER_SAMP)-1:0] cnt_samp;    // oversamp, default: 16
reg [4:0]                   bit_cnt;      // bit counter in Word.

assign seri_data_o = xmt_datareg[0];
assign seri_last_o = (bit_cnt==WD_SIZE+1);
assign samp_last_o = (cnt_samp==`OVER_SAMP-1);

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        xmt_datareg <= {WD_SIZE{1'b1}};
        bit_cnt     <= 4'd0;
    end else begin
        if(load_i) begin
            xmt_datareg <= {bus_data_i,1'b0};
        end else if(shift_i) begin
            xmt_datareg <= {1'b1,xmt_datareg[WD_SIZE:1]};
        end
        if(clear_i) begin
            bit_cnt <= 4'd0;
        end else if(shift_i) begin
            bit_cnt <= bit_cnt + 1;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        cnt_samp <= 'd0;
    end else begin
        if(inc_samp_cnt_i) begin
            if(cnt_samp==`OVER_SAMP-1) begin
                cnt_samp <= 'd0;
            end else begin
                cnt_samp <= cnt_samp + 1;
            end
        end else begin
            cnt_samp <= 'd0;
        end
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
