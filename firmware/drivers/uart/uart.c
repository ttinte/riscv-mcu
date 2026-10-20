#include "uart.h"
#include "soc.h"

#define REG(base, offset) (*(volatile unsigned char *)((base) + (offset)))

#define UART_TX      REG(UART_BASE, 0x00u)
#define UART_RX      REG(UART_BASE, 0x04u)
#define UART_STATUS  REG(UART_BASE, 0x08u)

#define UART_TX_FULL  (UART_STATUS & (1u << 0))
#define UART_RX_EMPTY (UART_STATUS & (1u << 1))

static uint32_t rx_byte_count;
static uint32_t tx_byte_count;

void uart_putc(char character)
{
    while (UART_TX_FULL) {}

    UART_TX = (unsigned char)character;
    ++tx_byte_count;
}

char uart_getc(void)
{
    while (UART_RX_EMPTY) {}

    ++rx_byte_count;
    return (char)UART_RX;
}

uint32_t uart_rx_count(void)
{
    return rx_byte_count;
}

uint32_t uart_tx_count(void)
{
    return tx_byte_count;
}
