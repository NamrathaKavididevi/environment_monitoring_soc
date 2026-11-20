// =============================================================================
// Testbench   : tb_gpio.sv
// DUT         : gpio.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Verification of AXI4-Lite GPIO IP with Set/Clear, Direction & Interrupts.
// =============================================================================

`timescale 1ns / 1ps

module tb_gpio;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    localparam GPIO_BASE        = 32'h4000_2000;
    localparam REG_GPIO_INPUT   = GPIO_BASE + 32'h00;
    localparam REG_GPIO_OUTPUT  = GPIO_BASE + 32'h04;
    localparam REG_GPIO_DIR     = GPIO_BASE + 32'h08;
    localparam REG_GPIO_SET     = GPIO_BASE + 32'h0C;
    localparam REG_GPIO_CLEAR   = GPIO_BASE + 32'h10;
    localparam REG_GPIO_IRQ_EN  = GPIO_BASE + 32'h14;
    localparam REG_GPIO_IRQ_ST  = GPIO_BASE + 32'h18;

    logic                  clk;
    logic                  rst_n;

    logic [7:0]            gpio_in;
    wire  [7:0]            gpio_out;

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

    wire                   irq_gpio;

    integer test_errors = 0;
    integer test_passes = 0;

    gpio #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .gpio_in      (gpio_in),
        .gpio_out     (gpio_out),
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
        .irq_gpio     (irq_gpio)
    );

    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

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
        $display("=== STARTING GPIO IP VERIFICATION ===");
        rst_n         = 0;
        gpio_in       = 8'h00;
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

        // Test 1: Direct Write and Read of GPIO_OUTPUT
        $display("[TEST 1] Write GPIO_OUTPUT = 0x55...");
        axi_write(REG_GPIO_OUTPUT, 32'h55);
        if (gpio_out == 8'h55) begin
            $display("  [PASS] gpio_out pin matches written value 0x55");
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] gpio_out pin mismatch: 0x%02X", gpio_out);
            test_errors = test_errors + 1;
        end

        // Test 2: Atomic SET and CLEAR Registers
        $display("[TEST 2] Testing GPIO_SET (bit 7) and GPIO_CLEAR (bit 0)...");
        axi_write(REG_GPIO_SET, 32'h80); // Set bit 7: 0x55 | 0x80 = 0xD5
        #(CLK_PERIOD * 2);
        if (gpio_out == 8'hD5) begin
            $display("  [PASS] GPIO_SET verified: gpio_out = 0x%02X", gpio_out);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] GPIO_SET failed: gpio_out = 0x%02X", gpio_out);
            test_errors = test_errors + 1;
        end

        axi_write(REG_GPIO_CLEAR, 32'h01); // Clear bit 0: 0xD5 & ~0x01 = 0xD4
        #(CLK_PERIOD * 2);
        if (gpio_out == 8'hD4) begin
            $display("  [PASS] GPIO_CLEAR verified: gpio_out = 0x%02X", gpio_out);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] GPIO_CLEAR failed: gpio_out = 0x%02X", gpio_out);
            test_errors = test_errors + 1;
        end

        // Test 3: Read Synchronized GPIO_INPUT
        $display("[TEST 3] Drive gpio_in = 0xA3 and read GPIO_INPUT...");
        gpio_in = 8'hA3;
        #(CLK_PERIOD * 5); // Allow 3 clock synchronizer stages to settle
        axi_read(REG_GPIO_INPUT, rdata);
        if (rdata[7:0] == 8'hA3) begin
            $display("  [PASS] GPIO_INPUT readback verified: 0x%02X", rdata[7:0]);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] GPIO_INPUT mismatch: Expected 0xA3, Got 0x%02X", rdata[7:0]);
            test_errors = test_errors + 1;
        end

        // Test 4: Edge Detection Interrupt and W1C
        $display("[TEST 4] Edge detection and W1C interrupt flag...");
        axi_write(REG_GPIO_IRQ_EN, 32'hFF); // Enable all IRQs
        gpio_in = 8'hB3; // Toggle bit 4
        #(CLK_PERIOD * 5);
        if (irq_gpio == 1'b1) begin
            $display("  [PASS] irq_gpio asserted on input edge");
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] irq_gpio not asserted on edge!");
            test_errors = test_errors + 1;
        end

        axi_write(REG_GPIO_IRQ_ST, 32'hFF); // W1C to clear flags
        #(CLK_PERIOD * 2);
        if (irq_gpio == 1'b0) begin
            $display("  [PASS] irq_gpio deasserted after W1C");
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] irq_gpio failed to clear on W1C!");
            test_errors = test_errors + 1;
        end

        $display("=== GPIO TESTBENCH COMPLETED: %0d PASSED, %0d FAILED ===", test_passes, test_errors);
        $finish;
    end

endmodule
