#ifndef GPIO_H
#define GPIO_H

#include <stdint.h>

#define GPIO_BASE           0x40002000

#define GPIO_REG_INPUT      (*(volatile uint32_t *)(GPIO_BASE + 0x00))
#define GPIO_REG_OUTPUT     (*(volatile uint32_t *)(GPIO_BASE + 0x04))
#define GPIO_REG_DIRECTION  (*(volatile uint32_t *)(GPIO_BASE + 0x08))
#define GPIO_REG_SET        (*(volatile uint32_t *)(GPIO_BASE + 0x0C))
#define GPIO_REG_CLEAR      (*(volatile uint32_t *)(GPIO_BASE + 0x10))
#define GPIO_REG_IRQ_ENABLE (*(volatile uint32_t *)(GPIO_BASE + 0x14))
#define GPIO_REG_IRQ_STATUS (*(volatile uint32_t *)(GPIO_BASE + 0x18))

static inline void gpio_init(uint8_t direction) {
    GPIO_REG_DIRECTION = direction;
    GPIO_REG_OUTPUT = 0x00;
}

static inline void gpio_write(uint8_t val) {
    GPIO_REG_OUTPUT = val;
}

static inline uint8_t gpio_read(void) {
    return (uint8_t)(GPIO_REG_INPUT & 0xFF);
}

static inline void gpio_set_pin(uint8_t pin_mask) {
    GPIO_REG_SET = pin_mask;
}

static inline void gpio_clear_pin(uint8_t pin_mask) {
    GPIO_REG_CLEAR = pin_mask;
}

#endif // GPIO_H
