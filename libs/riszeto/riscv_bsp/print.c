#include <stdarg.h>
#include <stdio.h>

#include "print.h"

// putchar for ghdl riscv cpu
inline void _putchar(const char c) {
    PRINT_REG = c;
}

inline size_t _nputstr(const char* str, size_t n) {
    size_t i = 0;
    while(str[i] != 0 && i < n) {
        _putchar(str[i]);
        i++;
    }
    return i;
}

size_t rv_printf(const char* fmt, ...) {
    char tmpbuff[RV_PRINTF_BUFLEN];
    
    // Wrapper for snprintf stdlib call
    va_list args;
    va_start(args, fmt);
    vsnprintf(tmpbuff, RV_PRINTF_BUFLEN, fmt, args);
    va_end(args);

    // Call riscv ghdl print
    return _nputstr(tmpbuff, RV_PRINTF_BUFLEN);
}
