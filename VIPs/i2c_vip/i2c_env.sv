`ifndef I2C_ENV_SV
`define I2C_ENV_SV

class i2c_env extends uvm_env;
  i2c_agent      agt;
  i2c_scoreboard sb;
  i2c_coverage   cov;

  `uvm_component_utils(i2c_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = i2c_agent::type_id::create("agt", this);
    sb  = i2c_scoreboard::type_id::create("sb", this);
    cov = i2c_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.ap.connect(sb.analysis_imp);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass

`endif
