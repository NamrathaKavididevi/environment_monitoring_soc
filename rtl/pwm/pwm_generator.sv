// =============================================================================
// Module      : pwm_generator.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : High-Precision Pulse-Width Modulation (PWM) Generator IP
//               with AXI4-Lite Slave Interface (Slave S06).
//
// Register Map (Base: 0x4000A000):
//   0x00 : PWM_CONTROL    [0] EN, [1] POLARITY (0=active-high, 1=active-low)
//   0x04 : PWM_PERIOD     [31:0] PWM period value in clock cycles
//   0x08 : PWM_DUTY       [31:0] Duty-cycle threshold (counter < duty => active)
//   0x0C : PWM_COUNTER    [31:0] Current PWM counter value (R/O)
//   0x10 : PWM_STATUS     [0] RUNNING, [1] CYCLE_COMPLETE (R/O, cleared on read)
//   0x14 : PWM_IRQ_ENABLE [0] CYCLE_COMPLETE_IE
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module pwm_generator #(
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

    // PWM Output
    output reg                   pwm_out,

    // Interrupt to VeeR EL2 PIC
    output wire                  irq_pwm
);

    // Internal Registers
    reg        reg_en;
    reg        reg_polarity;
    reg [31:0] reg_period;
    reg [31:0] reg_duty;
    reg [31:0] reg_counter;
    reg        reg_running;
    reg        reg_cycle_complete;
    reg        reg_irq_en;

    assign irq_pwm = reg_cycle_complete & reg_irq_en;

    // PWM Generation Logic
    wire pwm_raw = (reg_counter < reg_duty);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_counter        <= 32'd0;
            reg_running        <= 1'b0;
            reg_cycle_complete <= 1'b0;
            pwm_out            <= 1'b0;
        end else if (reg_en) begin
            reg_running <= 1'b1;
            pwm_out     <= reg_polarity ? ~pwm_raw : pwm_raw;

            if (reg_counter >= (reg_period - 1'b1)) begin
                reg_counter        <= 32'd0;
                reg_cycle_complete <= 1'b1;
            end else begin
                reg_counter <= reg_counter + 1'b1;
            end
        end else begin
            reg_running <= 1'b0;
            reg_counter <= 32'd0;
            pwm_out     <= reg_polarity ? 1'b1 : 1'b0;
        end
    end

    // AXI4-Lite Write Handshake
    reg [ADDR_WIDTH-1:0] awaddr_latched;
    reg aw_done, w_done;

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
            reg_polarity    <= 1'b0;
            reg_period      <= 32'd1000;
            reg_duty        <= 32'd500;
            reg_irq_en      <= 1'b0;
        end else begin
            if (s_axi_awvalid && !aw_done) begin
                s_axi_awready  <= 1'b1;
                awaddr_latched <= s_axi_awaddr;
                aw_done        <= 1'b1;
            end else begin
                s_axi_awready  <= 1'b0;
            end

            if (s_axi_wvalid && !w_done) begin
                s_axi_wready <= 1'b1;
                w_done       <= 1'b1;
            end else begin
                s_axi_wready <= 1'b0;
            end

            if (aw_done && w_done && !s_axi_bvalid) begin
                case (awaddr_latched[7:0])
                    8'h00: begin
                        reg_en       <= s_axi_wdata[0];
                        reg_polarity <= s_axi_wdata[1];
                    end
                    8'h04: reg_period <= (s_axi_wdata > 0) ? s_axi_wdata : 32'd1;
                    8'h08: reg_duty   <= s_axi_wdata;
                    8'h14: reg_irq_en <= s_axi_wdata[0];
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

    // AXI4-Lite Read Channel
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
                    8'h00: s_axi_rdata <= {30'd0, reg_polarity, reg_en};
                    8'h04: s_axi_rdata <= reg_period;
                    8'h08: s_axi_rdata <= reg_duty;
                    8'h0C: s_axi_rdata <= reg_counter;
                    8'h10: begin
                        s_axi_rdata        <= {30'd0, reg_cycle_complete, reg_running};
                        reg_cycle_complete <= 1'b0; // Clear on read
                    end
                    8'h14: s_axi_rdata <= {31'd0, reg_irq_en};
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
