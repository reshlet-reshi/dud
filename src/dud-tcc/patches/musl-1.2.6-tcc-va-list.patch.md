# src/dud-tcc/patches/musl-1.2.6-tcc-va-list.patch

This note is the evidence trail for `src/dud-tcc/patches/musl-1.2.6-tcc-va-list.patch`.

The patch replaces musl 1.2.6's `__builtin_va_list` typedef template entries
with the x86_64 bootstrap `__va_list_struct` layout used by dud-tcc.

## What The Patch Does

The old init path generated `bits/alltypes.h` with musl's `mkalltypes.sed`,
then rewrote these generated lines with `awk`:

```c
typedef __builtin_va_list va_list;
typedef __builtin_va_list __isoc_va_list;
```

This patch moves the same replacement into `include/alltypes.h.in` before
`mkalltypes.sed` runs, so the generated header comes out in the TCC-compatible
form directly.

## Why It Is Literal C

`mkalltypes.sed` understands simple `TYPEDEF`, `STRUCT`, and `UNION` template
records. It does not parse array declarators as typedef names. For example, a
template record like this:

```c
TYPEDEF __va_list_struct va_list[1];
```

would generate guards for `__NEED_va_list[1]`, which is not a valid or intended
need macro.

The patch therefore uses literal guarded C blocks for `va_list` and
`__isoc_va_list`. `mkalltypes.sed` leaves those blocks unchanged while still
processing the surrounding template records.

## Expected Output

The generated `bits/alltypes.h` should match the previous `mkalltypes.sed`
plus `awk` output. This is intended as a source-organization cleanup, not a
change to the `va_list` layout, typedef names, or include guards.
