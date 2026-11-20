`ifndef TIMER_SEQUENCER_SV
`define TIMER_SEQUENCER_SV

class timer_sequencer extends uvm_sequencer #(timer_item);
  `uvm_component_utils(timer_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

`endif
