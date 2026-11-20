`ifndef PWM_DRIVER_SV
`define PWM_DRIVER_SV

class pwm_driver extends uvm_driver #(pwm_item);
  virtual pwm_if.DRV vif;

  `uvm_component_utils(pwm_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual pwm_if.DRV)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"Cannot get virtual interface for ", get_full_name()})
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.rst_n);
    forever begin
      seq_item_port.get_next_item(req);
      drive_item(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_item(pwm_item req);
    @(vif.drv_cb);
      vif.drv_cb.s_axi_awaddr <= req.s_axi_awaddr;
      vif.drv_cb.s_axi_awvalid <= req.s_axi_awvalid;
      vif.drv_cb.s_axi_wdata <= req.s_axi_wdata;
      vif.drv_cb.s_axi_wstrb <= req.s_axi_wstrb;
      vif.drv_cb.s_axi_wvalid <= req.s_axi_wvalid;
      vif.drv_cb.s_axi_bready <= req.s_axi_bready;
      vif.drv_cb.s_axi_araddr <= req.s_axi_araddr;
      vif.drv_cb.s_axi_arvalid <= req.s_axi_arvalid;
      vif.drv_cb.s_axi_rready <= req.s_axi_rready;
    `uvm_info("DRV", {"Drove: ", req.convert2string()}, UVM_HIGH)
  endtask
endclass

`endif
