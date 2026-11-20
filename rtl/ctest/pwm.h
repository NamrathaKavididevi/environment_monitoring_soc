#ifndef PWM_H
#define PWM_H

#include <stdint.h>

#define PWM_BASE            0x4000A000

#define PWM_REG_CONTROL     (*(volatile uint32_t *)(PWM_BASE + 0x00))
#define PWM_REG_PERIOD      (*(volatile uint32_t *)(PWM_BASE + 0x04))
#define PWM_REG_DUTY        (*(volatile uint32_t *)(PWM_BASE + 0x08))
#define PWM_REG_COUNTER     (*(volatile uint32_t *)(PWM_BASE + 0x0C))
#define PWM_REG_STATUS      (*(volatile uint32_t *)(PWM_BASE + 0x10))
#define PWM_REG_IRQ_ENABLE  (*(volatile uint32_t *)(PWM_BASE + 0x14))

#define PWM_CTRL_EN         (1 << 0)
#define PWM_CTRL_POLARITY   (1 << 1)

static inline void pwm_init(uint32_t period, uint32_t duty) {
    PWM_REG_CONTROL = 0; // Disable
    PWM_REG_PERIOD = period;
    PWM_REG_DUTY = duty;
    PWM_REG_CONTROL = PWM_CTRL_EN; // Enable active-high
}

static inline void pwm_set_duty(uint32_t duty) {
    PWM_REG_DUTY = duty;
}

static inline void pwm_stop(void) {
    PWM_REG_CONTROL = 0;
}

#endif // PWM_H
