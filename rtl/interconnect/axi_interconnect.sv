// =============================================================================
// Module      : axi_interconnect.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : High-Performance 1-Master to 7-Slave AXI4-Lite Crossbar Interconnect
//               with built-in DECERR (Decode Error) protection unit for RISC-V VeeR EL2.
//
// Slave Address Map (Configured per System Architecture):
//   S0 (Unified Memory) : 0x0000_0000 - 0x0000_FFFF  (64 KB SRAM)
//   S1 (UART)           : 0x4000_0000 - 0x4000_1FFF  (8 KB Window)
//   S2 (GPIO)           : 0x4000_2000 - 0x4000_3FFF  (8 KB Window)
//   S3 (Timer)          : 0x4000_4000 - 0x4000_5FFF  (8 KB Window)
//   S4 (SPI)            : 0x4000_6000 - 0x4000_7FFF  (8 KB Window)
//   S5 (I2C)            : 0x4000_8000 - 0x4000_9FFF  (8 KB Window)
//   S6 (PWM)            : 0x4000_A000 - 0x4000_BFFF  (8 KB Window)
//   DECERR              : Any unmapped address returns 2'b11 (DECERR)
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module axi_interconnect #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // -------------------------------------------------------------------------
    // Slave Interface (Connected to VeeR EL2 LSU / System Bus via Adapter)
    // -------------------------------------------------------------------------
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
    input  wire                  s_axi_rready,

    // -------------------------------------------------------------------------
    // Master 0: Unified Memory (0x0000_0000 - 0x0000_FFFF)
    // -------------------------------------------------------------------------
    output wire [ADDR_WIDTH-1:0] m0_axi_awaddr,
    output wire                  m0_axi_awvalid,
    input  wire                  m0_axi_awready,
    output wire [DATA_WIDTH-1:0] m0_axi_wdata,
    output wire [3:0]            m0_axi_wstrb,
    output wire                  m0_axi_wvalid,
    input  wire                  m0_axi_wready,
    input  wire [1:0]            m0_axi_bresp,
    input  wire                  m0_axi_bvalid,
    output wire                  m0_axi_bready,
    output wire [ADDR_WIDTH-1:0] m0_axi_araddr,
    output wire                  m0_axi_arvalid,
    input  wire                  m0_axi_arready,
    input  wire [DATA_WIDTH-1:0] m0_axi_rdata,
    input  wire [1:0]            m0_axi_rresp,
    input  wire                  m0_axi_rvalid,
    output wire                  m0_axi_rready,

    // -------------------------------------------------------------------------
    // Master 1: UART (0x4000_0000 - 0x4000_1FFF)
    // -------------------------------------------------------------------------
    output wire [ADDR_WIDTH-1:0] m1_axi_awaddr,
    output wire                  m1_axi_awvalid,
    input  wire                  m1_axi_awready,
    output wire [DATA_WIDTH-1:0] m1_axi_wdata,
    output wire [3:0]            m1_axi_wstrb,
    output wire                  m1_axi_wvalid,
    input  wire                  m1_axi_wready,
    input  wire [1:0]            m1_axi_bresp,
    input  wire                  m1_axi_bvalid,
    output wire                  m1_axi_bready,
    output wire [ADDR_WIDTH-1:0] m1_axi_araddr,
    output wire                  m1_axi_arvalid,
    input  wire                  m1_axi_arready,
    input  wire [DATA_WIDTH-1:0] m1_axi_rdata,
    input  wire [1:0]            m1_axi_rresp,
    input  wire                  m1_axi_rvalid,
    output wire                  m1_axi_rready,

    // -------------------------------------------------------------------------
    // Master 2: GPIO (0x4000_2000 - 0x4000_3FFF)
    // -------------------------------------------------------------------------
    output wire [ADDR_WIDTH-1:0] m2_axi_awaddr,
    output wire                  m2_axi_awvalid,
    input  wire                  m2_axi_awready,
    output wire [DATA_WIDTH-1:0] m2_axi_wdata,
    output wire [3:0]            m2_axi_wstrb,
    output wire                  m2_axi_wvalid,
    input  wire                  m2_axi_wready,
    input  wire [1:0]            m2_axi_bresp,
    input  wire                  m2_axi_bvalid,
    output wire                  m2_axi_bready,
    output wire [ADDR_WIDTH-1:0] m2_axi_araddr,
    output wire                  m2_axi_arvalid,
    input  wire                  m2_axi_arready,
    input  wire [DATA_WIDTH-1:0] m2_axi_rdata,
    input  wire [1:0]            m2_axi_rresp,
    input  wire                  m2_axi_rvalid,
    output wire                  m2_axi_rready,

    // -------------------------------------------------------------------------
    // Master 3: Timer (0x4000_4000 - 0x4000_5FFF)
    // -------------------------------------------------------------------------
    output wire [ADDR_WIDTH-1:0] m3_axi_awaddr,
    output wire                  m3_axi_awvalid,
    input  wire                  m3_axi_awready,
    output wire [DATA_WIDTH-1:0] m3_axi_wdata,
    output wire [3:0]            m3_axi_wstrb,
    output wire                  m3_axi_wvalid,
    input  wire                  m3_axi_wready,
    input  wire [1:0]            m3_axi_bresp,
    input  wire                  m3_axi_bvalid,
    output wire                  m3_axi_bready,
    output wire [ADDR_WIDTH-1:0] m3_axi_araddr,
    output wire                  m3_axi_arvalid,
    input  wire                  m3_axi_arready,
    input  wire [DATA_WIDTH-1:0] m3_axi_rdata,
    input  wire [1:0]            m3_axi_rresp,
    input  wire                  m3_axi_rvalid,
    output wire                  m3_axi_rready,

    // -------------------------------------------------------------------------
    // Master 4: SPI (0x4000_6000 - 0x4000_7FFF)
    // -------------------------------------------------------------------------
    output wire [ADDR_WIDTH-1:0] m4_axi_awaddr,
    output wire                  m4_axi_awvalid,
    input  wire                  m4_axi_awready,
    output wire [DATA_WIDTH-1:0] m4_axi_wdata,
    output wire [3:0]            m4_axi_wstrb,
    output wire                  m4_axi_wvalid,
    input  wire                  m4_axi_wready,
    input  wire [1:0]            m4_axi_bresp,
    input  wire                  m4_axi_bvalid,
    output wire                  m4_axi_bready,
    output wire [ADDR_WIDTH-1:0] m4_axi_araddr,
    output wire                  m4_axi_arvalid,
    input  wire                  m4_axi_arready,
    input  wire [DATA_WIDTH-1:0] m4_axi_rdata,
    input  wire [1:0]            m4_axi_rresp,
    input  wire                  m4_axi_rvalid,
    output wire                  m4_axi_rready,

    // -------------------------------------------------------------------------
    // Master 5: I2C (0x4000_8000 - 0x4000_9FFF)
    // -------------------------------------------------------------------------
    output wire [ADDR_WIDTH-1:0] m5_axi_awaddr,
    output wire                  m5_axi_awvalid,
    input  wire                  m5_axi_awready,
    output wire [DATA_WIDTH-1:0] m5_axi_wdata,
    output wire [3:0]            m5_axi_wstrb,
    output wire                  m5_axi_wvalid,
    input  wire                  m5_axi_wready,
    input  wire [1:0]            m5_axi_bresp,
    input  wire                  m5_axi_bvalid,
    output wire                  m5_axi_bready,
    output wire [ADDR_WIDTH-1:0] m5_axi_araddr,
    output wire                  m5_axi_arvalid,
    input  wire                  m5_axi_arready,
    input  wire [DATA_WIDTH-1:0] m5_axi_rdata,
    input  wire [1:0]            m5_axi_rresp,
    input  wire                  m5_axi_rvalid,
    output wire                  m5_axi_rready,

    // -------------------------------------------------------------------------
    // Master 6: PWM (0x4000_A000 - 0x4000_BFFF)
    // -------------------------------------------------------------------------
    output wire [ADDR_WIDTH-1:0] m6_axi_awaddr,
    output wire                  m6_axi_awvalid,
    input  wire                  m6_axi_awready,
    output wire [DATA_WIDTH-1:0] m6_axi_wdata,
    output wire [3:0]            m6_axi_wstrb,
    output wire                  m6_axi_wvalid,
    input  wire                  m6_axi_wready,
    input  wire [1:0]            m6_axi_bresp,
    input  wire                  m6_axi_bvalid,
    output wire                  m6_axi_bready,
    output wire [ADDR_WIDTH-1:0] m6_axi_araddr,
    output wire                  m6_axi_arvalid,
    input  wire                  m6_axi_arready,
    input  wire [DATA_WIDTH-1:0] m6_axi_rdata,
    input  wire [1:0]            m6_axi_rresp,
    input  wire                  m6_axi_rvalid,
    output wire                  m6_axi_rready
);

    // -------------------------------------------------------------------------
    // Address Decoding Logic
    // -------------------------------------------------------------------------
    function automatic [3:0] decode_addr(input [ADDR_WIDTH-1:0] addr);
        if (addr <= 32'h0000_FFFF) begin
            decode_addr = 4'd0; // S0: Unified Memory (0x0000_0000 - 0x0000_FFFF)
        end else if (addr >= 32'h4000_0000 && addr <= 32'h4000_1FFF) begin
            decode_addr = 4'd1; // S1: UART
        end else if (addr >= 32'h4000_2000 && addr <= 32'h4000_3FFF) begin
            decode_addr = 4'd2; // S2: GPIO
        end else if (addr >= 32'h4000_4000 && addr <= 32'h4000_5FFF) begin
            decode_addr = 4'd3; // S3: Timer
        end else if (addr >= 32'h4000_6000 && addr <= 32'h4000_7FFF) begin
            decode_addr = 4'd4; // S4: SPI
        end else if (addr >= 32'h4000_8000 && addr <= 32'h4000_9FFF) begin
            decode_addr = 4'd5; // S5: I2C
        end else if (addr >= 32'h4000_A000 && addr <= 32'h4000_BFFF) begin
            decode_addr = 4'd6; // S6: PWM
        end else begin
            decode_addr = 4'd7; // DECERR (Unmapped space: 0x4000_C000+ or other)
        end
    endfunction

    // -------------------------------------------------------------------------
    // Write Channel Routing
    // -------------------------------------------------------------------------
    wire [3:0] wr_target = decode_addr(s_axi_awaddr);
    reg  [3:0] wr_target_latched;
    reg        wr_decerr_pending;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_target_latched <= 4'd0;
            wr_decerr_pending <= 1'b0;
        end else begin
            if (s_axi_awvalid && s_axi_awready) begin
                wr_target_latched <= wr_target;
                if (wr_target == 4'd7)
                    wr_decerr_pending <= 1'b1;
            end else if (s_axi_bvalid && s_axi_bready) begin
                wr_decerr_pending <= 1'b0;
            end
        end
    end

    // Forward write addresses and data to selected master
    assign m0_axi_awaddr  = s_axi_awaddr;
    assign m0_axi_awvalid = (wr_target == 4'd0) ? s_axi_awvalid : 1'b0;
    assign m0_axi_wdata   = s_axi_wdata;
    assign m0_axi_wstrb   = s_axi_wstrb;
    assign m0_axi_wvalid  = (wr_target_latched == 4'd0) ? s_axi_wvalid : 1'b0;
    assign m0_axi_bready  = (wr_target_latched == 4'd0) ? s_axi_bready : 1'b0;

    assign m1_axi_awaddr  = s_axi_awaddr;
    assign m1_axi_awvalid = (wr_target == 4'd1) ? s_axi_awvalid : 1'b0;
    assign m1_axi_wdata   = s_axi_wdata;
    assign m1_axi_wstrb   = s_axi_wstrb;
    assign m1_axi_wvalid  = (wr_target_latched == 4'd1) ? s_axi_wvalid : 1'b0;
    assign m1_axi_bready  = (wr_target_latched == 4'd1) ? s_axi_bready : 1'b0;

    assign m2_axi_awaddr  = s_axi_awaddr;
    assign m2_axi_awvalid = (wr_target == 4'd2) ? s_axi_awvalid : 1'b0;
    assign m2_axi_wdata   = s_axi_wdata;
    assign m2_axi_wstrb   = s_axi_wstrb;
    assign m2_axi_wvalid  = (wr_target_latched == 4'd2) ? s_axi_wvalid : 1'b0;
    assign m2_axi_bready  = (wr_target_latched == 4'd2) ? s_axi_bready : 1'b0;

    assign m3_axi_awaddr  = s_axi_awaddr;
    assign m3_axi_awvalid = (wr_target == 4'd3) ? s_axi_awvalid : 1'b0;
    assign m3_axi_wdata   = s_axi_wdata;
    assign m3_axi_wstrb   = s_axi_wstrb;
    assign m3_axi_wvalid  = (wr_target_latched == 4'd3) ? s_axi_wvalid : 1'b0;
    assign m3_axi_bready  = (wr_target_latched == 4'd3) ? s_axi_bready : 1'b0;

    assign m4_axi_awaddr  = s_axi_awaddr;
    assign m4_axi_awvalid = (wr_target == 4'd4) ? s_axi_awvalid : 1'b0;
    assign m4_axi_wdata   = s_axi_wdata;
    assign m4_axi_wstrb   = s_axi_wstrb;
    assign m4_axi_wvalid  = (wr_target_latched == 4'd4) ? s_axi_wvalid : 1'b0;
    assign m4_axi_bready  = (wr_target_latched == 4'd4) ? s_axi_bready : 1'b0;

    assign m5_axi_awaddr  = s_axi_awaddr;
    assign m5_axi_awvalid = (wr_target == 4'd5) ? s_axi_awvalid : 1'b0;
    assign m5_axi_wdata   = s_axi_wdata;
    assign m5_axi_wstrb   = s_axi_wstrb;
    assign m5_axi_wvalid  = (wr_target_latched == 4'd5) ? s_axi_wvalid : 1'b0;
    assign m5_axi_bready  = (wr_target_latched == 4'd5) ? s_axi_bready : 1'b0;

    assign m6_axi_awaddr  = s_axi_awaddr;
    assign m6_axi_awvalid = (wr_target == 4'd6) ? s_axi_awvalid : 1'b0;
    assign m6_axi_wdata   = s_axi_wdata;
    assign m6_axi_wstrb   = s_axi_wstrb;
    assign m6_axi_wvalid  = (wr_target_latched == 4'd6) ? s_axi_wvalid : 1'b0;
    assign m6_axi_bready  = (wr_target_latched == 4'd6) ? s_axi_bready : 1'b0;

    // Multiplex write ready and response
    always @(*) begin
        case (wr_target)
            4'd0: s_axi_awready = m0_axi_awready;
            4'd1: s_axi_awready = m1_axi_awready;
            4'd2: s_axi_awready = m2_axi_awready;
            4'd3: s_axi_awready = m3_axi_awready;
            4'd4: s_axi_awready = m4_axi_awready;
            4'd5: s_axi_awready = m5_axi_awready;
            4'd6: s_axi_awready = m6_axi_awready;
            default: s_axi_awready = 1'b1; // DECERR consumes immediately
        endcase
    end

    always @(*) begin
        case (wr_target_latched)
            4'd0: begin
                s_axi_wready = m0_axi_wready;
                s_axi_bresp  = m0_axi_bresp;
                s_axi_bvalid = m0_axi_bvalid;
            end
            4'd1: begin
                s_axi_wready = m1_axi_wready;
                s_axi_bresp  = m1_axi_bresp;
                s_axi_bvalid = m1_axi_bvalid;
            end
            4'd2: begin
                s_axi_wready = m2_axi_wready;
                s_axi_bresp  = m2_axi_bresp;
                s_axi_bvalid = m2_axi_bvalid;
            end
            4'd3: begin
                s_axi_wready = m3_axi_wready;
                s_axi_bresp  = m3_axi_bresp;
                s_axi_bvalid = m3_axi_bvalid;
            end
            4'd4: begin
                s_axi_wready = m4_axi_wready;
                s_axi_bresp  = m4_axi_bresp;
                s_axi_bvalid = m4_axi_bvalid;
            end
            4'd5: begin
                s_axi_wready = m5_axi_wready;
                s_axi_bresp  = m5_axi_bresp;
                s_axi_bvalid = m5_axi_bvalid;
            end
            4'd6: begin
                s_axi_wready = m6_axi_wready;
                s_axi_bresp  = m6_axi_bresp;
                s_axi_bvalid = m6_axi_bvalid;
            end
            default: begin // DECERR
                s_axi_wready = 1'b1;
                s_axi_bresp  = 2'b11; // DECERR response
                s_axi_bvalid = wr_decerr_pending;
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // Read Channel Routing
    // -------------------------------------------------------------------------
    wire [3:0] rd_target = decode_addr(s_axi_araddr);
    reg  [3:0] rd_target_latched;
    reg        rd_decerr_pending;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_target_latched <= 4'd0;
            rd_decerr_pending <= 1'b0;
        end else begin
            if (s_axi_arvalid && s_axi_arready) begin
                rd_target_latched <= rd_target;
                if (rd_target == 4'd7)
                    rd_decerr_pending <= 1'b1;
            end else if (s_axi_rvalid && s_axi_rready) begin
                rd_decerr_pending <= 1'b0;
            end
        end
    end

    // Forward read address to selected master
    assign m0_axi_araddr  = s_axi_araddr;
    assign m0_axi_arvalid = (rd_target == 4'd0) ? s_axi_arvalid : 1'b0;
    assign m0_axi_rready  = (rd_target_latched == 4'd0) ? s_axi_rready : 1'b0;

    assign m1_axi_araddr  = s_axi_araddr;
    assign m1_axi_arvalid = (rd_target == 4'd1) ? s_axi_arvalid : 1'b0;
    assign m1_axi_rready  = (rd_target_latched == 4'd1) ? s_axi_rready : 1'b0;

    assign m2_axi_araddr  = s_axi_araddr;
    assign m2_axi_arvalid = (rd_target == 4'd2) ? s_axi_arvalid : 1'b0;
    assign m2_axi_rready  = (rd_target_latched == 4'd2) ? s_axi_rready : 1'b0;

    assign m3_axi_araddr  = s_axi_araddr;
    assign m3_axi_arvalid = (rd_target == 4'd3) ? s_axi_arvalid : 1'b0;
    assign m3_axi_rready  = (rd_target_latched == 4'd3) ? s_axi_rready : 1'b0;

    assign m4_axi_araddr  = s_axi_araddr;
    assign m4_axi_arvalid = (rd_target == 4'd4) ? s_axi_arvalid : 1'b0;
    assign m4_axi_rready  = (rd_target_latched == 4'd4) ? s_axi_rready : 1'b0;

    assign m5_axi_araddr  = s_axi_araddr;
    assign m5_axi_arvalid = (rd_target == 4'd5) ? s_axi_arvalid : 1'b0;
    assign m5_axi_rready  = (rd_target_latched == 4'd5) ? s_axi_rready : 1'b0;

    assign m6_axi_araddr  = s_axi_araddr;
    assign m6_axi_arvalid = (rd_target == 4'd6) ? s_axi_arvalid : 1'b0;
    assign m6_axi_rready  = (rd_target_latched == 4'd6) ? s_axi_rready : 1'b0;

    // Multiplex read ready and data
    always @(*) begin
        case (rd_target)
            4'd0: s_axi_arready = m0_axi_arready;
            4'd1: s_axi_arready = m1_axi_arready;
            4'd2: s_axi_arready = m2_axi_arready;
            4'd3: s_axi_arready = m3_axi_arready;
            4'd4: s_axi_arready = m4_axi_arready;
            4'd5: s_axi_arready = m5_axi_arready;
            4'd6: s_axi_arready = m6_axi_arready;
            default: s_axi_arready = 1'b1; // DECERR consumes immediately
        endcase
    end

    always @(*) begin
        case (rd_target_latched)
            4'd0: begin
                s_axi_rdata  = m0_axi_rdata;
                s_axi_rresp  = m0_axi_rresp;
                s_axi_rvalid = m0_axi_rvalid;
            end
            4'd1: begin
                s_axi_rdata  = m1_axi_rdata;
                s_axi_rresp  = m1_axi_rresp;
                s_axi_rvalid = m1_axi_rvalid;
            end
            4'd2: begin
                s_axi_rdata  = m2_axi_rdata;
                s_axi_rresp  = m2_axi_rresp;
                s_axi_rvalid = m2_axi_rvalid;
            end
            4'd3: begin
                s_axi_rdata  = m3_axi_rdata;
                s_axi_rresp  = m3_axi_rresp;
                s_axi_rvalid = m3_axi_rvalid;
            end
            4'd4: begin
                s_axi_rdata  = m4_axi_rdata;
                s_axi_rresp  = m4_axi_rresp;
                s_axi_rvalid = m4_axi_rvalid;
            end
            4'd5: begin
                s_axi_rdata  = m5_axi_rdata;
                s_axi_rresp  = m5_axi_rresp;
                s_axi_rvalid = m5_axi_rvalid;
            end
            4'd6: begin
                s_axi_rdata  = m6_axi_rdata;
                s_axi_rresp  = m6_axi_rresp;
                s_axi_rvalid = m6_axi_rvalid;
            end
            default: begin // DECERR
                s_axi_rdata  = 32'hDEAD_DEAD;
                s_axi_rresp  = 2'b11; // DECERR response
                s_axi_rvalid = rd_decerr_pending;
            end
        endcase
    end

endmodule
`default_nettype wire
