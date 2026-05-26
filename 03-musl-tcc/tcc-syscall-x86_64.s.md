# 03-musl-tcc/tcc-syscall-x86_64.s

This note is the evidence trail for `03-musl-tcc/tcc-syscall-x86_64.s`.

This assembly file provides the out-of-line syscall helper functions declared
by `03-musl-tcc/syscall_arch.h`.

## Why It Exists

Upstream musl's `arch/x86_64/syscall_arch.h` implements `__syscall0` through
`__syscall6` as `static __inline` functions using GCC-style inline assembly.
This bootstrap replaces that header with declarations because the TCC bootstrap
path is not using musl's inline-assembly implementation.

The replacement declarations need actual symbols in `libc.a`, so this file
defines:

```text
__syscall0
__syscall1
__syscall2
__syscall3
__syscall4
__syscall5
__syscall6
```

## Calling Convention

The helpers receive arguments using the normal x86_64 C ABI, then move them to
the Linux syscall ABI:

- syscall number: C `rdi` -> syscall `rax`
- arg1: C `rsi` -> syscall `rdi`
- arg2: C `rdx` -> syscall `rsi`
- arg3: C `rcx` -> syscall `rdx`
- arg4: C `r8` -> syscall `r10`
- arg5: C `r9` -> syscall `r8`
- arg6: stack slot `8(%rsp)` -> syscall `r9`

Each helper then executes `syscall` and returns with the kernel result in
`rax`, which is also the C return register.
