//simulation block
class simulus;
  virtual fifo_if intf;
  int DEPTH;
  int error_count = 0;

  function new(virtual fifo_if intf, int DEPTH);
    this.intf = intf;
    this.DEPTH = DEPTH;
  endfunction
  
  //1. basic_write_read
  task basic_write_read_test;
    $display("Running basic write/read test");
    for (int i = 0; i < DEPTH; i++) begin
      intf.write_en = 1;
      intf.read_en = 0;
      intf.data_in = i;
      #10;
      $display("WRITE- Time: %0t ns, Data: %0d", $time, i);
    end

    intf.write_en = 0;
    for (int i = 0; i < DEPTH; i++) begin
      intf.read_en = 1;
      #10;
      $display("READ Time: %0t ns, Data: %0d", $time, intf.data_out);
      if (intf.data_out != i) begin
        $display("Mismatch: Expected %0d, Got %0d", i, intf.data_out);
        error_count++;
      end
    end
    intf.read_en = 0;
  endtask
  
  //2.overflow
  task overflow_test;
    $display("Running overflow test");
    for (int i = 0; i < DEPTH; i++) begin
      intf.write_en = 1;
      intf.data_in = i;
      #10;
      $display("WRITE- Time: %0t ns, Data: %0d", $time, i);
    end
    intf.write_en = 1;
    intf.data_in = 999;
    #10;
    $display("WRITE -Time: %0t ns, Data: %0d (attempt overflow)", $time, intf.data_in);
    intf.write_en = 0;
    #1;

    if (!intf.overflow) begin
      $display("ERROR: Overflow not triggered");
      error_count++;
    end else begin
      $display("Overflow correctly triggered");
    end
  endtask
  
  //3.underflow
  task underflow_test;
    $display("Running underflow test");
    intf.read_en = 1;
    #10;
    $display("READ - Time: %0t ns, Underflow status: %b", $time, intf.underflow);
    intf.read_en = 0;
    #1;

    if (!intf.underflow) begin
      $display("ERROR: Underflow not triggered");
      error_count++;
    end else begin
      $display("Underflow correctly triggered");
    end
  endtask

  //4.simultaneous_read_write_empty
  task simultaneous_read_write_empty_test;
    $display("Running simultaneous read/write on empty test");
    intf.write_en = 1;
    intf.read_en = 1;
    intf.data_in = 99;
    #10;
    $display("SIMULTANEOUS_EMPTY-Time: %0t ns, Written: %0d, Read: %0d", $time, intf.data_in, intf.data_out);
    intf.write_en = 0;
    intf.read_en = 0;
  endtask

  //5.simultaneous_read_write_full
  task simultaneous_read_write_full_test;
    $display("Running simultaneous read/write on full test");
    for (int i = 0; i < DEPTH; i++) begin
      intf.write_en = 1;
      intf.data_in = i + 100;
      #10;
      $display("WRITE_FULL - Time: %0t ns, Data: %0d", $time, intf.data_in);
    end

    for (int i = 0; i < DEPTH; i++) begin
      intf.write_en = 1;
      intf.read_en = 1;
      intf.data_in = i + 200;
      #10;
      $display("SIMULTANEOUSFULL Time: %0t ns, Written: %0d, Read: %0d", $time, intf.data_in, intf.data_out);
    end
    intf.write_en = 0;
    intf.read_en = 0;
  endtask
endclass
