.section .text
.global _start
_start:
    xor %edi, %edi
    xor %esi, %esi
    xor %edx, %edx
    xor %r10d, %r10d
    xor %r8d, %r8d
    mov $165, %eax
    syscall
    ud2

