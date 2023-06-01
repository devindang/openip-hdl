`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:       Devin
//  Email:          balddevin@outlook.com
//  Description:    Subroutine to expand the scope of result.
//  Parameters:
//                  Name      | Description
//                  ----------|:-----------------
//                  WD        | Word Length
//  Additional:     
//////////////////////////////////////////////////////////////////////////////////

module cordic_hyp_ext #(
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
    reg             vld;

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

//    always @(posedge i_clk or negedge i_arstn) begin
//        if(!i_arstn) begin
//            o_x1    <=  'b0;
//            o_y1    <=  'b0;
//            o_z1    <=  'b0;
//            o_valid <=  1'b0;
//        end else begin
//            if(i_valid==1'b1) begin
//                if(i_y[2*WD-1]==1'b1) begin
//                    o_x1  <=  i_x + i_y - i_y >>> (2-$signed(i_iter));
//                    o_y1  <=  i_y + i_x - i_x >>> (2-$signed(i_iter));
//                    o_z1  <=  i_z - atanh;
//                end else begin
//                    o_x1  <=  i_x - i_y + i_y >>> (2-$signed(i_iter));
//                    o_y1  <=  i_y - i_x + i_x >>> (2-$signed(i_iter));
//                    o_z1  <=  i_z + atanh;
//                end
//            end
//            o_valid <=  i_valid;
//        end
//    end

    always @(posedge i_clk or negedge i_arstn) begin
        if(!i_arstn) begin
            o_x1    <=  'b0;
            o_y1    <=  'b0;
            o_z1    <=  'b0;
            o_valid <=  1'b0;
        end else begin
            if(vld==1'b1) begin
                if(y0[2*WD-1]==1'b1) begin
                    o_x1  <=  $signed(x0 + y0) - $signed(y0 >>> (2-$signed(i_iter)));
                    o_y1  <=  $signed(y0 + x0) - $signed(x0 >>> (2-$signed(i_iter)));
                    o_z1  <=  $signed(z0) - $signed(atanh);
                end else begin
                    o_x1  <=  $signed(x0 - y0) + $signed(y0 >>> (2-$signed(i_iter)));
                    o_y1  <=  $signed(y0 - x0) + $signed(x0 >>> (2-$signed(i_iter)));
                    o_z1  <=  $signed(z0) + $signed(atanh);
                end
            end
            o_valid <=  vld;
        end
    end

    always @(posedge i_clk) begin
        case ($signed(i_iter))
            -5  : atanh <=  32'h02C54820;
            -4  : atanh <=  32'h026C0E53;
            -3  : atanh <=  32'h0212523D;
            -2  : atanh <=  32'h01B78CD5;
            -1  : atanh <=  32'h015AA163;
            0   : atanh <=  32'h00F91395;
            default : atanh <= 32'h00000000;
        endcase
    end


endmodule
