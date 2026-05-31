# Project Structure

```text
sandbox-runner/
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
    exit0.S
    exit7.S
    write_stdout.S
    open_file.S
    loop.S
    syscall_matrix.S

  tests/
    baseline.bats
    negative-syscalls.bats
    resource-limits.bats

  docs/
    add-back-checklist.md
    threat-model.md
    syscall-policy.md
```
