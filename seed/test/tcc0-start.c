void _start(void) {
    __asm__(
        "mov $60, %rax\n"
        "xor %rdi, %rdi\n"
        "syscall\n"
    );
}
