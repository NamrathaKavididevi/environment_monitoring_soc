# UVM Testbench Block Diagram with All UVM VIPs

**Student Name:** Namratha Kavididevi  
**Roll Number:** 1602-23-735-157  
**Department:** Electronics and Communication Engineering  
**Institution:** Vasavi College of Engineering (Autonomous), Hyderabad  
**Academic Year:** 2026-2027  
**Project:** RTL-Based Environmental Monitoring and Data-Logging SoC  

---

## 1. UVM Testbench Architecture Overview
The verification environment is architected using the Universal Verification Methodology (UVM 1.2 / IEEE 1800.2). The testbench verifies both individual IP blocks and the complete SoC system. The hierarchy consists of a top-level test (`soc_test`) instantiating the SoC environment (`soc_env`), which integrates 6 dedicated UVM Verification IP (VIP) agents alongside a unified multi-channel scoreboard and virtual sequencer.

```
+=============================================================================================================================+
|                                                      UVM TESTBENCH TOP (tb_top)                                             |
|                                                                                                                             |
|  +-----------------------------------------------------------------------------------------------------------------------+  |
|  |                                                 UVM ROOT: uvm_test_top (soc_test)                                    |  |
|  |                                                                                                                       |  |
|  |   +---------------------------------------------------------------------------------------------------------------+   |  |
|  |   |                                              UVM ENVIRONMENT (soc_env)                                        |   |  |
|  |   |                                                                                                               |   |  |
|  |   |   +---------------------------------------+                   +-------------------------------------------+   |   |  |
|  |   |   |            VIRTUAL SEQUENCER          |                   |             SOC SCOREBOARD                |   |   |  |
|  |   |   |       (soc_virtual_sequencer)         |                   |            (soc_scoreboard)               |   |   |  |
|  |   |   |  * Coordinates cross-IP scenarios     |                   |  * Compares C-firmware actions with       |   |   |  |
|  |   |   |  * Synchronizes acquire-log-alert     |                   |    peripheral monitor transactions        |   |   |  |
|  |   |   +--+--------+--------+--------+----+----+                   +---^-------^-------^-------^-------^-------^-+   |   |  |
|  |   |      |        |        |        |    |    |                       |       |       |       |       |       |      |   |  |
|  |   |   +--v--+  +--v--+  +--v--+  +--v--+ |    |                       |       |       |       |       |       |      |   |  |
|  |   |   |UART |  |GPIO |  |TIMER|  |SPI  | |I2C |PWM                    |       |       |       |       |       |      |   |  |
|  |   |   |SEQR |  |SEQR |  |SEQR |  |SEQR | |SEQR|SEQR                   |       |       |       |       |       |      |   |  |
|  |   |   +--+--+  +--+--+  +--+--+  +--+--+ +-+--+-+-+                   |       |       |       |       |       |      |   |  |
|  |   |      |        |        |        |      |    |                     |       |       |       |       |       |      |   |  |
|  |   |   +--v--------v--------v--------v------v----v---------------------+-------+-------+-------+-------+-------+--+   |   |  |
|  |   |   |                                 6 COMPLETE UVM VIP AGENTS                                            |   |   |  |
|  |   |   |                                                                                                      |   |   |  |
|  |   |   |  +------------+ +------------+ +------------+ +------------+ +------------+ +------------+           |   |   |  |
|  |   |   |  |  UART VIP  | |  GPIO VIP  | | TIMER VIP  | |  SPI VIP   | |  I2C VIP   | |  PWM VIP   |           |   |   |  |
|  |   |   |  | * Driver   | | * Driver   | | * Driver   | | * Driver   | | * Driver   | | * Driver   |           |   |   |  |
|  |   |   |  | * Monitor  | | * Monitor  | | * Monitor  | | * Monitor  | | * Monitor  | | * Monitor  |           |   |   |  |
|  |   |   |  | * Coverage | | * Coverage | | * Coverage | | * Coverage | | * Coverage | | * Coverage |           |   |   |  |
|  |   |   |  +-----+------+ +-----+------+ +-----+------+ +-----+------+ +-----+------+ +-----+------+           |   |   |  |
|  |   |   +--------|--------------|--------------|--------------|--------------|--------------|------------------+   |   |  |
|  |   +------------|--------------|--------------|--------------|--------------|--------------|----------------------+   |  |
|  +----------------|--------------|--------------|--------------|--------------|--------------|--------------------------+  |
|                   |              |              |              |              |              |                              |
|         virtual   |    virtual   |    virtual   |    virtual   |    virtual   |    virtual   |                              |
|         uart_if   |    gpio_if   |    timer_if  |    spi_if    |    i2c_if    |    pwm_if    |                              |
|  +================v==============v==============v==============v==============v==============v===========================+  |
|  |                                                                                                                       |  |
|  |                                          DESIGN UNDER TEST (DUT): soc_top.sv                                          |  |
|  |                                                                                                                       |  |
|  |  +-------------------+  +-------------------+  +-------------------+  +-------------------+  +---------------------+  |  |
|  |  |  RISC-V VeeR EL2  |  |   Unified SRAM    |  |  Address Decoder  |  | Bare-Metal C Test |  |  6 Memory-Mapped IPs|  |  |
|  |  |  Core (RV32IMC)   |  |      (64 KB)      |  |  Crossbar Fabric  |  | Firmware (ctest)  |  | (UART,GPIO,TMR,etc)|  |  |
|  |  +-------------------+  +-------------------+  +-------------------+  +-------------------+  +---------------------+  |  |
|  |                                                                                                                       |  |
|  +=======================================================================================================================+  |
|                                                                                                                             |
+=============================================================================================================================+
```

---

## 2. VIP Component Breakdown Table

| VIP Name | Interface File | Protocol Handshake / Pins | Driver Functionality | Monitor Functionality | Functional Coverage |
|:---|:---|:---|:---|:---|:---|
| **UART VIP** | `VIPs/uart_vip/uart_if.sv` | `tx`, `rx`, `baud_clk` | Injects serial RX bitstream (Start, 8-bit data, Stop bit) | Samples TX serial line, frames bytes, checks stop/parity | Baud rates, byte values (0x00-0xFF), back-to-back TX |
| **GPIO VIP** | `VIPs/gpio_vip/gpio_if.sv` | `gpio_pins_in[31:0]`, `gpio_pins_out[31:0]`, `gpio_pins_dir[31:0]` | Drives external switch inputs, stimulus triggers | Monitors pin level changes, verifies direction masks | Bit toggling, multi-pin concurrent transitions |
| **Timer VIP**| `VIPs/timer_vip/timer_if.sv`| `timer_irq`, `timer_ext_clk` | Injects external clock pulses and gate triggers | Measures period between compare matches | Timeout intervals, reload modes, prescaler values |
| **SPI VIP**  | `VIPs/spi_vip/spi_if.sv`   | `sclk`, `mosi`, `miso`, `cs_n[3:0]` | Acts as external Flash Memory slave responding to read commands | Logs MOSI telemetry writes, captures address/data packets | CPOL/CPHA modes, burst transfer lengths |
| **I2C VIP**  | `VIPs/i2c_vip/i2c_if.sv`   | `scl`, `sda` (Open-drain) | Emulates I2C temperature/humidity sensor responding with ACK | Decodes START, 7-bit Address, R/W bit, ACK, data bytes | ACK/NACK responses, address matching, clock stretching |
| **PWM VIP**  | `VIPs/pwm_vip/pwm_if.sv`   | `pwm_out[3:0]` | Passive monitor | Measures period high/low pulse widths, computes duty cycle % | 0% to 100% duty cycle bins, period variations |

---

## 3. Verification Closure Flow
1. **Compilation & Elaboration:** All 6 VIP packages (`*_pkg.sv`) are compiled into the `uvm_pkg` library.
2. **Virtual Interface Registration:** `tb_top.sv` binds each physical VIP interface to `soc_top` signals and registers them with `uvm_config_db`.
3. **Execution Phase:** `soc_test` starts parallel sequences across all VIPs while the RISC-V core executes the compiled C test firmware (`ctest.hex`).
4. **Automated Checking:** Monitors publish transactions to analysis FIFOs in `soc_scoreboard`, which flags any mismatch with zero tolerance (`UVM_ERROR` = 0).
