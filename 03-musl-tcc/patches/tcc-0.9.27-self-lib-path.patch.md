# 03-musl-tcc/patches/tcc-0.9.27-self-lib-path.patch

This note is the evidence trail for `03-musl-tcc/patches/tcc-0.9.27-self-lib-path.patch`.

The short version: the final bootstrap `tcc` is installed as a relocatable tree
under the caller-supplied `--install-dir`. TCC already has a `{B}` path
substitution mechanism, but upstream initializes `{B}` from `CONFIG_TCCDIR`. If
`CONFIG_TCCDIR` itself is the literal string `{B}`, then `{B}/include`,
`{B}/lib`, and `{B}/libtcc1.a` stay literal instead of becoming paths beside the
running `tcc` executable.

The patch makes that sentinel useful for the command-line compiler:

- It only activates when `CONFIG_TCCDIR` is exactly `{B}`.
- It asks Linux for the running executable path via `/proc/self/exe`.
- If that fails, it falls back to `argv[0]` only when `argv[0]` contains a
  slash.
- It strips the executable filename and calls `tcc_set_lib_path`.
- It runs before option parsing, so an explicit `-B` still overrides it.

## Upstream Path Model

In upstream TCC 0.9.27, `tcc_new()` initializes the library path like this on
non-Windows hosts:

```c
tcc_set_lib_path(s, CONFIG_TCCDIR);
```

Later, configured paths are split by `tcc_split_path()`. That function treats
`{B}` specially:

```c
if (c == 'B')
    cstr_cat(&str, s->tcc_lib_path, -1);
```

So the value of `s->tcc_lib_path` is the source of truth for all configured
`{B}` paths.

## Bootstrap Need

`03-musl-tcc/runme.sh` builds the final compiler with:

```text
-DCONFIG_TCCDIR="{B}"
-DCONFIG_TCC_CRTPREFIX="{B}/lib"
-DCONFIG_TCC_LIBPATHS="{B}/lib:{B}"
-DCONFIG_TCC_SYSINCLUDEPATHS="{B}/include"
```

The install layout is:

```text
<install-dir>/tcc
<install-dir>/include
<install-dir>/lib
<install-dir>/libtcc1.a
```

Without this patch, upstream would set `s->tcc_lib_path` to the literal string
`{B}`. Expanding `{B}/lib` would produce the literal path `{B}/lib`, not
`<install-dir>/lib`. The compiler could still be used with an explicit `-B`,
but the installed bootstrap compiler would not be self-locating.

With the patch, the installed compiler reports paths rooted at its own
directory. With a repo-local `--install-dir ./.dud/musl-tcc`, that should look
like:

```text
install: <repo>/.dud/musl-tcc
include:
  <repo>/.dud/musl-tcc/include
libraries:
  <repo>/.dud/musl-tcc/lib
  <repo>/.dud/musl-tcc
libtcc1:
  <repo>/.dud/musl-tcc/libtcc1.a
crt:
  <repo>/.dud/musl-tcc/lib
elfinterp:
  -
```

Those are the intended sibling paths for the installed `tcc`.

## Skeptical Notes

This is a bootstrap patch, not a general upstream-quality install-path design.

- `/proc/self/exe` is Linux-specific.
- The path buffer is fixed at 4096 bytes. That is practical here, but not a
  perfect general solution.
- Moving only `<install-dir>/tcc` without its sibling `include/`, `lib`, and
  `libtcc1.a` still breaks the install.
- The patch is in `tcc.c`, so it affects the command-line compiler, not libtcc
  API users.

Those limits are acceptable for this repo because the bootstrap is already a
Linux x86_64 bootstrap and installs a self-contained tree.
The patch does not replace TCC's existing path model; it supplies the missing
runtime value for the existing `{B}` substitution. Because it runs before
`tcc_parse_args()`, a user-provided `-B` remains the later, explicit override.
