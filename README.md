# RTL-Based Environmental Monitoring and Data-Logging SoC
## Integrated with RISC-V VeeR EL2 Core & AXI4-Lite Peripherals

This repository contains the complete synthesizable RTL, self-checking testbenches, and 2-column signal list CSV files for the **RTL-Based Environmental Monitoring and Data-Logging System-on-Chip (SoC)**, integrated with the Western Digital / CHIPS Alliance **RISC-V VeeR EL2 Core Complex (RV32IMC)** over an **AXI4-Lite crossbar fabric**.

---

## 1. Directory Structure

The project incorporates the cloned Chips Alliance **Cores-VeeR-EL2** repository inside the `rtl/` folder (`rtl/veer_el2` / `rtl/Cores-VeeR-EL2`) and integrates its overall core wrapper (`el2_veer_wrapper.sv` / `veer_wrapper.sv`).

Each IP block contains synthesizable SystemVerilog RTL (`<ip>.sv`), comprehensive testbenches (`tb_<ip>.sv`), and signal lists in strict 2-column CSV format (`<ip>_signals.csv` with header `signal_name,direction`).

```text
F:\honours course based project\
├── rtl\                            # Complete RTL Design & Subsystems
│   ├── Cores-VeeR-EL2\             # Cloned Chips Alliance RISC-V VeeR EL2 Repository
│   │   ├── design\                 # Core RTL (el2_veer_wrapper.sv, el2_veer.sv, etc.)
│   │   ├── configs\                # VeeR Configuration generator & scripts
│   │   └── snapshots\default\      # Core parameter headers (el2_param.vh, common_defines.vh)
│   ├── veer_el2\                   # Alias / Junction to Cores-VeeR-EL2
│   ├── gpio\                       # 8-bit GPIO Controller
│   ├── i2c\                        # I2C Master Controller (Sensor Interface)
│   ├── interconnect\               # 1-to-7 AXI4-Lite Crossbar + DECERR & Bridges
│   ├── memory\                     # Unified 64 KB SRAM
│   ├── pwm\                        # PWM Generator (Buzzer/Alert Actuator)
│   ├── spi\                        # SPI Master Controller (Flash Memory Logging)
│   ├── timer\                      # System Interval Timer & Prescaler
│   ├── uart\                       # UART Transceiver (Telemetry Streaming)
│   ├── soc_top.sv                  # Full SoC Top-Level Module
│   └── veer_wrapper.sv             # VeeR EL2 Core Overall Wrapper
├── gpio\                           # IP Block Directory (RTL, TB, CSV)
├── i2c\                            # IP Block Directory (RTL, TB, CSV)
├── interconnect\                   # IP Block Directory (RTL, TB, CSV)
├── memory\                         # IP Block Directory (RTL, TB, CSV)
├── pwm\                            # IP Block Directory (RTL, TB, CSV)
├── spi\                            # IP Block Directory (RTL, TB, CSV)
├── timer\                          # IP Block Directory (RTL, TB, CSV)
├── uart\                           # IP Block Directory (RTL, TB, CSV)
├── soc_top.sv                      # Full SoC Top-Level Module
├── top_level_tb.sv                 # Full SoC Top-Level Testbench
├── veer_wrapper.sv                 # RISC-V VeeR EL2 Core Wrapper
└── README.md                       # Project Documentation
```

---

## 2. AXI4-Lite Memory Map & Register Offsets

| Slave | Peripheral IP | Base Address | Offset Range | Access | Description |
|:---:|:---:|:---:|:---:|:---:|---|
| **S00** | **Unified Memory** | `0x0000_0000` | `0x0000 - 0xFFFF` | R/W | 64 KB SRAM storing instructions and data |
| **S01** | **UART** | `0x4000_0000` | `0x00 - 0x14` | Mixed | Serial telemetry & status logging |
| | `DATA` | | `0x00` | R/W | Transmit & receive data byte |
| | `STATUS` | | `0x04` | R/O | TX/RX status (TX_EMPTY, RX_VALID, OVRN) |
| | `CONTROL` | | `0x08` | R/W | TX/RX enable and loopback mode |
| | `BAUD_DIV` | | `0x0C` | R/W | Baud-rate divisor (f_clk / baud) |
| | `IRQ_ENABLE` | | `0x10` | R/W | Interrupt enable mask |
| | `IRQ_STATUS` | | `0x14` | R/W1C | Interrupt status flags |
| **S02** | **GPIO** | `0x4000_2000` | `0x00 - 0x18` | Mixed | Status LEDs, pushbuttons & alert lines |
| | `GPIO_INPUT` | | `0x00` | R/O | Synchronized input pin states |
| | `GPIO_OUTPUT` | | `0x04` | R/W | Direct output pin drive |
| | `GPIO_DIRECTION` | | `0x08` | R/W | Direction register (1=out, 0=in) |
| | `GPIO_SET` | | `0x0C` | W/O | Atomic bit set (OR) |
| | `GPIO_CLEAR` | | `0x10` | W/O | Atomic bit clear (AND ~val) |
| | `GPIO_IRQ_ENABLE` | | `0x14` | R/W | Per-bit edge interrupt enable |
| | `GPIO_IRQ_STATUS` | | `0x18` | R/W1C | Edge detection status flags |
| **S03** | **Timer** | `0x4000_4000` | `0x00 - 0x14` | Mixed | Sampling tick & interval timer |
| | `TIMER_CONTROL` | | `0x00` | R/W | Enable, Auto-Reload, Count direction |
| | `TIMER_COUNTER` | | `0x04` | R/W | Current counter value |
| | `TIMER_COMPARE` | | `0x08` | R/W | Timeout comparison threshold |
| | `TIMER_PRESCALER` | | `0x0C` | R/W | Input clock divider |
| | `TIMER_STATUS` | | `0x10` | R/W1C | TICK interval elapsed flag |
| | `TIMER_IRQ_ENABLE` | | `0x14` | R/W | Timer interrupt enable |
| **S04** | **SPI** | `0x4000_6000` | `0x00 - 0x1C` | Mixed | SPI Flash burst logger |
| | `SPI_CONTROL` | | `0x00` | R/W | Enable, CPOL, CPHA, Master mode |
| | `SPI_STATUS` | | `0x04` | R/O | Busy, TX ready, RX valid flags |
| | `SPI_TX_DATA` | | `0x08` | W/O | Transmit data (triggers transfer) |
| | `SPI_RX_DATA` | | `0x0C` | R/O | Received data byte |
| | `SPI_CLK_DIV` | | `0x10` | R/W | SPI SCLK clock divider |
| | `SPI_CS` | | `0x14` | R/W | Chip Select control (`spi_cs_n`) |
| | `SPI_IRQ_ENABLE` | | `0x18` | R/W | Transfer complete interrupt enable |
| | `SPI_IRQ_STATUS` | | `0x1C` | R/W1C | Transfer complete interrupt status |
| **S05** | **I2C** | `0x4000_8000` | `0x00 - 0x1C` | Mixed | Digital sensor bus master |
| | `I2C_CONTROL` | | `0x00` | R/W | Enable, Master mode |
| | `I2C_STATUS` | | `0x04` | R/O | Busy, ACK/NACK, transfer done |
| | `I2C_DATA` | | `0x08` | R/W | Transmit / Receive data byte |
| | `I2C_ADDRESS` | | `0x0C` | R/W | 7-bit sensor slave address + R/W |
| | `I2C_CLK_DIV` | | `0x10` | R/W | SCL clock prescaler |
| | `I2C_COMMAND` | | `0x14` | W/O | START, STOP, Write, Read command |
| | `I2C_IRQ_ENABLE` | | `0x18` | R/W | Done & NACK interrupt enable |
| | `I2C_IRQ_STATUS` | | `0x1C` | R/W1C | Done & NACK status flags |
| **S06** | **PWM** | `0x4000_A000` | `0x00 - 0x14` | Mixed | Threshold buzzer & alert driver |
| | `PWM_CONTROL` | | `0x00` | R/W | Output enable & polarity |
| | `PWM_PERIOD` | | `0x04` | R/W | Total period in clock cycles |
| | `PWM_DUTY` | | `0x08` | R/W | Duty cycle threshold |
| | `PWM_COUNTER` | | `0x0C` | R/O | Current counter value |
| | `PWM_STATUS` | | `0x10` | R/O | Running & Cycle Complete status |
| | `PWM_IRQ_ENABLE` | | `0x14` | R/W | Cycle complete interrupt enable |
| **-** | **DECERR Unit** | *Unmapped* | - | R/W | Returns `2'b11` to prevent CPU hang (e.g. `0x4000_C000+`) |

---

## 3. RISC-V VeeR EL2 PIC Interrupt Mapping

The VeeR EL2 core provides level-sensitive external interrupt lines (`extintsrc_req`). Each peripheral drives an active-high interrupt output routed directly to the PIC:

| Interrupt Signal | PIC Vector | Source Peripheral | Description |
|---|:---:|---|---|
| `uart_irq` | `extintsrc_req[0]` | `uart` | TX Empty / RX Valid Interrupt |
| `irq_timer` | `extintsrc_req[1]` | `timer` | Periodic Sampling Interval Elapsed |
| `irq_gpio` | `extintsrc_req[2]` | `gpio` | User Button Press / Edge Event |
| `irq_i2c` | `extintsrc_req[3]` | `i2c` | Sensor Transaction Complete / NACK |
| `irq_spi` | `extintsrc_req[4]` | `spi` | Flash Burst Write Complete |
| `irq_pwm` | `extintsrc_req[5]` | `pwm` | PWM Period Wrap / Alert Cycle Done |

---

## 4. Verification Workflow

1. **Top-Level Testbench**:
   - Run `top_level_tb.sv` with `soc_top.sv`.
   - Exercises the complete closed-loop sensor-to-actuator pipeline (SENSE $\rightarrow$ PROCESS $\rightarrow$ ACTUATE $\rightarrow$ DISPLAY $\rightarrow$ LOG).
2. **Individual IP Testbenches**:
   - Each IP directory contains `tb_<ip>.sv` for isolated block-level verification with 100% test pass rates.
