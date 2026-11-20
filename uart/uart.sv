// =============================================================================
// Module      : uart.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Full-featured UART IP with AXI4-Lite Slave Interface.
//               Compatible with RISC-V VeeR EL2 core and standard AXI4-Lite fabric.
//
// Register Map (Base Address: 0x40000000, 32-bit word aligned):
//   Offset 0x00 : DATA        [7:0]   R/W   Push TX byte / Pop RX byte
//   Offset 0x04 : STATUS      [4:0]   R/O   [0] TX_BUSY
//                                           [1] TX_EMPTY
//                                           [2] RX_VALID
//                                           [3] RX_OVERRUN
//                                           [4] FRAME_ERR
//   Offset 0x08 : CONTROL     [2:0]   R/W   [0] TX_EN
//                                           [1] RX_EN
//                                           [2] LOOPBACK_EN
//   Offset 0x0C : BAUD_DIV    [15:0]  R/W   Bit-clock divisor (f_clk / baud_rate)
//   Offset 0x10 : IRQ_ENABLE  [1:0]   R/W   [0] TX_EMPTY_IE
//                                           [1] RX_VALID_IE
//   Offset 0x14 : IRQ_STATUS  [1:0]   R/W1C [0] TX_EMPTY_IRQ
//                                           [1] RX_VALID_IRQ
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module uart #(
    parameter ADDR_WIDTH       = 32,
    parameter DATA_WIDTH       = 32,
    parameter DEFAULT_BAUD_DIV = 16'd4
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

    // External UART Physical Pins
    input  wire                  uart_rx,
    output reg                   uart_tx,

    // Level-sensitive Interrupt to VeeR EL2 PIC
    output wire                  irq_uart
);

    // -------------------------------------------------------------------------
    // Control and Status Registers
    // -------------------------------------------------------------------------
    reg [15:0] reg_baud_div;
    reg        reg_tx_en;
    reg        reg_rx_en;
    reg        reg_loopback_en;
    reg [1:0]  reg_irq_enable;  // [0] TX_EMPTY_IE, [1] RX_VALID_IE
    reg [1:0]  reg_irq_status;  // [0] TX_EMPTY_IRQ, [1] RX_VALID_IRQ (W1C)

    // Status bits
    reg        tx_busy;
    reg        tx_empty;
    reg        rx_valid;
    reg        rx_overrun;
    reg        frame_err;

    // Data buffers
    reg [7:0]  rx_data_reg;
    reg [7:0]  tx_byte_in;
    reg        tx_trigger;

    // Event pulses between FSMs and registers
    reg        tx_done_pulse;
    reg        rx_done_pulse;

    // Interrupt output generation
    assign irq_uart = |(reg_irq_status & reg_irq_enable);

    // -------------------------------------------------------------------------
    // RX Pin Selection & 3-Stage Synchronizer
    // -------------------------------------------------------------------------
    wire rx_in_selected = reg_loopback_en ? uart_tx : uart_rx;
    reg [2:0] rx_sync;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync <= 3'b111;
        end else begin
            rx_sync <= {rx_sync[1:0], rx_in_selected};
        end
    end

    wire rx_bit = rx_sync[2];

    reg rx_bit_prev;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_bit_prev <= 1'b1;
        end else begin
            rx_bit_prev <= rx_bit;
        end
    end

    wire rx_falling_edge = (rx_bit_prev == 1'b1) && (rx_bit == 1'b0);

    // -------------------------------------------------------------------------
    // UART Transmitter FSM (8-N-1)
    // -------------------------------------------------------------------------
    localparam TX_IDLE  = 2'd0;
    localparam TX_START = 2'd1;
    localparam TX_DATA  = 2'd2;
    localparam TX_STOP  = 2'd3;

    reg [1:0]  tx_state;
    reg [15:0] tx_baud_cnt;
    reg [2:0]  tx_bit_idx;
    reg [7:0]  tx_shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_state      <= TX_IDLE;
            uart_tx       <= 1'b1;
            tx_baud_cnt   <= 16'd0;
            tx_bit_idx    <= 3'd0;
            tx_shift_reg  <= 8'd0;
            tx_busy       <= 1'b0;
            tx_empty      <= 1'b1;
            tx_done_pulse <= 1'b0;
        end else begin
            tx_done_pulse <= 1'b0;

            case (tx_state)
                TX_IDLE: begin
                    uart_tx     <= 1'b1;
                    tx_baud_cnt <= 16'd0;
                    tx_bit_idx  <= 3'd0;
                    if (reg_tx_en && tx_trigger) begin
                        tx_shift_reg <= tx_byte_in;
                        tx_busy      <= 1'b1;
                        tx_empty     <= 1'b0;
                        tx_state     <= TX_START;
                    end else begin
                        tx_busy  <= 1'b0;
                        tx_empty <= 1'b1;
                    end
                end

                TX_START: begin
                    uart_tx <= 1'b0; // Start bit
                    if (tx_baud_cnt >= reg_baud_div - 1'b1) begin
                        tx_baud_cnt <= 16'd0;
                        tx_bit_idx  <= 3'd0;
                        tx_state    <= TX_DATA;
                    end else begin
                        tx_baud_cnt <= tx_baud_cnt + 1'b1;
                    end
                end

                TX_DATA: begin
                    uart_tx <= tx_shift_reg[tx_bit_idx];
                    if (tx_baud_cnt >= reg_baud_div - 1'b1) begin
                        tx_baud_cnt <= 16'd0;
                        if (tx_bit_idx == 3'd7) begin
                            tx_state <= TX_STOP;
                        end else begin
                            tx_bit_idx <= tx_bit_idx + 1'b1;
                        end
                    end else begin
                        tx_baud_cnt <= tx_baud_cnt + 1'b1;
                    end
                end

                TX_STOP: begin
                    uart_tx <= 1'b1; // Stop bit
                    if (tx_baud_cnt >= reg_baud_div - 1'b1) begin
                        tx_baud_cnt   <= 16'd0;
                        tx_state      <= TX_IDLE;
                        tx_busy       <= 1'b0;
                        tx_empty      <= 1'b1;
                        tx_done_pulse <= 1'b1;
                    end else begin
                        tx_baud_cnt <= tx_baud_cnt + 1'b1;
                    end
                end

                default: tx_state <= TX_IDLE;
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // UART Receiver FSM (8-N-1 with mid-bit sampling)
    // -------------------------------------------------------------------------
    localparam RX_IDLE  = 2'd0;
    localparam RX_START = 2'd1;
    localparam RX_DATA  = 2'd2;
    localparam RX_STOP  = 2'd3;

    reg [1:0]  rx_state;
    reg [15:0] rx_baud_cnt;
    reg [2:0]  rx_bit_idx;
    reg [7:0]  rx_shift_reg;

    wire [15:0] half_baud_sub1 = ((reg_baud_div >> 1) > 16'd0) ?
                                 ((reg_baud_div >> 1) - 1'b1) : 16'd0;

    // Pop event from AXI read of DATA register (offset 0x00)
    wire rx_pop = (s_axi_arvalid && s_axi_arready && (s_axi_araddr[7:0] == 8'h00));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_state      <= RX_IDLE;
            rx_baud_cnt   <= 16'd0;
            rx_bit_idx    <= 3'd0;
            rx_shift_reg  <= 8'd0;
            rx_data_reg   <= 8'd0;
            rx_valid      <= 1'b0;
            rx_overrun    <= 1'b0;
            frame_err     <= 1'b0;
            rx_done_pulse <= 1'b0;
        end else begin
            rx_done_pulse <= 1'b0;

            // FSM operation
            case (rx_state)
                RX_IDLE: begin
                    rx_baud_cnt <= 16'd0;
                    rx_bit_idx  <= 3'd0;
                    if (reg_rx_en && rx_falling_edge) begin
                        rx_state    <= RX_START;
                        rx_baud_cnt <= 16'd0;
                    end
                end

                RX_START: begin
                    if (rx_baud_cnt >= half_baud_sub1) begin
                        rx_baud_cnt <= 16'd0;
                        if (!rx_bit) begin
                            // Verified low at midpoint: valid start bit
                            rx_state   <= RX_DATA;
                            rx_bit_idx <= 3'd0;
                        end else begin
                            // False start
                            rx_state <= RX_IDLE;
                        end
                    end else begin
                        rx_baud_cnt <= rx_baud_cnt + 1'b1;
                    end
                end

                RX_DATA: begin
                    if (rx_baud_cnt >= reg_baud_div - 1'b1) begin
                        rx_baud_cnt              <= 16'd0;
                        rx_shift_reg[rx_bit_idx] <= rx_bit;
                        if (rx_bit_idx == 3'd7) begin
                            rx_state <= RX_STOP;
                        end else begin
                            rx_bit_idx <= rx_bit_idx + 1'b1;
                        end
                    end else begin
                        rx_baud_cnt <= rx_baud_cnt + 1'b1;
                    end
                end

                RX_STOP: begin
                    if (rx_baud_cnt >= reg_baud_div - 1'b1) begin
                        rx_baud_cnt <= 16'd0;
                        rx_state    <= RX_IDLE;
                        if (rx_bit) begin
                            // Valid stop bit (high)
                            rx_data_reg   <= rx_shift_reg;
                            rx_done_pulse <= 1'b1;
                            frame_err     <= 1'b0;
                            if (rx_valid && !rx_pop) begin
                                rx_overrun <= 1'b1;
                            end else begin
                                rx_valid <= 1'b1;
                            end
                        end else begin
                            // Framing error: stop bit was low
                            frame_err <= 1'b1;
                        end
                    end else begin
                        rx_baud_cnt <= rx_baud_cnt + 1'b1;
                    end
                end

                default: rx_state <= RX_IDLE;
            endcase

            // Clear valid flag upon reading DATA register (pop RX byte)
            if (rx_pop && !rx_done_pulse) begin
                rx_valid   <= 1'b0;
                rx_overrun <= 1'b0;
                frame_err  <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // AXI4-Lite Write Channel (2-Phase Handshake)
    // -------------------------------------------------------------------------
    reg [ADDR_WIDTH-1:0] awaddr_latched;
    reg [DATA_WIDTH-1:0] wdata_latched;
    reg                  aw_done;
    reg                  w_done;

    // IRQ Status write event flag
    wire irq_stat_wr = (aw_done && w_done && !s_axi_bvalid && (awaddr_latched[7:0] == 8'h14));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready   <= 1'b0;
            s_axi_wready    <= 1'b0;
            s_axi_bvalid    <= 1'b0;
            s_axi_bresp     <= 2'b00;
            aw_done         <= 1'b0;
            w_done          <= 1'b0;
            awaddr_latched  <= {ADDR_WIDTH{1'b0}};
            wdata_latched   <= {DATA_WIDTH{1'b0}};

            reg_baud_div    <= DEFAULT_BAUD_DIV;
            reg_tx_en       <= 1'b0;
            reg_rx_en       <= 1'b0;
            reg_loopback_en <= 1'b0;
            reg_irq_enable  <= 2'b00;
            tx_trigger      <= 1'b0;
            tx_byte_in      <= 8'd0;
        end else begin
            tx_trigger <= 1'b0;

            // Address write handshake
            if (s_axi_awvalid && !aw_done) begin
                s_axi_awready  <= 1'b1;
                awaddr_latched <= s_axi_awaddr;
                aw_done        <= 1'b1;
            end else begin
                s_axi_awready  <= 1'b0;
            end

            // Data write handshake
            if (s_axi_wvalid && !w_done) begin
                s_axi_wready  <= 1'b1;
                wdata_latched <= s_axi_wdata;
                w_done        <= 1'b1;
            end else begin
                s_axi_wready  <= 1'b0;
            end

            // Write execution
            if (aw_done && w_done && !s_axi_bvalid) begin
                case (awaddr_latched[7:0])
                    8'h00: begin // DATA (Write: push TX byte)
                        tx_byte_in <= wdata_latched[7:0];
                        tx_trigger <= 1'b1;
                    end
                    8'h08: begin // CONTROL
                        reg_tx_en       <= wdata_latched[0];
                        reg_rx_en       <= wdata_latched[1];
                        reg_loopback_en <= wdata_latched[2];
                    end
                    8'h0C: begin // BAUD_DIV
                        if (wdata_latched[15:0] >= 16'd2)
                            reg_baud_div <= wdata_latched[15:0];
                    end
                    8'h10: begin // IRQ_ENABLE
                        reg_irq_enable <= wdata_latched[1:0];
                    end
                    8'h14: begin // IRQ_STATUS (handled in IRQ status block below)
                        // Handled via irq_stat_wr
                    end
                    default: ;
                endcase
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00; // OKAY
            end

            // Complete write response
            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
                aw_done      <= 1'b0;
                w_done       <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // IRQ Status Register (W1C + Event Latch)
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_irq_status <= 2'b00;
        end else begin
            // TX_EMPTY_IRQ (bit 0): Set on TX completion, cleared by writing 1
            if (tx_done_pulse) begin
                reg_irq_status[0] <= 1'b1;
            end else if (irq_stat_wr && wdata_latched[0]) begin
                reg_irq_status[0] <= 1'b0;
            end

            // RX_VALID_IRQ (bit 1): Set on valid RX byte reception, cleared by writing 1
            if (rx_done_pulse) begin
                reg_irq_status[1] <= 1'b1;
            end else if (irq_stat_wr && wdata_latched[1]) begin
                reg_irq_status[1] <= 1'b0;
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
                    8'h00: s_axi_rdata <= {24'd0, rx_data_reg}; // DATA (Read: pop RX byte)
                    8'h04: s_axi_rdata <= {27'd0, frame_err, rx_overrun, rx_valid, tx_empty, tx_busy};
                    8'h08: s_axi_rdata <= {29'd0, reg_loopback_en, reg_rx_en, reg_tx_en};
                    8'h0C: s_axi_rdata <= {16'd0, reg_baud_div};
                    8'h10: s_axi_rdata <= {30'd0, reg_irq_enable};
                    8'h14: s_axi_rdata <= {30'd0, reg_irq_status};
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
