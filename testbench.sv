//Include files
`include "interface.svh"
`include "Clock_generation.svh"
`include "reset.svh"
`include "stimulus.svh"

//module declaration
module testbench;
  parameter DATA_WIDTH = 16;
  parameter DEPTH = 8;
  parameter ADDR_WIDTH = 3;

  fifo_if intf();
  
//DUT
  fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) fifo_dut (
    .clk(intf.clk),
    .reset_n(intf.reset_n),
    .write_en(intf.write_en),
    .read_en(intf.read_en),
    .data_in(intf.data_in),
    .data_out(intf.data_out),
    .full(intf.full),
    .empty(intf.empty),
    .almost_full(intf.almost_full),
    .almost_empty(intf.almost_empty),
    .overflow(intf.overflow),
    .underflow(intf.underflow)
  );
  
//initialization
  initial begin
    intf.clk = 0;
    intf.reset_n = 0;
    intf.write_en = 0;
    intf.read_en = 0;
    intf.data_in = 0;
  end
  
//assigning handle name for class
  clock_gen clk_obj;
  reset_gen rst_obj;
  stimulus stim_obj;


  initial begin
    clk_obj = new(intf);
    rst_obj = new(intf);
    stim_obj = new(intf, DEPTH);
    fork
      clk_obj.clk_task();
      rst_obj.rst_task();
      begin
        #100;
        stim_obj.basic_write_read_test();
        stim_obj.underflow_test();
        stim_obj.overflow_test();
        stim_obj.simultaneous_read_write_empty_test();
        stim_obj.simultaneous_read_write_full_test();
        $display("Test completed with %0d errors", stim_obj.error_count);
        $finish;
      end
    join
  end
  
  //dump waveform  
  initial begin
    $dumpfile("fifo_waveform.vcd");
    $dumpvars(0);
  end
endmodule
