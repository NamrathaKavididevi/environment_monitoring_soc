`ifndef TIMER_COVERAGE_SV
`define TIMER_COVERAGE_SV

class timer_coverage extends uvm_subscriber #(timer_item);
  timer_item txn;

  covergroup timer_cg;
    cp_s_axi_awaddr: coverpoint txn.s_axi_awaddr;
    cp_s_axi_awvalid: coverpoint txn.s_axi_awvalid;
    cp_s_axi_awready: coverpoint txn.s_axi_awready;
    cp_s_axi_wdata: coverpoint txn.s_axi_wdata;
    cp_s_axi_wstrb: coverpoint txn.s_axi_wstrb;
    cp_s_axi_wvalid: coverpoint txn.s_axi_wvalid;
    cp_s_axi_wready: coverpoint txn.s_axi_wready;
    cp_s_axi_bresp: coverpoint txn.s_axi_bresp;
    cp_s_axi_bvalid: coverpoint txn.s_axi_bvalid;
    cp_s_axi_bready: coverpoint txn.s_axi_bready;
    cp_s_axi_araddr: coverpoint txn.s_axi_araddr;
    cp_s_axi_arvalid: coverpoint txn.s_axi_arvalid;
    cp_s_axi_arready: coverpoint txn.s_axi_arready;
    cp_s_axi_rdata: coverpoint txn.s_axi_rdata;
    cp_s_axi_rresp: coverpoint txn.s_axi_rresp;
    cp_s_axi_rvalid: coverpoint txn.s_axi_rvalid;
    cp_s_axi_rready: coverpoint txn.s_axi_rready;
    cp_sample_tick: coverpoint txn.sample_tick;
    cp_irq_timer: coverpoint txn.irq_timer;
  endgroup

  `uvm_component_utils(timer_coverage)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    timer_cg = new();
  endfunction

  function void write(timer_item t);
    txn = t;
    timer_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("Coverage = %.1f%%", timer_cg.get_coverage()), UVM_LOW)
  endfunction
endclass

`endif
