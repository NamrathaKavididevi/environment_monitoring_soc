// =============================================================================
// Testbench   : tb_axi_interconnect.sv
// DUT         : axi_interconnect.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Verification of 1-Master to 7-Slave AXI4-Lite Interconnect with DECERR.
// =============================================================================

`timescale 1ns / 1ps

module tb_axi_interconnect;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
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

    // Master interfaces M0..M6
    `define DECLARE_MASTER(idx) \
        wire [ADDR_WIDTH-1:0] m``idx``_axi_awaddr; \
        wire                  m``idx``_axi_awvalid; \
        reg                   m``idx``_axi_awready; \
        wire [DATA_WIDTH-1:0] m``idx``_axi_wdata; \
        wire [3:0]            m``idx``_axi_wstrb; \
        wire                  m``idx``_axi_wvalid; \
        reg                   m``idx``_axi_wready; \
        reg  [1:0]            m``idx``_axi_bresp; \
        reg                   m``idx``_axi_bvalid; \
        wire                  m``idx``_axi_bready; \
        wire [ADDR_WIDTH-1:0] m``idx``_axi_araddr; \
        wire                  m``idx``_axi_arvalid; \
        reg                   m``idx``_axi_arready; \
        reg  [DATA_WIDTH-1:0] m``idx``_axi_rdata; \
        reg  [1:0]            m``idx``_axi_rresp; \
        reg                   m``idx``_axi_rvalid; \
        wire                  m``idx``_axi_rready;

    `DECLARE_MASTER(0)
    `DECLARE_MASTER(1)
    `DECLARE_MASTER(2)
    `DECLARE_MASTER(3)
    `DECLARE_MASTER(4)
    `DECLARE_MASTER(5)
    `DECLARE_MASTER(6)

    integer test_errors = 0;
    integer test_passes = 0;

    axi_interconnect #(
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

        // M0..M6 connections
        `define CONNECT_MASTER(idx) \
            .m``idx``_axi_awaddr (m``idx``_axi_awaddr), \
            .m``idx``_axi_awvalid(m``idx``_axi_awvalid), \
            .m``idx``_axi_awready(m``idx``_axi_awready), \
            .m``idx``_axi_wdata  (m``idx``_axi_wdata), \
            .m``idx``_axi_wstrb  (m``idx``_axi_wstrb), \
            .m``idx``_axi_wvalid (m``idx``_axi_wvalid), \
            .m``idx``_axi_wready (m``idx``_axi_wready), \
            .m``idx``_axi_bresp  (m``idx``_axi_bresp), \
            .m``idx``_axi_bvalid (m``idx``_axi_bvalid), \
            .m``idx``_axi_bready (m``idx``_axi_bready), \
            .m``idx``_axi_araddr (m``idx``_axi_araddr), \
            .m``idx``_axi_arvalid(m``idx``_axi_arvalid), \
            .m``idx``_axi_arready(m``idx``_axi_arready), \
            .m``idx``_axi_rdata  (m``idx``_axi_rdata), \
            .m``idx``_axi_rresp  (m``idx``_axi_rresp), \
            .m``idx``_axi_rvalid (m``idx``_axi_rvalid), \
            .m``idx``_axi_rready (m``idx``_axi_rready)

        `CONNECT_MASTER(0),
        `CONNECT_MASTER(1),
        `CONNECT_MASTER(2),
        `CONNECT_MASTER(3),
        `CONNECT_MASTER(4),
        `CONNECT_MASTER(5),
        `CONNECT_MASTER(6)
    );

    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Simple responder for all masters
    `define RESPONDER(idx, exp_data) \
        always @(posedge clk or negedge rst_n) begin \
            if (!rst_n) begin \
                m``idx``_axi_awready <= 1'b0; \
                m``idx``_axi_wready  <= 1'b0; \
                m``idx``_axi_bvalid  <= 1'b0; \
                m``idx``_axi_bresp   <= 2'b00; \
                m``idx``_axi_arready <= 1'b0; \
                m``idx``_axi_rvalid  <= 1'b0; \
                m``idx``_axi_rdata   <= 32'd0; \
                m``idx``_axi_rresp   <= 2'b00; \
            end else begin \
                m``idx``_axi_awready <= m``idx``_axi_awvalid; \
                m``idx``_axi_wready  <= m``idx``_axi_wvalid; \
                if (m``idx``_axi_wvalid && m``idx``_axi_wready) begin \
                    m``idx``_axi_bvalid <= 1'b1; \
                    m``idx``_axi_bresp  <= 2'b00; \
                end else if (m``idx``_axi_bready) begin \
                    m``idx``_axi_bvalid <= 1'b0; \
                end \
                m``idx``_axi_arready <= m``idx``_axi_arvalid; \
                if (m``idx``_axi_arvalid && m``idx``_axi_arready) begin \
                    m``idx``_axi_rvalid <= 1'b1; \
                    m``idx``_axi_rdata  <= exp_data; \
                    m``idx``_axi_rresp  <= 2'b00; \
                end else if (m``idx``_axi_rready) begin \
                    m``idx``_axi_rvalid <= 1'b0; \
                end \
            end \
        end

    `RESPONDER(0, 32'hAAAA_0000)
    `RESPONDER(1, 32'hBBBB_0001)
    `RESPONDER(2, 32'hCCCC_0002)
    `RESPONDER(3, 32'hDDDD_0003)
    `RESPONDER(4, 32'hEEEE_0004)
    `RESPONDER(5, 32'hFFFF_0005)
    `RESPONDER(6, 32'h1111_0006)

    task automatic axi_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data, output [1:0] resp);
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
            resp = s_axi_rresp;
            @(posedge clk);
            s_axi_rready <= 1'b0;
        end
    endtask

    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0] rresp;

    initial begin
        $display("=== STARTING 1-TO-7 AXI CROSSBAR INTERCONNECT VERIFICATION ===");
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

        // Verify routing to S0 (Memory at 0x0000_0000)
        axi_read(32'h0000_0100, rdata, rresp);
        if (rdata == 32'hAAAA_0000 && rresp == 2'b00) begin
            $display("  [PASS] S0 Unified Memory route verified: 0x%08h", rdata);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] S0 Memory route failed!");
            test_errors = test_errors + 1;
        end

        // Verify routing to S1 (UART at 0x4000_0000)
        axi_read(32'h4000_0004, rdata, rresp);
        if (rdata == 32'hBBBB_0001 && rresp == 2'b00) begin
            $display("  [PASS] S1 UART route verified: 0x%08h", rdata);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] S1 UART route failed!");
            test_errors = test_errors + 1;
        end

        // Verify routing to S6 (PWM at 0x4000_A000)
        axi_read(32'h4000_A004, rdata, rresp);
        if (rdata == 32'h1111_0006 && rresp == 2'b00) begin
            $display("  [PASS] S6 PWM route verified: 0x%08h", rdata);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] S6 PWM route failed!");
            test_errors = test_errors + 1;
        end

        // Verify DECERR on 0x4000_C000 (Previously 7-seg, now unmapped space)
        axi_read(32'h4000_C000, rdata, rresp);
        if (rresp == 2'b11) begin
            $display("  [PASS] DECERR successfully generated for 0x4000_C000 (rresp=2'b11)");
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] DECERR not generated for 0x4000_C000! Got rresp=%b", rresp);
            test_errors = test_errors + 1;
        end

        // Verify DECERR on unmapped space (0x8000_0000)
        axi_read(32'h8000_0000, rdata, rresp);
        if (rresp == 2'b11) begin
            $display("  [PASS] DECERR successfully generated for unmapped address (rresp=2'b11)");
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] DECERR not generated for unmapped address! Got rresp=%b", rresp);
            test_errors = test_errors + 1;
        end

        $display("=== INTERCONNECT TESTBENCH COMPLETED: %0d PASSED, %0d FAILED ===", test_passes, test_errors);
        $finish;
    end

endmodule
