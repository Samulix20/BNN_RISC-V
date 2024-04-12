#ifndef RV_CONFIG_H
#define RV_CONFIG_H

// mtimer registers
#define MTIMER_COUNTER      *((volatile uint64 *) MTIMER_BASE_ADDR)
#define MTIMER_CMP          *((volatile uint64 *) (MTIMER_BASE_ADDR + 8))

// print register
#define PRINT_REG       *((volatile unsigned int *) PRINT_REG_ADDR)

#endif

