.section .text
.global _start
_start:
    xor %edi, %edi
    xor %esi, %esi
    xor %edx, %edx
    mov $16, %eax
    syscall
    ud2

