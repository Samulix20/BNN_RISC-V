#include <string.h>

extern void* _sbss_start;
extern void* _sbss_end;
extern void* _bss_start;
extern void* _bss_end;

// Set bss and sbss sections to 0
void bss_init() {
    // sbss
    memset(_sbss_start, 0, _sbss_end - _sbss_start);
    // bss
    memset(_bss_start, 0, _bss_end - _bss_start);
}
