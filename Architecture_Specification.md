# Architecture Specification: RTL-Based Environmental Monitoring and Data-Logging SoC

**Student Name:** Namratha Kavididevi  
**Roll Number:** 1602-23-735-157  
**Department:** Electronics and Communication Engineering  
**Institution:** Vasavi College of Engineering (Autonomous), Hyderabad  
**Academic Year:** 2026-2027  
**Document Revision:** 1.0  

---

## 1. System Overview
The RTL-Based Environmental Monitoring and Data-Logging System-on-Chip (SoC) is a high-reliability, 32-bit embedded system designed for autonomous environmental telemetry acquisition, real-time threshold monitoring, non-volatile data logging, and alarm triggering. The architecture is centered around the Western Digital / CHIPS Alliance RISC-V VeeR EL2 core (RV32IMC), integrated with unified on-chip SRAM and six memory-mapped peripheral controllers through an address-decoding bus interconnect.

---

## 2. Top-Level SoC Block Diagram

```
+===================================================================================================+
|                                    ENVIRONMENT MONITORING SoC TOP                                 |
|                                                                                                   |
|  +---------------------------------------------------------------------------------------------+  |
|  |                              RISC-V VeeR EL2 PROCESSOR CORE                                 |  |
|  |  * RV32IMC 4-Stage In-Order Scalar Pipeline                                                 |  |
|  |  * IFU (Instruction Fetch Unit) & LSU (Load/Store Unit) Master Ports                        |  |
|  |  * Programmable Interrupt Controller (PIC) - 8 Global IRQ Lines                            |  |
|  +-------------------------------------+-------------------------------------------------------+  |
|                                        | System Bus (AHB-Lite / Internal Decoded Bus)             |
|  +-------------------------------------v-------------------------------------------------------+  |
|  |                             ADDRESS DECODER & CROSSBAR INTERCONNECT                         |  |
|  |  * Base Address Routing: SRAM (0x0000_0000) | Peripherals (0x4000_0000 - 0x4000_BFFF)       |  |
|  |  * Arbitration & Multiplexing for rdata, ready, and error responses                         |  |
|  +--+-------------+-------------+-------------+-------------+-------------+-------------+------+  |
|     | S0          | S1          | S2          | S3          | S4          | S5          | S6      |
|  +--v--------+ +--v--------+ +--v--------+ +--v--------+ +--v--------+ +--v--------+ +--v------+  |
|  | Unified   | | UART      | | GPIO      | | Interval  | | SPI Master| | I2C Master| | PWM     |  |
|  | SRAM      | | Controller| | Controller| | Timer     | | Flash Log | | Sensor IF | | Alarm   |  |
|  | (64 KB)   | | 115200 8N1| | 32-bit    | | 32-bit    | | Master    | | Master    | | Generat.|  |
|  | 0x00000000| | 0x40000000| | 0x40002000| | 0x40004000| | 0x40006000| | 0x40008000| |0x4000A000|  |
|  +-----------+ +----+------+ +----+------+ +----+------+ +----+------+ +----+------+ +----+----+  |
|                     |             |             |             |             |           |         |
|                     |             |             |             |             |           |         |
+=====================|=============|=============|=============|=============|===========|=========+
                      |             |             |             |             |           |
                   uart_tx/rx     gpio_io     timer_irq     spi_clk/mosi/  i2c_scl/sda   pwm_out
                   (Telemetry)   (LEDs/Btns)   (SysTick)    miso/cs (Flash)(Sensor Bus) (Buzzer/LED)
```

---

## 3. Memory Map & Address Allocation

The 32-bit address space is allocated into contiguous, non-overlapping windows with dedicated peripheral decoding:

| Slave ID | Base Address | End Address | Size | Subsystem / IP Description | Access Privilege |
|:---:|:---:|:---:|:---:|:---|:---:|
| **S0** | `0x0000_0000` | `0x0000_FFFF` | 64 KB | **Unified SRAM** (Instruction & Data Memory) | R / W / X |
| **S1** | `0x4000_0000` | `0x4000_1FFF` | 8 KB | **UART Controller** (Live Telemetry & Debug Console) | R / W |
| **S2** | `0x4000_2000` | `0x4000_3FFF` | 8 KB | **GPIO Controller** (32-bit User I/O, Threshold Alert Pins) | R / W |
| **S3** | `0x4000_4000` | `0x4000_5FFF` | 8 KB | **Interval Timer** (Periodic Sampling & SysTick) | R / W |
| **S4** | `0x4000_6000` | `0x4000_7FFF` | 8 KB | **SPI Master** (Flash Memory Telemetry Data Logging) | R / W |
| **S5** | `0x4000_8000` | `0x4000_9FFF` | 8 KB | **I2C Master** (Environmental Sensor Interface) | R / W |
| **S6** | `0x4000_A000` | `0x4000_BFFF` | 8 KB | **PWM Generator** (Duty-Cycle Alarm Tone / LED Brightness) | R / W |
| **--** | `0x4000_C000` | `0xFFFF_FFFF` | -- | **Reserved / DECERR** (Unmapped Address Space) | Fault / DECERR |

---

## 4. Subsystem & Peripheral Register Specifications

### 4.1 UART IP (`0x4000_0000`)
* **`0x4000_0000` (DATA, R/W, 32-bit):** [7:0] Transmit / Receive data byte. Writing initiates serial transmission; reading dequeues received byte from RX buffer.
* **`0x4000_0004` (STATUS, R/O, 32-bit):** Bit [0] TX FIFO Empty, Bit [1] TX Busy, Bit [2] RX FIFO Valid, Bit [3] Frame Error.
* **`0x4000_0008` (CONTROL, R/W, 32-bit):** Bit [0] TX Enable, Bit [1] RX Enable, Bit [2] Parity Enable, Bit [3] Stop Bits (0=1, 1=2).
* **`0x4000_000C` (BAUD_DIV, R/W, 32-bit):** Baud rate divisor value ($Divisor = \frac{f_{clk}}{16 \times Baud}$).
* **`0x4000_0010` (IRQ_ENABLE, R/W, 32-bit):** Bit [0] TX Done IRQ Enable, Bit [1] RX Data Ready IRQ Enable.
* **`0x4000_0014` (IRQ_STATUS, R/W1C, 32-bit):** Bit [0] TX Done Flag, Bit [1] RX Ready Flag.

### 4.2 GPIO IP (`0x4000_2000`)
* **`0x4000_2000` (GPIO_INPUT, R/O, 32-bit):** Current physical sampled state of external GPIO pins.
* **`0x4000_2004` (GPIO_OUTPUT, R/W, 32-bit):** Output register driving configured output pins.
* **`0x4000_2008` (GPIO_DIRECTION, R/W, 32-bit):** Pin direction mask (0 = Input, 1 = Output).
* **`0x4000_200C` (GPIO_SET, W/O, 32-bit):** Atomic bit-set register (writing '1' sets corresponding output bit).
* **`0x4000_2010` (GPIO_CLEAR, W/O, 32-bit):** Atomic bit-clear register (writing '1' clears corresponding output bit).
* **`0x4000_2014` (GPIO_IRQ_ENABLE, R/W, 32-bit):** Per-pin interrupt enable mask.
* **`0x4000_2018` (GPIO_IRQ_STATUS, R/W1C, 32-bit):** Per-pin interrupt pending flag.

### 4.3 Timer IP (`0x4000_4000`)
* **`0x4000_4000` (TIMER_CONTROL, R/W, 32-bit):** Bit [0] Timer Enable, Bit [1] Auto-reload Mode, Bit [2] Prescaler Enable.
* **`0x4000_4004` (TIMER_COUNTER, R/W, 32-bit):** Live 32-bit incrementing tick counter value.
* **`0x4000_4008` (TIMER_COMPARE, R/W, 32-bit):** Compare match target value triggering interrupt.
* **`0x4000_400C` (TIMER_PRESCALER, R/W, 32-bit):** Clock division prescaler factor ($f_{timer} = \frac{f_{clk}}{Prescaler + 1}$).
* **`0x4000_4010` (TIMER_STATUS, R/W1C, 32-bit):** Bit [0] Compare Match Occurred Flag.
* **`0x4000_4014` (TIMER_IRQ_ENABLE, R/W, 32-bit):** Bit [0] Compare Match Interrupt Enable.

### 4.4 SPI Master IP (`0x4000_6000`)
* **`0x4000_6000` (SPI_CONTROL, R/W, 32-bit):** Bit [0] SPI Enable, Bit [1] CPOL, Bit [2] CPHA, Bit [3] Manual/Auto CS.
* **`0x4000_6004` (SPI_STATUS, R/O, 32-bit):** Bit [0] SPI Busy, Bit [1] TX FIFO Empty, Bit [2] RX FIFO Not Empty.
* **`0x4000_6008` (SPI_TX_DATA, W/O, 32-bit):** Transmit FIFO data register (8/16/32-bit burst).
* **`0x4000_600C` (SPI_RX_DATA, R/O, 32-bit):** Receive FIFO data register.
* **`0x4000_6010` (SPI_CLK_DIV, R/W, 32-bit):** SCLK clock prescaler divisor.
* **`0x4000_6014` (SPI_CS, R/W, 32-bit):** Active-low chip-select line assertion register.
* **`0x4000_6018` (SPI_IRQ_ENABLE, R/W, 32-bit):** Transfer complete interrupt enable.
* **`0x4000_601C` (SPI_IRQ_STATUS, R/W1C, 32-bit):** Transfer complete interrupt flag.

### 4.5 I2C Master IP (`0x4000_8000`)
* **`0x4000_8000` (I2C_CONTROL, R/W, 32-bit):** Bit [0] I2C Core Enable, Bit [1] 7-bit/10-bit mode, Bit [2] ACK Generation.
* **`0x4000_8004` (I2C_STATUS, R/O, 32-bit):** Bit [0] Busy, Bit [1] RX ACK/NACK received, Bit [2] Bus error/Lost arbitration.
* **`0x4000_8008` (I2C_DATA, R/W, 32-bit):** Byte transmit buffer / received data register.
* **`0x4000_800C` (I2C_ADDRESS, R/W, 32-bit):** Target slave device address (7-bit address + R/W bit).
* **`0x4000_8010` (I2C_CLK_DIV, R/W, 32-bit):** SCL clock divider setting standard (100 kHz) or fast (400 kHz) mode.
* **`0x4000_8014` (I2C_COMMAND, W/O, 32-bit):** Bit [0] Generate START, Bit [1] Generate STOP, Bit [2] Read Byte, Bit [3] Write Byte.
* **`0x4000_8018` (I2C_IRQ_ENABLE, R/W, 32-bit):** Byte transfer finished / STOP detected interrupt enable.
* **`0x4000_801C` (I2C_IRQ_STATUS, R/W1C, 32-bit):** Byte transfer complete flag.

### 4.6 PWM Generator IP (`0x4000_A000`)
* **`0x4000_A000` (PWM_CONTROL, R/W, 32-bit):** Bit [0] PWM Channel Enable, Bit [1] Invert Polarity, Bit [2] Continuous/One-shot.
* **`0x4000_A004` (PWM_PERIOD, R/W, 32-bit):** Total cycle period count value ($T = Period \times T_{clk}$).
* **`0x4000_A008` (PWM_DUTY, R/W, 32-bit):** High-level pulse duration count ($Duty = \frac{PWM\_DUTY}{PWM\_PERIOD}$).
* **`0x4000_A00C` (PWM_COUNTER, R/O, 32-bit):** Instantaneous counter value.
* **`0x4000_A010` (PWM_STATUS, R/O, 32-bit):** PWM active running state flag.
* **`0x4000_A014` (PWM_IRQ_ENABLE, R/W, 32-bit):** Period overflow / reload interrupt enable.

---

## 5. Core Interrupt Routing (PIC)

The SoC routes peripheral interrupts to the VeeR EL2 Programmable Interrupt Controller (PIC):
* **IRQ 1:** UART Interrupt (TX buffer empty / RX data available)
* **IRQ 2:** GPIO External Interrupt (Emergency stop / User button event)
* **IRQ 3:** Interval Timer Interrupt (Sensor sampling trigger)
* **IRQ 4:** SPI Master Interrupt (Flash write completion)
* **IRQ 5:** I2C Master Interrupt (Sensor data byte ready)
* **IRQ 6:** PWM Generator Interrupt (Audio tone cycle reload)

---

## 6. Primary Chip External Pinout

| Signal Name | Direction | Width | Pin Function & Domain |
|:---|:---:|:---:|:---|
| `clk` | Input | 1 | Master 50 MHz SoC System Clock |
| `rst_n` | Input | 1 | Asynchronous Active-Low Master Reset |
| `uart_rx` | Input | 1 | UART Serial Data In |
| `uart_tx` | Output | 1 | UART Serial Data Out |
| `gpio_pins_in` | Input | 32 | GPIO Input Data Lines |
| `gpio_pins_out` | Output | 32 | GPIO Output Drive Lines |
| `gpio_pins_dir` | Output | 32 | GPIO Output Enable / Direction Lines |
| `i2c_scl_o`, `i2c_scl_t` | Inout / Tri | 1 | I2C Open-Drain Serial Clock Line |
| `i2c_sda_o`, `i2c_sda_t` | Inout / Tri | 1 | I2C Open-Drain Serial Data Line |
| `spi_sclk` | Output | 1 | SPI Master Serial Clock |
| `spi_mosi` | Output | 1 | SPI Master Output Slave Input |
| `spi_miso` | Input | 1 | SPI Master Input Slave Output |
| `spi_cs_n` | Output | 4 | SPI Chip Select lines (Flash memory select) |
| `pwm_out` | Output | 4 | PWM High-Drive Alarm Audio/LED Outputs |
