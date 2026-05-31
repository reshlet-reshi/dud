.section .text
.global _start
_start:
    mov $2, %edi
    mov $1, %esi
    xor %edx, %edx
    mov $41, %eax
    syscall
    ud2

