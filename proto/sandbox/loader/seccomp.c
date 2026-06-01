#define _GNU_SOURCE

#include "seccomp.h"

#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/prctl.h>
#include <sys/syscall.h>
#include <unistd.h>

#include <linux/audit.h>
#include <linux/filter.h>
#include <linux/seccomp.h>

#ifndef SYS_seccomp
#ifdef __NR_seccomp
#define SYS_seccomp __NR_seccomp
#endif
#endif

int install_exit0_seccomp(void) {
    struct sock_filter filter[] = {
        BPF_STMT(
            BPF_LD | BPF_W | BPF_ABS,
            (uint32_t) offsetof(struct seccomp_data, arch)
        ),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, AUDIT_ARCH_X86_64, 1, 0),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS),

        BPF_STMT(
            BPF_LD | BPF_W | BPF_ABS,
            (uint32_t) offsetof(struct seccomp_data, nr)
        ),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_exit, 1, 0),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS),

        BPF_STMT(
            BPF_LD | BPF_W | BPF_ABS,
            (uint32_t) offsetof(struct seccomp_data, args[0])
        ),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0, 1, 0),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS),

        BPF_STMT(
            BPF_LD | BPF_W | BPF_ABS,
            (uint32_t) offsetof(struct seccomp_data, args[0]) + 4U
        ),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0, 1, 0),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS),

        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
    };
    struct sock_fprog program = {
        .len = (unsigned short) (sizeof(filter) / sizeof(filter[0])),
        .filter = filter,
    };

#ifdef SYS_seccomp
    if (syscall(SYS_seccomp, SECCOMP_SET_MODE_FILTER, 0, &program) == 0) {
        return 0;
    }

    if (errno != ENOSYS) {
        return -1;
    }
#endif

    return prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &program);
}

