// =============================================================================
// Testbench   : tb_spi_controller.sv
// DUT         : spi_controller.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Verification of SPI Master Controller with Flash slave emulation.
// =============================================================================

`timescale 1ns / 1ps

module tb_spi_controller;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    localparam SPI_BASE        = 32'h4000_6000;
    localparam REG_SPI_CTRL    = SPI_BASE + 32'h00;
    localparam REG_SPI_STATUS  = SPI_BASE + 32'h04;
    localparam REG_SPI_TX      = SPI_BASE + 32'h08;
    localparam REG_SPI_RX      = SPI_BASE + 32'h0C;
    localparam REG_SPI_CLKDIV  = SPI_BASE + 32'h10;
    localparam REG_SPI_CS      = SPI_BASE + 32'h14;
    localparam REG_SPI_IRQ_EN  = SPI_BASE + 32'h18;
    localparam REG_SPI_IRQ_ST  = SPI_BASE + 32'h1C;

    logic                  clk;
    logic                  rst_n;

    wire                   spi_sclk;
    wire                   spi_mosi;
    logic                  spi_miso;
    wire                   spi_cs_n;

    logic [ADDR_WIDTH-1:0] s_axi_awaddr;
    logic                  s_axi_awvalid;
    wire                   s_axi_awready;

    logic [DATA_WIDTH-1:0] s_axi_wdata;
    logic [3:0]            s_axi_wstrb;
    logic                  s_axi_wvalid;
    wire                   s_axi_wready;

    wire  [1:0]            s_axi_bresp;
    wire                   s_axi_bvalid;
    logic                  s_axi_bready;

    logic [ADDR_WIDTH-1:0] s_axi_araddr;
    logic                  s_axi_arvalid;
    wire                   s_axi_arready;

    wire  [DATA_WIDTH-1:0] s_axi_rdata;
    wire  [1:0]            s_axi_rresp;
    wire                   s_axi_rvalid;
    logic                  s_axi_rready;

    wire                   irq_spi;

    integer test_errors = 0;
    integer test_passes = 0;

    spi_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .spi_sclk     (spi_sclk),
        .spi_mosi     (spi_mosi),
        .spi_miso     (spi_miso),
        .spi_cs_n     (spi_cs_n),
        .s_axi_awaddr (s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata  (s_axi_wdata),
        .s_axi_wstrb  (s_axi_wstrb),
        .s_axi_wvalid (s_axi_wvalid),
        .s_axi_wready (s_axi_wready),
        .s_axi_bresp  (s_axi_bresp),
        .s_axi_bvalid (s_axi_bvalid),
        .s_axi_bready (s_axi_bready),
        .s_axi_araddr (s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata  (s_axi_rdata),
        .s_axi_rresp  (s_axi_rresp),
        .s_axi_rvalid (s_axi_rvalid),
        .s_axi_rready (s_axi_rready),
        .irq_spi      (irq_spi)
    );

    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Behavioral SPI Slave Flash model (echoes inverted MOSI data to MISO)
    reg [7:0] slave_shift;
    always @(posedge spi_sclk or posedge spi_cs_n) begin
        if (spi_cs_n) begin
            slave_shift <= 8'h00;
            spi_miso    <= 1'b0;
        end else begin
            slave_shift <= {slave_shift[6:0], spi_mosi};
            spi_miso    <= ~slave_shift[7]; // Output inverted MSB
        end
    end

    task automatic axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);
            s_axi_awaddr  <= addr;
            s_axi_awvalid <= 1'b1;
            s_axi_wdata   <= data;
            s_axi_wstrb   <= 4'b1111;
            s_axi_wvalid  <= 1'b1;
            s_axi_bready  <= 1'b1;

            fork
                begin
                    while (!s_axi_awready) @(posedge clk);
                    @(posedge clk);
                    s_axi_awvalid <= 1'b0;
                end
                begin
                    while (!s_axi_wready) @(posedge clk);
                    @(posedge clk);
                    s_axi_wvalid <= 1'b0;
                end
            join

            while (!s_axi_bvalid) @(posedge clk);
            @(posedge clk);
            s_axi_bready <= 1'b0;
        end
    endtask

    task automatic axi_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);
            s_axi_araddr  <= addr;
            s_axi_arvalid <= 1'b1;
            s_axi_rready  <= 1'b1;

            while (!s_axi_arready) @(posedge clk);
            @(posedge clk);
            s_axi_arvalid <= 1'b0;

            while (!s_axi_rvalid) @(posedge clk);
            data = s_axi_rdata;
            @(posedge clk);
            s_axi_rready <= 1'b0;
        end
    endtask

    logic [DATA_WIDTH-1:0] rdata;

    initial begin
        $display("=== STARTING SPI MASTER CONTROLLER VERIFICATION ===");
        rst_n         = 0;
        spi_miso      = 0;
        s_axi_awaddr  = 0;
        s_axi_awvalid = 0;
        s_axi_wdata   = 0;
        s_axi_wstrb   = 0;
        s_axi_wvalid  = 0;
        s_axi_bready  = 0;
        s_axi_araddr  = 0;
        s_axi_arvalid = 0;
        s_axi_rready  = 0;

        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 2);

        // Configure SPI: CLKDIV=2, Enable master mode
        axi_write(REG_SPI_CLKDIV, 32'd2);
        axi_write(REG_SPI_IRQ_EN, 32'h03);
        axi_write(REG_SPI_CTRL, 32'h09); // EN=1, MASTER_MODE=1, CPOL=0, CPHA=0

        // Assert Chip Select (CS_N = 0)
        axi_write(REG_SPI_CS, 32'h00);
        if (spi_cs_n == 1'b0) begin
            $display("  [PASS] spi_cs_n asserted low");
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] spi_cs_n failed to assert!");
            test_errors = test_errors + 1;
        end

        // Transmit data byte 0xA5
        $display("[TEST 1] Transmit byte 0xA5 over SPI...");
        axi_write(REG_SPI_TX, 32'hA5);

        // Wait for transfer complete
        #(CLK_PERIOD * 100);
        axi_read(REG_SPI_STATUS, rdata);
        if (rdata[2] == 1'b1) begin // RX_VALID
            $display("  [PASS] SPI Transfer complete, RX_VALID asserted: 0x%08h", rdata);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] SPI RX_VALID not asserted: 0x%08h", rdata);
            test_errors = test_errors + 1;
        end

        // Deassert CS
        axi_write(REG_SPI_CS, 32'h01);
        if (spi_cs_n == 1'b1) begin
            $display("  [PASS] spi_cs_n deasserted high");
            test_passes = test_passes + 1;
        end

        $display("=== SPI TESTBENCH COMPLETED: %0d PASSED, %0d FAILED ===", test_passes, test_errors);
        $finish;
    end

endmodule
