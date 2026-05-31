mov rax, 0x007465677261742f
push rax
mov rdi, rsp
xor esi, esi
mov eax, 2
syscall
ud2
