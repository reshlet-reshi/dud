# 03-musl-tcc/syscall_arch.h

This note is the evidence trail for `03-musl-tcc/syscall_arch.h`.

The file replaces musl 1.2.6's `arch/x86_64/syscall_arch.h` during the musl-tcc
bootstrap.

## What It Does

Upstream musl's x86_64 `syscall_arch.h` defines the syscall entry points as
`static __inline` functions containing GCC-style inline assembly.

The bootstrap TCC path used here provides out-of-line syscall helpers instead,
so this replacement keeps musl's required macro definitions but declares the
helper entry points as hidden functions:

```c
hidden long __syscall0(long);
hidden long __syscall1(long, long);
hidden long __syscall2(long, long, long);
hidden long __syscall3(long, long, long, long);
hidden long __syscall4(long, long, long, long, long);
hidden long __syscall5(long, long, long, long, long, long);
hidden long __syscall6(long, long, long, long, long, long, long);
```

The VDSO symbol macros and `IPC_64` value match upstream musl's x86_64 header.

## Bootstrap Scope

This is a bootstrap header for the repo's x86_64 Linux musl-tcc runme path. It is
not intended to be a general replacement for musl's upstream `syscall_arch.h`,
and it depends on this bootstrap providing compatible implementations of
`__syscall0` through `__syscall6`.
