#include "mtimer.h"
#include "csr.h"
#include "print.h"

static uint64 period;

void (*mtimer_callback_fun_ptr)(void) = NULL;

void _mtimer_irq() {
    MTIMER_CMP = MTIMER_COUNTER + period;
    if(mtimer_callback_fun_ptr != NULL) {
        (*mtimer_callback_fun_ptr)();
    }
}

void set_mtimer_period(uint64 p) {
    period = p;
    MTIMER_CMP = MTIMER_COUNTER + period;
}

void enable_mtimer() {
    set_mie(MIE_MTIMER);
    set_mstatus(MSTATUS_MIE);
}

void disable_mtimer() {
    clear_mie(MIE_MTIMER);
    clear_mstatus(MSTATUS_MIE);
}

void set_mtimer_callback(void (*callback)()) {
    mtimer_callback_fun_ptr = callback;
}

