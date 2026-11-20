`ifndef PWM_SCOREBOARD_SV
`define PWM_SCOREBOARD_SV

class pwm_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp #(pwm_item, pwm_scoreboard) analysis_imp;
  int unsigned txn_count;

  `uvm_component_utils(pwm_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    txn_count = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_imp = new("analysis_imp", this);
  endfunction

  function void write(pwm_item txn);
    txn_count++;
    `uvm_info("SCB", $sformatf("Txn #%0d: %s", txn_count, txn.convert2string()), UVM_MEDIUM)
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SCB", $sformatf("Total transactions checked: %0d", txn_count), UVM_LOW)
  endfunction
endclass

`endif
