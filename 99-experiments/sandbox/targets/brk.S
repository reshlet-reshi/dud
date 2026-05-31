.section .text
.global _start
_start:
    xor %edi, %edi
    mov $12, %eax
    syscall
    ud2

