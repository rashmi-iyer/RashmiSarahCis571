/* Sarah Luthra, saluthra
   Rashmi Iyer, rashmii */

`timescale 1ns / 1ps
`default_nettype none

module lc4_alu(input  wire [15:0] i_insn,
               input wire [15:0]  i_pc,
               input wire [15:0]  i_r1data,
               input wire [15:0]  i_r2data,
               output wire [15:0] o_result);


      /*** YOUR CODE HERE ***/

endmodule

module mux2to1(input wire S,
            input wire [15:0] A,
            input wire [15:0] B,
            output wire [15:0] Out);
      assign Out = S ? B : A;
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

module mux16to1(input wire S1,
            input wire S2,
            input wire S3,
            input wire S4,
            input wire [15:0] A,
            input wire [15:0] B,
            input wire [15:0] C,
            input wire [15:0] D,
            input wire [15:0] E,
            input wire [15:0] F,
            input wire [15:0] G,
            input wire [15:0] H,
            input wire [15:0] I,
            input wire [15:0] J,
            input wire [15:0] K,
            input wire [15:0] L,
            input wire [15:0] M,
            input wire [15:0] N,
            input wire [15:0] O,
            input wire [15:0] P,
            output wire [15:0] Out);
      wire [15:0] mux1out;
      wire [15:0] mux2out;
      mux8to1 m1(.S1(S1), .S2(S2), .S3(S3), .A(A), .B(B), .C(C), .D(D), .E(E), .F(F), .G(G), .H(H), .Out(mux1out));
      mux8to1 m2(.S1(S1), .S2(S2), .S3(S3), .A(I), .B(J), .C(K), .D(L), .E(M), .F(N), .G(O), .H(P), .Out(mux2out));
      mux2to1 m3(.S(S4), .A(mux1out), .B(mux2out), .Out(Out));
endmodule

