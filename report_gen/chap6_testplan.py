# -*- coding: utf-8 -*-
"""
Chapter 6: Testplan with External/Internal Test Column (Pages 26 to 29)
Candidate: Namratha Kavididevi (Roll No: 1602-23-735-157)
"""

from common import make_page

def get_chap6_pages():
    pages = []

    # ==============================================================================
    # PAGE 26: Chapter Title, Methodology, Dual-Perspective Architecture, Tests 1 to 7
    # ==============================================================================
    p26_content = """
    <h2 class="chap-num">Chapter 6</h2>
    <h1 class="chap-title">Testplan with External/Internal Test Column</h1>

    <h2 class="sec-title">6.1 Verification Methodology & Strategy</h2>
    <p>
        Verifying an integrated System-on-Chip requires a dual-perspective verification methodology. Software execution alone cannot guarantee bus timing compliance, signal integrity, or external protocol adherence. Conversely, hardware testbenches cannot observe the internal execution context of firmware subroutines.
    </p>

    <h2 class="sec-title">6.2 Dual-Perspective Verification Architecture (Internal vs. External)</h2>
    <p>
        The verification architecture establishes two complementary, synchronized validation lenses:
    </p>
    <ul>
        <li><b>Internal Verification (C Firmware):</b> Bare-metal firmware running natively on the VeeR EL2 processor core. It writes stimulus to peripheral registers, measures internal timing, executes algorithm logic, and signals test pass/fail via designated memory-mapped signatures (<code>PASS_SIGNATURE = 0x900D</code>).</li>
        <li><b>External Verification (SV / UVM Testbench):</b> An IEEE 1800.2 UVM 1.2 environment equipped with 6 custom Verification IPs (VIPs) snooping external SoC pads (<code>uart_tx/rx</code>, <code>i2c_scl/sda</code>, <code>spi_sclk/mosi/miso/cs_n</code>, <code>gpio_io</code>, <code>pwm_pad_o</code>, <code>sample_tick</code>) to verify protocol framing, edge timings, and signal states.</li>
    </ul>

    <div class="caption"><b>Table 6.1:</b> Master Comprehensive Verification Matrix (Part 1: Boot & UART Subsystems)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 5%;">SNo</th>
                <th style="width: 14%;">Test ID</th>
                <th style="width: 25%;">Feature Under Test</th>
                <th style="width: 26%;">Internal Verification (C Part)</th>
                <th style="width: 20%;">External Verification (SV/UVM)</th>
                <th style="width: 10%;">Overall</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>1</td>
                <td><b>TC_BOOT_01</b></td>
                <td>Reset vector deassertion & initial instruction fetch at 0x0</td>
                <td>Boot entry in <code>crt0.S</code>, stack setup, write 0x01 to GPIO_OUTPUT.</td>
                <td>Monitor core boot; verify fetch at 0x0, buses idle during reset.</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
            <tr>
                <td>2</td>
                <td><b>TC_BOOT_02</b></td>
                <td>Unified SRAM stack frame & byte-strobe integrity check</td>
                <td>Push/pop stack memory, verify byte (sb), halfword (sh), word (sw).</td>
                <td>Snoop LSU bus & SRAM; verify wstrb[3:0] byte masking & 1-cycle ack.</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
            <tr>
                <td>3</td>
                <td><b>TC_UART_01</b></td>
                <td>UART Baud Divisor & Control register configuration</td>
                <td>Write baud div 4 to 0x1000_000C; enable TX/RX in UART_CTRL.</td>
                <td>Snoop Port S01; verify AXI/crossbar handshakes & OKAY response.</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
            <tr>
                <td>4</td>
                <td><b>TC_UART_02</b></td>
                <td>UART single telemetry byte serialization & 8N1 framing</td>
                <td>Poll TX_BUSY==0; write 0x55 ('U') to UART_DATA; poll TX_EMPTY.</td>
                <td>Detect falling edge on uart_tx; sample 8 bits at 115.2k; check stop bit.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>5</td>
                <td><b>TC_UART_03</b></td>
                <td>UART command byte injection & RX interrupt check</td>
                <td>Enable RX_IE; poll RX_VALID; read DATA (0x5A); clear IRQ.</td>
                <td>Drive serial byte 0x5A on uart_rx; monitor uart_irq assertion to PIC.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>6</td>
                <td><b>TC_UART_04</b></td>
                <td>UART environmental telemetry burst transmission</td>
                <td>Stream 8-byte telemetry packet (header, temp, hum, checksum).</td>
                <td>Capture UART frame stream; assert zero framing errors & FIFO clear.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>7</td>
                <td><b>TC_TMR_01</b></td>
                <td>Interval timer prescaler & monotonic counter progression</td>
                <td>Write prescaler=0; write 0x07 to TIMER_CTRL (EN | RELOAD).</td>
                <td>Snoop Port S03; verify reg_counter advances monotonically.</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
        </tbody>
    </table>
    """
    pages.append(make_page(p26_content, "26"))

    # ==============================================================================
    # PAGE 27: Table 6.1 (Part 2: Timer, GPIO & SPI Tests 8 to 14)
    # ==============================================================================
    p27_content = """
    <div class="caption"><b>Table 6.1:</b> Master Comprehensive Verification Matrix (Part 2: Timer, GPIO & SPI Subsystems)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 5%;">SNo</th>
                <th style="width: 14%;">Test ID</th>
                <th style="width: 25%;">Feature Under Test</th>
                <th style="width: 26%;">Internal Verification (C Part)</th>
                <th style="width: 20%;">External Verification (SV/UVM)</th>
                <th style="width: 10%;">Overall</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>8</td>
                <td><b>TC_TMR_02</b></td>
                <td>Timer compare match & sample_tick periodic pulse</td>
                <td>Program TIMER_COMPARE=25; wait for tick; clear flag via W1C.</td>
                <td>Monitor top-level sample_tick; assert exactly 1-cycle active-high pulse.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>9</td>
                <td><b>TC_TMR_03</b></td>
                <td>Level interrupt generation & routing to VeeR PIC Line 1</td>
                <td>Enable TIMER_IRQ_ENABLE; enable PIC IRQ line 1; verify ISR.</td>
                <td>Monitor irq_timer pin & PIC request; verify active-high deassert on W1C.</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
            <tr>
                <td>10</td>
                <td><b>TC_GPIO_01</b></td>
                <td>GPIO output config & direct LED drive (Pins 0-7)</td>
                <td>Write 0xFF to GPIO_DIR; write alert pattern 0x3C to GPIO_DATA_OUT.</td>
                <td>Monitor pad gpio_out[7:0]; verify immediate update to 8'h3C.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>11</td>
                <td><b>TC_GPIO_02</b></td>
                <td>GPIO atomic bit manipulation (SET & CLEAR registers)</td>
                <td>Write 0x0F to GPIO_SET; write 0x03 to GPIO_CLEAR; read back.</td>
                <td>Verify atomic bitwise update without read-modify-write hazard.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>12</td>
                <td><b>TC_GPIO_03</b></td>
                <td>GPIO synchronized external threshold input sampling</td>
                <td>Set GPIO_DIR=0x0; read GPIO_DATA_IN; verify match with pins.</td>
                <td>Drive pattern 8'hA5 on gpio_in[7:0]; verify 2-stage synchronizer.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>13</td>
                <td><b>TC_GPIO_04</b></td>
                <td>GPIO edge-triggered alarm interrupt & W1C servicing</td>
                <td>Enable pin IRQ in GPIO_INT_EN; await ISR; clear via W1C.</td>
                <td>Pulse gpio_in[2] 0&rarr;1; monitor irq_gpio; verify deassertion on W1C.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>14</td>
                <td><b>TC_SPI_01</b></td>
                <td>SPI clock prescaler & mode setup (CPOL=0, CPHA=0)</td>
                <td>Write 0x02 to SPI_CLK_DIV; write 0x09 to SPI_CTRL (EN=1, MASTER=1).</td>
                <td>Snoop Port S04; verify SPI enters idle; spi_cs_n remains HIGH.</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
        </tbody>
    </table>
    """
    pages.append(make_page(p27_content, "27"))

    # ==============================================================================
    # PAGE 28: Table 6.1 (Part 3: SPI, I2C, PWM & Interconnect Tests 15 to 20)
    # ==============================================================================
    p28_content = """
    <div class="caption"><b>Table 6.1:</b> Master Comprehensive Verification Matrix (Part 3: SPI, I2C, PWM & Pipeline)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 5%;">SNo</th>
                <th style="width: 14%;">Test ID</th>
                <th style="width: 25%;">Feature Under Test</th>
                <th style="width: 26%;">Internal Verification (C Part)</th>
                <th style="width: 20%;">External Verification (SV/UVM)</th>
                <th style="width: 10%;">Overall</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>15</td>
                <td><b>TC_SPI_02</b></td>
                <td>SPI byte write transfer for Flash logging (spi_mosi)</td>
                <td>Assert CS (write 0 to SPI_CS); write 0xD2 to SPI_DATA; poll busy.</td>
                <td>Monitor spi_cs_n LOW; count 8 SCLK pulses; capture 8'hD2 on MOSI.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>16</td>
                <td><b>TC_SPI_03</b></td>
                <td>SPI Flash read transaction & log buffer retrieval</td>
                <td>Write dummy byte; poll RX_VALID; read SPI_DATA (0xB4).</td>
                <td>Drive 8'hB4 on spi_miso synchronously with sclk; verify RX_DATA.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>17</td>
                <td><b>TC_I2C_01</b></td>
                <td>I2C prescaler & master enable configuration</td>
                <td>Write prescaler=2 to I2C_CLK_DIV; write 0x03 to I2C_CTRL.</td>
                <td>Snoop Port S05; verify pullups hold open-drain SCL/SDA HIGH.</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
            <tr>
                <td>18</td>
                <td><b>TC_I2C_02</b></td>
                <td>I2C sensor addressing & START / ACK bus framing</td>
                <td>Write address 0x90 to I2C_ADDR; issue START command; poll status.</td>
                <td>Detect open-drain START transition; sample 8 bits; check ACK pulse.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>19</td>
                <td><b>TC_I2C_03</b></td>
                <td>I2C telemetry data reception & STOP condition</td>
                <td>Issue READ_BYTE; wait for DONE; read I2C_DATA (0x3E); issue STOP.</td>
                <td>Emulate sensor driving 8'h3E on sda; verify STOP condition.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>20</td>
                <td><b>TC_PWM_01</b></td>
                <td>PWM threshold alert modulation (40% buzzer duty)</td>
                <td>Write period 100 to PWM_PERIOD; duty 40 to PWM_DUTY; enable PWM.</td>
                <td>Measure high time & period on pwm_out; verify exactly 40.0% duty.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
        </tbody>
    </table>
    """
    pages.append(make_page(p28_content, "28"))

    # ==============================================================================
    # PAGE 29: Table 6.1 (Part 4: PWM, Interconnect, Regression Tests 21 to 26)
    # ==============================================================================
    p29_content = """
    <div class="caption"><b>Table 6.1:</b> Master Comprehensive Verification Matrix (Part 4: PWM, Bus & System Regression)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 5%;">SNo</th>
                <th style="width: 14%;">Test ID</th>
                <th style="width: 25%;">Feature Under Test</th>
                <th style="width: 26%;">Internal Verification (C Part)</th>
                <th style="width: 20%;">External Verification (SV/UVM)</th>
                <th style="width: 10%;">Overall</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>21</td>
                <td><b>TC_PWM_02</b></td>
                <td>PWM dynamic duty sweep {0%, 25%, 50%, 75%, 100%}</td>
                <td>Step through duty thresholds with 100-cycle delay; verify status.</td>
                <td>Monitor pwm_out waveform; verify glitch-free counter rollover.</td>
                <td><span style="color:#16a34a; font-weight:bold;">External</span></td>
            </tr>
            <tr>
                <td>22</td>
                <td><b>TC_PWM_03</b></td>
                <td>PWM cycle rollover interrupt & PIC routing Line 5</td>
                <td>Enable PWM_INT_EN; enable PIC IRQ line 5; handle ISR.</td>
                <td>Monitor irq_pwm & PIC request; verify deassert on status read.</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
            <tr>
                <td>23</td>
                <td><b>TC_PIPE_01</b></td>
                <td>Full autonomous telemetry pipeline (SENSE &rarr; LOG &rarr; ALERT)</td>
                <td>Read I2C &rarr; compare limit &rarr; trip PWM &rarr; drive LED &rarr; SPI log &rarr; UART.</td>
                <td>Concurrent verification across all 6 peripheral interfaces in testbench.</td>
                <td><span style="color:#b45309; font-weight:bold;">Dual</span></td>
            </tr>
            <tr>
                <td>24</td>
                <td><b>TC_BUS_01</b></td>
                <td>Crossbar single-cycle address decode across all 7 slaves</td>
                <td>Sequential write/read sweeps across all 7 slave apertures.</td>
                <td>Verify decoder selects correct master port; verify 100% OKAY.</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
            <tr>
                <td>25</td>
                <td><b>TC_BUS_02</b></td>
                <td>Interconnect unmapped address decode isolation (DECERR)</td>
                <td>Perform load/store to unmapped addresses 0x1000_6000 & 0x8000_0000.</td>
                <td>Snoop interconnect slave; verify decode triggers DECERR (2'b10).</td>
                <td><span style="color:#0284c7; font-weight:bold;">Internal</span></td>
            </tr>
            <tr>
                <td>26</td>
                <td><b>TC_FULL_01</b></td>
                <td>Full system regression sign-off covering all subsystems</td>
                <td>Execute full main() suite; confirm signature PASS_SIGNATURE = 0x900D.</td>
                <td>Scoreboard confirms zero errors, 100% pass, and calls $finish.</td>
                <td><span style="color:#b45309; font-weight:bold;">Dual</span></td>
            </tr>
        </tbody>
    </table>

    <h2 class="sec-title">6.4 Test Coverage Goals & Acceptance Criteria</h2>
    <p>
        The verification environment enforces strict closure metrics: <b>100% Statement Coverage</b> on all peripheral control FSMs, <b>100% Branch Coverage</b> on interconnect decoder logic, and zero protocol errors across all 26 verification checkpoints.
    </p>
    """
    pages.append(make_page(p29_content, "29"))

    return pages
