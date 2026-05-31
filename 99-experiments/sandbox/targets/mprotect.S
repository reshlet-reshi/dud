.section .text
.global _start
_start:
    xor %edi, %edi
    mov $4096, %esi
    mov $7, %edx
    mov $10, %eax
    syscall
    ud2

