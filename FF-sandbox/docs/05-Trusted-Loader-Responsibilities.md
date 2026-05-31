# Trusted Loader Responsibilities

The trusted loader is the real final lockdown boundary.

Baseline sequence:

```text
1. open /target
2. read target bytes
3. mmap anonymous memory for target
4. copy target bytes into mapping
5. mprotect target mapping RX
6. close /target fd
7. clear sensitive buffers
8. set no_new_privs
9. install Landlock deny-all
10. close all fds, including stdin/stdout/stderr
11. set final RLIMITs
12. install final seccomp: allow only exit
13. switch to clean minimal stack
14. jump to target entry
```

More concrete loader pseudocode:

```c
int main(int argc, char **argv) {
    int fd = open("/target", O_RDONLY | O_CLOEXEC);
    struct stat st;
    fstat(fd, &st);

    void *mem = mmap(NULL, st.st_size,
                     PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS,
                     -1, 0);

    read_exact(fd, mem, st.st_size);
    close(fd);

    mprotect(mem, st.st_size, PROT_READ | PROT_EXEC);

    zero_sensitive_scratch_buffers();

    prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);

    install_landlock_deny_all_if_available();

    close_range(0, ~0U, 0);

    setrlimit(RLIMIT_CORE,  0);
    setrlimit(RLIMIT_FSIZE, 0);
    setrlimit(RLIMIT_CPU,   1);
    setrlimit(RLIMIT_AS,    small_limit);
    setrlimit(RLIMIT_STACK, small_limit);
    setrlimit(RLIMIT_NPROC, 0_or_1);
    setrlimit(RLIMIT_NOFILE, 0);

    install_seccomp_allow_only_exit();

    switch_to_clean_stack_and_jump(mem);
}
```

Order matters.

Do setup first, then progressively remove authority:

```text
map target
close fds
lower rlimits
Landlock
seccomp
jump
```

After final seccomp, the loader cannot repair anything. 

The target can only call `exit`.
