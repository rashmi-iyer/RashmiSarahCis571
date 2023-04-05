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

   wire [15:0] pc;
   wire [15:0] next_pc;
   assign next_pc = take_branch ? x_aluout : (load_to_use_stall ? pc : pc_plus_one);

   Nbit_reg #(16, 16'h8200) f_pc_reg (.in(next_pc), .out(pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   // code to fetch here
   wire [15:0] d_pc;
   wire [15:0] d_insn;
   wire [15:0] d_pc_plus_one;
   Nbit_reg #(16, 16'h8200) d_pc_reg (.in(take_branch ? 16'b0 : pc), .out(d_pc), .clk(clk), .we(!load_to_use_stall), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) d_insn_reg (.in(take_branch ? 16'b0 : i_cur_insn), .out(d_insn), .clk(clk), .we(!load_to_use_stall), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) d_pc_plus_one_reg (.in(take_branch ? 16'b0 : pc_plus_one), .out(d_pc_plus_one), .clk(clk), .we(!load_to_use_stall), .gwe(gwe), .rst(rst));


   //code to decode here
   wire [17:0] d_decode_output;
   wire [15:0] d_r1val_output;
   wire [15:0] d_r2val_output;
   wire [15:0] x_pc;
   wire [15:0] x_insn;
   wire [17:0] x_decodevals;
   wire [15:0] x_r1val;
   wire [15:0] x_r2val;
   wire [15:0] x_pc_plus_one;
   wire load_to_use_stall = x_decodevals[14] & ((d_decode_output[3] & (d_decode_output[2:0] == x_decodevals[10:8])) | 
                           (d_decode_output[7] & d_decode_output[6:4] == x_decodevals[10:8] & !d_decode_output[15]) |
                           d_decode_output[16]);

   lc4_decoder decoder(.insn(d_insn), .r1sel(d_decode_output[2:0]), .r1re(d_decode_output[3]), .r2sel(d_decode_output[6:4]), .r2re(d_decode_output[7]), 
      .wsel(d_decode_output[10:8]), .regfile_we(d_decode_output[11]), .nzp_we(d_decode_output[12]), .select_pc_plus_one(d_decode_output[13]),
      .is_load(d_decode_output[14]), .is_store(d_decode_output[15]), .is_branch(d_decode_output[16]), .is_control_insn(d_decode_output[17]));

   //update i_rd, i_wdata, i_rd_we based on writeback
   lc4_regfile#(16) regfile (.clk(clk), .gwe(gwe), .rst(rst), .i_rs(d_decode_output[2:0]), .o_rs_data(d_r1val_output), 
      .i_rt(d_decode_output[6:4]), .o_rt_data(d_r2val_output), .i_rd(w_decodevals[10:8]), .i_wdata(w_rd_write_val), .i_rd_we(w_decodevals[11]));

   wire [15:0] d_actual_r1val;
   wire [15:0] d_actual_r2val;
   assign d_actual_r1val = (d_decode_output[3] & w_decodevals[10:8] == d_decode_output[2:0] & w_decodevals[11]) ?
                           w_rd_write_val : d_r1val_output;
   assign d_actual_r2val = (d_decode_output[7] & w_decodevals[10:8] == d_decode_output[6:4] & w_decodevals[11]) ?
                           w_rd_write_val : d_r2val_output;

   Nbit_reg #(16, 16'h8200) x_pc_reg (.in((load_to_use_stall | take_branch) ? 16'b0 : d_pc), .out(x_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_insn_reg (.in(take_branch ? 16'b0 : (load_to_use_stall ? 16'b1 : d_insn)), .out(x_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 18'b0) x_decodevals_reg (.in((take_branch | load_to_use_stall) ? 18'b0 : d_decode_output), .out(x_decodevals), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_r1val_reg (.in((take_branch | load_to_use_stall) ? 16'b0 : d_actual_r1val), .out(x_r1val), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_r2val_reg (.in((take_branch | load_to_use_stall) ? 16'b0 : d_actual_r2val), .out(x_r2val), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) x_pc_plus_one_reg (.in((take_branch | load_to_use_stall) ? 16'b0 : d_pc_plus_one), .out(x_pc_plus_one), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   //code to execute here

   wire [15:0] x_aluout;
   wire [15:0] m_pc;
   wire [15:0] m_insn;
   wire [17:0] m_decodevals;
   wire [15:0] m_r1val;
   wire [15:0] m_r2val;
   wire [15:0] m_aluout;
   wire [15:0] x_actual_r1val;
   wire [15:0] x_actual_r2val;
   wire [15:0] m_pc_plus_one;
   assign x_actual_r1val = (x_decodevals[3] & !m_decodevals[14] & m_decodevals[10:8] == x_decodevals[2:0] & m_decodevals[11]) ?
                           m_aluout : ((x_decodevals[3] & w_decodevals[10:8] == x_decodevals[2:0] & w_decodevals[11]) ?
                           w_rd_write_val : x_r1val);
   assign x_actual_r2val = (x_decodevals[7] & !m_decodevals[14] & m_decodevals[10:8] == x_decodevals[6:4] & m_decodevals[11]) ?
                           m_aluout : ((x_decodevals[7] & w_decodevals[10:8] == x_decodevals[6:4] & w_decodevals[11]) ?
                           w_rd_write_val : x_r2val);


   lc4_alu alu(.i_insn(x_insn), .i_pc(x_pc), .i_r1data(x_actual_r1val), .i_r2data(x_actual_r2val), .o_result(x_aluout));

   wire take_branch;
   assign take_branch = (x_decodevals[16] & ((x_insn[11:9] & (m_decodevals[12] ? nzp_towrite: m_nzp_out)) != 3'b0)) | x_decodevals[17];

   Nbit_reg #(16, 16'h8200) m_pc_reg (.in(x_pc), .out(m_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_insn_reg (.in(x_insn), .out(m_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 18'b0) m_decodevals_reg (.in(x_decodevals), .out(m_decodevals), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_r1val_reg (.in(x_actual_r1val), .out(m_r1val), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_r2val_reg (.in(x_actual_r2val), .out(m_r2val), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_aluout_reg (.in(x_aluout), .out(m_aluout), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) m_pc_plus_one_reg (.in(x_pc_plus_one), .out(m_pc_plus_one), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   //code to memory here 

   assign o_dmem_addr = (m_decodevals[14] | m_decodevals[15]) ? m_aluout : 16'b0;
   assign o_dmem_we = m_decodevals[15];
   assign o_dmem_towrite = (m_decodevals[15] & w_decodevals[11] & m_decodevals[6:4] == w_decodevals[10:8]) ?
                           w_rd_write_val : m_r2val;

   wire[2:0] nzp_towrite;
   wire[2:0] m_nzp_out;
   Nbit_reg #(3, 3'b0) nzp_reg (.in(nzp_towrite), .out(m_nzp_out), .clk(clk), .we(m_decodevals[12]), .gwe(gwe), .rst(rst));

   assign nzp_towrite[2] = $signed(m_rd_write_val) < 0;
   assign nzp_towrite[1] = $signed(m_rd_write_val) == 0;
   assign nzp_towrite[0] = $signed(m_rd_write_val) > 0;

   wire[15:0] m_rd_write_val;
   assign m_rd_write_val = m_decodevals[13] ? m_pc_plus_one : (m_decodevals[14] ? i_cur_dmem_data : m_aluout);

   assign test_nzp_new_bits  = m_nzp_out;

   wire [15:0] w_pc;
   wire [15:0] w_insn;
   wire [17:0] w_decodevals;
   wire [15:0] w_rd_write_val;
   wire [2:0] w_nzp_out;
   wire [15:0] w_dmem_data;
   wire [15:0] w_dmem_to_write;
   wire [15:0] w_dmem_addr;

   Nbit_reg #(16, 16'h8200) w_pc_reg (.in(m_pc), .out(w_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_insn_reg (.in(m_insn), .out(w_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 18'b0) w_decodevals_reg (.in(m_decodevals), .out(w_decodevals), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_rd_writeval_reg (.in(m_rd_write_val), .out(w_rd_write_val), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(3, 3'b0) w_nzp_out_reg (.in(m_nzp_out), .out(w_nzp_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_dmem_data_reg (.in(i_cur_dmem_data), .out(w_dmem_data), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_dmem_to_write_reg (.in(o_dmem_towrite), .out(w_dmem_to_write), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 16'b0) w_dmem_addr_reg (.in(o_dmem_addr), .out(w_dmem_addr), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   //code for write here (done above with reg file)
   
   assign o_cur_pc = pc;
   assign test_stall = (w_insn == 16'b0) ? 2'b10 : (w_insn == 16'b1 ? 2'b11 : 2'b00);
   assign test_cur_pc = w_pc;
   assign test_cur_insn = w_insn;
   assign test_regfile_we = w_decodevals[11];
   assign test_regfile_wsel = w_decodevals[10:8];
   assign test_regfile_data = w_rd_write_val;
   assign test_nzp_we = w_decodevals[12];
   assign test_dmem_we = w_decodevals[15];
   assign test_dmem_addr = w_dmem_addr;
   assign test_dmem_data = w_decodevals[14] ? w_dmem_data : (w_decodevals[15] ? w_dmem_to_write : 16'b0);




   /* Add $display(...) calls in the always block below to
    * print out debug information at the end of every cycle.
    *
    * You may also use if statements inside the always block
    * to conditionally print out information.
    */
   always @(posedge gwe) begin
      // $display("%d %h %h %h %h %h", $time, f_pc, d_pc, e_pc, m_pc, test_cur_pc);
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
