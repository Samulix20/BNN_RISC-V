#ifndef CSR_H
#define CSR_H

#include "types.h"

// mcause values
#define MCAUSE_MISALIGNED_FETCH      0x0
#define MCAUSE_FETCH_ACCESS          0x1
#define MCAUSE_ILLEGAL_INSTRUCTION   0x2
#define MCAUSE_BREAKPOINT            0x3
#define MCAUSE_MISALIGNED_LOAD       0x4
#define MCAUSE_LOAD_ACCESS           0x5
#define MCAUSE_MISALIGNED_STORE      0x6
#define MCAUSE_STORE_ACCESS          0x7
#define MCAUSE_USER_ECALL            0x8
#define MCAUSE_SUPERVISOR_ECALL      0x9
#define MCAUSE_HYPERVISOR_ECALL      0xa
#define MCAUSE_MACHINE_ECALL         0xb
#define MCAUSE_FETCH_PAGE_FAULT      0xc
#define MCAUSE_LOAD_PAGE_FAULT       0xd
#define MCAUSE_STORE_PAGE_FAULT      0xf
#define MCAUSE_TIMER_IRQ             0x80000007

// FUNCTIONS IMPLEMENTED HERE FOR INLINING

inline uint32 read_mcause() {
    uint32 mcause;
    asm volatile("csrr %0, mcause" : "=r" (mcause));
    return mcause;
}

inline uint32 read_mscratch() {
    uint32 mscratch;
    asm volatile("csrr %0, mscratch" : "=r" (mscratch));
    return mscratch;
}

// Bitmask set mie
inline void set_mie(uint32 mask) {
    asm volatile("csrs mie, %0" :: "r" (mask));
}
// Bitmask clear mie
inline void clear_mie(uint32 mask) {
    asm volatile("csrc mie, %0" :: "r" (mask));
}

// mstatus mie bit
#define MSTATUS_MIE (1 << 3)
// Bitmask set mstatus
inline void set_mstatus(uint32 mask) {
    asm volatile("csrs mstatus, %0" :: "r" (mask));
}
// Bitmask clear mstatus
inline void clear_mstatus(uint32 mask) {
    asm volatile("csrc mstatus, %0" :: "r" (mask));
}
inline uint32 read_mstatus() {
    uint32 mstatus;
    asm volatile("csrr %0, mstatus" : "=r" (mstatus));
    return mstatus;
}

inline uint32 read_mepc() {
    uint32 mepc;
    asm volatile("csrr %0, mepc" : "=r" (mepc));
    return mepc;
}

// mcountinhibit bits
#define MCYCLE_BIT      (1)
#define MINSTRET_BIT    (1 << 2)

inline void set_mcountinhibit(uint32 mask) {
    asm volatile("csrs mcountinhibit, %0" :: "r" (mask));
}

inline void clear_mcountinhibit(uint32 mask) {
    asm volatile("csrc mcountinhibit, %0" :: "r" (mask));
}

inline uint64 read_mcycle() {
    uint32 cl, ch;

    set_mcountinhibit(MCYCLE_BIT);
    asm volatile(
        "csrr %0, mcycle\n"
        "csrr %1, mcycleh" 
        : "=r" (cl), "=r" (ch)
    );
    clear_mcountinhibit(MCYCLE_BIT);

    return ((uint64) ch << 32) | cl;
}

inline uint64 read_instret() {
    uint32 il, ih;

    set_mcountinhibit(MINSTRET_BIT);
    asm volatile(
        "csrr %0, minstret\n"
        "csrr %1, minstreth"
        : "=r" (il), "=r" (ih)
    );
    clear_mcountinhibit(MINSTRET_BIT);

    return ((uint64) ih << 32) | il;
}

inline void read_hw_counters(uint64* cycles, uint64* instr) {
    uint32 cl, ch, il, ih;

    set_mcountinhibit(MINSTRET_BIT | MCYCLE_BIT);
    asm volatile(
        "csrr %0, mcycle\n"
        "csrr %1, mcycleh" 
        : "=r" (cl), "=r" (ch)
    );
    asm volatile(
        "csrr %0, minstret\n"
        "csrr %1, minstreth"
        : "=r" (il), "=r" (ih)
    );
    clear_mcountinhibit(MINSTRET_BIT | MCYCLE_BIT);

    *cycles = ((uint64) ch << 32) | cl;
    *instr = ((uint64) ih << 32) | il;
}

#endif
