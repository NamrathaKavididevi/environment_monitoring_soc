// =============================================================================
// Testbench   : tb_pwm_generator.sv
// DUT         : pwm_generator.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Comprehensive verification of AXI4-Lite PWM Generator IP.
// =============================================================================

`timescale 1ns / 1ps

module tb_pwm_generator;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    localparam PWM_BASE        = 32'h4000_A000;
    localparam REG_PWM_CONTROL = PWM_BASE + 32'h00;
    localparam REG_PWM_PERIOD  = PWM_BASE + 32'h04;
    localparam REG_PWM_DUTY    = PWM_BASE + 32'h08;
    localparam REG_PWM_COUNTER = PWM_BASE + 32'h0C;
    localparam REG_PWM_STATUS  = PWM_BASE + 32'h10;
    localparam REG_PWM_IRQ_EN  = PWM_BASE + 32'h14;

    logic                  clk;
    logic                  rst_n;

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

    wire                   pwm_out;
    wire                   irq_pwm;

    integer test_errors = 0;
    integer test_passes = 0;

    pwm_generator #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
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
        .pwm_out      (pwm_out),
        .irq_pwm      (irq_pwm)
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
    integer high_count;

    initial begin
        $display("=== STARTING PWM GENERATOR IP VERIFICATION ===");
        rst_n         = 0;
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

        // Test 1: Configure Period=100, Duty=25 (25% Duty Cycle)
        $display("[TEST 1] Configure PWM 25% Duty Cycle (Period=100, Duty=25)...");
        axi_write(REG_PWM_PERIOD, 32'd100);
        axi_write(REG_PWM_DUTY, 32'd25);
        axi_write(REG_PWM_IRQ_EN, 32'd1); // Enable cycle complete interrupt
        axi_write(REG_PWM_CONTROL, 32'h01); // EN=1, POLARITY=0

        // Measure duty cycle
        while (pwm_out == 1'b1) @(posedge clk);
        while (pwm_out == 1'b0) @(posedge clk);
        high_count = 0;
        while (pwm_out == 1'b1) begin
            high_count = high_count + 1;
            @(posedge clk);
        end
        if (high_count == 25) begin
            $display("  [PASS] Measured High Duration: %0d clocks (Expected 25)", high_count);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] Measured High Duration: %0d clocks (Expected 25)", high_count);
            test_errors = test_errors + 1;
        end

        // Wait for cycle complete interrupt
        #(CLK_PERIOD * 100);
        axi_read(REG_PWM_STATUS, rdata);
        if (rdata[1] == 1'b1) begin
            $display("  [PASS] Cycle Complete Status Flag asserted: 0x%08h", rdata);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] Cycle Complete Status Flag not asserted: 0x%08h", rdata);
            test_errors = test_errors + 1;
        end

        // Test 2: Inverted Polarity Test
        $display("[TEST 2] Inverted Polarity Test (POLARITY=1)...");
        axi_write(REG_PWM_CONTROL, 32'h03); // EN=1, POLARITY=1
        #(CLK_PERIOD * 5);
        axi_read(REG_PWM_CONTROL, rdata);
        if (rdata[1:0] == 2'b11) begin
            $display("  [PASS] Control Register Verified with Inversion: 0x%08h", rdata);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] Control Register mismatch: 0x%08h", rdata);
            test_errors = test_errors + 1;
        end

        $display("=== PWM TESTBENCH COMPLETED: %0d PASSED, %0d FAILED ===", test_passes, test_errors);
        $finish;
    end

endmodule
