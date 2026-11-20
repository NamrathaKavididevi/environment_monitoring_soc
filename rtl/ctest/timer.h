#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>

#define TIMER_BASE            0x40004000

#define TIMER_REG_CONTROL     (*(volatile uint32_t *)(TIMER_BASE + 0x00))
#define TIMER_REG_COUNTER     (*(volatile uint32_t *)(TIMER_BASE + 0x04))
#define TIMER_REG_COMPARE     (*(volatile uint32_t *)(TIMER_BASE + 0x08))
#define TIMER_REG_PRESCALER   (*(volatile uint32_t *)(TIMER_BASE + 0x0C))
#define TIMER_REG_STATUS      (*(volatile uint32_t *)(TIMER_BASE + 0x10))
#define TIMER_REG_IRQ_ENABLE  (*(volatile uint32_t *)(TIMER_BASE + 0x14))

#define TIMER_CTRL_EN           (1 << 0)
#define TIMER_CTRL_AUTO_RELOAD  (1 << 1)
#define TIMER_CTRL_COUNT_UP     (1 << 2)

static inline void timer_init(uint32_t compare, uint32_t prescaler) {
    TIMER_REG_CONTROL = 0; // Stop
    TIMER_REG_PRESCALER = prescaler;
    TIMER_REG_COMPARE = compare;
    TIMER_REG_COUNTER = 0;
    TIMER_REG_STATUS = 1; // Clear any pending tick
    TIMER_REG_IRQ_ENABLE = 1;
    TIMER_REG_CONTROL = TIMER_CTRL_EN | TIMER_CTRL_AUTO_RELOAD | TIMER_CTRL_COUNT_UP;
}

static inline int timer_poll_tick(void) {
    if (TIMER_REG_STATUS & 1) {
        TIMER_REG_STATUS = 1; // Clear on W1C
        return 1;
    }
    return 0;
}

#endif // TIMER_H
