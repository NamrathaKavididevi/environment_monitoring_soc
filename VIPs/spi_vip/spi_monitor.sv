`ifndef SPI_MONITOR_SV
`define SPI_MONITOR_SV

class spi_monitor extends uvm_monitor;
  virtual spi_if.MON vif;
  uvm_analysis_port #(spi_item) ap;

  `uvm_component_utils(spi_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual spi_if.MON)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"Cannot get virtual interface for ", get_full_name()})
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.rst_n);
    forever begin
      spi_item txn;
      @(vif.mon_cb);
      txn = spi_item::type_id::create("txn");
      txn.spi_sclk = vif.mon_cb.spi_sclk;
      txn.spi_mosi = vif.mon_cb.spi_mosi;
      txn.spi_miso = vif.mon_cb.spi_miso;
      txn.spi_cs_n = vif.mon_cb.spi_cs_n;
      txn.s_axi_awaddr = vif.mon_cb.s_axi_awaddr;
      txn.s_axi_awvalid = vif.mon_cb.s_axi_awvalid;
      txn.s_axi_awready = vif.mon_cb.s_axi_awready;
      txn.s_axi_wdata = vif.mon_cb.s_axi_wdata;
      txn.s_axi_wstrb = vif.mon_cb.s_axi_wstrb;
      txn.s_axi_wvalid = vif.mon_cb.s_axi_wvalid;
      txn.s_axi_wready = vif.mon_cb.s_axi_wready;
      txn.s_axi_bresp = vif.mon_cb.s_axi_bresp;
      txn.s_axi_bvalid = vif.mon_cb.s_axi_bvalid;
      txn.s_axi_bready = vif.mon_cb.s_axi_bready;
      txn.s_axi_araddr = vif.mon_cb.s_axi_araddr;
      txn.s_axi_arvalid = vif.mon_cb.s_axi_arvalid;
      txn.s_axi_arready = vif.mon_cb.s_axi_arready;
      txn.s_axi_rdata = vif.mon_cb.s_axi_rdata;
      txn.s_axi_rresp = vif.mon_cb.s_axi_rresp;
      txn.s_axi_rvalid = vif.mon_cb.s_axi_rvalid;
      txn.s_axi_rready = vif.mon_cb.s_axi_rready;
      txn.irq_spi = vif.mon_cb.irq_spi;
      ap.write(txn);
      `uvm_info("MON", {"Sampled: ", txn.convert2string()}, UVM_HIGH)
    end
  endtask
endclass

`endif
