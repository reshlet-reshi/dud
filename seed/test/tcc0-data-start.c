extern long x;

void _start(void) {
    long status = x != 42;
    __asm__(
        "mov $60, %%rax\n"
        "mov %0, %%rdi\n"
        "syscall\n"
        : : "r"(status) : "rax", "rdi"
    );
}
