`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:       Devin
//  Email:          balddevin@outlook.com
//  Description:    Testbench for cordic_log.v
//  Parameters:
//  Additional:     Verification tool: Modelsim 10.6d
//////////////////////////////////////////////////////////////////////////////////

module tb_cordic_log(
);

localparam CLK_PERIOD = 10;
reg     clk = 1'b0;
reg     arstn = 1'b0;
reg  [31:0] din;
wire [31:0] ln_val;
wire        vld;

always begin
    #(CLK_PERIOD/2) clk <=  ~ clk;
end

initial begin
    arstn <= 1'b0;
    din   <= 'b0;
    repeat(20) @(posedge clk);
    arstn <= 1'b1;
    @(posedge clk);
    din <=  32'd1;
    repeat(5000) begin
        @(posedge clk);
        din   <= din+1;
    end
end

cordic_log #(
    .WD     (32),   // word length
    .ITER   (16)
) inst_cordic_log (
    .i_clk       (clk),     // input                   i_clk,
    .i_arstn     (arstn),   // input                   i_arstn,
    .i_valid_in  (1'b1),    // input                   i_valid_in,
    .i_data_in   (din),     // input       [WD-1:0]    i_data_in,
    .o_data_out  (ln_val),  // output  reg [WD-1:0]    o_data_out,
    .o_valid_out (vld)      // output  reg             o_valid_out
);

endmodule
