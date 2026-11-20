// =============================================================================
// Module      : soc_top.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Full System-on-Chip Top-Level Integration.
//
// Integrates:
//   1. RISC-V VeeR EL2 Processor Core (RV32IMC with PIC Interrupts)
//   2. 3x 64-bit to 32-bit AXI Width Down-Converters (LSU, IFU, SB)
//   3. AXI4 Multi-Master Arbiter & Multiplexer (Instruction & Data routing)
//   4. 1-to-7 AXI4-Lite Crossbar Interconnect (with DECERR protection)
//   5. Unified Instruction & Data Memory (S00: 64 KB at 0x0000_0000)
//   6. Peripherals Subsystem:
//      - S01: UART Controller               (0x4000_0000)
//      - S02: GPIO Controller               (0x4000_2000)
//      - S03: System Interval Timer         (0x4000_4000)
//      - S04: SPI Flash Master Controller   (0x4000_6000)
//      - S05: I2C Digital Sensor Master     (0x4000_8000)
//      - S06: PWM Alert Generator           (0x4000_A000)
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module soc_top #(
    parameter DATA_WIDTH   = 32,
    parameter ADDR_WIDTH   = 32,
    parameter ID_WIDTH     = 8,
    parameter PIC_TOTAL_INT= 8,

    // Address Mapping per System Architecture
    parameter MEM_BASE_ADDR   = 32'h0000_0000,
    parameter UART_BASE_ADDR  = 32'h4000_0000,
    parameter GPIO_BASE_ADDR  = 32'h4000_2000,
    parameter TIMER_BASE_ADDR = 32'h4000_4000,
    parameter SPI_BASE_ADDR   = 32'h4000_6000,
    parameter I2C_BASE_ADDR   = 32'h4000_8000,
    parameter PWM_BASE_ADDR   = 32'h4000_A000
)(
    // System Clock & Reset
    input  wire                 clk,
    input  wire                 rst_n,

    // Core Control & Vectors
    input  wire [31:1]          rst_vec,
    input  wire                 nmi_int,
    input  wire [31:1]          nmi_vec,
    input  wire [31:1]          jtag_id,

    // UART Serial Interface
    input  wire                 uart_rx,
    output wire                 uart_tx,
    output wire                 uart_irq,

    // System Timer
    output wire                 sample_tick,
    output wire                 irq_timer,

    // GPIO Interface
    input  wire [7:0]           gpio_in,
    output wire [7:0]           gpio_out,
    output wire                 irq_gpio,

    // I2C Sensor Interface
    inout  wire                 scl,
    inout  wire                 sda,
    output wire                 irq_i2c,

    // SPI Flash Memory Interface
    output wire                 spi_sclk,
    output wire                 spi_mosi,
    input  wire                 spi_miso,
    output wire                 spi_cs_n,
    output wire                 irq_spi,

    // PWM Actuator Output
    output wire                 pwm_out,
    output wire                 irq_pwm
);

    wire rst = ~rst_n;

    // -------------------------------------------------------------------------
    // Interrupt Routing to VeeR EL2 Programmable Interrupt Controller (PIC)
    // -------------------------------------------------------------------------
    wire [PIC_TOTAL_INT-1:0] core_extintsrc_req;
    assign core_extintsrc_req[0] = uart_irq;
    assign core_extintsrc_req[1] = irq_timer;
    assign core_extintsrc_req[2] = irq_gpio;
    assign core_extintsrc_req[3] = irq_i2c;
    assign core_extintsrc_req[4] = irq_spi;
    assign core_extintsrc_req[5] = irq_pwm;
    assign core_extintsrc_req[6] = 1'b0;
    assign core_extintsrc_req[7] = 1'b0;

    // -------------------------------------------------------------------------
    // 64-bit Core AXI4 Interfaces
    // -------------------------------------------------------------------------
    // LSU 64-bit (Data Load/Store)
    wire                    lsu_axi_awvalid, lsu_axi_awready;
    wire [ID_WIDTH-1:0]     lsu_axi_awid;
    wire [31:0]             lsu_axi_awaddr;
    wire [3:0]              lsu_axi_awregion;
    wire [7:0]              lsu_axi_awlen;
    wire [2:0]              lsu_axi_awsize;
    wire [1:0]              lsu_axi_awburst;
    wire                    lsu_axi_awlock;
    wire [3:0]              lsu_axi_awcache;
    wire [2:0]              lsu_axi_awprot;
    wire [3:0]              lsu_axi_awqos;
    wire                    lsu_axi_wvalid, lsu_axi_wready;
    wire [63:0]             lsu_axi_wdata;
    wire [7:0]              lsu_axi_wstrb;
    wire                    lsu_axi_wlast;
    wire                    lsu_axi_bvalid, lsu_axi_bready;
    wire [1:0]              lsu_axi_bresp;
    wire [ID_WIDTH-1:0]     lsu_axi_bid;
    wire                    lsu_axi_arvalid, lsu_axi_arready;
    wire [ID_WIDTH-1:0]     lsu_axi_arid;
    wire [31:0]             lsu_axi_araddr;
    wire [3:0]              lsu_axi_arregion;
    wire [7:0]              lsu_axi_arlen;
    wire [2:0]              lsu_axi_arsize;
    wire [1:0]              lsu_axi_arburst;
    wire                    lsu_axi_arlock;
    wire [3:0]              lsu_axi_arcache;
    wire [2:0]              lsu_axi_arprot;
    wire [3:0]              lsu_axi_arqos;
    wire                    lsu_axi_rvalid, lsu_axi_rready;
    wire [ID_WIDTH-1:0]     lsu_axi_rid;
    wire [63:0]             lsu_axi_rdata;
    wire [1:0]              lsu_axi_rresp;
    wire                    lsu_axi_rlast;

    // IFU 64-bit (Instruction Fetch)
    wire                    ifu_axi_awvalid, ifu_axi_awready;
    wire [ID_WIDTH-1:0]     ifu_axi_awid;
    wire [31:0]             ifu_axi_awaddr;
    wire [3:0]              ifu_axi_awregion;
    wire [7:0]              ifu_axi_awlen;
    wire [2:0]              ifu_axi_awsize;
    wire [1:0]              ifu_axi_awburst;
    wire                    ifu_axi_awlock;
    wire [3:0]              ifu_axi_awcache;
    wire [2:0]              ifu_axi_awprot;
    wire [3:0]              ifu_axi_awqos;
    wire                    ifu_axi_wvalid, ifu_axi_wready;
    wire [63:0]             ifu_axi_wdata;
    wire [7:0]              ifu_axi_wstrb;
    wire                    ifu_axi_wlast;
    wire                    ifu_axi_bvalid, ifu_axi_bready;
    wire [1:0]              ifu_axi_bresp;
    wire [ID_WIDTH-1:0]     ifu_axi_bid;
    wire                    ifu_axi_arvalid, ifu_axi_arready;
    wire [ID_WIDTH-1:0]     ifu_axi_arid;
    wire [31:0]             ifu_axi_araddr;
    wire [3:0]              ifu_axi_arregion;
    wire [7:0]              ifu_axi_arlen;
    wire [2:0]              ifu_axi_arsize;
    wire [1:0]              ifu_axi_arburst;
    wire                    ifu_axi_arlock;
    wire [3:0]              ifu_axi_arcache;
    wire [2:0]              ifu_axi_arprot;
    wire [3:0]              ifu_axi_arqos;
    wire                    ifu_axi_rvalid, ifu_axi_rready;
    wire [ID_WIDTH-1:0]     ifu_axi_rid;
    wire [63:0]             ifu_axi_rdata;
    wire [1:0]              ifu_axi_rresp;
    wire                    ifu_axi_rlast;

    // SB 64-bit (System Bus)
    wire                    sb_axi_awvalid, sb_axi_awready;
    wire [ID_WIDTH-1:0]     sb_axi_awid;
    wire [31:0]             sb_axi_awaddr;
    wire [3:0]              sb_axi_awregion;
    wire [7:0]              sb_axi_awlen;
    wire [2:0]              sb_axi_awsize;
    wire [1:0]              sb_axi_awburst;
    wire                    sb_axi_awlock;
    wire [3:0]              sb_axi_awcache;
    wire [2:0]              sb_axi_awprot;
    wire [3:0]              sb_axi_awqos;
    wire                    sb_axi_wvalid, sb_axi_wready;
    wire [63:0]             sb_axi_wdata;
    wire [7:0]              sb_axi_wstrb;
    wire                    sb_axi_wlast;
    wire                    sb_axi_bvalid, sb_axi_bready;
    wire [1:0]              sb_axi_bresp;
    wire [ID_WIDTH-1:0]     sb_axi_bid;
    wire                    sb_axi_arvalid, sb_axi_arready;
    wire [ID_WIDTH-1:0]     sb_axi_arid;
    wire [31:0]             sb_axi_araddr;
    wire [3:0]              sb_axi_arregion;
    wire [7:0]              sb_axi_arlen;
    wire [2:0]              sb_axi_arsize;
    wire [1:0]              sb_axi_arburst;
    wire                    sb_axi_arlock;
    wire [3:0]              sb_axi_arcache;
    wire [2:0]              sb_axi_arprot;
    wire [3:0]              sb_axi_arqos;
    wire                    sb_axi_rvalid, sb_axi_rready;
    wire [ID_WIDTH-1:0]     sb_axi_rid;
    wire [63:0]             sb_axi_rdata;
    wire [1:0]              sb_axi_rresp;
    wire                    sb_axi_rlast;

    // -------------------------------------------------------------------------
    // 1. RISC-V VeeR EL2 Core Instance
    // -------------------------------------------------------------------------
    veer_wrapper u_veer_core (
        .clk                    (clk),
        .rst_l                  (rst_n),
        .dbg_rst_l              (rst_n),
        .rst_vec                (rst_vec),
        .nmi_int                (nmi_int),
        .nmi_vec                (nmi_vec),
        .jtag_id                (jtag_id),

        .timer_int              (1'b0),
        .extintsrc_req          (core_extintsrc_req),

        .lsu_bus_clk_en         (1'b1),
        .ifu_bus_clk_en         (1'b1),
        .dbg_bus_clk_en         (1'b1),
        .dma_bus_clk_en         (1'b1),

        .lsu_axi_awvalid        (lsu_axi_awvalid),
        .lsu_axi_awready        (lsu_axi_awready),
        .lsu_axi_awid           (lsu_axi_awid),
        .lsu_axi_awaddr         (lsu_axi_awaddr),
        .lsu_axi_awregion       (lsu_axi_awregion),
        .lsu_axi_awlen          (lsu_axi_awlen),
        .lsu_axi_awsize         (lsu_axi_awsize),
        .lsu_axi_awburst        (lsu_axi_awburst),
        .lsu_axi_awlock         (lsu_axi_awlock),
        .lsu_axi_awcache        (lsu_axi_awcache),
        .lsu_axi_awprot         (lsu_axi_awprot),
        .lsu_axi_awqos          (lsu_axi_awqos),
        .lsu_axi_wvalid         (lsu_axi_wvalid),
        .lsu_axi_wready         (lsu_axi_wready),
        .lsu_axi_wdata          (lsu_axi_wdata),
        .lsu_axi_wstrb          (lsu_axi_wstrb),
        .lsu_axi_wlast          (lsu_axi_wlast),
        .lsu_axi_bvalid         (lsu_axi_bvalid),
        .lsu_axi_bready         (lsu_axi_bready),
        .lsu_axi_bresp          (lsu_axi_bresp),
        .lsu_axi_bid            (lsu_axi_bid),
        .lsu_axi_arvalid        (lsu_axi_arvalid),
        .lsu_axi_arready        (lsu_axi_arready),
        .lsu_axi_arid           (lsu_axi_arid),
        .lsu_axi_araddr         (lsu_axi_araddr),
        .lsu_axi_arregion       (lsu_axi_arregion),
        .lsu_axi_arlen          (lsu_axi_arlen),
        .lsu_axi_arsize         (lsu_axi_arsize),
        .lsu_axi_arburst        (lsu_axi_arburst),
        .lsu_axi_arlock         (lsu_axi_arlock),
        .lsu_axi_arcache        (lsu_axi_arcache),
        .lsu_axi_arprot         (lsu_axi_arprot),
        .lsu_axi_arqos          (lsu_axi_arqos),
        .lsu_axi_rvalid         (lsu_axi_rvalid),
        .lsu_axi_rready         (lsu_axi_rready),
        .lsu_axi_rid            (lsu_axi_rid),
        .lsu_axi_rdata          (lsu_axi_rdata),
        .lsu_axi_rresp          (lsu_axi_rresp),
        .lsu_axi_rlast          (lsu_axi_rlast),

        .ifu_axi_awvalid        (ifu_axi_awvalid),
        .ifu_axi_awready        (ifu_axi_awready),
        .ifu_axi_awid           (ifu_axi_awid),
        .ifu_axi_awaddr         (ifu_axi_awaddr),
        .ifu_axi_awregion       (ifu_axi_awregion),
        .ifu_axi_awlen          (ifu_axi_awlen),
        .ifu_axi_awsize         (ifu_axi_awsize),
        .ifu_axi_awburst        (ifu_axi_awburst),
        .ifu_axi_awlock         (ifu_axi_awlock),
        .ifu_axi_awcache        (ifu_axi_awcache),
        .ifu_axi_awprot         (ifu_axi_awprot),
        .ifu_axi_awqos          (ifu_axi_awqos),
        .ifu_axi_wvalid         (ifu_axi_wvalid),
        .ifu_axi_wready         (ifu_axi_wready),
        .ifu_axi_wdata          (ifu_axi_wdata),
        .ifu_axi_wstrb          (ifu_axi_wstrb),
        .ifu_axi_wlast          (ifu_axi_wlast),
        .ifu_axi_bvalid         (ifu_axi_bvalid),
        .ifu_axi_bready         (ifu_axi_bready),
        .ifu_axi_bresp          (ifu_axi_bresp),
        .ifu_axi_bid            (ifu_axi_bid),
        .ifu_axi_arvalid        (ifu_axi_arvalid),
        .ifu_axi_arready        (ifu_axi_arready),
        .ifu_axi_arid           (ifu_axi_arid),
        .ifu_axi_araddr         (ifu_axi_araddr),
        .ifu_axi_arregion       (ifu_axi_arregion),
        .ifu_axi_arlen          (ifu_axi_arlen),
        .ifu_axi_arsize         (ifu_axi_arsize),
        .ifu_axi_arburst        (ifu_axi_arburst),
        .ifu_axi_arlock         (ifu_axi_arlock),
        .ifu_axi_arcache        (ifu_axi_arcache),
        .ifu_axi_arprot         (ifu_axi_arprot),
        .ifu_axi_arqos          (ifu_axi_arqos),
        .ifu_axi_rvalid         (ifu_axi_rvalid),
        .ifu_axi_rready         (ifu_axi_rready),
        .ifu_axi_rid            (ifu_axi_rid),
        .ifu_axi_rdata          (ifu_axi_rdata),
        .ifu_axi_rresp          (ifu_axi_rresp),
        .ifu_axi_rlast          (ifu_axi_rlast),

        .sb_axi_awvalid         (sb_axi_awvalid),
        .sb_axi_awready         (sb_axi_awready),
        .sb_axi_awid            (sb_axi_awid),
        .sb_axi_awaddr          (sb_axi_awaddr),
        .sb_axi_awregion        (sb_axi_awregion),
        .sb_axi_awlen           (sb_axi_awlen),
        .sb_axi_awsize          (sb_axi_awsize),
        .sb_axi_awburst         (sb_axi_awburst),
        .sb_axi_awlock          (sb_axi_awlock),
        .sb_axi_awcache         (sb_axi_awcache),
        .sb_axi_awprot          (sb_axi_awprot),
        .sb_axi_awqos           (sb_axi_awqos),
        .sb_axi_wvalid          (sb_axi_wvalid),
        .sb_axi_wready          (sb_axi_wready),
        .sb_axi_wdata           (sb_axi_wdata),
        .sb_axi_wstrb           (sb_axi_wstrb),
        .sb_axi_wlast           (sb_axi_wlast),
        .sb_axi_bvalid          (sb_axi_bvalid),
        .sb_axi_bready          (sb_axi_bready),
        .sb_axi_bresp           (sb_axi_bresp),
        .sb_axi_bid             (sb_axi_bid),
        .sb_axi_arvalid         (sb_axi_arvalid),
        .sb_axi_arready         (sb_axi_arready),
        .sb_axi_arid            (sb_axi_arid),
        .sb_axi_araddr          (sb_axi_araddr),
        .sb_axi_arregion        (sb_axi_arregion),
        .sb_axi_arlen           (sb_axi_arlen),
        .sb_axi_arsize          (sb_axi_arsize),
        .sb_axi_arburst         (sb_axi_arburst),
        .sb_axi_arlock          (sb_axi_arlock),
        .sb_axi_arcache         (sb_axi_arcache),
        .sb_axi_arprot          (sb_axi_arprot),
        .sb_axi_arqos           (sb_axi_arqos),
        .sb_axi_rvalid          (sb_axi_rvalid),
        .sb_axi_rready          (sb_axi_rready),
        .sb_axi_rid             (sb_axi_rid),
        .sb_axi_rdata           (sb_axi_rdata),
        .sb_axi_rresp           (sb_axi_rresp),
        .sb_axi_rlast           (sb_axi_rlast),

        .soft_int               (1'b0),
        .core_id                ('0)
    );

    // -------------------------------------------------------------------------
    // 2. 64-bit to 32-bit AXI Down-Converters
    // -------------------------------------------------------------------------
    // LSU 32-bit converted signals
    wire [ADDR_WIDTH-1:0] lsu32_awaddr;
    wire                  lsu32_awvalid, lsu32_awready;
    wire [DATA_WIDTH-1:0] lsu32_wdata;
    wire [3:0]            lsu32_wstrb;
    wire                  lsu32_wvalid, lsu32_wready;
    wire [1:0]            lsu32_bresp;
    wire                  lsu32_bvalid, lsu32_bready;
    wire [ADDR_WIDTH-1:0] lsu32_araddr;
    wire                  lsu32_arvalid, lsu32_arready;
    wire [DATA_WIDTH-1:0] lsu32_rdata;
    wire [1:0]            lsu32_rresp;
    wire                  lsu32_rvalid, lsu32_rready;

    axi_adapter_64_to_32 #(
        .ADDR_WIDTH(ADDR_WIDTH), .ID_WIDTH(ID_WIDTH)
    ) u_adapter_lsu (
        .clk(clk), .rst(rst),
        .s_axi_awid(lsu_axi_awid), .s_axi_awaddr(lsu_axi_awaddr), .s_axi_awlen(lsu_axi_awlen),
        .s_axi_awsize(lsu_axi_awsize), .s_axi_awburst(lsu_axi_awburst), .s_axi_awlock(lsu_axi_awlock),
        .s_axi_awcache(lsu_axi_awcache), .s_axi_awprot(lsu_axi_awprot), .s_axi_awqos(lsu_axi_awqos),
        .s_axi_awregion(lsu_axi_awregion), .s_axi_awuser(1'b0), .s_axi_awvalid(lsu_axi_awvalid), .s_axi_awready(lsu_axi_awready),
        .s_axi_wdata(lsu_axi_wdata), .s_axi_wstrb(lsu_axi_wstrb), .s_axi_wlast(lsu_axi_wlast),
        .s_axi_wuser(1'b0), .s_axi_wvalid(lsu_axi_wvalid), .s_axi_wready(lsu_axi_wready),
        .s_axi_bid(lsu_axi_bid), .s_axi_bresp(lsu_axi_bresp), .s_axi_buser(),
        .s_axi_bvalid(lsu_axi_bvalid), .s_axi_bready(lsu_axi_bready),
        .s_axi_arid(lsu_axi_arid), .s_axi_araddr(lsu_axi_araddr), .s_axi_arlen(lsu_axi_arlen),
        .s_axi_arsize(lsu_axi_arsize), .s_axi_arburst(lsu_axi_arburst), .s_axi_arlock(lsu_axi_arlock),
        .s_axi_arcache(lsu_axi_arcache), .s_axi_arprot(lsu_axi_arprot), .s_axi_arqos(lsu_axi_arqos),
        .s_axi_arregion(lsu_axi_arregion), .s_axi_aruser(1'b0), .s_axi_arvalid(lsu_axi_arvalid), .s_axi_arready(lsu_axi_arready),
        .s_axi_rid(lsu_axi_rid), .s_axi_rdata(lsu_axi_rdata), .s_axi_rresp(lsu_axi_rresp),
        .s_axi_rlast(lsu_axi_rlast), .s_axi_ruser(), .s_axi_rvalid(lsu_axi_rvalid), .s_axi_rready(lsu_axi_rready),

        .m_axi_awid(), .m_axi_awaddr(lsu32_awaddr), .m_axi_awlen(), .m_axi_awsize(), .m_axi_awburst(),
        .m_axi_awlock(), .m_axi_awcache(), .m_axi_awprot(), .m_axi_awqos(), .m_axi_awregion(), .m_axi_awuser(),
        .m_axi_awvalid(lsu32_awvalid), .m_axi_awready(lsu32_awready),
        .m_axi_wdata(lsu32_wdata), .m_axi_wstrb(lsu32_wstrb), .m_axi_wlast(), .m_axi_wuser(),
        .m_axi_wvalid(lsu32_wvalid), .m_axi_wready(lsu32_wready),
        .m_axi_bid(8'd0), .m_axi_bresp(lsu32_bresp), .m_axi_buser(1'b0),
        .m_axi_bvalid(lsu32_bvalid), .m_axi_bready(lsu32_bready),
        .m_axi_arid(), .m_axi_araddr(lsu32_araddr), .m_axi_arlen(), .m_axi_arsize(), .m_axi_arburst(),
        .m_axi_arlock(), .m_axi_arcache(), .m_axi_arprot(), .m_axi_arqos(), .m_axi_arregion(), .m_axi_aruser(),
        .m_axi_arvalid(lsu32_arvalid), .m_axi_arready(lsu32_arready),
        .m_axi_rid(8'd0), .m_axi_rdata(lsu32_rdata), .m_axi_rresp(lsu32_rresp), .m_axi_rlast(1'b1),
        .m_axi_ruser(1'b0), .m_axi_rvalid(lsu32_rvalid), .m_axi_rready(lsu32_rready)
    );

    // IFU 32-bit converted signals (Instruction Fetch to Memory)
    wire [ADDR_WIDTH-1:0] ifu32_araddr;
    wire                  ifu32_arvalid, ifu32_arready;
    wire [DATA_WIDTH-1:0] ifu32_rdata;
    wire [1:0]            ifu32_rresp;
    wire                  ifu32_rvalid, ifu32_rready;

    axi_adapter_64_to_32 #(
        .ADDR_WIDTH(ADDR_WIDTH), .ID_WIDTH(ID_WIDTH)
    ) u_adapter_ifu (
        .clk(clk), .rst(rst),
        .s_axi_awid(ifu_axi_awid), .s_axi_awaddr(ifu_axi_awaddr), .s_axi_awlen(ifu_axi_awlen),
        .s_axi_awsize(ifu_axi_awsize), .s_axi_awburst(ifu_axi_awburst), .s_axi_awlock(ifu_axi_awlock),
        .s_axi_awcache(ifu_axi_awcache), .s_axi_awprot(ifu_axi_awprot), .s_axi_awqos(ifu_axi_awqos),
        .s_axi_awregion(ifu_axi_awregion), .s_axi_awuser(1'b0), .s_axi_awvalid(ifu_axi_awvalid), .s_axi_awready(ifu_axi_awready),
        .s_axi_wdata(ifu_axi_wdata), .s_axi_wstrb(ifu_axi_wstrb), .s_axi_wlast(ifu_axi_wlast),
        .s_axi_wuser(1'b0), .s_axi_wvalid(ifu_axi_wvalid), .s_axi_wready(ifu_axi_wready),
        .s_axi_bid(ifu_axi_bid), .s_axi_bresp(ifu_axi_bresp), .s_axi_buser(),
        .s_axi_bvalid(ifu_axi_bvalid), .s_axi_bready(ifu_axi_bready),
        .s_axi_arid(ifu_axi_arid), .s_axi_araddr(ifu_axi_araddr), .s_axi_arlen(ifu_axi_arlen),
        .s_axi_arsize(ifu_axi_arsize), .s_axi_arburst(ifu_axi_arburst), .s_axi_arlock(ifu_axi_arlock),
        .s_axi_arcache(ifu_axi_arcache), .s_axi_arprot(ifu_axi_arprot), .s_axi_arqos(ifu_axi_arqos),
        .s_axi_arregion(ifu_axi_arregion), .s_axi_aruser(1'b0), .s_axi_arvalid(ifu_axi_arvalid), .s_axi_arready(ifu_axi_arready),
        .s_axi_rid(ifu_axi_rid), .s_axi_rdata(ifu_axi_rdata), .s_axi_rresp(ifu_axi_rresp),
        .s_axi_rlast(ifu_axi_rlast), .s_axi_ruser(), .s_axi_rvalid(ifu_axi_rvalid), .s_axi_rready(ifu_axi_rready),

        .m_axi_awid(), .m_axi_awaddr(), .m_axi_awlen(), .m_axi_awsize(), .m_axi_awburst(),
        .m_axi_awlock(), .m_axi_awcache(), .m_axi_awprot(), .m_axi_awqos(), .m_axi_awregion(), .m_axi_awuser(),
        .m_axi_awvalid(), .m_axi_awready(1'b1),
        .m_axi_wdata(), .m_axi_wstrb(), .m_axi_wlast(), .m_axi_wuser(),
        .m_axi_wvalid(), .m_axi_wready(1'b1),
        .m_axi_bid(8'd0), .m_axi_bresp(2'b00), .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0), .m_axi_bready(),
        .m_axi_arid(), .m_axi_araddr(ifu32_araddr), .m_axi_arlen(), .m_axi_arsize(), .m_axi_arburst(),
        .m_axi_arlock(), .m_axi_arcache(), .m_axi_arprot(), .m_axi_arqos(), .m_axi_arregion(), .m_axi_aruser(),
        .m_axi_arvalid(ifu32_arvalid), .m_axi_arready(ifu32_arready),
        .m_axi_rid(8'd0), .m_axi_rdata(ifu32_rdata), .m_axi_rresp(ifu32_rresp), .m_axi_rlast(1'b1),
        .m_axi_ruser(1'b0), .m_axi_rvalid(ifu32_rvalid), .m_axi_rready(ifu32_rready)
    );

    // -------------------------------------------------------------------------
    // 3. Multi-Master Multiplexing (Arbitrates IFU Instruction Fetch & LSU Data)
    // -------------------------------------------------------------------------
    wire [ADDR_WIDTH-1:0] arb_awaddr  = lsu32_awaddr;
    wire                  arb_awvalid = lsu32_awvalid;
    wire                  arb_awready;
    assign lsu32_awready = arb_awready;

    wire [DATA_WIDTH-1:0] arb_wdata   = lsu32_wdata;
    wire [3:0]            arb_wstrb   = lsu32_wstrb;
    wire                  arb_wvalid  = lsu32_wvalid;
    wire                  arb_wready;
    assign lsu32_wready  = arb_wready;

    wire [1:0]            arb_bresp;
    wire                  arb_bvalid;
    wire                  arb_bready  = lsu32_bready;
    assign lsu32_bresp   = arb_bresp;
    assign lsu32_bvalid  = arb_bvalid;

    // Read arbitration: IFU has priority unless LSU is requesting
    reg ifu_active_q;
    wire [ADDR_WIDTH-1:0] arb_araddr  = lsu32_arvalid ? lsu32_araddr  : ifu32_araddr;
    wire                  arb_arvalid = lsu32_arvalid ? lsu32_arvalid : ifu32_arvalid;
    wire                  arb_arready;

    assign lsu32_arready = lsu32_arvalid ? arb_arready : 1'b0;
    assign ifu32_arready = lsu32_arvalid ? 1'b0        : arb_arready;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ifu_active_q <= 1'b0;
        end else if (arb_arvalid && arb_arready) begin
            ifu_active_q <= !lsu32_arvalid;
        end
    end

    wire [DATA_WIDTH-1:0] arb_rdata;
    wire [1:0]            arb_rresp;
    wire                  arb_rvalid;
    wire                  arb_rready  = ifu_active_q ? ifu32_rready : lsu32_rready;

    assign lsu32_rdata  = arb_rdata;
    assign lsu32_rresp  = arb_rresp;
    assign lsu32_rvalid = !ifu_active_q ? arb_rvalid : 1'b0;

    assign ifu32_rdata  = arb_rdata;
    assign ifu32_rresp  = arb_rresp;
    assign ifu32_rvalid = ifu_active_q  ? arb_rvalid : 1'b0;

    // -------------------------------------------------------------------------
    // 4. 1-to-8 AXI4-Lite Crossbar Interconnect
    // -------------------------------------------------------------------------
    // Interconnect master ports (connecting to Peripherals & Memory)
    `define DECLARE_XBAR_M(idx) \
        wire [ADDR_WIDTH-1:0] m``idx``_awaddr;  wire m``idx``_awvalid; wire m``idx``_awready; \
        wire [DATA_WIDTH-1:0] m``idx``_wdata;   wire [3:0] m``idx``_wstrb; wire m``idx``_wvalid; wire m``idx``_wready; \
        wire [1:0]            m``idx``_bresp;   wire m``idx``_bvalid;  wire m``idx``_bready; \
        wire [ADDR_WIDTH-1:0] m``idx``_araddr;  wire m``idx``_arvalid; wire m``idx``_arready; \
        wire [DATA_WIDTH-1:0] m``idx``_rdata;   wire [1:0] m``idx``_rresp; wire m``idx``_rvalid; wire m``idx``_rready;

    `DECLARE_XBAR_M(0) // S0: Unified Memory
    `DECLARE_XBAR_M(1) // S1: UART
    `DECLARE_XBAR_M(2) // S2: GPIO
    `DECLARE_XBAR_M(3) // S3: Timer
    `DECLARE_XBAR_M(4) // S4: SPI
    `DECLARE_XBAR_M(5) // S5: I2C
    `DECLARE_XBAR_M(6) // S6: PWM

    axi_interconnect #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_interconnect (
        .clk          (clk),
        .rst_n        (rst_n),
        .s_axi_awaddr (arb_awaddr),
        .s_axi_awvalid(arb_awvalid),
        .s_axi_awready(arb_awready),
        .s_axi_wdata  (arb_wdata),
        .s_axi_wstrb  (arb_wstrb),
        .s_axi_wvalid (arb_wvalid),
        .s_axi_wready (arb_wready),
        .s_axi_bresp  (arb_bresp),
        .s_axi_bvalid (arb_bvalid),
        .s_axi_bready (arb_bready),
        .s_axi_araddr (arb_araddr),
        .s_axi_arvalid(arb_arvalid),
        .s_axi_arready(arb_arready),
        .s_axi_rdata  (arb_rdata),
        .s_axi_rresp  (arb_rresp),
        .s_axi_rvalid (arb_rvalid),
        .s_axi_rready (arb_rready),

        // M0: Unified Memory
        .m0_axi_awaddr (m0_awaddr),  .m0_axi_awvalid(m0_awvalid), .m0_axi_awready(m0_awready),
        .m0_axi_wdata  (m0_wdata),   .m0_axi_wstrb  (m0_wstrb),   .m0_axi_wvalid (m0_wvalid),  .m0_axi_wready(m0_wready),
        .m0_axi_bresp  (m0_bresp),   .m0_axi_bvalid (m0_bvalid),  .m0_axi_bready (m0_bready),
        .m0_axi_araddr (m0_araddr),  .m0_axi_arvalid(m0_arvalid), .m0_axi_arready(m0_arready),
        .m0_axi_rdata  (m0_rdata),   .m0_axi_rresp  (m0_rresp),   .m0_axi_rvalid (m0_rvalid),  .m0_axi_rready(m0_rready),

        // M1: UART
        .m1_axi_awaddr (m1_awaddr),  .m1_axi_awvalid(m1_awvalid), .m1_axi_awready(m1_awready),
        .m1_axi_wdata  (m1_wdata),   .m1_axi_wstrb  (m1_wstrb),   .m1_axi_wvalid (m1_wvalid),  .m1_axi_wready(m1_wready),
        .m1_axi_bresp  (m1_bresp),   .m1_axi_bvalid (m1_bvalid),  .m1_axi_bready (m1_bready),
        .m1_axi_araddr (m1_araddr),  .m1_axi_arvalid(m1_arvalid), .m1_axi_arready(m1_arready),
        .m1_axi_rdata  (m1_rdata),   .m1_axi_rresp  (m1_rresp),   .m1_axi_rvalid (m1_rvalid),  .m1_axi_rready(m1_rready),

        // M2: GPIO
        .m2_axi_awaddr (m2_awaddr),  .m2_axi_awvalid(m2_awvalid), .m2_axi_awready(m2_awready),
        .m2_axi_wdata  (m2_wdata),   .m2_axi_wstrb  (m2_wstrb),   .m2_axi_wvalid (m2_wvalid),  .m2_axi_wready(m2_wready),
        .m2_axi_bresp  (m2_bresp),   .m2_axi_bvalid (m2_bvalid),  .m2_axi_bready (m2_bready),
        .m2_axi_araddr (m2_araddr),  .m2_axi_arvalid(m2_arvalid), .m2_axi_arready(m2_arready),
        .m2_axi_rdata  (m2_rdata),   .m2_axi_rresp  (m2_rresp),   .m2_axi_rvalid (m2_rvalid),  .m2_axi_rready(m2_rready),

        // M3: Timer
        .m3_axi_awaddr (m3_awaddr),  .m3_axi_awvalid(m3_awvalid), .m3_axi_awready(m3_awready),
        .m3_axi_wdata  (m3_wdata),   .m3_axi_wstrb  (m3_wstrb),   .m3_axi_wvalid (m3_wvalid),  .m3_axi_wready(m3_wready),
        .m3_axi_bresp  (m3_bresp),   .m3_axi_bvalid (m3_bvalid),  .m3_axi_bready (m3_bready),
        .m3_axi_araddr (m3_araddr),  .m3_axi_arvalid(m3_arvalid), .m3_axi_arready(m3_arready),
        .m3_axi_rdata  (m3_rdata),   .m3_axi_rresp  (m3_rresp),   .m3_axi_rvalid (m3_rvalid),  .m3_axi_rready(m3_rready),

        // M4: SPI
        .m4_axi_awaddr (m4_awaddr),  .m4_axi_awvalid(m4_awvalid), .m4_axi_awready(m4_awready),
        .m4_axi_wdata  (m4_wdata),   .m4_axi_wstrb  (m4_wstrb),   .m4_axi_wvalid (m4_wvalid),  .m4_axi_wready(m4_wready),
        .m4_axi_bresp  (m4_bresp),   .m4_axi_bvalid (m4_bvalid),  .m4_axi_bready (m4_bready),
        .m4_axi_araddr (m4_araddr),  .m4_axi_arvalid(m4_arvalid), .m4_axi_arready(m4_arready),
        .m4_axi_rdata  (m4_rdata),   .m4_axi_rresp  (m4_rresp),   .m4_axi_rvalid (m4_rvalid),  .m4_axi_rready(m4_rready),

        // M5: I2C
        .m5_axi_awaddr (m5_awaddr),  .m5_axi_awvalid(m5_awvalid), .m5_axi_awready(m5_awready),
        .m5_axi_wdata  (m5_wdata),   .m5_axi_wstrb  (m5_wstrb),   .m5_axi_wvalid (m5_wvalid),  .m5_axi_wready(m5_wready),
        .m5_axi_bresp  (m5_bresp),   .m5_axi_bvalid (m5_bvalid),  .m5_axi_bready (m5_bready),
        .m5_axi_araddr (m5_araddr),  .m5_axi_arvalid(m5_arvalid), .m5_axi_arready(m5_arready),
        .m5_axi_rdata  (m5_rdata),   .m5_axi_rresp  (m5_rresp),   .m5_axi_rvalid (m5_rvalid),  .m5_axi_rready(m5_rready),

        // M6: PWM
        .m6_axi_awaddr (m6_awaddr),  .m6_axi_awvalid(m6_awvalid), .m6_axi_awready(m6_awready),
        .m6_axi_wdata  (m6_wdata),   .m6_axi_wstrb  (m6_wstrb),   .m6_axi_wvalid (m6_wvalid),  .m6_axi_wready(m6_wready),
        .m6_axi_bresp  (m6_bresp),   .m6_axi_bvalid (m6_bvalid),  .m6_axi_bready (m6_bready),
        .m6_axi_araddr (m6_araddr),  .m6_axi_arvalid(m6_arvalid), .m6_axi_arready(m6_arready),
        .m6_axi_rdata  (m6_rdata),   .m6_axi_rresp  (m6_rresp),   .m6_axi_rvalid (m6_rvalid),  .m6_axi_rready(m6_rready)
    );

    // -------------------------------------------------------------------------
    // 5. Unified Memory Subsystem (S00: 64 KB SRAM at 0x0000_0000)
    // -------------------------------------------------------------------------
    axi_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH (16384) // 64 KB SRAM
    ) u_memory (
        .clk          (clk),
        .rst_n        (rst_n),
        .s_axi_awaddr (m0_awaddr),
        .s_axi_awvalid(m0_awvalid),
        .s_axi_awready(m0_awready),
        .s_axi_wdata  (m0_wdata),
        .s_axi_wstrb  (m0_wstrb),
        .s_axi_wvalid (m0_wvalid),
        .s_axi_wready (m0_wready),
        .s_axi_bresp  (m0_bresp),
        .s_axi_bvalid (m0_bvalid),
        .s_axi_bready (m0_bready),
        .s_axi_araddr (m0_araddr),
        .s_axi_arvalid(m0_arvalid),
        .s_axi_arready(m0_arready),
        .s_axi_rdata  (m0_rdata),
        .s_axi_rresp  (m0_rresp),
        .s_axi_rvalid (m0_rvalid),
        .s_axi_rready (m0_rready)
    );

    // -------------------------------------------------------------------------
    // 6. UART IP (S01: 0x4000_0000)
    // -------------------------------------------------------------------------
    uart #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_uart (
        .clk          (clk),
        .rst_n        (rst_n),
        .s_axi_awaddr (m1_awaddr),
        .s_axi_awvalid(m1_awvalid),
        .s_axi_awready(m1_awready),
        .s_axi_wdata  (m1_wdata),
        .s_axi_wstrb  (m1_wstrb),
        .s_axi_wvalid (m1_wvalid),
        .s_axi_wready (m1_wready),
        .s_axi_bresp  (m1_bresp),
        .s_axi_bvalid (m1_bvalid),
        .s_axi_bready (m1_bready),
        .s_axi_araddr (m1_araddr),
        .s_axi_arvalid(m1_arvalid),
        .s_axi_arready(m1_arready),
        .s_axi_rdata  (m1_rdata),
        .s_axi_rresp  (m1_rresp),
        .s_axi_rvalid (m1_rvalid),
        .s_axi_rready (m1_rready),
        .uart_rx      (uart_rx),
        .uart_tx      (uart_tx),
        .irq_uart     (uart_irq)
    );

    // -------------------------------------------------------------------------
    // 7. GPIO IP (S02: 0x4000_2000)
    // -------------------------------------------------------------------------
    gpio #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_gpio (
        .clk          (clk),
        .rst_n        (rst_n),
        .gpio_in      (gpio_in),
        .gpio_out     (gpio_out),
        .s_axi_awaddr (m2_awaddr),
        .s_axi_awvalid(m2_awvalid),
        .s_axi_awready(m2_awready),
        .s_axi_wdata  (m2_wdata),
        .s_axi_wstrb  (m2_wstrb),
        .s_axi_wvalid (m2_wvalid),
        .s_axi_wready (m2_wready),
        .s_axi_bresp  (m2_bresp),
        .s_axi_bvalid (m2_bvalid),
        .s_axi_bready (m2_bready),
        .s_axi_araddr (m2_araddr),
        .s_axi_arvalid(m2_arvalid),
        .s_axi_arready(m2_arready),
        .s_axi_rdata  (m2_rdata),
        .s_axi_rresp  (m2_rresp),
        .s_axi_rvalid (m2_rvalid),
        .s_axi_rready (m2_rready),
        .irq_gpio     (irq_gpio)
    );

    // -------------------------------------------------------------------------
    // 8. Timer IP (S03: 0x4000_4000)
    // -------------------------------------------------------------------------
    timer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_timer (
        .clk          (clk),
        .rst_n        (rst_n),
        .s_axi_awaddr (m3_awaddr),
        .s_axi_awvalid(m3_awvalid),
        .s_axi_awready(m3_awready),
        .s_axi_wdata  (m3_wdata),
        .s_axi_wstrb  (m3_wstrb),
        .s_axi_wvalid (m3_wvalid),
        .s_axi_wready (m3_wready),
        .s_axi_bresp  (m3_bresp),
        .s_axi_bvalid (m3_bvalid),
        .s_axi_bready (m3_bready),
        .s_axi_araddr (m3_araddr),
        .s_axi_arvalid(m3_arvalid),
        .s_axi_arready(m3_arready),
        .s_axi_rdata  (m3_rdata),
        .s_axi_rresp  (m3_rresp),
        .s_axi_rvalid (m3_rvalid),
        .s_axi_rready (m3_rready),
        .sample_tick  (sample_tick),
        .irq_timer    (irq_timer)
    );

    // -------------------------------------------------------------------------
    // 9. SPI Controller IP (S04: 0x4000_6000)
    // -------------------------------------------------------------------------
    spi_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_spi (
        .clk          (clk),
        .rst_n        (rst_n),
        .spi_sclk     (spi_sclk),
        .spi_mosi     (spi_mosi),
        .spi_miso     (spi_miso),
        .spi_cs_n     (spi_cs_n),
        .s_axi_awaddr (m4_awaddr),
        .s_axi_awvalid(m4_awvalid),
        .s_axi_awready(m4_awready),
        .s_axi_wdata  (m4_wdata),
        .s_axi_wstrb  (m4_wstrb),
        .s_axi_wvalid (m4_wvalid),
        .s_axi_wready (m4_wready),
        .s_axi_bresp  (m4_bresp),
        .s_axi_bvalid (m4_bvalid),
        .s_axi_bready (m4_bready),
        .s_axi_araddr (m4_araddr),
        .s_axi_arvalid(m4_arvalid),
        .s_axi_arready(m4_arready),
        .s_axi_rdata  (m4_rdata),
        .s_axi_rresp  (m4_rresp),
        .s_axi_rvalid (m4_rvalid),
        .s_axi_rready (m4_rready),
        .irq_spi      (irq_spi)
    );

    // -------------------------------------------------------------------------
    // 10. I2C Controller IP (S05: 0x4000_8000)
    // -------------------------------------------------------------------------
    wire scl_pad_o, scl_padoen_o;
    wire sda_pad_o, sda_padoen_o;

    i2c_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_i2c (
        .clk          (clk),
        .rst_n        (rst_n),
        .s_axi_awaddr (m5_awaddr),
        .s_axi_awvalid(m5_awvalid),
        .s_axi_awready(m5_awready),
        .s_axi_wdata  (m5_wdata),
        .s_axi_wstrb  (m5_wstrb),
        .s_axi_wvalid (m5_wvalid),
        .s_axi_wready (m5_wready),
        .s_axi_bresp  (m5_bresp),
        .s_axi_bvalid (m5_bvalid),
        .s_axi_bready (m5_bready),
        .s_axi_araddr (m5_araddr),
        .s_axi_arvalid(m5_arvalid),
        .s_axi_arready(m5_arready),
        .s_axi_rdata  (m5_rdata),
        .s_axi_rresp  (m5_rresp),
        .s_axi_rvalid (m5_rvalid),
        .s_axi_rready (m5_rready),
        .scl_pad_i    (scl),
        .scl_pad_o    (scl_pad_o),
        .scl_padoen_o (scl_padoen_o),
        .sda_pad_i    (sda),
        .sda_pad_o    (sda_pad_o),
        .sda_padoen_o (sda_padoen_o),
        .scl          (scl),
        .sda          (sda),
        .irq_i2c      (irq_i2c)
    );

    // -------------------------------------------------------------------------
    // 11. PWM Generator IP (S06: 0x4000_A000)
    // -------------------------------------------------------------------------
    pwm_generator #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_pwm (
        .clk          (clk),
        .rst_n        (rst_n),
        .s_axi_awaddr (m6_awaddr),
        .s_axi_awvalid(m6_awvalid),
        .s_axi_awready(m6_awready),
        .s_axi_wdata  (m6_wdata),
        .s_axi_wstrb  (m6_wstrb),
        .s_axi_wvalid (m6_wvalid),
        .s_axi_wready (m6_wready),
        .s_axi_bresp  (m6_bresp),
        .s_axi_bvalid (m6_bvalid),
        .s_axi_bready (m6_bready),
        .s_axi_araddr (m6_araddr),
        .s_axi_arvalid(m6_arvalid),
        .s_axi_arready(m6_arready),
        .s_axi_rdata  (m6_rdata),
        .s_axi_rresp  (m6_rresp),
        .s_axi_rvalid (m6_rvalid),
        .s_axi_rready (m6_rready),
        .pwm_out      (pwm_out),
        .irq_pwm      (irq_pwm)
    );

endmodule
`default_nettype wire
