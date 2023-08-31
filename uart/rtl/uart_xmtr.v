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
//  Description : 
//
//-------------------------------------------------------------------

`include "uart_defines.v"

module uart_xmtr #(
    parameter   WD_SIZE = `WD_SIZE; // default: 8
)(
    input               clk         ,
    input               rstn        ,
    input [WD_SIZE-1:0] bus_data_i  ,
    input               load_xmt_i  ,
    output              seri_data_o
);

//------------------------ SIGNALS ------------------------//

wire data_seri_last;
wire ctrl_start;
wire ctrl_shift;
wire ctrl_clear;
wire ctrl_load;

//------------------------ SIGNALS ------------------------//

uart_xmtr_ctrl_path u_xmtr_ctrl(
    .clk            (clk),
    .rstn           (rstn),
    .load_xmt_i     (load_xmt_i),
    .seri_last_i    (data_seri_last),
    .start_o        (ctrl_start),
    .shift_o        (ctrl_shift),
    .clear_o        (ctrl_clear),
    .load_o         (ctrl_load)
);

uart_xmtr_ctrl_path #(
    .WD_SIZE(WD_SIZE)
)u_xmtr_ctrl(
    .clk         (clk),
    .rstn        (rstn),
    .load_i      (ctrl_load),
    .shift_i     (ctrl_shift),
    .clear_i     (ctrl_clear),
    .bus_data_i  (bus_data_i),
    .seri_data_o (seri_data_o),
    .seri_last_o (data_seri_last)
);

endmodule

//------------------------ SUBROUTINE ------------------------//

module uart_xmtr_ctrl_path(
    input           clk         ,
    input           rstn        ,
    input           load_xmt_i  ,
    input           seri_last_i ,
    output          start_o     ,
    output          shift_o     ,
    output          clear_o     ,
    output          load_o
);
localparam IDLE = 2'b01;
localparam SEND = 2'b10;
reg [clog2(`OVER_SAMP)-1:0] cnt_ovsmp;    // oversamp, default: 16
reg [1:0] state_reg, state_next;

always @(*) begin
    case(state_reg)
        IDLE: begin
            if(load_xmt_i) begin
                load_o = 1'b1;
                state_next = SEND:
            end
        end
        SEND: begin
            if(ovsmp_last) begin
                if(!seri_last_i) begin
                    shift_o     <= 1'b1;
                    state_next  <= SEND;
                end else begin
                    clear_o     <= 1'1b;
                    if(load_xmt_i) begin
                        load_o     <= 1'b1;
                        state_next <= SEND;
                    end else begin
                        state_next <= IDLE;
                    end
                end
            end else begin
                state_next <= SEND;
            end
        end
        default: state_next <= IDLE;
    endcase
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        state_reg <= IDLE;
    end else begin
        state_reg <= state_next;
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        cnt_ovsmp <= 'd0;
    end else begin
        if(state_next==SEND) begin
            if(cnt_ovsmp==`OVER_SAMP-1) begin
                cnt_ovsmp <= 'd0;
            end else begin
                cnt_ovsmp <= cnt_ovsmp + 1;
            end
        end else begin
            cnt_ovsmp <= 'd0;
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


module uart_xmtr_data_path #(
    parameter   WD_SIZE = `WD_SIZE, // default: 8
)(
    input               clk         ,
    input               rstn        ,
    input               load_i      ,
    input               shift_i     ,
    input               clear_i     ,
    input [WD_SIZE-1:0] bus_data_i  ,
    output              seri_data_o ,
    output              seri_last_o
);
reg [WD_SIZE:0] xmt_datareg;  // Transmitter Data Register
reg [4:0]       bit_cnt;      // bit counter in Word.

assign seri_data_o = xmt_datareg[0];
assign seri_last_o = (bit_cnt==WD_SIZE+1);

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        xmt_datareg <= {WD_SIZE'b1};
        bit_cnt     <= 4'd0;
    end else begin
        if(load_xmt_i) begin
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

endmodule
