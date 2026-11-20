`ifndef I2C_SEQUENCE_SV
`define I2C_SEQUENCE_SV

class i2c_base_seq extends uvm_sequence #(i2c_item);
  `uvm_object_utils(i2c_base_seq)

  int unsigned num_txns = 10;

  function new(string name = "i2c_base_seq");
    super.new(name);
  endfunction

  task body();
    i2c_item req;
    repeat (num_txns) begin
      req = i2c_item::type_id::create("req");
      start_item(req);
      if (!req.randomize())
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

`endif
