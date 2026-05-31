# Core Architecture

Do **not** execute the hostile target directly with `bwrap`.

Instead use:

```text
outer supervisor
  -> bwrap sandbox
      -> trusted static loader as PID 1
          -> map hostile target bytes
          -> apply final lockdown
          -> jump into hostile code
```

a bwrap-level seccomp policy must allow `execve`.
- bwrap installs seccomp before its final `execve` call into the target.

The hostile target inherits that permission.

The trusted-loader architecture removes that hole:

```text
bwrap executes trusted loader
trusted loader maps target itself
trusted loader installs final seccomp allowlist
trusted loader jumps to target
hostile code never receives execve permission
```

Final hostile-code syscall policy can therefore be:

```text
allow:
  exit

kill:
  everything else
```

For the absolute proof baseline, make it even stricter:

```text
allow:
  exit(status == 0)

kill:
  everything else
```

For a practical runner that reports arbitrary exit codes
- allow `exit` with any status.
