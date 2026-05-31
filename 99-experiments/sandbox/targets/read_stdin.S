.section .text
.global _start
_start:
    xor %edi, %edi
    lea byte_buf(%rip), %rsi
    mov $1, %edx
    xor %eax, %eax
    syscall
    ud2
byte_buf:
    .byte 0

