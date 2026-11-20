`ifndef TIMER_SEQUENCE_SV
`define TIMER_SEQUENCE_SV

class timer_base_seq extends uvm_sequence #(timer_item);
  `uvm_object_utils(timer_base_seq)

  int unsigned num_txns = 10;

  function new(string name = "timer_base_seq");
    super.new(name);
  endfunction

  task body();
    timer_item req;
    repeat (num_txns) begin
      req = timer_item::type_id::create("req");
      start_item(req);
      if (!req.randomize())
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

`endif
