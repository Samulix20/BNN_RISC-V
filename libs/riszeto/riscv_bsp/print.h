#ifndef PRINT_H
#define PRINT_H

#include "types.h"
#include "config.h"

#define TERM_CHAR           0x4

#define RV_PRINTF_BUFLEN    255
size_t rv_printf(const char* fmt, ...);

// Override stdio printf definition
#define printf rv_printf

#endif
