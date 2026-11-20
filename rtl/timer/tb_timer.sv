// =============================================================================
// Testbench   : tb_timer.sv
// DUT         : timer.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Verification of System Interval Timer IP with prescaler and IRQ.
// =============================================================================

`timescale 1ns / 1ps

module tb_timer;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    localparam TIMER_BASE        = 32'h4000_4000;
    localparam REG_TIMER_CTRL    = TIMER_BASE + 32'h00;
    localparam REG_TIMER_COUNT   = TIMER_BASE + 32'h04;
    localparam REG_TIMER_COMP    = TIMER_BASE + 32'h08;
    localparam REG_TIMER_PRESC   = TIMER_BASE + 32'h0C;
    localparam REG_TIMER_STATUS  = TIMER_BASE + 32'h10;
    localparam REG_TIMER_IRQ_EN  = TIMER_BASE + 32'h14;

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

    wire                   sample_tick;
    wire                   irq_timer;

    integer test_errors = 0;
    integer test_passes = 0;

    timer #(
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
        .sample_tick  (sample_tick),
        .irq_timer    (irq_timer)
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
        $display("=== STARTING TIMER IP VERIFICATION ===");
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

        // Test 1: Configure Countdown Timer with Compare=20, auto-reload, prescaler=0
        $display("[TEST 1] Configure Countdown Timer (Compare=20, Prescaler=0)...");
        axi_write(REG_TIMER_COMP, 32'd20);
        axi_write(REG_TIMER_COUNT, 32'd20);
        axi_write(REG_TIMER_PRESC, 32'd0);
        axi_write(REG_TIMER_IRQ_EN, 32'd1); // Enable TICK_IE
        axi_write(REG_TIMER_CTRL, 32'h03);  // EN=1, AUTO_RELOAD=1, COUNT_UP=0

        // Wait for sample_tick pulse
        wait(sample_tick == 1'b1);
        $display("  [PASS] sample_tick pulse received from Timer!");
        test_passes = test_passes + 1;

        // Verify status TICK flag and IRQ assertion
        #(CLK_PERIOD * 2);
        if (irq_timer == 1'b1) begin
            $display("  [PASS] irq_timer level interrupt asserted");
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] irq_timer not asserted!");
            test_errors = test_errors + 1;
        end

        // Clear TICK status flag via W1C
        axi_write(REG_TIMER_STATUS, 32'h01);
        #(CLK_PERIOD * 2);
        axi_read(REG_TIMER_STATUS, rdata);
        if (rdata[0] == 1'b0) begin
            $display("  [PASS] STATUS TICK flag cleared via W1C");
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] STATUS TICK flag did not clear!");
            test_errors = test_errors + 1;
        end

        $display("=== TIMER TESTBENCH COMPLETED: %0d PASSED, %0d FAILED ===", test_passes, test_errors);
        $finish;
    end

endmodule
