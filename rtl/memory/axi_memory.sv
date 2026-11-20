// =============================================================================
// Module      : axi_memory.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : High-Performance AXI4-Lite SRAM Memory Subsystem.
//               Functions as Unified Instruction and Data Memory for program storage,
//               sensor data staging, and circular log buffers for VeeR EL2 RISC-V core.
//
// Address Space:
//   Base Address : 0x0000_0000
//   End Address  : 0x0000_FFFF (64 KB)
//
// Features:
//   - Pure SRAM (no internal register map)
//   - 16384 x 32-bit words = 64 KB SRAM
//   - 4 separate byte-wide RAM arrays (ram_b0, ram_b1, ram_b2, ram_b3)
//   - Full byte-write strobe masking (wstrb[3:0]) for RISC-V sb, sh, sw instructions
//   - Word address = addr[15:2] (14-bit index into 16384 words)
//   - Low-latency 1-cycle pipelined response
//   - Standard AXI4-Lite OKAY response (bresp=2'b00, rresp=2'b00)
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module axi_memory #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 16384 // 16384 x 32-bit words = 64 KB SRAM
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // AXI4-Lite Slave Interface
    input  wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire                  s_axi_awvalid,
    output reg                   s_axi_awready,

    input  wire [DATA_WIDTH-1:0] s_axi_wdata,
    input  wire [3:0]            s_axi_wstrb,
    input  wire                  s_axi_wvalid,
    output reg                   s_axi_wready,

    output reg  [1:0]            s_axi_bresp,
    output reg                   s_axi_bvalid,
    input  wire                  s_axi_bready,

    input  wire [ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire                  s_axi_arvalid,
    output reg                   s_axi_arready,

    output reg  [DATA_WIDTH-1:0] s_axi_rdata,
    output reg  [1:0]            s_axi_rresp,
    output reg                   s_axi_rvalid,
    input  wire                  s_axi_rready
);

    // Local address width to address words in RAM
    localparam RAM_ADDR_BITS = $clog2(MEM_DEPTH);

    // Byte-wide RAM arrays for byte-strobe support
    reg [7:0] ram_b0 [0:MEM_DEPTH-1];
    reg [7:0] ram_b1 [0:MEM_DEPTH-1];
    reg [7:0] ram_b2 [0:MEM_DEPTH-1];
    reg [7:0] ram_b3 [0:MEM_DEPTH-1];

    // -------------------------------------------------------------------------
    // AXI4-Lite Write Channel
    // -------------------------------------------------------------------------
    reg [ADDR_WIDTH-1:0] awaddr_latched;
    reg [DATA_WIDTH-1:0] wdata_latched;
    reg [3:0]            wstrb_latched;
    reg                  aw_done;
    reg                  w_done;

    wire [RAM_ADDR_BITS-1:0] wr_word_idx = awaddr_latched[RAM_ADDR_BITS+1:2];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready  <= 1'b0;
            s_axi_wready   <= 1'b0;
            s_axi_bvalid   <= 1'b0;
            s_axi_bresp    <= 2'b00;
            aw_done        <= 1'b0;
            w_done         <= 1'b0;
            awaddr_latched <= {ADDR_WIDTH{1'b0}};
            wdata_latched  <= {DATA_WIDTH{1'b0}};
            wstrb_latched  <= 4'b0000;
        end else begin
            // Address handshake
            if (s_axi_awvalid && !aw_done) begin
                s_axi_awready  <= 1'b1;
                awaddr_latched <= s_axi_awaddr;
                aw_done        <= 1'b1;
            end else begin
                s_axi_awready  <= 1'b0;
            end

            // Data handshake
            if (s_axi_wvalid && !w_done) begin
                s_axi_wready  <= 1'b1;
                wdata_latched <= s_axi_wdata;
                wstrb_latched <= s_axi_wstrb;
                w_done        <= 1'b1;
            end else begin
                s_axi_wready  <= 1'b0;
            end

            // Write to SRAM upon receiving address & data
            if (aw_done && w_done && !s_axi_bvalid) begin
                if (wstrb_latched[0]) ram_b0[wr_word_idx] <= wdata_latched[7:0];
                if (wstrb_latched[1]) ram_b1[wr_word_idx] <= wdata_latched[15:8];
                if (wstrb_latched[2]) ram_b2[wr_word_idx] <= wdata_latched[23:16];
                if (wstrb_latched[3]) ram_b3[wr_word_idx] <= wdata_latched[31:24];

                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00; // OKAY
            end

            // Response completion handshake
            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
                aw_done      <= 1'b0;
                w_done       <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // AXI4-Lite Read Channel
    // -------------------------------------------------------------------------
    wire [RAM_ADDR_BITS-1:0] rd_word_idx = s_axi_araddr[RAM_ADDR_BITS+1:2];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_arready <= 1'b0;
            s_axi_rvalid  <= 1'b0;
            s_axi_rdata   <= {DATA_WIDTH{1'b0}};
            s_axi_rresp   <= 2'b00;
        end else begin
            if (s_axi_arvalid && !s_axi_rvalid) begin
                s_axi_arready <= 1'b1;
                s_axi_rvalid  <= 1'b1;
                s_axi_rresp   <= 2'b00; // OKAY
                s_axi_rdata   <= {ram_b3[rd_word_idx], ram_b2[rd_word_idx],
                                  ram_b1[rd_word_idx], ram_b0[rd_word_idx]};
            end else begin
                s_axi_arready <= 1'b0;
            end

            // Response completion handshake
            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule
`default_nettype wire
