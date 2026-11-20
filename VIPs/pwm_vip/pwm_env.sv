`ifndef PWM_ENV_SV
`define PWM_ENV_SV

class pwm_env extends uvm_env;
  pwm_agent      agt;
  pwm_scoreboard sb;
  pwm_coverage   cov;

  `uvm_component_utils(pwm_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = pwm_agent::type_id::create("agt", this);
    sb  = pwm_scoreboard::type_id::create("sb", this);
    cov = pwm_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.ap.connect(sb.analysis_imp);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass

`endif
