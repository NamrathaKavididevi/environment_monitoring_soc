`ifndef SPI_ENV_SV
`define SPI_ENV_SV

class spi_env extends uvm_env;
  spi_agent      agt;
  spi_scoreboard sb;
  spi_coverage   cov;

  `uvm_component_utils(spi_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = spi_agent::type_id::create("agt", this);
    sb  = spi_scoreboard::type_id::create("sb", this);
    cov = spi_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.ap.connect(sb.analysis_imp);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass

`endif
