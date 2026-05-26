#define __SYSCALL_LL_E(x) (x)
#define __SYSCALL_LL_O(x) (x)

hidden long __syscall0(long);
hidden long __syscall1(long, long);
hidden long __syscall2(long, long, long);
hidden long __syscall3(long, long, long, long);
hidden long __syscall4(long, long, long, long, long);
hidden long __syscall5(long, long, long, long, long, long);
hidden long __syscall6(long, long, long, long, long, long, long);

#define VDSO_USEFUL
#define VDSO_CGT_SYM "__vdso_clock_gettime"
#define VDSO_CGT_VER "LINUX_2.6"
#define VDSO_GETCPU_SYM "__vdso_getcpu"
#define VDSO_GETCPU_VER "LINUX_2.6"

#define IPC_64 0
