.section .text
.global _start
_start:
    xor %edi, %edi
    xor %esi, %esi
    xor %edx, %edx
    xor %r10d, %r10d
    mov $101, %eax
    syscall
    ud2

