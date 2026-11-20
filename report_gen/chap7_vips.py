# -*- coding: utf-8 -*-
"""
Chapter 7: All VIPs CSV Files and Interface Files (Pages 30 to 39)
Candidate: Namratha Kavididevi (Roll No: 1602-23-735-157)
"""

from common import make_page, format_listing

def get_chap7_pages():
    pages = []

    lst7_1 = format_listing([
        '`ifndef UART_IF_SV',
        '`define UART_IF_SV',
        'interface uart_if(input logic clk, input logic rst_n);',
        '  logic [31:0] s_axi_awaddr;   logic s_axi_awvalid;   logic s_axi_awready;',
        '  logic [31:0] s_axi_wdata;    logic [3:0] s_axi_wstrb;',
        '  logic        s_axi_wvalid;   logic s_axi_wready;',
        '  logic [1:0]  s_axi_bresp;    logic s_axi_bvalid;    logic s_axi_bready;',
        '  logic [31:0] s_axi_araddr;   logic s_axi_arvalid;   logic s_axi_arready;',
        '  logic [31:0] s_axi_rdata;    logic [1:0] s_axi_rresp;',
        '  logic        s_axi_rvalid;   logic s_axi_rready;',
        '  logic        uart_rx;        logic uart_tx;         logic irq_uart;',
        '',
        '  clocking drv_cb @(posedge clk);',
        '    default input #1 output #1;',
        '    output s_axi_awaddr, s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wvalid;',
        '    input  s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid;',
        '    output s_axi_bready, s_axi_araddr, s_axi_arvalid, s_axi_rready, uart_rx;',
        '    input  s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid, uart_tx, irq_uart;',
        '  endclocking',
        '',
        '  clocking mon_cb @(posedge clk);',
        '    default input #1;',
        '    input s_axi_awaddr, s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb;',
        '    input s_axi_wvalid, s_axi_wready, s_axi_bresp, s_axi_bvalid, s_axi_bready;',
        '    input s_axi_araddr, s_axi_arvalid, s_axi_arready, s_axi_rdata, s_axi_rresp;',
        '    input s_axi_rvalid, s_axi_rready, uart_rx, uart_tx, irq_uart;',
        '  endclocking',
        '',
        '  modport driver  (clocking drv_cb, input clk, rst_n);',
        '  modport monitor (clocking mon_cb, input clk, rst_n);',
        'endinterface',
        '`endif'
    ], 1)

    lst7_2 = format_listing([
        '`ifndef GPIO_IF_SV',
        '`define GPIO_IF_SV',
        'interface gpio_if(input logic clk, input logic rst_n);',
        '  logic [31:0] s_axi_awaddr;   logic s_axi_awvalid;   logic s_axi_awready;',
        '  logic [31:0] s_axi_wdata;    logic [3:0] s_axi_wstrb;',
        '  logic        s_axi_wvalid;   logic s_axi_wready;',
        '  logic [1:0]  s_axi_bresp;    logic s_axi_bvalid;    logic s_axi_bready;',
        '  logic [31:0] s_axi_araddr;   logic s_axi_arvalid;   logic s_axi_arready;',
        '  logic [31:0] s_axi_rdata;    logic [1:0] s_axi_rresp;',
        '  logic        s_axi_rvalid;   logic s_axi_rready;',
        '  logic [31:0] gpio_in;        logic [31:0] gpio_out; logic [31:0] gpio_dir;',
        '  logic        irq_gpio;',
        '',
        '  clocking drv_cb @(posedge clk);',
        '    default input #1 output #1;',
        '    output s_axi_awaddr, s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wvalid;',
        '    input  s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid;',
        '    output s_axi_bready, s_axi_araddr, s_axi_arvalid, s_axi_rready, gpio_in;',
        '    input  s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid, gpio_out, gpio_dir, irq_gpio;',
        '  endclocking',
        '',
        '  clocking mon_cb @(posedge clk);',
        '    default input #1;',
        '    input s_axi_awaddr, s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb;',
        '    input s_axi_wvalid, s_axi_wready, s_axi_bresp, s_axi_bvalid, s_axi_bready;',
        '    input s_axi_araddr, s_axi_arvalid, s_axi_arready, s_axi_rdata, s_axi_rresp;',
        '    input s_axi_rvalid, s_axi_rready, gpio_in, gpio_out, gpio_dir, irq_gpio;',
        '  endclocking',
        '',
        '  modport driver  (clocking drv_cb, input clk, rst_n);',
        '  modport monitor (clocking mon_cb, input clk, rst_n);',
        'endinterface',
        '`endif'
    ], 1)

    lst7_3 = format_listing([
        '`ifndef TIMER_IF_SV',
        '`define TIMER_IF_SV',
        'interface timer_if(input logic clk, input logic rst_n);',
        '  logic [31:0] s_axi_awaddr;   logic s_axi_awvalid;   logic s_axi_awready;',
        '  logic [31:0] s_axi_wdata;    logic [3:0] s_axi_wstrb;',
        '  logic        s_axi_wvalid;   logic s_axi_wready;',
        '  logic [1:0]  s_axi_bresp;    logic s_axi_bvalid;    logic s_axi_bready;',
        '  logic [31:0] s_axi_araddr;   logic s_axi_arvalid;   logic s_axi_arready;',
        '  logic [31:0] s_axi_rdata;    logic [1:0] s_axi_rresp;',
        '  logic        s_axi_rvalid;   logic s_axi_rready;',
        '  logic        sample_tick;    logic irq_timer;',
        '',
        '  clocking drv_cb @(posedge clk);',
        '    default input #1 output #1;',
        '    output s_axi_awaddr, s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wvalid;',
        '    input  s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid;',
        '    output s_axi_bready, s_axi_araddr, s_axi_arvalid, s_axi_rready;',
        '    input  s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid, sample_tick, irq_timer;',
        '  endclocking',
        '',
        '  clocking mon_cb @(posedge clk);',
        '    default input #1;',
        '    input s_axi_awaddr, s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb;',
        '    input s_axi_wvalid, s_axi_wready, s_axi_bresp, s_axi_bvalid, s_axi_bready;',
        '    input s_axi_araddr, s_axi_arvalid, s_axi_arready, s_axi_rdata, s_axi_rresp;',
        '    input s_axi_rvalid, s_axi_rready, sample_tick, irq_timer;',
        '  endclocking',
        '',
        '  modport driver  (clocking drv_cb, input clk, rst_n);',
        '  modport monitor (clocking mon_cb, input clk, rst_n);',
        'endinterface',
        '`endif'
    ], 1)

    lst7_4 = format_listing([
        '`ifndef SPI_IF_SV',
        '`define SPI_IF_SV',
        'interface spi_if(input logic clk, input logic rst_n);',
        '  logic [31:0] s_axi_awaddr;   logic s_axi_awvalid;   logic s_axi_awready;',
        '  logic [31:0] s_axi_wdata;    logic [3:0] s_axi_wstrb;',
        '  logic        s_axi_wvalid;   logic s_axi_wready;',
        '  logic [1:0]  s_axi_bresp;    logic s_axi_bvalid;    logic s_axi_bready;',
        '  logic [31:0] s_axi_araddr;   logic s_axi_arvalid;   logic s_axi_arready;',
        '  logic [31:0] s_axi_rdata;    logic [1:0] s_axi_rresp;',
        '  logic        s_axi_rvalid;   logic s_axi_rready;',
        '  logic        spi_sclk;       logic spi_mosi;        logic spi_miso; logic spi_cs_n;',
        '  logic        irq_spi;',
        '',
        '  clocking drv_cb @(posedge clk);',
        '    default input #1 output #1;',
        '    output s_axi_awaddr, s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wvalid;',
        '    input  s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid;',
        '    output s_axi_bready, s_axi_araddr, s_axi_arvalid, s_axi_rready, spi_miso;',
        '    input  s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid, spi_sclk, spi_mosi, spi_cs_n, irq_spi;',
        '  endclocking',
        '',
        '  clocking mon_cb @(posedge clk);',
        '    default input #1;',
        '    input s_axi_awaddr, s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb;',
        '    input s_axi_wvalid, s_axi_wready, s_axi_bresp, s_axi_bvalid, s_axi_bready;',
        '    input s_axi_araddr, s_axi_arvalid, s_axi_arready, s_axi_rdata, s_axi_rresp;',
        '    input s_axi_rvalid, s_axi_rready, spi_sclk, spi_mosi, spi_miso, spi_cs_n, irq_spi;',
        '  endclocking',
        '',
        '  modport driver  (clocking drv_cb, input clk, rst_n);',
        '  modport monitor (clocking mon_cb, input clk, rst_n);',
        'endinterface',
        '`endif'
    ], 1)

    lst7_5 = format_listing([
        '`ifndef I2C_IF_SV',
        '`define I2C_IF_SV',
        'interface i2c_if(input logic clk, input logic rst_n);',
        '  logic [31:0] s_axi_awaddr;   logic s_axi_awvalid;   logic s_axi_awready;',
        '  logic [31:0] s_axi_wdata;    logic [3:0] s_axi_wstrb;',
        '  logic        s_axi_wvalid;   logic s_axi_wready;',
        '  logic [1:0]  s_axi_bresp;    logic s_axi_bvalid;    logic s_axi_bready;',
        '  logic [31:0] s_axi_araddr;   logic s_axi_arvalid;   logic s_axi_arready;',
        '  logic [31:0] s_axi_rdata;    logic [1:0] s_axi_rresp;',
        '  logic        s_axi_rvalid;   logic s_axi_rready;',
        '  logic        i2c_scl;        logic i2c_sda_out;     logic i2c_sda_in; logic irq_i2c;',
        '',
        '  clocking drv_cb @(posedge clk);',
        '    default input #1 output #1;',
        '    output s_axi_awaddr, s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wvalid;',
        '    input  s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid;',
        '    output s_axi_bready, s_axi_araddr, s_axi_arvalid, s_axi_rready, i2c_sda_in;',
        '    input  s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid, i2c_scl, i2c_sda_out, irq_i2c;',
        '  endclocking',
        '',
        '  clocking mon_cb @(posedge clk);',
        '    default input #1;',
        '    input s_axi_awaddr, s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb;',
        '    input s_axi_wvalid, s_axi_wready, s_axi_bresp, s_axi_bvalid, s_axi_bready;',
        '    input s_axi_araddr, s_axi_arvalid, s_axi_arready, s_axi_rdata, s_axi_rresp;',
        '    input s_axi_rvalid, s_axi_rready, i2c_scl, i2c_sda_out, i2c_sda_in, irq_i2c;',
        '  endclocking',
        '',
        '  modport driver  (clocking drv_cb, input clk, rst_n);',
        '  modport monitor (clocking mon_cb, input clk, rst_n);',
        'endinterface',
        '`endif'
    ], 1)

    lst7_6 = format_listing([
        '`ifndef PWM_IF_SV',
        '`define PWM_IF_SV',
        'interface pwm_if(input logic clk, input logic rst_n);',
        '  logic [31:0] s_axi_awaddr;   logic s_axi_awvalid;   logic s_axi_awready;',
        '  logic [31:0] s_axi_wdata;    logic [3:0] s_axi_wstrb;',
        '  logic        s_axi_wvalid;   logic s_axi_wready;',
        '  logic [1:0]  s_axi_bresp;    logic s_axi_bvalid;    logic s_axi_bready;',
        '  logic [31:0] s_axi_araddr;   logic s_axi_arvalid;   logic s_axi_arready;',
        '  logic [31:0] s_axi_rdata;    logic [1:0] s_axi_rresp;',
        '  logic        s_axi_rvalid;   logic s_axi_rready;',
        '  logic        pwm_pad_o;      logic irq_pwm;',
        '',
        '  clocking drv_cb @(posedge clk);',
        '    default input #1 output #1;',
        '    output s_axi_awaddr, s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wvalid;',
        '    input  s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid;',
        '    output s_axi_bready, s_axi_araddr, s_axi_arvalid, s_axi_rready;',
        '    input  s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid, pwm_pad_o, irq_pwm;',
        '  endclocking',
        '',
        '  clocking mon_cb @(posedge clk);',
        '    default input #1;',
        '    input s_axi_awaddr, s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb;',
        '    input s_axi_wvalid, s_axi_wready, s_axi_bresp, s_axi_bvalid, s_axi_bready;',
        '    input s_axi_araddr, s_axi_arvalid, s_axi_arready, s_axi_rdata, s_axi_rresp;',
        '    input s_axi_rvalid, s_axi_rready, pwm_pad_o, irq_pwm;',
        '  endclocking',
        '',
        '  modport driver  (clocking drv_cb, input clk, rst_n);',
        '  modport monitor (clocking mon_cb, input clk, rst_n);',
        'endinterface',
        '`endif'
    ], 1)

    lst7_7 = format_listing([
        '# Master VIP Filelist for Synopsys VCS / QuestaSim Compilation',
        '+incdir+./uart_vip',
        '+incdir+./gpio_vip',
        '+incdir+./timer_vip',
        '+incdir+./spi_vip',
        '+incdir+./i2c_vip',
        '+incdir+./pwm_vip',
        '',
        '# VIP Interface Syntheses',
        './uart_vip/uart_if.sv',
        './gpio_vip/gpio_if.sv',
        './timer_vip/timer_if.sv',
        './spi_vip/spi_if.sv',
        './i2c_vip/i2c_if.sv',
        './pwm_vip/pwm_if.sv',
        '',
        '# VIP Package Compilations',
        './uart_vip/uart_pkg.sv',
        './gpio_vip/gpio_pkg.sv',
        './timer_vip/timer_pkg.sv',
        './spi_vip/spi_pkg.sv',
        './i2c_vip/i2c_pkg.sv',
        './pwm_vip/pwm_pkg.sv'
    ], 1)

    lst7_8 = format_listing([
        'module top_level_tb;',
        '    logic clk, rst_n;',
        '    logic [31:1] rst_vec = 31\'h0; logic nmi_int = 1\'b0;',
        '    wire  uart_tx;  logic uart_rx = 1\'b1;',
        '    wire  sample_tick, irq_timer, irq_gpio, irq_i2c, irq_spi, irq_pwm;',
        '    logic [31:0] gpio_in = 32\'h0; wire [31:0] gpio_out, gpio_dir;',
        '    wire  scl, sda, spi_sclk, spi_mosi, spi_cs_n, pwm_pad_o; logic spi_miso = 1\'b0;',
        '',
        '    // 50 MHz Master Clock Generation',
        '    always #10 clk = ~clk;',
        '',
        '    // SoC DUT Instantiation',
        '    soc_top u_soc (',
        '        .clk(clk), .rst_n(rst_n),',
        '        .uart_rx(uart_rx), .uart_tx(uart_tx),',
        '        .gpio_in(gpio_in), .gpio_out(gpio_out), .gpio_dir(gpio_dir),',
        '        .sample_tick(sample_tick),',
        '        .spi_sclk(spi_sclk), .spi_mosi(spi_mosi), .spi_miso(spi_miso), .spi_cs_n(spi_cs_n),',
        '        .i2c_scl(scl), .i2c_sda_out(), .i2c_sda_in(sda),',
        '        .pwm_pad_o(pwm_pad_o)',
        '    );',
        'endmodule'
    ], 1)

    # Page 30
    p30_content = """
    <h2 class="chap-num">Chapter 7</h2>
    <h1 class="chap-title">All VIPs CSV Files and Interface Files</h1>

    <h2 class="sec-title">7.1 Automated VIP Generation Methodology</h2>
    <p>
        Building industry-grade UVM 1.2 Verification IPs (VIPs) for six heterogeneous peripheral interfaces manually is error-prone. To achieve rapid, deterministic verification closure, a Python-driven metadata generator was employed. Each peripheral's pinout and bus interface was formalized as a structured Comma-Separated Values (CSV) manifest detailing signal identifier, direction, and bit width. A code generation template then parsed these CSV tables to synthesize complete SystemVerilog interfaces (<code>*_if.sv</code>), transaction sequence items (<code>*_item.sv</code>), driver agents (<code>*_driver.sv</code>), monitors (<code>*_monitor.sv</code>), sequencers, and package definitions.
    </p>

    <h2 class="sec-title">7.2 CSV Port Definition Specifications (6 VIPs)</h2>

    <div class="caption"><b>Table 7.1:</b> UART VIP Interface Port List (CSV Definition: <code>CSV_files/uart.csv</code>)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 25%;">Signal Name</th>
                <th style="width: 20%;">Direction</th>
                <th style="width: 15%;">Bit Width</th>
                <th style="width: 40%;">Protocol / Pin Function</th>
            </tr>
        </thead>
        <tbody>
            <tr><td><code>clk</code>, <code>rst_n</code></td><td>input</td><td>1, 1</td><td>Synchronous system clock & active-low reset.</td></tr>
            <tr><td><code>s_axi_awaddr</code>, <code>s_axi_awvalid</code>, <code>s_axi_awready</code></td><td>input / output</td><td>32, 1, 1</td><td>AXI4-Lite Write Address Channel handshake.</td></tr>
            <tr><td><code>s_axi_wdata</code>, <code>s_axi_wstrb</code>, <code>s_axi_wvalid</code>, <code>s_axi_wready</code></td><td>input / output</td><td>32, 4, 1, 1</td><td>AXI4-Lite Write Data Channel handshake.</td></tr>
            <tr><td><code>s_axi_bresp</code>, <code>s_axi_bvalid</code>, <code>s_axi_bready</code></td><td>output / input</td><td>2, 1, 1</td><td>AXI4-Lite Write Response Channel.</td></tr>
            <tr><td><code>s_axi_araddr</code>, <code>s_axi_arvalid</code>, <code>s_axi_arready</code></td><td>input / output</td><td>32, 1, 1</td><td>AXI4-Lite Read Address Channel.</td></tr>
            <tr><td><code>s_axi_rdata</code>, <code>s_axi_rresp</code>, <code>s_axi_rvalid</code>, <code>s_axi_rready</code></td><td>output / input</td><td>32, 2, 1, 1</td><td>AXI4-Lite Read Data Channel.</td></tr>
            <tr><td><code>uart_rx</code>, <code>uart_tx</code>, <code>irq_uart</code></td><td>input / output</td><td>1, 1, 1</td><td>External serial lines & interrupt line to core.</td></tr>
        </tbody>
    </table>

    <div class="caption"><b>Table 7.2:</b> GPIO VIP Interface Port List (CSV Definition: <code>CSV_files/gpio.csv</code>)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 25%;">Signal Name</th>
                <th style="width: 20%;">Direction</th>
                <th style="width: 15%;">Bit Width</th>
                <th style="width: 40%;">Protocol / Pin Function</th>
            </tr>
        </thead>
        <tbody>
            <tr><td><code>clk</code>, <code>rst_n</code>, <code>s_axi_*</code></td><td>input / output</td><td>Standard AXI</td><td>Full 32-bit AXI4-Lite slave control bus.</td></tr>
            <tr><td><code>gpio_in</code></td><td>input</td><td>32</td><td>External digital sensory input lines.</td></tr>
            <tr><td><code>gpio_out</code>, <code>gpio_dir</code></td><td>output</td><td>32, 32</td><td>Output data drive bus & tristate direction controls.</td></tr>
            <tr><td><code>irq_gpio</code></td><td>output</td><td>1</td><td>Interrupt request line asserting on input edge.</td></tr>
        </tbody>
    </table>

    <div class="caption"><b>Table 7.3:</b> Timer VIP Interface Port List (CSV Definition: <code>CSV_files/timer.csv</code>)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 25%;">Signal Name</th>
                <th style="width: 20%;">Direction</th>
                <th style="width: 15%;">Bit Width</th>
                <th style="width: 40%;">Protocol / Pin Function</th>
            </tr>
        </thead>
        <tbody>
            <tr><td><code>clk</code>, <code>rst_n</code>, <code>s_axi_*</code></td><td>input / output</td><td>Standard AXI</td><td>Full 32-bit AXI4-Lite slave control bus.</td></tr>
            <tr><td><code>sample_tick</code></td><td>output</td><td>1</td><td>Single-cycle periodic sampling tick pulse.</td></tr>
            <tr><td><code>irq_timer</code></td><td>output</td><td>1</td><td>Level interrupt asserting upon counter match.</td></tr>
        </tbody>
    </table>
    """
    pages.append(make_page(p30_content, "30"))

    # Page 31
    p31_content = """
    <div class="caption"><b>Table 7.4:</b> SPI VIP Interface Port List (CSV Definition: <code>CSV_files/spi.csv</code>)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 25%;">Signal Name</th>
                <th style="width: 20%;">Direction</th>
                <th style="width: 15%;">Bit Width</th>
                <th style="width: 40%;">Protocol / Pin Function</th>
            </tr>
        </thead>
        <tbody>
            <tr><td><code>clk</code>, <code>rst_n</code>, <code>s_axi_*</code></td><td>input / output</td><td>Standard AXI</td><td>Full 32-bit AXI4-Lite slave control bus.</td></tr>
            <tr><td><code>spi_sclk</code></td><td>output</td><td>1</td><td>Motorola SPI master clock line.</td></tr>
            <tr><td><code>spi_mosi</code>, <code>spi_miso</code></td><td>output / input</td><td>1, 1</td><td>Full-duplex master transmit / receive serial lines.</td></tr>
            <tr><td><code>spi_cs_n</code></td><td>output</td><td>1</td><td>Active-low external Flash chip-select pin.</td></tr>
            <tr><td><code>irq_spi</code></td><td>output</td><td>1</td><td>Transfer completion interrupt line.</td></tr>
        </tbody>
    </table>

    <div class="caption"><b>Table 7.5:</b> I2C VIP Interface Port List (CSV Definition: <code>CSV_files/i2c.csv</code>)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 25%;">Signal Name</th>
                <th style="width: 20%;">Direction</th>
                <th style="width: 15%;">Bit Width</th>
                <th style="width: 40%;">Protocol / Pin Function</th>
            </tr>
        </thead>
        <tbody>
            <tr><td><code>clk</code>, <code>rst_n</code>, <code>s_axi_*</code></td><td>input / output</td><td>Standard AXI</td><td>Full 32-bit AXI4-Lite slave control bus.</td></tr>
            <tr><td><code>i2c_scl</code></td><td>output</td><td>1</td><td>I2C serial clock output (100/400 kHz).</td></tr>
            <tr><td><code>i2c_sda_out</code>, <code>i2c_sda_in</code></td><td>output / input</td><td>1, 1</td><td>Open-drain bidirectional serial data split lines.</td></tr>
            <tr><td><code>irq_i2c</code></td><td>output</td><td>1</td><td>Sensor transaction complete / error interrupt.</td></tr>
        </tbody>
    </table>

    <div class="caption"><b>Table 7.6:</b> PWM VIP Interface Port List (CSV Definition: <code>CSV_files/pwm.csv</code>)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 25%;">Signal Name</th>
                <th style="width: 20%;">Direction</th>
                <th style="width: 15%;">Bit Width</th>
                <th style="width: 40%;">Protocol / Pin Function</th>
            </tr>
        </thead>
        <tbody>
            <tr><td><code>clk</code>, <code>rst_n</code>, <code>s_axi_*</code></td><td>input / output</td><td>Standard AXI</td><td>Full 32-bit AXI4-Lite slave control bus.</td></tr>
            <tr><td><code>pwm_pad_o</code></td><td>output</td><td>1</td><td>Square-wave output driving acoustic piezo alarm.</td></tr>
            <tr><td><code>irq_pwm</code></td><td>output</td><td>1</td><td>Cycle rollover interrupt line to PIC.</td></tr>
        </tbody>
    </table>

    <h2 class="sec-title">7.3 SystemVerilog VIP Interface Architectures</h2>
    <p>
        The synthesized SystemVerilog interfaces encapsulate synchronous clocking blocks (<code>drv_cb</code> and <code>mon_cb</code>) with strict setup (#1ns) and hold (#1ns) timing assertions, ensuring zero race conditions between testbench drivers and the RTL device under test (DUT). The complete code listings are presented in Listings 7.1 through 7.6.
    </p>
    """
    pages.append(make_page(p31_content, "31"))

    # Page 32
    p32_content = f"""
    <div class="caption"><b>Listing 7.1:</b> Complete UART VIP Interface Definition (<code>VIPs/uart_vip/uart_if.sv</code>)</div>
    {lst7_1}
    """
    pages.append(make_page(p32_content, "32"))

    # Page 33
    p33_content = f"""
    <div class="caption"><b>Listing 7.2:</b> Complete GPIO VIP Interface Definition (<code>VIPs/gpio_vip/gpio_if.sv</code>)</div>
    {lst7_2}
    """
    pages.append(make_page(p33_content, "33"))

    # Page 34
    p34_content = f"""
    <div class="caption"><b>Listing 7.3:</b> Complete Interval Timer VIP Interface Definition (<code>VIPs/timer_vip/timer_if.sv</code>)</div>
    {lst7_3}
    """
    pages.append(make_page(p34_content, "34"))

    # Page 35
    p35_content = f"""
    <div class="caption"><b>Listing 7.4:</b> Complete SPI Master/Slave VIP Interface Definition (<code>VIPs/spi_vip/spi_if.sv</code>)</div>
    {lst7_4}
    """
    pages.append(make_page(p35_content, "35"))

    # Page 36
    p36_content = f"""
    <div class="caption"><b>Listing 7.5:</b> Complete I2C Master/Slave VIP Interface Definition (<code>VIPs/i2c_vip/i2c_if.sv</code>)</div>
    {lst7_5}
    """
    pages.append(make_page(p36_content, "36"))

    # Page 37
    p37_content = f"""
    <div class="caption"><b>Listing 7.6:</b> Complete PWM VIP Interface Definition (<code>VIPs/pwm_vip/pwm_if.sv</code>)</div>
    {lst7_6}
    """
    pages.append(make_page(p37_content, "37"))

    # Page 38
    p38_content = f"""
    <h2 class="sec-title">7.4 Automated VIP Master Build & Compilation Manifest</h2>
    <p>
        To ensure clean, repeatable simulation runs across EDA tool suites (Synopsys VCS, QuestaSim, Cadence Xcelium), all VIP packages and interface files are unified into an EDA compilation manifest (<code>VIPs/all_drv_run.f</code>). Listing 7.7 documents this master filelist.
    </p>

    <div class="caption"><b>Listing 7.7:</b> Master UVM VIP Compilation Manifest (<code>VIPs/all_drv_run.f</code>)</div>
    {lst7_7}

    <h3 class="subsec-title">7.4.1 Toolchain Invocation</h3>
    <p>
        The VIPs are compiled alongside the SoC RTL in Synopsys VCS using the command:<br>
        <code>vcs -sverilog -ntb_opts uvm-1.2 -f VIPs/all_drv_run.f soc_top.sv top_level_tb.sv -R</code>
    </p>
    """
    pages.append(make_page(p38_content, "38"))

    # Page 39
    p39_content = f"""
    <h2 class="sec-title">7.5 Top-Level SoC Verification Testbench Architecture</h2>
    <p>
        The top-level verification harness (<code>top_level_tb.sv</code>) instantiates the complete SoC (<code>soc_top.sv</code>), synthesizes 50 MHz clock and reset, connects all external VIP interfaces, emulates external I2C environmental sensors, and monitors serial telemetry frames.
    </p>

    <div class="caption"><b>Listing 7.8:</b> Excerpt of Top-Level SoC Verification Testbench (<code>top_level_tb.sv</code>)</div>
    {lst7_8}
    """
    pages.append(make_page(p39_content, "39"))

    return pages
