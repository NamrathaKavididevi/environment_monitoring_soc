# C-Test Firmware & HEX File Documentation

**Project**: RTL-Based Environmental Monitoring and Data-Logging SoC  
**Processor**: RISC-V VeeR EL2 Core (RV32IMC with PIC Interrupts)  
**Memory System**: 64 KB Unified SRAM at `0x0000_0000` (Instructions, Data, Stack)  

---

## 1. Generated HEX & Binary Files

All firmware artifacts are generated and located in both `F:\honours course based project\` and `F:\honours course based project\sw\`:

| File Name | Format | Purpose / Simulator Usage |
|:---|:---|:---|
| **`ctest.hex`** (and `firmware.hex`) | Verilog Byte Memory Hex (`@00000000 ...`) | Standard `$readmemh` byte format (16 bytes per line). Compatible with VCS, Questa, ModelSim, Vivado, and Icarus. |
| **`ctest_words.hex`** | 32-bit Word Hex (1 word per line) | Direct word-indexed memory initialization format for 32-bit wide SRAM arrays. |
| **`firmware_words.vh`** | SystemVerilog Backdoor Loader Task (`load_c_firmware()`) | Backdoor task loaded into `top_level_tb.sv` that populates `ram_b0`..`ram_b3` at simulation start. |
| **`ctest.bin`** | Raw Flat Binary (424 bytes) | Native machine code binary for hardware programmer/JTAG memory download. |
| **`ctest.ihex`** | Intel HEX (`:100000...`) | Industry-standard Intel HEX record format with per-line checksums and EOF record. |

---

## 2. Memory Map & Peripheral Addresses Verified in C-Test

The firmware executes the complete closed-loop sensor-to-actuator and logging pipeline:

```
+-------------------+--------------------+------------------------------------------+
| Subsystem         | Base Address Range | Diagnostic Action Performed in C-Test    |
+-------------------+--------------------+------------------------------------------+
| Unified SRAM      | 0x0000_0000-0xFFFF | Boots from 0x0, executes crt0 & main     |
| UART Telemetry    | 0x4000_0000-0x1FFF | Configures Baud=4, streams sync byte 0x55|
| GPIO Controller   | 0x4000_2000-0x3FFF | Sets DIR=0xFF, drives alert LED pattern  |
| System Timer      | 0x4000_4000-0x5FFF | Prescaler=0, Compare=25, asserts tick    |
| SPI Flash Master  | 0x4000_6000-0x7FFF | Asserts CS_N, writes log byte 0xD2       |
| I2C Sensor Master | 0x4000_8000-0x9FFF | Divisor=2, issues START to Sensor 0x48   |
| PWM Alert Gen     | 0x4000_A000-0xBFFF | Period=100, Duty=40 (40% Buzzer Alert)   |
| DECERR Unit       | 0x4000_C000+       | Bus safety decode error protection       |
+-------------------+--------------------+------------------------------------------+
```

---

## 3. C-Firmware Execution Sequence

1. **Reset & Boot (`crt0.S`)**:
   - `csrci mstatus, 8`: Disables global interrupts during initialization.
   - VeeR EL2 MRAC CSR (`0x7C0`): Configures Region 0 (`0x0000_0000`) as Cacheable/Idempotent (`0x2`) and Region 4 (`0x4000_0000`) as Non-Cacheable Device I/O (`0x6`).
   - Stack Pointer (`sp`): Initialized to `0x0000_FFF0` (Top of 64 KB SRAM).
2. **UART Setup**:
   - Programs `BAUD_DIV = 4` at `0x4000_000C` and `CONTROL = 0x03` (`TX_EN | RX_EN`) at `0x4000_0008`.
3. **GPIO Setup**:
   - Configures direction to output (`0xFF`) at `0x4000_2008` and initializes output to `0x00` at `0x4000_2004`.
4. **Interval Timer Armed**:
   - Sets prescaler to 0 (`0x4000_400C`), compare threshold to 25 (`0x4000_4008`), presets counter to 25 (`0x4000_4004`), and arms timer interrupt (`0x4000_4014`).
5. **PWM Alert Modulated**:
   - Sets period to 100 (`0x4000_A004`), duty threshold to 40 (`0x4000_A008`), and enables generator (`0x4000_A000`).
6. **I2C Sensor Acquisition**:
   - Sets clock divisor to 2 (`0x4000_8010`), target address to `0x90` (`0x48 << 1`, write) at `0x4000_800C`, and issues `START` command (`0x4000_8014`).
7. **SPI Flash Logging**:
   - Asserts `CS_N` low at `0x4000_6014` and writes log packet header `0xD2` to `0x4000_6008`.
8. **GPIO Alert Status**:
   - Drives alert status LED pattern `0x3C` onto `gpio_out[7:0]` at `0x4000_2004`.
9. **UART Telemetry Stream**:
   - Writes telemetry sync byte `0x55` ('U') to `0x4000_0000`, followed by formatted confirmation string.
10. **Halt**:
    - Enters low-power `wfi` idle loop.

---

## 4. How to Run Simulation

In [`top_level_tb.sv`](file:///F:/honours%20course%20based%20project/top_level_tb.sv), the firmware is automatically loaded into Unified Memory via:
```verilog
write_imem_word(i, 32'h0000_0013); // Preload NOPs
load_c_firmware();                  // Backdoor load ctest binary
```
When running simulation, the VeeR EL2 core automatically fetches from `0x0000_0000` and executes all 8 subsystem tests.
