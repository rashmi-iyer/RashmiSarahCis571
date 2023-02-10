/* TODO: INSERT NAME AND PENNKEY HERE */
/* Rashmi Iyer - rashmii */
/* Sarah Luthra - saluthra */

`timescale 1ns / 1ps
`default_nettype none

module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);

      /*** YOUR CODE HERE ***/
      wire [15:0] dividend1; // represents dividend post the first iteration
      wire [15:0] remainder1;
      wire [15:0] quotient1;
      lc4_divider_one_iter m1(.i_dividend(i_dividend), .i_divisor(i_divisor), .i_remainder(16'b0), 
                        .i_quotient(16'b0), .o_dividend(dividend1), .o_remainder(remainder1), .o_quotient(quotient1));
      
      wire [15:0] dividend2;
      wire [15:0] remainder2;
      wire [15:0] quotient2;
      lc4_divider_one_iter m2(.i_dividend(dividend1), .i_divisor(i_divisor), .i_remainder(remainder1), 
                        .i_quotient(quotient1), .o_dividend(dividend2), .o_remainder(remainder2), .o_quotient(quotient2));

      wire [15:0] dividend3;
      wire [15:0] remainder3;
      wire [15:0] quotient3;
      lc4_divider_one_iter m3(.i_dividend(dividend2), .i_divisor(i_divisor), .i_remainder(remainder2), 
                        .i_quotient(quotient2), .o_dividend(dividend3), .o_remainder(remainder3), .o_quotient(quotient3));

      wire [15:0] dividend4;
      wire [15:0] remainder4;
      wire [15:0] quotient4;
      lc4_divider_one_iter m4(.i_dividend(dividend3), .i_divisor(i_divisor), .i_remainder(remainder3), 
                        .i_quotient(quotient3), .o_dividend(dividend4), .o_remainder(remainder4), .o_quotient(quotient4));

      wire [15:0] dividend5;
      wire [15:0] remainder5;
      wire [15:0] quotient5;
      lc4_divider_one_iter m5(.i_dividend(dividend4), .i_divisor(i_divisor), .i_remainder(remainder4), 
                        .i_quotient(quotient4), .o_dividend(dividend5), .o_remainder(remainder5), .o_quotient(quotient5));

      wire [15:0] dividend6;
      wire [15:0] remainder6;
      wire [15:0] quotient6;
      lc4_divider_one_iter m6(.i_dividend(dividend5), .i_divisor(i_divisor), .i_remainder(remainder5), 
                        .i_quotient(quotient5), .o_dividend(dividend6), .o_remainder(remainder6), .o_quotient(quotient6));

      wire [15:0] dividend7;
      wire [15:0] remainder7;
      wire [15:0] quotient7;
      lc4_divider_one_iter m7(.i_dividend(dividend6), .i_divisor(i_divisor), .i_remainder(remainder6), 
                        .i_quotient(quotient6), .o_dividend(dividend7), .o_remainder(remainder7), .o_quotient(quotient7));

      wire [15:0] dividend8;
      wire [15:0] remainder8;
      wire [15:0] quotient8;
      lc4_divider_one_iter m8(.i_dividend(dividend7), .i_divisor(i_divisor), .i_remainder(remainder7), 
                        .i_quotient(quotient7), .o_dividend(dividend8), .o_remainder(remainder8), .o_quotient(quotient8));

      wire [15:0] dividend9;
      wire [15:0] remainder9;
      wire [15:0] quotient9;
      lc4_divider_one_iter m9(.i_dividend(dividend8), .i_divisor(i_divisor), .i_remainder(remainder8), 
                        .i_quotient(quotient8), .o_dividend(dividend9), .o_remainder(remainder9), .o_quotient(quotient9));

      wire [15:0] dividend10;
      wire [15:0] remainder10;
      wire [15:0] quotient10;
      lc4_divider_one_iter m10(.i_dividend(dividend9), .i_divisor(i_divisor), .i_remainder(remainder9), 
                        .i_quotient(quotient9), .o_dividend(dividend10), .o_remainder(remainder10), .o_quotient(quotient10));

      wire [15:0] dividend11;
      wire [15:0] remainder11;
      wire [15:0] quotient11;
      lc4_divider_one_iter m11(.i_dividend(dividend10), .i_divisor(i_divisor), .i_remainder(remainder10), 
                        .i_quotient(quotient10), .o_dividend(dividend11), .o_remainder(remainder11), .o_quotient(quotient11));

      wire [15:0] dividend12;
      wire [15:0] remainder12;
      wire [15:0] quotient12;
      lc4_divider_one_iter m12(.i_dividend(dividend11), .i_divisor(i_divisor), .i_remainder(remainder11), 
                        .i_quotient(quotient11), .o_dividend(dividend12), .o_remainder(remainder12), .o_quotient(quotient12));
      
      wire [15:0] dividend13;
      wire [15:0] remainder13;
      wire [15:0] quotient13;
      lc4_divider_one_iter m13(.i_dividend(dividend12), .i_divisor(i_divisor), .i_remainder(remainder12), 
                        .i_quotient(quotient12), .o_dividend(dividend13), .o_remainder(remainder13), .o_quotient(quotient13));

      wire [15:0] dividend14;
      wire [15:0] remainder14;
      wire [15:0] quotient14;
      lc4_divider_one_iter m14(.i_dividend(dividend13), .i_divisor(i_divisor), .i_remainder(remainder13), 
                        .i_quotient(quotient13), .o_dividend(dividend14), .o_remainder(remainder14), .o_quotient(quotient14));

      wire [15:0] dividend15;
      wire [15:0] remainder15;
      wire [15:0] quotient15;
      lc4_divider_one_iter m15(.i_dividend(dividend14), .i_divisor(i_divisor), .i_remainder(remainder14), 
                        .i_quotient(quotient14), .o_dividend(dividend15), .o_remainder(remainder15), .o_quotient(quotient15));

      wire [15:0] remainder16;
      wire [15:0] quotient16;
      lc4_divider_one_iter m16(.i_dividend(dividend15), .i_divisor(i_divisor), .i_remainder(remainder15), 
                        .i_quotient(quotient15), .o_dividend(), .o_remainder(remainder16), .o_quotient(quotient16));

      assign o_remainder = (i_divisor == 0) ? 16'b0 : remainder16;
      assign o_quotient = (i_divisor == 0) ? 16'b0 : quotient16;

endmodule // lc4_divider

module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire [15:0] o_remainder,
                            output wire [15:0] o_quotient);

      /*** YOUR CODE HERE ***/
      wire [15:0] firstRUpdate;
      assign firstRUpdate = (i_remainder << 1) | ((i_dividend >> 15) & 16'b1);
      assign o_dividend = i_dividend << 1;
      wire sel;
      assign sel = firstRUpdate < i_divisor;
      assign o_quotient = sel ? (i_quotient << 1) : (i_quotient << 1 | 16'b1);
      assign o_remainder = sel ? firstRUpdate : firstRUpdate - i_divisor;

endmodule

/*module mux2to1(input wire S,
            input wire [15:0] A,
            input wire [15:0] B,
            output wire [15:0] Out);
      assign Out = S ? B : A;
endmodule */
