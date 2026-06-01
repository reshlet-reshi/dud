mov rax, 0x0000000000647773
push rax
mov rax, 0x7361702f6374652f
push rax
mov rdi, rsp
xor esi, esi
mov eax, 2
syscall
ud2
