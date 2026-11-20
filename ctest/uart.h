#ifndef UART_H
#define UART_H

#include <stdint.h>

#define UART_BASE           0x40000000

#define UART_REG_DATA       (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_REG_STATUS     (*(volatile uint32_t *)(UART_BASE + 0x04))
#define UART_REG_CONTROL    (*(volatile uint32_t *)(UART_BASE + 0x08))
#define UART_REG_BAUD_DIV   (*(volatile uint32_t *)(UART_BASE + 0x0C))
#define UART_REG_IRQ_ENABLE (*(volatile uint32_t *)(UART_BASE + 0x10))
#define UART_REG_IRQ_STATUS (*(volatile uint32_t *)(UART_BASE + 0x14))

#define UART_STATUS_TX_BUSY   (1 << 0)
#define UART_STATUS_TX_EMPTY  (1 << 1)
#define UART_STATUS_RX_VALID  (1 << 2)

#define UART_CONTROL_TX_EN    (1 << 0)
#define UART_CONTROL_RX_EN    (1 << 1)

void uart_init(uint16_t baud_div);
void uart_putc(char c);
void uart_puts(const char *str);
int  uart_has_rx(void);
char uart_getc(void);

#endif // UART_H
