#ifndef I2C_H
#define I2C_H

#include <stdint.h>

#define I2C_BASE            0x40008000

#define I2C_REG_CONTROL     (*(volatile uint32_t *)(I2C_BASE + 0x00))
#define I2C_REG_STATUS      (*(volatile uint32_t *)(I2C_BASE + 0x04))
#define I2C_REG_DATA        (*(volatile uint32_t *)(I2C_BASE + 0x08))
#define I2C_REG_ADDRESS     (*(volatile uint32_t *)(I2C_BASE + 0x0C))
#define I2C_REG_CLK_DIV     (*(volatile uint32_t *)(I2C_BASE + 0x10))
#define I2C_REG_COMMAND     (*(volatile uint32_t *)(I2C_BASE + 0x14))
#define I2C_REG_IRQ_ENABLE  (*(volatile uint32_t *)(I2C_BASE + 0x18))
#define I2C_REG_IRQ_STATUS  (*(volatile uint32_t *)(I2C_BASE + 0x1C))

#define I2C_CTRL_EN         (1 << 0)
#define I2C_CTRL_MASTER     (1 << 1)

#define I2C_STATUS_BUSY     (1 << 0)
#define I2C_STATUS_ACK      (1 << 1)
#define I2C_STATUS_DONE     (1 << 3)

#define I2C_CMD_START       (1 << 0)
#define I2C_CMD_STOP        (1 << 1)
#define I2C_CMD_WRITE       (1 << 2)
#define I2C_CMD_READ        (1 << 3)

static inline void i2c_init(uint16_t clk_div) {
    I2C_REG_CLK_DIV = clk_div;
    I2C_REG_CONTROL = I2C_CTRL_EN | I2C_CTRL_MASTER;
}

static inline int i2c_start_write(uint8_t slave_addr) {
    I2C_REG_ADDRESS = (slave_addr << 1) & 0xFE; // Write mode (bit 0 = 0)
    I2C_REG_COMMAND = I2C_CMD_START;
    return 0;
}

static inline int i2c_read_byte(uint8_t slave_addr, uint8_t *val) {
    I2C_REG_ADDRESS = (slave_addr << 1) | 0x01; // Read mode (bit 0 = 1)
    I2C_REG_COMMAND = I2C_CMD_START | I2C_CMD_READ;
    *val = (uint8_t)(I2C_REG_DATA & 0xFF);
    I2C_REG_COMMAND = I2C_CMD_STOP;
    return 0;
}

#endif // I2C_H
