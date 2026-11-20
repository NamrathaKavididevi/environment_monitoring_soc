// =============================================================================
// Module      : aes.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : AES-128 Encryption Core — Behavioral Model (FIPS 197).
//               Standalone IP, NOT connected to SoC fabric.
//               Uses AXI4-Lite registers for key/plaintext/ciphertext.
//               Encryption runs as a pure combinational reference function;
//               result is registered after START with one-cycle latency per step.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module aes #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire [ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  wire                   s_axi_awvalid,
    output reg                    s_axi_awready,
    input  wire [DATA_WIDTH-1:0]  s_axi_wdata,
    input  wire [3:0]             s_axi_wstrb,
    input  wire                   s_axi_wvalid,
    output reg                    s_axi_wready,
    output reg  [1:0]             s_axi_bresp,
    output reg                    s_axi_bvalid,
    input  wire                   s_axi_bready,
    input  wire [ADDR_WIDTH-1:0]  s_axi_araddr,
    input  wire                   s_axi_arvalid,
    output reg                    s_axi_arready,
    output reg  [DATA_WIDTH-1:0]  s_axi_rdata,
    output reg  [1:0]             s_axi_rresp,
    output reg                    s_axi_rvalid,
    input  wire                   s_axi_rready
);

    // =========================================================================
    // S-Box (FIPS 197)
    // =========================================================================
    function automatic [7:0] SBOX(input [7:0] x);
        case(x)
8'h00:SBOX=8'h63;8'h01:SBOX=8'h7c;8'h02:SBOX=8'h77;8'h03:SBOX=8'h7b;8'h04:SBOX=8'hf2;8'h05:SBOX=8'h6b;8'h06:SBOX=8'h6f;8'h07:SBOX=8'hc5;
8'h08:SBOX=8'h30;8'h09:SBOX=8'h01;8'h0a:SBOX=8'h67;8'h0b:SBOX=8'h2b;8'h0c:SBOX=8'hfe;8'h0d:SBOX=8'hd7;8'h0e:SBOX=8'hab;8'h0f:SBOX=8'h76;
8'h10:SBOX=8'hca;8'h11:SBOX=8'h82;8'h12:SBOX=8'hc9;8'h13:SBOX=8'h7d;8'h14:SBOX=8'hfa;8'h15:SBOX=8'h59;8'h16:SBOX=8'h47;8'h17:SBOX=8'hf0;
8'h18:SBOX=8'had;8'h19:SBOX=8'hd4;8'h1a:SBOX=8'ha2;8'h1b:SBOX=8'haf;8'h1c:SBOX=8'h9c;8'h1d:SBOX=8'ha4;8'h1e:SBOX=8'h72;8'h1f:SBOX=8'hc0;
8'h20:SBOX=8'hb7;8'h21:SBOX=8'hfd;8'h22:SBOX=8'h93;8'h23:SBOX=8'h26;8'h24:SBOX=8'h36;8'h25:SBOX=8'h3f;8'h26:SBOX=8'hf7;8'h27:SBOX=8'hcc;
8'h28:SBOX=8'h34;8'h29:SBOX=8'ha5;8'h2a:SBOX=8'he5;8'h2b:SBOX=8'hf1;8'h2c:SBOX=8'h71;8'h2d:SBOX=8'hd8;8'h2e:SBOX=8'h31;8'h2f:SBOX=8'h15;
8'h30:SBOX=8'h04;8'h31:SBOX=8'hc7;8'h32:SBOX=8'h23;8'h33:SBOX=8'hc3;8'h34:SBOX=8'h18;8'h35:SBOX=8'h96;8'h36:SBOX=8'h05;8'h37:SBOX=8'h9a;
8'h38:SBOX=8'h07;8'h39:SBOX=8'h12;8'h3a:SBOX=8'h80;8'h3b:SBOX=8'he2;8'h3c:SBOX=8'heb;8'h3d:SBOX=8'h27;8'h3e:SBOX=8'hb2;8'h3f:SBOX=8'h75;
8'h40:SBOX=8'h09;8'h41:SBOX=8'h83;8'h42:SBOX=8'h2c;8'h43:SBOX=8'h1a;8'h44:SBOX=8'h1b;8'h45:SBOX=8'h6e;8'h46:SBOX=8'h5a;8'h47:SBOX=8'ha0;
8'h48:SBOX=8'h52;8'h49:SBOX=8'h3b;8'h4a:SBOX=8'hd6;8'h4b:SBOX=8'hb3;8'h4c:SBOX=8'h29;8'h4d:SBOX=8'he3;8'h4e:SBOX=8'h2f;8'h4f:SBOX=8'h84;
8'h50:SBOX=8'h53;8'h51:SBOX=8'hd1;8'h52:SBOX=8'h00;8'h53:SBOX=8'hed;8'h54:SBOX=8'h20;8'h55:SBOX=8'hfc;8'h56:SBOX=8'hb1;8'h57:SBOX=8'h5b;
8'h58:SBOX=8'h6a;8'h59:SBOX=8'hcb;8'h5a:SBOX=8'hbe;8'h5b:SBOX=8'h39;8'h5c:SBOX=8'h4a;8'h5d:SBOX=8'h4c;8'h5e:SBOX=8'h58;8'h5f:SBOX=8'hcf;
8'h60:SBOX=8'hd0;8'h61:SBOX=8'hef;8'h62:SBOX=8'haa;8'h63:SBOX=8'hfb;8'h64:SBOX=8'h43;8'h65:SBOX=8'h4d;8'h66:SBOX=8'h33;8'h67:SBOX=8'h85;
8'h68:SBOX=8'h45;8'h69:SBOX=8'hf9;8'h6a:SBOX=8'h02;8'h6b:SBOX=8'h7f;8'h6c:SBOX=8'h50;8'h6d:SBOX=8'h3c;8'h6e:SBOX=8'h9f;8'h6f:SBOX=8'ha8;
8'h70:SBOX=8'h51;8'h71:SBOX=8'ha3;8'h72:SBOX=8'h40;8'h73:SBOX=8'h8f;8'h74:SBOX=8'h92;8'h75:SBOX=8'h9d;8'h76:SBOX=8'h38;8'h77:SBOX=8'hf5;
8'h78:SBOX=8'hbc;8'h79:SBOX=8'hb6;8'h7a:SBOX=8'hda;8'h7b:SBOX=8'h21;8'h7c:SBOX=8'h10;8'h7d:SBOX=8'hff;8'h7e:SBOX=8'hf3;8'h7f:SBOX=8'hd2;
8'h80:SBOX=8'hcd;8'h81:SBOX=8'h0c;8'h82:SBOX=8'h13;8'h83:SBOX=8'hec;8'h84:SBOX=8'h5f;8'h85:SBOX=8'h97;8'h86:SBOX=8'h44;8'h87:SBOX=8'h17;
8'h88:SBOX=8'hc4;8'h89:SBOX=8'ha7;8'h8a:SBOX=8'h7e;8'h8b:SBOX=8'h3d;8'h8c:SBOX=8'h64;8'h8d:SBOX=8'h5d;8'h8e:SBOX=8'h19;8'h8f:SBOX=8'h73;
8'h90:SBOX=8'h60;8'h91:SBOX=8'h81;8'h92:SBOX=8'h4f;8'h93:SBOX=8'hdc;8'h94:SBOX=8'h22;8'h95:SBOX=8'h2a;8'h96:SBOX=8'h90;8'h97:SBOX=8'h88;
8'h98:SBOX=8'h46;8'h99:SBOX=8'hee;8'h9a:SBOX=8'hb8;8'h9b:SBOX=8'h14;8'h9c:SBOX=8'hde;8'h9d:SBOX=8'h5e;8'h9e:SBOX=8'h0b;8'h9f:SBOX=8'hdb;
8'ha0:SBOX=8'he0;8'ha1:SBOX=8'h32;8'ha2:SBOX=8'h3a;8'ha3:SBOX=8'h0a;8'ha4:SBOX=8'h49;8'ha5:SBOX=8'h06;8'ha6:SBOX=8'h24;8'ha7:SBOX=8'h5c;
8'ha8:SBOX=8'hc2;8'ha9:SBOX=8'hd3;8'haa:SBOX=8'hac;8'hab:SBOX=8'h62;8'hac:SBOX=8'h91;8'had:SBOX=8'h95;8'hae:SBOX=8'he4;8'haf:SBOX=8'h79;
8'hb0:SBOX=8'he7;8'hb1:SBOX=8'hc8;8'hb2:SBOX=8'h37;8'hb3:SBOX=8'h6d;8'hb4:SBOX=8'h8d;8'hb5:SBOX=8'hd5;8'hb6:SBOX=8'h4e;8'hb7:SBOX=8'ha9;
8'hb8:SBOX=8'h6c;8'hb9:SBOX=8'h56;8'hba:SBOX=8'hf4;8'hbb:SBOX=8'hea;8'hbc:SBOX=8'h65;8'hbd:SBOX=8'h7a;8'hbe:SBOX=8'hae;8'hbf:SBOX=8'h08;
8'hc0:SBOX=8'hba;8'hc1:SBOX=8'h78;8'hc2:SBOX=8'h25;8'hc3:SBOX=8'h2e;8'hc4:SBOX=8'h1c;8'hc5:SBOX=8'ha6;8'hc6:SBOX=8'hb4;8'hc7:SBOX=8'hc6;
8'hc8:SBOX=8'he8;8'hc9:SBOX=8'hdd;8'hca:SBOX=8'h74;8'hcb:SBOX=8'h1f;8'hcc:SBOX=8'h4b;8'hcd:SBOX=8'hbd;8'hce:SBOX=8'h8b;8'hcf:SBOX=8'h8a;
8'hd0:SBOX=8'h70;8'hd1:SBOX=8'h3e;8'hd2:SBOX=8'hb5;8'hd3:SBOX=8'h66;8'hd4:SBOX=8'h48;8'hd5:SBOX=8'h03;8'hd6:SBOX=8'hf6;8'hd7:SBOX=8'h0e;
8'hd8:SBOX=8'h61;8'hd9:SBOX=8'h35;8'hda:SBOX=8'h57;8'hdb:SBOX=8'hb9;8'hdc:SBOX=8'h86;8'hdd:SBOX=8'hc1;8'hde:SBOX=8'h1d;8'hdf:SBOX=8'h9e;
8'he0:SBOX=8'he1;8'he1:SBOX=8'hf8;8'he2:SBOX=8'h98;8'he3:SBOX=8'h11;8'he4:SBOX=8'h69;8'he5:SBOX=8'hd9;8'he6:SBOX=8'h8e;8'he7:SBOX=8'h94;
8'he8:SBOX=8'h9b;8'he9:SBOX=8'h1e;8'hea:SBOX=8'h87;8'heb:SBOX=8'he9;8'hec:SBOX=8'hce;8'hed:SBOX=8'h55;8'hee:SBOX=8'h28;8'hef:SBOX=8'hdf;
8'hf0:SBOX=8'h8c;8'hf1:SBOX=8'ha1;8'hf2:SBOX=8'h89;8'hf3:SBOX=8'h0d;8'hf4:SBOX=8'hbf;8'hf5:SBOX=8'he6;8'hf6:SBOX=8'h42;8'hf7:SBOX=8'h68;
8'hf8:SBOX=8'h41;8'hf9:SBOX=8'h99;8'hfa:SBOX=8'h2d;8'hfb:SBOX=8'h0f;8'hfc:SBOX=8'hb0;8'hfd:SBOX=8'h54;8'hfe:SBOX=8'hbb;8'hff:SBOX=8'h16;
            default: SBOX=8'h00;
        endcase
    endfunction

    function automatic [7:0] RCON(input [3:0] r);
        case(r)
            4'd1:RCON=8'h01; 4'd2:RCON=8'h02; 4'd3:RCON=8'h04; 4'd4:RCON=8'h08;
            4'd5:RCON=8'h10; 4'd6:RCON=8'h20; 4'd7:RCON=8'h40; 4'd8:RCON=8'h80;
            4'd9:RCON=8'h1b; 4'd10:RCON=8'h36;
            default:RCON=8'h00;
        endcase
    endfunction

    function automatic [7:0] xt(input [7:0] a);
        xt = a[7] ? ({a[6:0],1'b0}^8'h1b) : {a[6:0],1'b0};
    endfunction

    // =========================================================================
    // Full AES-128 encrypt as a single combinational function
    // Input/output: 128-bit big-endian (MSByte=byte0 of plaintext)
    // =========================================================================
    function automatic [127:0] AES128_encrypt(
        input [127:0] pt,   // plaintext
        input [127:0] key   // 128-bit key
    );
        // We store state as byte array: b[0..15] where b[0]=pt[127:120]
        // AES column-major: col c = {b[c*4], b[c*4+1], b[c*4+2], b[c*4+3]}
        reg [7:0] b[0:15];
        reg [7:0] tmp[0:15];
        // Key schedule: 44 words
        reg [31:0] W[0:43];
        reg [31:0] wt;
        reg [3:0]  r_idx;
        integer i, r;

        begin
            // --- Load plaintext into byte array ---
            for (i=0;i<16;i=i+1)
                b[i] = pt[127-i*8 -: 8];

            // --- Key Expansion ---
            W[0] = key[127:96]; W[1] = key[95:64];
            W[2] = key[63:32];  W[3] = key[31:0];
            for (i=4; i<44; i=i+1) begin
                wt = W[i-1];
                if (i%4 == 0) begin
                    // RotWord + SubWord + Rcon
                    r_idx = i / 4;
                    wt = {SBOX(wt[23:16])^RCON(r_idx),
                          SBOX(wt[15:8]),
                          SBOX(wt[7:0]),
                          SBOX(wt[31:24])};
                end
                W[i] = W[i-4] ^ wt;
            end

            // --- Initial AddRoundKey (round 0) ---
            for (i=0;i<4;i=i+1) begin
                b[i*4]   = b[i*4]   ^ W[i][31:24];
                b[i*4+1] = b[i*4+1] ^ W[i][23:16];
                b[i*4+2] = b[i*4+2] ^ W[i][15:8];
                b[i*4+3] = b[i*4+3] ^ W[i][7:0];
            end

            // --- Rounds 1..10 ---
            for (r=1; r<=10; r=r+1) begin
                // SubBytes
                for (i=0;i<16;i=i+1) tmp[i] = SBOX(b[i]);
                // ShiftRows: row 1 shift left 1, row 2 shift left 2, row 3 shift left 3
                // After sub, reorganize by rows:
                // row 0: tmp[0],tmp[4],tmp[8],tmp[12]  -> no shift
                // row 1: tmp[1],tmp[5],tmp[9],tmp[13]  -> shift left 1 -> tmp[5],tmp[9],tmp[13],tmp[1]
                // row 2: tmp[2],tmp[6],tmp[10],tmp[14] -> shift left 2 -> tmp[10],tmp[14],tmp[2],tmp[6]
                // row 3: tmp[3],tmp[7],tmp[11],tmp[15] -> shift left 3 -> tmp[15],tmp[3],tmp[7],tmp[11]
                b[0]=tmp[0];  b[4]=tmp[4];  b[8]=tmp[8];  b[12]=tmp[12]; // row0
                b[1]=tmp[5];  b[5]=tmp[9];  b[9]=tmp[13]; b[13]=tmp[1];  // row1
                b[2]=tmp[10]; b[6]=tmp[14]; b[10]=tmp[2]; b[14]=tmp[6];  // row2
                b[3]=tmp[15]; b[7]=tmp[3];  b[11]=tmp[7]; b[15]=tmp[11]; // row3
                // MixColumns (skipped in final round)
                if (r < 10) begin
                    for (i=0;i<4;i=i+1) begin
                        reg [7:0] a0,a1,a2,a3;
                        a0=b[i*4]; a1=b[i*4+1]; a2=b[i*4+2]; a3=b[i*4+3];
                        b[i*4]   = xt(a0)^(xt(a1)^a1)^a2^a3;
                        b[i*4+1] = a0^xt(a1)^(xt(a2)^a2)^a3;
                        b[i*4+2] = a0^a1^xt(a2)^(xt(a3)^a3);
                        b[i*4+3] = (xt(a0)^a0)^a1^a2^xt(a3);
                    end
                end
                // AddRoundKey
                for (i=0;i<4;i=i+1) begin
                    b[i*4]   = b[i*4]   ^ W[r*4+i][31:24];
                    b[i*4+1] = b[i*4+1] ^ W[r*4+i][23:16];
                    b[i*4+2] = b[i*4+2] ^ W[r*4+i][15:8];
                    b[i*4+3] = b[i*4+3] ^ W[r*4+i][7:0];
                end
            end

            // --- Pack output ---
            for (i=0;i<16;i=i+1)
                AES128_encrypt[127-i*8 -: 8] = b[i];
        end
    endfunction

    // =========================================================================
    // Registers
    // =========================================================================
    reg [31:0] key_w[0:3];
    reg [31:0] pt_w[0:3];
    reg [127:0] ct_r;
    reg ctrl_start;
    reg busy_r, valid_r;

    localparam S_IDLE=1'b0, S_DONE=1'b1;
    reg fsm;

    // AXI Write
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready<=0; s_axi_wready<=0; s_axi_bresp<=0; s_axi_bvalid<=0;
            ctrl_start<=0;
            key_w[0]<=0; key_w[1]<=0; key_w[2]<=0; key_w[3]<=0;
            pt_w[0]<=0;  pt_w[1]<=0;  pt_w[2]<=0;  pt_w[3]<=0;
        end else begin
            ctrl_start<=0; s_axi_awready<=0; s_axi_wready<=0;
            if (s_axi_bvalid && s_axi_bready) s_axi_bvalid<=0;
            if (s_axi_awvalid && s_axi_wvalid && !s_axi_awready) begin
                s_axi_awready<=1; s_axi_wready<=1; s_axi_bresp<=0; s_axi_bvalid<=1;
                case(s_axi_awaddr[5:2])
                    4'h0: ctrl_start <= s_axi_wdata[0];
                    4'h2: key_w[0]   <= s_axi_wdata;
                    4'h3: key_w[1]   <= s_axi_wdata;
                    4'h4: key_w[2]   <= s_axi_wdata;
                    4'h5: key_w[3]   <= s_axi_wdata;
                    4'h6: pt_w[0]    <= s_axi_wdata;
                    4'h7: pt_w[1]    <= s_axi_wdata;
                    4'h8: pt_w[2]    <= s_axi_wdata;
                    4'h9: pt_w[3]    <= s_axi_wdata;
                    default:;
                endcase
            end
        end
    end

    // AXI Read
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_arready<=0; s_axi_rdata<=0; s_axi_rresp<=0; s_axi_rvalid<=0;
        end else begin
            s_axi_arready<=0;
            if (s_axi_arvalid && !s_axi_arready) begin
                s_axi_arready<=1; s_axi_rresp<=0; s_axi_rvalid<=1;
                case(s_axi_araddr[5:2])
                    4'h0,4'h1: s_axi_rdata <= {30'h0, valid_r, busy_r};
                    4'hA: s_axi_rdata <= ct_r[127:96];
                    4'hB: s_axi_rdata <= ct_r[95:64];
                    4'hC: s_axi_rdata <= ct_r[63:32];
                    4'hD: s_axi_rdata <= ct_r[31:0];
                    default: s_axi_rdata <= 32'hDEADBEEF;
                endcase
            end
            if (s_axi_rvalid && s_axi_rready) s_axi_rvalid<=0;
        end
    end

    // AES FSM: 1 cycle BUSY, then DONE
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fsm<=S_IDLE; busy_r<=0; valid_r<=0; ct_r<=0;
        end else begin
            case(fsm)
                S_IDLE: begin
                    valid_r<=0;
                    if (ctrl_start && !busy_r) begin
                        busy_r<=1;
                        // Compute AES in one shot (behavioral)
                        ct_r <= AES128_encrypt(
                            {pt_w[0],pt_w[1],pt_w[2],pt_w[3]},
                            {key_w[0],key_w[1],key_w[2],key_w[3]}
                        );
                        fsm<=S_DONE;
                    end
                end
                S_DONE: begin
                    busy_r<=0; valid_r<=1; fsm<=S_IDLE;
                end
            endcase
        end
    end

endmodule
`default_nettype wire
