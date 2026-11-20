#ifndef SPI_H
#define SPI_H

#include <stdint.h>

#define SPI_BASE            0x40006000

#define SPI_REG_CONTROL     (*(volatile uint32_t *)(SPI_BASE + 0x00))
#define SPI_REG_STATUS      (*(volatile uint32_t *)(SPI_BASE + 0x04))
#define SPI_REG_TX_DATA     (*(volatile uint32_t *)(SPI_BASE + 0x08))
#define SPI_REG_RX_DATA     (*(volatile uint32_t *)(SPI_BASE + 0x0C))
#define SPI_REG_CLK_DIV     (*(volatile uint32_t *)(SPI_BASE + 0x10))
#define SPI_REG_CS          (*(volatile uint32_t *)(SPI_BASE + 0x14))
#define SPI_REG_IRQ_ENABLE  (*(volatile uint32_t *)(SPI_BASE + 0x18))
#define SPI_REG_IRQ_STATUS  (*(volatile uint32_t *)(SPI_BASE + 0x1C))

#define SPI_CTRL_EN         (1 << 0)
#define SPI_CTRL_CPOL       (1 << 1)
#define SPI_CTRL_CPHA       (1 << 2)
#define SPI_CTRL_MASTER     (1 << 3)

#define SPI_STATUS_BUSY     (1 << 0)
#define SPI_STATUS_TX_READY (1 << 1)
#define SPI_STATUS_RX_VALID (1 << 2)

static inline void spi_init(uint16_t clk_div) {
    SPI_REG_CLK_DIV = clk_div;
    SPI_REG_CS = 1; // Deassert CS_N (active low)
    SPI_REG_CONTROL = SPI_CTRL_EN | SPI_CTRL_MASTER;
}

static inline void spi_cs_assert(void) {
    SPI_REG_CS = 0;
}

static inline void spi_cs_deassert(void) {
    SPI_REG_CS = 1;
}

static inline uint8_t spi_transfer(uint8_t data) {
    while (SPI_REG_STATUS & SPI_STATUS_BUSY) {
        // Wait
    }
    SPI_REG_TX_DATA = data;
    while (SPI_REG_STATUS & SPI_STATUS_BUSY) {
        // Wait for shift complete
    }
    return (uint8_t)(SPI_REG_RX_DATA & 0xFF);
}

#endif // SPI_H
