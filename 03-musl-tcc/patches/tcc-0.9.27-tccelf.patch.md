# 03-musl-tcc/patches/tcc-0.9.27-tccelf.patch

This note is the evidence trail for `03-musl-tcc/patches/tcc-0.9.27-tccelf.patch`.

The short version: unpatched TCC 0.9.27 can emit static x86_64
`-nostdlib` executables that still route default-visibility cross-object
references through GOT/PLT machinery. In the function case, a call reaches a
PLT entry whose GOT slot is zero. In the data case, the GOT slot should be
filled by TCC itself, but unpatched TCC calls `fill_got` after
`tidy_section_headers` has hidden the relocation sections that `fill_got`
still scans as internal metadata.

The patch has two hunks:

- Treat `R_X86_64_PLT32` relocations as direct `R_X86_64_PC32`
  relocations for static links only when the target symbol is defined and
  non-absolute. This intentionally leaves the source comment's absolute-symbol
  escape path in place.
- Move only the static executable `fill_got` call before
  `tidy_section_headers`, so static executable GOT slots are filled while
  relocation sections are still in TCC's section list. The dynamic
  `fill_local_got_entries` call stays after `tidy_section_headers`.

## Inputs And Tool Versions

The reproduction is rooted in these two tarballs:

```text
MUSL_CC_TARBALL  02-musl-cc/x86_64-linux-musl-native.tgz
TCC_TARBALL      vendor/tcc-0.9.27.tar.bz2
```

Hashes observed in the local investigation:

```text
eb1db6f0f3c2bdbdbfb993d7ef7e2eeef82ac1259f6a6e1757c33a97dbcef3ad  02-musl-cc/x86_64-linux-musl-native.tgz
de23af78fca90ce32dff2dd45b3432b2334740bb9bb7b05bf60fdbfc396ceb9c  vendor/tcc-0.9.27.tar.bz2
5fc861bb9761f097fea129cde479c876a6e31acdffbc428a3038a0c1cc6294d4  03-musl-tcc/patches/tcc-0.9.27-tccelf.patch
```

Tool versions used to regenerate the traces below:

```text
tar (GNU tar) 1.35
gzip 1.14
bzip2, a block-sorting file compressor.  Version 1.0.8, 13-Jul-2019.
sha256sum (uutils coreutils) 0.8.0
mktemp (uutils coreutils) 0.8.0
sed (GNU sed) 4.9
GNU gdb (Ubuntu 17.1-2ubuntu1) 17.1
GNU readelf (GNU Binutils for Ubuntu) 2.46
GNU objdump (GNU Binutils for Ubuntu) 2.46
GNU patch 2.8
file-5.46
gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0
x86_64-linux-musl-gcc (GCC) 11.2.1 20211120
```

The local system `gcc` version is recorded for context. The `tcc0` binary used
for the investigation was built with the vendored `x86_64-linux-musl-gcc`.

## Standalone tcc0 Build Script

This script builds the unpatched host `tcc0` used by the reproducer. It is
project-neutral: provide the two tarball paths and it writes only under
`${TMPDIR:-/tmp}`.

```sh
#!/bin/sh
set -eu

: "${TCC_TARBALL:?set TCC_TARBALL=/path/to/tcc-0.9.27.tar.bz2}"
: "${MUSL_CC_TARBALL:?set MUSL_CC_TARBALL=/path/to/02-musl-cc/x86_64-linux-musl-native.tgz}"

work=$(mktemp -d "${TMPDIR:-/tmp}/tccelf-repro.XXXXXX")
printf 'work=%s\n' "$work"

printf '== input hashes ==\n'
sha256sum "$MUSL_CC_TARBALL" "$TCC_TARBALL"

printf '\n== unpack tools ==\n'
tar --version | sed -n '1p'
gzip --version | sed -n '1p'
bzip2 --version 2>&1 | sed -n '1p'

tar -xzf "$MUSL_CC_TARBALL" -C "$work"
tar -xjf "$TCC_TARBALL" -C "$work"

musl_cc=$work/x86_64-linux-musl-native
tcc_src=$work/tcc-0.9.27
tcc0=$work/tcc0

: > "$tcc_src/config.h"

printf '\n== vendored compiler ==\n'
"$musl_cc/bin/x86_64-linux-musl-gcc" --version | sed -n '1p'

(
    cd "$tcc_src"
    "$musl_cc/bin/x86_64-linux-musl-gcc" -g3 -O0 -w \
        -static \
        -I . \
        -o "$tcc0" \
        -DTCC_TARGET_X86_64=1 \
        -DCONFIG_TCCBOOT=1 \
        '-DCONFIG_TCCDIR=""' \
        '-DCONFIG_TCC_CRTPREFIX=""' \
        '-DCONFIG_TCC_LIBPATHS=""' \
        '-DCONFIG_TCC_SYSINCLUDEPATHS=""' \
        -DCONFIG_TCC_STATIC=1 \
        '-DTCC_VERSION="0.9.27"' \
        -DONE_SOURCE=1 \
        tcc.c
)

printf '\ntcc0=%s\n' "$tcc0"
```

The investigation run used the same command shape. Its host compiler was a
statically linked executable from the musl toolchain tarball:

```text
x86_64-linux-musl-gcc (GCC) 11.2.1 20211120
.../x86_64-linux-musl-native/bin/x86_64-linux-musl-gcc: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped
```

## Synthetic Tests

The test programs deliberately avoid libc and exit through the Linux x86_64
`exit` syscall.

```c
/* baseline.c */
void _start(void) {
    __asm__(
        "mov $60, %rax\n"
        "xor %rdi, %rdi\n"
        "syscall\n"
    );
}
```

```c
/* func-default-start.c */
extern long foo(long);
void _start(void) {
    long x = foo(41);
    __asm__(
        "mov $60, %%rax\n"
        "mov %0, %%rdi\n"
        "syscall\n"
        : : "r"(x) : "rax", "rdi"
    );
}

/* func-default-foo.c */
long foo(long x) { return x + 1; }
```

```c
/* data-default-start.c */
extern long x;
void _start(void) {
    long y = x;
    __asm__(
        "mov $60, %%rax\n"
        "mov %0, %%rdi\n"
        "syscall\n"
        : : "r"(y) : "rax", "rdi"
    );
}

/* data-default-data.c */
long x = 42;
```

The hidden variants are the same tests with
`__attribute__((visibility("hidden")))` on the declaration and definition.

Commands:

```sh
"$tcc0" -static -nostdlib baseline.c -o baseline
"$tcc0" -static -nostdlib func-default-start.c func-default-foo.c -o func-default
"$tcc0" -static -nostdlib func-hidden-start.c func-hidden-foo.c -o func-hidden
"$tcc0" -static -nostdlib data-default-start.c data-default-data.c -o data-default
"$tcc0" -static -nostdlib data-hidden-start.c data-hidden-data.c -o data-hidden
"$tcc0" -static -nostdlib -g data-default-start.c data-default-data.c -o data-default-g
"$tcc0" -static -nostdlib -g data-hidden-start.c data-hidden-data.c -o data-hidden-g
```

Unpatched result matrix:

```text
compile=baseline status=0
run=baseline status=0

compile=func-default status=0
run=func-default status=139

compile=func-hidden status=0
run=func-hidden status=42

compile=func-samefile status=0
run=func-samefile status=139

compile=data-default status=0
run=data-default status=139

compile=data-hidden status=0
run=data-hidden status=139

compile=data-default-g status=0
run=data-default-g status=42

compile=data-hidden-g status=0
run=data-hidden-g status=42
```

Patched spot-check using the exact patch hash above:

```text
patched_compile=baseline status=0
patched_run=baseline status=0

patched_compile=func-default status=0
patched_run=func-default status=42

patched_compile=func-hidden status=0
patched_run=func-hidden status=42

patched_compile=func-samefile status=0
patched_run=func-samefile status=42

patched_compile=data-default status=0
patched_run=data-default status=42

patched_compile=data-hidden status=0
patched_run=data-hidden status=42

patched_compile=data-default-g status=0
patched_run=data-default-g status=42

patched_compile=data-hidden-g status=0
patched_run=data-hidden-g status=42
```

## Bug 1: Static Calls Routed Through PLT

The unpatched static function-call failure looks like this:

```text
static -nostdlib executable

  _start
    |
    | call foo
    v
  .plt entry for foo
    |
    | jmp *.got[foo]
    v
  0x0000000000000000
    |
    v
  SIGSEGV at RIP=0
```

The key fact is that `foo` is defined in the same final executable, but
unpatched TCC still creates a PLT entry because the symbol is global,
default-visibility, and the x86_64 special-case only direct-relocates
non-default or local symbols.

Compiler-side GDB trace:

```text
HIT build_got_entries static=1 nostdlib=1 do_debug=0 nb_sections=10 got=(nil) plt=(nil)
HIT put_got_entry dyn_reloc_type=7 sym_index=3 name=foo bind=1 type=2 vis=0 shndx=1 got=0x7ffff7e71420 plt=(nil)
HIT final_sections_reloc static=1 nostdlib=1 do_debug=0 nb_sections=14 got=0x7ffff7e71420 plt=0x7ffff7e71540
HIT tidy_section_headers entry static=1 do_debug=0 nb_sections=14
  rela-before[6] name=. sh_name=0 flags=0x0 info=1
  rela-before[11] name=. sh_name=0 flags=0x0 info=10
HIT fill_got entry static=1 do_debug=0 nb_sections=10 got=0x7ffff7e71420 plt=0x7ffff7e71540
```

`dyn_reloc_type=7` is TCC's `R_JMP_SLOT` path. The symbol fields decode as:

```text
name=foo
bind=1  STB_GLOBAL
type=2  STT_FUNC
vis=0   STV_DEFAULT
```

Executable-side GDB trace:

```text
Program received signal SIGSEGV, Segmentation fault.
0x0000000000000000 in ?? ()
Program stopped at 0x0.
It stopped with signal SIGSEGV, Segmentation fault.
rip            0x0                 0x0
rax            0x29                41
rdi            0x29                41
#0  0x0000000000000000 in ?? ()
#1  0x00000000004000cd in ?? ()

   0x4000c8: call   0x400110
   0x4000cd: mov    %rax,-0x8(%rbp)
   ...
   0x4000e3: push   %rbp
   0x4000e4: mov    %rsp,%rbp
   ...
   0x4000f6: add    $0x1,%rax
   0x4000fb: ret
   ...
   0x400110: jmp    *0x18(%rip)        # 0x40012e
   0x400116: push   $0x1
   0x40011b: jmp    0x400100

-- got memory --
0x600120: 0x0000000000000000 0x0000000000000000
0x600130: 0x0000000000000000 0x0000000000000000
```

The interesting part is visible in the same disassembly: the real `foo` body
exists in `.text` at `0x4000e3`, but `_start` calls `0x400110`, the PLT entry.
With no dynamic loader participating in this static `-nostdlib` executable, the
GOT slot remains zero.

## Bug 2: `fill_got` Runs After Its Metadata Was Hidden

The unpatched static data-reference failure is related, but not identical.
There is no `.plt` here. The bad path is:

```text
unpatched order:

  final_sections_reloc
    |
    v
  tidy_section_headers
    |
    | removes unnamed relocation sections from the active output list
    v
  fill_got
    |
    | scans s1->sections looking for SHT_RELX sections
    | finds none relevant
    v
  .got[x] remains 0
    |
    v
  _start loads 0 from GOT, then dereferences 0
    |
    v
  SIGSEGV
```

Compiler-side GDB trace without `-g`:

```text
HIT build_got_entries static=1 nostdlib=1 do_debug=0 nb_sections=10 got=(nil) plt=(nil)
HIT put_got_entry dyn_reloc_type=6 sym_index=3 name=x bind=1 type=1 vis=0 shndx=2 got=0x7ffff7e71660 plt=(nil)
HIT final_sections_reloc static=1 nostdlib=1 do_debug=0 nb_sections=13 got=0x7ffff7e71660 plt=(nil)
HIT tidy_section_headers entry static=1 do_debug=0 nb_sections=13
  rela-before[6] name=. sh_name=0 flags=0x0 info=1
  rela-before[11] name=. sh_name=0 flags=0x0 info=10
HIT fill_got entry static=1 do_debug=0 nb_sections=9 got=0x7ffff7e71660 plt=(nil)
```

Notice the drop from `nb_sections=13` to `nb_sections=9`. There are relocation
sections before `tidy_section_headers`, but the later `fill_got` trace has no
`rela-at-fill_got[...]` lines and no `fill_got_entry` hit.

Executable-side GDB trace:

```text
Program received signal SIGSEGV, Segmentation fault.
0x00000000004000c2 in ?? ()
Program stopped at 0x4000c2.
It stopped with signal SIGSEGV, Segmentation fault.
rip            0x4000c2            0x4000c2
rax            0x0                 0
rdi            0x0                 0

   0x4000bb: mov    0x20003e(%rip),%rax        # 0x600100
=> 0x4000c2: mov    (%rax),%rax
   0x4000c5: mov    %rax,-0x8(%rbp)

-- got memory --
0x6000e8: 0x0000000000000000 0x0000000000000000
0x6000f8: 0x0000000000000000 0x0000000000000000
```

The first load reads a GOT slot, which should contain the address of `x`. It
contains zero, so the second load dereferences address zero.

## The Interesting `-g` Mask

Compiling the data repro with `tcc -g` can mask the second bug:

```text
without -g:
  run=data-default status=139
  run=data-hidden status=139

with -g:
  run=data-default-g status=42
  run=data-hidden-g status=42
```

The GDB trace explains why. With `-g`, `s1->do_debug` is set, the section list
still has relocation sections when `fill_got` runs, and `fill_got_entry` fires:

```text
HIT build_got_entries static=1 nostdlib=1 do_debug=1 nb_sections=13 got=(nil) plt=(nil)
HIT put_got_entry dyn_reloc_type=6 sym_index=4 name=x bind=1 type=1 vis=0 shndx=2 got=0x7ffff7e71300 plt=(nil)
HIT final_sections_reloc static=1 nostdlib=1 do_debug=1 nb_sections=16 got=0x7ffff7e71300 plt=(nil)
HIT tidy_section_headers entry static=1 do_debug=1 nb_sections=16
  rela-before[8] name=. sh_name=49 flags=0x0 info=6
  rela-before[9] name=. sh_name=60 flags=0x0 info=1
  rela-before[14] name=. sh_name=115 flags=0x0 info=13
HIT fill_got entry static=1 do_debug=1 nb_sections=16 got=0x7ffff7e71300 plt=(nil)
  rela-at-fill_got[12] name=. sh_name=49 flags=0x0 info=10
  rela-at-fill_got[13] name=. sh_name=60 flags=0x0 info=1
  rela-at-fill_got[14] name=. sh_name=115 flags=0x0 info=6
HIT fill_got_entry rtype=9 sym_index=4 offset=0xe
```

That is why the bootstrap host `tcc0` is built with debug info for
investigation, but the synthetic output tests still need no-`-g` cases. If
every repro executable is built with `tcc -g`, the GOT ordering bug can appear
to vanish.

## Minimality Checks

A follow-up run on 2026-05-25 tested variants under
`/tmp/tccgot-plan.1pHU9u` from fresh `vendor/tcc-0.9.27.tar.bz2`
extracts. The host
`tcc0` binaries were built with the local system compiler:

```text
gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0
GNU readelf (GNU Binutils for Ubuntu) 2.46
GNU objdump (GNU Binutils for Ubuntu) 2.46
```

The split-hunk results were:

```text
variant=upstream
  func-default run=139
  func-samefile run=139
  data-default run=139
  data-hidden run=139

variant=hunk1-only
  func-default run=42
  func-samefile run=42
  data-default run=139
  data-hidden run=139

variant=hunk2-static-fill-only
  func-default run=139
  func-samefile run=139
  data-default run=42
  data-hidden run=42

variant=narrowed-final
  baseline run=0
  func-default run=42
  func-hidden run=42
  func-samefile run=42
  data-default run=42
  data-hidden run=42
  data-default-g run=42
  data-hidden-g run=42
  undef-strong compile=1
  undef-weak-func run=77
  undef-weak-data run=77
```

A dynamic `-nostdlib` baseline was also attempted with both the empty
bootstrap interpreter setting and `/lib64/ld-linux-x86-64.so.2`. In this
`CONFIG_TCCBOOT` build, `tcc0` segfaulted before producing the output for all
tested variants, including unpatched upstream. That result is not used as
evidence for or against this patch; the narrowed patch intentionally leaves the
dynamic `fill_local_got_entries` ordering on its original side of
`tidy_section_headers`.

This is why the final patch keeps both fixes, but narrows them:

- The function failure needs an x86_64 `R_X86_64_PLT32` direct-relocation
  rule for static links.
- The data failure needs static `fill_got` before `tidy_section_headers`.
- The dynamic/local-GOT path does not need to be moved for these failures.

The static data executable still has zero words in `.got`, but those include
TCC's reserved `_DYNAMIC` and dummy GOT entries. The meaningful slot was filled:

```text
Contents of section .got:
 6000e8 00000000 00000000 00000000 00000000  ................
 6000f8 00000000 00000000 e0006000 00000000  ..........`.....
```

`0x6000e0` is the address of `x` in `.data`.

## Far Absolute Symbol Probe

The source comment near `AUTO_GOTPLT_ENTRY` says absolute symbols, probably
created by `tcc_add_symbol`, may be too far from application code on 64-bit
targets. The broad version of this patch violated that warning by direct
relocating every static `R_X86_64_PLT32`/`R_X86_64_PC32`.

The targeted probe used an absolute function symbol at address zero and moved
`.text` above the signed 32-bit PC-relative window:

```c
__asm__(".globl far_abs_func\n.set far_abs_func,0\n");
extern long far_abs_func(long);
void _start(void) {
    long x = far_abs_func(41);
    __asm__(
        "mov $60, %%rax\n"
        "mov %0, %%rdi\n"
        "syscall\n"
        : : "r"(x) : "rax", "rdi"
    );
}
```

Command shape:

```sh
tcc0 -static -nostdlib -Wl,-Ttext=90000000 abs-func.c -o abs-func-hightext
```

Observed results:

```text
upstream compile=0 run=139 static=.plt yes got slot zero
broad-static-link-patch compile=1 error="internal error: relocation failed"
narrowed-final compile=0 run=139 static=.plt yes got slot zero
```

The broad patch's failure confirms the source comment is a real hazard: an
absolute symbol can be outside PC-relative range. The narrowed patch avoids
introducing that new link failure by excluding `SHN_ABS` and `SHN_UNDEF` from
the static direct-call rule.

This does not mean upstream TCC handles absolute function calls usefully in
static `-nostdlib` executables. In the upstream and narrowed cases, the call is
routed through `.plt` and reaches a zero GOT slot:

```text
90000018: e8 2b 00 00 00        call   0x90000048
...
90000048: ff 25 18 00 00 00     jmp    *0x18(%rip)

Contents of section .got:
 90200058 00000000 00000000 00000000 00000000
 90200068 00000000 00000000 00000000 00000000
```

So the narrowed rule is a conservative bootstrap fix, not a general repair for
absolute function symbols. It fixes defined non-absolute symbols from the final
executable and leaves the existing absolute-symbol behavior unchanged.

An attempted scalar absolute-data test:

```c
__asm__(".globl far_abs_data\n.set far_abs_data,0x100000000\n");
extern long far_abs_data;
unsigned long y = (unsigned long)&far_abs_data;
```

was rejected by TCC with `lvalue expected`. An array-shaped variant compiled,
but did not produce a useful nonzero GOT-slot proof, so it is not used as
evidence for this patch.

## Static Output Diagnostics

This is not practical to fix in CRT. CRT starts after control has already
passed through `_start`; it also lacks TCC's relocation metadata, so it cannot
reconstruct which GOT/PLT entries were intended to point at which symbols.

A lightweight post-link diagnostic for this class of failure is:

```sh
readelf -l "$exe" | grep -q INTERP && dynamic=yes || dynamic=no
readelf -S "$exe" | grep -q ' .plt ' && has_plt=yes || has_plt=no
objdump -s -j .got "$exe"
objdump -d -j .plt "$exe"
```

For static bootstrap executables, `dynamic=no` plus `has_plt=yes` is suspicious
because no dynamic loader will fill PLT GOT slots. For data GOT checks, ignore
TCC's first three reserved pointer-sized GOT words; a zero after that is the
interesting failure signal.

## Standards Breadcrumbs

These are not the proof by themselves; the traces above are the proof. The
standards explain why the traces are bad.

- AMD64 psABI relocation table:
  <https://www.ucw.cz/~hubicka/papers/abi/node19.html>

  `R_X86_64_PC32` calculates `S + A - P`, while `R_X86_64_PLT32` calculates
  `L + A - P`. The same table gives `R_X86_64_GOTPCREL` as
  `G + GOT + A - P`.

- AMD64 psABI dynamic linking:
  <https://www.ucw.cz/~hubicka/papers/abi/node22.html>

  Short quote: "procedure linkage table redirects position-independent
  function calls". The same section says the dynamic linker modifies the GOT
  memory image to point PLT calls at their final destinations.

- ELF gABI dynamic linking:
  <https://refspecs.linuxfoundation.org/elf/gabi4+/ch5.dynamic.html>

  Short quote: "Performing relocations for the executable file". The point for
  this bug: that actor is absent in a static `-nostdlib` executable.

- ELF gABI symbol table:
  <https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.symtab.html>

  Short quote: "Global symbols are visible to all object files being combined."
  In dynamic-linking contexts, default global symbols are exactly the ones TCC
  tries to preserve through PLT/GOT machinery.

- ELF gABI relocation:
  <https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.reloc.html>

  Short quote: "A relocation section references two other sections". The two
  relationships are the symbol table and the section to modify.

- ELF gABI section headers:
  <https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.sheader.html>

  `SHT_REL` and `SHT_RELA` are relocation sections. The `sh_link`/`sh_info`
  table says relocation sections link to the associated symbol table and the
  section to which the relocation applies.

## Trace Appendix

All paths below are from one fresh `/tmp` run. The directory name is
normalized here; the real run used an equivalent `mktemp -d` directory.

```text
work=/tmp/tccelf-repro.SGHYtF
tcc0=/tmp/tccelf-repro.SGHYtF/tcc0
```

### Build Command

```text
== vendored compiler ==
x86_64-linux-musl-gcc (GCC) 11.2.1 20211120

== build command ==
cd "$tcc_src"
"$musl_cc/bin/x86_64-linux-musl-gcc" -g3 -O0 -w -static -I . -o "$tcc0" \
    -DTCC_TARGET_X86_64=1 \
    -DCONFIG_TCCBOOT=1 \
    '-DCONFIG_TCCDIR=""' \
    '-DCONFIG_TCC_CRTPREFIX=""' \
    '-DCONFIG_TCC_LIBPATHS=""' \
    '-DCONFIG_TCC_SYSINCLUDEPATHS=""' \
    -DCONFIG_TCC_STATIC=1 \
    '-DTCC_VERSION="0.9.27"' \
    -DONE_SOURCE=1 \
    tcc.c
build_status=0
```

### GDB Commands Used

Compiler trace:

```sh
gdb -q -batch -x tcc-compile.gdb --args "$tcc0" \
    -static -nostdlib func-default-start.c func-default-foo.c -o func-default-gdb
gdb -q -batch -x tcc-compile.gdb --args "$tcc0" \
    -static -nostdlib data-default-start.c data-default-data.c -o data-default-gdb
gdb -q -batch -x tcc-compile.gdb --args "$tcc0" \
    -static -nostdlib -g data-default-start.c data-default-data.c -o data-default-gdb-with-debug
```

Executable trace:

```sh
gdb -q -batch -x run-exe.gdb func-default
gdb -q -batch -x run-exe.gdb data-default
```

The compiler GDB script set breakpoints on:

```text
build_got_entries
put_got_entry
final_sections_reloc
tidy_section_headers
fill_got
fill_got_entry
```

### Section And Disassembly Evidence

Function case section table excerpt:

```text
There are 10 section headers, starting at offset 0x190:

[Nr] Name              Type             Address           Offset
[ 1] .text             PROGBITS         00000000004000b0  000000b0
     000000000000004c  0000000000000000  AX       0     0     8
[ 5] .plt              PROGBITS         0000000000400100  00000100
     0000000000000020  0000000000000004  AX       0     0     8
[ 7] .got              PROGBITS         0000000000600120  00000120
     0000000000000020  0000000000000004  WA       0     0     8
```

Function case disassembly excerpt:

```text
Disassembly of section .text:

00000000004000b0 <.text>:
  4000bb: 48 b8 29 00 00 00 00  movabs $0x29,%rax
  4000c5: 48 89 c7              mov    %rax,%rdi
  4000c8: e8 43 00 00 00        call   0x400110
  4000cd: 48 89 45 f8           mov    %rax,-0x8(%rbp)
  ...
  4000e3: 55                    push   %rbp
  4000e4: 48 89 e5              mov    %rsp,%rbp
  4000f6: 48 83 c0 01           add    $0x1,%rax
  4000fb: c3                    ret

Disassembly of section .plt:

0000000000400100 <.plt>:
  400100: ff 35 08 00 00 00     push   0x8(%rip)        # 0x40010e
  400106: ff 25 10 00 00 00     jmp    *0x10(%rip)        # 0x40011c
  400110: ff 25 18 00 00 00     jmp    *0x18(%rip)        # 0x40012e
  400116: 68 01 00 00 00        push   $0x1
  40011b: e9 e0 ff ff ff        jmp    0x400100
```

Data case section table excerpt:

```text
There are 9 section headers, starting at offset 0x150:

[Nr] Name              Type             Address           Offset
[ 1] .text             PROGBITS         00000000004000b0  000000b0
     000000000000002b  0000000000000000  AX       0     0     8
[ 5] .data             PROGBITS         00000000006000e0  000000e0
     0000000000000008  0000000000000000  WA       0     0     8
[ 6] .got              PROGBITS         00000000006000e8  000000e8
     0000000000000020  0000000000000004  WA       0     0     8
```

Data case disassembly excerpt:

```text
Disassembly of section .text:

00000000004000b0 <.text>:
  4000bb: 48 8b 05 3e 00 20 00  mov    0x20003e(%rip),%rax        # 0x600100
  4000c2: 48 8b 00              mov    (%rax),%rax
  4000c5: 48 89 45 f8           mov    %rax,-0x8(%rbp)
  4000cd: 48 c7 c0 3c 00 00 00  mov    $0x3c,%rax
  4000d4: 48 89 cf              mov    %rcx,%rdi
  4000d7: 0f 05                 syscall
```
