//reset generation
class reset_gen;
  virtual fifo_if intf;
  function new(virtual fifo_if intf);
    this.intf = intf;
  endfunction

  task rst_task;
    intf.reset_n = 0;
    #15;
    intf.reset_n = 1;
  endtask
endclass
