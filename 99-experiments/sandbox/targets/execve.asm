mov rax, 0x00000065706f6e2f
push rax
mov rdi, rsp
xor esi, esi
xor edx, edx
mov eax, 59
syscall
ud2
