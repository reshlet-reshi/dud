# src/dud-tcc/TODO.md

## Bootstrap Distribution Audit Followups

`src/dud-tcc/audit-bootstrap-tcc` currently passes with warnings only. These
are the followups worth considering.

## Easy / Worth Doing

- Normalize installed tree modes before canonical tar hashing:
  - directories: `755`
  - `tcc`: `755`
  - headers, objects, archives: `644`
  This will change the canonical hash once, then should make future tarball
  metadata cleaner.

- Fix archive member mode metadata. Check whether normalizing object modes
  before `tcc0 -ar` is enough to stop archive members from recording
  world-writable modes.

- Strip the archive index from `libtcc1.a`, matching the existing `libc.a`
  no-index shape.

- Resolve the `complex.h` mismatch. The compiler advertises
  `__STDC_NO_COMPLEX__`, but musl's `complex.h` is still installed and TCC
  cannot parse it. Options:
  - remove `complex.h` from the installed include tree
  - replace it with a small guarded diagnostic header

## Moderate / Probably Worth Doing

- Avoid truncated and duplicate visible archive member names in `libc.a`.
  TCC's ar format exposes only short member names, so long basenames truncate
  and collide. A practical fix is to stage archive inputs under short, unique
  archive-facing basenames before invoking `tcc0 -ar`.

## Harder / Separate Patch

- Emit `PT_GNU_STACK` from TCC's ELF output. This affects `tcc` itself and
  every binary it produces, so it should be a focused linker patch with tests.
