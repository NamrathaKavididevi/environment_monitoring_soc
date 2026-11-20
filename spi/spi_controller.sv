// =============================================================================
// Module      : spi_controller.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : SPI Master Controller with AXI4-Lite Slave (Slave S04).
//
// Register Map (Base: 0x40006000):
//   0x00 : SPI_CONTROL    [0] EN, [1] CPOL, [2] CPHA, [3] MASTER_MODE
//   0x04 : SPI_STATUS     [0] BUSY, [1] TX_READY, [2] RX_VALID  (R/O)
//   0x08 : SPI_TX_DATA    [7:0] Transmit data byte (W/O, starts transfer)
//   0x0C : SPI_RX_DATA    [7:0] Received data byte (R/O)
//   0x10 : SPI_CLK_DIV    [15:0] SCLK = clk / (2*(CLK_DIV+1))
//   0x14 : SPI_CS         [0] CS_N control (write 0 to assert)
//   0x18 : SPI_IRQ_ENABLE [0] DONE_IE, [1] RX_VALID_IE
//   0x1C : SPI_IRQ_STATUS [0] DONE_IRQ, [1] RX_VALID_IRQ (R/W1C)
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module spi_controller #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst_n,

    output reg                   spi_sclk,
    output reg                   spi_mosi,
    input  wire                  spi_miso,
    output wire                  spi_cs_n,

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

    output wire                  irq_spi
);

    // Control registers
    reg        reg_en, reg_cpol, reg_cpha, reg_master;
    reg        reg_busy, reg_tx_ready, reg_rx_valid;
    reg [7:0]  reg_rx_data;
    reg [15:0] reg_clk_div;
    reg        reg_cs_n;
    reg [1:0]  reg_irq_en;
    reg [1:0]  reg_irq_status;

    assign spi_cs_n = reg_cs_n;
    assign irq_spi  = |(reg_irq_status & reg_irq_en);

    // SPI shift register
    reg [7:0]  shift_reg;
    reg [2:0]  bit_cnt;
    reg [15:0] clk_cnt;
    reg        spi_active;
    reg        sclk_phase; // 0=first edge, 1=second edge

    wire sclk_idle = reg_cpol;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_sclk    <= 1'b0;
            spi_mosi    <= 1'b0;
            reg_busy    <= 1'b0;
            reg_tx_ready<= 1'b1;
            reg_rx_valid<= 1'b0;
            reg_rx_data <= 8'd0;
            shift_reg   <= 8'd0;
            bit_cnt     <= 3'd0;
            clk_cnt     <= 16'd0;
            spi_active  <= 1'b0;
            sclk_phase  <= 1'b0;
        end else begin
            if (!spi_active) begin
                spi_sclk <= sclk_idle;
            end else begin
                if (clk_cnt >= reg_clk_div) begin
                    clk_cnt <= 16'd0;
                    if (!sclk_phase) begin
                        // First edge: shift out (CPHA=0) or sample (CPHA=1)
                        spi_sclk <= ~spi_sclk;
                        if (!reg_cpha) begin
                            // Sample MISO
                            shift_reg <= {shift_reg[6:0], spi_miso};
                        end else begin
                            // Shift out MOSI
                            spi_mosi <= shift_reg[7];
                        end
                        sclk_phase <= 1'b1;
                    end else begin
                        // Second edge
                        spi_sclk <= ~spi_sclk;
                        if (!reg_cpha) begin
                            // Shift out next bit
                            shift_reg <= {shift_reg[6:0], 1'b0};
                            spi_mosi  <= shift_reg[6];
                        end else begin
                            // Sample MISO
                            shift_reg <= {shift_reg[6:0], spi_miso};
                        end
                        sclk_phase <= 1'b0;

                        if (bit_cnt == 3'd7) begin
                            // Transfer complete
                            spi_active   <= 1'b0;
                            reg_busy     <= 1'b0;
                            reg_tx_ready <= 1'b1;
                            reg_rx_valid <= 1'b1;
                            reg_rx_data  <= reg_cpha ? {shift_reg[6:0], spi_miso} : shift_reg;
                            reg_irq_status <= reg_irq_status | 2'b11;
                            spi_sclk     <= sclk_idle;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                            if (!reg_cpha) spi_mosi <= shift_reg[6];
                        end
                    end
                end else begin
                    clk_cnt <= clk_cnt + 1'b1;
                end
            end
        end
    end

    // AXI Write
    reg [ADDR_WIDTH-1:0] awaddr_latched;
    reg aw_done, w_done;
    reg start_transfer;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b0; s_axi_wready <= 1'b0;
            s_axi_bvalid <= 1'b0; s_axi_bresp <= 2'b00;
            aw_done <= 1'b0; w_done <= 1'b0;
            awaddr_latched <= {ADDR_WIDTH{1'b0}};
            reg_en <= 1'b0; reg_cpol <= 1'b0; reg_cpha <= 1'b0; reg_master <= 1'b1;
            reg_clk_div <= 16'd1; reg_cs_n <= 1'b1;
            reg_irq_en <= 2'b00; reg_irq_status <= 2'b00;
            start_transfer <= 1'b0;
        end else begin
            // Launch transfer
            if (start_transfer && reg_en && !reg_busy) begin
                spi_active   <= 1'b1;
                reg_busy     <= 1'b1;
                reg_tx_ready <= 1'b0;
                reg_rx_valid <= 1'b0;
                bit_cnt      <= 3'd0;
                clk_cnt      <= 16'd0;
                sclk_phase   <= 1'b0;
                if (!reg_cpha) spi_mosi <= shift_reg[7];
                start_transfer <= 1'b0;
            end else begin
                start_transfer <= 1'b0;
            end

            if (s_axi_awvalid && !aw_done) begin
                s_axi_awready <= 1'b1; awaddr_latched <= s_axi_awaddr; aw_done <= 1'b1;
            end else s_axi_awready <= 1'b0;

            if (s_axi_wvalid && !w_done) begin
                s_axi_wready <= 1'b1; w_done <= 1'b1;
            end else s_axi_wready <= 1'b0;

            if (aw_done && w_done && !s_axi_bvalid) begin
                case (awaddr_latched[7:0])
                    8'h00: begin reg_en <= s_axi_wdata[0]; reg_cpol <= s_axi_wdata[1]; reg_cpha <= s_axi_wdata[2]; reg_master <= s_axi_wdata[3]; end
                    8'h08: begin shift_reg <= s_axi_wdata[7:0]; start_transfer <= 1'b1; end
                    8'h10: reg_clk_div <= s_axi_wdata[15:0];
                    8'h14: reg_cs_n    <= s_axi_wdata[0];
                    8'h18: reg_irq_en  <= s_axi_wdata[1:0];
                    8'h1C: reg_irq_status <= reg_irq_status & ~s_axi_wdata[1:0];
                    default: ;
                endcase
                s_axi_bvalid <= 1'b1; s_axi_bresp <= 2'b00;
            end

            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0; aw_done <= 1'b0; w_done <= 1'b0;
            end
        end
    end

    // AXI Read
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_arready <= 1'b0; s_axi_rvalid <= 1'b0;
            s_axi_rdata <= 32'd0; s_axi_rresp <= 2'b00;
        end else begin
            if (s_axi_arvalid && !s_axi_rvalid) begin
                s_axi_arready <= 1'b1; s_axi_rvalid <= 1'b1; s_axi_rresp <= 2'b00;
                case (s_axi_araddr[7:0])
                    8'h00: s_axi_rdata <= {28'd0, reg_master, reg_cpha, reg_cpol, reg_en};
                    8'h04: s_axi_rdata <= {29'd0, reg_rx_valid, reg_tx_ready, reg_busy};
                    8'h0C: s_axi_rdata <= {24'd0, reg_rx_data};
                    8'h10: s_axi_rdata <= {16'd0, reg_clk_div};
                    8'h14: s_axi_rdata <= {31'd0, reg_cs_n};
                    8'h18: s_axi_rdata <= {30'd0, reg_irq_en};
                    8'h1C: s_axi_rdata <= {30'd0, reg_irq_status};
                    default: s_axi_rdata <= 32'd0;
                endcase
            end else s_axi_arready <= 1'b0;
            if (s_axi_rvalid && s_axi_rready) s_axi_rvalid <= 1'b0;
        end
    end

endmodule
`default_nettype wire
