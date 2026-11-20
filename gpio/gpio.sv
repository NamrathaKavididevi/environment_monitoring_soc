// =============================================================================
// Module      : gpio.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : General Purpose I/O Controller with AXI4-Lite Slave (Slave S02).
//
// Register Map (Base: 0x40002000):
//   0x00 : GPIO_INPUT      [7:0] R/O   Reads input pin states (synchronized)
//   0x04 : GPIO_OUTPUT     [7:0] R/W   Sets output pin values
//   0x08 : GPIO_DIRECTION  [7:0] R/W   Configures direction (1=output, 0=input)
//   0x0C : GPIO_SET        [7:0] W/O   Sets selected output bits (OR)
//   0x10 : GPIO_CLEAR      [7:0] W/O   Clears selected output bits (AND ~val)
//   0x14 : GPIO_IRQ_ENABLE [7:0] R/W   Enables GPIO interrupts per-bit
//   0x18 : GPIO_IRQ_STATUS [7:0] R/W1C GPIO interrupt flags
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module gpio #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire [7:0]            gpio_in,
    output wire [7:0]            gpio_out,

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

    output wire                  irq_gpio
);

    reg [7:0] reg_output;
    reg [7:0] reg_direction;
    reg [7:0] reg_irq_en;
    reg [7:0] reg_irq_status;

    assign gpio_out = reg_output;
    assign irq_gpio = |(reg_irq_status & reg_irq_en);

    // 3-stage synchronizer and edge detection
    reg [7:0] sync0, sync1, sync2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync0 <= 8'd0; sync1 <= 8'd0; sync2 <= 8'd0;
        end else begin
            sync0 <= gpio_in; sync1 <= sync0; sync2 <= sync1;
        end
    end
    wire [7:0] input_edge = (sync1 ^ sync2);

    // AXI Write Channel
    reg [ADDR_WIDTH-1:0] awaddr_latched;
    reg aw_done, w_done;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready  <= 1'b0; s_axi_wready <= 1'b0;
            s_axi_bvalid   <= 1'b0; s_axi_bresp  <= 2'b00;
            aw_done <= 1'b0; w_done <= 1'b0;
            awaddr_latched <= {ADDR_WIDTH{1'b0}};
            reg_output     <= 8'd0; reg_direction <= 8'd0;
            reg_irq_en     <= 8'd0; reg_irq_status <= 8'd0;
        end else begin
            reg_irq_status <= reg_irq_status | input_edge;

            if (s_axi_awvalid && !aw_done) begin
                s_axi_awready <= 1'b1; awaddr_latched <= s_axi_awaddr; aw_done <= 1'b1;
            end else s_axi_awready <= 1'b0;

            if (s_axi_wvalid && !w_done) begin
                s_axi_wready <= 1'b1; w_done <= 1'b1;
            end else s_axi_wready <= 1'b0;

            if (aw_done && w_done && !s_axi_bvalid) begin
                case (awaddr_latched[7:0])
                    8'h04: reg_output    <= s_axi_wdata[7:0];
                    8'h08: reg_direction <= s_axi_wdata[7:0];
                    8'h0C: reg_output    <= reg_output | s_axi_wdata[7:0];  // SET
                    8'h10: reg_output    <= reg_output & ~s_axi_wdata[7:0]; // CLEAR
                    8'h14: reg_irq_en    <= s_axi_wdata[7:0];
                    8'h18: reg_irq_status <= (reg_irq_status & ~s_axi_wdata[7:0]) | (input_edge & ~s_axi_wdata[7:0]);
                    default: ;
                endcase
                s_axi_bvalid <= 1'b1; s_axi_bresp <= 2'b00;
            end

            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0; aw_done <= 1'b0; w_done <= 1'b0;
            end
        end
    end

    // AXI Read Channel
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_arready <= 1'b0; s_axi_rvalid <= 1'b0;
            s_axi_rdata <= 32'd0; s_axi_rresp <= 2'b00;
        end else begin
            if (s_axi_arvalid && !s_axi_rvalid) begin
                s_axi_arready <= 1'b1; s_axi_rvalid <= 1'b1; s_axi_rresp <= 2'b00;
                case (s_axi_araddr[7:0])
                    8'h00: s_axi_rdata <= {24'd0, sync1};
                    8'h04: s_axi_rdata <= {24'd0, reg_output};
                    8'h08: s_axi_rdata <= {24'd0, reg_direction};
                    8'h14: s_axi_rdata <= {24'd0, reg_irq_en};
                    8'h18: s_axi_rdata <= {24'd0, reg_irq_status};
                    default: s_axi_rdata <= 32'd0;
                endcase
            end else s_axi_arready <= 1'b0;
            if (s_axi_rvalid && s_axi_rready) s_axi_rvalid <= 1'b0;
        end
    end

endmodule
`default_nettype wire
