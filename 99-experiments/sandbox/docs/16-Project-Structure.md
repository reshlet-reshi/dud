# Project Structure

```text
sandbox/
  README.md

  scripts/
    run-sandbox.sh
    run-in-cgroup.sh

  loader/
    loader.c
    seccomp.c
    seccomp.h
    landlock.c
    landlock.h
    rlimits.c
    rlimits.h
    jump_x86_64.S

  targets/
    exit0.asm
    exit7.asm
    write_stdout.asm
    open_file.asm
    loop.asm
    syscall_matrix.asm

  tests/
    baseline.bats
    negative-syscalls.bats
    resource-limits.bats

  docs/
    add-back-checklist.md
    threat-model.md
    syscall-policy.md
```
