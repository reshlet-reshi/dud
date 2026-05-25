extern long foo(long);

void _start(void) {
    long status = foo(41) != 42;
    __asm__(
        "mov $60, %%rax\n"
        "mov %0, %%rdi\n"
        "syscall\n"
        : : "r"(status) : "rax", "rdi"
    );
}
