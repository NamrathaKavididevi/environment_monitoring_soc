`ifndef UART_ITEM_SV
`define UART_ITEM_SV

class uart_item extends uvm_sequence_item;

  rand bit [31:0] s_axi_awaddr;
  rand bit        s_axi_awvalid;
       bit        s_axi_awready;
  rand bit [31:0] s_axi_wdata;
  rand bit [3:0] s_axi_wstrb;
  rand bit        s_axi_wvalid;
       bit        s_axi_wready;
       bit [1:0] s_axi_bresp;
       bit        s_axi_bvalid;
  rand bit        s_axi_bready;
  rand bit [31:0] s_axi_araddr;
  rand bit        s_axi_arvalid;
       bit        s_axi_arready;
       bit [31:0] s_axi_rdata;
       bit [1:0] s_axi_rresp;
       bit        s_axi_rvalid;
  rand bit        s_axi_rready;
  rand bit        uart_rx;
       bit        uart_tx;
       bit        irq_uart;

  `uvm_object_utils_begin(uart_item)
    `uvm_field_int(s_axi_awaddr, UVM_ALL_ON)
    `uvm_field_int(s_axi_awvalid, UVM_ALL_ON)
    `uvm_field_int(s_axi_awready, UVM_ALL_ON)
    `uvm_field_int(s_axi_wdata, UVM_ALL_ON)
    `uvm_field_int(s_axi_wstrb, UVM_ALL_ON)
    `uvm_field_int(s_axi_wvalid, UVM_ALL_ON)
    `uvm_field_int(s_axi_wready, UVM_ALL_ON)
    `uvm_field_int(s_axi_bresp, UVM_ALL_ON)
    `uvm_field_int(s_axi_bvalid, UVM_ALL_ON)
    `uvm_field_int(s_axi_bready, UVM_ALL_ON)
    `uvm_field_int(s_axi_araddr, UVM_ALL_ON)
    `uvm_field_int(s_axi_arvalid, UVM_ALL_ON)
    `uvm_field_int(s_axi_arready, UVM_ALL_ON)
    `uvm_field_int(s_axi_rdata, UVM_ALL_ON)
    `uvm_field_int(s_axi_rresp, UVM_ALL_ON)
    `uvm_field_int(s_axi_rvalid, UVM_ALL_ON)
    `uvm_field_int(s_axi_rready, UVM_ALL_ON)
    `uvm_field_int(uart_rx, UVM_ALL_ON)
    `uvm_field_int(uart_tx, UVM_ALL_ON)
    `uvm_field_int(irq_uart, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "uart_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("s_axi_awaddr=0x%0h, s_axi_awvalid=0x%0h, s_axi_awready=0x%0h, s_axi_wdata=0x%0h, s_axi_wstrb=0x%0h, s_axi_wvalid=0x%0h, s_axi_wready=0x%0h, s_axi_bresp=0x%0h, s_axi_bvalid=0x%0h, s_axi_bready=0x%0h, s_axi_araddr=0x%0h, s_axi_arvalid=0x%0h, s_axi_arready=0x%0h, s_axi_rdata=0x%0h, s_axi_rresp=0x%0h, s_axi_rvalid=0x%0h, s_axi_rready=0x%0h, uart_rx=0x%0h, uart_tx=0x%0h, irq_uart=0x%0h", s_axi_awaddr, s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb, s_axi_wvalid, s_axi_wready, s_axi_bresp, s_axi_bvalid, s_axi_bready, s_axi_araddr, s_axi_arvalid, s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid, s_axi_rready, uart_rx, uart_tx, irq_uart);
  endfunction
endclass

`endif
