`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:       Devin
//  Email:          balddevin@outlook.com
//  Description:    Given unsigned integer, calculate the natural logarithm.
//                  The output is fix32_24.
//  Parameters:
//                  Name      | Description
//                  ----------|:-----------------
//                  WD        | Word Length
//                  ITER      | Iteration
//  Latency:        21+ITER*3 (Required to be optimized)
//  Additional:     You can use a multiplier to impelement the logarithm of any base.
//                  L(base m) = L(module output) * (2/log(m))
//////////////////////////////////////////////////////////////////////////////////

module cordic_log #(
    parameter WD = 32,   // word length
    parameter ITER = 16
) (
    input                   i_clk,
    input                   i_arstn,
    input                   i_valid_in,
    input       [WD-1:0]    i_data_in,      // uint
    output  reg [31:0]      o_data_out,     // fix32_24
    output  reg             o_valid_out
);

genvar i;
integer j;
reg [ITER+6:0]  vld;
reg [2*WD-1:0]  x [ITER+6:0];
reg [2*WD-1:0]  y [ITER+6:0];
reg [31:0]      z [ITER+6:0];

wire [ITER+6:0]  vld_w;
wire [2*WD-1:0]  x_w [ITER+6:0];
wire [2*WD-1:0]  y_w [ITER+6:0];
wire [31:0]      z_w [ITER+6:0];

always @(posedge i_clk or negedge i_arstn) begin : reg_proc
    if(!i_arstn) begin
        vld  <=  'b0;
        for(j=0;j<=ITER+6;j=j+1) begin
            x[j] <=  'd0;
            y[j] <=  'd0;
            z[j] <=  'd0;
        end
    end else begin
        if(i_valid_in == 1'b1) begin
            if(i_data_in == 0) begin
                vld[0]  <=  1'b0;
                x[0]    <=  'b0;
                y[0]    <=  'b0;
                z[0]    <=  'b0;
            end else begin
                vld[0]  <=  1'b1;
                x[0]    <=  {{i_data_in + 1} , {WD{1'b0}}};
                y[0]    <=  {{i_data_in - 1} , {WD{1'b0}}};
                z[0]    <=  'b0;
            end
            vld[ITER+6:1] <=  vld_w[ITER+6:1];
            for(j=1;j<=ITER+6;j=j+1) begin
                x[j]   <=  x_w[j];
                y[j]   <=  y_w[j];
                z[j]   <=  z_w[j];
            end
        end
    end
end

always @(posedge i_clk or negedge i_arstn) begin : out_proc
    if(!i_arstn) begin
        o_valid_out <=  1'b0;
        o_data_out  <=  'b0;
    end else begin
        o_valid_out <=  vld[ITER+6];
        o_data_out  <=  z[ITER+6];
    end
end

for (i=-5; i<=0; i=i+1) begin : hyp_ext_generate
    cordic_hyp_ext #(
        .WD    (WD)
    ) u_cordic_hyp_ext (
        .i_clk   (i_clk),       // input                   i_clk,
        .i_arstn (i_arstn),     // input                   i_arstn,
        .i_iter  (i),
        .i_valid (vld[i+5]),    // input                   i_valid,
        .i_x     (x[i+5]),      // input       [2*WD-1:0]  i_x,
        .i_y     (y[i+5]),      // input       [2*WD-1:0]  i_y,
        .i_z     (z[i+5]),      // input       [31:0]      i_z,
        .o_x1    (x_w[i+6]),      // output  reg [2*WD-1:0]  o_x1,
        .o_y1    (y_w[i+6]),      // output  reg [2*WD-1:0]  o_y1,
        .o_z1    (z_w[i+6]),      // output  reg [31:0]      o_z1,
        .o_valid (vld_w[i+6])     // output  reg             o_valid
    );
end

for (i=1; i<=ITER; i=i+1) begin : hyp_core_generate
    cordic_hyp_core #(
        .WD    (WD)
    ) u_cordic_hyp_core (
        .i_clk   (i_clk),       // input                   i_clk,
        .i_arstn (i_arstn),     // input                   i_arstn,
        .i_iter  (i),
        .i_valid (vld[i+5]),    // input                   i_valid,
        .i_x     (x[i+5]),      // input       [2*WD-1:0]  i_x,
        .i_y     (y[i+5]),      // input       [2*WD-1:0]  i_y,
        .i_z     (z[i+5]),      // input       [31:0]      i_z,
        .o_x1    (x_w[i+6]),      // output  reg [2*WD-1:0]  o_x1,
        .o_y1    (y_w[i+6]),      // output  reg [2*WD-1:0]  o_y1,
        .o_z1    (z_w[i+6]),      // output  reg [31:0]      o_z1,
        .o_valid (vld_w[i+6])     // output  reg             o_valid
    );
end

endmodule
