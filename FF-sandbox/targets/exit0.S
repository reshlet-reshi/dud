.section .text
.global _start
_start:
    xor %edi, %edi
    mov $60, %eax
    syscall

