module fifo #(
  parameter DATA_WIDTH = 16,
  parameter DEPTH = 8,
  parameter ADDR_WIDTH = 3
)(
  input  logic clk,
  input  logic reset_n,
  input  logic write_en,
  input  logic read_en,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic full,
  output logic empty,
  output logic almost_full,
  output logic almost_empty,
  output logic overflow,
  output logic underflow
);

  logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
  logic [ADDR_WIDTH-1:0] write_ptr, read_ptr;
  logic [ADDR_WIDTH:0] count;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      write_ptr     <= 0;
      read_ptr      <= 0;
      count         <= 0;
      data_out      <= '0;
      full          <= 0;
      empty         <= 1;
      almost_full   <= 0;
      almost_empty  <= 1;
      overflow      <= 0;
      underflow     <= 0;
    end 
    else begin
      overflow <= 0;
      underflow <= 0;

      // Simultaneous write and read
      if (write_en && read_en) begin
        fifo_mem[write_ptr] <= data_in;
        data_out <= fifo_mem[read_ptr];
        write_ptr <= (write_ptr == DEPTH-1) ? 0 : write_ptr + 1;
        read_ptr  <= (read_ptr == DEPTH-1)  ? 0 : read_ptr + 1;
      end

      //Write
      else if (write_en && !read_en) begin
        if (count < DEPTH) begin
          fifo_mem[write_ptr] <= data_in;
          write_ptr <= (write_ptr == DEPTH-1) ? 0 : write_ptr + 1;
          count <= count + 1;
        end 
        //Overflow
        else begin
          overflow <= 1;
        end
      end

      //Read
      else if (!write_en && read_en) begin
        if (count > 0) begin
          data_out <= fifo_mem[read_ptr];
          read_ptr <= (read_ptr == DEPTH-1) ? 0 : read_ptr + 1;
          count <= count - 1;
        end 
        //Underflow
        else begin
          underflow <= 1;
        end
      end

      // Status flag updates
      full         <= (count == DEPTH);
      empty        <= (count == 0);
      almost_full  <= (count >= DEPTH - 1);
      almost_empty <= (count <= 1);
    end
  end
endmodule
