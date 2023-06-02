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
//  Latency:        14+ITER*2 (Required to be optimized)
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
wire        [ITER+5:0]  vld;
wire signed [2*WD-1:0]  x [ITER+5:0];
wire signed [2*WD-1:0]  y [ITER+5:0];
wire signed [31:0]      z [ITER+5:0];

reg                    vld_0;
reg signed [2*WD-1:0]  x_0;
reg signed [2*WD-1:0]  y_0;

always @(posedge i_clk or negedge i_arstn) begin : reg_proc
    if(!i_arstn) begin
        vld_0 <=  'b0;
        x_0   <=  'd0;
        y_0   <=  'd0;
    end else begin
        vld_0   <=  i_valid_in;
        if(i_valid_in == 1'b1) begin
            if(i_data_in == 0) begin
                x_0  <=  {{(WD-1){1'b0}},1'b1,{(WD+1){1'b0}}}; // the half is fractional bits
                y_0  <=  'd0;
            end else begin
                x_0  <=  {{$unsigned(i_data_in) + 1} , {WD{1'b0}}};
                y_0  <=  {{$unsigned(i_data_in) - 1} , {WD{1'b0}}};
            end
        end
    end
end

always @(posedge i_clk or negedge i_arstn) begin : out_proc
    if(!i_arstn) begin
        o_valid_out <=  1'b0;
        o_data_out  <=  'b0;
    end else begin
        o_valid_out <=  vld[ITER+5];
        o_data_out  <=  z[ITER+5];
    end
end

// first stage in
    cordic_hyp_ext #(
        .WD    (WD)
    ) u_cordic_hyp_ext (
        .i_clk   (i_clk),    // input                   i_clk,
        .i_arstn (i_arstn),  // input                   i_arstn,
        .i_iter  (-5),
        .i_valid (vld_0),    // input                   i_valid,
        .i_x     (x_0),      // input       [2*WD-1:0]  i_x,
        .i_y     (y_0),      // input       [2*WD-1:0]  i_y,
        .i_z     (32'b0),      // input       [31:0]      i_z,
        .o_x1    (x[0]),     // output  reg [2*WD-1:0]  o_x1,
        .o_y1    (y[0]),     // output  reg [2*WD-1:0]  o_y1,
        .o_z1    (z[0]),    // output  reg [31:0]      o_z1,
        .o_valid (vld[0])    // output  reg             o_valid
    );

for (i=-4; i<=0; i=i+1) begin : hyp_ext_generate
    cordic_hyp_ext #(
        .WD    (WD)
    ) u_cordic_hyp_ext (
        .i_clk   (i_clk),       // input                   i_clk,
        .i_arstn (i_arstn),     // input                   i_arstn,
        .i_iter  (i),
        .i_valid (vld[i+4]),    // input                   i_valid,
        .i_x     (x[i+4]),      // input       [2*WD-1:0]  i_x,
        .i_y     (y[i+4]),      // input       [2*WD-1:0]  i_y,
        .i_z     (z[i+4]),      // input       [31:0]      i_z,
        .o_x1    (x[i+5]),      // output  reg [2*WD-1:0]  o_x1,
        .o_y1    (y[i+5]),      // output  reg [2*WD-1:0]  o_y1,
        .o_z1    (z[i+5]),      // output  reg [31:0]      o_z1,
        .o_valid (vld[i+5])     // output  reg             o_valid
    );
end

for (i=1; i<=ITER; i=i+1) begin : hyp_core_generate
    cordic_hyp_core #(
        .WD    (WD)
    ) u_cordic_hyp_core (
        .i_clk   (i_clk),       // input                   i_clk,
        .i_arstn (i_arstn),     // input                   i_arstn,
        .i_iter  (i),
        .i_valid (vld[i+4]),    // input                   i_valid,
        .i_x     (x[i+4]),      // input       [2*WD-1:0]  i_x,
        .i_y     (y[i+4]),      // input       [2*WD-1:0]  i_y,
        .i_z     (z[i+4]),      // input       [31:0]      i_z,
        .o_x1    (x[i+5]),      // output  reg [2*WD-1:0]  o_x1,
        .o_y1    (y[i+5]),      // output  reg [2*WD-1:0]  o_y1,
        .o_z1    (z[i+5]),      // output  reg [31:0]      o_z1,
        .o_valid (vld[i+5])     // output  reg             o_valid
    );
end

endmodule
