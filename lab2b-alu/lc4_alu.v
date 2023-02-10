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

      // CLA calculations

      wire cin;
      assign cin = ((i_insn[15:12] == 4'b0001 & i_insn[5:3] == 3'b010) | i_insn[15:11]== 5'b11001 | i_insn[15:12] == 4'b0000);

      wire [15:0] a;
      assign a = (i_insn[15:12] == 4'b0001 | i_insn[15:12] == 4'b0110 | i_insn[15:12] == 4'b0111) ? i_r1data : i_pc;

      wire [15:0] m0;
      assign m0 = (i_insn[15:13] == 3'b011) ? ({{10{i_insn[5]}}, i_insn[5:0]}) : {{11{i_insn[4]}}, i_insn[4:0]};

      wire [15:0] m1;
      assign m1 = (i_insn[15:11] == 5'b11001) ? {{5{i_insn[10]}}, i_insn[10:0]} : m0;

      wire [15:0] zerowire;
      assign zerowire = 16'b0000000000000000;

      wire [15:0] m2;
      assign m2 = (i_insn[15:9] == 7'b0) ? zerowire : m1;

      wire [15:0] m3;
      assign m3 = (i_insn[15:12] == 4'b0) ? {{7{i_insn[8]}}, i_insn[8:0]} : m2;

      wire [15:0] m4;
      assign m4 = (i_insn[5:3] == 3'b010) ? ~i_r2data : i_r2data;

      wire [15:0] b;
      assign b = (i_insn[15:12] == 4'b0001 & i_insn[5] == 1'b0) ? m4 : m3;

      //wire [15:0] bprime;
      //assign bprime = (i_insn[15:9] == 7'b0000000) ? 16'b0000000000000000 : b;

      wire [15:0] cla_out;
      cla16 cla(.a(a), .b(b), .cin(cin), .sum(cla_out));

      //assign o_result = cla_out;

      // Logic

      wire [15:0] l1;
      assign l1 = (i_insn[4]) ? (i_r1data | i_r2data) : (i_r1data & i_r2data);

      wire [15:0] l2;
      assign l2 = (i_insn[4]) ? (i_r1data ^ i_r2data) : ~i_r1data;

      wire [15:0] l3;
      assign l3 = (i_insn[3]) ? l2 : l1;

      wire [15:0] logic_out;
      assign logic_out = (i_insn[5]) ? (i_r1data & {{11{i_insn[4]}}, i_insn[4:0]}) : l3;

      // cmp

      wire [15:0] c1;
      assign c1 = (i_insn[8:7]== 2'b00 & $signed(i_r1data) < $signed(i_r2data)) | 
                  (i_insn[8:7] == 2'b01  & (i_r1data < i_r2data)) |
                  (i_insn[8:7]== 2'b10 & $signed(i_r1data) < $signed(i_insn[6:0])) |
                  (i_insn[8:7]== 2'b11 & i_r1data < i_insn[6:0]) ? 16'b1111111111111111 : 16'b1;
      
      wire [15:0] cmp_out;   
      assign cmp_out = ((i_insn[8] == 0 & i_r1data == i_r2data) | (i_insn[8:7] == 2'b10 & i_r1data == {{9{i_insn[6]}}, i_insn[6:0]}) |
                        (i_insn[8:7] == 2'b11 & i_r1data == i_insn[6:0])) ? 16'b0 : c1;

      // shifts and mod

      wire [15:0] qout;
      wire [15:0] rout;
      lc4_divider lc4(.i_dividend(i_r1data), .i_divisor(i_r2data), .o_remainder(rout), .o_quotient(qout));

      wire [15:0] shift_out;
      mux4to1 mux4(.S1(i_insn[5]), .S2(i_insn[4]), .A(rout), .B($signed(i_r1data) >>> i_insn[3:0]), .C(i_r1data >> i_insn[3:0]), 
                  .D(i_r1data << i_insn[3:0]), .Out(shift_out));

      // final arith

      wire [15:0] a1;
      assign a1 = (i_insn[5:3] == 3'b011) ? qout : cla_out;

      wire [15:0] arith;
      assign arith = (i_insn[5:3] == 3'b001) ? (i_r1data * i_r2data) : a1;

      // jsrr and jsr

      wire [15:0] jsr;
      assign jsr = (i_insn[11]) ? ((i_pc & 16'h8000) | i_insn[10:0] << 4) : i_r1data;

      // jmp

      wire [15:0] jmp;
      assign jmp = (i_insn[11]) ? cla_out : i_r1data;

      // final 16 bit mux

      mux16to1 mux16(.S1(i_insn[15]), .S2(i_insn[14]), .S3(i_insn[13]), .S4(i_insn[12]), 
                     .A(16'h8000 | i_insn[7:0]), .B(cla_out), .C(16'b0), .D(16'b0),
                     .E((i_r1data & 16'hFF) | (i_insn[7:0] << 8)), .F(logic_out), .G({{7{i_insn[8]}}, i_insn[8:0]}), .H(arith),
                     .I(cla_out), .J(cla_out), .K(shift_out), .L(cmp_out),
                     .M(jmp), .N(jsr), .O(i_r1data), .P(cla_out), .Out(o_result)); 


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

