`ifndef SPI_TB_TOP_SV
`define SPI_TB_TOP_SV

module spi_tb_top;
  import uvm_pkg::*;
  import spi_pkg::*;

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
  spi_if vif(.clk(clk), .rst_n(rst_n));

  // UVM configuration and test launch
  initial begin
    uvm_config_db#(virtual spi_if.DRV)::set(null, "*.agt.drv", "vif", vif);
    uvm_config_db#(virtual spi_if.MON)::set(null, "*.agt.mon", "vif", vif);
    run_test("spi_base_test");
  end

  // Optional waveform dump
  initial begin
    $dumpfile("spi_dump.vcd");
    $dumpvars(0, spi_tb_top);
  end
endmodule

`endif
