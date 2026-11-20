# =============================================================================
# Makefile for RISC-V VeeR EL2 Bare-Metal C-Firmware
# Project : RTL-Based Environmental Monitoring and Data-Logging SoC
# =============================================================================

CROSS_COMPILE ?= riscv-none-elf-
CC      = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

ARCH_FLAGS = -march=rv32imc -mabi=ilp32
CFLAGS     = $(ARCH_FLAGS) -O2 -g -Wall -nostdlib -ffreestanding -fno-builtin -I.
LDFLAGS    = -T link.ld -nostdlib -Wl,--gc-sections

SRCS = crt0.S main.c uart.c
OBJS = $(SRCS:.c=.o)
OBJS := $(OBJS:.S=.o)

TARGET = ctest

all: $(TARGET).elf $(TARGET).hex $(TARGET).bin $(TARGET).dump firmware_words.vh

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET).elf: $(OBJS) link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O verilog --verilog-data-width=1 $< $@

$(TARGET).dump: $(TARGET).elf
	$(OBJDUMP) -D $< > $@

firmware_words.vh: $(TARGET).bin
	python bin2hex.py $< $@

clean:
	rm -f *.o *.elf *.bin *.hex *.dump firmware_words.vh

.PHONY: all clean
