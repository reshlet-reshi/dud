.section .text
.global _start
_start:
    lea path(%rip), %rdi
    xor %esi, %esi
    xor %edx, %edx
    mov $59, %eax
    syscall
    ud2
path:
    .asciz "/nope"

