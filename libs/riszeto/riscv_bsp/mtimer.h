#ifndef MTIMER_H
#define MTIMER_H

#include "types.h"
#include "config.h"

// mtimer bit in mie
#define MIE_MTIMER (1 << 7)

// mtimer irq handler
void _mtimer_irq();

// mtimer set interrupt period in ticks
void set_mtimer_period(uint64 p);

// Enable mtimer interrupts
void enable_mtimer();

// Disable mtimer interrupts
void disable_mtimer();

// Set callback funtion pointer
void set_mtimer_callback(void (*callback)());

#endif
