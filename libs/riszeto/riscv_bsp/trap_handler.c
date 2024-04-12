#include "print.h"
#include "csr.h"
#include "mtimer.h"

#include <stdlib.h>

void _trap_handler() {
    uint32 mcause = read_mcause();

    switch (mcause) {
        case MCAUSE_TIMER_IRQ:
            _mtimer_irq();
            break;
        default:
            rv_printf("Unexpected mcause found: 0x%x\n", mcause);
            rv_printf("MEPC: 0x%x\n", read_mepc());
            rv_printf("MSCRATCH: 0x%x\n", read_mscratch());
            exit(mcause);
    }
}
