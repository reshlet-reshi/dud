# Target ABI for Baseline

Start with a raw x86-64 code blob, not a normal ELF process.

Baseline ABI:

```text
architecture:
  x86-64 Linux

entrypoint:
  byte 0 of mapped target blob

stack:
  tiny clean stack created by loader

argv/envp/auxv:
  none

fds:
  none

allowed syscall:
  exit

return behavior:
  target must not return
  returning should segfault or otherwise fail
```

Example intended target logic:

```asm
.global _start
_start:
    xor %edi, %edi      # status = 0
    mov $60, %eax       # x86-64 SYS_exit
    syscall
```

For a raw blob, assemble/extract only the code bytes. 

have the loader understand your chosen object format.

Do not begin with libc. 

Do not begin with dynamic linking. 

Do not begin with normal ELF. 

Implement a real ELF loader in a future milestone.
