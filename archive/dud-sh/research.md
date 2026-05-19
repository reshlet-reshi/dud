# Research Report on AGENTS Policy for `dud` and `dud-sh`

Standalone markdown edition with ordinary inline citation links.

Citation note: this version replaces the deep-research UI citation tokens with normal markdown links. Citations to the uploaded project handoff point to the companion file [`prompt.md`](prompt.md); external citations point directly to their public source URLs.

## 1. Executive summary

I treated the attached handoff as the governing brief for repo identity, settled constraints, owner priorities, current `dud-sh` subset, the proposed layout, and the `patch-elf`-first bootstrap ladder. This report does not try to reopen choices the handoff already marks as decided; it focuses on the remaining policy decisions that matter most for a future `AGENTS.md`. Source basis: [`prompt.md`](prompt.md).

My strongest recommendation is a **literate, conformance-first, portability-preserving policy**: keep shared bootstrap source in a tiny shell-hosted `dud-sh` subset; use **POSIX-portable octal byte emission in source** while allowing **hex in comments and docs**; split **shared `.dsh` files** from **host-only `.sh` helpers**; treat root `.bin/` as generated native outputs and root `.tmp/` as scratch; use a **Python-stdlib test runner** as the canonical conformance harness; and keep `exec`, FD tricks, general quoting, and most shell features **reserved but out of scope**. That package best matches the project’s stated priorities of correctness, low hidden host-dependency risk, easy conformance testing, future non-shell hosts, and auditable provenance. It also fits the lineage of bootstrappable systems that favor explicit provenance and tiny, comprehensible stages, including [Bootstrappable Builds](https://www.bootstrappable.org/), [live-bootstrap](https://github.com/fosslinux/live-bootstrap/blob/master/README.rst), [live-bootstrap `parts.rst`](https://github.com/fosslinux/live-bootstrap/blob/master/parts.rst), [Mu](https://github.com/akkartik/mu), [Akkartik’s Mu notes](https://akkartik.name/post/mu-2019-1), and [SectorLISP](https://github.com/jart/sectorlisp).

The single largest hidden trap is **hex escapes in `printf`**. POSIX requires octal escapes for the `printf` utility but does **not** require `\xNN`; GNU `printf` supports `\xHH`, but a common `/bin/sh` implementation, `dash`, documents octal escapes while omitting `\x`, and its builtin `printf` is therefore not a safe foundation for shared shell-hosted bootstrap source. A close second trap is pretending that `/bin/sh` is “the POSIX standard shell path”: POSIX explicitly says portable applications cannot assume the standard shell lives at `/bin/sh` or `/usr/bin/sh`, so requiring `/bin/sh` is a **deliberate project host constraint**, not a portable fact. Sources: [POSIX `printf(1p)`](https://man7.org/linux/man-pages/man1/printf.1p.html), [dash(1)](https://man7.org/linux/man-pages/man1/dash.1.html), [GNU Coreutils `printf`](https://www.gnu.org/software/coreutils/manual/html_node/printf-invocation.html), and [POSIX `sh(1p)`](https://man7.org/linux/man-pages/man1/sh.1p.html).

## 2. Assumptions and source basis

The following assumptions are inherited from the handoff rather than re-argued here:

- root project: `dud`
- first subproject: `dud-sh`
- internal/prototype shorthand: `dsh`
- later tools: `dud-asm`, then maybe `dud-cc`
- current target: `i386-linux-elf`
- first native artifact: `patch-elf`
- first modular artifact: `patch-elf-modular`
- current shared source host: `/bin/sh`-compatible syntax with only `printf`, `chmod`, and explicit-path project executables allowed
- current language subset: `set -e`, `set --`, `.`, `:`, `printf`, `chmod +x`, explicit-path commands, `>`/`>>`, `$1`…`$9`, `"$1"`…`"$9"`, and whole-line comments only

Source: [`prompt.md`](prompt.md).

The most important external sources consulted were standards/manpage materials for shell, `printf`, `chmod`, `set`, and dot-sourcing; bootstrapping projects; ELF materials; i386/syscall provenance sources; QEMU user-mode docs; modern `AGENTS.md` docs; and 0BSD license sources. Key sources include [POSIX `printf`](https://man7.org/linux/man-pages/man1/printf.1p.html), [POSIX `chmod`](https://man7.org/linux/man-pages/man1/chmod.1p.html), [POSIX `set`](https://man7.org/linux/man-pages/man1/set.1p.html), [POSIX `.`](https://man7.org/linux/man-pages/man1/dot.1p.html), [POSIX `sh`](https://man7.org/linux/man-pages/man1/sh.1p.html), [The Open Group Shell Command Language](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html), [ELF gABI header](https://gabi.xinuos.com/elf/02-eheader.html), [ELF gABI program header](https://gabi.xinuos.com/elf/07-pheader.html), [`elf(5)`](https://man7.org/linux/man-pages/man5/elf.5.html), [Intel SDM](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html), [ChromiumOS syscall constants](https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/), [QEMU user-mode docs](https://www.qemu.org/docs/master/user/main.html), [QEMU user guide mirror](https://qemu-project.gitlab.io/qemu/user/index.html), [GitHub Copilot custom instructions](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot), [OpenAI Codex `AGENTS.md` guide](https://developers.openai.com/codex/guides/agents-md), [OSI 0BSD](https://opensource.org/license/0bsd), and [SPDX 0BSD](https://spdx.org/licenses/0BSD.html).

## 3. Proposed answer sets

### Set A — Portable octal core

**What it optimizes for:** wide real-world `/bin/sh` compatibility, low hidden host-dependency risk, and a clean future path to non-shell `dud-sh` implementations.

**Policy shape:** shared source emits bytes using POSIX `printf` escapes, mostly octal. Comments and docs may show hex. Shared files use `.dsh`; host-only helpers use `.sh`. Dot-sourced files must use explicit slash paths such as `. ./lib/foo.dsh`, not `. foo`, because POSIX dot-sourcing searches `PATH` when the operand contains no slash. Source: [POSIX dot utility](https://man7.org/linux/man-pages/man1/dot.1p.html).

**Test posture:** byte-first conformance tests, exact exit status, exact stdout bytes, stderr text not normative. Native i386 execution is optional. QEMU user-mode is allowed as an optional smoke-test helper, not a core requirement. Sources: [QEMU user-mode docs](https://www.qemu.org/docs/master/user/main.html) and [QEMU user guide mirror](https://qemu-project.gitlab.io/qemu/user/index.html).

**Sacrifice:** less pleasant byte authoring if the author thinks in hex first. Octal is uglier for opcodes and ELF fields.

**Why it fits:** it best matches the owner’s preference for correctness, conformance testing, hidden dependency avoidance, and future non-shell hosts. Source: [`prompt.md`](prompt.md).

**Risk:** octal source can be harder to audit by humans.

**Mitigation:** require comments/docs to show hex equivalents for opaque byte sequences and require logical `printf` units rather than byte-per-line sludge.

### Set B — GNU-ish hex velocity

**What it optimizes for:** early authoring speed and source readability for humans accustomed to hex byte streams.

**Policy shape:** shared source may use `\xNN`, and the project explicitly narrows its host contract to `printf` implementations that support GNU-style hex escapes. AGENTS would require a fail-fast host check before bootstrap work proceeds.

**Sacrifice:** POSIX portability. POSIX `printf` guarantees octal escapes but not `\x`; GNU `printf` documents `\xHH`; `dash` documents octal escapes and does not advertise `\x`. Sources: [POSIX `printf`](https://man7.org/linux/man-pages/man1/printf.1p.html), [GNU Coreutils `printf`](https://www.gnu.org/software/coreutils/manual/html_node/printf-invocation.html), and [dash(1)](https://man7.org/linux/man-pages/man1/dash.1.html).

**Why it conflicts:** it weakens the stated preference to avoid hidden host dependencies. If the project really wants this mode, AGENTS must say so bluntly: this is not “plain POSIX”; it is “common GNU-ish host profile.” Source: [`prompt.md`](prompt.md).

**Risk:** casual use of `printf '\x..'` makes later portability fixes painful because byte fragments become saturated with non-portable syntax.

**Mitigation:** keep Set B as an explicitly named profile, not the default. Add tests that reject hosts lacking `\x` support before running stage-0 scripts.

### Set C — Tiny-kernel purity

**What it optimizes for:** preventing `dud-sh` from drifting into a small-but-still-general shell.

**Policy shape:** keep the current allowlist brutally small, avoid `exec`, FD redirection, `$0`, `$#`, `shift`, functions, pipelines, variables, loops, tests, command substitution, and generalized quoting. Future features are named only as reserved and ask-first. The tokenizer remains “newline-separated commands, whitespace-separated tokens”; extra interpretation belongs to commands, not the file parser. Source: [`prompt.md`](prompt.md).

**Sacrifice:** less ergonomic composition and fewer conveniences for later stages. Some useful shell-shaped affordances, especially FD output via `exec`, remain unavailable until a future milestone.

**Why it fits:** it is excellent for future native interpreter implementations and for maintaining a crisp conformance suite.

**Risk:** too little documentation or ergonomics may make the source tree feel like a private puzzle rather than a learnable bootstrap.

**Mitigation:** combine Tiny-kernel purity with literate docs, not with terse obscurity.

### Set D — Literate conformance-first

**What it optimizes for:** correctness, learning value, future independent implementations, and auditability.

**Policy shape:** Set A portability plus stronger headers, concept-first docs, a canonical conformance runner, and layered root/nested `AGENTS.md` instructions. This is the recommended default.

The style is close to the pattern visible in [SectorLISP](https://github.com/jart/sectorlisp), which pairs a tiny native artifact with a readable reference implementation, and in [Mu](https://github.com/akkartik/mu), which repeatedly emphasizes small surface area and comprehensibility. It also fits modern agent tooling: both [GitHub Copilot custom instructions](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot) and [OpenAI Codex `AGENTS.md`](https://developers.openai.com/codex/guides/agents-md) support repo-local instruction files, with nearest/local files affecting agent behavior.

**Sacrifice:** slightly more initial process and documentation overhead.

**Why it fits:** it best serves the owner priorities in the handoff: technical correctness, fast iteration through clean tests, simplicity, learning, maintainability, and low dependency risk. Source: [`prompt.md`](prompt.md).

**Risk:** the docs can become heavier than the bootstrap.

**Mitigation:** keep AGENTS compact; put long explanations in concept docs; link from source using repo-local references.

## 4. Decision matrix

| Set | Correctness | Bootstrap coherence | POSIX portability | Initial speed | Simplicity | Learnability | Maintainability | Future host ease | Conformance clarity | Hidden-dep risk | Full-shell creep risk |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| A: Portable octal core | High | High | Very high | Medium | High | Medium | High | High | High | Very low | Low |
| B: GNU-ish hex velocity | Medium | Medium | Low | High | Medium | High | Medium | Medium | Medium | High | Medium |
| C: Tiny-kernel purity | High | High | Very high | Medium | Very high | Medium | High | Very high | High | Very low | Very low |
| D: Literate conformance-first | Very high | Very high | Very high | Medium | Medium | Very high | Very high | Very high | Very high | Very low | Low |

The only surprising score is that Set D is not “simplest” despite being the recommended default. It is not the minimum-process answer; it is the best answer for a repo whose output should be read, reimplemented, audited, and extended without accidentally becoming a shell.

## 5. Recommended default set

I recommend **Set D: Literate conformance-first**, with the slogan:

> portable source, explicit docs, exact bytes, tiny language.

That recommendation follows from the owner’s priority order in the handoff, from the portability constraints around `printf`, from the complexity of real shell parsing, from the loader-facing reality of ELF program headers, and from modern agent tooling that supports layered local instruction files. Sources: [`prompt.md`](prompt.md), [POSIX `printf`](https://man7.org/linux/man-pages/man1/printf.1p.html), [dash(1)](https://man7.org/linux/man-pages/man1/dash.1.html), [Morbig POSIX-shell parser paper](https://www.niols.fr/paper/Jeannerod%2B17a.pdf), [ELF gABI program header](https://gabi.xinuos.com/elf/07-pheader.html), [`elf(5)`](https://man7.org/linux/man-pages/man5/elf.5.html), [GitHub Copilot custom instructions](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot), and [OpenAI Codex `AGENTS.md`](https://developers.openai.com/codex/guides/agents-md).

### Recommended default votes

| Question | Recommended default |
|---|---|
| Shared byte escapes in source | **Octal** |
| Human-facing byte notation in comments/docs | **Hex, with octal shown where useful** |
| Shared constrained file extension | **`.dsh`** |
| Host-only helper extension | **`.sh`** |
| Executables in `src/dud-sh/bin/` | **No extension** |
| Shared script launch style during `/bin/sh` phase | **Invoke with `/bin/sh path` or `sh path`, not shebang-dependent direct exec** |
| Generated native outputs | **Root `.bin/`** |
| Scratch/intermediates | **Root `.tmp/`** |
| AGENTS structure | **Root `AGENTS.md` plus `src/dud-sh/AGENTS.md`; no `src/AGENTS.md` yet** |
| Exact marker-byte ABI | **Provisional; ask first; do not freeze yet** |
| `exec`, FD handling, `$0`, `$#`, `shift` | **Reserved future; not current subset** |
| License during setup | **Create 0BSD at initial scaffolding; do not silently change legal files later** |

These choices reinforce each other. Octal-in-source removes the `printf` portability landmine; `.dsh` marks the intentionally smaller language and discourages Bash creep; avoiding shebang dependence keeps the same files runnable by `/bin/sh` today and a later native host tomorrow; `.bin/` and `.tmp/` make generated vs transient artifacts obvious; and layered AGENTS files let workflow rules stay global while language rules stay local and concise. Sources: [POSIX `printf`](https://man7.org/linux/man-pages/man1/printf.1p.html), [dash(1)](https://man7.org/linux/man-pages/man1/dash.1.html), [POSIX shell language](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html), [POSIX dot utility](https://man7.org/linux/man-pages/man1/dot.1p.html), [GitHub Copilot custom instructions](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot), and [OpenAI Codex `AGENTS.md`](https://developers.openai.com/codex/guides/agents-md).

## 6. Detailed answers to open questions

### A. Project identity and naming

Root `AGENTS.md` should refer to the repository as `dud`. The current work should be called `dud-sh`. `dsh` should be treated as a shorthand/internal alias unless the owner explicitly decides it is a public name. `dud-asm` and `dud-cc` should be mentioned only as long-term context, not as design drivers for the first milestone. AGENTS should include the slogan “Shell temporarily hosts dsh; later dsh runs the same files itself” because it crisply communicates the compatibility constraint. Source: [`prompt.md`](prompt.md).

### B. First milestone and bootstrap graph

The first milestone should be stated explicitly:

```text
/bin/sh-hosted dud-sh-compatible source
  -> first native patch-elf
  -> patch-elf-modular built from dot-sourced fragments
  -> toward a native dud-sh kernel
```

`patch-elf` should be explicitly named as the first native artifact, and `patch-elf-modular` as the first modular artifact. Labels and relocations should be explicitly out of scope for stage 0. The bootstrap graph belongs in `docs/` and should be summarized in root/subproject READMEs; AGENTS should contain only the operational rules and pointer. Source: [`prompt.md`](prompt.md).

“Done” for the first milestone should mean: the hosted pipeline produces the native `patch-elf`; the modular build produces a behaviorally equivalent or byte-identical result where expected; `patch-elf` patches ELF32 program-header size fields correctly; and the conformance suite can validate the shared subset without requiring native i386 Linux execution on every host. QEMU user-mode can be optional because it supports running binaries built for another CPU architecture on the same OS family with syscall translation. Sources: [QEMU user-mode docs](https://www.qemu.org/docs/master/user/main.html) and [QEMU user guide mirror](https://qemu-project.gitlab.io/qemu/user/index.html).

Agents should avoid circular dependencies by documenting which stage produces each artifact, keeping generated outputs out of source, and forbidding a stage from using an artifact it is supposed to create unless that artifact is marked as an existing bootstrap seed.

### C. `dud-sh` language semantics

The current source allowlist should be written as a positive list:

```text
set -e
set -- ARG...
:
. PATH-WITH-SLASH
printf FORMAT [> PATH | >> PATH]
printf FORMAT [with caller-owned redirection]
chmod +x PATH
explicit-path project commands containing /
> and >> as trailing command-local redirection forms
$1..$9 and "$1".."$9" in the constrained forms documented by the subset
whole-line comments only
```

`exec`, FD redirection, `$0`, `$#`, `shift`, pipelines, functions, variables, loops, `exit`, and `return` should be **reserved future / not current subset**. Do not merely omit them, because omission invites agents to “helpfully” introduce them. Source: [`prompt.md`](prompt.md).

`PATH` lookup should be explicitly forbidden in shared bootstrap scripts. Dot-sourced paths must contain `/`, and explicit project commands must contain `/`, because ambient `PATH` resolution is exactly the kind of hidden dependency this project is trying to avoid. Source: [POSIX dot utility](https://man7.org/linux/man-pages/man1/dot.1p.html).

Invalid-script conformance should specify accept/reject, byte output, and exit status where practical, but should not require exact stderr text. That follows the handoff’s conformance rule. Source: [`prompt.md`](prompt.md).

### D. Tokenization and quoting

AGENTS should not say “no quoting” and then show shell-quoted `printf` strings; that is confusing. It should say:

> Shared `dud-sh` files use only a tiny shell-compatible quoting profile. Quotes are allowed as token wrappers, not as a general string language.

Recommended allowed quoting profile:

- single quotes are allowed around literal `printf` format tokens and other fully literal tokens;
- double quotes are allowed only when the whole token is one positional parameter such as `"$1"`;
- mixed quoted/unquoted token concatenation is forbidden;
- command substitution, backticks, `${...}`, arithmetic expansion, globs, escaped-space token tricks, and general variables are forbidden;
- inline comments are invalid in `dud-sh` source;
- comments may appear after leading whitespace only when `#` is the first token on the line;
- backslash byte interpretation belongs to `printf`, not to the file tokenizer.

This is intentionally stricter than POSIX shell. POSIX shell tokenization and expansion are complex enough that reproducing them would be a different project. Sources: [The Open Group Shell Command Language](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html), [POSIX Shell Command Language PDF](https://upload.wikimedia.org/wikipedia/commons/3/32/POSIX_Shell_Command_Language.pdf), and [Morbig POSIX-shell parser paper](https://www.niols.fr/paper/Jeannerod%2B17a.pdf).

### E. Byte emission convention

Use octal escapes in shared source and hex in comments/docs. POSIX `printf` specifies octal escapes such as `\ddd`; GNU `printf` adds `\xHH`, but that is not a portable baseline. Sources: [POSIX `printf`](https://man7.org/linux/man-pages/man1/printf.1p.html), [GNU Coreutils `printf`](https://www.gnu.org/software/coreutils/manual/html_node/printf-invocation.html), and [dash(1)](https://man7.org/linux/man-pages/man1/dash.1.html).

Good source style:

```sh
# ELF magic: 7f 45 4c 46
printf '\177\105\114\106'
```

Every byte-emitting `printf` should be a logical unit: one instruction, one header field bundle, one marker record, or one small conceptual byte word. Do not explode everything to one byte per line unless that is genuinely clearer. Leaf instruction files may emit a small logical bundle when clearer than single-byte fragments. Source: [`prompt.md`](prompt.md).

Fragments should default to writing bytes to stdout and let the caller own redirection. Top-level assembly/build scripts may use `>` and `>>`. FD-based output via `exec` should be delayed until after the initial path and named as future only.

### F. Host portability and runtime assumptions

State the host contract honestly:

```text
The current bootstrap host is POSIX-ish and must provide /bin/sh-compatible execution,
POSIX-style printf behavior, chmod +x, LF text files, and a filesystem with an executable bit.
The project intentionally requires /bin/sh during the hosted phase even though POSIX does not
promise the standard shell resides exactly there on every system.
```

Sources: [POSIX `sh(1p)`](https://man7.org/linux/man-pages/man1/sh.1p.html), [POSIX `printf`](https://man7.org/linux/man-pages/man1/printf.1p.html), and [POSIX `chmod`](https://man7.org/linux/man-pages/man1/chmod.1p.html).

The host should **not** be required to run i386 Linux ELF natively. Native-executable run tests should skip when unsupported. Optional QEMU smoke tests are fine, but QEMU should not become a runtime/source dependency. Sources: [QEMU user-mode docs](https://www.qemu.org/docs/master/user/main.html) and [QEMU user guide mirror](https://qemu-project.gitlab.io/qemu/user/index.html).

Use `LC_ALL=C` in tests where byte/string ordering or locale-sensitive behavior could matter. Constrain source files to LF line endings.

### G. Repository layout and file placement

Accept the owner-proposed layout with these refinements:

```text
dud/
  .bin/          # generated final native artifacts, untracked except .gitkeep
  .tmp/          # scratch/intermediates/test temp, untracked except .gitkeep
  docs/          # root bootstrap graph and cross-project docs
  src/
    dud-sh/
      AGENTS.md
      README.md
      bin/       # executable entry scripts, no extension
      lib/       # shared dud-sh subset files, .dsh
        std/
          i386/
          elf32/
          patch-elf/
      test/
      docs/
      test.py
  AGENTS.md
  README.md
  LICENSE
```

Do **not** add `src/AGENTS.md` yet. Use root `AGENTS.md` for general workflow and `src/dud-sh/AGENTS.md` for the language/profile rules. Modern agent tooling already supports local instruction files, but every extra layer adds precedence and cognitive overhead. Sources: [GitHub Copilot custom instructions](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot) and [OpenAI Codex `AGENTS.md`](https://developers.openai.com/codex/guides/agents-md).

Top-level bootstrap entry scripts belong in `src/dud-sh/bin/`, with no extension. Shared dot-sourced files use `.dsh`. Host-only shell adapters use `.sh` and should live outside shared bootstrap source or be clearly marked as host-only.

### H. Generated artifacts and scratch policy

Generated native artifacts should go under root `.bin/`. Scratch, intermediates, and test temp files should go under root `.tmp/`. Build processes should not emit into the current working directory by default. `.bin/` and `.tmp/` should be untracked except `.gitkeep`.

Tests may create and delete files under `.tmp/`; they should avoid `/tmp` unless a specific test documents why it needs it. Checked-in golden fixtures are allowed when they are human-readable, such as hex/octal dumps, expected stdout bytes written as escaped text, or checksum text. Raw generated ELF binaries should not be checked in unless there is an exceptional audit reason. Source: [`prompt.md`](prompt.md).

### I. Testing and conformance suite

`src/dud-sh/test.py` should be the canonical test runner. It should use only Python 3 standard library, `/bin/sh`, and project-generated executables. It should compare bytes using Python file reads, not `cmp`, `od`, `xxd`, `hexdump`, `sed`, `awk`, or `grep`.

Primary conformance oracles:

- exact accepted/rejected command syntax;
- exact stdout bytes;
- exact generated file bytes;
- exact exit status where specified;
- whitespace/comment behavior;
- stderr text excluded from conformance except maybe “non-empty vs empty” if needed.

The suite should be organized as conformance cases that later host implementations can run. `/bin/sh` can serve as a compatibility oracle only for valid shared-subset scripts, not for invalid scripts where shell diagnostics vary. Source: [`prompt.md`](prompt.md).

Defer `mypy`. Type hints are fine, but a tiny stdlib-only runner does not justify a mandatory extra tool.

Executable-run tests for i386 Linux ELF should be optional when the host cannot run them. Tests that inspect ELF bytes and patched fields should remain mandatory.

### J. ELF, i386, syscalls, and binary correctness

Use a strict source hierarchy:

- ELF layout and program headers: official ELF/System V ABI materials, then `elf(5)`.
- i386 instruction encodings: Intel’s official manuals.
- Linux syscall numbers/ABI: Linux kernel headers or maintained syscall tables, with architecture/ABI explicitly stated.
- POSIX shell/utility behavior: POSIX/Open Group specs and POSIX manpages.

Sources: [ELF gABI header](https://gabi.xinuos.com/elf/02-eheader.html), [ELF gABI program header](https://gabi.xinuos.com/elf/07-pheader.html), [`elf(5)`](https://man7.org/linux/man-pages/man5/elf.5.html), [Intel SDM](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html), [ChromiumOS syscall constants](https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/), and an example [`unistd_32.h`](https://chromium.googlesource.com/native_client/linux-headers-for-nacl/%2B/2dc04f8190a54defc0d59e693fa6cff3e8a916a9/include/asm/unistd_32.h).

Agents should browse/re-check primary sources whenever touching instruction encodings, syscall numbers, ELF headers, POSIX portability, or licensing. Source: [`prompt.md`](prompt.md).

`patch-elf` should be described as patching **program header fields**, not section headers. `elf(5)` and the gABI describe the program header table as the loader-facing structure used to prepare an executable for execution, and section headers may be absent. Sources: [`elf(5)`](https://man7.org/linux/man-pages/man5/elf.5.html) and [ELF gABI program header](https://gabi.xinuos.com/elf/07-pheader.html).

For the current minimal one-PHDR design, document and test these offsets:

```text
Elf32_Ehdr size:      0x34
Elf32_Phdr size:      0x20
code starts at:       0x54
p_filesz file offset: 0x44
p_memsz file offset:  0x48
```

The ELF standard-library layer should be explicitly separate from `dud-sh` kernel semantics. `dud-sh` emits bytes and composes fragments; ELF knowledge belongs in `src/dud-sh/lib/std/elf32/` and concept docs, not in the file parser.

### K. Fragment, marker, and sealed-gadget discipline

AGENTS should include the open-fragment vs sealed-gadget rule.

Open fragment:

```text
- may be dot-sourced by other files;
- may emit bytes;
- must not emit relative jumps whose offsets depend on surrounding layout;
- should document emits/expects/preserves/provenance.
```

Sealed gadget:

```text
- emits all bytes inline;
- does not dot-source other files;
- may contain internal relative jumps because its layout is frozen;
- must document local relative offsets and provenance.
```

This is not over-engineering. Direct machine-code emission without labels/relocations makes manual jump-offset computation fragile; live-bootstrap’s early `hex0` lineage is a useful cautionary precedent. Source: [live-bootstrap `parts.rst`](https://github.com/fosslinux/live-bootstrap/blob/master/parts.rst).

The proposed marker byte pattern `90 6a ID 8d 64 24 04` should be treated as **provisional**, not settled. Standardize semantics now: marker records must be executable-safe or trivially skippable, documented, and test-covered. Defer exact byte ABI until the first implementation and stripper/consumer logic exist. Source: [`prompt.md`](prompt.md).

Parameterized fragments using `set --` are allowed but should be minimized. POSIX `set --` can set positional parameters, and dot-sourced scripts run in the current shell environment, so parameterization is real but global-stateful. Sources: [POSIX `set`](https://man7.org/linux/man-pages/man1/set.1p.html) and [POSIX dot utility](https://man7.org/linux/man-pages/man1/dot.1p.html).

### L. Agent behavior and repo workflow

Root AGENTS should say:

- inspect current branch before editing;
- on `main`, refuse or ask before changing files;
- inspect `git status`;
- read root and nearby AGENTS/docs/tests;
- broad filesystem scans are allowed;
- web search is allowed and required for low-level/provenance-sensitive changes;
- edits should stay inside the repo and project scratch/output directories;
- do not modify public API/ABI, emitted ABI, conformance expectations, language subset, dependencies, or legal files without explicit owner approval.

Off `main`, agents may edit freely. Prefer one coherent final commit over WIP commits unless checkpointing is requested. When GitHub tooling and credentials are available, opening/updating a PR automatically is reasonable after tests pass. AGENTS changes and license-file changes should be ask-first or task-specific because they alter future project behavior. Source: [`prompt.md`](prompt.md).

After edits, agents should report changed files, why they changed, tests run, tests skipped, relevant test output, and open risks. Commit messages should have a short line under 60 characters and a body with the change explanation, files touched, tests run/not run, and relevant output.

### M. Documentation and literate code style

The repo should be literate but DRY/DAMP. Explain opaque things in detail the first time they appear in the intended reading path; after that, link to concept docs.

Recommended docs:

```text
docs/bootstrap-graph.md
src/dud-sh/docs/language.md
src/dud-sh/docs/byte-emission.md
src/dud-sh/docs/elf32.md
src/dud-sh/docs/i386.md
src/dud-sh/docs/patch-elf.md
src/dud-sh/docs/conformance.md
```

Source comments in `.dsh`/`.sh` should remain whole-line comments. Prefer repo-local references in source, such as:

```text
# @./src/dud-sh/docs/elf32.md#single-load-segment
# @./src/dud-sh/docs/i386.md#mov-eax-imm32
```

External URLs should live mostly in docs, not every tiny source file. That keeps byte-emitting files readable without throwing away provenance. The style aligns with the explicit/educational tendencies in [live-bootstrap](https://github.com/fosslinux/live-bootstrap/blob/master/README.rst), [live-bootstrap `parts.rst`](https://github.com/fosslinux/live-bootstrap/blob/master/parts.rst), [Mu](https://github.com/akkartik/mu), and [SectorLISP](https://github.com/jart/sectorlisp).

### N. Provenance, research, and source-copying rules

Acceptable source hierarchy:

1. official specs and vendor manuals;
2. POSIX/Open Group docs and POSIX manpages;
3. Linux man pages and kernel headers;
4. well-maintained project docs;
5. OSDev-style bridge docs with caution;
6. blogs as idea sources only;
7. Stack Overflow not as primary authority;
8. generated code never copied verbatim.

AGENTS should explicitly forbid copying substantial third-party code or generated code verbatim. Every opaque byte sequence should have local provenance: either a source comment with a repo-local doc reference or a concept doc that records the external citation.

If sources disagree, agents should stop and state the disagreement, then recommend the conservative choice. For this repo, “conservative” usually means: preserve `/bin/sh` compatibility, preserve the tiny subset, and avoid hidden host dependencies.

### O. Licensing

Create `LICENSE` as 0BSD during initial scaffolding if repo initialization is part of the task. After that, license changes require explicit owner approval. Do not keep Unlicense or CC0 in AGENTS unless the owner asks for a license comparison; mentioning alternatives creates unnecessary ambiguity. Sources: [OSI 0BSD](https://opensource.org/license/0bsd), [OSI approved licenses](https://opensource.org/licenses), and [SPDX 0BSD](https://spdx.org/licenses/0BSD.html).

0BSD is compatible with the project’s expected open-source contribution style in the practical sense that it is an OSI-approved permissive license and SPDX has a standard identifier for it. Sources: [OSI 0BSD](https://opensource.org/license/0bsd) and [SPDX 0BSD](https://spdx.org/licenses/0BSD.html).

### P. Future-feature policy

Future features such as `exec`, FD redirection, `$0`, `$#`, `shift`, pipelines, `exit`, `return`, functions, variables, command substitution, and loops should be listed as **reserved/future**, not current. This prevents premature expansion while giving later work a named place to land.

Consider versioned profiles once the conformance suite exists, for example:

```text
dsh0: current patch-elf bootstrap subset
dsh1: adds exec/fd redirection if needed
dsh2: later native kernel conveniences
```

Do not optimize for conventional assembler design too early. `dud-asm` and `dud-cc` should remain long-term context only. Source: [`prompt.md`](prompt.md).

### Q. Risk register / ask-before-changing rules

Major risks:

1. **Accidental host narrowing**: `\xNN`, `. foo`, shebang dependence, GNU-only utilities, or ambient `PATH` lookup.
2. **Language creep**: adding “just one” shell feature until `dud-sh` becomes a shell dialect.
3. **Premature ABI fossilization**: freezing marker bytes, fragment metadata, or loader conventions before implementation proves them.
4. **Unauditable byte provenance**: emitted bytes without docs/tests/source trail.
5. **Host-specific tests**: requiring native i386 execution everywhere.
6. **Circular bootstrap graph**: relying on an artifact before the stage that creates it.
7. **Legal drift**: casual license or code-copying changes.

Mitigations:

- octal in source;
- hex in comments/docs;
- slash-required dot imports;
- no `PATH` lookup;
- reserved-future list;
- ask-first for emitted ABI and language changes;
- byte-checked conformance fixtures;
- optional native-exec tests;
- root `.bin/` and `.tmp/` discipline;
- compact layered AGENTS files.

Sources: [`prompt.md`](prompt.md), [POSIX `printf`](https://man7.org/linux/man-pages/man1/printf.1p.html), [POSIX dot utility](https://man7.org/linux/man-pages/man1/dot.1p.html), [POSIX shell language](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html), and [Morbig POSIX-shell parser paper](https://www.niols.fr/paper/Jeannerod%2B17a.pdf).

## 7. Open risks and mitigations

The major risks are concrete rather than philosophical.

First, **accidental host narrowing**: a casual `\xNN`, `. foo` without a slash, or reliance on shebang launch semantics silently undermines the portability story. Mitigation: octal-in-source, slash-required dot imports, explicit invocation by `/bin/sh path` or configured `sh path`, and tests that validate the allowed subset. Sources: [POSIX `printf`](https://man7.org/linux/man-pages/man1/printf.1p.html), [dash(1)](https://man7.org/linux/man-pages/man1/dash.1.html), [POSIX dot utility](https://man7.org/linux/man-pages/man1/dot.1p.html), and [POSIX `sh(1p)`](https://man7.org/linux/man-pages/man1/sh.1p.html).

Second, **language creep**: once agents are allowed to use “a little more shell,” the subset stops being a future tiny interpreter target and starts becoming a moving shell dialect. Mitigation: positive allowlist plus reserved-future list.

Third, **ABI fossilization too early**: if marker bytes, fragment metadata, or partial loader conventions are frozen before the first working end-to-end pipeline exists, early mistakes become expensive. Mitigation: semantic marker requirements now, exact marker byte ABI later.

Fourth, **test host specificity**: i386 Linux ELF execution is inherently target-specific. Mitigation: make byte-structure and `patch-elf` field tests mandatory, but make executable-run tests optional or QEMU-backed.

## 8. Questions still requiring project-owner taste

These are taste-bearing choices rather than purely research-settled issues:

1. How much comment header boilerplate should appear in the very first committed byte fragments?
2. Should root + nested `AGENTS.md` be created immediately, or should the repo start with root-only AGENTS and split once `src/dud-sh/` becomes nontrivial?
3. Should exact marker bytes be deferred, as recommended, or frozen now for momentum?
4. How strict should the first conformance suite be about invalid scripts?
5. Should `dsh0`/`dsh1` profile naming be introduced now, or wait until the first non-shell implementation exists?

## 9. Suggested `AGENTS.md` implications

The future root `AGENTS.md` should be short and operational:

- project identity and current milestone;
- branch/edit rules;
- write boundaries;
- test/report/commit expectations;
- ask-first boundaries;
- license default;
- provenance requirements for technical changes;
- pointer to `src/dud-sh/AGENTS.md` for language rules.

The nested `src/dud-sh/AGENTS.md` should contain the actual `dud-sh` contract:

- current allowlist;
- forbidden/reserved shell features;
- quoting profile;
- whole-line comment rule;
- `.dsh` vs `.sh` placement;
- slash-required dot imports;
- octal-in-source byte policy;
- fragment/gadget discipline;
- `.bin/` and `.tmp/` conventions;
- conformance test expectations;
- provenance style.

Both files should stay compact because modern agent tooling layers local instructions and size is not free. Sources: [GitHub Copilot custom instructions](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot), [OpenAI Codex `AGENTS.md`](https://developers.openai.com/codex/guides/agents-md), and [OpenAI Codex exec plans](https://developers.openai.com/cookbook/articles/codex_exec_plans).

## 10. Decision ballot

Pick one default:

```text
[x] D: literate conformance-first
[ ] A: portability-first only
[ ] B: velocity-first / hex-first
[ ] C: tiny-kernel-first only
[ ] custom mix: ______________________
```

Must-decide items:

```text
1. Byte escapes in shared source:
   [x] octal
   [ ] hex
   [ ] profile-dependent

2. Human byte notation in comments/docs:
   [x] hex-friendly
   [ ] octal-only

3. Shared dot-sourced files:
   [x] .dsh
   [ ] .sh
   [ ] split another way

4. Host-only helpers:
   [x] .sh and clearly separate
   [ ] no separate host-only class

5. Generated artifacts:
   [x] root .bin/
   [ ] current working directory
   [ ] per-stage local output dirs

6. Scratch:
   [x] root .tmp/
   [ ] /tmp allowed by default
   [ ] per-test temp dirs elsewhere

7. Native i386 execution tests:
   [x] optional / skip when unsupported
   [ ] mandatory
   [ ] forbidden until later

8. QEMU:
   [x] optional smoke-test helper
   [ ] required
   [ ] forbidden

9. exec / FD redirection:
   [x] reserved future, not current
   [ ] omit entirely
   [ ] introduce now

10. AGENTS layout:
   [x] root + src/dud-sh/AGENTS.md
   [ ] root only
   [ ] root + src/AGENTS.md + src/dud-sh/AGENTS.md

11. Marker bytes:
   [x] defer exact encoding; keep ask-first
   [ ] freeze now

12. License setup:
   [x] create 0BSD during initialization
   [ ] recommend only until explicitly asked
```

## 11. Sources consulted

### Project source

- [`prompt.md`](prompt.md) — uploaded project handoff and governing brief.

### POSIX, shell, and portability

- [POSIX `printf(1p)`](https://man7.org/linux/man-pages/man1/printf.1p.html)
- [GNU Coreutils `printf` invocation](https://www.gnu.org/software/coreutils/manual/html_node/printf-invocation.html)
- [dash(1)](https://man7.org/linux/man-pages/man1/dash.1.html)
- [POSIX `chmod(1p)`](https://man7.org/linux/man-pages/man1/chmod.1p.html)
- [POSIX `set(1p)`](https://man7.org/linux/man-pages/man1/set.1p.html)
- [POSIX `sh(1p)`](https://man7.org/linux/man-pages/man1/sh.1p.html)
- [POSIX dot utility](https://man7.org/linux/man-pages/man1/dot.1p.html)
- [The Open Group Shell Command Language](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html)
- [POSIX Shell Command Language PDF](https://upload.wikimedia.org/wikipedia/commons/3/32/POSIX_Shell_Command_Language.pdf)
- [Morbig: A Static Parser for POSIX Shell](https://www.niols.fr/paper/Jeannerod%2B17a.pdf)

### Bootstrapping lineage

- [Bootstrappable Builds](https://www.bootstrappable.org/)
- [Bootstrappable Builds best practices](https://www.bootstrappable.org/best-practices.html)
- [live-bootstrap README](https://github.com/fosslinux/live-bootstrap/blob/master/README.rst)
- [live-bootstrap `parts.rst`](https://github.com/fosslinux/live-bootstrap/blob/master/parts.rst)
- [Mu](https://github.com/akkartik/mu)
- [Akkartik’s Mu notes](https://akkartik.name/post/mu-2019-1)
- [SectorLISP](https://github.com/jart/sectorlisp)

### ELF, i386, and syscall provenance

- [ELF gABI: ELF Header](https://gabi.xinuos.com/elf/02-eheader.html)
- [ELF gABI: Program Header](https://gabi.xinuos.com/elf/07-pheader.html)
- [`elf(5)`](https://man7.org/linux/man-pages/man5/elf.5.html)
- [Intel Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
- [ChromiumOS syscall constants](https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/)
- [`unistd_32.h` example](https://chromium.googlesource.com/native_client/linux-headers-for-nacl/%2B/2dc04f8190a54defc0d59e693fa6cff3e8a916a9/include/asm/unistd_32.h)

### Agent tooling

- [GitHub Copilot custom instructions](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [OpenAI Codex `AGENTS.md` guide](https://developers.openai.com/codex/guides/agents-md)
- [OpenAI Codex exec plans](https://developers.openai.com/cookbook/articles/codex_exec_plans)

### Testing and emulation

- [QEMU user-mode docs](https://www.qemu.org/docs/master/user/main.html)
- [QEMU user guide mirror](https://qemu-project.gitlab.io/qemu/user/index.html)

### License

- [OSI 0BSD](https://opensource.org/license/0bsd)
- [OSI approved licenses](https://opensource.org/licenses)
- [SPDX 0BSD](https://spdx.org/licenses/0BSD.html)
