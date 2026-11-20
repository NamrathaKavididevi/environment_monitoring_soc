`ifndef UART_MONITOR_SV
`define UART_MONITOR_SV

class uart_monitor extends uvm_monitor;
  virtual uart_if vif;
  uvm_analysis_port #(uart_item) ap;

  `uvm_component_utils(uart_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"Cannot get virtual interface for ", get_full_name()})
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.rst_n);
    forever begin
      uart_item txn;
      @(vif.mon_cb);
      txn = uart_item::type_id::create("txn");
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
      txn.uart_rx = vif.mon_cb.uart_rx;
      txn.uart_tx = vif.mon_cb.uart_tx;
      txn.irq_uart = vif.mon_cb.irq_uart;
      ap.write(txn);
      `uvm_info("MON", {"Sampled: ", txn.convert2string()}, UVM_HIGH)
    end
  endtask
endclass

`endif
