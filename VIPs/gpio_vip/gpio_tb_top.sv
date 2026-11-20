`ifndef GPIO_TB_TOP_SV
`define GPIO_TB_TOP_SV

module gpio_tb_top;
  import uvm_pkg::*;
  import gpio_pkg::*;

  // Clock and reset signals
  logic clk;
  logic rst_n;

  // 100 MHz clock generation
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Reset pulse
  initial begin
    rst_n = 1'b0;
    #100;
    rst_n = 1'b1;
  end

  // Interface instantiation
  gpio_if vif(.clk(clk), .rst_n(rst_n));

  // UVM configuration and test launch
  initial begin
    uvm_config_db#(virtual gpio_if.DRV)::set(null, "*.agt.drv", "vif", vif);
    uvm_config_db#(virtual gpio_if.MON)::set(null, "*.agt.mon", "vif", vif);
    run_test("gpio_base_test");
  end

  // Optional waveform dump
  initial begin
    $dumpfile("gpio_dump.vcd");
    $dumpvars(0, gpio_tb_top);
  end
endmodule

`endif
