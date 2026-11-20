// =============================================================================
// Module      : i2c_controller.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : I2C Master Controller with AXI4-Lite Slave (Slave S05).
//
// Register Map (Base: 0x40008000):
//   0x00 : I2C_CONTROL    [0] EN, [1] MASTER_MODE
//   0x04 : I2C_STATUS     [0] BUSY, [1] ACK_RECEIVED, [2] ARB_LOST, [3] TRANSFER_DONE (R/O)
//   0x08 : I2C_DATA       [7:0] Transmit or receive data byte (R/W)
//   0x0C : I2C_ADDRESS    [6:0] Target address, [7] R/W_N
//   0x10 : I2C_CLK_DIV    [15:0] SCL = clk / (4*(CLK_DIV+1))
//   0x14 : I2C_COMMAND    [0] START, [1] STOP, [2] WRITE_BYTE, [3] READ_BYTE (W/O)
//   0x18 : I2C_IRQ_ENABLE [0] DONE_IE, [1] NACK_IE
//   0x1C : I2C_IRQ_STATUS [0] DONE_IRQ, [1] NACK_IRQ (R/W1C)
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module i2c_controller #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst_n,

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

    input  wire                  scl_pad_i,
    output reg                   scl_pad_o,
    output reg                   scl_padoen_o,
    input  wire                  sda_pad_i,
    output reg                   sda_pad_o,
    output reg                   sda_padoen_o,
    inout  wire                  scl,
    inout  wire                  sda,
    output wire                  irq_i2c
);

    assign scl = scl_padoen_o ? 1'bz : 1'b0;
    assign sda = sda_padoen_o ? 1'bz : 1'b0;

    // Registers
    reg        reg_en, reg_master;
    reg        reg_busy, reg_ack_received, reg_arb_lost, reg_transfer_done;
    reg [7:0]  reg_data;
    reg [7:0]  reg_address;  // [6:0] addr, [7] rw_n
    reg [15:0] reg_clk_div;
    reg [1:0]  reg_irq_en, reg_irq_status;

    assign irq_i2c = |(reg_irq_status & reg_irq_en);

    // I2C state machine
    localparam I2C_IDLE       = 4'd0;
    localparam I2C_START_1    = 4'd1;
    localparam I2C_START_2    = 4'd2;
    localparam I2C_WRITE_BIT  = 4'd3;
    localparam I2C_WRITE_SCL  = 4'd4;
    localparam I2C_WRITE_DONE = 4'd5;
    localparam I2C_READ_BIT   = 4'd6;
    localparam I2C_READ_SCL   = 4'd7;
    localparam I2C_READ_DONE  = 4'd8;
    localparam I2C_ACK_PHASE  = 4'd9;
    localparam I2C_ACK_SCL    = 4'd10;
    localparam I2C_STOP_1     = 4'd11;
    localparam I2C_STOP_2     = 4'd12;
    localparam I2C_STOP_3     = 4'd13;

    reg [3:0]  state;
    reg [15:0] clk_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  shift_reg;
    reg        cmd_start, cmd_stop, cmd_write, cmd_read;
    reg [15:0] quarter_period;

    always @(*) quarter_period = reg_clk_div + 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= I2C_IDLE;
            clk_cnt <= 16'd0;
            bit_idx <= 3'd0;
            shift_reg <= 8'd0;
            scl_pad_o <= 1'b1; scl_padoen_o <= 1'b1;
            sda_pad_o <= 1'b1; sda_padoen_o <= 1'b1;
            reg_busy <= 1'b0; reg_ack_received <= 1'b0;
            reg_arb_lost <= 1'b0; reg_transfer_done <= 1'b0;
        end else if (reg_en) begin
            case (state)
                I2C_IDLE: begin
                    scl_padoen_o <= 1'b1; // Release SCL
                    if (cmd_start) begin
                        sda_padoen_o <= 1'b1; // SDA high first
                        reg_busy <= 1'b1;
                        reg_transfer_done <= 1'b0;
                        state <= I2C_START_1;
                        clk_cnt <= 16'd0;
                    end else if (cmd_write) begin
                        shift_reg <= reg_data;
                        bit_idx <= 3'd7;
                        reg_busy <= 1'b1;
                        reg_transfer_done <= 1'b0;
                        state <= I2C_WRITE_BIT;
                        clk_cnt <= 16'd0;
                    end else if (cmd_read) begin
                        sda_padoen_o <= 1'b1; // Release SDA for slave
                        bit_idx <= 3'd7;
                        shift_reg <= 8'd0;
                        reg_busy <= 1'b1;
                        reg_transfer_done <= 1'b0;
                        state <= I2C_READ_BIT;
                        clk_cnt <= 16'd0;
                    end else if (cmd_stop) begin
                        sda_padoen_o <= 1'b0; // Pull SDA low
                        reg_busy <= 1'b1;
                        state <= I2C_STOP_1;
                        clk_cnt <= 16'd0;
                    end
                end

                // START: SDA falls while SCL high
                I2C_START_1: begin
                    scl_padoen_o <= 1'b1; // SCL high
                    if (clk_cnt >= quarter_period) begin
                        sda_padoen_o <= 1'b0; // Pull SDA low -> START
                        clk_cnt <= 16'd0;
                        state <= I2C_START_2;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                I2C_START_2: begin
                    if (clk_cnt >= quarter_period) begin
                        scl_padoen_o <= 1'b0; // Pull SCL low
                        clk_cnt <= 16'd0;
                        state <= I2C_IDLE;
                        cmd_start <= 1'b0;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end

                // WRITE: 8 data bits + read ACK
                I2C_WRITE_BIT: begin
                    scl_padoen_o <= 1'b0; // SCL low
                    sda_padoen_o <= shift_reg[bit_idx] ? 1'b1 : 1'b0;
                    if (clk_cnt >= quarter_period) begin
                        clk_cnt <= 16'd0;
                        state <= I2C_WRITE_SCL;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                I2C_WRITE_SCL: begin
                    scl_padoen_o <= 1'b1; // SCL high
                    if (clk_cnt >= quarter_period) begin
                        scl_padoen_o <= 1'b0; // SCL low
                        clk_cnt <= 16'd0;
                        if (bit_idx == 3'd0) begin
                            state <= I2C_ACK_PHASE;
                        end else begin
                            bit_idx <= bit_idx - 1'b1;
                            state <= I2C_WRITE_BIT;
                        end
                    end else clk_cnt <= clk_cnt + 1'b1;
                end

                // ACK phase after write
                I2C_ACK_PHASE: begin
                    sda_padoen_o <= 1'b1; // Release SDA for ACK
                    scl_padoen_o <= 1'b0;
                    if (clk_cnt >= quarter_period) begin
                        clk_cnt <= 16'd0;
                        state <= I2C_ACK_SCL;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                I2C_ACK_SCL: begin
                    scl_padoen_o <= 1'b1;
                    if (clk_cnt >= quarter_period) begin
                        reg_ack_received <= sda_pad_i ? 1'b1 : 1'b0; // 0=ACK, 1=NACK
                        if (sda_pad_i) reg_irq_status <= reg_irq_status | 2'b10; // NACK IRQ
                        scl_padoen_o <= 1'b0;
                        clk_cnt <= 16'd0;
                        reg_transfer_done <= 1'b1;
                        reg_irq_status <= reg_irq_status | 2'b01; // DONE IRQ
                        reg_busy <= 1'b0;
                        cmd_write <= 1'b0;
                        state <= I2C_IDLE;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end

                // READ: 8 data bits + send ACK/NACK
                I2C_READ_BIT: begin
                    scl_padoen_o <= 1'b0;
                    sda_padoen_o <= 1'b1; // Release SDA
                    if (clk_cnt >= quarter_period) begin
                        clk_cnt <= 16'd0;
                        state <= I2C_READ_SCL;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                I2C_READ_SCL: begin
                    scl_padoen_o <= 1'b1;
                    if (clk_cnt >= quarter_period) begin
                        shift_reg[bit_idx] <= sda_pad_i;
                        scl_padoen_o <= 1'b0;
                        clk_cnt <= 16'd0;
                        if (bit_idx == 3'd0) begin
                            state <= I2C_READ_DONE;
                        end else begin
                            bit_idx <= bit_idx - 1'b1;
                            state <= I2C_READ_BIT;
                        end
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                I2C_READ_DONE: begin
                    // Send ACK (pull SDA low) for now
                    sda_padoen_o <= 1'b0; // ACK
                    scl_padoen_o <= 1'b0;
                    if (clk_cnt >= quarter_period) begin
                        scl_padoen_o <= 1'b1;
                        clk_cnt <= 16'd0;
                        state <= I2C_WRITE_DONE;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                I2C_WRITE_DONE: begin
                    if (clk_cnt >= quarter_period) begin
                        scl_padoen_o <= 1'b0;
                        sda_padoen_o <= 1'b1;
                        reg_data <= shift_reg;
                        reg_transfer_done <= 1'b1;
                        reg_irq_status <= reg_irq_status | 2'b01;
                        reg_busy <= 1'b0;
                        cmd_read <= 1'b0;
                        clk_cnt <= 16'd0;
                        state <= I2C_IDLE;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end

                // STOP: SDA rises while SCL high
                I2C_STOP_1: begin
                    sda_padoen_o <= 1'b0; // SDA low
                    scl_padoen_o <= 1'b0; // SCL low
                    if (clk_cnt >= quarter_period) begin
                        scl_padoen_o <= 1'b1; // SCL high
                        clk_cnt <= 16'd0;
                        state <= I2C_STOP_2;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                I2C_STOP_2: begin
                    if (clk_cnt >= quarter_period) begin
                        sda_padoen_o <= 1'b1; // SDA high -> STOP
                        clk_cnt <= 16'd0;
                        state <= I2C_STOP_3;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                I2C_STOP_3: begin
                    if (clk_cnt >= quarter_period) begin
                        reg_busy <= 1'b0;
                        cmd_stop <= 1'b0;
                        state <= I2C_IDLE;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end

                default: state <= I2C_IDLE;
            endcase
        end
    end

    // AXI Write
    reg [ADDR_WIDTH-1:0] awaddr_latched;
    reg aw_done, w_done;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b0; s_axi_wready <= 1'b0;
            s_axi_bvalid <= 1'b0; s_axi_bresp <= 2'b00;
            aw_done <= 1'b0; w_done <= 1'b0;
            awaddr_latched <= {ADDR_WIDTH{1'b0}};
            reg_en <= 1'b0; reg_master <= 1'b1;
            reg_address <= 8'd0; reg_clk_div <= 16'd9;
            reg_irq_en <= 2'b00; reg_irq_status <= 2'b00;
            cmd_start <= 1'b0; cmd_stop <= 1'b0;
            cmd_write <= 1'b0; cmd_read <= 1'b0;
        end else begin
            if (s_axi_awvalid && !aw_done) begin
                s_axi_awready <= 1'b1; awaddr_latched <= s_axi_awaddr; aw_done <= 1'b1;
            end else s_axi_awready <= 1'b0;

            if (s_axi_wvalid && !w_done) begin
                s_axi_wready <= 1'b1; w_done <= 1'b1;
            end else s_axi_wready <= 1'b0;

            if (aw_done && w_done && !s_axi_bvalid) begin
                case (awaddr_latched[7:0])
                    8'h00: begin reg_en <= s_axi_wdata[0]; reg_master <= s_axi_wdata[1]; end
                    8'h08: reg_data    <= s_axi_wdata[7:0];
                    8'h0C: reg_address <= s_axi_wdata[7:0];
                    8'h10: reg_clk_div <= s_axi_wdata[15:0];
                    8'h14: begin
                        cmd_start <= s_axi_wdata[0];
                        cmd_stop  <= s_axi_wdata[1];
                        cmd_write <= s_axi_wdata[2];
                        cmd_read  <= s_axi_wdata[3];
                    end
                    8'h18: reg_irq_en <= s_axi_wdata[1:0];
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
                    8'h00: s_axi_rdata <= {30'd0, reg_master, reg_en};
                    8'h04: s_axi_rdata <= {28'd0, reg_transfer_done, reg_arb_lost, reg_ack_received, reg_busy};
                    8'h08: s_axi_rdata <= {24'd0, reg_data};
                    8'h0C: s_axi_rdata <= {24'd0, reg_address};
                    8'h10: s_axi_rdata <= {16'd0, reg_clk_div};
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
