`ifndef UART_IF_SV
`define UART_IF_SV

interface uart_if(input logic clk, input logic rst_n);
  logic [31:0] s_axi_awaddr;
  logic s_axi_awvalid;
  logic s_axi_awready;
  logic [31:0] s_axi_wdata;
  logic [3:0] s_axi_wstrb;
  logic s_axi_wvalid;
  logic s_axi_wready;
  logic [1:0] s_axi_bresp;
  logic s_axi_bvalid;
  logic s_axi_bready;
  logic [31:0] s_axi_araddr;
  logic s_axi_arvalid;
  logic s_axi_arready;
  logic [31:0] s_axi_rdata;
  logic [1:0] s_axi_rresp;
  logic s_axi_rvalid;
  logic s_axi_rready;
  logic uart_rx;
  logic uart_tx;
  logic irq_uart;

  clocking drv_cb @(posedge clk);
    default input #1 output #1;
    output s_axi_awaddr;
    output s_axi_awvalid;
    input  s_axi_awready;
    output s_axi_wdata;
    output s_axi_wstrb;
    output s_axi_wvalid;
    input  s_axi_wready;
    input  s_axi_bresp;
    input  s_axi_bvalid;
    output s_axi_bready;
    output s_axi_araddr;
    output s_axi_arvalid;
    input  s_axi_arready;
    input  s_axi_rdata;
    input  s_axi_rresp;
    input  s_axi_rvalid;
    output s_axi_rready;
    output uart_rx;
    input  uart_tx;
    input  irq_uart;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1;
    input s_axi_awaddr;
    input s_axi_awvalid;
    input s_axi_awready;
    input s_axi_wdata;
    input s_axi_wstrb;
    input s_axi_wvalid;
    input s_axi_wready;
    input s_axi_bresp;
    input s_axi_bvalid;
    input s_axi_bready;
    input s_axi_araddr;
    input s_axi_arvalid;
    input s_axi_arready;
    input s_axi_rdata;
    input s_axi_rresp;
    input s_axi_rvalid;
    input s_axi_rready;
    input uart_rx;
    input uart_tx;
    input irq_uart;
  endclocking

  modport DRV (clocking drv_cb, input clk, input rst_n);
  modport MON (clocking mon_cb, input clk, input rst_n);

endinterface

`endif
