`ifndef I2C_TEST_SV
`define I2C_TEST_SV

class i2c_base_test extends uvm_test;
  i2c_env env;

  `uvm_component_utils(i2c_base_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = i2c_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    i2c_base_seq seq;
    phase.raise_objection(this);
    seq = i2c_base_seq::type_id::create("seq");
    seq.start(env.agt.seqr);
    #100;
    phase.drop_objection(this);
  endtask
endclass

`endif
