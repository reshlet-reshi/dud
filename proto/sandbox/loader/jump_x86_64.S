.text
.global sandbox_jump
.type sandbox_jump, @function
sandbox_jump:
    mov %rsi, %rsp
    and $-16, %rsp
    push %rdi

    xor %rax, %rax
    xor %rbx, %rbx
    xor %rcx, %rcx
    xor %rdx, %rdx
    xor %rsi, %rsi
    xor %rdi, %rdi
    xor %rbp, %rbp
    xor %r8, %r8
    xor %r9, %r9
    xor %r10, %r10
    xor %r11, %r11
    xor %r12, %r12
    xor %r13, %r13
    xor %r14, %r14
    xor %r15, %r15

    ret
    ud2
.size sandbox_jump, .-sandbox_jump

.section .note.GNU-stack,"",@progbits
