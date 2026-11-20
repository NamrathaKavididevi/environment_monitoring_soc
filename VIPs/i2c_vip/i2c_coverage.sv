`ifndef I2C_COVERAGE_SV
`define I2C_COVERAGE_SV

class i2c_coverage extends uvm_subscriber #(i2c_item);
  i2c_item txn;

  covergroup i2c_cg;
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
    cp_scl_pad_i: coverpoint txn.scl_pad_i;
    cp_scl_pad_o: coverpoint txn.scl_pad_o;
    cp_scl_padoen_o: coverpoint txn.scl_padoen_o;
    cp_sda_pad_i: coverpoint txn.sda_pad_i;
    cp_sda_pad_o: coverpoint txn.sda_pad_o;
    cp_sda_padoen_o: coverpoint txn.sda_padoen_o;
    cp_irq_i2c: coverpoint txn.irq_i2c;
  endgroup

  `uvm_component_utils(i2c_coverage)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    i2c_cg = new();
  endfunction

  function void write(i2c_item t);
    txn = t;
    i2c_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("Coverage = %.1f%%", i2c_cg.get_coverage()), UVM_LOW)
  endfunction
endclass

`endif
