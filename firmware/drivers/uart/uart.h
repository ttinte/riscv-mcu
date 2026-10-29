#ifndef UART_H
#define UART_H

#include <stdint.h>

/* Clock and baud are configured in RTL. uart_putc() and uart_getc() block;
 * uart_try_getc() returns zero immediately when the RX FIFO is empty. */

void uart_putc(char character);
char uart_getc(void);
uint32_t uart_try_getc(char *character);

uint32_t uart_rx_count(void);
uint32_t uart_tx_count(void);

#endif
