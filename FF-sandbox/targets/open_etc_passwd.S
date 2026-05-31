.section .text
.global _start
_start:
    lea path(%rip), %rdi
    xor %esi, %esi
    mov $2, %eax
    syscall
    ud2
path:
    .asciz "/etc/passwd"

