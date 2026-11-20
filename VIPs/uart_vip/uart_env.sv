`ifndef UART_ENV_SV
`define UART_ENV_SV

class uart_env extends uvm_env;
  uart_agent      agt;
  uart_scoreboard sb;
  uart_coverage   cov;

  `uvm_component_utils(uart_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = uart_agent::type_id::create("agt", this);
    sb  = uart_scoreboard::type_id::create("sb", this);
    cov = uart_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.ap.connect(sb.analysis_imp);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass

`endif
