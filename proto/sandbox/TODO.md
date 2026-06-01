# sandbox TODO

Milestone 1 establishes the strict trusted-loader baseline. Keep that profile
as the regression target while adding larger capabilities.

## Milestone 2: Landlock Deny-All

- Install a deny-by-default Landlock ruleset in the loader before final seccomp.
- Handle kernels without Landlock deliberately: either fail closed in strict
  mode or report a clear unsupported status for this milestone.
- Keep the final hostile syscall policy at `exit(status == 0)` for the proof
  baseline.
- Add regression tests showing accidental path exposure does not become usable
  when filesystem syscalls are later experimented with.

## Milestone 3: Resource Controls

- Add inner loader limits immediately before hostile code:
  `RLIMIT_CORE`, `RLIMIT_FSIZE`, `RLIMIT_CPU`, `RLIMIT_AS`,
  `RLIMIT_STACK`, `RLIMIT_NPROC`, and `RLIMIT_NOFILE`.
- Add an optional `systemd-run --user` cgroup launcher that runs the wrapper
  script, not a pre-open-fd bwrap command.
- Keep the existing outer `timeout` fallback.
- Add tests for infinite loops, memory pressure, fd spam attempts, and absence
  of core dumps.

## Milestone 4: Read-Only Input

- Prefer loader-provided input memory over target path access.
- Define a tiny target ABI extension for input pointer and length.
- Keep target `open`, `read`, and filesystem access denied unless a later app
  proves it needs path-based input.
- Add negative tests for neighboring host paths and for attempts to mutate
  input memory.

## Milestone 5: Bounded Output

- Add at most one explicit output channel.
- Prefer one pre-opened output fd or pipe with a strict byte limit.
- Keep stdout/stderr discarded unless this milestone explicitly changes that.
- Constrain output size with an outer reader and/or `RLIMIT_FSIZE`.
- Add tests for successful bounded output, oversized output, wrong-fd writes,
  and continued denial of filesystem writes.

## Milestone 6: Larger App Support

- Keep the raw-blob strict baseline as a regression target.
- Add a minimal static ELF loader only after the baseline profiles are solid.
- Add controlled `mmap`/`brk` support with `RLIMIT_AS`, cgroup memory limits,
  and checks that prevent new executable writable mappings.
- Add `argv`, `envp`, and `auxv` only as specific target conventions require.
- Grow a libc-style syscall cluster cautiously, with a per-syscall add-back
  checklist and matching negative tests.
- Prefer `/proc` stubs or precomputed metadata over mounting a real `/proc`.
- Treat this milestone as the point where the project may become a
  compatibility container; keep the original deny-everything profile available.
