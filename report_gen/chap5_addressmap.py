# -*- coding: utf-8 -*-
"""
Chapter 5: Address Map (Pages 22 to 25)
Candidate: Namratha Kavididevi (Roll No: 1602-23-735-157)
"""

from common import make_page

def get_chap5_pages():
    pages = []

    # ==============================================================================
    # PAGE 22: Chapter Title, System-Level Address Map Overview, Table 5.1
    # ==============================================================================
    p22_content = """
    <h2 class="chap-num">Chapter 5</h2>
    <h1 class="chap-title">Address Map</h1>

    <h2 class="sec-title">5.1 System-Level Address Map Overview</h2>
    <p>
        The Environmental Monitoring SoC implements a unified 32-bit physical address space spanning <code>0x0000_0000</code> to <code>0xFFFF_FFFF</code> (4 Gigabytes). The lower 64 Kilobytes are assigned to single-cycle synchronous on-chip SRAM for code execution, global data, stack, and heap. The peripheral aperture commences at <code>0x1000_0000</code>, with each peripheral controller allocated an isolated 4 Kilobyte aperture to prevent address aliasing. All remaining unmapped regions are routed to the bus decode error (DECERR) trap. Table 5.1 defines the master memory map.
    </p>

    <div class="caption"><b>Table 5.1:</b> Master SoC Memory & Peripheral Address Map (0x0000_0000 – 0xFFFF_FFFF)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 20%;">Region / Subsystem</th>
                <th style="width: 25%;">Address Range</th>
                <th style="width: 12%;">Size</th>
                <th style="width: 10%;">Access</th>
                <th style="width: 33%;">Description & Target Hardware</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><b>On-Chip Unified SRAM</b></td>
                <td><code>0x0000_0000 - 0x0000_FFFF</code></td>
                <td>64 KB</td>
                <td>R/W/X</td>
                <td>Single-cycle instructions, data, stack, and heap.</td>
            </tr>
            <tr>
                <td><b>Reserved SRAM Gap</b></td>
                <td><code>0x0001_0000 - 0x0FFF_FFFF</code></td>
                <td>~255 MB</td>
                <td>None</td>
                <td>Unmapped space; triggers DECERR bus error trap.</td>
            </tr>
            <tr>
                <td><b>UART Controller</b></td>
                <td><code>0x1000_0000 - 0x1000_0FFF</code></td>
                <td>4 KB</td>
                <td>R/W</td>
                <td>8-N-1 115200 baud serial console and telemetry.</td>
            </tr>
            <tr>
                <td><b>GPIO Controller</b></td>
                <td><code>0x1000_1000 - 0x1000_1FFF</code></td>
                <td>4 KB</td>
                <td>R/W</td>
                <td>32-bit bidirectional digital I/O, LEDs, panic buttons.</td>
            </tr>
            <tr>
                <td><b>Interval Timer</b></td>
                <td><code>0x1000_2000 - 0x1000_2FFF</code></td>
                <td>4 KB</td>
                <td>R/W</td>
                <td>32-bit prescaler, sampling ticks, periodic ISR timer.</td>
            </tr>
            <tr>
                <td><b>SPI Master</b></td>
                <td><code>0x1000_3000 - 0x1000_3FFF</code></td>
                <td>4 KB</td>
                <td>R/W</td>
                <td>Non-volatile Flash memory telemetry logging.</td>
            </tr>
            <tr>
                <td><b>I2C Master</b></td>
                <td><code>0x1000_4000 - 0x1000_4FFF</code></td>
                <td>4 KB</td>
                <td>R/W</td>
                <td>Digital temperature and humidity sensor ingest.</td>
            </tr>
            <tr>
                <td><b>PWM Generator</b></td>
                <td><code>0x1000_5000 - 0x1000_5FFF</code></td>
                <td>4 KB</td>
                <td>R/W</td>
                <td>Variable duty/period audio buzzer threshold alarm.</td>
            </tr>
            <tr>
                <td><b>Reserved System Gap</b></td>
                <td><code>0x1000_6000 - 0xFFFF_FFFF</code></td>
                <td>~3.75 GB</td>
                <td>None</td>
                <td>Unmapped space; triggers DECERR bus error trap.</td>
            </tr>
        </tbody>
    </table>
    """
    pages.append(make_page(p22_content, "22"))

    # ==============================================================================
    # PAGE 23: Peripheral Register Specifications (UART & GPIO)
    # ==============================================================================
    p23_content = """
    <h2 class="sec-title">5.2 Peripheral Register Specifications</h2>
    <p>
        All peripheral registers are 32-bit aligned. Software accesses must use 32-bit load/store instructions (<code>lw</code> / <code>sw</code>). Sub-word writes are gated by internal byte-enable lines (<code>we[3:0]</code>).
    </p>

    <div class="caption"><b>Table 5.2:</b> UART Controller Register Map (Base: 0x1000_0000)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 22%;">Register Name</th>
                <th style="width: 18%;">Offset Address</th>
                <th style="width: 10%;">Type</th>
                <th style="width: 14%;">Reset Value</th>
                <th style="width: 36%;">Bit Field Functionality</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>UART_DATA</code></td>
                <td><code>0x1000_0000</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>[7:0] TX write data / RX read data byte.</td>
            </tr>
            <tr>
                <td><code>UART_STATUS</code></td>
                <td><code>0x1000_0004</code></td>
                <td>RO</td>
                <td><code>0x0000_0002</code></td>
                <td>Bit 0: RX FIFO Ready, Bit 1: TX FIFO Empty, Bit 2: Overrun Error.</td>
            </tr>
            <tr>
                <td><code>UART_CTRL</code></td>
                <td><code>0x1000_0008</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>Bit 0: TX Enable, Bit 1: RX Enable, Bit 2: RX Interrupt Enable.</td>
            </tr>
            <tr>
                <td><code>UART_BAUD_DIV</code></td>
                <td><code>0x1000_000C</code></td>
                <td>R/W</td>
                <td><code>0x0000_01B2</code></td>
                <td>[15:0] Clock divider = 50MHz / (16 × 115200) = 434 (0x1B2).</td>
            </tr>
        </tbody>
    </table>

    <div class="caption"><b>Table 5.3:</b> General Purpose I/O (GPIO) Register Map (Base: 0x1000_1000)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 22%;">Register Name</th>
                <th style="width: 18%;">Offset Address</th>
                <th style="width: 10%;">Type</th>
                <th style="width: 14%;">Reset Value</th>
                <th style="width: 36%;">Bit Field Functionality</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>GPIO_DATA_IN</code></td>
                <td><code>0x1000_1000</code></td>
                <td>RO</td>
                <td><code>0x0000_0000</code></td>
                <td>[31:0] Current physical state of external GPIO pins.</td>
            </tr>
            <tr>
                <td><code>GPIO_DATA_OUT</code></td>
                <td><code>0x1000_1004</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>[31:0] Output drive latch (LEDs, relays, triggers).</td>
            </tr>
            <tr>
                <td><code>GPIO_DIR</code></td>
                <td><code>0x1000_1008</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>[31:0] Direction mask: 1 = Output drive, 0 = Input tristate.</td>
            </tr>
            <tr>
                <td><code>GPIO_INT_EN</code></td>
                <td><code>0x1000_100C</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>[31:0] Interrupt enable mask per pin (Edge/level trigger).</td>
            </tr>
        </tbody>
    </table>
    """
    pages.append(make_page(p23_content, "23"))

    # ==============================================================================
    # PAGE 24: Peripheral Register Specifications (Timer & SPI)
    # ==============================================================================
    p24_content = """
    <div class="caption"><b>Table 5.4:</b> 32-Bit Interval Timer Register Map (Base: 0x1000_2000)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 22%;">Register Name</th>
                <th style="width: 18%;">Offset Address</th>
                <th style="width: 10%;">Type</th>
                <th style="width: 14%;">Reset Value</th>
                <th style="width: 36%;">Bit Field Functionality</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>TIMER_CTRL</code></td>
                <td><code>0x1000_2000</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>Bit 0: Enable, Bit 1: Auto-Reload, Bit 2: Interrupt Enable.</td>
            </tr>
            <tr>
                <td><code>TIMER_LOAD</code></td>
                <td><code>0x1000_2004</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>[31:0] Initial reload value for down-counter.</td>
            </tr>
            <tr>
                <td><code>TIMER_COUNTER</code></td>
                <td><code>0x1000_2008</code></td>
                <td>RO</td>
                <td><code>0x0000_0000</code></td>
                <td>[31:0] Current running countdown value (read on-the-fly).</td>
            </tr>
            <tr>
                <td><code>TIMER_PRESCALER</code></td>
                <td><code>0x1000_200C</code></td>
                <td>R/W</td>
                <td><code>0x0000_0031</code></td>
                <td>[15:0] Prescaler divider value (50 = 1 MHz tick @ 50 MHz).</td>
            </tr>
        </tbody>
    </table>

    <div class="caption"><b>Table 5.5:</b> SPI Master Controller Register Map (Base: 0x1000_3000)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 22%;">Register Name</th>
                <th style="width: 18%;">Offset Address</th>
                <th style="width: 10%;">Type</th>
                <th style="width: 14%;">Reset Value</th>
                <th style="width: 36%;">Bit Field Functionality</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>SPI_CTRL</code></td>
                <td><code>0x1000_3000</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>Bit 0: Enable, Bit 1: CPOL, Bit 2: CPHA, [7:4] Baud Prescaler.</td>
            </tr>
            <tr>
                <td><code>SPI_STATUS</code></td>
                <td><code>0x1000_3004</code></td>
                <td>RO</td>
                <td><code>0x0000_0001</code></td>
                <td>Bit 0: Transfer Complete, Bit 1: Busy, Bit 2: RX FIFO Full.</td>
            </tr>
            <tr>
                <td><code>SPI_DATA</code></td>
                <td><code>0x1000_3008</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>[7:0] Transmit data byte (Write) / Receive byte (Read).</td>
            </tr>
            <tr>
                <td><code>SPI_CS</code></td>
                <td><code>0x1000_300C</code></td>
                <td>R/W</td>
                <td><code>0x0000_0001</code></td>
                <td>Bit 0: Active-low chip select control (0 = Asserted, 1 = Idle).</td>
            </tr>
        </tbody>
    </table>
    """
    pages.append(make_page(p24_content, "24"))

    # ==============================================================================
    # PAGE 25: Peripheral Register Specifications (I2C & PWM) & Bus Fault Logic
    # ==============================================================================
    p25_content = """
    <div class="caption"><b>Table 5.6:</b> I2C Master Controller Register Map (Base: 0x1000_4000)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 22%;">Register Name</th>
                <th style="width: 18%;">Offset Address</th>
                <th style="width: 10%;">Type</th>
                <th style="width: 14%;">Reset Value</th>
                <th style="width: 36%;">Bit Field Functionality</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>I2C_CTRL</code></td>
                <td><code>0x1000_4000</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>Bit 0: Start, Bit 1: Stop, Bit 2: Read/Write, Bit 3: Ack En.</td>
            </tr>
            <tr>
                <td><code>I2C_STATUS</code></td>
                <td><code>0x1000_4004</code></td>
                <td>RO</td>
                <td><code>0x0000_0000</code></td>
                <td>Bit 0: Busy, Bit 1: RxACK, Bit 2: Transfer Done, Bit 3: Error.</td>
            </tr>
            <tr>
                <td><code>I2C_ADDR</code></td>
                <td><code>0x1000_4008</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>[6:0] Target 7-bit sensor slave address (e.g., 0x44 for SHT31).</td>
            </tr>
            <tr>
                <td><code>I2C_DATA</code></td>
                <td><code>0x1000_400C</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>[7:0] Ingested sensor data byte / Command parameter byte.</td>
            </tr>
        </tbody>
    </table>

    <div class="caption"><b>Table 5.7:</b> PWM Audio Buzzer Modulator Register Map (Base: 0x1000_5000)</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 22%;">Register Name</th>
                <th style="width: 18%;">Offset Address</th>
                <th style="width: 10%;">Type</th>
                <th style="width: 14%;">Reset Value</th>
                <th style="width: 36%;">Bit Field Functionality</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>PWM_CTRL</code></td>
                <td><code>0x1000_5000</code></td>
                <td>R/W</td>
                <td><code>0x0000_0000</code></td>
                <td>Bit 0: PWM Output Enable, Bit 1: Invert Polarity.</td>
            </tr>
            <tr>
                <td><code>PWM_PERIOD</code></td>
                <td><code>0x1000_5004</code></td>
                <td>R/W</td>
                <td><code>0x0000_61A8</code></td>
                <td>[15:0] Period divider = 50MHz / 2kHz = 25000 (0x61A8).</td>
            </tr>
            <tr>
                <td><code>PWM_DUTY</code></td>
                <td><code>0x1000_5008</code></td>
                <td>R/W</td>
                <td><code>0x0000_30D4</code></td>
                <td>[15:0] Active high duty count = 50% = 12500 (0x30D4).</td>
            </tr>
        </tbody>
    </table>

    <h2 class="sec-title">5.3 Address Decode Logic & Bus Fault Handling</h2>
    <p>
        Address decode error handling is implemented inside the interconnect crossbar logic. If the core initiates an access to an unmapped address (e.g., <code>0x1000_6000</code> or <code>0x2000_0000</code>), the default decoder branch asserts <code>resp = 2'b10</code> (DECERR) and returns <code>rdata = 32'hDEAD_BEEF</code>, triggering an exception in the VeeR EL2 core without stalling bus transactions.
    </p>
    """
    pages.append(make_page(p25_content, "25"))

    return pages
