`ifndef GPIO_COVERAGE_SV
`define GPIO_COVERAGE_SV

class gpio_coverage extends uvm_subscriber #(gpio_item);
  gpio_item txn;

  covergroup gpio_cg;
    cp_gpio_in: coverpoint txn.gpio_in;
    cp_gpio_out: coverpoint txn.gpio_out;
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
    cp_irq_gpio: coverpoint txn.irq_gpio;
  endgroup

  `uvm_component_utils(gpio_coverage)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    gpio_cg = new();
  endfunction

  function void write(gpio_item t);
    txn = t;
    gpio_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("Coverage = %.1f%%", gpio_cg.get_coverage()), UVM_LOW)
  endfunction
endclass

`endif
