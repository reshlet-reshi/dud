# Goal

Build a sandbox runner that starts from the most restrictive useful baseline:

```text
hostile target = raw x86-64 code whose only intended operation is:
  syscall exit(0)
```

The project should establish a **deny-everything baseline**.

Initialy, the target is only allowed to exit. 

Then add 

- capabilities, 
- syscalls, 
- files, 
- resources, 
- and communication channels back 

only when a concrete larger app requires them.

The desired long-term model:

```text
start with:
  no filesystem
  no network
  no /proc
  no /dev
  no environment
  no inherited file descriptors
  no stdout/stderr output
  no execve
  no open/read/write
  no mmap/brk/mprotect after startup
  no threads/processes
  no capabilities
  only final syscall: exit

then add back:
  one object, syscall, resource, or channel at a time
```

The only intended output channel is:

```text
exit status + unavoidable timing
```

---

1. [Core Architecture](01-Core-Architecture.md)
2. [Baseline Threat Model](02-Baseline-Threat-Model.md)
3. [Strict Baseline `bwrap` Shape](03-Strict-Baseline-Shape.md)
4. [Outer Wrapper Responsibilities](04-Outer-Wrapper-Responsibilities.md)
5. [Trusted Loader Responsibilities](05-Trusted-Loader-Responsibilities.md)
6. [Target ABI for Baseline](06-Target-ABI-for-Baseline.md)
7. [Why Not Allow `exit_group`?](07-Why-Not-Allow-Exit-Group.md)
8. [Seccomp Baseline](08-Seccomp-Baseline.md)
9. [Landlock Baseline](09-Landlock-Baseline.md)
10. [RLIMITs and Cgroups](10-RLIMITs-and-Cgroups.md)
11. [Capability Policy](11-Capability-Policy.md)
12. [Add-Back Process](12-Add-Back-Process.md)
13. [Per-Relaxation-Checklist](13-Per-Relaxation-Checklist.md)
14. [Common Add-Back Recipes](14-Common-Add-Back-Recipes.md)
15. [Negative Test Suite for Baseline](15-Negative-Test-Suite-for-Baseline.md)
16. [Project Structure](16-Project-Structure.md)
17. [Milestones](17-Milestones.md)
18. [Non-Negotiable Invariants](18-Non-Negotiable-Invariants.md)
