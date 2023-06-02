`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:       Devin
//  Email:          balddevin@outlook.com
//  Description:    Subroutine to perform hyperbolic cordic.
//  Parameters:
//                  Name      | Description
//                  ----------|:-----------------
//                  WD        | Word Length
//  Additional:     
//////////////////////////////////////////////////////////////////////////////////


module cordic_hyp_core #(
    parameter WD    = 32
) (
    input                   i_clk,
    input                   i_arstn,
    input       [7:0]       i_iter,
    input                   i_valid,
    input       [2*WD-1:0]  i_x,
    input       [2*WD-1:0]  i_y,
    input       [31:0]      i_z,
    output  reg [2*WD-1:0]  o_x1,
    output  reg [2*WD-1:0]  o_y1,
    output  reg [31:0]      o_z1,
    output  reg             o_valid
);

    reg signed [31:0]      atanh;
    reg signed [2*WD-1:0]  x0;
    reg signed [2*WD-1:0]  y0;
    reg signed [31:0]      z0;
    reg                    vld;

    always @(posedge i_clk or negedge i_arstn) begin : reg_proc
        if(!i_arstn) begin
            x0  <=  'b0;
            y0  <=  'b0;
            z0  <=  'b0;
            vld <=  1'b0;
        end else begin
            x0  <=  i_x;
            y0  <=  i_y;
            z0  <=  i_z;
            vld <=  i_valid;
        end
    end

    always @(posedge i_clk or negedge i_arstn) begin
        if(!i_arstn) begin
            o_x1    <=  'b0;
            o_y1    <=  'b0;
            o_z1    <=  'b0;
            o_valid <=  1'b0;
        end else begin
            if(vld==1'b1) begin
                if(y0[2*WD-1]==1'b1) begin
                    o_x1  <=  x0 + $signed(y0 >>> $unsigned(i_iter));
                    o_y1  <=  y0 + $signed(x0 >>> $unsigned(i_iter));
                    o_z1  <=  z0 - atanh;
                end else begin
                    o_x1  <=  x0 - $signed(y0 >>> $unsigned(i_iter));
                    o_y1  <=  y0 - $signed(x0 >>> $unsigned(i_iter));
                    o_z1  <=  z0 + atanh;
                end
            end
            o_valid <=  vld;
        end
    end

    always @(posedge i_clk) begin
        case ($unsigned(i_iter))
            1   : atanh <=  32'h008C9F54;
            2   : atanh <=  32'h004162BC;
            3   : atanh <=  32'h00202B12;
            4   : atanh <=  32'h00100559;
            5   : atanh <=  32'h000800AB;
            6   : atanh <=  32'h00040015;
            7   : atanh <=  32'h00020003;
            8   : atanh <=  32'h00010000;
            9   : atanh <=  32'h00008000;
            10  : atanh <=  32'h00004000;
            11  : atanh <=  32'h00002000;
            12  : atanh <=  32'h00001000;
            13  : atanh <=  32'h00000800;
            14  : atanh <=  32'h00000400;
            15  : atanh <=  32'h00000200;
            16  : atanh <=  32'h00000100;
            17  : atanh <=  32'h00000080;
            18  : atanh <=  32'h00000040;
            19  : atanh <=  32'h00000020;
            20  : atanh <=  32'h00000010;
            21  : atanh <=  32'h00000008;
            22  : atanh <=  32'h00000004;
            23  : atanh <=  32'h00000002;
            24  : atanh <=  32'h00000001;
            25  : atanh <=  32'h00000001;
            26  : atanh <=  32'h00000000;
            27  : atanh <=  32'h00000000;
            28  : atanh <=  32'h00000000;
            29  : atanh <=  32'h00000000;
            30  : atanh <=  32'h00000000;
            31  : atanh <=  32'h00000000;
            32  : atanh <=  32'h00000000;
            default : atanh <= 32'h00000000;
        endcase
    end

endmodule
