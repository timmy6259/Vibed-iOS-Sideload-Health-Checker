#include "JitProbe.h"

#include <sys/mman.h>
#include <unistd.h>
#include <stdbool.h>
#include <stddef.h>

bool jit_probe_available(void) {
    long pageSize = sysconf(_SC_PAGESIZE);
    if (pageSize <= 0) {
        return false;
    }

    void *ptr = mmap(NULL, (size_t)pageSize, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANON, -1, 0);
    if (ptr == MAP_FAILED) {
        return false;
    }

    #ifdef MAP_JIT
    void *jitPtr = mmap(NULL, (size_t)pageSize, PROT_READ | PROT_WRITE,
                       MAP_PRIVATE | MAP_ANON | MAP_JIT, -1, 0);
    if (jitPtr != MAP_FAILED) {
        munmap(jitPtr, (size_t)pageSize);
    }
    #endif

    int protectionOK = mprotect(ptr, (size_t)pageSize, PROT_READ | PROT_EXEC);
    munmap(ptr, (size_t)pageSize);

    return protectionOK == 0;
}
