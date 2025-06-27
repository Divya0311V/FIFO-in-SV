//signals
interface fifo_if;
  logic clk;
  logic reset_n;
  logic write_en;
  logic read_en;
  logic [15:0] data_in;
  logic [15:0] data_out;
  logic full;
  logic empty;
  logic almost_full;
  logic almost_empty;
  logic overflow;
  logic underflow;
endinterface
