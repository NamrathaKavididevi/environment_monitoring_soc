`ifndef UART_SEQUENCE_SV
`define UART_SEQUENCE_SV

class uart_base_seq extends uvm_sequence #(uart_item);
  `uvm_object_utils(uart_base_seq)

  int unsigned num_txns = 10;

  function new(string name = "uart_base_seq");
    super.new(name);
  endfunction

  task body();
    uart_item req;
    repeat (num_txns) begin
      req = uart_item::type_id::create("req");
      start_item(req);
      if (!req.randomize())
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

`endif
