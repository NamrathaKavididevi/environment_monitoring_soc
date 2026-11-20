# -*- coding: utf-8 -*-
"""
Chapter 2: Architecture Specification (Pages 5 to 13)
Candidate: Namratha Kavididevi (Roll No: 1602-23-735-157)
"""

from common import make_page

def get_chap2_pages():
    pages = []

    # ==============================================================================
    # PAGE 5: Chapter Title, Overview, Figure 2.1 SoC Block Diagram
    # ==============================================================================
    p5_content = """
    <h2 class="chap-num">Chapter 2</h2>
    <h1 class="chap-title">Architecture Specification</h1>

    <h2 class="sec-title">2.1 SoC High-Level Architectural Overview</h2>
    <p>
        The Environmental Monitoring and Data-Logging System-on-Chip (SoC) is designed as a self-contained, real-time edge processing engine. It integrates a 32-bit RISC-V processor core with a memory-mapped crossbar interconnect and six specialized peripheral subsystems to capture, timestamp, evaluate, log, and stream ambient sensory data without external microcontroller supervision.
    </p>

    <div class="caption-fig"><b>Figure 2.1:</b> RTL-Based Environmental Monitoring SoC Architecture Block Diagram</div>
    <div class="fig-container">
        <svg width="620" height="380" viewBox="0 0 740 450" xmlns="http://www.w3.org/2000/svg" style="background:#fff; border:1px solid #b0bec5; border-radius:4px;">
            <!-- Outer SoC Boundary -->
            <rect x="20" y="15" width="700" height="420" rx="8" fill="#f8fafc" stroke="#1e3a8a" stroke-width="2.5" />
            <text x="35" y="38" font-family="sans-serif" font-size="13" font-weight="bold" fill="#1e3a8a">SoC TOP-LEVEL BOUNDARY (soc_top.sv) - RV32IMC Target</text>

            <!-- VeeR EL2 Core Box -->
            <rect x="40" y="55" width="220" height="150" rx="6" fill="#e0f2fe" stroke="#0284c7" stroke-width="2"/>
            <text x="55" y="78" font-family="sans-serif" font-size="12" font-weight="bold" fill="#0369a1">VeeR EL2 RISC-V CORE</text>
            <text x="55" y="96" font-family="sans-serif" font-size="9.5" fill="#334155">• RV32IMC 4-Stage Dual-Issue</text>
            <text x="55" y="112" font-family="sans-serif" font-size="9.5" fill="#334155">• 32 KB ICCM (Instruction Cache)</text>
            <text x="55" y="128" font-family="sans-serif" font-size="9.5" fill="#334155">• 64 KB DCCM (Data Cache)</text>
            <text x="55" y="144" font-family="sans-serif" font-size="9.5" fill="#334155">• Integrated PIC (8 Irq lines)</text>
            <text x="55" y="160" font-family="sans-serif" font-size="9.5" fill="#334155">• Hardware Multiplier/Divider</text>
            <rect x="50" y="172" width="200" height="24" rx="3" fill="#bae6fd" stroke="#0284c7" stroke-width="1"/>
            <text x="75" y="188" font-family="sans-serif" font-size="9.5" font-weight="bold" fill="#0369a1">AXI4 / AHB-Lite Master</text>

            <!-- SRAM Box -->
            <rect x="40" y="240" width="220" height="85" rx="6" fill="#fef3c7" stroke="#d97706" stroke-width="2"/>
            <text x="55" y="265" font-family="sans-serif" font-size="11.5" font-weight="bold" fill="#b45309">ON-CHIP SRAM (64 KB)</text>
            <text x="55" y="285" font-family="sans-serif" font-size="9" fill="#78350f">• Base: 0x0000_0000 - 0x0000_FFFF</text>
            <text x="55" y="302" font-family="sans-serif" font-size="9" fill="#78350f">• Single-Cycle Synchronous Access</text>
            <text x="55" y="318" font-family="sans-serif" font-size="9" fill="#78350f">• Program Code & Stack/Heap</text>

            <!-- Central Interconnect Crossbar -->
            <rect x="300" y="55" width="130" height="360" rx="6" fill="#f1f5f9" stroke="#475569" stroke-width="2.5"/>
            <text x="315" y="85" font-family="sans-serif" font-size="11" font-weight="bold" fill="#1e293b">MEMORY-MAPPED</text>
            <text x="318" y="103" font-family="sans-serif" font-size="11" font-weight="bold" fill="#1e293b">CROSSBAR BUS</text>
            <text x="325" y="125" font-family="sans-serif" font-size="8.5" fill="#475569">• 32-bit Address</text>
            <text x="325" y="140" font-family="sans-serif" font-size="8.5" fill="#475569">• 32-bit Data</text>
            <text x="325" y="155" font-family="sans-serif" font-size="8.5" fill="#475569">• Round-Robin Arb</text>
            <text x="325" y="170" font-family="sans-serif" font-size="8.5" fill="#475569">• Byte Enables</text>
            <text x="325" y="185" font-family="sans-serif" font-size="8.5" fill="#475569">• DECERR Handler</text>
            <text x="325" y="200" font-family="sans-serif" font-size="8.5" fill="#475569">• Single-cycle Ack</text>

            <!-- Peripherals Right Column -->
            <!-- UART -->
            <rect x="470" y="55" width="140" height="48" rx="4" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.5"/>
            <text x="480" y="73" font-family="sans-serif" font-size="10" font-weight="bold" fill="#5b21b6">UART Subsystem</text>
            <text x="480" y="88" font-family="sans-serif" font-size="8" fill="#4c1d95">0x1000_0000 | 115.2k</text>

            <!-- GPIO -->
            <rect x="470" y="112" width="140" height="48" rx="4" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5"/>
            <text x="480" y="130" font-family="sans-serif" font-size="10" font-weight="bold" fill="#15803d">GPIO (32-bit)</text>
            <text x="480" y="145" font-family="sans-serif" font-size="8" fill="#14532d">0x1000_1000 | LEDs/Keys</text>

            <!-- Timer -->
            <rect x="470" y="169" width="140" height="48" rx="4" fill="#ffedd5" stroke="#ea580c" stroke-width="1.5"/>
            <text x="480" y="187" font-family="sans-serif" font-size="10" font-weight="bold" fill="#c2410c">32-Bit Timer</text>
            <text x="480" y="202" font-family="sans-serif" font-size="8" fill="#7c2d12">0x1000_2000 | Pacing</text>

            <!-- SPI -->
            <rect x="470" y="226" width="140" height="48" rx="4" fill="#fae8ff" stroke="#c026d3" stroke-width="1.5"/>
            <text x="480" y="244" font-family="sans-serif" font-size="10" font-weight="bold" fill="#a21caf">SPI Master</text>
            <text x="480" y="259" font-family="sans-serif" font-size="8" fill="#701a75">0x1000_3000 | Flash Log</text>

            <!-- I2C -->
            <rect x="470" y="283" width="140" height="48" rx="4" fill="#e0e7ff" stroke="#4338ca" stroke-width="1.5"/>
            <text x="480" y="301" font-family="sans-serif" font-size="10" font-weight="bold" fill="#3730a3">I2C Master</text>
            <text x="480" y="316" font-family="sans-serif" font-size="8" fill="#312e81">0x1000_4000 | Sensors</text>

            <!-- PWM -->
            <rect x="470" y="340" width="140" height="48" rx="4" fill="#fee2e2" stroke="#dc2626" stroke-width="1.5"/>
            <text x="480" y="358" font-family="sans-serif" font-size="10" font-weight="bold" fill="#b91c1c">PWM Generator</text>
            <text x="480" y="373" font-family="sans-serif" font-size="8" fill="#7f1d1d">0x1000_5000 | Buzzer</text>

            <!-- External Pads / Signals -->
            <text x="625" y="75" font-family="monospace" font-size="8" font-weight="bold" fill="#4c1d95">uart_tx/rx</text>
            <text x="625" y="132" font-family="monospace" font-size="8" font-weight="bold" fill="#14532d">gpio_io[31:0]</text>
            <text x="625" y="189" font-family="monospace" font-size="8" font-weight="bold" fill="#7c2d12">sample_tick</text>
            <text x="625" y="246" font-family="monospace" font-size="8" font-weight="bold" fill="#701a75">spi_sclk/mosi</text>
            <text x="625" y="303" font-family="monospace" font-size="8" font-weight="bold" fill="#312e81">i2c_scl/sda</text>
            <text x="625" y="360" font-family="monospace" font-size="8" font-weight="bold" fill="#7f1d1d">pwm_pad_o</text>

            <!-- Arrows Left to Middle -->
            <line x1="260" y1="130" x2="300" y2="130" stroke="#0284c7" stroke-width="2.5" marker-end="url(#arrow)"/>
            <line x1="260" y1="280" x2="300" y2="280" stroke="#d97706" stroke-width="2.5"/>

            <!-- Arrows Middle to Right -->
            <line x1="430" y1="78" x2="470" y2="78" stroke="#7c3aed" stroke-width="2"/>
            <line x1="430" y1="135" x2="470" y2="135" stroke="#16a34a" stroke-width="2"/>
            <line x1="430" y1="192" x2="470" y2="192" stroke="#ea580c" stroke-width="2"/>
            <line x1="430" y1="249" x2="470" y2="249" stroke="#c026d3" stroke-width="2"/>
            <line x1="430" y1="306" x2="470" y2="306" stroke="#4338ca" stroke-width="2"/>
            <line x1="430" y1="363" x2="470" y2="363" stroke="#dc2626" stroke-width="2"/>

            <!-- External Arrows -->
            <line x1="610" y1="78" x2="650" y2="78" stroke="#7c3aed" stroke-width="1.5"/>
            <line x1="610" y1="135" x2="650" y2="135" stroke="#16a34a" stroke-width="1.5"/>
            <line x1="610" y1="192" x2="650" y2="192" stroke="#ea580c" stroke-width="1.5"/>
            <line x1="610" y1="249" x2="650" y2="249" stroke="#c026d3" stroke-width="1.5"/>
            <line x1="610" y1="306" x2="650" y2="306" stroke="#4338ca" stroke-width="1.5"/>
            <line x1="610" y1="363" x2="650" y2="363" stroke="#dc2626" stroke-width="1.5"/>
        </svg>
    </div>
    """
    pages.append(make_page(p5_content, "5"))

    # ==============================================================================
    # PAGE 6: IP Inventory Table (Table 2.1)
    # ==============================================================================
    p6_content = """
    <h2 class="sec-title">2.2 System-Level Specifications & IP Inventory</h2>
    <p>
        The SoC hardware comprises seven distinct on-chip intellectual property (IP) blocks interconnected through a memory-mapped crossbar switch. Table 2.1 specifies the functional parameters, memory allocations, and bus protocol standards for every integrated core.
    </p>

    <div class="caption"><b>Table 2.1:</b> Complete IP Block Inventory & Parameter Specifications</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 14%;">IP Block</th>
                <th style="width: 18%;">Standard / Type</th>
                <th style="width: 18%;">Base Address</th>
                <th style="width: 14%;">Size / Span</th>
                <th style="width: 36%;">Key Features & Operational Role</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><b>VeeR EL2</b></td>
                <td>RV32IMC Core</td>
                <td>N/A (Master)</td>
                <td>Internal</td>
                <td>4-stage pipeline, dual-issue superscalar, 32 KB ICCM, 64 KB DCCM, integrated PIC, 50 MHz.</td>
            </tr>
            <tr>
                <td><b>On-Chip SRAM</b></td>
                <td>Synchronous RAM</td>
                <td><code>0x0000_0000</code></td>
                <td>64 KB</td>
                <td>Single-cycle zero-wait-state memory for firmware execution, variables, stack, and heap.</td>
            </tr>
            <tr>
                <td><b>UART Controller</b></td>
                <td>Memory-Mapped</td>
                <td><code>0x1000_0000</code></td>
                <td>4 KB</td>
                <td>8-N-1 framing, 115200 baud @ 50MHz, 16-byte TX/RX FIFOs, overrun detection, interrupt generation.</td>
            </tr>
            <tr>
                <td><b>GPIO Controller</b></td>
                <td>Memory-Mapped</td>
                <td><code>0x1000_1000</code></td>
                <td>4 KB</td>
                <td>32 bidirectional I/O pins, individual direction masking, edge/level interrupt triggers, LED driver.</td>
            </tr>
            <tr>
                <td><b>Interval Timer</b></td>
                <td>Memory-Mapped</td>
                <td><code>0x1000_2000</code></td>
                <td>4 KB</td>
                <td>32-bit prescaler, 32-bit counter, periodic tick generation, sampling cadence pacing, time-stamping.</td>
            </tr>
            <tr>
                <td><b>SPI Master</b></td>
                <td>Motorola SPI</td>
                <td><code>0x1000_3000</code></td>
                <td>4 KB</td>
                <td>CPOL=0, CPHA=0, 4-wire interface, programmable baud divider, 8-bit burst logging to Flash.</td>
            </tr>
            <tr>
                <td><b>I2C Master</b></td>
                <td>Philips / NXP I2C</td>
                <td><code>0x1000_4000</code></td>
                <td>4 KB</td>
                <td>Standard/Fast mode (100/400 kHz), automated START/STOP, 7-bit addressing, ACK/NACK detection.</td>
            </tr>
            <tr>
                <td><b>PWM Generator</b></td>
                <td>Memory-Mapped</td>
                <td><code>0x1000_5000</code></td>
                <td>4 KB</td>
                <td>8-bit duty cycle resolution, programmable period, audible alarm frequency synthesis for buzzer.</td>
            </tr>
            <tr>
                <td><b>AES-128 Engine*</b></td>
                <td>NIST FIPS-197</td>
                <td>Isolated Subsys</td>
                <td>128-bit Core</td>
                <td>10-round iterative cryptographic transform, 128-bit key/data, standalone telemetry hardening testbench.</td>
            </tr>
        </tbody>
    </table>
    <p style="font-size: 8pt; color: #555; margin-top: 4px;">
        *Note: The AES-128 engine is maintained as an isolated verification module within the repository (<code>aes/</code> directory) to demonstrate cryptographic hardening without altering the core SoC baseline RTL footprint.
    </p>

    <h2 class="sec-title">2.3 External Top-Level Pinout Specifications</h2>
    <p>
        The top-level SoC boundary interface (<code>soc_top.sv</code>) exposes power, reference clock, active-low asynchronous reset, and dedicated digital I/O pads for peripheral communication. Table 2.2 itemizes the primary control and telemetry signals.
    </p>
    """
    pages.append(make_page(p6_content, "6"))

    # ==============================================================================
    # PAGE 7: Pinout Tables 2.2 and 2.3
    # ==============================================================================
    p7_content = """
    <div class="caption"><b>Table 2.2:</b> System Power, Clock, and Primary Communication Interface Pinout</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 18%;">Port Identifier</th>
                <th style="width: 12%;">Direction</th>
                <th style="width: 10%;">Width</th>
                <th style="width: 15%;">Voltage</th>
                <th style="width: 45%;">Functional Description</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>clk</code></td>
                <td>Input</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>Primary master system clock (50.0 MHz nominal).</td>
            </tr>
            <tr>
                <td><code>rst_n</code></td>
                <td>Input</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>Active-low asynchronous system master reset.</td>
            </tr>
            <tr>
                <td><code>uart_rx</code></td>
                <td>Input</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>UART asynchronous serial receive data line (Host PC to SoC).</td>
            </tr>
            <tr>
                <td><code>uart_tx</code></td>
                <td>Output</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>UART asynchronous serial transmit data line (SoC to Host PC).</td>
            </tr>
            <tr>
                <td><code>gpio_in[31:0]</code></td>
                <td>Input</td>
                <td>32</td>
                <td>3.3V CMOS</td>
                <td>General-purpose digital input bus (Pushbuttons, sensor alert pins).</td>
            </tr>
            <tr>
                <td><code>gpio_out[31:0]</code></td>
                <td>Output</td>
                <td>32</td>
                <td>3.3V CMOS</td>
                <td>General-purpose digital output bus (Status LEDs, relay triggers).</td>
            </tr>
            <tr>
                <td><code>gpio_dir[31:0]</code></td>
                <td>Output</td>
                <td>32</td>
                <td>3.3V CMOS</td>
                <td>Tristate buffer direction control (1=Output, 0=Input).</td>
            </tr>
        </tbody>
    </table>

    <div class="caption"><b>Table 2.3:</b> Sensor, Logging, Alert, and Debug Interface Pinout</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 18%;">Port Identifier</th>
                <th style="width: 12%;">Direction</th>
                <th style="width: 10%;">Width</th>
                <th style="width: 15%;">Voltage</th>
                <th style="width: 45%;">Functional Description</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>i2c_scl</code></td>
                <td>Output</td>
                <td>1</td>
                <td>3.3V OD*</td>
                <td>I2C serial clock line (100 kHz standard mode).</td>
            </tr>
            <tr>
                <td><code>i2c_sda_out</code></td>
                <td>Output</td>
                <td>1</td>
                <td>3.3V OD*</td>
                <td>I2C serial data output (Active low open-drain drive).</td>
            </tr>
            <tr>
                <td><code>i2c_sda_in</code></td>
                <td>Input</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>I2C serial data input (Readback from sensor bus).</td>
            </tr>
            <tr>
                <td><code>spi_sclk</code></td>
                <td>Output</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>SPI master serial clock (up to 12.5 MHz).</td>
            </tr>
            <tr>
                <td><code>spi_mosi</code></td>
                <td>Output</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>SPI Master-Out-Slave-In serial data to Flash memory.</td>
            </tr>
            <tr>
                <td><code>spi_miso</code></td>
                <td>Input</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>SPI Master-In-Slave-Out serial data from Flash memory.</td>
            </tr>
            <tr>
                <td><code>spi_cs_n</code></td>
                <td>Output</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>SPI active-low chip select.</td>
            </tr>
            <tr>
                <td><code>pwm_pad_o</code></td>
                <td>Output</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>Pulse-width modulated output driving acoustic piezo alarm.</td>
            </tr>
            <tr>
                <td><code>sample_tick</code></td>
                <td>Output</td>
                <td>1</td>
                <td>3.3V CMOS</td>
                <td>Deterministic interval timer cadence tick (Scope sync).</td>
            </tr>
        </tbody>
    </table>
    <p style="font-size: 8pt; color: #555; margin-top: 4px;">
        *OD = Open-Drain configuration requiring external 4.7 kΩ pull-up resistors to 3.3V rail.
    </p>
    """
    pages.append(make_page(p7_content, "7"))

    # ==============================================================================
    # PAGE 8: Control Path Arbitration & Interconnect Bus Matrix
    # ==============================================================================
    p8_content = """
    <h2 class="sec-title">2.4 Control Path Arbitration & Interconnect Bus Matrix</h2>
    <p>
        The central bus interconnect is implemented as a multi-master, multi-slave memory-mapped crossbar switch. It coordinates transactions between the VeeR EL2 processor core (driving both instruction fetch and data load/store masters) and the seven target slave modules (SRAM and 6 peripherals).
    </p>

    <h3 class="subsec-title">2.4.1 Arbitration Protocol & Starvation Prevention</h3>
    <p>
        Arbitration across conflicting peripheral accesses employs a fair Round-Robin algorithm. Each master is allocated a single burst/word window before arbitration advances to the next requesting agent. This eliminates master starvation during extended logging cycles. If an invalid or unmapped memory address (e.g., outside the valid SRAM or peripheral apertures) is asserted, the interconnect decodes the address into a dedicated Decode Error (DECERR) response channel, triggering a non-maskable bus fault exception in the processor core.
    </p>

    <h3 class="subsec-title">2.4.2 Address Decoding & Aperture Routing</h3>
    <p>
        The address decode logic examines upper address bits <code>[31:28]</code> and <code>[27:12]</code> to route read/write requests:
    </p>
    <ul>
        <li><b>Region 0x0000_0000 - 0x0000_FFFF:</b> Decoded directly to the 64 KB on-chip SRAM with zero wait states.</li>
        <li><b>Region 0x1000_0000 - 0x1000_5FFF:</b> Decoded to the peripheral register subsystem. Address bits <code>[15:12]</code> select the specific peripheral instance (0x0 for UART, 0x1 for GPIO, 0x2 for Timer, 0x3 for SPI, 0x4 for I2C, 0x5 for PWM).</li>
        <li><b>Unmapped Regions:</b> Immediately routed to the bus error trap logic with an error response cycle (<code>resp = 2'b10</code>).</li>
    </ul>

    <h3 class="subsec-title">2.4.3 Bus Timing & Wait-State Generation</h3>
    <p>
        The crossbar supports single-cycle synchronous handshakes for high-speed SRAM accesses (<code>ready = 1'b1</code> asserted on the cycle following request). Peripheral accesses introduce deterministic wait states matching the internal peripheral register update timings (typically 1 to 2 clock cycles).
    </p>
    """
    pages.append(make_page(p8_content, "8"))

    # ==============================================================================
    # PAGE 9: Data Path Pipeline & Sensor Ingest Subsystem (I2C)
    # ==============================================================================
    p9_content = """
    <h2 class="sec-title">2.5 Data Path Pipeline & Peripheral Interconnect Bridge</h2>
    <p>
        The SoC data path establishes a high-throughput, low-latency pipeline connecting ambient physical sensors to non-volatile storage and host telemetry. During normal operation, data progresses through five deterministic stages:
    </p>
    <ol>
        <li><b>Physical Sensing Ingest:</b> Digital sensors (e.g., SHT31, BME280) serialize ambient temperature and humidity onto the I2C bus. The I2C Master deserializes these packets into 32-bit internal register words.</li>
        <li><b>CPU Processing & Threshold Comparison:</b> The VeeR EL2 core reads raw sensor words from the I2C registers, converts them to engineering units (°C, %RH), and compares them against software-configured warning and critical thresholds.</li>
        <li><b>Timestamp Attachment:</b> The core queries the 32-bit Interval Timer to obtain the current epoch timestamp, packing timestamp, temperature, and humidity into a standardized 16-byte telemetry record.</li>
        <li><b>Non-Volatile Logging:</b> The record is transferred to the SPI Master TX buffer, which autonomously clocks the data into external NOR Flash memory.</li>
        <li><b>Live Telemetry Streaming:</b> Formatted ASCII diagnostic frames (e.g., <code>[ENV-MON] T:24.5C H:48.2% STATUS:OK</code>) are queued into the UART FIFO for transmission to the monitoring terminal.</li>
    </ol>

    <h2 class="sec-title">2.6 Sensor Ingest Subsystem (I2C Master FSM)</h2>
    <p>
        The I2C Master IP executes sensor polling via a robust 6-state finite state machine (FSM): <code>IDLE</code>, <code>START</code>, <code>ADDR_TX</code>, <code>DATA_RX</code>, <code>ACK_CHECK</code>, and <code>STOP</code>. Clock stretching by slow sensors is monitored via continuous sampling of the <code>i2c_scl</code> line. If a slave fails to assert ACK within 9 clock pulses, a timeout interrupt flag is set, enabling firmware error recovery without hanging the processor pipeline.
    </p>
    """
    pages.append(make_page(p9_content, "9"))

    # ==============================================================================
    # PAGE 10: Timer and SPI Logging Subsystem
    # ==============================================================================
    p10_content = """
    <h2 class="sec-title">2.7 Precision Sampling Cadence Subsystem (Interval Timer)</h2>
    <p>
        The Interval Timer IP establishes the real-time heartbeat of the Environmental Monitoring SoC. It incorporates a 32-bit prescaler register (<code>TIMER_PRESCALER</code>) and a 32-bit reload counter (<code>TIMER_LOAD</code>).
    </p>

    <h3 class="subsec-title">2.7.1 Deterministic Cadence Generation</h3>
    <p>
        Operating from the 50 MHz system clock, the prescaler divides the master clock down to a 1 MHz base reference (50 clock ticks per microsecond). The 32-bit counter decrements on each prescaled tick. Upon reaching zero, the timer:
    </p>
    <ul>
        <li>Asserts a single-cycle external synchronization pulse on <code>sample_tick</code> for oscilloscope and logic analyzer triggering.</li>
        <li>Asserts an internal level-sensitive interrupt line to the VeeR EL2 Programmable Interrupt Controller (PIC).</li>
        <li>Automatically reloads the counter value from <code>TIMER_LOAD</code> in periodic mode, ensuring zero drift across millions of sensor acquisition cycles.</li>
    </ul>

    <h2 class="sec-title">2.8 Non-Volatile Telemetry Logging Subsystem (SPI Master)</h2>
    <p>
        To prevent loss of environmental records during power disruptions, the SoC integrates a high-speed SPI Master controller driving an external SPI NOR Flash (e.g., Winbond W25Q128).
    </p>

    <h3 class="subsec-title">2.8.1 SPI Controller Architecture</h3>
    <p>
        The controller supports Motorola SPI Mode 0 (CPOL=0, CPHA=0). It incorporates:
    </p>
    <ul>
        <li><b>Baud Rate Generator:</b> Divides the 50 MHz core clock down to programmable SCK frequencies (typically 12.5 MHz).</li>
        <li><b>8-Bit Shift Register:</b> Performs simultaneous full-duplex serialization and deserialization between <code>spi_mosi</code> and <code>spi_miso</code>.</li>
        <li><b>Automated Chip-Select (CS_N):</b> Firmware asserts CS_N by writing to the control register, transfers multi-byte write bursts (Flash Page Program command 0x02 + 24-bit address + 16-byte record), and deasserts CS_N upon completion.</li>
    </ul>
    """
    pages.append(make_page(p10_content, "10"))

    # ==============================================================================
    # PAGE 11: Alerting (PWM & GPIO) and Telemetry (UART)
    # ==============================================================================
    p11_content = """
    <h2 class="sec-title">2.9 Alerting & Annunciation Subsystem (PWM & GPIO)</h2>
    <p>
        The alerting subsystem provides immediate, hardware-driven acoustic and visual feedback when environmental readings exceed safe operating envelopes (e.g., ambient temperature &gt; 45°C or humidity &gt; 80%).
    </p>

    <h3 class="subsec-title">2.9.1 PWM Audio Buzzer Modulator</h3>
    <p>
        The PWM controller generates variable-frequency, variable-duty-cycle square waves to drive an external piezoelectric transducer. The period register (<code>PWM_PERIOD</code>) establishes the tone frequency (e.g., 2 kHz warning tone, 4 kHz critical alarm), while the duty cycle register (<code>PWM_DUTY</code>) modulates acoustic volume. Under normal environmental conditions, firmware sets the enable bit to 0, completely silencing the buzzer.
    </p>

    <h3 class="subsec-title">2.9.2 GPIO Status Annunciation</h3>
    <p>
        The 32-bit GPIO controller provides atomic bit-set and bit-clear registers. Pins <code>gpio_out[3:0]</code> drive front-panel status LEDs:
    </p>
    <ul>
        <li><code>LED[0] (Green):</code> System heartbeat (toggled by the timer interrupt service routine).</li>
        <li><code>LED[1] (Blue):</code> Active I2C sensor acquisition / SPI Flash write in progress.</li>
        <li><code>LED[2] (Yellow):</code> Warning threshold exceeded (temperature &gt; 35°C).</li>
        <li><code>LED[3] (Red):</code> Critical threshold alarm (temperature &gt; 45°C or sensor hardware fault).</li>
    </ul>

    <h2 class="sec-title">2.10 Host Telemetry Streaming Subsystem (UART Transceiver)</h2>
    <p>
        The UART controller provides the primary serial telemetry link to host computers, industrial SCADA systems, or wireless cellular modems. Configured for 115200 baud, 8 data bits, no parity, and 1 stop bit (8-N-1), it features 16-byte circular transmit and receive FIFOs. A fractional baud rate divider ensures &lt;0.5% timing error at 50 MHz, ensuring zero framing errors across extended transmissions.
    </p>
    """
    pages.append(make_page(p11_content, "11"))

    # ==============================================================================
    # PAGE 12: Clock, Reset, and Interrupt Architecture
    # ==============================================================================
    p12_content = """
    <h2 class="sec-title">2.11 Clock Domain, Reset Tree, and Power Architecture</h2>
    <p>
        To ensure high reliability and eliminate metastable clock-domain crossings, the SoC operates within a synchronous single-clock domain running at 50.0 MHz.
    </p>

    <h3 class="subsec-title">2.11.1 Reset Tree Architecture</h3>
    <p>
        The active-low master reset (<code>rst_n</code>) is applied asynchronously from an external supervisor IC and synchronized internally using a 2-stage flip-flop synchronizer. This guarantees that reset deassertion is strictly synchronous with the rising edge of <code>clk</code>, preventing race conditions during core boot.
    </p>

    <h2 class="sec-title">2.12 Interrupt Architecture & Core Vectored Servicing</h2>
    <p>
        The VeeR EL2 core integrates a Programmable Interrupt Controller (PIC) supporting up to 8 prioritized external interrupt sources. Interrupt assignments are mapped as follows:
    </p>
    <ul>
        <li><b>IRQ 0 (Priority 7 - Highest):</b> Hardware Watchdog / Emergency Operator Panic Button (GPIO pin 0 edge).</li>
        <li><b>IRQ 1 (Priority 6):</b> Interval Timer Cadence Tick (initiates periodic sensor acquisition loop).</li>
        <li><b>IRQ 2 (Priority 5):</b> I2C Transaction Complete / Error Interrupt.</li>
        <li><b>IRQ 3 (Priority 4):</b> SPI Transfer Complete (Flash write buffer committed).</li>
        <li><b>IRQ 4 (Priority 3):</b> UART Receiver FIFO Threshold (incoming host command packet).</li>
        <li><b>IRQ 5 (Priority 2):</b> UART Transmitter FIFO Empty (ready to stream next telemetry packet).</li>
        <li><b>IRQ 6 (Priority 1):</b> GPIO Level Alert (auxiliary environmental threshold sensor trip).</li>
        <li><b>IRQ 7 (Priority 0 - Lowest):</b> Software test trigger interrupt.</li>
    </ul>
    <p>
        The core services interrupts through a vectored table in SRAM, minimizing ISR latency to under 12 clock cycles (240 ns @ 50 MHz).
    </p>
    """
    pages.append(make_page(p12_content, "12"))

    # ==============================================================================
    # PAGE 13: Safety, Fault Handling, and Bus Error Protection
    # ==============================================================================
    p13_content = """
    <h2 class="sec-title">2.13 Safety, Fault Handling, and Bus Error Protection</h2>
    <p>
        Safety-critical industrial edge systems require robust hardware fault tolerance to prevent catastrophic runaway conditions. The SoC incorporates multi-layered protection mechanisms:
    </p>

    <h3 class="subsec-title">2.13.1 Decode Error (DECERR) Trapping</h3>
    <p>
        Whenever software or a speculative instruction fetch addresses an unmapped memory region (outside the 64 KB SRAM aperture or valid peripheral registers), the crossbar bus matrix aborts the transaction and returns a <code>DECERR</code> response (<code>resp = 2'b10</code>). The VeeR EL2 core traps this condition as a Precise Synchronous Bus Fault, transferring execution to a fail-safe exception handler that logs the offending program counter (PC) and safely resets the peripheral subsystem.
    </p>

    <h3 class="subsec-title">2.13.2 Peripheral Bus Timeout Protection</h3>
    <p>
        Each peripheral controller incorporates a hardware watchdog timer (1024 clock cycles). If an external slave device locks the bus (for example, if a damaged I2C sensor permanently pulls <code>i2c_sda</code> low), the peripheral hardware FSM forcibly aborts the transaction, asserts a bus error interrupt, and releases the internal bus interface to allow normal core operation to continue.
    </p>

    <div class="callout">
        <div class="callout-title">Summary of Architectural Compliance</div>
        <div class="callout-body">
            The SoC architecture combines the high processing throughput of the RV32IMC VeeR EL2 core with non-blocking hardware peripherals, deterministic round-robin arbitration, 64 KB single-cycle SRAM, and comprehensive fault trapping. This provides a resilient hardware platform for continuous, real-time environmental monitoring.
        </div>
    </div>
    """
    pages.append(make_page(p13_content, "13"))

    return pages
