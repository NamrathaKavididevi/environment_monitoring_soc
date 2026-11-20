# An RTL-Based Environmental Monitoring and Data-Logging System-on-Chip (SoC)

**Student Name:** Namratha Kavididevi  
**Roll Number:** 1602-23-735-157  
**Department:** Electronics and Communication Engineering  
**Institution:** Vasavi College of Engineering (Autonomous), Hyderabad  
**Academic Year:** 2026-2027  
**Repository:** [https://github.com/NamrathaKavididevi/environment_monitoring_soc.git](https://github.com/NamrathaKavididevi/environment_monitoring_soc.git)  

---

## 1. Problem Statement
Embedded environmental monitoring systems — temperature and humidity logging, industrial process sensing, and low-power IoT edge nodes — require a processing core that can continuously sample sensor data, evaluate it against safety or quality thresholds in real time, and preserve a durable record of readings for later retrieval, all without the cost and power overhead of a general-purpose microcontroller. Most academic RISC-V SoC projects that touch sensing or logging stop at reading a single peripheral in isolation, without tying acquisition, non-volatile storage, and alerting together into one coherent, always-running system, which is precisely the gap between a classroom peripheral demo and a design that resembles a real embedded product.

This project addresses that gap by designing a System-on-Chip, built around a provided RISC-V RTL processor core (Western Digital / CHIPS Alliance VeeR EL2), that periodically samples an environmental sensor over I2C, evaluates each reading against a configurable threshold, logs every timestamped sample to external SPI flash for persistent storage, and drives a PWM-based visual/audible alert the moment a threshold is crossed — while continuously reporting live status over UART. The objective is to demonstrate, through RTL design and simulation-based verification, that a small set of tightly-coupled memory-mapped IP blocks — sensor acquisition, non-volatile logging, and threshold-driven alerting — can deliver a complete acquire-log-alert pipeline suitable for constrained edge and industrial monitoring use cases.

---

## 2. Proposed SoC Architecture
The SoC is organized around the provided RISC-V processor core as the central control unit, connected via a shared memory-mapped bus interconnect to instruction memory, data memory, and a set of peripheral IP blocks. The processor's role is limited to configuration, sequencing, and decision-making; continuous protocol-level data movement is handled by dedicated peripheral hardware, off the processor's critical path. The system follows this data-flow pipeline:

* **Acquisition** — A sensor source (a behavioral I2C sensor model in simulation) is sampled at an interval set by the Timer; on each Timer interrupt, the processor triggers the I2C Controller to read a fresh temperature/humidity value into data memory.
* **Evaluation** — The processor compares the newly acquired sample against a configurable threshold register; the comparison result determines whether the current sample is logged as normal or as an alert condition.
* **Logging** — Every sample, tagged with a timestamp derived from the Timer, is written through the SPI Controller to an external flash memory model, building a persistent, retrievable history of readings independent of the volatile data memory.
* **Alerting** — When a sample crosses the threshold, the processor drives the PWM Generator to activate a buzzer/LED alert at a configurable duty cycle, and sets the GPIO alert output; both remain active until the condition clears or is acknowledged.
* **Control and Reporting** — The processor reads GPIO for user commands (manual sample trigger, alert acknowledge/reset) and reports every sample, log event, and alert transition as a status line over the mandatory UART peripheral.

This architecture keeps the RISC-V core focused on configuration and decision logic — it triggers each peripheral transaction and evaluates results, but the protocol-level timing of I2C, SPI, and PWM is generated entirely in dedicated hardware, mirroring how real embedded sensor-and-logging peripherals are decoupled from their host CPU. The complete memory map, bus protocol details, and per-block register interfaces are specified in the accompanying Architecture Document.

---

## 3. Selected IPs

### Mandatory (Required by the SoC Architecture):
1. **RISC-V Processor Core (VeeR EL2)** — RV32IMC 4-stage in-order scalar core, central control and sequencing unit.
2. **Instruction Memory and Data Memory (Unified SRAM)** — 64 KB single-cycle SRAM for program storage and sample/log staging buffers.
3. **Bus Interconnect** — Address-decoding memory-mapped crossbar connecting core master ports to all slave peripherals.
4. **UART Controller** — Serial transmission of live status, telemetry sample, and alert data.
5. **Timer IP** — Configurable prescaled interval timer providing periodic sensor sampling interrupts and timestamps.
6. **GPIO Controller** — 32-bit bidirectional general-purpose I/O capturing user controls (manual trigger, alert reset) and driving status LEDs.

### Additional IPs:
7. **I2C Master Controller** — Memory-mapped master controller implementing START/STOP conditions, 7-bit slave addressing, clock stretching, and byte-level read/write with ACK/NACK handling to sample environmental sensors.
8. **SPI Master Controller** — High-speed serial peripheral interface (SCLK generator, MOSI/MISO shift registers, configurable chip-select) writing timestamped telemetry logs to external flash memory.
9. **PWM Generator** — Configurable period and duty-cycle pulse generator driving visual/audible alarms upon sensor threshold breach.

---

## 4. Verification Methodology
1. **IP-Level Verification:** Basic testbench verification for each individual IP block (I2C, UART, SPI, GPIO, Timer, PWM) verifying protocol compliance and signal handshakes.
2. **SoC Integration Verification:** Full SoC RTL simulation executing compiled bare-metal RISC-V C firmware testing end-to-end acquire-log-alert flows.
3. **UVM VIP Development:** Complete Universal Verification Methodology (UVM) Verification IP (VIP) generation for each external interface, with automated sequence generation, coverage, and scoreboarding.
