# ==============================================================================
# Master Filelist for UVM Verification IPs Compilation (all_drv_run.f)
# Project: RTL-Based Environmental Monitoring and Data-Logging SoC
# Candidate: Namratha Kavididevi (Roll No: 1602-23-735-157)
# ==============================================================================

+incdir+./uart_vip
+incdir+./gpio_vip
+incdir+./timer_vip
+incdir+./spi_vip
+incdir+./i2c_vip
+incdir+./pwm_vip

# VIP Interface Files
./uart_vip/uart_if.sv
./gpio_vip/gpio_if.sv
./timer_vip/timer_if.sv
./spi_vip/spi_if.sv
./i2c_vip/i2c_if.sv
./pwm_vip/pwm_if.sv

# VIP Package Definitions
./uart_vip/uart_pkg.sv
./gpio_vip/gpio_pkg.sv
./timer_vip/timer_pkg.sv
./spi_vip/spi_pkg.sv
./i2c_vip/i2c_pkg.sv
./pwm_vip/pwm_pkg.sv
