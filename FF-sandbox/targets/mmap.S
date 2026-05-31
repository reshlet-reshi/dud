.section .text
.global _start
_start:
    xor %edi, %edi
    mov $4096, %esi
    mov $3, %edx
    mov $34, %r10d
    mov $-1, %r8d
    xor %r9d, %r9d
    mov $9, %eax
    syscall
    ud2

