.section .text
.global _start
_start:
    xor %eax, %eax
    mov (%rax), %rax

