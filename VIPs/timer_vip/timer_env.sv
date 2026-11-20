`ifndef TIMER_ENV_SV
`define TIMER_ENV_SV

class timer_env extends uvm_env;
  timer_agent      agt;
  timer_scoreboard sb;
  timer_coverage   cov;

  `uvm_component_utils(timer_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = timer_agent::type_id::create("agt", this);
    sb  = timer_scoreboard::type_id::create("sb", this);
    cov = timer_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.ap.connect(sb.analysis_imp);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass

`endif
