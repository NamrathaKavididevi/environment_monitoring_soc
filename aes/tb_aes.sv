// =============================================================================
// Testbench   : tb_aes.sv
// DUT         : aes.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Self-checking AES-128 verification TB using FIPS 197 Appendix B
//               test vector:
//               Key     : 2b7e151628aed2a6abf7158809cf4f3c
//               Plaintext: 3243f6a8885a308d313198a2e0370734
//               Expected : 3925841d02dc09fbdc118597196a0b32
// =============================================================================

`timescale 1ns / 1ps

module tb_aes;

    localparam CLK_PERIOD = 10;
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam AES_BASE   = 32'h4000_C000;

    // --- FIPS 197 Appendix B test vector ---
    localparam [127:0] TEST_KEY = 128'h2b7e151628aed2a6abf7158809cf4f3c;
    localparam [127:0] TEST_PT  = 128'h3243f6a8885a308d313198a2e0370734;
    localparam [127:0] EXPECTED = 128'h3925841d02dc09fbdc118597196a0b32;

    integer pass_count = 0;
    integer fail_count = 0;

    // -------------------------------------------------------------------------
    // DUT I/O
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------------------------
    aes dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .s_axi_awaddr  (s_axi_awaddr),
        .s_axi_awvalid (s_axi_awvalid),
        .s_axi_awready (s_axi_awready),
        .s_axi_wdata   (s_axi_wdata),
        .s_axi_wstrb   (s_axi_wstrb),
        .s_axi_wvalid  (s_axi_wvalid),
        .s_axi_wready  (s_axi_wready),
        .s_axi_bresp   (s_axi_bresp),
        .s_axi_bvalid  (s_axi_bvalid),
        .s_axi_bready  (s_axi_bready),
        .s_axi_araddr  (s_axi_araddr),
        .s_axi_arvalid (s_axi_arvalid),
        .s_axi_arready (s_axi_arready),
        .s_axi_rdata   (s_axi_rdata),
        .s_axi_rresp   (s_axi_rresp),
        .s_axi_rvalid  (s_axi_rvalid),
        .s_axi_rready  (s_axi_rready)
    );

    // -------------------------------------------------------------------------
    // Clock generation
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // -------------------------------------------------------------------------
    // VCD Dump handled by TCL
    // -------------------------------------------------------------------------

    // -------------------------------------------------------------------------
    // AXI Write Task
    // -------------------------------------------------------------------------
    task axi_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            s_axi_awaddr  <= addr;
            s_axi_awvalid <= 1'b1;
            s_axi_wdata   <= data;
            s_axi_wstrb   <= 4'hF;
            s_axi_wvalid  <= 1'b1;
            s_axi_bready  <= 1'b1;
            @(posedge clk);
            wait(s_axi_awready && s_axi_wready);
            @(posedge clk);
            s_axi_awvalid <= 1'b0;
            s_axi_wvalid  <= 1'b0;
            wait(s_axi_bvalid);
            @(posedge clk);
            s_axi_bready  <= 1'b0;
        end
    endtask

    // -------------------------------------------------------------------------
    // AXI Read Task
    // -------------------------------------------------------------------------
    task axi_read(input [31:0] addr, output [31:0] data);
        begin
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
            s_axi_rready  <= 1'b0;
        end
    endtask

    // -------------------------------------------------------------------------
    // Check Task
    // -------------------------------------------------------------------------
    task check(input [127:0] got, input [127:0] exp, input [80*8:1] label);
        if (got === exp) begin
            $display("  PASS: %s = %h (expected %h)", label, got, exp);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: %s = %h (expected %h)", label, got, exp);
            fail_count = fail_count + 1;
        end
    endtask

    // -------------------------------------------------------------------------
    // Stimulus
    // -------------------------------------------------------------------------
    reg [31:0] rd_data;
    reg [127:0] ct_read;
    integer poll;

    initial begin
        // Initialise bus
        s_axi_awaddr  = '0; s_axi_awvalid = 0;
        s_axi_wdata   = '0; s_axi_wstrb   = '0; s_axi_wvalid = 0;
        s_axi_bready  = 0;
        s_axi_araddr  = '0; s_axi_arvalid = 0;
        s_axi_rready  = 0;
        rst_n = 0;
        repeat(4) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);

        $display("=== AES-128 Encryption Test (FIPS 197 Appendix B) ===");
        $display("  Key       : %h", TEST_KEY);
        $display("  Plaintext : %h", TEST_PT);

        // ---- Program 128-bit key (4 x 32-bit, MSW first) ----
        $display("[%0t] Programming key...", $time);
        axi_write(AES_BASE + 32'h08, TEST_KEY[127:96]);
        axi_write(AES_BASE + 32'h0C, TEST_KEY[95:64]);
        axi_write(AES_BASE + 32'h10, TEST_KEY[63:32]);
        axi_write(AES_BASE + 32'h14, TEST_KEY[31:0]);

        // ---- Program 128-bit plaintext ----
        $display("[%0t] Programming plaintext...", $time);
        axi_write(AES_BASE + 32'h18, TEST_PT[127:96]);
        axi_write(AES_BASE + 32'h1C, TEST_PT[95:64]);
        axi_write(AES_BASE + 32'h20, TEST_PT[63:32]);
        axi_write(AES_BASE + 32'h24, TEST_PT[31:0]);

        // ---- Trigger START ----
        $display("[%0t] Asserting START...", $time);
        axi_write(AES_BASE + 32'h00, 32'h1);

        // ---- Poll STATUS until VALID_OUT (bit 1) ----
        $display("[%0t] Waiting for VALID_OUT...", $time);
        poll = 0;
        rd_data = 0;
        while (!rd_data[1] && poll < 100) begin
            axi_read(AES_BASE + 32'h04, rd_data);
            poll = poll + 1;
            @(posedge clk);
        end
        $display("[%0t] VALID_OUT asserted after %0d polls", $time, poll);

        // ---- Read 128-bit ciphertext ----
        axi_read(AES_BASE + 32'h28, rd_data); ct_read[127:96] = rd_data;
        axi_read(AES_BASE + 32'h2C, rd_data); ct_read[95:64]  = rd_data;
        axi_read(AES_BASE + 32'h30, rd_data); ct_read[63:32]  = rd_data;
        axi_read(AES_BASE + 32'h34, rd_data); ct_read[31:0]   = rd_data;

        $display("[%0t] Ciphertext read: %h", $time, ct_read);
        $display("[%0t] Expected       : %h", $time, EXPECTED);

        // ---- Verify ----
        check(ct_read, EXPECTED, "AES-128 Ciphertext (FIPS 197 App-B)");

        repeat(5) @(posedge clk);

        $display("=== Test Summary: %0d PASS / %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL CHECKS PASSED");
        else
            $display("SOME CHECKS FAILED");

        $finish;
    end

    // ---- Timeout watchdog ----
    initial begin
        #500000;
        $display("TIMEOUT: simulation exceeded 500 us");
        $finish;
    end

endmodule
