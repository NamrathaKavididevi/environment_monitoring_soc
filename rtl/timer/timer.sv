// =============================================================================
// Module      : timer.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : System Interval Timer with AXI4-Lite Slave Interface.
//               Compatible with RISC-V VeeR EL2 core (Slave S03).
//
// Register Map (Base: 0x40004000, Aperture: 8 KB):
//   0x00 : TIMER_CONTROL   [0] EN, [1] AUTO_RELOAD, [2] COUNT_UP (0=down,1=up)
//   0x04 : TIMER_COUNTER   [31:0] Current counter value (R/W, writable to preset)
//   0x08 : TIMER_COMPARE   [31:0] Timeout comparison value (match triggers tick)
//   0x0C : TIMER_PRESCALER [31:0] Input clock divider (counter ticks every PRESCALER+1 clks)
//   0x10 : TIMER_STATUS    [0] TICK (match event flag, R/W1C)
//   0x14 : TIMER_IRQ_ENABLE[0] TICK_IE (enables timer interrupt)
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module timer #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
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
    input  wire                  s_axi_rready,

    // Hardware Outputs
    output reg                   sample_tick,
    output wire                  irq_timer
);

    // -------------------------------------------------------------------------
    // Internal Registers
    // -------------------------------------------------------------------------
    reg        reg_en;
    reg        reg_auto_reload;
    reg        reg_count_up;
    reg [31:0] reg_counter;
    reg [31:0] reg_compare;
    reg [31:0] reg_prescaler;
    reg        reg_tick;          // STATUS[0] - sticky, W1C
    reg        reg_tick_ie;       // IRQ_ENABLE[0]

    assign irq_timer = reg_tick & reg_tick_ie;

    // -------------------------------------------------------------------------
    // Prescaler & Counter Logic
    // -------------------------------------------------------------------------
    reg [31:0] prescale_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescale_cnt <= 32'd0;
            reg_counter  <= 32'd0;
            sample_tick  <= 1'b0;
        end else if (reg_en) begin
            sample_tick <= 1'b0;
            if (prescale_cnt >= reg_prescaler) begin
                prescale_cnt <= 32'd0;
                // Main counter tick
                if (reg_count_up) begin
                    // Count-up mode
                    if (reg_counter >= reg_compare) begin
                        sample_tick <= 1'b1;
                        if (reg_auto_reload)
                            reg_counter <= 32'd0;
                    end else begin
                        reg_counter <= reg_counter + 1'b1;
                    end
                end else begin
                    // Count-down mode
                    if (reg_counter == 32'd0) begin
                        sample_tick <= 1'b1;
                        if (reg_auto_reload)
                            reg_counter <= reg_compare;
                    end else begin
                        reg_counter <= reg_counter - 1'b1;
                    end
                end
            end else begin
                prescale_cnt <= prescale_cnt + 1'b1;
                sample_tick  <= 1'b0;
            end
        end else begin
            prescale_cnt <= 32'd0;
            sample_tick  <= 1'b0;
        end
    end

    // -------------------------------------------------------------------------
    // AXI4-Lite Write Channel
    // -------------------------------------------------------------------------
    reg [ADDR_WIDTH-1:0] awaddr_latched;
    reg                  aw_done;
    reg                  w_done;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready   <= 1'b0;
            s_axi_wready    <= 1'b0;
            s_axi_bvalid    <= 1'b0;
            s_axi_bresp     <= 2'b00;
            aw_done         <= 1'b0;
            w_done          <= 1'b0;
            awaddr_latched  <= {ADDR_WIDTH{1'b0}};

            reg_en          <= 1'b0;
            reg_auto_reload <= 1'b1;
            reg_count_up    <= 1'b0;
            reg_compare     <= 32'd0;
            reg_prescaler   <= 32'd0;
            reg_tick        <= 1'b0;
            reg_tick_ie     <= 1'b0;
        end else begin
            // Latch TICK flag when sample_tick fires
            if (sample_tick)
                reg_tick <= 1'b1;

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
                s_axi_wready <= 1'b1;
                w_done       <= 1'b1;
            end else begin
                s_axi_wready <= 1'b0;
            end

            // Write execution
            if (aw_done && w_done && !s_axi_bvalid) begin
                case (awaddr_latched[7:0])
                    8'h00: begin // TIMER_CONTROL
                        reg_en          <= s_axi_wdata[0];
                        reg_auto_reload <= s_axi_wdata[1];
                        reg_count_up    <= s_axi_wdata[2];
                    end
                    8'h04: begin // TIMER_COUNTER (writable preset)
                        reg_counter <= s_axi_wdata;
                    end
                    8'h08: begin // TIMER_COMPARE
                        reg_compare <= s_axi_wdata;
                    end
                    8'h0C: begin // TIMER_PRESCALER
                        reg_prescaler <= s_axi_wdata;
                    end
                    8'h10: begin // TIMER_STATUS (W1C)
                        if (s_axi_wdata[0]) reg_tick <= 1'b0;
                    end
                    8'h14: begin // TIMER_IRQ_ENABLE
                        reg_tick_ie <= s_axi_wdata[0];
                    end
                    default: ;
                endcase
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00;
            end

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
                s_axi_rresp   <= 2'b00;
                case (s_axi_araddr[7:0])
                    8'h00: s_axi_rdata <= {29'd0, reg_count_up, reg_auto_reload, reg_en};
                    8'h04: s_axi_rdata <= reg_counter;
                    8'h08: s_axi_rdata <= reg_compare;
                    8'h0C: s_axi_rdata <= reg_prescaler;
                    8'h10: s_axi_rdata <= {31'd0, reg_tick};
                    8'h14: s_axi_rdata <= {31'd0, reg_tick_ie};
                    default: s_axi_rdata <= 32'd0;
                endcase
            end else begin
                s_axi_arready <= 1'b0;
            end

            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule
`default_nettype wire
