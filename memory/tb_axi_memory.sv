// =============================================================================
// Testbench   : tb_axi_memory.sv
// DUT         : axi_memory.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Verification of Unified AXI4-Lite SRAM Memory Subsystem (0x0000_0000).
//               Verifies 32-bit word, 16-bit halfword, and 8-bit byte writes (RISC-V sw, sh, sb).
// =============================================================================

`timescale 1ns / 1ps

module tb_axi_memory;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam MEM_DEPTH  = 256; // Fast simulation depth
    localparam CLK_PERIOD = 10;

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

    integer test_errors = 0;
    integer test_passes = 0;

    axi_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH (MEM_DEPTH)
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
        .s_axi_rready (s_axi_rready)
    );

    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    task automatic axi_write(
        input [ADDR_WIDTH-1:0] addr,
        input [DATA_WIDTH-1:0] data,
        input [3:0]            strb
    );
        begin
            @(posedge clk);
            s_axi_awaddr  <= addr;
            s_axi_awvalid <= 1'b1;
            s_axi_wdata   <= data;
            s_axi_wstrb   <= strb;
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

    task automatic axi_read(
        input  [ADDR_WIDTH-1:0] addr,
        output [DATA_WIDTH-1:0] data
    );
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

    logic [DATA_WIDTH-1:0] rd_val;

    initial begin
        $display("=== STARTING UNIFIED SRAM MEMORY VERIFICATION (0x0000_0000) ===");
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

        // Test 1: Full word write and readback at base 0x0000_0000
        $display("[TEST 1] Full 32-bit Word Write and Readback (sw / lw)...");
        axi_write(32'h0000_0000, 32'hDEAD_BEEF, 4'b1111);
        axi_read(32'h0000_0000, rd_val);
        if (rd_val === 32'hDEAD_BEEF) begin
            $display("  [PASS] Read 0x00000000: Expected 0xDEADBEEF, Got 0x%08h", rd_val);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] Read 0x00000000: Expected 0xDEADBEEF, Got 0x%08h", rd_val);
            test_errors = test_errors + 1;
        end

        // Test 2: Byte-selective write testing (RISC-V 'sb' store byte)
        $display("[TEST 2] RISC-V Store Byte (sb) Emulation via Byte Strobes...");
        // Modify byte 0 (lowest byte: EF -> AA)
        axi_write(32'h0000_0000, 32'h0000_00AA, 4'b0001);
        axi_read(32'h0000_0000, rd_val);
        if (rd_val === 32'hDEAD_BEAA) begin
            $display("  [PASS] Byte 0 modified: 0xDEADBEAA", rd_val);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] Byte 0 modification failed: Got 0x%08h", rd_val);
            test_errors = test_errors + 1;
        end

        // Test 3: Halfword write testing (RISC-V 'sh' store halfword)
        $display("[TEST 3] RISC-V Store Halfword (sh) Emulation...");
        // Modify upper halfword (DEAD -> CAFE)
        axi_write(32'h0000_0000, 32'hCAFE_0000, 4'b1100);
        axi_read(32'h0000_0000, rd_val);
        if (rd_val === 32'hCAFE_BEAA) begin
            $display("  [PASS] Upper halfword modified: 0xCAFEBEAA", rd_val);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] Upper halfword modification failed: Got 0x%08h", rd_val);
            test_errors = test_errors + 1;
        end

        $display("=== MEMORY TESTBENCH COMPLETED: %0d PASSED, %0d FAILED ===", test_passes, test_errors);
        $finish;
    end

endmodule
