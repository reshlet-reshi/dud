.section .text
.global _start
_start:
    mov $1, %edi
    lea msg(%rip), %rsi
    mov $1, %edx
    mov $1, %eax
    syscall
    ud2
msg:
    .ascii "x"

