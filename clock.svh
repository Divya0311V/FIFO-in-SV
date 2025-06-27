//clock generation
class clock_gen;
  virtual fifo_if intf;
  function new(virtual fifo_if intf);
    this.intf = intf;
  endfunction

  task clk_task;
    forever begin
      #5 intf.clk = ~intf.clk;
    end
  endtask
endclass
