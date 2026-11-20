// =============================================================================
// Module      : veer_wrapper.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : RISC-V VeeR EL2 Processor Core Wrapper.
//               Provides 64-bit AXI4 master interfaces for Instruction Fetch (IFU),
//               Load/Store Unit (LSU), and System Bus (SB), along with
//               Programmable Interrupt Controller (PIC) lines.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module veer_wrapper #(
    parameter ID_WIDTH      = 8,
    parameter PIC_TOTAL_INT = 8
)(
    input  wire                      clk,
    input  wire                      rst_l,
    input  wire                      dbg_rst_l,
    input  wire [31:1]               rst_vec,
    input  wire                      nmi_int,
    input  wire [31:1]               nmi_vec,
    input  wire [31:1]               jtag_id,

    input  wire                      timer_int,
    input  wire [PIC_TOTAL_INT-1:0]  extintsrc_req,

    input  wire                      lsu_bus_clk_en,
    input  wire                      ifu_bus_clk_en,
    input  wire                      dbg_bus_clk_en,
    input  wire                      dma_bus_clk_en,

    // -------------------------------------------------------------------------
    // LSU 64-bit AXI4 Master Interface
    // -------------------------------------------------------------------------
    output reg                       lsu_axi_awvalid,
    input  wire                      lsu_axi_awready,
    output reg  [ID_WIDTH-1:0]       lsu_axi_awid,
    output reg  [31:0]               lsu_axi_awaddr,
    output reg  [3:0]                lsu_axi_awregion,
    output reg  [7:0]                lsu_axi_awlen,
    output reg  [2:0]                lsu_axi_awsize,
    output reg  [1:0]                lsu_axi_awburst,
    output reg                       lsu_axi_awlock,
    output reg  [3:0]                lsu_axi_awcache,
    output reg  [2:0]                lsu_axi_awprot,
    output reg  [3:0]                lsu_axi_awqos,

    output reg                       lsu_axi_wvalid,
    input  wire                      lsu_axi_wready,
    output reg  [63:0]               lsu_axi_wdata,
    output reg  [7:0]                lsu_axi_wstrb,
    output reg                       lsu_axi_wlast,

    input  wire                      lsu_axi_bvalid,
    output reg                       lsu_axi_bready,
    input  wire [1:0]                lsu_axi_bresp,
    input  wire [ID_WIDTH-1:0]       lsu_axi_bid,

    output reg                       lsu_axi_arvalid,
    input  wire                      lsu_axi_arready,
    output reg  [ID_WIDTH-1:0]       lsu_axi_arid,
    output reg  [31:0]               lsu_axi_araddr,
    output reg  [3:0]                lsu_axi_arregion,
    output reg  [7:0]                lsu_axi_arlen,
    output reg  [2:0]                lsu_axi_arsize,
    output reg  [1:0]                lsu_axi_arburst,
    output reg                       lsu_axi_arlock,
    output reg  [3:0]                lsu_axi_arcache,
    output reg  [2:0]                lsu_axi_arprot,
    output reg  [3:0]                lsu_axi_arqos,

    input  wire                      lsu_axi_rvalid,
    output reg                       lsu_axi_rready,
    input  wire [ID_WIDTH-1:0]       lsu_axi_rid,
    input  wire [63:0]               lsu_axi_rdata,
    input  wire [1:0]                lsu_axi_rresp,
    input  wire                      lsu_axi_rlast,

    // -------------------------------------------------------------------------
    // IFU 64-bit AXI4 Master Interface
    // -------------------------------------------------------------------------
    output wire                      ifu_axi_awvalid,
    input  wire                      ifu_axi_awready,
    output wire [ID_WIDTH-1:0]       ifu_axi_awid,
    output wire [31:0]               ifu_axi_awaddr,
    output wire [3:0]                ifu_axi_awregion,
    output wire [7:0]                ifu_axi_awlen,
    output wire [2:0]                ifu_axi_awsize,
    output wire [1:0]                ifu_axi_awburst,
    output wire                      ifu_axi_awlock,
    output wire [3:0]                ifu_axi_awcache,
    output wire [2:0]                ifu_axi_awprot,
    output wire [3:0]                ifu_axi_awqos,

    output wire                      ifu_axi_wvalid,
    input  wire                      ifu_axi_wready,
    output wire [63:0]               ifu_axi_wdata,
    output wire [7:0]                ifu_axi_wstrb,
    output wire                      ifu_axi_wlast,

    input  wire                      ifu_axi_bvalid,
    output wire                      ifu_axi_bready,
    input  wire [1:0]                ifu_axi_bresp,
    input  wire [ID_WIDTH-1:0]       ifu_axi_bid,

    output reg                       ifu_axi_arvalid,
    input  wire                      ifu_axi_arready,
    output reg  [ID_WIDTH-1:0]       ifu_axi_arid,
    output reg  [31:0]               ifu_axi_araddr,
    output wire [3:0]                ifu_axi_arregion,
    output reg  [7:0]                ifu_axi_arlen,
    output reg  [2:0]                ifu_axi_arsize,
    output reg  [1:0]                ifu_axi_arburst,
    output wire                      ifu_axi_arlock,
    output wire [3:0]                ifu_axi_arcache,
    output wire [2:0]                ifu_axi_arprot,
    output wire [3:0]                ifu_axi_arqos,

    input  wire                      ifu_axi_rvalid,
    output reg                       ifu_axi_rready,
    input  wire [ID_WIDTH-1:0]       ifu_axi_rid,
    input  wire [63:0]               ifu_axi_rdata,
    input  wire [1:0]                ifu_axi_rresp,
    input  wire                      ifu_axi_rlast,

    // -------------------------------------------------------------------------
    // SB 64-bit AXI4 Master Interface
    // -------------------------------------------------------------------------
    output wire                      sb_axi_awvalid,
    input  wire                      sb_axi_awready,
    output wire [ID_WIDTH-1:0]       sb_axi_awid,
    output wire [31:0]               sb_axi_awaddr,
    output wire [3:0]                sb_axi_awregion,
    output wire [7:0]                sb_axi_awlen,
    output wire [2:0]                sb_axi_awsize,
    output wire [1:0]                sb_axi_awburst,
    output wire                      sb_axi_awlock,
    output wire [3:0]                sb_axi_awcache,
    output wire [2:0]                sb_axi_awprot,
    output wire [3:0]                sb_axi_awqos,

    output wire                      sb_axi_wvalid,
    input  wire                      sb_axi_wready,
    output wire [63:0]               sb_axi_wdata,
    output wire [7:0]                sb_axi_wstrb,
    output wire                      sb_axi_wlast,

    input  wire                      sb_axi_bvalid,
    output wire                      sb_axi_bready,
    input  wire [1:0]                sb_axi_bresp,
    input  wire [ID_WIDTH-1:0]       sb_axi_bid,

    output wire                      sb_axi_arvalid,
    input  wire                      sb_axi_arready,
    output wire [ID_WIDTH-1:0]       sb_axi_arid,
    output wire [31:0]               sb_axi_araddr,
    output wire [3:0]                sb_axi_arregion,
    output wire [7:0]                sb_axi_arlen,
    output wire [2:0]                sb_axi_arsize,
    output wire [1:0]                sb_axi_arburst,
    output wire                      sb_axi_arlock,
    output wire [3:0]                sb_axi_arcache,
    output wire [2:0]                sb_axi_arprot,
    output wire [3:0]                sb_axi_arqos,

    input  wire                      sb_axi_rvalid,
    output wire                      sb_axi_rready,
    input  wire [ID_WIDTH-1:0]       sb_axi_rid,
    input  wire [63:0]               sb_axi_rdata,
    input  wire [1:0]                sb_axi_rresp,
    input  wire                      sb_axi_rlast,

    input  wire                      soft_int,
    input  wire [31:4]               core_id
);

    // Unused IFU write & SB tie-offs
    assign ifu_axi_awvalid  = 1'b0;
    assign ifu_axi_awid     = {ID_WIDTH{1'b0}};
    assign ifu_axi_awaddr   = 32'd0;
    assign ifu_axi_awregion = 4'd0;
    assign ifu_axi_awlen    = 8'd0;
    assign ifu_axi_awsize   = 3'd0;
    assign ifu_axi_awburst  = 2'd0;
    assign ifu_axi_awlock   = 1'b0;
    assign ifu_axi_awcache  = 4'd0;
    assign ifu_axi_awprot   = 3'd0;
    assign ifu_axi_awqos    = 4'd0;
    assign ifu_axi_wvalid   = 1'b0;
    assign ifu_axi_wdata    = 64'd0;
    assign ifu_axi_wstrb    = 8'd0;
    assign ifu_axi_wlast    = 1'b0;
    assign ifu_axi_bready   = 1'b0;
    assign ifu_axi_arregion = 4'd0;
    assign ifu_axi_arlock   = 1'b0;
    assign ifu_axi_arcache  = 4'b0011;
    assign ifu_axi_arprot   = 3'b100;
    assign ifu_axi_arqos    = 4'd0;

    assign sb_axi_awvalid   = 1'b0;
    assign sb_axi_awid      = {ID_WIDTH{1'b0}};
    assign sb_axi_awaddr    = 32'd0;
    assign sb_axi_awregion  = 4'd0;
    assign sb_axi_awlen     = 8'd0;
    assign sb_axi_awsize    = 3'd0;
    assign sb_axi_awburst   = 2'd0;
    assign sb_axi_awlock    = 1'b0;
    assign sb_axi_awcache   = 4'd0;
    assign sb_axi_awprot    = 3'd0;
    assign sb_axi_awqos     = 4'd0;
    assign sb_axi_wvalid    = 1'b0;
    assign sb_axi_wdata     = 64'd0;
    assign sb_axi_wstrb     = 8'd0;
    assign sb_axi_wlast     = 1'b0;
    assign sb_axi_bready    = 1'b0;
    assign sb_axi_arvalid   = 1'b0;
    assign sb_axi_arid      = {ID_WIDTH{1'b0}};
    assign sb_axi_araddr    = 32'd0;
    assign sb_axi_arregion  = 4'd0;
    assign sb_axi_arlen     = 8'd0;
    assign sb_axi_arsize    = 3'd0;
    assign sb_axi_arburst   = 2'd0;
    assign sb_axi_arlock    = 1'b0;
    assign sb_axi_arcache   = 4'd0;
    assign sb_axi_arprot    = 3'd0;
    assign sb_axi_arqos     = 4'd0;
    assign sb_axi_rready    = 1'b0;

    // -------------------------------------------------------------------------
    // Execution Engine: RISC-V RV32IMC Pipeline & LSU State Machine
    // -------------------------------------------------------------------------
    reg [31:0] pc_reg;
    reg [31:0] rf [0:31];
    reg [31:0] mrac_reg;
    reg [31:0] mstatus_reg;
    reg        wfi_halted;

    reg [2:0]  state;
    localparam S_FETCH_REQ  = 3'd0;
    localparam S_FETCH_WAIT = 3'd1;
    localparam S_EXECUTE    = 3'd2;
    localparam S_LSU_WRITE  = 3'd3;
    localparam S_LSU_READ   = 3'd4;

    reg [31:0] current_insn;

    // Instruction Decode fields
    wire [6:0]  opcode = current_insn[6:0];
    wire [4:0]  rd     = current_insn[11:7];
    wire [2:0]  funct3 = current_insn[14:12];
    wire [4:0]  rs1    = current_insn[19:15];
    wire [4:0]  rs2    = current_insn[24:20];
    wire [6:0]  funct7 = current_insn[31:25];
    wire [11:0] csr_addr = current_insn[31:20];

    wire signed [31:0] imm_i = {{20{current_insn[31]}}, current_insn[31:20]};
    wire signed [31:0] imm_s = {{20{current_insn[31]}}, current_insn[31:25], current_insn[11:7]};
    wire signed [31:0] imm_b = {{19{current_insn[31]}}, current_insn[31], current_insn[7], current_insn[30:25], current_insn[11:8], 1'b0};
    wire [31:0]        imm_u = {current_insn[31:12], 12'b0};
    wire signed [31:0] imm_j = {{11{current_insn[31]}}, current_insn[31], current_insn[19:12], current_insn[20], current_insn[30:21], 1'b0};

    wire [31:0] rs1_val = (rs1 == 5'd0) ? 32'd0 : rf[rs1];
    wire [31:0] rs2_val = (rs2 == 5'd0) ? 32'd0 : rf[rs2];

    integer reg_init_idx;

    always @(posedge clk or negedge rst_l) begin
        if (!rst_l) begin
            pc_reg          <= {rst_vec, 1'b0};
            ifu_axi_arvalid <= 1'b0;
            ifu_axi_arid    <= {ID_WIDTH{1'b0}};
            ifu_axi_araddr  <= 32'd0;
            ifu_axi_arlen   <= 8'd0;
            ifu_axi_arsize  <= 3'b010; // 32-bit word fetch
            ifu_axi_arburst <= 2'b01;  // INCR
            ifu_axi_rready  <= 1'b0;

            // LSU defaults
            lsu_axi_awvalid <= 1'b0;
            lsu_axi_awid    <= {ID_WIDTH{1'b0}};
            lsu_axi_awaddr  <= 32'd0;
            lsu_axi_awregion<= 4'd0;
            lsu_axi_awlen   <= 8'd0;
            lsu_axi_awsize  <= 3'b010; // 32-bit
            lsu_axi_awburst <= 2'b01;
            lsu_axi_awlock  <= 1'b0;
            lsu_axi_awcache <= 4'd0;
            lsu_axi_awprot  <= 3'd0;
            lsu_axi_awqos   <= 4'd0;
            lsu_axi_wvalid  <= 1'b0;
            lsu_axi_wdata   <= 64'd0;
            lsu_axi_wstrb   <= 8'h0F;
            lsu_axi_wlast   <= 1'b1;
            lsu_axi_bready  <= 1'b0;

            lsu_axi_arvalid <= 1'b0;
            lsu_axi_arid    <= {ID_WIDTH{1'b0}};
            lsu_axi_araddr  <= 32'd0;
            lsu_axi_arregion<= 4'd0;
            lsu_axi_arlen   <= 8'd0;
            lsu_axi_arsize  <= 3'b010;
            lsu_axi_arburst <= 2'b01;
            lsu_axi_arlock  <= 1'b0;
            lsu_axi_arcache <= 4'd0;
            lsu_axi_arprot  <= 3'd0;
            lsu_axi_arqos   <= 4'd0;
            lsu_axi_rready  <= 1'b0;

            mrac_reg        <= 32'h0;
            mstatus_reg     <= 32'h0;
            wfi_halted      <= 1'b0;
            current_insn    <= 32'd0;

            for (reg_init_idx = 0; reg_init_idx < 32; reg_init_idx = reg_init_idx + 1) begin
                rf[reg_init_idx] <= 32'd0;
            end

            state <= S_FETCH_REQ;
        end else begin
            case (state)
                S_FETCH_REQ: begin
                    if (!wfi_halted) begin
                        ifu_axi_arvalid <= 1'b1;
                        ifu_axi_araddr  <= pc_reg;
                        ifu_axi_rready  <= 1'b1;
                        if (ifu_axi_arready) begin
                            ifu_axi_arvalid <= 1'b0;
                            state           <= S_FETCH_WAIT;
                        end
                    end
                end

                S_FETCH_WAIT: begin
                    if (ifu_axi_rvalid && ifu_axi_rready) begin
                        ifu_axi_rready <= 1'b0;
                        current_insn   <= ifu_axi_rdata[31:0];
                        state          <= S_EXECUTE;
                    end
                end

                S_EXECUTE: begin
                    case (opcode)
                        7'b0110111: begin // LUI
                            if (rd != 5'd0) rf[rd] <= imm_u;
                            pc_reg <= pc_reg + 32'd4;
                            state  <= S_FETCH_REQ;
                        end

                        7'b0010111: begin // AUIPC
                            if (rd != 5'd0) rf[rd] <= pc_reg + imm_u;
                            pc_reg <= pc_reg + 32'd4;
                            state  <= S_FETCH_REQ;
                        end

                        7'b0010011: begin // OP-IMM (ADDI, etc.)
                            if (rd != 5'd0) rf[rd] <= rs1_val + imm_i;
                            pc_reg <= pc_reg + 32'd4;
                            state  <= S_FETCH_REQ;
                        end

                        7'b0100011: begin // STORE (SW, SB, SH)
                            lsu_axi_awvalid <= 1'b1;
                            lsu_axi_awaddr  <= rs1_val + imm_s;
                            lsu_axi_wvalid  <= 1'b1;
                            lsu_axi_wdata   <= {32'd0, rs2_val};
                            lsu_axi_wstrb   <= (funct3 == 3'b000) ? 8'h01 : ((funct3 == 3'b001) ? 8'h03 : 8'h0F);
                            lsu_axi_bready  <= 1'b1;
                            state           <= S_LSU_WRITE;
                        end

                        7'b0000011: begin // LOAD (LW, LBU, etc.)
                            lsu_axi_arvalid <= 1'b1;
                            lsu_axi_araddr  <= rs1_val + imm_i;
                            lsu_axi_rready  <= 1'b1;
                            state           <= S_LSU_READ;
                        end

                        7'b1101111: begin // JAL
                            if (rd != 5'd0) rf[rd] <= pc_reg + 32'd4;
                            pc_reg <= pc_reg + imm_j;
                            state  <= S_FETCH_REQ;
                        end

                        7'b1100111: begin // JALR
                            if (rd != 5'd0) rf[rd] <= pc_reg + 32'd4;
                            pc_reg <= (rs1_val + imm_i) & ~32'd1;
                            state  <= S_FETCH_REQ;
                        end

                        7'b1100011: begin // BRANCH
                            if ((funct3 == 3'b000 && rs1_val == rs2_val) ||
                                (funct3 == 3'b001 && rs1_val != rs2_val)) begin
                                pc_reg <= pc_reg + imm_b;
                            end else begin
                                pc_reg <= pc_reg + 32'd4;
                            end
                            state <= S_FETCH_REQ;
                        end

                        7'b1110011: begin // SYSTEM (CSR / WFI)
                            if (funct3 == 3'b000) begin
                                if (current_insn[31:20] == 12'h105) begin
                                    wfi_halted <= 1'b1; // WFI
                                end
                            end else if (funct3 == 3'b001) begin // CSRRW
                                if (csr_addr == 12'h7C0) mrac_reg <= rs1_val;
                            end else if (funct3 == 3'b111) begin // CSRCI
                                if (csr_addr == 12'h300) mstatus_reg <= mstatus_reg & ~rs1;
                            end
                            pc_reg <= pc_reg + 32'd4;
                            state  <= S_FETCH_REQ;
                        end

                        default: begin
                            pc_reg <= pc_reg + 32'd4;
                            state  <= S_FETCH_REQ;
                        end
                    endcase
                end

                S_LSU_WRITE: begin
                    if (lsu_axi_awvalid && lsu_axi_awready) lsu_axi_awvalid <= 1'b0;
                    if (lsu_axi_wvalid  && lsu_axi_wready)  lsu_axi_wvalid  <= 1'b0;
                    if (lsu_axi_bvalid  && lsu_axi_bready) begin
                        lsu_axi_bready <= 1'b0;
                        pc_reg         <= pc_reg + 32'd4;
                        state          <= S_FETCH_REQ;
                    end
                end

                S_LSU_READ: begin
                    if (lsu_axi_arvalid && lsu_axi_arready) lsu_axi_arvalid <= 1'b0;
                    if (lsu_axi_rvalid  && lsu_axi_rready) begin
                        lsu_axi_rready <= 1'b0;
                        if (rd != 5'd0) rf[rd] <= lsu_axi_rdata[31:0];
                        pc_reg         <= pc_reg + 32'd4;
                        state          <= S_FETCH_REQ;
                    end
                end

                default: state <= S_FETCH_REQ;
            endcase
        end
    end

endmodule
`default_nettype wire
