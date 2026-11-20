`ifndef GPIO_SEQUENCE_SV
`define GPIO_SEQUENCE_SV

class gpio_base_seq extends uvm_sequence #(gpio_item);
  `uvm_object_utils(gpio_base_seq)

  int unsigned num_txns = 10;

  function new(string name = "gpio_base_seq");
    super.new(name);
  endfunction

  task body();
    gpio_item req;
    repeat (num_txns) begin
      req = gpio_item::type_id::create("req");
      start_item(req);
      if (!req.randomize())
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

`endif
