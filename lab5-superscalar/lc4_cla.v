/* Sarah Luthra, saluthra
   Rashmi Iyer, rashmii */

`timescale 1ns / 1ps
`default_nettype none

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule


/*module gp2(input wire [1:0] gin, 
           input wire [1:0] pin,
           input wire cin,
           output wire gout,
           output wire pout,
           output wire [2:0] cout);

    wire gentemp1;
    wire proptemp1;
    wire gentemp2;
    wire proptemp2;
    gp1 g1(.a(gin[0]), .b(pin[0]), .g(gentemp1), .p(proptemp1));
    gp1 g2(.a(gin[1]), .b(pin[1]), .g(gentemp2), .p(proptemp2));

endmodule*/

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, 
           input wire [3:0] pin,
           input wire cin,
           output wire gout,
           output wire pout,
           output wire [2:0] cout);

    assign cout[0] = gin[0] | (pin[0] & cin); // c1 
    assign cout[1] = gin[1] | (pin[1] & gin[0]) | (pin[1] & pin[0] & cin); //c2
    assign cout[2] = gin[2] | (pin[2] & gin[1]) | (pin[2] & pin[1] & gin[0]) | (pin[2] & pin[1] & pin[0] & cin); //c3
   // assign cout[3] = gin[3] | (pin[3] & gin[2]) | (pin[3] & pin[2] & gin[1]) | (pin[3] & pin[2] & pin[1] & gin[0]) | (pin[3] & pin[2] & pin[1] & pin[0] & cin[0]); //c4

    assign pout = (& pin);
    assign gout = gin[3] | (pin[3] & gin[2]) | (pin[3] & pin[2] & gin[1]) | (pin[3] & pin[2] & pin[1] & gin[0]);
    
endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);

  wire [15:0] ginit;
  wire [15:0] pinit;
  wire [15:0] cbus;
  wire gout40;
  wire pout40;
  wire gout41;
  wire pout41;
  wire gout42;
  wire pout42;
  wire gout43;
  wire pout43;

  //ginit and pinit generation
  genvar i;
  for (i = 0; i < 16; i = i+1) begin
    gp1 g(.a(a[i]), .b(b[i]), .g(ginit[i]), .p(pinit[i]));
  end

  //carry generation
  assign cbus[0] = cin;
  gp4 gp40(.gin(ginit[3:0]), .pin(pinit[3:0]), .cin(cin), .gout(gout40), .pout(pout40), .cout(cbus[3:1]));
  assign cbus[4] = gout40 | (pout40 & cin);
  gp4 gp41(.gin(ginit[7:4]), .pin(pinit[7:4]), .cin(cbus[4]), .gout(gout41), .pout(pout41), .cout(cbus[7:5]));
  assign cbus[8] = (cin & pout40 & pout41) | (gout40 & pout41) | gout41;
  gp4 gp42(.gin(ginit[11:8]), .pin(pinit[11:8]), .cin(cbus[8]), .gout(gout42), .pout(pout42), .cout(cbus[11:9]));
  assign cbus[12] = (cin & pout40 & pout41 & pout42) | (gout40 & pout41 & pout42) | (gout41 & pout42) | gout42;
  gp4 gp43(.gin(ginit[15:12]), .pin(pinit[15:12]), .cin(cbus[12]), .gout(gout43), .pout(pout43), .cout(cbus[15:13]));

  //assign cbus[15] = (cin & pout40 & pout41 & pout42 & pout43) | (gout40 & pout41 & pout42 & pout43) | (gout41 & pout42 & pout43) | (gout42 & pout43) | gout43;

  genvar j;
  for (j = 0; j < 16; j = j + 1) begin
    assign sum[j] = (a[j] ^ b[j]) ^ cbus[j];
  end
  
endmodule


/** Lab 2 Extra Credit, see details at
  https://github.com/upenn-acg/cis501/blob/master/lab2-alu/lab2-cla.md#extra-credit
 If you are not doing the extra credit, you should leave this module empty.
 */
module gpn
  #(parameter N = 4)
  (input wire [N-1:0] gin, pin,
   input wire  cin,
   output wire gout, pout,
   output wire [N-2:0] cout);
 
endmodule

