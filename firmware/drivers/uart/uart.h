#ifndef UART_H
#define UART_H

#include <stdint.h>

/* Blocking, polling-only UART access. Clock and baud are configured in RTL.
 * These functions check STATUS before accessing TX/RX: full TX or empty RX
 * accesses return an APB error, which currently halts the CPU. */
 
void uart_putc(char character);
char uart_getc(void);

uint32_t uart_rx_count(void);
uint32_t uart_tx_count(void);

#endif
