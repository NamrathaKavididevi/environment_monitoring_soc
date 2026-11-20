import os
import base64
import subprocess
import re

base_dir = r"F:\honours course based project"
wave_dir = os.path.join(base_dir, "Waveforms")
output_html = os.path.join(base_dir, "Lab_Report_College_Format.html")
output_pdf = os.path.join(base_dir, "Lab_Report.pdf")

def get_b64(filename):
    p = os.path.join(wave_dir, filename)
    if os.path.exists(p):
        with open(p, "rb") as f:
            return "data:image/png;base64," + base64.b64encode(f.read()).decode("ascii")
    return ""

img1  = get_b64("wave_exp1_i2c.png")
img2  = get_b64("wave_exp2_axi.png")
img3  = get_b64("wave_exp3_aes.png")
img4  = get_b64("wave_exp4_uart.png")
img8  = get_b64("wave_exp8_soc.png")
img9  = get_b64("wave_exp9_vip.png")
img10 = get_b64("wave_exp10_uvm.png")

print("Waveforms loaded. Building HTML pages...")

pages = []

def make_page(body_content, page_num):
    return f"""  <div class="page-box">
    <div class="hdr">
      <span>Name: Namratha Kavididevi</span>
      <span>Roll No: 1602-23-735-157</span>
    </div>
    <div class="body">
{body_content}
    </div>
    <div class="ftr">
      <span>Design Verification Lab Record - RTL-Based Environmental Monitoring and Data-Logging SoC</span>
      <span>Page {page_num}</span>
    </div>
  </div>"""

# ==============================================================================
# COVER / INDEX PAGE
# ==============================================================================
cover_html = """  <div class="page-box">
    <div class="body" style="padding: 18px 24px;">
      <div style="text-align: center; margin-bottom: 12px;">
        <div style="font-size: 14pt; font-weight: bold; letter-spacing: 0.5px; color: #000;">VASAVI COLLEGE OF ENGINEERING</div>
        <div style="font-size: 10.5pt; font-weight: bold; color: #000;">(AUTONOMOUS)</div>
        <div style="font-size: 9.5pt; color: #111;">(Affiliated to Osmania University)</div>
        <div style="font-size: 9.5pt; color: #111;">Ibrahimbagh, Hyderabad - 31.</div>
        <div style="font-size: 10pt; font-weight: bold; margin-top: 5px; color: #000;">Academic Year : 2026-27</div>
      </div>

      <div style="border-top: 1.5px solid #000; border-bottom: 1.5px solid #000; padding: 7px 0; margin-bottom: 10px; font-size: 9pt; color: #000;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
          <span><strong>Name of the Laboratory :</strong> Design Verification Lab</span>
          <span><strong>Department :</strong> ECE</span>
          <span><strong>Hall Ticket No. :</strong> 1602-23-735-157</span>
        </div>
        <div style="display: flex; justify-content: space-between;">
          <span><strong>Name :</strong> Namratha Kavididevi</span>
          <span><strong>Project :</strong> RTL-Based Environmental Monitoring and Data-Logging SoC</span>
        </div>
      </div>

      <div style="text-align: center; font-size: 12pt; font-weight: bold; margin: 8px 0; color: #000; letter-spacing: 1px;">INDEX</div>

      <table class="index-table">
        <thead>
          <tr>
            <th style="width: 6%;">Sl.<br>No.</th>
            <th style="width: 44%;">Name of the Experiment</th>
            <th style="width: 11%;">Conducted<br>on<br>Date</th>
            <th style="width: 11%;">Date of<br>Submission</th>
            <th style="width: 9%; white-space: nowrap;">Page<br>No.</th>
            <th style="width: 9%;">Grade /<br>Marks</th>
            <th style="width: 10%;">Signature of<br>the faculty</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="tc">1</td>
            <td>Verification of I2C IP with Basic Testbench</td>
            <td></td><td></td>
            <td class="tc pg">1 - 6</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td class="tc">2</td>
            <td>Verification of AXI IP with Basic Testbench</td>
            <td></td><td></td>
            <td class="tc pg">7 - 13</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td class="tc">3</td>
            <td>AES-128 Encryption Verification Using SystemVerilog</td>
            <td></td><td></td>
            <td class="tc pg">14 - 16</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td class="tc">4</td>
            <td>Verification of UART IP with Basic Testbench - Test Sequence and Waveform</td>
            <td></td><td></td>
            <td class="tc pg">17 - 20</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td class="tc">5</td>
            <td>Git Repository Setup - Steps to Set Up a GitHub Account</td>
            <td></td><td></td>
            <td class="tc pg">21 - 22</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td class="tc">6</td>
            <td>RISC-V Toolchain Installation Using Windows Terminal</td>
            <td></td><td></td>
            <td class="tc pg">23</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td class="tc">7</td>
            <td>RISC-V Setup - Basic C Test Compilation and HEX File Generation</td>
            <td></td><td></td>
            <td class="tc pg">24 - 25</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td class="tc">8</td>
            <td>SoC RTL Integration - C Test Execution</td>
            <td></td><td></td>
            <td class="tc pg">26 - 29</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td class="tc">9</td>
            <td>UVM VIPs Generation - Interface Files of All VIPs</td>
            <td></td><td></td>
            <td class="tc pg">30 - 35</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td class="tc">10</td>
            <td>UART Transmitter Design and Verification Using SystemVerilog and UVM</td>
            <td></td><td></td>
            <td class="tc pg">36 - 44</td>
            <td></td><td></td>
          </tr>
        </tbody>
      </table>

      <div style="display: flex; justify-content: space-between; font-size: 10pt; font-weight: bold; margin-top: 24px; color: #000;">
        <span>No. of Experiments : 10</span>
        <span>Signature of the Faculty</span>
      </div>
      <div style="text-align: center; font-size: 8.5pt; color: #333; margin-top: 16px;">
        Repository: https://github.com/NamrathaKavididevi/environment_monitoring_soc.git
      </div>
    </div>
  </div>"""

pages.append(cover_html)

# ==============================================================================
# EXP 1: Pages 1 to 6
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT 1</h1>
<h2 class="subtitle">VERIFICATION OF I2C IP WITH BASIC TESTBENCH</h2>
<h3 class="sec">EXPERIMENT 1: Verification of I2C IP with Basic Testbench</h3>
<h3 class="sec">1. Aim</h3>
<p>To verify I2C communication using a SystemVerilog testbench by performing a basic write transaction and observing the simulation waveforms.</p>
<h3 class="sec">2. Design Code - Design.sv</h3>
<pre class="code">module i2c_slave (
 input logic scl,
 inout tri1 sda,
 output logic [6:0] received_addr,
 output logic [7:0] received_data,
 output logic transaction_done
);
 logic slave_sda_low;
 logic [7:0] address_byte;
 assign sda = slave_sda_low ? 1'b0 : 1'bz;
 task automatic receive_byte(output logic [7:0] value);
 integer i;
 begin
 value = 0;
 for (i = 7; i &gt;= 0; i = i - 1) begin
 @(posedge scl);
 value[i] = sda;
 end
 end
 endtask
 task automatic send_ack;
 begin
 @(negedge scl);
 slave_sda_low = 1'b1;</pre>""", 1))

pages.append(make_page("""<pre class="code"> @(posedge scl);
 @(negedge scl);
 slave_sda_low = 1'b0;
 end
 endtask
 initial begin
 slave_sda_low = 0;
 received_addr = 0;
 received_data = 0;
 transaction_done = 0;
 forever begin
 @(negedge sda);
 if (scl === 1'b1) begin
 receive_byte(address_byte);
 received_addr = address_byte[7:1];
 if (received_addr == 7'h42 &amp;&amp;
 address_byte[0] == 1'b0) begin
 send_ack();
 receive_byte(received_data);
 send_ack();
 wait (scl === 1'b1 &amp;&amp; sda === 1'b1);
 transaction_done = 1'b1;
 end
 end
 end
 end
endmodule
<h3 class="sec">3. Testbench Code - Testbench.sv</h3>
`timescale 1ns/1ps
module tb;
 logic scl;</pre>""", 2))

pages.append(make_page("""<pre class="code"> logic master_sda_low;
 tri1 sda;
 logic [6:0] received_addr;
 logic [7:0] received_data;
 logic transaction_done;
 assign sda = master_sda_low ? 1'b0 : 1'bz;
 i2c_slave DUT (
 .scl(scl),
 .sda(sda),
 .received_addr(received_addr),
 .received_data(received_data),
 .transaction_done(transaction_done)
 );
 task automatic send_bit(input logic bit_value);
 begin
 scl = 0;
 master_sda_low = (bit_value == 0);
 #5;
 scl = 1;
 #5;
 end
 endtask
 task automatic send_byte(input logic [7:0] value);
 integer i;
 begin
 for (i = 7; i &gt;= 0; i = i - 1)
 send_bit(value[i]);
 scl = 0;
 master_sda_low = 0;
 #2;
 scl = 1;</pre>""", 3))

pages.append(make_page("""<pre class="code"> #2;
 if (sda === 0)
 $display("ACK RECEIVED");
 else
 $fatal(1, "ACK NOT RECEIVED");
 #3;
 scl = 0;
 #5;
 end
 endtask
 initial begin
 // Waveform generation
 $dumpfile("i2c_wave.vcd");
 $dumpvars(0, tb);
 scl = 1;
 master_sda_low = 0;
 $display("I2C IP VERIFICATION STARTED");
 #10;
 // START condition
 $display("START CONDITION");
 master_sda_low = 1;
 #5;
 scl = 0;
 // Address and write bit
 $display("ADDRESS = 0x42");
 send_byte(8'h84);
 // Data transmission
 $display("DATA = 0xA5");
 send_byte(8'hA5);
 // STOP condition
 master_sda_low = 1;</pre>""", 4))

pages.append(make_page(f"""<pre class="code"> #5;
 scl = 1;
 #5;
 master_sda_low = 0;
 wait(transaction_done == 1);
 #5;
 $display("RECEIVED ADDRESS = %h", received_addr);
 $display("RECEIVED DATA = %h", received_data);
 $display("I2C TEST PASSED");
 #10;
 $finish;
 end
endmodule</pre>
<h3 class="sec">5. Output</h3>
<pre class="out">I2C IP VERIFICATION STARTED
START CONDITION
ADDRESS = 0x42
ACK RECEIVED
DATA = 0xA5
ACK RECEIVED
RECEIVED ADDRESS = 42
RECEIVED DATA = a5
I2C TEST PASSED</pre>
<h3 class="sec">6. Waveform</h3>
<img src="{img1}" class="wave-img" alt="I2C Waveform">""", 5))

pages.append(make_page("""<h3 class="sec">7. Result</h3>
<p>The basic I2C behavioral model was simulated using a SystemVerilog testbench. The write transaction, address, data and ACK responses were checked through simulation and waveform observation.</p>""", 6))

# ==============================================================================
# EXP 2: Pages 7 to 13
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT 2: Verification of AXI IP with Basic Testbench</h1>
<h3 class="sec">1. Aim</h3>
<p>To verify AXI4-Lite communication using a SystemVerilog testbench by performing basic write and read transactions and observing the simulation waveforms.</p>
<h3 class="sec">2. Design Code - Design.sv</h3>
<pre class="code">module axi_slave (
 input logic aclk,
 input logic aresetn,
 input logic [31:0] awaddr,
 input logic awvalid,
 output logic awready,
 input logic [31:0] wdata,
 input logic wvalid,
 output logic wready,
 output logic [1:0] bresp,
 output logic bvalid,
 input logic bready,
 input logic [31:0] araddr,
 input logic arvalid,
 output logic arready,
 output logic [31:0] rdata,
 output logic [1:0] rresp,
 output logic rvalid,
 input logic rready
);
 logic [31:0] mem [0:15];
 integer i;
 assign awready = aresetn &amp;&amp; !bvalid;
 assign wready = aresetn &amp;&amp; !bvalid;
 assign arready = aresetn &amp;&amp; !rvalid;
 always_ff @(posedge aclk) begin</pre>""", 7))

pages.append(make_page("""<pre class="code"> if (!aresetn) begin
 bvalid &lt;= 0;
 rvalid &lt;= 0;
 bresp &lt;= 0;
 rresp &lt;= 0;
 rdata &lt;= 0;
 for (i = 0; i &lt; 16; i = i + 1)
 mem[i] &lt;= 0;
 end
 else begin
 if (awvalid &amp;&amp; awready &amp;&amp; wvalid &amp;&amp; wready) begin
 mem[awaddr[5:2]] &lt;= wdata;
 bvalid &lt;= 1;
 bresp &lt;= 2'b00;
 end
 if (bvalid &amp;&amp; bready)
 bvalid &lt;= 0;
 if (arvalid &amp;&amp; arready) begin
 rdata &lt;= mem[araddr[5:2]];
 rresp &lt;= 2'b00;
 rvalid &lt;= 1;
 end
 if (rvalid &amp;&amp; rready)
 rvalid &lt;= 0;
 end
 end
endmodule
<h3 class="sec">3. Testbench Code - Testbench.sv</h3>
`timescale 1ns/1ps
module tb;
 logic aclk;</pre>""", 8))

pages.append(make_page("""<pre class="code"> logic aresetn;
 logic [31:0] awaddr;
 logic awvalid, awready;
 logic [31:0] wdata;
 logic wvalid, wready;
 logic [1:0] bresp;
 logic bvalid, bready;
 logic [31:0] araddr;
 logic arvalid, arready;
 logic [31:0] rdata;
 logic [1:0] rresp;
 logic rvalid, rready;
 axi_slave DUT (
 .aclk(aclk),
 .aresetn(aresetn),
 .awaddr(awaddr),
 .awvalid(awvalid),
 .awready(awready),
 .wdata(wdata),
 .wvalid(wvalid),
 .wready(wready),
 .bresp(bresp),
 .bvalid(bvalid),
 .bready(bready),
 .araddr(araddr),
 .arvalid(arvalid),
 .arready(arready),
 .rdata(rdata),
 .rresp(rresp),
 .rvalid(rvalid),
 .rready(rready)</pre>""", 9))

pages.append(make_page("""<pre class="code"> );
 always #5 aclk = ~aclk;
 task automatic axi_write(input logic [31:0] addr,input logic [31:0] data);
 begin
 @(negedge aclk);
 awaddr = addr;
 wdata = data;
 awvalid = 1;
 wvalid = 1;
 do @(posedge aclk);
 while (!(awready &amp;&amp; wready));
 @(negedge aclk);
 awvalid = 0;
 wvalid = 0;
 wait(bvalid == 1);
 if (bresp == 2'b00)
 $display("WRITE RESPONSE: OKAY");
 @(negedge aclk);
 bready = 1;
 @(negedge aclk);
 bready = 0;
 end
 endtask
 task automatic axi_read(input logic [31:0] addr);
 begin
 @(negedge aclk);
 araddr = addr;
 arvalid = 1;
 do @(posedge aclk);
 while (!arready);
 @(negedge aclk);</pre>""", 10))

pages.append(make_page("""<pre class="code"> arvalid = 0;
 wait(rvalid == 1);
 $display("READ DATA = %h", rdata);
 if (rresp == 2'b00)
 $display("READ RESPONSE: OKAY");
 if (rdata == 32'h12345678)
 $display("DATA VERIFICATION PASSED");
 else
 $fatal(1, "DATA VERIFICATION FAILED");
 @(negedge aclk);
 rready = 1;
 @(negedge aclk);
 rready = 0;
 end
 endtask
 initial begin
 $dumpfile("axi_wave.vcd");
 $dumpvars(0, tb);
 aclk = 0;
 aresetn = 0;
 awaddr = 0;
 awvalid = 0;
 wdata = 0;
 wvalid = 0;
 bready = 0;
 araddr = 0;
 arvalid = 0;
 rready = 0;
 $display("--------------------------------");
 $display("AXI IP VERIFICATION STARTED");
 $display("--------------------------------");</pre>""", 11))

pages.append(make_page("""<pre class="code"> repeat(3) @(negedge aclk);
 aresetn = 1;
 $display("STARTING WRITE TRANSACTION");
 axi_write(32'h00000004,32'h12345678);
 $display("STARTING READ TRANSACTION");
 axi_read(32'h00000004);
 $display("--------------------------------");
 $display("AXI TEST PASSED");
 $display("--------------------------------");
 #20;
 $finish;
 end
endmodule</pre>
<h3 class="sec">4. Output</h3>
<pre class="out">--------------------------------
AXI IP VERIFICATION STARTED
--------------------------------
STARTING WRITE TRANSACTION
WRITE RESPONSE: OKAY
STARTING READ TRANSACTION
READ DATA = 12345678
READ RESPONSE: OKAY
DATA VERIFICATION PASSED
--------------------------------
AXI TEST PASSED
--------------------------------</pre>
<h3 class="sec">5. Waveform</h3>
<p>Waveform generation:<br>
<code>$dumpfile("axi_wave.vcd");</code><br>
<code>$dumpvars(0, tb);</code><br>
Select these signals under tb in EPWave:</p>""", 12))

pages.append(make_page(f"""<ul>
<li>aclk</li>
<li>aresetn</li>
<li>awaddr</li>
<li>awvalid</li>
<li>awready</li>
<li>wdata</li>
<li>wvalid</li>
<li>wready</li>
<li>bvalid</li>
<li>araddr</li>
<li>arvalid</li>
<li>arready</li>
<li>rdata</li>
<li>rvalid</li>
<li>rready</li>
</ul>
<img src="{img2}" class="wave-img" alt="AXI Waveform">
<h3 class="sec">6. Result</h3>
<p>The AXI4-Lite behavioral slave model was simulated using a SystemVerilog testbench. Write and read transactions were performed successfully, and the received data 0x12345678 matched the transmitted data.</p>""", 13))

# ==============================================================================
# EXP 3: Pages 14 to 16
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT: AES-128 Encryption Verification Using SystemVerilog</h1>
<h3 class="sec">1. Aim</h3>
<p>To design and verify an AES-128 encryption module using SystemVerilog and simulate its operation using a testbench. The generated ciphertext is compared with the standard AES-128 test vector to verify the output.</p>
<h3 class="sec">2. Design - SystemVerilog Code (aes_top.sv)</h3>
<pre class="code">module aes_top(input logic clk,input logic rst_n,input logic start,input logic [127:0] 
pt,input logic [127:0] key,output logic [127:0] ct,output logic done);
always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n) begin
ct&lt;=128'b0;
done&lt;=1'b0;
end
else begin
done&lt;=1'b0;
if(start) begin
ct&lt;=128'h69C4E0D86A7B0430D8CDB78070B4C55A;
done&lt;=1'b1;
end
end
end
endmodule</pre>
<h3 class="sec">3. Testbench - SystemVerilog Code (aes_tb.sv)</h3>
<pre class="code">module aes_tb;
logic clk,rst_n,start;
logic [127:0] pt,key,ct;
logic done;
always #5 clk=~clk;
aes_top u_dut(.clk(clk),.rst_n(rst_n),.start(start),.pt(pt),.key(key),.ct(ct),.done(done));
initial begin
clk=0;
rst_n=0;</pre>""", 14))

pages.append(make_page("""<pre class="code">start=0;
pt=128'h00112233445566778899AABBCCDDEEFF;
key=128'h000102030405060708090A0B0C0D0E0F;
#10;
rst_n=1;
#10;
start=1;
#10;
start=0;
wait(done==1);
$display("Plaintext = %h",pt);
$display("Key = %h",key);
$display("Ciphertext = %h",ct);
if(ct==128'h69C4E0D86A7B0430D8CDB78070B4C55A)
$display("AES TEST PASSED");
else
$display("AES TEST FAILED");
#20;
$finish;
end
endmodule</pre>
<h3 class="sec">4. Output</h3>
<p>Advanced Encryption Standard (AES) is a symmetric-key encryption algorithm used to secure digital information. AES-128 operates on 128-bit plaintext blocks using a 128-bit secret key and performs 10 rounds of encryption. The encryption process consists of four main operations: SubBytes, ShiftRows, MixColumns and AddRoundKey. These operations transform the input plaintext into an encrypted ciphertext.</p>
<p>The standard AES-128 test vector used in this experiment is:</p>
<table style="width: 100%; border-collapse: collapse; margin: 6px 0; font-size: 9pt;">
  <tr><td style="width: 25%; font-weight: bold; border: 1px solid #777; padding: 5px;">Parameter</td><td style="font-weight: bold; border: 1px solid #777; padding: 5px;">Hexadecimal Value</td></tr>
  <tr><td style="border: 1px solid #777; padding: 5px;">Plaintext</td><td style="border: 1px solid #777; padding: 5px;">00112233445566778899AABBCCDDEEFF</td></tr>
  <tr><td style="border: 1px solid #777; padding: 5px;">Key</td><td style="border: 1px solid #777; padding: 5px;">000102030405060708090A0B0C0D0E0F</td></tr>
</table>""", 15))

pages.append(make_page(f"""<p>Expected Ciphertext <strong>69C4E0D86A7B0430D8CDB78070B4C55A</strong></p>
<h3 class="sec">5. Waveform</h3>
<img src="{img3}" class="wave-img" alt="AES Waveform">
<h3 class="sec">6. Result</h3>
<p>The AES-128 testbench simulation produced the expected ciphertext 69C4E0D86A7B0430D8CDB78070B4C55A. The output matched the standard AES-128 test vector, indicating successful test-vector verification of the fixed-output behavioral model.</p>
<p><strong>Note:</strong> The provided design is a fixed-output behavioral demonstration, not a complete AES hardware implementation. It does not perform the actual AES encryption rounds or calculate the ciphertext from the input plaintext and key.</p>""", 16))

# ==============================================================================
# EXP 4: Pages 17 to 20
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT 4: VERIFICATION OF UART IP WITH BASIC TESTBENCH - TEST SEQUENCE AND WAVEFORM</h1>
<h3 class="sec">1. Aim</h3>
<p>To design and verify a UART Transmitter IP using SystemVerilog and a basic testbench. The transmission of 8-bit serial data is verified by observing the control signals, internal states and output waveform.</p>
<h3 class="sec">2. Design - SystemVerilog Code (uart_tx.sv)</h3>
<pre class="code">module uart_tx #(parameter CLKS_PER_BIT=4)(input logic clk,rst_n,input logic 
tx_start,input logic [7:0] tx_data,output logic tx,output logic tx_done);
typedef enum logic [1:0] {IDLE,START,DATA,STOP} state_t;
state_t state;
logic [7:0] shift_reg;
logic [2:0] bit_index;
logic [15:0] clk_count;
always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n) begin
state&lt;=IDLE;
tx&lt;=1'b1;
tx_done&lt;=1'b0;
shift_reg&lt;=8'b0;
bit_index&lt;=0;
clk_count&lt;=0;
end
else begin
tx_done&lt;=1'b0;
case(state)
IDLE: begin
tx&lt;=1'b1;
if(tx_start) begin
shift_reg&lt;=tx_data;
state&lt;=START;
clk_count&lt;=0;</pre>""", 17))

pages.append(make_page("""<pre class="code">end
end
START: begin
tx&lt;=1'b0;
if(clk_count==CLKS_PER_BIT-1) begin
clk_count&lt;=0;
state&lt;=DATA;
end
else clk_count&lt;=clk_count+1;
end
DATA: begin
tx&lt;=shift_reg[0];
if(clk_count==CLKS_PER_BIT-1) begin
clk_count&lt;=0;
shift_reg&lt;=shift_reg&gt;&gt;1;
if(bit_index==7) begin
bit_index&lt;=0;
state&lt;=STOP;
end
else bit_index&lt;=bit_index+1;
end
else clk_count&lt;=clk_count+1;
end
STOP: begin
tx&lt;=1'b1;
if(clk_count==CLKS_PER_BIT-1) begin
clk_count&lt;=0;
tx_done&lt;=1'b1;
state&lt;=IDLE;
end
else clk_count&lt;=clk_count+1;</pre>""", 18))

pages.append(make_page("""<pre class="code">end
default: state&lt;=IDLE;
endcase
end
end
endmodule
<h3 class="sec">3. Testbench - SystemVerilog Code (uart_tb.sv)</h3>
module uart_tb;
logic clk,rst_n,tx_start;
logic [7:0] tx_data;
logic tx,tx_done;
always #5 clk=~clk;
uart_tx #(.CLKS_PER_BIT(4)) 
dut(.clk(clk),.rst_n(rst_n),.tx_start(tx_start),.tx_data(tx_data),.tx(tx),.tx_done(tx_done));
initial begin
$dumpfile("uart.vcd");
$dumpvars(0,uart_tb);
clk=0;
rst_n=0;
tx_start=0;
tx_data=8'hA5;
#20;
rst_n=1;
#20;
tx_start=1;
#10;
tx_start=0;
wait(tx_done==1);
$display("UART TRANSMISSION COMPLETED");
$display("Transmitted Data = %h",tx_data);
#30;</pre>""", 19))

pages.append(make_page(f"""<pre class="code">$finish;
end
initial begin
$monitor("Time=%0t | TX=%b | TX_DONE=%b",$time,tx,tx_done);
end
endmodule</pre>
<h3 class="sec">4. Output</h3>
<pre class="out">VCD info: dumpfile uart.vcd opened for output.
UART TRANSMISSION COMPLETED
Transmitted Data = a5
The transmitted data is A5 (10100101). UART sends the data LSB first, between the START 
bit (LOW) and STOP bit (HIGH).</pre>
<h3 class="sec">5. Waveform</h3>
<img src="{img4}" class="wave-img" alt="UART Waveform">
<h3 class="sec">6. Result</h3>
<p>The UART Transmitter IP was simulated and verified successfully using a basic SystemVerilog testbench. The serial transmission of 8-bit data was observed, and the tx_done signal indicated the completion of transmission.</p>""", 20))

# ==============================================================================
# EXP 5: Pages 21 to 22
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT 5: GIT REPOSITORY SETUP - STEPS TO SET UP A GITHUB ACCOUNT</h1>
<h3 class="sec">1. Aim</h3>
<p>To create a GitHub account and set up a Git repository for storing, managing and tracking project source code using version control.</p>
<h3 class="sec">2. Procedure</h3>
<ol>
<li>Open a web browser and visit https://github.com.</li>
<li>Click on the Sign Up option.</li>
<li>Enter a valid email address and create a password.</li>
<li>Choose a unique GitHub username.</li>
<li>Complete the account verification process.</li>
<li>Verify the email address using the verification code sent by GitHub.</li>
<li>Log in to the GitHub account.</li>
<li>Click on the New Repository option.</li>
<li>Enter a repository name and provide a short description.</li>
<li>Select Public or Private repository visibility.</li>
<li>Select the Add a README file option.</li>
<li>Click on Create Repository.</li>
<li>The GitHub repository is created successfully.</li>
<li>Upload project files using Add file -&gt; Upload files.</li>
<li>Click on Commit changes to save the uploaded files.</li>
</ol>
<h3 class="sec">3. Output</h3>
<pre class="out">GitHub website opened successfully.
New GitHub account created.
Email verification completed.
User logged in successfully.
New repository created successfully.
Repository name: Honors_Project
README.md file added successfully.
Project files uploaded successfully.
Changes committed successfully.
GitHub repository setup completed.</pre>""", 21))

pages.append(make_page("""<h3 class="sec">5. Result</h3>
<p>Successfully created a GitHub account and configured a new Git repository. The repository was used to store and manage project source files using GitHub version control.</p>""", 22))

# ==============================================================================
# EXP 6: Page 23
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT 6: RISC-V TOOLCHAIN INSTALLATION USING WINDOWS TERMINAL</h1>
<h3 class="sec">1. Aim</h3>
<p>To install and configure the RISC-V GNU toolchain using Windows Terminal and verify the successful installation by checking the compiler version.</p>
<h3 class="sec">2. Procedure</h3>
<ol>
<li>Open Windows Terminal or PowerShell as Administrator.</li>
<li>Check whether Chocolatey is installed.</li>
<li>Install Chocolatey if it is not already available.</li>
<li>Execute the RISC-V toolchain installation command.</li>
<li>Wait until the installation is completed.</li>
<li>Verify the installation using the GCC version command.</li>
<li>Confirm that the RISC-V compiler is accessible from the terminal.</li>
</ol>
<h3 class="sec">3. Commands Executed in Terminal</h3>
<p><strong>Step 1: Install Chocolatey (if not already installed).</strong></p>
<pre class="code">Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = 
[System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object 
System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'
))</pre>
<p><strong>Step 2: Install RISC-V toolchain.</strong></p>
<pre class="code">choco install riscv64-elf-gcc -y</pre>
<p><strong>Step 3: Verify installation.</strong></p>
<pre class="code">riscv64-elf-gcc --version</pre>
<h3 class="sec">4. Result</h3>
<p>Successfully installed and configured the RISC-V GNU toolchain through Windows Terminal. The compiler installation was verified using the version command, providing the required environment for developing and compiling programs for the RISC-V processor.</p>""", 23))

# ==============================================================================
# EXP 7: Pages 24 to 25
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT 7: RISC-V SETUP - BASIC C TEST COMPILATION AND HEX FILE GENERATION</h1>
<h3 class="sec">1. Aim</h3>
<p>To write a basic C program, compile it using the RISC-V GNU toolchain and generate ELF, BIN and HEX files for loading into the RISC-V SoC or simulation environment.</p>
<h3 class="sec">2. C Program (test.c)</h3>
<pre class="code">#include &lt;stdio.h&gt;
int main(void) {
volatile int a=5;
volatile int b=7;
int sum=a+b;
printf("Sum = %d\\n",sum);
return 0;
}</pre>
<h3 class="sec">3. Compilation and Linking Commands</h3>
<p>Execute the following commands in the terminal.</p>
<p><strong>Step 1: Compile and generate ELF file.</strong><br>
<code>riscv64-elf-gcc -march=rv32imac -mabi=ilp32 -O0 -g test.c -o test.elf</code></p>
<p><strong>Step 2: Convert ELF file into binary format.</strong><br>
<code>riscv64-elf-objcopy -O binary test.elf test.bin</code></p>
<p><strong>Step 3: Convert binary file into Intel HEX format.</strong><br>
<code>riscv64-elf-objcopy -I binary -O ihex test.bin test.hex</code></p>
<h3 class="sec">4. Output - Terminal transcript</h3>
<pre class="out">PS C:\\RISC-V&gt; riscv64-elf-gcc -march=rv32imac -mabi=ilp32 -O0 -g test.c -o test.elf
Compilation completed successfully.
PS C:\\RISC-V&gt; riscv64-elf-objcopy -O binary test.elf test.bin
Binary file generated successfully.
PS C:\\RISC-V&gt; riscv64-elf-objcopy -I binary -O ihex test.bin test.hex
HEX file generated successfully.
PS C:\\RISC-V&gt; dir
test.c</pre>""", 24))

pages.append(make_page("""<pre class="out">test.elf
test.bin
test.hex</pre>
<p><em>Note: This is an illustrative transcript. Actual output depends on the compiler and terminal environment.</em></p>
<h3 class="sec">5. Theoretical Output</h3>
<p>The C program initializes two integer variables with values 5 and 7 and calculates their sum. The RISC-V GCC compiler converts the C source code into RISC-V machine instructions. The generated ELF file contains executable information, the BIN file contains binary machine code, and the HEX file represents the binary data in Intel HEX format.</p>
<p>Expected calculation:<br>
5 + 7 = 12<br>
Expected program output: Sum = 12</p>
<h3 class="sec">7. Result</h3>
<p>Successfully compiled the basic C test program using the RISC-V GNU toolchain and generated ELF, BIN and HEX files for use in the RISC-V SoC or simulation environment.</p>""", 25))

# ==============================================================================
# EXP 8: Pages 26 to 29
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT 8: SoC RTL Integration - C Test Execution</h1>
<h3 class="sec">1. Aim</h3>
<p>To design and simulate a basic SoC system using SystemVerilog, demonstrate an addition operation, and verify the execution result using simulation output and waveforms.</p>
<h3 class="sec">2. Design Code - design.sv</h3>
<pre class="code">module soc_design(
input logic clk,
input logic rst_n,
output logic [31:0] pc,
output logic [31:0] result,
output logic done
);
logic [31:0] instruction;
logic [31:0] reg_a,reg_b;
logic [31:0] instruction_memory[0:3];
logic [31:0] data_memory[0:3];
initial begin
instruction_memory[0]=32'h00500093;
instruction_memory[1]=32'h00700113;
instruction_memory[2]=32'h002081B3;
instruction_memory[3]=32'h00000013;
end
always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n) begin
pc&lt;=0;
reg_a&lt;=0;
reg_b&lt;=0;
result&lt;=0;
done&lt;=0;
end</pre>""", 26))

pages.append(make_page("""<pre class="code">else if(!done) begin
instruction&lt;=instruction_memory[pc[3:2]];
case(pc)
0: reg_a&lt;=5;
4: reg_b&lt;=7;
8: begin
result&lt;=reg_a+reg_b;
data_memory[0]&lt;=reg_a+reg_b;
end
12: done&lt;=1;
endcase
pc&lt;=pc+4;
end
end
endmodule
<h3 class="sec">3. Testbench Code - tb.sv</h3>
module tb;
logic clk,rst_n;
logic [31:0] pc,result;
logic done;
soc_design dut(
.clk(clk),
.rst_n(rst_n),
.pc(pc),
.result(result),
.done(done)
);
initial begin
clk=0;
forever #5 clk=~clk;
end</pre>""", 27))

pages.append(make_page("""<pre class="code">initial begin
rst_n=0;
#20;
rst_n=1;
end
initial begin
$dumpfile("soc_c_test.vcd");
$dumpvars(0,tb);
wait(done==1);
#10;
$display("SOC C TEST EXECUTION");
$display("Program Counter=%h",pc);
$display("Result=%d",result);
if(result==12)
$display("PASS: C TEST RESULT=12");
else
$display("FAIL");
$finish;
end
endmodule</pre>
<h3 class="sec">4. Expected Output</h3>
<pre class="out">SOC C TEST EXECUTION
Program Counter=00000010
Result=12
PASS: C TEST RESULT=12</pre>
<h3 class="sec">5. Waveform</h3>
<p>Signals observed: clk, rst_n, pc, dut.reg_a, dut.reg_b, result, done.</p>
<p>Expected observations:</p>
<ul>
<li>Clock generates continuous pulses.</li>
<li>Reset changes from LOW to HIGH.</li>
<li>Program counter increments by 4.</li>
</ul>""", 28))

pages.append(make_page(f"""<ul>
<li>Register A stores 5.</li>
<li>Register B stores 7.</li>
<li>Result becomes 12.</li>
<li>Done signal becomes HIGH.</li>
</ul>
<img src="{img8}" class="wave-img" alt="SoC Waveform">
<h3 class="sec">6. Result</h3>
<p>The behavioral SoC design was simulated successfully. The addition of 5 and 7 produced the expected result of 12 (0x0000000C), which was verified through simulation output and waveform observation.</p>""", 29))

# ==============================================================================
# EXP 9: Pages 30 to 35
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT 9: UVM VIPs Generation - Interface Files of All VIPs</h1>
<h3 class="sec">1. Aim</h3>
<p>To generate and simulate SystemVerilog VIP interface files for I2C, AXI, AES, UART and SRAM, and verify their signal initialization and communication interfaces using EDA Playground waveforms.</p>
<h3 class="sec">2. Design Code - design.sv</h3>
<pre class="code">interface i2c_if(input logic clk);
 tri1 scl;
 tri1 sda;
 modport master(inout scl,sda);
 modport slave(inout scl,sda);
endinterface
interface axi_if(input logic aclk);
 logic aresetn;
 logic [31:0] awaddr,wdata;
 logic [3:0] wstrb;
 logic awvalid,awready;
 logic wvalid,wready;
 logic [1:0] bresp;
 logic bvalid,bready;
 logic [31:0] araddr,rdata;
 logic arvalid,arready;
 logic [1:0] rresp;
 logic rvalid,rready;
 modport master(
 output awaddr,awvalid,wdata,wstrb,wvalid,bready,
 araddr,arvalid,rready,
 input awready,wready,bresp,bvalid,
 arready,rdata,rresp,rvalid,aresetn
 );
 modport slave(</pre>""", 30))

pages.append(make_page("""<pre class="code"> input awaddr,awvalid,wdata,wstrb,wvalid,bready,
 araddr,arvalid,rready,aresetn,
 output awready,wready,bresp,bvalid,
 arready,rdata,rresp,rvalid
 );
endinterface
interface aes_if(input logic clk);
 logic reset_n;
 logic start,done;
 logic [127:0] data_in,data_out,key;
 modport master(
 output start,data_in,key,
 input done,data_out,reset_n
 );
 modport slave(
 input start,data_in,key,reset_n,
 output done,data_out
 );
endinterface
interface uart_if(input logic clk);
 logic reset_n;
 logic rx,tx;
 modport master(
 output tx,
 input rx,reset_n
 );
 modport slave(
 input tx,reset_n,
 output rx
 );
endinterface</pre>""", 31))

pages.append(make_page("""<pre class="code">interface sram_if(input logic clk);
 logic reset_n;
 logic [31:0] addr,wdata,rdata;
 logic we,re;
 modport master(
 output addr,wdata,we,re,
 input rdata,reset_n
 );
 modport slave(
 input addr,wdata,we,re,reset_n,
 output rdata
 );
endinterface
<h3 class="sec">3. Testbench Code - tb.sv</h3>
module tb;
 logic clk;
 i2c_if i2c(clk);
 axi_if axi(clk);
 aes_if aes(clk);
 uart_if uart(clk);
 sram_if sram(clk);
 initial begin
 clk=0;
 forever #5 clk=~clk;
 end
 initial begin
 axi.aresetn=0;
 aes.reset_n=0;
 uart.reset_n=0;
 sram.reset_n=0;
 #20;</pre>""", 32))

pages.append(make_page("""<pre class="code"> axi.aresetn=1;
 aes.reset_n=1;
 uart.reset_n=1;
 sram.reset_n=1;
 aes.start=0;
 aes.data_in=128'h123456789ABCDEF;
 aes.key=128'hAABBCCDDEEFF;
 uart.rx=1;
 axi.awaddr=32'h1000;
 axi.wdata=32'h12345678;
 axi.wstrb=4'hF;
 axi.awvalid=1;
 axi.wvalid=1;
 axi.bready=1;
 axi.araddr=32'h1000;
 axi.arvalid=1;
 axi.rready=1;
 sram.addr=32'h100;
 sram.wdata=32'h12345678;
 sram.we=1;
 sram.re=0;
 #20;
 $display("UVM VIP INTERFACE TEST");
 $display("I2C Interface Created");
 $display("AXI Interface Created");
 $display("AES Interface Created");
 $display("UART Interface Created");
 $display("SRAM Interface Created");
 $display("PASS: ALL VIP INTERFACES INSTANTIATED");
 $finish;
 end</pre>""", 33))

pages.append(make_page("""<pre class="code"> initial begin
 $dumpfile("vip_wave.vcd");
 $dumpvars(0,tb);
 end
endmodule</pre>
<h3 class="sec">4. Expected Output</h3>
<pre class="out">UVM VIP INTERFACE TEST
I2C Interface Created
AXI Interface Created
AES Interface Created
UART Interface Created
SRAM Interface Created
PASS: ALL VIP INTERFACES INSTANTIATED</pre>
<h3 class="sec">5. Waveform</h3>
<p>The following signals are observed in the EDA Playground waveform:</p>
<table style="width: 100%; border-collapse: collapse; margin: 4px 0; font-size: 8.8pt;">
  <tr><td style="font-weight: bold; border: 1px solid #777; padding: 4px 6px; width: 30%;">Signal</td><td style="font-weight: bold; border: 1px solid #777; padding: 4px 6px;">Expected observation</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">clk</td><td style="border: 1px solid #777; padding: 4px 6px;">Continuous clock pulses</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">aresetn</td><td style="border: 1px solid #777; padding: 4px 6px;">Changes from 0 to 1</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">addr[31:0]</td><td style="border: 1px solid #777; padding: 4px 6px;">00000100</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">wdata[31:0]</td><td style="border: 1px solid #777; padding: 4px 6px;">12345678</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">we</td><td style="border: 1px solid #777; padding: 4px 6px;">HIGH</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">rx</td><td style="border: 1px solid #777; padding: 4px 6px;">HIGH</td></tr>
</table>""", 34))

pages.append(make_page(f"""<table style="width: 100%; border-collapse: collapse; margin: 4px 0; font-size: 8.8pt;">
  <tr><td style="border: 1px solid #777; padding: 4px 6px; width: 30%;">awaddr[31:0]</td><td style="border: 1px solid #777; padding: 4px 6px;">00001000</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">awready</td><td style="border: 1px solid #777; padding: 4px 6px;">X (undriven)</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">tx</td><td style="border: 1px solid #777; padding: 4px 6px;">X (undriven)</td></tr>
</table>
<img src="{img9}" class="wave-img" alt="VIP Waveform">
<p><strong>Waveform observation:</strong> The clock toggles continuously. Reset signals are released after 20 ns. AXI address and write data, SRAM address and write data, and control signals are initialized and displayed in the waveform.</p>
<h3 class="sec">6. Result</h3>
<p>The five SystemVerilog VIP interfaces (I2C, AXI, AES, UART and SRAM) were successfully instantiated in the testbench. Their signal initialization and waveform generation were verified using EDA Playground.</p>""", 35))

# ==============================================================================
# EXP 10: Pages 36 to 44
# ==============================================================================
pages.append(make_page("""<h1 class="title">EXPERIMENT: UART TRANSMITTER DESIGN AND VERIFICATION USING SYSTEMVERILOG AND UVM</h1>
<h3 class="sec">1. AIM</h3>
<p>To design a UART (Universal Asynchronous Receiver Transmitter) transmitter using SystemVerilog and verify its functionality using a UVM testbench. The design is simulated in QuestaSim and verified by observing the waveform signals.</p>
<h3 class="sec">2. DESIGN - SYSTEMVERILOG CODE</h3>
<p><strong>File name: design.sv</strong></p>
<pre class="code">module uart_tx (
 input logic clk,
 input logic rst,
 input logic tx_start,
 input logic [7:0] data_in,
 output logic tx,
 output logic tx_done
);
 logic [3:0] state;
 logic [3:0] bit_count;
 logic [9:0] shift_reg;
 parameter IDLE = 0,
 START = 1,
 DATA = 2,
 STOP = 3;
 always_ff @(posedge clk) begin
 if (rst) begin
 state &lt;= IDLE;
 tx &lt;= 1'b1;
 tx_done &lt;= 1'b0;
 bit_count &lt;= 0;
 shift_reg &lt;= 0;
 end
 else begin</pre>""", 36))

pages.append(make_page("""<pre class="code"> tx_done &lt;= 0;
 case (state)
 IDLE: begin
 tx &lt;= 1'b1;
 if (tx_start) begin
 shift_reg &lt;= {1'b1, data_in, 1'b0};
 state &lt;= START;
 end
 end
 START: begin
 tx &lt;= 1'b0;
 state &lt;= DATA;
 end
 DATA: begin
 tx &lt;= shift_reg[bit_count + 1];
 bit_count &lt;= bit_count + 1;
 if (bit_count == 7) begin
 bit_count &lt;= 0;
 state &lt;= STOP;
 end
 end
 STOP: begin
 tx &lt;= 1'b1;
 tx_done &lt;= 1'b1;
 state &lt;= IDLE;
 end
 endcase
 end
 end
endmodule
<h3 class="sec">3. TESTBENCH - UVM SYSTEMVERILOG CODE</h3>""", 37))

pages.append(make_page("""<p><strong>File name: testbench.sv</strong></p>
<p>The following testbench uses UVM components to generate transactions and verify the UART transmitter.</p>
<pre class="code">`include "uvm_macros.svh"
import uvm_pkg::*;
// Interface
interface uart_if(input logic clk);
 logic rst;
 logic tx_start;
 logic [7:0] data_in;
 logic tx;
 logic tx_done;
endinterface
// Transaction
class uart_transaction extends uvm_sequence_item;
 rand bit [7:0] data;
 `uvm_object_utils_begin(uart_transaction)
 `uvm_field_int(data, UVM_ALL_ON)
 `uvm_object_utils_end
 function new(string name = "uart_transaction");
 super.new(name);
 endfunction
endclass
// Sequence
class uart_sequence extends uvm_sequence #(uart_transaction);
 `uvm_object_utils(uart_sequence)
 function new(string name = "uart_sequence");
 super.new(name);
 endfunction
 task body();
 uart_transaction tr;</pre>""", 38))

pages.append(make_page("""<pre class="code"> repeat (5) begin
 tr = uart_transaction::type_id::create("tr");
 start_item(tr);
 assert(tr.randomize());
 finish_item(tr);
 end
 endtask
endclass
// Driver
class uart_driver extends uvm_driver #(uart_transaction);
 `uvm_component_utils(uart_driver)
 virtual uart_if vif;
 function new(string name, uvm_component parent);
 super.new(name, parent);
 endfunction
 function void build_phase(uvm_phase phase);
 super.build_phase(phase);
 if (!uvm_config_db#(virtual uart_if)::get(
 this, "", "vif", vif))
 `uvm_fatal("NOVIF", "Interface not found")
 endfunction
 task run_phase(uvm_phase phase);
 uart_transaction tr;
 vif.tx_start &lt;= 0;
 vif.rst &lt;= 1;
 repeat (2) @(posedge vif.clk);
 vif.rst &lt;= 0;
 forever begin
 seq_item_port.get_next_item(tr);
 @(negedge vif.clk);
 vif.data_in &lt;= tr.data;</pre>""", 39))

pages.append(make_page("""<pre class="code"> vif.tx_start &lt;= 1;
 @(negedge vif.clk);
 vif.tx_start &lt;= 0;
 wait(vif.tx_done == 1);
 `uvm_info("UART_DRIVER",
 $sformatf("Transmitted data = %h", tr.data),
 UVM_MEDIUM)
 seq_item_port.item_done();
 end
 endtask
endclass
// Monitor
class uart_monitor extends uvm_monitor;
 `uvm_component_utils(uart_monitor)
 virtual uart_if vif;
 function new(string name, uvm_component parent);
 super.new(name, parent);
 endfunction
 function void build_phase(uvm_phase phase);
 super.build_phase(phase);
 if (!uvm_config_db#(virtual uart_if)::get(
 this, "", "vif", vif))
 `uvm_fatal("NOVIF", "Interface not found")
 endfunction
 task run_phase(uvm_phase phase);
 forever begin
 @(posedge vif.clk);
 if (vif.tx_done)
 `uvm_info("UART_MONITOR",
 "UART transmission completed",
 UVM_MEDIUM)</pre>""", 40))

pages.append(make_page("""<pre class="code"> end
 endtask
endclass
// Agent
class uart_agent extends uvm_agent;
 `uvm_component_utils(uart_agent)
 uart_driver drv;
 uart_monitor mon;
 uvm_sequencer #(uart_transaction) seqr;
 function new(string name, uvm_component parent);
 super.new(name, parent);
 endfunction
 function void build_phase(uvm_phase phase);
 super.build_phase(phase);
 drv = uart_driver::type_id::create("drv", this);
 mon = uart_monitor::type_id::create("mon", this);
 seqr = uvm_sequencer#(uart_transaction)::type_id::create(
 "seqr", this);
 endfunction
 function void connect_phase(uvm_phase phase);
 drv.seq_item_port.connect(seqr.seq_item_export);
 endfunction
endclass
// Environment
class uart_env extends uvm_env;
 `uvm_component_utils(uart_env)
 uart_agent agent;
 function new(string name, uvm_component parent);
 super.new(name, parent);
 endfunction
 function void build_phase(uvm_phase phase);</pre>""", 41))

pages.append(make_page("""<pre class="code"> super.build_phase(phase);
 agent = uart_agent::type_id::create("agent", this);
 endfunction
endclass
// Test
class uart_test extends uvm_test;
 `uvm_component_utils(uart_test)
 uart_env env;
 function new(string name, uvm_component parent);
 super.new(name, parent);
 endfunction
 function void build_phase(uvm_phase phase);
 super.build_phase(phase);
 env = uart_env::type_id::create("env", this);
 endfunction
 task run_phase(uvm_phase phase);
 uart_sequence seq;
 phase.raise_objection(this);
 seq = uart_sequence::type_id::create("seq");
 seq.start(env.agent.seqr);
 #100;
 phase.drop_objection(this);
 endtask
endclass
// Top module
module tb_top;
 logic clk = 0;
 always #5 clk = ~clk;
 uart_if vif(clk);
 uart_tx dut (
 .clk(clk),</pre>""", 42))

pages.append(make_page("""<pre class="code"> .rst(vif.rst),
 .tx_start(vif.tx_start),
 .data_in(vif.data_in),
 .tx(vif.tx),
 .tx_done(vif.tx_done)
 );
 initial begin
 uvm_config_db#(virtual uart_if)::set(
 null, "*", "vif", vif);
 run_test("uart_test");
 end
endmodule</pre>
<h3 class="sec">4. EXPECTED OUTPUT</h3>
<p>The simulation is expected to show:</p>
<table style="width: 100%; border-collapse: collapse; margin: 4px 0; font-size: 8.8pt;">
  <tr><td style="font-weight: bold; border: 1px solid #777; padding: 4px 6px; width: 30%;">Signal</td><td style="font-weight: bold; border: 1px solid #777; padding: 4px 6px;">Expected behaviour</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">clk</td><td style="border: 1px solid #777; padding: 4px 6px;">Continuous clock pulses</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">rst</td><td style="border: 1px solid #777; padding: 4px 6px;">Reset initialization</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">data_in[7:0]</td><td style="border: 1px solid #777; padding: 4px 6px;">Five different input bytes</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">tx_start</td><td style="border: 1px solid #777; padding: 4px 6px;">Transmission start request</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">state[3:0]</td><td style="border: 1px solid #777; padding: 4px 6px;">IDLE, START, DATA, STOP</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">bit_count[3:0]</td><td style="border: 1px solid #777; padding: 4px 6px;">Counts 8 data bits</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">shift_reg[9:0]</td><td style="border: 1px solid #777; padding: 4px 6px;">Stores transmission data</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">tx</td><td style="border: 1px solid #777; padding: 4px 6px;">Serial output</td></tr>
  <tr><td style="border: 1px solid #777; padding: 4px 6px;">tx_done</td><td style="border: 1px solid #777; padding: 4px 6px;">Completion pulse</td></tr>
</table>
<h3 class="sec">5. WAVEFORM</h3>
<p>The following signals are observed in the QuestaSim waveform:</p>
<ul>
<li>Clock and reset</li>
<li>Input data and TX start</li>
<li>FSM state transitions</li>
</ul>""", 43))

pages.append(make_page(f"""<ul>
<li>Bit counter</li>
<li>Shift register</li>
<li>Serial TX output</li>
<li>TX completion signal</li>
</ul>
<img src="{img10}" class="wave-img" alt="UVM Waveform">
<h3 class="sec">6. RESULT</h3>
<p>The UART transmitter was designed using SystemVerilog and verified using a UVM testbench in QuestaSim. The simulation demonstrated input data generation, reset operation, FSM state transitions, serial data transmission and completion indication.</p>
<p>Hence, the UART transmitter functionality was successfully verified through simulation and waveform analysis.</p>""", 44))

full_html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Design Verification Lab Record</title>
<style>
  @page {{
    size: A4 portrait;
    margin: 8mm;
  }}
  * {{ box-sizing: border-box; }}
  body {{
    margin: 0;
    padding: 0;
    font-family: Arial, Helvetica, sans-serif;
    color: #000;
    background: #fff;
    -webkit-print-color-adjust: exact;
  }}
  .page-box {{
    width: 100%;
    height: 280mm;
    border: 1.5px solid #2b4c6f;
    page-break-after: always;
    page-break-inside: avoid;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    margin-bottom: 0;
    overflow: hidden;
  }}
  .hdr {{
    height: 9.5mm;
    border-bottom: 1.5px solid #2b4c6f;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 16px;
    font-size: 9pt;
    font-weight: bold;
    color: #000;
    flex-shrink: 0;
  }}
  .ftr {{
    height: 8.5mm;
    border-top: 1.5px solid #2b4c6f;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 16px;
    font-size: 8.5pt;
    font-weight: 500;
    color: #333;
    flex-shrink: 0;
  }}
  .body {{
    flex-grow: 1;
    padding: 16px 24px;
    font-size: 9.5pt;
    line-height: 1.45;
    color: #000;
  }}
  h1.title {{
    font-size: 11pt;
    font-weight: bold;
    text-transform: uppercase;
    margin: 0 0 4px 0;
    color: #000;
  }}
  h2.subtitle {{
    font-size: 10.5pt;
    font-weight: bold;
    text-transform: uppercase;
    margin: 0 0 12px 0;
    color: #000;
  }}
  h3.sec {{
    font-size: 10pt;
    font-weight: bold;
    margin: 10px 0 4px 0;
    color: #000;
  }}
  p {{ margin: 3px 0 6px 0; color: #000; }}
  ul, ol {{ margin: 3px 0 8px 18px; padding: 0; color: #000; }}
  li {{ margin-bottom: 3px; color: #000; }}
  
  pre.code {{
    font-family: Consolas, 'Courier New', monospace;
    font-size: 8.6pt;
    line-height: 1.36;
    background: transparent;
    color: #000;
    margin: 4px 0;
    white-space: pre-wrap;
    word-break: break-all;
  }}
  
  pre.out {{
    font-family: Consolas, 'Courier New', monospace;
    font-size: 8.8pt;
    line-height: 1.4;
    margin: 4px 0;
    color: #000;
  }}

  /* Index Table */
  table.index-table {{
    width: 100%;
    border-collapse: collapse;
    margin-top: 8px;
    font-size: 9pt;
    color: #000;
  }}
  table.index-table th, table.index-table td {{
    border: 1px solid #000;
    padding: 5px 6px;
    text-align: left;
    vertical-align: middle;
  }}
  table.index-table th {{
    text-align: center;
    font-weight: bold;
    background: #f8fafc;
  }}
  .tc {{ text-align: center; }}
  .pg {{ font-weight: bold; white-space: nowrap; }}

  /* Waveform container */
  .wave-img {{
    margin: 8px 0;
    width: 100%;
    display: block;
    border: 1px solid #000;
  }}
</style>
</head>
<body>
""" + "\n".join(pages) + """
</body>
</html>"""

with open(output_html, "w", encoding="utf-8") as f:
    f.write(full_html)

print(f"HTML file written cleanly with UTF-8: {output_html}")

# Convert with Chrome
chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
print("Printing to PDF via Chrome headless...")
res = subprocess.run([
    chrome_path,
    "--headless=new",
    "--disable-gpu",
    "--no-pdf-header-footer",
    f"--print-to-pdf={output_pdf}",
    f"file:///{output_html.replace(chr(92), '/')}"
], capture_output=True, text=True)

print("Chrome output:", res.stdout, res.stderr)
if os.path.exists(output_pdf):
    size = os.path.getsize(output_pdf)
    print(f"PDF generated successfully: {output_pdf} ({size} bytes)")
else:
    print("PDF generation failed.")
