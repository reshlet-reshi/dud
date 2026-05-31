# Why Not Allow `exit_group`?

For the baseline, only `exit` is needed.

```text
exit
  terminates the calling thread

exit_group
  terminates the whole thread group
```

Since the final seccomp denies 

- `clone`, 
- `clone3`, 
- `fork`, 
- and `vfork`, 

hostile code cannot create threads. 

Therefore:

```text
single-threaded raw blob -> allow exit only
```

Allow `exit_group` only if later target conventions require it. 

> such as libc-style process termination.
