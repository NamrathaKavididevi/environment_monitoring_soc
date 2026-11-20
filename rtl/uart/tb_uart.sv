// =============================================================================
// Testbench   : tb_uart.sv
// DUT         : uart.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Self-checking verification testbench for AXI4-Lite UART IP.
//               Verifies register read/write, serial loopback transmit/receive,
//               mid-bit sampling, status flags, and write-1-to-clear interrupts.
// =============================================================================

`timescale 1ns / 1ps

module tb_uart;

    localparam CLK_PERIOD = 10; // 100 MHz clock
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    // Base address and register offsets
    localparam UART_BASE       = 32'h4000_0000;
    localparam REG_DATA        = UART_BASE + 32'h00;
    localparam REG_STATUS      = UART_BASE + 32'h04;
    localparam REG_CONTROL     = UART_BASE + 32'h08;
    localparam REG_BAUD_DIV    = UART_BASE + 32'h0C;
    localparam REG_IRQ_ENABLE  = UART_BASE + 32'h10;
    localparam REG_IRQ_STATUS  = UART_BASE + 32'h14;

    // Test tracking counters
    integer pass_count = 0;
    integer fail_count = 0;

    // Clock and reset
    logic                  clk;
    logic                  rst_n;

    // AXI4-Lite Slave Signals
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

    // Physical UART Pins
    wire                   uart_tx;
    wire                   uart_rx;
    wire                   irq_uart;

    // Direct loopback wire
    assign uart_rx = uart_tx;

    // Instantiate DUT
    uart #(
        .ADDR_WIDTH      (ADDR_WIDTH),
        .DATA_WIDTH      (DATA_WIDTH),
        .DEFAULT_BAUD_DIV(16'd4)
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
        .uart_rx      (uart_rx),
        .uart_tx      (uart_tx),
        .irq_uart     (irq_uart)
    );

    // 100 MHz clock generation
    always #(CLK_PERIOD / 2) clk = ~clk;

    // -------------------------------------------------------------------------
    // AXI4-Lite Write Task
    // -------------------------------------------------------------------------
    task axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        @(posedge clk);
        s_axi_awaddr  <= addr;
        s_axi_awvalid <= 1'b1;
        s_axi_wdata   <= data;
        s_axi_wstrb   <= 4'hF;
        s_axi_wvalid  <= 1'b1;
        s_axi_bready  <= 1'b1;

        fork
            begin
                wait(s_axi_awready);
                @(posedge clk);
                s_axi_awvalid <= 1'b0;
            end
            begin
                wait(s_axi_wready);
                @(posedge clk);
                s_axi_wvalid <= 1'b0;
            end
        join

        wait(s_axi_bvalid);
        @(posedge clk);
        s_axi_bready <= 1'b0;
    endtask

    // -------------------------------------------------------------------------
    // AXI4-Lite Read Task
    // -------------------------------------------------------------------------
    task axi_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
        @(posedge clk);
        s_axi_araddr  <= addr;
        s_axi_arvalid <= 1'b1;
        s_axi_rready  <= 1'b1;

        wait(s_axi_arready);
        @(posedge clk);
        s_axi_arvalid <= 1'b0;

        wait(s_axi_rvalid);
        data = s_axi_rdata;
        @(posedge clk);
        s_axi_rready <= 1'b0;
    endtask

    // -------------------------------------------------------------------------
    // Verification Procedure
    // -------------------------------------------------------------------------
    initial begin
        logic [DATA_WIDTH-1:0] rdata;

        $display("==========================================================");
        $display(" Starting UART IP Verification (tb_uart)");
        $display("==========================================================");

        // Initialize signals
        clk           = 0;
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

        // Apply reset
        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 5);

        // ---------------------------------------------------------------------
        // Test 1: Verify Initial Defaults upon Reset
        // ---------------------------------------------------------------------
        $display("\n--- Test 1: Check Reset Defaults ---");
        axi_read(REG_STATUS, rdata);
        if (rdata[1] == 1'b1 && rdata[0] == 1'b0 && rdata[2] == 1'b0) begin
            $display("[PASS] Test 1A: STATUS register default verified (TX_EMPTY=1, TX_BUSY=0, RX_VALID=0).");
            pass_count++;
        end else begin
            $display("[FAIL] Test 1A: STATUS register default unexpected! Got 0x%08X", rdata);
            fail_count++;
        end

        axi_read(REG_IRQ_STATUS, rdata);
        if (rdata[1:0] == 2'b00 && irq_uart == 1'b0) begin
            $display("[PASS] Test 1B: IRQ_STATUS is 0x00 and irq_uart is 0 on reset.");
            pass_count++;
        end else begin
            $display("[FAIL] Test 1B: IRQ_STATUS or irq_uart non-zero after reset! Got 0x%08X, irq=%b", rdata, irq_uart);
            fail_count++;
        end

        // ---------------------------------------------------------------------
        // Test 2: Set BAUD_DIV for Fast Simulation (divisor = 4)
        // ---------------------------------------------------------------------
        $display("\n--- Test 2: Configure BAUD_DIV ---");
        axi_write(REG_BAUD_DIV, 32'd4);
        axi_read(REG_BAUD_DIV, rdata);
        if (rdata[15:0] == 16'd4) begin
            $display("[PASS] Test 2: BAUD_DIV set to 4 successfully.");
            pass_count++;
        end else begin
            $display("[FAIL] Test 2: BAUD_DIV mismatch! Expected 4, got %0d", rdata[15:0]);
            fail_count++;
        end

        // ---------------------------------------------------------------------
        // Test 3: Write CONTROL to Enable TX and RX
        // ---------------------------------------------------------------------
        $display("\n--- Test 3: Configure CONTROL (TX_EN=1, RX_EN=1) ---");
        axi_write(REG_CONTROL, 32'h03);
        axi_read(REG_CONTROL, rdata);
        if (rdata[1:0] == 2'b11) begin
            $display("[PASS] Test 3: CONTROL register configured (TX_EN=1, RX_EN=1).");
            pass_count++;
        end else begin
            $display("[FAIL] Test 3: CONTROL register mismatch! Expected 0x03, got 0x%02X", rdata[1:0]);
            fail_count++;
        end

        // ---------------------------------------------------------------------
        // Test 4: Write IRQ_ENABLE to Enable Both Interrupts
        // ---------------------------------------------------------------------
        $display("\n--- Test 4: Configure IRQ_ENABLE (TX_EMPTY_IE=1, RX_VALID_IE=1) ---");
        axi_write(REG_IRQ_ENABLE, 32'h03);
        axi_read(REG_IRQ_ENABLE, rdata);
        if (rdata[1:0] == 2'b11) begin
            $display("[PASS] Test 4: IRQ_ENABLE configured (TX_EMPTY_IE=1, RX_VALID_IE=1).");
            pass_count++;
        end else begin
            $display("[FAIL] Test 4: IRQ_ENABLE mismatch! Expected 0x03, got 0x%02X", rdata[1:0]);
            fail_count++;
        end

        // ---------------------------------------------------------------------
        // Test 5: Transmit Byte 0xA5 and Verify Loopback
        // ---------------------------------------------------------------------
        $display("\n--- Test 5: Transmit Byte 0xA5 over Loopback ---");
        axi_write(REG_DATA, 32'hA5);

        // Wait for transmission and reception (irq_uart or RX_VALID)
        wait(irq_uart == 1'b1);
        #(CLK_PERIOD * 2);
        $display("[PASS] Test 5A: Interrupt irq_uart asserted upon transaction completion.");
        pass_count++;

        // ---------------------------------------------------------------------
        // Test 6: Read STATUS and Verify RX_VALID
        // ---------------------------------------------------------------------
        $display("\n--- Test 6: Verify STATUS RX_VALID ---");
        axi_read(REG_STATUS, rdata);
        if (rdata[2] == 1'b1 && rdata[0] == 1'b0) begin
            $display("[PASS] Test 6: STATUS verified (RX_VALID=1, TX_BUSY=0).");
            pass_count++;
        end else begin
            $display("[FAIL] Test 6: STATUS unexpected! Expected RX_VALID=1, got 0x%08X", rdata);
            fail_count++;
        end

        // ---------------------------------------------------------------------
        // Test 7: Read DATA and Verify Received Byte Matches Sent Byte
        // ---------------------------------------------------------------------
        $display("\n--- Test 7: Read DATA and Verify Byte 0xA5 ---");
        axi_read(REG_DATA, rdata);
        if (rdata[7:0] == 8'hA5) begin
            $display("[PASS] Test 7: Received byte matches sent byte (0xA5).");
            pass_count++;
        end else begin
            $display("[FAIL] Test 7: Received byte mismatch! Expected 0xA5, got 0x%02X", rdata[7:0]);
            fail_count++;
        end

        // Verify pop cleared RX_VALID in STATUS
        axi_read(REG_STATUS, rdata);
        if (rdata[2] == 1'b0) begin
            $display("[PASS] Test 7B: Reading DATA popped RX byte (RX_VALID=0).");
            pass_count++;
        end else begin
            $display("[FAIL] Test 7B: RX_VALID should be cleared after reading DATA! Got 0x%08X", rdata);
            fail_count++;
        end

        // ---------------------------------------------------------------------
        // Test 8: Read IRQ_STATUS and Verify Interrupt Flags
        // ---------------------------------------------------------------------
        $display("\n--- Test 8: Verify IRQ_STATUS Flags ---");
        axi_read(REG_IRQ_STATUS, rdata);
        if (rdata[0] == 1'b1 && rdata[1] == 1'b1) begin
            $display("[PASS] Test 8: IRQ_STATUS flags verified (TX_EMPTY_IRQ=1, RX_VALID_IRQ=1).");
            pass_count++;
        end else begin
            $display("[FAIL] Test 8: IRQ_STATUS mismatch! Expected 0x03, got 0x%02X", rdata[1:0]);
            fail_count++;
        end

        // ---------------------------------------------------------------------
        // Test 9: Write IRQ_STATUS to Clear Flags (W1C) and Verify
        // ---------------------------------------------------------------------
        $display("\n--- Test 9: Clear IRQ_STATUS via W1C and Verify ---");
        axi_write(REG_IRQ_STATUS, 32'h03);
        axi_read(REG_IRQ_STATUS, rdata);
        if (rdata[1:0] == 2'b00 && irq_uart == 1'b0) begin
            $display("[PASS] Test 9: IRQ_STATUS flags cleared successfully, irq_uart deasserted.");
            pass_count++;
        end else begin
            $display("[FAIL] Test 9: IRQ_STATUS not cleared! Got 0x%02X, irq_uart=%b", rdata[1:0], irq_uart);
            fail_count++;
        end

        // ---------------------------------------------------------------------
        // Test 10: Sequential Multi-Byte Transfers (0x5A, 0x3C, 0xF0)
        // ---------------------------------------------------------------------
        $display("\n--- Test 10: Sequential Multi-Byte Loopback Transfers ---");

        // Send 0x5A
        axi_write(REG_DATA, 32'h5A);
        wait(irq_uart == 1'b1);
        #(CLK_PERIOD * 2);
        axi_read(REG_DATA, rdata);
        if (rdata[7:0] == 8'h5A) begin
            $display("[PASS] Test 10A: Byte 0x5A verified successfully.");
            pass_count++;
        end else begin
            $display("[FAIL] Test 10A: Byte 0x5A mismatch! Got 0x%02X", rdata[7:0]);
            fail_count++;
        end
        axi_write(REG_IRQ_STATUS, 32'h03); // clear IRQ

        // Send 0x3C
        axi_write(REG_DATA, 32'h3C);
        wait(irq_uart == 1'b1);
        #(CLK_PERIOD * 2);
        axi_read(REG_DATA, rdata);
        if (rdata[7:0] == 8'h3C) begin
            $display("[PASS] Test 10B: Byte 0x3C verified successfully.");
            pass_count++;
        end else begin
            $display("[FAIL] Test 10B: Byte 0x3C mismatch! Got 0x%02X", rdata[7:0]);
            fail_count++;
        end
        axi_write(REG_IRQ_STATUS, 32'h03); // clear IRQ

        // Send 0xF0
        axi_write(REG_DATA, 32'hF0);
        wait(irq_uart == 1'b1);
        #(CLK_PERIOD * 2);
        axi_read(REG_DATA, rdata);
        if (rdata[7:0] == 8'hF0) begin
            $display("[PASS] Test 10C: Byte 0xF0 verified successfully.");
            pass_count++;
        end else begin
            $display("[FAIL] Test 10C: Byte 0xF0 mismatch! Got 0x%02X", rdata[7:0]);
            fail_count++;
        end
        axi_write(REG_IRQ_STATUS, 32'h03); // clear IRQ

        // ---------------------------------------------------------------------
        // Final Summary
        // ---------------------------------------------------------------------
        $display("\n==========================================================");
        $display(" UART VERIFICATION SUMMARY");
        $display(" Tests Passed : %0d", pass_count);
        $display(" Tests Failed : %0d", fail_count);
        if (fail_count == 0) begin
            $display(" STATUS       : ALL UART TESTS PASSED SUCCESSFULLY!");
        end else begin
            $display(" STATUS       : UART TESTS FAILED WITH %0d ERRORS!", fail_count);
            $fatal(1, "UART testbench failed!");
        end
        $display("==========================================================");

        $finish;
    end

endmodule
