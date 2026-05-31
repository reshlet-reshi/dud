.section .text
.global _start
_start:
    mov $7, %edi
    mov $60, %eax
    syscall

