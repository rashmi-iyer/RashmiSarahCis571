`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

module lc4_processor(input wire         clk,             // main clock
                     input wire         rst,             // global reset
                     input wire         gwe,             // global we for single-step clock

                     output wire [15:0] o_cur_pc,        // address to read from instruction memory
                     input wire [15:0]  i_cur_insn_A,    // output of instruction memory (pipe A)
                     input wire [15:0]  i_cur_insn_B,    // output of instruction memory (pipe B)

                     output wire [15:0] o_dmem_addr,     // address to read/write from/to data memory
                     input wire [15:0]  i_cur_dmem_data, // contents of o_dmem_addr
                     output wire        o_dmem_we,       // data memory write enable
                     output wire [15:0] o_dmem_towrite,  // data to write to o_dmem_addr if we is set

                     // testbench signals (always emitted from the WB stage)
                     output wire [ 1:0] test_stall_A,        // is this a stall cycle?  (0: no stall,
                     output wire [ 1:0] test_stall_B,        // 1: pipeline stall, 2: branch stall, 3: load stall)

                     output wire [15:0] test_cur_pc_A,       // program counter
                     output wire [15:0] test_cur_pc_B,
                     output wire [15:0] test_cur_insn_A,     // instruction bits
                     output wire [15:0] test_cur_insn_B,
                     output wire        test_regfile_we_A,   // register file write-enable
                     output wire        test_regfile_we_B,
                     output wire [ 2:0] test_regfile_wsel_A, // which register to write
                     output wire [ 2:0] test_regfile_wsel_B,
                     output wire [15:0] test_regfile_data_A, // data to write to register file
                     output wire [15:0] test_regfile_data_B,
                     output wire        test_nzp_we_A,       // nzp register write enable
                     output wire        test_nzp_we_B,
                     output wire [ 2:0] test_nzp_new_bits_A, // new nzp bits
                     output wire [ 2:0] test_nzp_new_bits_B,
                     output wire        test_dmem_we_A,      // data memory write enable
                     output wire        test_dmem_we_B,
                     output wire [15:0] test_dmem_addr_A,    // address to read/write from/to memory
                     output wire [15:0] test_dmem_addr_B,
                     output wire [15:0] test_dmem_data_A,    // data to read/write from/to memory
                     output wire [15:0] test_dmem_data_B,

                     // zedboard switches/display/leds (ignore if you don't want to control these)
                     input  wire [ 7:0] switch_data,         // read on/off status of zedboard's 8 switches
                     output wire [ 7:0] led_data             // set on/off status of zedboard's 8 leds
                     );

   /***  YOUR CODE HERE ***/

   assign led_data = switch_data;

   wire [15:0] pc_plus_one;
   cla16 pc_cla(.a(pc), .b(16'b1), .cin(1'b0), .sum(pc_plus_one));

   wire [15:0] pc_plus_two;
   cla16 pc_cla2(.a(pc), .b(16'h2), .cin(1'b0), .sum(pc_plus_two));

   wire [15:0] pc;
   wire [15:0] next_pc;

   assign next_pc = ltu_destA ? pc : (b_stall ? pc_plus_one: pc_plus_two);
   //assign next_pc = take_branch ? x_aluout : (load_to_use_stall ? pc : pc_plus_one);

   Nbit_reg #(16, 16'h8200) f_pc_reg (.in(next_pc), .out(pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   // code to fetch here
   wire [15:0] d_pc_A;
   wire [15:0] d_insn_A;
   wire [15:0] d_pc_plus_one_A;
   wire [15:0] d_pc_B;
   wire [15:0] d_insn_B;
   wire [15:0] d_pc_plus_one_B;
   //Nbit_reg #(16, 16'h8200) d_pc_reg (.in(take_branch ? 16'b0 : pc), .out(d_pc), .clk(clk), .we(!load_to_use_stall), .gwe(gwe), .rst(rst));
   //Nbit_reg #(16, 16'b0) d_insn_reg (.in(take_branch ? 16'b0 : i_cur_insn), .out(d_insn), .clk(clk), .we(!load_to_use_stall), .gwe(gwe), .rst(rst));
   //Nbit_reg #(16, 16'b0) d_pc_plus_one_reg (.in(take_branch ? 16'b0 : pc_plus_one), .out(d_pc_plus_one), .clk(clk), .we(!load_to_use_stall), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'h8200) d_pc_reg_A (.in(ltu_destA ? d_pc_A : (b_stall ? d_pc_B : pc)), .out(d_pc_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) d_insn_reg_A (.in(ltu_destA ? d_insn_A : (b_stall ? d_insn_B : i_cur_insn_A)), .out(d_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) d_pc_plus_one_reg_A (.in(ltu_destA ? d_pc_plus_one_A : (b_stall ? d_pc_plus_one_B : pc_plus_one)), .out(d_pc_plus_one_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   Nbit_reg #(16, 16'h8201) d_pc_reg_B (.in(ltu_destA ? d_pc_B : (b_stall ? pc : pc_plus_one)), .out(d_pc_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) d_insn_reg_B (.in(ltu_destA ? d_insn_B : (b_stall ? i_cur_insn_A : i_cur_insn_B)), .out(d_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) d_pc_plus_one_reg_B (.in(ltu_destA ? d_pc_plus_one_B : (b_stall ? pc_plus_one : pc_plus_two)), .out(d_pc_plus_one_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));


   //code to decode here
   wire [17:0] d_decode_output_A;
   wire [15:0] d_r1val_output_A;
   wire [15:0] d_r2val_output_A;
   wire [15:0] x_pc_A;
   wire [15:0] x_insn_A;
   wire [17:0] x_decodevals_A;
   wire [15:0] x_r1val_A;
   wire [15:0] x_r2val_A;
   wire [15:0] x_pc_plus_one_A;
   wire [17:0] d_decode_output_B;
   wire [15:0] d_r1val_output_B;
   wire [15:0] d_r2val_output_B;
   wire [15:0] x_pc_B;
   wire [15:0] x_insn_B;
   wire [17:0] x_decodevals_B;
   wire [15:0] x_r1val_B;
   wire [15:0] x_r2val_B;
   wire [15:0] x_pc_plus_one_B;

   //wire load_to_use_stall = x_decodevals[14] & ((d_decode_output[3] & (d_decode_output[2:0] == x_decodevals[10:8])) | 
                           //(d_decode_output[7] & d_decode_output[6:4] == x_decodevals[10:8] & !d_decode_output[15]) |
                           //d_decode_output[16]);

   lc4_decoder decoder_A(.insn(d_insn_A), .r1sel(d_decode_output_A[2:0]), .r1re(d_decode_output_A[3]), .r2sel(d_decode_output_A[6:4]), .r2re(d_decode_output_A[7]), 
      .wsel(d_decode_output_A[10:8]), .regfile_we(d_decode_output_A[11]), .nzp_we(d_decode_output_A[12]), .select_pc_plus_one(d_decode_output_A[13]),
      .is_load(d_decode_output_A[14]), .is_store(d_decode_output_A[15]), .is_branch(d_decode_output_A[16]), .is_control_insn(d_decode_output_A[17]));

   lc4_decoder decoder_B(.insn(d_insn_B), .r1sel(d_decode_output_B[2:0]), .r1re(d_decode_output_B[3]), .r2sel(d_decode_output_B[6:4]), .r2re(d_decode_output_B[7]), 
      .wsel(d_decode_output_B[10:8]), .regfile_we(d_decode_output_B[11]), .nzp_we(d_decode_output_B[12]), .select_pc_plus_one(d_decode_output_B[13]),
      .is_load(d_decode_output_B[14]), .is_store(d_decode_output_B[15]), .is_branch(d_decode_output_B[16]), .is_control_insn(d_decode_output_B[17]));

   
   wire a_to_b_dep;
   assign a_to_b_dep = d_decode_output_A[11] & ((d_decode_output_B[3] & d_decode_output_A[10:8] == d_decode_output_B[2:0]) | 
                                                         (d_decode_output_B[7] & d_decode_output_A[10:8] == d_decode_output_B[6:4]));

   wire ltu_destA;
   assign ltu_destA = ((x_decodevals_A[14] & ((d_decode_output_A[3] & (d_decode_output_A[2:0] == x_decodevals_A[10:8])) | 
                           (d_decode_output_A[7] & d_decode_output_A[6:4] == x_decodevals_A[10:8] & !d_decode_output_A[15]) |
                           d_decode_output_A[16]))  & !(x_decodevals_B[11] & x_decodevals_B[10:8] == x_decodevals_A[10:8]))|
                           (x_decodevals_B[14] & ((d_decode_output_A[3] & (d_decode_output_A[2:0] == x_decodevals_B[10:8])) | 
                           (d_decode_output_A[7] & d_decode_output_A[6:4] == x_decodevals_B[10:8] & !d_decode_output_A[15]) |
                           d_decode_output_A[16]));

   wire ltu_destB;
   assign ltu_destB = ((x_decodevals_A[14] & ((d_decode_output_B[3] & (d_decode_output_B[2:0] == x_decodevals_A[10:8])) | 
                           (d_decode_output_B[7] & d_decode_output_B[6:4] == x_decodevals_A[10:8] & !d_decode_output_B[15]) |
                           d_decode_output_B[16])) & !(d_decode_output_A[11] & d_decode_output_A[10:8] == x_decodevals_A[10:8])
                           & !(x_decodevals_B[11] & x_decodevals_B[10:8] == x_decodevals_A[10:8])) |
                           ((x_decodevals_B[14] & ((d_decode_output_B[3] & (d_decode_output_B[2:0] == x_decodevals_B[10:8])) | 
                           (d_decode_output_B[7] & d_decode_output_B[6:4] == x_decodevals_B[10:8] & !d_decode_output_B[15]) |
                           d_decode_output_B[16])) & !(d_decode_output_A[11] & d_decode_output_A[10:8] == x_decodevals_B[10:8]));

   wire struct_dep;
   assign struct_dep = (d_decode_output_B[15] | d_decode_output_B[14]) & (d_decode_output_A[15] | d_decode_output_A[14]);

   wire b_stall;
   assign b_stall = !ltu_destA & (ltu_destB | a_to_b_dep | struct_dep);

   //update i_rd, i_wdata, i_rd_we based on writeback

   lc4_regfile_ss#(16) regfile (.clk(clk), .gwe(gwe), .rst(rst), .i_rs_A(d_decode_output_A[2:0]), .o_rs_data_A(d_r1val_output_A), 
      .i_rt_A(d_decode_output_A[6:4]), .o_rt_data_A(d_r2val_output_A), .i_rd_A(w_decodevals_A[10:8]), .i_wdata_A(w_rd_write_val_A), .i_rd_we_A(w_decodevals_A[11]),
      .i_rs_B(d_decode_output_B[2:0]), .o_rs_data_B(d_r1val_output_B), .i_rt_B(d_decode_output_B[6:4]), 
      .o_rt_data_B(d_r2val_output_B), .i_rd_B(w_decodevals_B[10:8]), .i_wdata_B(w_rd_write_val_B), .i_rd_we_B(w_decodevals_B[11]));

   
   // This was WD bypass
   /* wire [15:0] d_actual_r1val;
   wire [15:0] d_actual_r2val;
   assign d_actual_r1val = (d_decode_output[3] & w_decodevals[10:8] == d_decode_output[2:0] & w_decodevals[11]) ?
                           w_rd_write_val : d_r1val_output;
   assign d_actual_r2val = (d_decode_output[7] & w_decodevals[10:8] == d_decode_output[6:4] & w_decodevals[11]) ?
                           w_rd_write_val : d_r2val_output; */

   //Nbit_reg #(16, 16'h8200) x_pc_reg (.in((load_to_use_stall | take_branch) ? 16'b0 : d_pc), .out(x_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   //Nbit_reg #(16, 16'b0) x_insn_reg (.in(take_branch ? 16'b0 : (load_to_use_stall ? 16'b1 : d_insn)), .out(x_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   //Nbit_reg #(18, 18'b0) x_decodevals_reg (.in((take_branch | load_to_use_stall) ? 18'b0 : d_decode_output), .out(x_decodevals), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   //Nbit_reg #(16, 16'b0) x_r1val_reg (.in((take_branch | load_to_use_stall) ? 16'b0 : d_r1val_output), .out(x_r1val), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   //Nbit_reg #(16, 16'b0) x_r2val_reg (.in((take_branch | load_to_use_stall) ? 16'b0 : d_r2val_output), .out(x_r2val), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   //Nbit_reg #(16, 16'b0) x_pc_plus_one_reg (.in((take_branch | load_to_use_stall) ? 16'b0 : d_pc_plus_one), .out(x_pc_plus_one), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'h8200) x_pc_reg_A (.in(ltu_destA ? 16'b0 : d_pc_A), .out(x_pc_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_insn_reg_A (.in(ltu_destA ? 16'b1 : d_insn_A), .out(x_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 18'b0) x_decodevals_reg_A (.in(ltu_destA ? 18'b0 : d_decode_output_A), .out(x_decodevals_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_r1val_reg_A (.in(ltu_destA ? 16'b0 : d_r1val_output_A), .out(x_r1val_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_r2val_reg_A (.in(ltu_destA ? 16'b0 : d_r2val_output_A), .out(x_r2val_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_pc_plus_one_reg_A (.in(ltu_destA ? 16'b0 : d_pc_plus_one_A), .out(x_pc_plus_one_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   Nbit_reg #(16, 16'h8200) x_pc_reg_B (.in(ltu_destA | b_stall ? 16'b0 : d_pc_B), .out(x_pc_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_insn_reg_B (.in(ltu_destA | a_to_b_dep | struct_dep ? (16'h2) : (ltu_destB ? 16'b1 : d_insn_B)), .out(x_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 18'b0) x_decodevals_reg_B (.in(ltu_destA | b_stall ? 18'b0: d_decode_output_B), .out(x_decodevals_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_r1val_reg_B (.in(ltu_destA | b_stall ? 16'b0 : d_r1val_output_B), .out(x_r1val_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_r2val_reg_B (.in(ltu_destA | b_stall ? 16'b0: d_r2val_output_B), .out(x_r2val_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_pc_plus_one_reg_B (.in(ltu_destA | b_stall ? 16'b0: d_pc_plus_one_B), .out(x_pc_plus_one_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   //code to execute here

   wire [15:0] x_aluout_A;
   wire [15:0] m_pc_A;
   wire [15:0] m_insn_A;
   wire [17:0] m_decodevals_A;
   wire [15:0] m_r1val_A;
   wire [15:0] m_r2val_A;
   wire [15:0] m_aluout_A;
   wire [15:0] x_actual_r1val_A;
   wire [15:0] x_actual_r2val_A;
   wire [15:0] m_pc_plus_one_A;
   wire [15:0] x_aluout_B;
   wire [15:0] m_pc_B;
   wire [15:0] m_insn_B;
   wire [17:0] m_decodevals_B;
   wire [15:0] m_r1val_B;
   wire [15:0] m_r2val_B;
   wire [15:0] m_aluout_B;
   wire [15:0] x_actual_r1val_B;
   wire [15:0] x_actual_r2val_B;
   wire [15:0] m_pc_plus_one_B;

   // MX & WX bypass
   assign x_actual_r1val_A = (x_decodevals_A[3] & !m_decodevals_B[14] & m_decodevals_B[10:8] == x_decodevals_A[2:0] & m_decodevals_B[11]) ? m_aluout_B : 
                              ((x_decodevals_A[3] & !m_decodevals_A[14] & m_decodevals_A[10:8] == x_decodevals_A[2:0] & m_decodevals_A[11]) ? m_aluout_A :
                              ((x_decodevals_A[3] & w_decodevals_B[10:8] == x_decodevals_A[2:0] & w_decodevals_B[11]) ? w_rd_write_val_B : 
                              ((x_decodevals_A[3] & w_decodevals_A[10:8] == x_decodevals_A[2:0] & w_decodevals_A[11]) ? w_rd_write_val_A : x_r1val_A)));

   assign x_actual_r2val_A = (x_decodevals_A[7] & !m_decodevals_B[14] & m_decodevals_B[10:8] == x_decodevals_A[6:4] & m_decodevals_B[11]) ? m_aluout_B : 
                              ((x_decodevals_A[7] & !m_decodevals_A[14] & m_decodevals_A[10:8] == x_decodevals_A[6:4] & m_decodevals_A[11]) ? m_aluout_A :
                              ((x_decodevals_A[7] & w_decodevals_B[10:8] == x_decodevals_A[6:4] & w_decodevals_B[11]) ? w_rd_write_val_B : 
                              ((x_decodevals_A[7] & w_decodevals_A[10:8] == x_decodevals_A[6:4] & w_decodevals_A[11]) ? w_rd_write_val_A : x_r2val_A)));

   assign x_actual_r1val_B = (x_decodevals_B[3] & !m_decodevals_B[14] & m_decodevals_B[10:8] == x_decodevals_B[2:0] & m_decodevals_B[11]) ? m_aluout_B : 
                              ((x_decodevals_B[3] & !m_decodevals_A[14] & m_decodevals_A[10:8] == x_decodevals_B[2:0] & m_decodevals_A[11]) ? m_aluout_A :
                              ((x_decodevals_B[3] & w_decodevals_B[10:8] == x_decodevals_B[2:0] & w_decodevals_B[11]) ? w_rd_write_val_B : 
                              ((x_decodevals_B[3] & w_decodevals_A[10:8] == x_decodevals_B[2:0] & w_decodevals_A[11]) ? w_rd_write_val_A : x_r1val_B)));

   assign x_actual_r2val_B = (x_decodevals_B[7] & !m_decodevals_B[14] & m_decodevals_B[10:8] == x_decodevals_B[6:4] & m_decodevals_B[11]) ? m_aluout_B : 
                              ((x_decodevals_B[7] & !m_decodevals_A[14] & m_decodevals_A[10:8] == x_decodevals_B[6:4] & m_decodevals_A[11]) ? m_aluout_A :
                              ((x_decodevals_B[7] & w_decodevals_B[10:8] == x_decodevals_B[6:4] & w_decodevals_B[11]) ? w_rd_write_val_B : 
                              ((x_decodevals_B[7] & w_decodevals_A[10:8] == x_decodevals_B[6:4] & w_decodevals_A[11]) ? w_rd_write_val_A : x_r2val_B)));


   lc4_alu alu_A(.i_insn(x_insn_A), .i_pc(x_pc_A), .i_r1data(x_actual_r1val_A), .i_r2data(x_actual_r2val_A), .o_result(x_aluout_A));
   lc4_alu alu_B(.i_insn(x_insn_B), .i_pc(x_pc_B), .i_r1data(x_actual_r1val_B), .i_r2data(x_actual_r2val_B), .o_result(x_aluout_B));

   //wire take_branch;
   //assign take_branch = (x_decodevals[16] & ((x_insn[11:9] & (m_decodevals[12] ? nzp_towrite: m_nzp_out)) != 3'b0)) | x_decodevals[17];

   Nbit_reg #(16, 16'h8200) m_pc_reg_A (.in(x_pc_A), .out(m_pc_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_insn_reg_A (.in(x_insn_A), .out(m_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 18'b0) m_decodevals_reg_A (.in(x_decodevals_A), .out(m_decodevals_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_r1val_reg_A (.in(x_actual_r1val_A), .out(m_r1val_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_r2val_reg_A (.in(x_actual_r2val_A), .out(m_r2val_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_aluout_reg_A (.in(x_aluout_A), .out(m_aluout_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_pc_plus_one_reg_A (.in(x_pc_plus_one_A), .out(m_pc_plus_one_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   Nbit_reg #(16, 16'h8200) m_pc_reg_B (.in(x_pc_B), .out(m_pc_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_insn_reg_B (.in(x_insn_B), .out(m_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 18'b0) m_decodevals_reg_B (.in(x_decodevals_B), .out(m_decodevals_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_r1val_reg_B (.in(x_actual_r1val_B), .out(m_r1val_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_r2val_reg_B (.in(x_actual_r2val_B), .out(m_r2val_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_aluout_reg_B (.in(x_aluout_B), .out(m_aluout_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_pc_plus_one_reg_B (.in(x_pc_plus_one_B), .out(m_pc_plus_one_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   //code to memory here 

   assign o_dmem_addr = (m_decodevals_A[14] | m_decodevals_A[15]) ? m_aluout_A : ((m_decodevals_B[14] | m_decodevals_B[15]) ? m_aluout_B : 16'b0);
   assign o_dmem_we = m_decodevals_A[15] | m_decodevals_B[15];

   assign o_dmem_towrite = m_decodevals_A[15] ? o_dmem_ifA : o_dmem_ifB;

   wire[15:0] o_dmem_ifA;
   assign o_dmem_ifA = (m_decodevals_A[15] & w_decodevals_B[11] & m_decodevals_A[6:4] == w_decodevals_B[10:8]) ? w_rd_write_val_B :
                        (m_decodevals_A[15] & w_decodevals_A[11] & m_decodevals_A[6:4] == w_decodevals_A[10:8] ? w_rd_write_val_A :
                        (m_r2val_A));

   wire[15:0] o_dmem_ifB;
   assign o_dmem_ifB = m_decodevals_B[15] & m_decodevals_A[11] & m_decodevals_B[6:4] == m_decodevals_A[10:8] ? m_rd_write_val_A :
                        ((m_decodevals_B[15] & w_decodevals_B[11] & m_decodevals_B[6:4] == w_decodevals_B[10:8]) ? w_rd_write_val_B :
                        (m_decodevals_B[15] & w_decodevals_A[11] & m_decodevals_B[6:4] == w_decodevals_A[10:8] ? w_rd_write_val_A :
                        (m_r2val_B)));

   // 4B NEED TO UPDATE NO IDEA IF NZP IS DONE RIGHT
   wire[2:0] nzp_towrite_A;
   wire[2:0] m_nzp_out_A;
   Nbit_reg #(3, 3'b0) nzp_reg_A (.in(nzp_towrite_A), .out(m_nzp_out_A), .clk(clk), .we(m_decodevals_A[12]), .gwe(gwe), .rst(rst));
   wire[2:0] nzp_towrite_B;
   wire[2:0] m_nzp_out_B;
   Nbit_reg #(3, 3'b0) nzp_reg_B (.in(nzp_towrite_B), .out(m_nzp_out_B), .clk(clk), .we(m_decodevals_B[12]), .gwe(gwe), .rst(rst));

   assign nzp_towrite_A[2] = $signed(m_rd_write_val_A) < 0;
   assign nzp_towrite_A[1] = $signed(m_rd_write_val_A) == 0;
   assign nzp_towrite_A[0] = $signed(m_rd_write_val_A) > 0;
   assign nzp_towrite_B[2] = $signed(m_rd_write_val_B) < 0;
   assign nzp_towrite_B[1] = $signed(m_rd_write_val_B) == 0;
   assign nzp_towrite_B[0] = $signed(m_rd_write_val_B) > 0;

   wire[15:0] m_rd_write_val_A;
   assign m_rd_write_val_A = m_decodevals_A[13] ? m_pc_plus_one_A : (m_decodevals_A[14] ? i_cur_dmem_data : m_aluout_A);
   wire[15:0] m_rd_write_val_B;
   assign m_rd_write_val_B = m_decodevals_B[13] ? m_pc_plus_one_B : (m_decodevals_B[14] ? i_cur_dmem_data : m_aluout_B);

   assign test_nzp_new_bits_A  = m_nzp_out_A;
   assign test_nzp_new_bits_B  = m_nzp_out_B;

   wire [15:0] w_pc_A;
   wire [15:0] w_insn_A;
   wire [17:0] w_decodevals_A;
   wire [15:0] w_rd_write_val_A;
   wire [2:0] w_nzp_out_A;
   wire [15:0] w_pc_B;
   wire [15:0] w_insn_B;
   wire [17:0] w_decodevals_B;
   wire [15:0] w_rd_write_val_B;
   wire [2:0] w_nzp_out_B;
   wire [15:0] w_dmem_data;
   wire [15:0] w_dmem_to_write;
   wire [15:0] w_dmem_addr;

   Nbit_reg #(16, 16'h8200) w_pc_reg_A (.in(m_pc_A), .out(w_pc_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_insn_reg_A (.in(m_insn_A), .out(w_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 18'b0) w_decodevals_reg_A (.in(m_decodevals_A), .out(w_decodevals_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_rd_writeval_reg_A (.in(m_rd_write_val_A), .out(w_rd_write_val_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(3, 3'b0) w_nzp_out_reg_A (.in(m_nzp_out_A), .out(w_nzp_out_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'h8200) w_pc_reg_B (.in(m_pc_B), .out(w_pc_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_insn_reg_B (.in(m_insn_B), .out(w_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 18'b0) w_decodevals_reg_B (.in(m_decodevals_B), .out(w_decodevals_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_rd_writeval_reg_B (.in(m_rd_write_val_B), .out(w_rd_write_val_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(3, 3'b0) w_nzp_out_reg_B (.in(m_nzp_out_B), .out(w_nzp_out_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_dmem_data_reg (.in(i_cur_dmem_data), .out(w_dmem_data), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_dmem_to_write_reg (.in(o_dmem_towrite), .out(w_dmem_to_write), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_dmem_addr_reg (.in(o_dmem_addr), .out(w_dmem_addr), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   //code for write here (done above with reg file)
   
   assign o_cur_pc = pc;
   assign test_stall_A = (w_insn_A == 16'b0) ? 2'b10 : (w_insn_A == 16'b1 ? 2'b11 : 2'b00);
   assign test_cur_pc_A = w_pc_A;
   assign test_cur_insn_A = w_insn_A;
   assign test_regfile_we_A = w_decodevals_A[11];
   assign test_regfile_wsel_A = w_decodevals_A[10:8];
   assign test_regfile_data_A = w_rd_write_val_A;
   assign test_nzp_we_A = w_decodevals_A[12];

   assign test_stall_B = (w_insn_B == 16'b0) ? 2'b10 : (w_insn_B == 16'b1 ? 2'b11 : (w_insn_B == 16'h2 ? 2'b01 : 2'b00));
   assign test_cur_pc_B = w_pc_B;
   assign test_cur_insn_B = w_insn_B;
   assign test_regfile_we_B = w_decodevals_B[11];
   assign test_regfile_wsel_B = w_decodevals_B[10:8];
   assign test_regfile_data_B = w_rd_write_val_B;
   assign test_nzp_we_B = w_decodevals_B[12];

   assign test_dmem_we_A = w_decodevals_A[15];
   assign test_dmem_addr_A = (w_decodevals_A[14] | w_decodevals_A[15]) ? w_dmem_addr : 16'b0;
   assign test_dmem_data_A = w_decodevals_A[14] ? w_dmem_data : (w_decodevals_A[15] ? w_dmem_to_write : 16'b0);

   assign test_dmem_we_B = w_decodevals_B[15];
   assign test_dmem_addr_B = (w_decodevals_B[14] | w_decodevals_B[15]) ? w_dmem_addr : 16'b0;
   assign test_dmem_data_B = w_decodevals_B[14] ? w_dmem_data : (w_decodevals_B[15] ? w_dmem_to_write : 16'b0);




   /* Add $display(...) calls in the always block below to
    * print out debug information at the end of every cycle.
    *
    * You may also use if statements inside the always block
    * to conditionally print out information.
    */
   always @(posedge gwe) begin
      //$display("%d %h %h", $time, w_insn_A, w_insn_B);
      // if (o_dmem_we)
      //   $display("%d STORE %h <= %h", $time, o_dmem_addr, o_dmem_towrite);

      // Start each $display() format string with a %d argument for time
      // it will make the output easier to read.  Use %b, %h, and %d
      // for binary, hex, and decimal output of additional variables.
      // You do not need to add a \n at the end of your format string.
      // $display("%d ...", $time);

      // Try adding a $display() call that prints out the PCs of
      // each pipeline stage in hex.  Then you can easily look up the
      // instructions in the .asm files in test_data.

      // basic if syntax:
      // if (cond) begin
      //    ...;
      //    ...;
      // end

      // Set a breakpoint on the empty $display() below
      // to step through your pipeline cycle-by-cycle.
      // You'll need to rewind the simulation to start
      // stepping from the beginning.

      // You can also simulate for XXX ns, then set the
      // breakpoint to start stepping midway through the
      // testbench.  Use the $time printouts you added above (!)
      // to figure out when your problem instruction first
      // enters the fetch stage.  Rewind your simulation,
      // run it for that many nanoseconds, then set
      // the breakpoint.

      // In the objects view, you can change the values to
      // hexadecimal by selecting all signals (Ctrl-A),
      // then right-click, and select Radix->Hexadecimal.

      // To see the values of wires within a module, select
      // the module in the hierarchy in the "Scopes" pane.
      // The Objects pane will update to display the wires
      // in that module.

      //$display();
   end
endmodule
