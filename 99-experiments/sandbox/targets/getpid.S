.section .text
.global _start
_start:
    mov $39, %eax
    syscall
    ud2

