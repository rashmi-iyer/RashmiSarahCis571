`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

/* 8-register, n-bit register file with
 * four read ports and two write ports
 * to support two pipes.
 * 
 * If both pipes try to write to the
 * same register, pipe B wins.
 * 
 * Inputs should be bypassed to the outputs
 * as needed so the register file returns
 * data that is written immediately
 * rather than only on the next cycle.
 */
module lc4_regfile_ss #(parameter n = 16)
   (input  wire         clk,
    input  wire         gwe,
    input  wire         rst,

    input  wire [  2:0] i_rs_A,      // pipe A: rs selector
    output wire [n-1:0] o_rs_data_A, // pipe A: rs contents
    input  wire [  2:0] i_rt_A,      // pipe A: rt selector
    output wire [n-1:0] o_rt_data_A, // pipe A: rt contents

    input  wire [  2:0] i_rs_B,      // pipe B: rs selector
    output wire [n-1:0] o_rs_data_B, // pipe B: rs contents
    input  wire [  2:0] i_rt_B,      // pipe B: rt selector
    output wire [n-1:0] o_rt_data_B, // pipe B: rt contents

    input  wire [  2:0]  i_rd_A,     // pipe A: rd selector
    input  wire [n-1:0]  i_wdata_A,  // pipe A: data to write
    input  wire          i_rd_we_A,  // pipe A: write enable

    input  wire [  2:0]  i_rd_B,     // pipe B: rd selector
    input  wire [n-1:0]  i_wdata_B,  // pipe B: data to write
    input  wire          i_rd_we_B   // pipe B: write enable
    );

   /*** TODO: Your Code Here ***/

   wire [n-1:0] r0_out;
   wire [n-1:0] r1_out;
   wire [n-1:0] r2_out;
   wire [n-1:0] r3_out;
   wire [n-1:0] r4_out;
   wire [n-1:0] r5_out;
   wire [n-1:0] r6_out;
   wire [n-1:0] r7_out;

   Nbit_reg #(n, 0) reg0 (.in(i_rd_we_B & i_rd_B == 3'b000 ? i_wdata_B : i_wdata_A), .out(r0_out), .clk(clk), .we((i_rd_we_A & i_rd_A == 3'b000) | (i_rd_we_B & i_rd_B == 3'b000)), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg1 (.in(i_rd_we_B & i_rd_B == 3'b001 ? i_wdata_B : i_wdata_A), .out(r1_out), .clk(clk), .we((i_rd_we_A & i_rd_A == 3'b001) | (i_rd_we_B & i_rd_B == 3'b001)), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg2 (.in(i_rd_we_B & i_rd_B == 3'b010 ? i_wdata_B : i_wdata_A), .out(r2_out), .clk(clk), .we((i_rd_we_A & i_rd_A == 3'b010) | (i_rd_we_B & i_rd_B == 3'b010)), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg3 (.in(i_rd_we_B & i_rd_B == 3'b011 ? i_wdata_B : i_wdata_A), .out(r3_out), .clk(clk), .we((i_rd_we_A & i_rd_A == 3'b011) | (i_rd_we_B & i_rd_B == 3'b011)), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg4 (.in(i_rd_we_B & i_rd_B == 3'b100 ? i_wdata_B : i_wdata_A), .out(r4_out), .clk(clk), .we((i_rd_we_A & i_rd_A == 3'b100) | (i_rd_we_B & i_rd_B == 3'b100)), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg5 (.in(i_rd_we_B & i_rd_B == 3'b101 ? i_wdata_B : i_wdata_A), .out(r5_out), .clk(clk), .we((i_rd_we_A & i_rd_A == 3'b101) | (i_rd_we_B & i_rd_B == 3'b101)), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg6 (.in(i_rd_we_B & i_rd_B == 3'b110 ? i_wdata_B : i_wdata_A), .out(r6_out), .clk(clk), .we((i_rd_we_A & i_rd_A == 3'b110) | (i_rd_we_B & i_rd_B == 3'b110)), .gwe(gwe), .rst(rst));
   Nbit_reg #(n, 0) reg7 (.in(i_rd_we_B & i_rd_B == 3'b111 ? i_wdata_B : i_wdata_A), .out(r7_out), .clk(clk), .we((i_rd_we_A & i_rd_A == 3'b111) | (i_rd_we_B & i_rd_B == 3'b111)), .gwe(gwe), .rst(rst));

   wire[15:0] o_rs_data_A_init;
   assign o_rs_data_A = (i_rd_we_B & i_rd_B == i_rs_A) ? i_wdata_B : ((i_rd_we_A & i_rd_A == i_rs_A) ? i_wdata_A : o_rs_data_A_init);
   wire[15:0] o_rt_data_A_init;
   assign o_rt_data_A = (i_rd_we_B & i_rd_B == i_rt_A) ? i_wdata_B : ((i_rd_we_A & i_rd_A == i_rt_A) ? i_wdata_A : o_rt_data_A_init);

   mux8to1 mux_rs_A(.S1(i_rs_A[2]), .S2(i_rs_A[1]), .S3(i_rs_A[0]), .A(r7_out), .B(r3_out), .C(r5_out), .D(r1_out), 
                    .E(r6_out), .F(r2_out), .G(r4_out), .H(r0_out), .Out(o_rs_data_A_init));

   mux8to1 mux_rt_A(.S1(i_rt_A[2]), .S2(i_rt_A[1]), .S3(i_rt_A[0]), .A(r7_out), .B(r3_out), .C(r5_out), .D(r1_out), 
                    .E(r6_out), .F(r2_out), .G(r4_out), .H(r0_out), .Out(o_rt_data_A_init));


   wire[15:0] o_rs_data_B_init;
   assign o_rs_data_B = (i_rd_we_B & i_rd_B == i_rs_B) ? i_wdata_B : ((i_rd_we_A & i_rd_A == i_rs_B) ? i_wdata_A : o_rs_data_B_init);
   wire[15:0] o_rt_data_B_init;
   assign o_rt_data_B = (i_rd_we_B & i_rd_B == i_rt_B) ? i_wdata_B : ((i_rd_we_A & i_rd_A == i_rt_B) ? i_wdata_A : o_rt_data_B_init);

   mux8to1 mux_rs_B(.S1(i_rs_B[2]), .S2(i_rs_B[1]), .S3(i_rs_B[0]), .A(r7_out), .B(r3_out), .C(r5_out), .D(r1_out), 
                    .E(r6_out), .F(r2_out), .G(r4_out), .H(r0_out), .Out(o_rs_data_B_init));

   mux8to1 mux_rt_B(.S1(i_rt_B[2]), .S2(i_rt_B[1]), .S3(i_rt_B[0]), .A(r7_out), .B(r3_out), .C(r5_out), .D(r1_out), 
                    .E(r6_out), .F(r2_out), .G(r4_out), .H(r0_out), .Out(o_rt_data_B_init));


endmodule



module mux2to1(input wire S,
            input wire [15:0] A,
            input wire [15:0] B,
            output wire [15:0] Out);
      assign Out = S ? A : B;
endmodule

module mux4to1(input wire S1,
            input wire S2,
            input wire [15:0] A,
            input wire [15:0] B,
            input wire [15:0] C,
            input wire [15:0] D,
            output wire [15:0] Out);
      wire [15:0] mux1out;
      wire [15:0] mux2out;
      mux2to1 m1(.S(S1), .A(A), .B(B), .Out(mux1out));
      mux2to1 m2(.S(S1), .A(C), .B(D), .Out(mux2out));
      mux2to1 m3(.S(S2), .A(mux1out), .B(mux2out), .Out(Out));
endmodule

module mux8to1(input wire S1,
            input wire S2,
            input wire S3,
            input wire [15:0] A,
            input wire [15:0] B,
            input wire [15:0] C,
            input wire [15:0] D,
            input wire [15:0] E,
            input wire [15:0] F,
            input wire [15:0] G,
            input wire [15:0] H,
            output wire [15:0] Out);
      wire [15:0] mux1out;
      wire [15:0] mux2out;
      mux4to1 m1(.S1(S1), .S2(S2), .A(A), .B(B), .C(C), .D(D), .Out(mux1out));
      mux4to1 m2(.S1(S1), .S2(S2), .A(E), .B(F), .C(G), .D(H), .Out(mux2out));
      mux2to1 m3(.S(S3), .A(mux1out), .B(mux2out), .Out(Out));
endmodule