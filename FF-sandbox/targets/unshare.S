.section .text
.global _start
_start:
    xor %edi, %edi
    mov $272, %eax
    syscall
    ud2

