`ifndef PWM_SEQUENCE_SV
`define PWM_SEQUENCE_SV

class pwm_base_seq extends uvm_sequence #(pwm_item);
  `uvm_object_utils(pwm_base_seq)

  int unsigned num_txns = 10;

  function new(string name = "pwm_base_seq");
    super.new(name);
  endfunction

  task body();
    pwm_item req;
    repeat (num_txns) begin
      req = pwm_item::type_id::create("req");
      start_item(req);
      if (!req.randomize())
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

`endif
