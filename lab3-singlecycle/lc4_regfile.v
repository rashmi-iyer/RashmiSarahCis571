/* TODO: Rashmi Iyer, Sarah Luthra
 * TODO: rashmii, saluthra
 *
 * lc4_regfile.v
 * Implements an 8-register register file parameterized on word size.
 *
 */

`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

module lc4_regfile #(parameter n = 16)
   (input  wire         clk,
    input  wire         gwe,
    input  wire         rst,
    input  wire [  2:0] i_rs,      // rs selector
    output wire [n-1:0] o_rs_data, // rs contents
    input  wire [  2:0] i_rt,      // rt selector
    output wire [n-1:0] o_rt_data, // rt contents
    input  wire [  2:0] i_rd,      // rd selector
    input  wire [n-1:0] i_wdata,   // data to write
    input  wire         i_rd_we    // write enable
    );
   
   wire [n-1:0] r0_out;
   wire [n-1:0] r1_out;
   wire [n-1:0] r2_out;
   wire [n-1:0] r3_out;
   wire [n-1:0] r4_out;
   wire [n-1:0] r5_out;
   wire [n-1:0] r6_out;
   wire [n-1:0] r7_out;

   Nbit_reg #(n, 0) reg0 (.in(i_wdata), .out(r0_out), .clk(clk), .we(i_rd_we & i_rd == 3'b000), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg1 (.in(i_wdata), .out(r1_out), .clk(clk), .we(i_rd_we & i_rd == 3'b001), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg2 (.in(i_wdata), .out(r2_out), .clk(clk), .we(i_rd_we & i_rd == 3'b010), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg3 (.in(i_wdata), .out(r3_out), .clk(clk), .we(i_rd_we & i_rd == 3'b011), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg4 (.in(i_wdata), .out(r4_out), .clk(clk), .we(i_rd_we & i_rd == 3'b100), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg5 (.in(i_wdata), .out(r5_out), .clk(clk), .we(i_rd_we & i_rd == 3'b101), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg6 (.in(i_wdata), .out(r6_out), .clk(clk), .we(i_rd_we & i_rd == 3'b110), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg7 (.in(i_wdata), .out(r7_out), .clk(clk), .we(i_rd_we & i_rd == 3'b111), .gwe(gwe), .rst(rst));

   mux8to1 mux_rs(.S1(i_rs[2]), .S2(i_rs[1]), .S3(i_rs[0]), .A(r7_out), .B(r3_out), .C(r5_out), .D(r1_out), 
                    .E(r6_out), .F(r2_out), .G(r4_out), .H(r0_out), .Out(o_rs_data));

   mux8to1 mux_rt(.S1(i_rt[2]), .S2(i_rt[1]), .S3(i_rt[0]), .A(r7_out), .B(r3_out), .C(r5_out), .D(r1_out), 
                    .E(r6_out), .F(r2_out), .G(r4_out), .H(r0_out), .Out(o_rt_data));

endmodule
