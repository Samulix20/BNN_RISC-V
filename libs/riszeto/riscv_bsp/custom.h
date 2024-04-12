#ifndef CUSTOM_H
#define CUSTOM_H

#include "types.h"

// FUNCTIONS IMPLEMENTED HERE FOR INLINING

// Gaussian number generator
inline int32 gen_num() {
    int32 aux;
    asm volatile("genum %0" : "=r" (aux));
    return aux;
}

// Sets reg_id register of generator internal value to seed
inline void set_seed(uint32 reg_id, uint32 seed) {
    asm volatile(
        "setseed %0, %1\n"
        "nop\n"
        "nop\n"
        "nop\n"
        "nop"
        :: "r" (reg_id), "r" (seed)
    );
}

#endif
