.global __syscall0
.hidden __syscall0
__syscall0:
    mov %rdi,%rax
    syscall
    ret

.global __syscall1
.hidden __syscall1
__syscall1:
    mov %rdi,%rax
    mov %rsi,%rdi
    syscall
    ret

.global __syscall2
.hidden __syscall2
__syscall2:
    mov %rdi,%rax
    mov %rsi,%rdi
    mov %rdx,%rsi
    syscall
    ret

.global __syscall3
.hidden __syscall3
__syscall3:
    mov %rdi,%rax
    mov %rsi,%rdi
    mov %rdx,%rsi
    mov %rcx,%rdx
    syscall
    ret

.global __syscall4
.hidden __syscall4
__syscall4:
    mov %rdi,%rax
    mov %rsi,%rdi
    mov %rdx,%rsi
    mov %rcx,%rdx
    mov %r8,%r10
    syscall
    ret

.global __syscall5
.hidden __syscall5
__syscall5:
    mov %rdi,%rax
    mov %rsi,%rdi
    mov %rdx,%rsi
    mov %rcx,%rdx
    mov %r8,%r10
    mov %r9,%r8
    syscall
    ret

.global __syscall6
.hidden __syscall6
__syscall6:
    mov %rdi,%rax
    mov %rsi,%rdi
    mov %rdx,%rsi
    mov %rcx,%rdx
    mov %r8,%r10
    mov %r9,%r8
    mov 8(%rsp),%r9
    syscall
    ret
