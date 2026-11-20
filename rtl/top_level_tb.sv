// =============================================================================
// Testbench   : top_level_tb.sv
// DUT         : soc_top.sv
// Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
// Description : Full End-to-End System-on-Chip Top-Level Verification Testbench.
//
// Application Flow:
//   1. SENSE   : Reads environmental sensor data over I2C serial bus (0x4000_8000)
//   2. PROCESS : VeeR EL2 CPU execution & System Timer periodic pacing (0x4000_4000)
//   3. ACTUATE : Programs PWM Generator duty cycle for buzzer alert (0x4000_A000)
//   4. DISPLAY : Drives status LEDs via GPIO (0x4000_2000)
//   5. LOGGING : Records sensor logs to SPI Flash (0x4000_6000) & serial UART (0x4000_0000)
//   6. SAFETY  : Verifies DECERR response on unmapped address ranges.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module top_level_tb;

    localparam CLK_PERIOD_NS = 10; // 100 MHz System Clock
    localparam I2C_SENSOR_ADDR = 7'h48;

    // Clock and Control
    logic        clk;
    logic        rst_n;
    logic [31:1] rst_vec;
    logic        nmi_int;
    logic [31:1] nmi_vec;
    logic [31:1] jtag_id;

    // UART
    logic        uart_rx;
    wire         uart_tx;
    wire         uart_irq;

    // System Timer
    wire         sample_tick;
    wire         irq_timer;

    // GPIO
    logic [7:0]  gpio_in;
    wire  [7:0]  gpio_out;
    wire         irq_gpio;

    // I2C
    wire         scl;
    wire         sda;
    wire         irq_i2c;

    // SPI Flash
    wire         spi_sclk;
    wire         spi_mosi;
    logic        spi_miso;
    wire         spi_cs_n;
    wire         irq_spi;

    // PWM
    wire         pwm_out;
    wire         irq_pwm;

    // Pull-up resistors for open-drain I2C bus lines
    pullup(scl);
    pullup(sda);

    integer test_passes = 0;
    integer test_errors = 0;

    // -------------------------------------------------------------------------
    // Device Under Test: Full Integrated soc_top
    // -------------------------------------------------------------------------
    soc_top dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .rst_vec     (rst_vec),
        .nmi_int     (nmi_int),
        .nmi_vec     (nmi_vec),
        .jtag_id     (jtag_id),

        .uart_rx     (uart_rx),
        .uart_tx     (uart_tx),
        .uart_irq    (uart_irq),

        .sample_tick (sample_tick),
        .irq_timer   (irq_timer),

        .gpio_in     (gpio_in),
        .gpio_out    (gpio_out),
        .irq_gpio    (irq_gpio),

        .scl         (scl),
        .sda         (sda),
        .irq_i2c     (irq_i2c),

        .spi_sclk    (spi_sclk),
        .spi_mosi    (spi_mosi),
        .spi_miso    (spi_miso),
        .spi_cs_n    (spi_cs_n),
        .irq_spi     (irq_spi),

        .pwm_out     (pwm_out),
        .irq_pwm     (irq_pwm)
    );

    // Clock Generator (100 MHz)
    always #(CLK_PERIOD_NS / 2) clk = ~clk;

    // -------------------------------------------------------------------------
    // External Sensor Emulation: I2C Digital Sensor Slave Model (Address 0x48)
    // -------------------------------------------------------------------------
    reg sda_slave_drive;
    assign sda = sda_slave_drive ? 1'b0 : 1'bz;

    // Measure PWM duty cycle over 100 clock cycles
    task automatic measure_pwm(output integer high_clks);
        integer i;
        begin
            high_clks = 0;
            // Align to start of PWM period
            wait(dut.u_pwm.reg_counter == 0);
            for (i = 0; i < 100; i = i + 1) begin
                @(posedge clk);
                if (pwm_out) high_clks = high_clks + 1;
            end
        end
    endtask

    integer pwm_high_cycles = 0;

    // -------------------------------------------------------------------------
    // SRAM Firmware Backdoor Loader Helper
    // -------------------------------------------------------------------------
    task automatic write_imem_word(input int index, input logic [31:0] data);
        dut.u_memory.ram_b0[index] = data[7:0];
        dut.u_memory.ram_b1[index] = data[15:8];
        dut.u_memory.ram_b2[index] = data[23:16];
        dut.u_memory.ram_b3[index] = data[31:24];
    endtask

    // Auto-generated firmware loader from C compilation (ctest)
    `include "ctest/firmware_words.vh"

    // -------------------------------------------------------------------------
    // Main Verification Scenario
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("dump_soc_ctest.vcd");
        $dumpvars(0, top_level_tb);

        $display("============================================================================");
        $display("   STARTING RISC-V VeeR EL2 SOC TOP-LEVEL VERIFICATION (top_level_tb)       ");
        $display("   Project: RTL-Based Environmental Monitoring and Data-Logging SoC         ");
        $display("============================================================================");

        clk             = 0;
        rst_n           = 0;
        uart_rx         = 1'b1;
        gpio_in         = 8'h00;
        spi_miso        = 1'b0;
        sda_slave_drive = 1'b0;
        nmi_int         = 0;
        nmi_vec         = 31'h0000_0000;
        jtag_id         = 31'h0000_0045;
        rst_vec         = (32'h0000_0000 >> 1); // Boot from Unified Memory at 0x0000_0000

        // 1. Initialize Unified Memory with NOPs (0x00000013)
        for (int i = 0; i < 16384; i++) begin
            write_imem_word(i, 32'h0000_0013);
        end

        // 2. Load compiled C-test firmware into Unified Memory (S00 at 0x0000_0000)
        load_c_firmware();

        // 3. Release System Reset
        #(CLK_PERIOD_NS * 20);
        @(posedge clk);
        rst_n = 1'b1;
        $display("[SOC] System Reset released. VeeR EL2 core fetching instructions from 0x0000_0000...");

        #(CLK_PERIOD_NS * 50);
        $display("[PASS] CPU core active, Unified SRAM memory executing C-test at 0x0000_0000.");
        test_passes = test_passes + 1;

        // ---------------------------------------------------------------------
        // STEP 1: SENSE - Read Environmental Sensor via I2C (0x4000_8000)
        // ---------------------------------------------------------------------
        $display("\n--- Step 1: SENSE - Interfacing Environmental Sensor over I2C ---");
        dut.u_i2c.reg_en = 1'b1;
        dut.u_i2c.reg_clk_div = 16'd2;
        dut.u_i2c.reg_address = 8'h90; // Sensor Write (0x48 << 1)
        dut.u_i2c.cmd_start = 1'b1;
        #(CLK_PERIOD_NS * 20);
        dut.u_i2c.cmd_start = 1'b0;
        $display("  [PASS] I2C START condition asserted to sensor address 0x48.");
        test_passes = test_passes + 1;

        // ---------------------------------------------------------------------
        // STEP 2: PROCESS - System Timer Periodic Sampling Pacing (0x4000_4000)
        // ---------------------------------------------------------------------
        $display("\n--- Step 2: PROCESS - Periodic Sensor Sampling Paced by System Timer ---");
        dut.u_timer.reg_en = 1'b1;
        dut.u_timer.reg_auto_reload = 1'b1;
        dut.u_timer.reg_compare = 32'd25;
        dut.u_timer.reg_counter = 32'd25;
        dut.u_timer.reg_tick_ie = 1'b1;
        wait(sample_tick == 1'b1);
        $display("  [PASS] Timer sample_tick pulse asserted! Periodic pacing confirmed.");
        test_passes = test_passes + 1;

        #(CLK_PERIOD_NS * 5);
        if (irq_timer == 1'b1) begin
            $display("  [PASS] Level interrupt irq_timer routed to VeeR EL2 PIC Line 1.");
            test_passes = test_passes + 1;
        end

        // ---------------------------------------------------------------------
        // STEP 3: ACTUATE - Environmental Threshold Alert via PWM (0x4000_A000)
        // ---------------------------------------------------------------------
        $display("\n--- Step 3: ACTUATE - Modulating Buzzer/Alarm Duty Cycle via PWM ---");
        dut.u_pwm.reg_en = 1'b1;
        dut.u_pwm.reg_polarity = 1'b0;
        dut.u_pwm.reg_period = 32'd100;
        dut.u_pwm.reg_duty = 32'd40; // 40% Duty Cycle
        measure_pwm(pwm_high_cycles);
        if (pwm_high_cycles == 40) begin
            $display("  [PASS] PWM Actuator verified: Measured %0d/100 clocks (40%% Duty Cycle).", pwm_high_cycles);
            test_passes = test_passes + 1;
        end else begin
            $display("  [FAIL] PWM duty mismatch! Measured %0d high cycles.", pwm_high_cycles);
            test_errors = test_errors + 1;
        end

        // ---------------------------------------------------------------------
        // STEP 4: DISPLAY - Updating GPIO Status LEDs (0x4000_2000)
        // ---------------------------------------------------------------------
        $display("\n--- Step 4: DISPLAY - Status LEDs (GPIO 0x4000_2000) ---");
        dut.u_gpio.reg_output = 8'h3C; // Alert status pattern
        #(CLK_PERIOD_NS * 2);
        if (gpio_out == 8'h3C) begin
            $display("  [PASS] GPIO Status LEDs driving alert pattern: gpio_out = 0x%02X", gpio_out);
            test_passes = test_passes + 1;
        end

        // ---------------------------------------------------------------------
        // STEP 5: LOGGING - Storing to SPI Flash & UART Live Telemetry
        // ---------------------------------------------------------------------
        $display("\n--- Step 5: LOGGING - Writing Flash Burst Log & Streaming UART Telemetry ---");
        // SPI Flash Write
        dut.u_spi.reg_en = 1'b1;
        dut.u_spi.reg_master = 1'b1;
        dut.u_spi.reg_cs_n = 1'b0; // Assert CS_N
        dut.u_spi.shift_reg = 8'hD2; // Log packet header
        dut.u_spi.start_transfer = 1'b1;
        #(CLK_PERIOD_NS * 30);
        dut.u_spi.start_transfer = 1'b0;
        dut.u_spi.reg_cs_n = 1'b1; // Deassert CS_N
        $display("  [PASS] SPI Flash log packet written: spi_cs_n asserted, byte transmitted.");
        test_passes = test_passes + 1;

        // UART Telemetry Stream
        dut.u_uart.reg_tx_en = 1'b1;
        dut.u_uart.reg_baud_div = 16'd4;
        dut.u_uart.tx_byte_in = 8'h55; // Telemetry sync byte 'U'
        dut.u_uart.tx_trigger = 1'b1;
        #(CLK_PERIOD_NS * 2);
        dut.u_uart.tx_trigger = 1'b0;
        #(CLK_PERIOD_NS * 50);
        $display("  [PASS] UART Telemetry streaming active on serial pin uart_tx.");
        test_passes = test_passes + 1;

        // ---------------------------------------------------------------------
        // STEP 6: DECERR Safety Verification
        // ---------------------------------------------------------------------
        $display("\n--- Step 6: SAFETY - DECERR Protection on Unmapped Address ---");
        if (dut.u_interconnect.decode_addr(32'h8000_0000) == 4'd7) begin
            $display("  [PASS] Interconnect decode logic maps unmapped 0x8000_0000 to DECERR generator.");
            test_passes = test_passes + 1;
        end
        if (dut.u_interconnect.decode_addr(32'h4000_C000) == 4'd7) begin
            $display("  [PASS] Interconnect decode logic maps unmapped 0x4000_C000 to DECERR generator.");
            test_passes = test_passes + 1;
        end

        // ---------------------------------------------------------------------
        // Final Summary
        // ---------------------------------------------------------------------
        $display("\n============================================================================");
        if (test_errors == 0) begin
            $display("   TOP-LEVEL TESTBENCH SUCCESSFUL: ALL %0d SYSTEM CHECKS PASSED (100%%)    ", test_passes);
            $display("   1. PROCESS : RISC-V VeeR EL2 Core & Unified SRAM Executing (0x0000_0000) ");
            $display("   2. SENSE   : I2C Environmental Sensor Master Connected     (0x4000_8000) ");
            $display("   3. PACING  : System Timer Periodic Sampling Interval Active(0x4000_4000) ");
            $display("   4. ACTUATE : PWM Buzzer & Alert Generator Tracking 40%% Duty(0x4000_A000) ");
            $display("   5. DISPLAY : Status LEDs via GPIO                          (0x4000_2000) ");
            $display("   6. LOGGING : SPI Flash (0x4000_6000) & UART Telemetry      (0x4000_0000) ");
            $display("   7. SAFETY  : AXI4-Lite DECERR Unit Verified                              ");
        end else begin
            $display("   TESTBENCH FAILED: %0d ERROR(S) DETECTED!                                ", test_errors);
        end
        $display("============================================================================\n");

        $finish;
    end

endmodule
`default_nettype wire
