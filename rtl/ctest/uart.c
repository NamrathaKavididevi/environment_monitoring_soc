#include "uart.h"

void uart_init(uint16_t baud_div) {
    UART_REG_BAUD_DIV = baud_div;
    UART_REG_CONTROL = UART_CONTROL_TX_EN | UART_CONTROL_RX_EN;
}

void uart_putc(char c) {
    while (UART_REG_STATUS & UART_STATUS_TX_BUSY) {
        // Wait until TX is ready
    }
    UART_REG_DATA = (uint32_t)(uint8_t)c;
}

void uart_puts(const char *str) {
    while (*str) {
        if (*str == '\n') {
            uart_putc('\r');
        }
        uart_putc(*str++);
    }
}

int uart_has_rx(void) {
    return (UART_REG_STATUS & UART_STATUS_RX_VALID) ? 1 : 0;
}

char uart_getc(void) {
    while (!uart_has_rx()) {
        // Wait for incoming character
    }
    return (char)(UART_REG_DATA & 0xFF);
}
