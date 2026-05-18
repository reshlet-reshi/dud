# Researcher Handoff: `dud` / `dud-sh` `AGENTS.md` Planning

Draft: 0

## 1. Purpose of this handoff

This document is a prompt for a deep-research agent.

The researcher's job is to produce a planning report for the project owner. The report should help the owner decide how the eventual `AGENTS.md` should instruct coding, documentation, and research agents working in this repository.

The researcher **must not write `AGENTS.md`**. The desired output is a report with several coherent proposed answer sets, tradeoffs, and recommendations. The project owner will choose or splice from those answer sets later.

The expected final research output should help answer:

```text
Given the settled project facts below, what project conventions, bootstrap discipline,
agent workflow rules, and documentation/testing policies should be encoded in AGENTS.md?
```

The core requirement is **coherence**. Do not answer each open question independently if the answers conflict. Instead, propose internally consistent modes such as:

```text
A. Maximal POSIX portability / octal-first
B. Pragmatic bootstrap velocity / hex-first
C. Tiny-kernel purity / minimal source feature set
D. Literate conformance-first / educational source tree
E. Multi-host challenge / Rosetta-Code-style implementation target
```

The project owner will prefer a package of choices that fits the project philosophy, not a long list of unrelated opinions.

---

## 2. Project summary

The root project is named `dud`.

The first subproject is `dud-sh`, sometimes shortened to `dsh` in prototype/report notes. `dud-sh` is not a full shell. It is a deliberately tiny `/bin/sh`-compatible bootstrap command language.

The long-term idea is to bootstrap upward from ordinary `/bin/sh` into a tiny native Dud kernel, then later into better tools such as `dud-asm`, and eventually perhaps `dud-cc`.

The project's current guiding slogan is:

```text
Shell temporarily hosts dsh.
Later dsh runs the same files itself.
```

A second important maxim:

```text
A file is newline-separated commands.
A command is whitespace-separated tokens.
The kernel parser does no global syntax parsing beyond that.
Any extra interpretation belongs to a command, not to the file parser.
```

The early bootstrap scripts should be valid under `/bin/sh` today, while also staying small and regular enough that a future native `dud-sh` kernel can interpret the same files without emulating all of shell.

The first concrete bootstrap path appears to be:

```text
/bin/sh-hosted dud-sh-compatible scripts
  -> first native patch-elf
  -> patch-elf-modular built from dot-sourced fragments
  -> native/self-hosting dud-sh kernel path
```

`patch-elf` is a tiny native executable that patches ELF32 program header fields so later scripts can emit executable ELF files without hard-coding total file size.

`dud-asm` is a later, real-er assembler, expected to aim toward FASM-ish parity. It is not the first milestone.

---

## 3. Owner preferences and decision criteria

The project owner wants the agent to behave like a skeptical open-source developer with their own fork of the project.

Default optimization order:

```text
1. correctness of response / technical correctness
2. speed of response / fast iteration
3. simplicity
4. learning and explanation
5. maintainability
6. minimal diffs
```

Project-specific preferences:

```text
- Prefer choices that keep dud-sh tiny.
- Prefer choices that preserve /bin/sh compatibility during bootstrap.
- Prefer choices that make conformance testing easy.
- Prefer choices that avoid hidden host dependencies.
- Prefer choices that make future non-shell host implementations easy.
- Prefer choices that make byte provenance auditable.
- Prefer choices that avoid turning dud-sh into a general shell.
- Prefer low-dependency test infrastructure.
- Prefer readable, learner-friendly source, but not at the cost of uncontrolled complexity.
```

The owner values:

```text
- avoiding unnecessary filesystem writes while agents work
- fast responses
- multiple implementation options when real tradeoffs exist
- regression avoidance
- dead-simple tests
- safe refactors
- agents learning the owner's code/factoring style over time
```

When design uncertainty is real, the agent should call it out and present 2-3 options. If there is no meaningful tradeoff, the agent should be direct.

Default explanation style: terse rationale by default; deeper explanation only when requested.

---

## 4. Settled facts

This section is intended as a source of truth for what has already been decided. Do not reinterpret these as open unless a conflict is explicitly listed later.

### 4.1 Repository identity

```text
root repo / project: dud
first subproject: dud-sh
later assembler: dud-asm
later stretch compiler: dud-cc
```

`dud-sh` is the first thing being incrementally bootstrapped toward. `dud-asm` comes later.

### 4.2 Project type and audience

```text
project type: CLI / bootstrap toolchain project
stage: brand new empty repo
audience: project owner plus open-source developers interested in bootstrapping
```

### 4.3 Current target architecture / executable format

The current spelling for the architecture/format target is:

```text
i386-linux-elf
```

The early executable format is ELF32 for i386/Linux-style native executables.

ELF support should be provided by a standard-library-like layer built above raw byte emission, not by the `dud-sh` kernel itself.

### 4.4 Runtime/bootstrap source dependency rule

For bootstrap/runtime source, the current intended host model is:

```text
/bin/sh-compatible syntax, with only printf and chmod allowed as host external utilities.
```

The following tools are hard-forbidden in runtime/bootstrap source unless the owner explicitly changes the rule:

```text
cat
rm
mkdir
cmp
diff
od
sed
awk
grep
make
env
```

This hard-forbidden list applies to source/bootstrap scripts, not necessarily to tests.

`printf` and `chmod` are allowed as external utilities. There is still a known philosophical tension with earlier notes saying “pure shell builtins only”; see Known Tensions.

### 4.5 Current allowed bootstrap language subset

The current exercised `dud-sh` / `dsh` subset is very small:

```text
set -e
set -- ARG...
:
.
printf
chmod +x
redirection: > and >>
positional parameters: $1 .. $9 and "$1" .. "$9"
external path commands containing /, e.g. ./patch-elf
whole-line comments only
```

The current scripts intentionally do **not** require:

```text
if
case
for
while
test / [
&&
||
!
pipes
functions
general variables
inline comments
globbing
command substitution
general shell quoting
exit
return
```

Some may be future features, but they are not needed for the current `patch-elf-modular` path.

### 4.6 Comment and tokenization rule

Settled owner preference:

```text
- Comments are whole-line only.
- A comment line is one whose first non-whitespace token starts with #.
- Inline comments are an error in dud-sh.
- Tokens may only start with # if they are the first token on a line.
- Commands are simple whitespace-split tokens.
- All command-specific special meaning is local to the command.
- Scripts must be written so that /bin/sh and dud-sh agree on behavior.
```

There remains an open question about how to describe shell-compatible quoting for `printf` format tokens and positional parameters.

### 4.7 Argument / variable model

Settled:

```text
- Agents must not introduce broader variable semantics unless explicitly asked.
- set -- is allowed.
- Positional parameter expansion is allowed in the constrained forms currently needed.
```

Open:

```text
- Whether $0 is part of the model now.
- Whether $# should be mentioned as maybe-future or omitted.
- Whether shift should remain maybe-future.
```

### 4.8 Conformance expectations

For host implementations of `dud-sh`, the following should be identical:

```text
accepted command syntax
byte output
exit status
whitespace/comment behavior
test suite behavior
```

The following need not be identical:

```text
exact error messages
```

Conformance is a central product goal. The test suite should become a Rosetta-Code-like challenge for implementing a tiny `dud-sh` kernel in many languages.

Host implementations are encouraged in languages such as:

```text
Python
C
Lua
Tcl
Zig
Rust
C#
Guile/MES Scheme
SectorLISP
Forth/SectorForth
Haskell
Lean
NASM/GAS/FASM
Go
Perl
Awk
Node.js
```

### 4.9 Testing constraints

Tests do not need to follow the same bootstrap purity as runtime/source files.

Allowed for tests:

```text
Python 3.x, standard library only
/bin/sh
executables bootstrapped by the project itself
```

Tests should assume bare POSIX-ish compatibility and avoid overt host/tool dependencies unless explicitly documented.

Tests should avoid temporary files outside the project scratch area. Earlier wording said `tmp/`; the more recent layout specifies `.tmp/`.

The test suite should be low-dependency and should form a conformance suite for `dud-sh` implementations and later bootstrap stages.

### 4.10 Generated files

Settled rule:

```text
Files generated by agents may exist.
Files generated by build processes/code must not be checked in.
All checked-in files must be nice, documentable, human-readable source.
```

Open:

```text
- Whether generated native bootstrap artifacts such as patch-elf should always live under .bin/.
- Whether byte fixtures/checksums may be checked in if human-readable.
```

### 4.11 Proposed repository layout

Owner-proposed layout:

```text
dud/
  .bin/
    .gitkeep
  .tmp/
    .gitkeep
  docs/
  src/
    AGENTS.md
    README.md
    dud-sh/
      AGENTS.md
      README.md
      bin/      # executable shell scripts, no extensions
      lib/      # dot-sourced shell scripts, extension unresolved
      test/     # support for test.py
      docs/
      test.py
  AGENTS.md
  README.md
  LICENSE
```

Settled:

```text
- Commit dud/.tmp/.gitkeep.
- Commit dud/.bin/.gitkeep.
- Executable scripts in src/dud-sh/bin/ should have no extension.
```

Open:

```text
- Whether dot-sourced fragments should use .sh, .dsh, or a split convention.
- Where the report-style std/ tree belongs inside this layout.
- Whether top-level bootstrap scripts belong in bin/, boot/, stage0/, test/, or elsewhere.
```

### 4.12 Branch, commit, and PR workflow

Settled:

```text
- Agents may edit freely only when not on main.
- On main, agents must refuse or ask before changing files.
- The owner expects agent work to be merged into main only through owner-reviewed GitHub PRs.
- Agents are allowed to use GitHub tooling.
- Commit creation is part of agent behavior.
```

Before editing, agents should:

```text
- inspect current branch and refuse/ask on main
- inspect git status
- read AGENTS.md
- read nearby docs/tests
- broad filesystem scans are allowed
- web search is allowed
```

After editing, agents should:

```text
1. run the smallest relevant test
2. explain exactly what changed
3. list files touched
4. mention tests run and not run
5. include relevant test output
6. create a commit when changes pass
7. open/update a PR when GitHub tooling is available
```

Commit style:

```text
- Initial short line under 60 characters.
- Longer message includes the change explanation, files touched, tests run/not run, and relevant output.
```

PR style is intentionally deferred for a later best-practices research pass.

### 4.13 API/ABI boundaries that require asking first

Changing any of the following should require asking first:

```text
bootstrap shell subset
dud-sh command syntax/semantics
emitted executable ABI
CLI behavior
conformance test expectations
```

Also ask before:

```text
- changing dependencies
- changing public API/ABI
- touching files outside whitelisted areas
- broadening the dud-sh language beyond the current subset
```

### 4.14 Documentation and literate style

The repo should be literate, but DRY/DAMP.

Owner preference:

```text
There should be an intended linear way to read the code.
Everything should be explained in maximum useful detail the first time it appears,
or linked to an out-of-line doc.
After that, the first time each potentially opaque thing appears in a file,
reference the out-of-line doc.
```

For generated executable bytes:

```text
Each individual printf should try to be a logical unit:
one instruction, opcode/immediate group, header field, etc.
```

Open:

```text
- Exact required header formats for sealed gadgets and open fragments.
- Exact doc-reference syntax.
- Whether code comments should use raw URLs, repo-local @./docs references, or both.
```

### 4.15 Provenance and research rules

Settled:

```text
- Provenance should be encoded inline where practical.
- For large/unwieldy citations, use a doc reference format like @./path/to/doc.
- Doc references should be liberally included in generated code.
- Agents should browse by default when touching instruction encodings, syscall numbers,
  POSIX portability, ELF headers, or historical bootstrap claims.
```

Acceptable source hierarchy:

```text
official specs preferred
man pages acceptable
OSDev wiki acceptable with caution
Stack Overflow discouraged
blog posts okay only for ideas, and should be cited if used
generated code must never be copied verbatim
```

Open:

```text
- Exact citation/comment format.
- How to handle external source copying/copyright in AGENTS.md language.
```

### 4.16 License preference

Settled preference:

```text
Prefer 0BSD unless the owner overrides it later.
```

Earlier notes also mentioned the 0BSD / Unlicense / CC0 family, maybe even a trio. The current owner answer says agents should prefer 0BSD.

Open:

```text
- Whether agents should create LICENSE as 0BSD during repo setup, or merely recommend it until explicitly asked.
```

---

## 5. Current bootstrap model from the prior report

The prior bootstrap report should be treated as a high-value source of current design intent.

### 5.1 `dud-sh` / `dsh` kernel profile

The current bootstrap scripts exercise only:

```text
set -e
:
.
printf
chmod
external path command
>
>>
set --
$1
```

The current subset is deliberately not a real shell. The future kernel should interpret the same files that `/bin/sh` hosts today.

### 5.2 `set -e`

Every top-level bootstrap script should begin with:

```sh
set -e
```

In `dud-sh`, this should mean simplified fail-fast behavior:

```text
If any command returns nonzero, abort the script.
```

The scripts avoid shell constructs that make real-shell `set -e` behavior surprising.

### 5.3 Redirection

The parser sees tokens. Commands such as `printf` and `:` interpret trailing redirection tokens locally.

Needed forms:

```text
> PATH
>> PATH
```

No `<`, `>&`, `<&` are needed for `patch-elf-modular` yet, although fd forms are planned via `exec`.

### 5.4 `printf`

The report's `printf` subset is:

```text
printf FORMAT > PATH
printf FORMAT >> PATH
```

The report primarily uses octal escapes such as:

```sh
printf '\177\105\114\106' >> ./out
```

This conflicts with the owner's earlier stated preference for hex escapes such as:

```sh
printf '\x7fELF...'
```

This is a key research question.

### 5.5 Dot sourcing

`.` is the main composition mechanism.

Instead of one huge byte stream, scripts should split into small reusable files:

```sh
. ./i386/insn/mov-eax-019.dsh
. ./i386/insn/mov-ebx-esi.dsh
. ./i386/insn/xor-ecx-ecx.dsh
. ./i386/insn/mov-edx-002.dsh
. ./i386/insn/int-80.dsh
```

The report suggests a standard-library-like tree:

```text
std/
  i386/
    insn/
    gadget/
    mark/
    check/
  elf32/
  patch-elf/
```

Where this tree belongs in the owner-proposed repo layout remains open.

### 5.6 Parameterized fragments

`set --` allows reusable fragments while remaining shell-shaped.

Example:

```sh
set -- '\004'
. ./i386/mark/mark-imm8.dsh
```

This only requires:

```text
set -- ARG...
$1
"$1"
```

No general variables.

### 5.7 Marker / gadget strategy

Problem: relative jumps become fragile when code is split across dot-sourced fragments.

Current rule from the report:

```text
If a .dsh file dot-sources any other file,
it must not emit relative jumps whose offsets depend on surrounding code.
```

Relative jumps are allowed only inside sealed gadget files.

A sealed gadget file:

```text
- emits all bytes inline with printf
- does not dot-source other files
- documents all local relative offsets
- is treated as an opaque byte word by other fragments
```

Marker format currently proposed:

```text
90 6a ID 8d 64 24 04
```

Assembly:

```asm
nop
push byte ID
lea esp, [esp + 4]
```

Rule from the report:

```text
Bootstrap-generated code should reserve NOP 0x90 for marker starts,
or at least avoid accidental marker-shaped byte sequences.
```

### 5.8 `patch-elf`

The first monolithic native executable should be:

```text
patch-elf
```

Purpose:

```text
Given a target ELF32 file:
  get its length
  compute payload_len = file_len - 0x54
  poke payload_len into program header p_filesz at offset 0x44
  poke payload_len into program header p_memsz  at offset 0x48
```

Important report details:

```text
ELF32 header:      0x34 bytes
one PT_LOAD phdr:  0x20 bytes
code starts at:    0x54
p_filesz offset:   0x44
p_memsz offset:    0x48
```

The project should say “program header fields,” not section headers.

The first `patch-elf` may be a single large byte stream. After it exists, build `patch-elf-modular` using dot-sourced fragments, then run:

```sh
./patch-elf ./patch-elf-modular
chmod +x ./patch-elf-modular
```

### 5.9 `exec` future role

The prior report recommends including `exec` in the eventual `dud-sh` kernel, even if `patch-elf-modular` does not exercise it yet.

Two roles:

```text
1. Process replacement:
   exec ./next-stage "$@"

2. File descriptor setup:
   exec 3> ./patch-elf-modular
   printf '\220' >&3
   exec 3>&-
```

Suggested future subset:

```text
exec PATH ARG...
exec FD> PATH
exec FD>> PATH
exec FD>&-
printf FORMAT >&FD
```

Open: whether `AGENTS.md` should mention this now or wait until implementation actively introduces it.

---

## 6. Known tensions and conflicts to resolve

The researcher should not hide these. They should be turned into coherent alternative answer sets.

### 6.1 Hex vs octal `printf` escapes

Owner earlier said:

```text
Stage 0 is literally printf with hex escapes.
Use printf '\x7fELF...'.
Fail if unsupported.
```

The bootstrap report strongly uses octal:

```sh
printf '\177\105\114\106'
```

Research needed:

```text
- POSIX portability implications.
- Ergonomics/readability implications.
- What host printf implementations commonly support.
- Whether source should use octal while docs/comments show hex.
- Whether requiring \xNN is acceptable for this project.
```

### 6.2 Pure shell builtins vs allowed external utilities

Earlier wording said “nothing but POSIX sh” means pure shell builtins only. Later answers settled on allowing `printf` and `chmod` as host external utilities.

Research task: propose precise `AGENTS.md` wording that captures the actual intended rule without contradiction.

Likely rule:

```text
Bootstrap source is /bin/sh-compatible and may invoke only printf and chmod as host utilities,
plus explicit-path project-generated executables as the bootstrap progresses.
```

But the researcher should test this wording against the bootstrap model.

### 6.3 No quoting semantics vs shell-compatible quoted tokens

The project owner says all commands are whitespace-split tokens with no general quoting semantics, while real `/bin/sh` examples need shell quotes around `printf` byte strings and sometimes double quotes around positional parameters.

The prototype/report recognizes constrained quote handling.

Research task: propose exact language for allowed quoting.

Possible resolution:

```text
Quotes are allowed only as shell-compatible token wrappers for printf formats and positional parameters;
they are not a general string language.
```

But the researcher should assess whether that is too permissive or too vague.

### 6.4 `.tmp/` vs `tmp/`

Earlier notes referred to `tmp/`; later layout specifies `.tmp/`.

Likely resolution: use only `dud/.tmp/`.

Research task: confirm and propose agent/test scratch policy.

### 6.5 `.sh` vs `.dsh` file extensions

Owner layout says `src/dud-sh/lib/` contains dot-sourced shell scripts, maybe with `.sh` extension. The report examples use `.dsh`.

Research task: propose extension convention that balances:

```text
- valid /bin/sh hosting
- clarity that files are in the dud-sh subset
- editor/tooling ergonomics
- separation of host-only shell adapters from shared dud-sh scripts
```

### 6.6 Current subset vs planned `exec`

`exec` is not currently needed for `patch-elf-modular`, but the report argues it belongs in the eventual kernel.

Research task: propose whether `AGENTS.md` should mention planned `exec` now, and how to prevent agents from prematurely expanding the language.

### 6.7 Tiny source vs literate source

The project wants small bootstrap machinery but also highly educational source.

Likely resolution:

```text
Literate, but DRY/DAMP: explain opaque things in detail the first time;
then link/reference out-of-line docs.
```

Research task: propose concrete comment/doc rules for byte-emitting files.

### 6.8 Bare POSIX host vs i386 Linux ELF target

Tests should avoid overt Linuxisms and assume bare POSIX-ish compatibility, but generated executables are `i386-linux-elf` and must run somewhere.

Research task: propose exact host assumptions:

```text
- Is the host OS expected to run i386 Linux executables?
- Are tests allowed to skip native execution if the host cannot run them?
- Should QEMU/emulation be forbidden, optional, or out of scope?
- How should AGENTS phrase portability without promising impossible host support?
```

---

## 7. Open questions by category

The researcher should answer all of these, either directly or by creating answer sets that cover them.

If additional blind spots are found, add them explicitly.

### A. Project identity and naming

1. Should the root `AGENTS.md` refer to the current work primarily as `dud`, `dud-sh`, or `dsh`?
2. Should `dsh` be treated as a shorthand/internal alias, or an actual public name?
3. How should `dud-sh`, `dud-asm`, and `dud-cc` be described so agents do not prematurely design the later tools?
4. Should `AGENTS.md` include the “shell temporarily hosts dsh” slogan?

### B. First milestone and bootstrap graph

1. Should the first milestone be stated as:

   ```text
   Build the path from /bin/sh-hosted dud-sh-compatible scripts
   to patch-elf, then patch-elf-modular, then toward a native dud-sh kernel.
   ```

   Or should the milestone language stay more general?

2. Should `patch-elf` be explicitly named as the first native artifact?
3. Should `patch-elf-modular` be explicitly named as the first modular artifact?
4. Should labels/relocations be explicitly out of scope for stage 0?
5. Should the bootstrap graph be documented in `docs/`, `README.md`, or only in `AGENTS.md`?
6. What should count as “done” for the first milestone?
7. How should agents avoid circular dependencies in the bootstrap graph?

### C. `dud-sh` language semantics

1. What is the exact current source allowlist?
2. Should it include exactly:

   ```text
   set -e
   set --
   :
   .
   printf
   chmod +x
   explicit-path external commands
   >
   >>
   $1..$9 / "$1".."$9"
   whole-line comments only
   ```

3. Should `exec` be mentioned as planned/future?
4. Should `$0` be part of the current positional model?
5. Should `$#` be explicitly maybe-future, or omitted?
6. Should `shift` be explicitly maybe-future, or omitted?
7. Should pipelines remain maybe-future, or be explicitly forbidden until asked?
8. How should exact invalid-script behavior be specified, given exact error messages are not conformance requirements?
9. Should `exit` and `return` remain forbidden until asked?
10. Should `PATH` lookup be explicitly forbidden in all bootstrap scripts?

### D. Tokenization and quoting

1. How should `AGENTS.md` state the no-general-quoting rule while allowing shell-hosted scripts to contain quoted `printf` formats?
2. Are single quotes allowed only around `printf` format tokens?
3. Are double quotes allowed only around positional parameters such as `"$1"`?
4. Is `printf "$1"` allowed only for parameterized byte fragments?
5. Are mixed literal/positional strings allowed, or forbidden?
6. Should backslash interpretation belong only to `printf`, not the file tokenizer?
7. Should inline comments produce an error, or should agents merely avoid them?
8. Should the tokenizer support comments after leading whitespace before `#`?

### E. Byte emission convention

1. Should source use hex escapes, octal escapes, or both?
2. If hex escapes are preferred, should the project intentionally require `printf` with `\xNN` support even if stricter POSIX portability favors octal?
3. If octal escapes are preferred, should comments/docs show equivalent hex bytes for readability?
4. Should agents verify `printf '\x41'` support before assuming hex escapes?
5. Should agents verify octal `printf` behavior as part of tests?
6. Should every byte-emitting `printf` be a logical unit: one instruction, one header field, one marker part, etc.?
7. Should leaf instruction files emit exactly one conceptual byte word, or may they emit a small logical bundle when clearer?
8. Should byte emission default to stdout bytes or explicit file redirection?
9. Should fd-based output via `exec` be delayed until after the initial path, or planned immediately?

### F. Host portability and runtime assumptions

1. What host requirements should be stated?
2. Is the host required to be POSIX-ish with `/bin/sh`, `printf`, and `chmod +x`?
3. Is the host required to run i386 Linux ELF executables natively?
4. Should generated native-executable tests skip when unsupported, or fail?
5. Should optional emulation like QEMU be allowed, discouraged, or forbidden?
6. Should `/bin/sh` be required exactly, or should `sh` from PATH be allowed in tests?
7. Should locale/environment variables be constrained, e.g. `LC_ALL=C`?
8. Should line endings be constrained to LF?
9. How should `chmod` portability be handled?
10. How should filesystem assumptions be stated, especially executable bit support?

### G. Repository layout and file placement

1. Should the owner-proposed layout be accepted exactly?
2. Where should the report-style `std/` tree live?

   Candidate:

   ```text
   src/dud-sh/lib/std/i386/
   src/dud-sh/lib/std/elf32/
   src/dud-sh/lib/std/patch-elf/
   ```

3. Should top-level bootstrap scripts live in `src/dud-sh/bin/`, `src/dud-sh/boot/`, `src/dud-sh/stage0/`, or elsewhere?
4. Should executable scripts have no extension?
5. Should dot-sourced shared scripts use `.sh`, `.dsh`, or a split convention?
6. Should host-only adapter scripts use a different extension/location than shared `dud-sh` scripts?
7. Should root `.bin/` hold generated native artifacts?
8. Should root `.tmp/` be the only scratch directory?
9. Should nested `AGENTS.md` files be created now or later?
10. Should the first emitted instruction file/doc live under `src/dud-sh/lib/` or `src/dud-sh/docs/` first?

### H. Generated artifacts and scratch policy

1. Should generated native artifacts go under root `.bin/`?
2. Should scripts ever emit into the current working directory, as the report examples do?
3. Should build outputs be untracked even when bootstrap-critical?
4. Should `.bin/` contain only untracked generated executables except `.gitkeep`?
5. Should `.tmp/` contain all scratch/test temporary files?
6. Should agents/tests be forbidden from using `/tmp`?
7. May tests create and delete files under `.tmp/`?
8. Should checked-in golden fixtures be allowed if human-readable?
9. Should checksums be checked in? If yes, in what format?

### I. Testing and conformance suite

1. Should `src/dud-sh/test.py` be the canonical test runner?
2. Should tests compare generated bytes using Python file reads rather than shelling out to `cmp`, `od`, `xxd`, or `hexdump`?
3. Should mypy be forbidden, optional-if-available, allowed as dev-only, or deferred?
4. Should tests be organized as conformance cases that every host implementation can run?
5. Should `/bin/sh` be used as a compatibility oracle?
6. How should tests handle invalid scripts whose exact shell error behavior cannot be controlled?
7. Should exact stderr be excluded from conformance?
8. Should exit status be coarse or exact?
9. Should byte-for-byte output be the main oracle?
10. Should tests include `patch-elf-modular` byte-identical output from the start?
11. Should executable-run tests be optional when the host cannot run i386 Linux ELF?
12. Should tests be self-describing for learners?
13. Should test fixtures live in `src/dud-sh/test/fixtures/` or another path?
14. Should tests be allowed to invoke generated executables only from `.bin/`?
15. Should tests clean `.tmp/` themselves or leave artifacts for debugging?

### J. ELF, i386, syscalls, and binary correctness

1. What external specifications should be treated as authoritative for ELF32, i386 instruction encoding, Linux syscall ABI, and POSIX shell behavior?
2. Should agents browse every time they touch instruction encodings, syscall numbers, ELF headers, or POSIX portability?
3. How should byte provenance be recorded for ELF header fields?
4. How should byte provenance be recorded for i386 instructions?
5. Should `patch-elf`'s offsets be documented in source comments, docs, tests, or all three?
6. Should the project avoid section headers entirely for tiny ELF files?
7. Should the ELF standard-library layer be explicitly separate from `dud-sh` kernel semantics?
8. Should AGENTS require tests that verify `p_filesz` and `p_memsz` offsets/values?
9. Should syscall numbers be centralized in docs/fragments?
10. How should endianness be documented and tested?

### K. Fragment, marker, and sealed-gadget discipline

1. Should `AGENTS.md` include the rule that open fragments must not emit relative jumps?
2. Should relative jumps be allowed only inside sealed gadgets?
3. Should sealed gadget files require a standard header like:

   ```sh
   # sealed gadget
   # emits:
   # inputs:
   # outputs:
   # clobbers:
   # local relative offsets:
   # provenance:
   ```

4. Should open dot-sourced fragments require a standard header like:

   ```sh
   # open fragment
   # emits:
   # expects:
   # preserves:
   # must not contain relative jumps
   # provenance:
   ```

5. Should marker records be executable no-ops?
6. Should the marker format `90 6a ID 8d 64 24 04` be treated as settled or provisional?
7. Should generated code reserve `0x90` NOP for marker starts when practical?
8. How should accidental marker-shaped byte sequences be avoided/tested?
9. Should leaf instruction files be single-purpose and tiny even if that increases file count?
10. Should parameterized fragments using `set --` be encouraged early or minimized?

### L. Agent behavior and repo workflow

1. If an agent finds itself on `main`, should it refuse all edits, ask before editing, or create/switch to an agent branch automatically?
2. Should WIP commits be forbidden unless explicitly requested?
3. Should every passing change be committed automatically?
4. Should agents open/update PRs automatically when GitHub tooling is available?
5. Should a minimal PR summary format be included now despite detailed PR best practices being deferred?
6. Should the placeholder PR format be:

   ```text
   Summary
   Tests
   Provenance
   Risks / Review notes
   ```

7. Should agents be allowed to modify `AGENTS.md` itself after it exists?
8. Should `AGENTS.md` modification require a dedicated commit?
9. Should agents read nested `AGENTS.md` files from root to leaf?
10. Should broad filesystem scans remain allowed?
11. What write whitelist should be encoded?
12. Should agents be forbidden from writing outside the repo and `.tmp/`?
13. Should agents be allowed to use web search freely for technical validation?
14. What exact after-edit report should agents produce?
15. Should relevant test output be included verbatim in commit messages or just in chat/PR summaries?

### M. Documentation and literate code style

1. How should the intended linear reading path be documented?
2. Should the root README explain the whole bootstrap ladder or only the current milestone?
3. Should each subproject have its own README and AGENTS?
4. Should byte-emitting files contain detailed comments or mostly references to docs?
5. How should “first time this appears” be tracked across files?
6. Should docs be organized by concept, e.g. `docs/elf32.md`, `docs/i386.md`, `docs/dud-sh-language.md`?
7. Should source comments include `@./docs/...` references?
8. Should raw external URLs appear in source comments, docs only, or both?
9. Should comments in `.dsh`/`.sh` files be whole-line only to remain valid `dud-sh`?
10. How verbose should generated-byte comments be?

### N. Provenance, research, and source-copying rules

1. What source types are acceptable for facts/specs?
2. Should official specs/man pages be required for instruction encodings and ELF fields when available?
3. Is OSDev wiki acceptable only as a secondary/bridging source?
4. Should Stack Overflow be effectively prohibited for code and discouraged for facts?
5. Should blog posts be allowed only as idea sources with citations?
6. Should AGENTS explicitly forbid copying generated code or substantial third-party code verbatim?
7. How should agents cite sources in source files?
8. How should agents cite sources in docs?
9. What must agents do if sources disagree?
10. Should provenance be required for every opaque byte sequence?

### O. Licensing

1. Should `LICENSE` be created as 0BSD during initial setup?
2. Should AGENTS say “prefer 0BSD unless the owner overrides it”?
3. Should Unlicense or CC0 remain mentioned, or would that create confusion?
4. Should generated code and docs use the same license?
5. Is a public-domain-like license compatible with the project's expected external contributions?

### P. Future-feature policy

1. How should AGENTS prevent premature expansion of `dud-sh`?
2. Should future features such as `exec`, fd redirection, `$0`, `$#`, `shift`, and pipelines be listed as reserved/future?
3. Should the language have versioned profiles, e.g. `dsh0`, `dsh1`?
4. Should future host implementations be encouraged immediately or after a conformance suite exists?
5. Should `dud-asm` and `dud-cc` be mentioned only as long-term context?
6. Should agents be told not to optimize for conventional assembler design too early?
7. How should compatibility be maintained as the subset evolves?

### Q. Risk register / ask-before-changing rules

1. What choices could accidentally make `dud-sh` grow into a full shell?
2. What choices could create hidden host dependencies?
3. What choices could make future non-shell implementations hard?
4. What choices could make byte provenance unauditable?
5. What choices could make tests host-specific?
6. What choices could make the bootstrap graph circular?
7. What choices could make the source unreadable despite being “minimal”?
8. What choices could create licensing/copyright risk?
9. What changes must always require owner approval?
10. What changes should agents reject even if asked casually?

---

## 8. Required research output format

The researcher should produce a report with this structure:

```text
1. Executive summary
2. Assumptions and source basis
3. Proposed answer sets
   - Set A
   - Set B
   - Set C
   - optional Set D/E
4. Decision matrix
5. Recommended default set
6. Detailed answers to open questions
7. Open risks and mitigations
8. Questions still requiring project-owner taste
9. Suggested AGENTS.md implications
10. Sources consulted
```

Each answer set must be internally coherent and must cover at least:

```text
- language subset
- tokenization/quoting rule
- byte emission convention
- printf portability stance
- source file extension convention
- repo layout refinements
- generated artifact location
- scratch policy
- test strategy
- conformance strictness
- ELF/i386 provenance policy
- fragment/gadget discipline
- documentation style
- agent workflow rules
- first milestone wording
- future-feature policy
- license action
```

For each answer set, include:

```text
- what it optimizes for
- what it sacrifices
- why it fits or conflicts with the owner's priorities
- risks
- mitigations
- what AGENTS.md would say differently under this set
```

The decision matrix should compare answer sets on at least:

```text
correctness
bootstrap coherence
POSIX portability
implementation speed
simplicity
learnability/literacy
maintainability
future host-implementation ease
conformance-test clarity
hidden dependency risk
risk of becoming a full shell
```

Use a simple score or qualitative ranking. Explain any surprising scores.

---

## 9. Suggested answer-set archetypes

The researcher may choose different archetypes, but these are likely useful.

### Set A: Maximal POSIX portability

Likely traits:

```text
- octal escapes in source
- hex shown in comments/docs
- avoid non-POSIX printf features
- very strict host assumptions
- tests emphasize /bin/sh compatibility
- slower ergonomics, stronger portability story
```

### Set B: Pragmatic bootstrap velocity

Likely traits:

```text
- hex escapes in source
- fail fast if printf lacks \xNN
- faster byte authoring/review
- clear admission that this requires a common printf extension
- stronger early progress, weaker strict POSIX story
```

### Set C: Tiny-kernel purity

Likely traits:

```text
- extremely narrow language subset
- no mention of future features except as ask-first reserved items
- no exec until actively implemented
- strict no-PATH/no-extra-utilities rule
- may slow down modular output ergonomics
```

### Set D: Literate conformance-first

Likely traits:

```text
- source and docs optimized for a reader implementing dsh in another language
- standard headers for fragments/gadgets
- heavy use of docs and provenance
- tests organized as conformance cases from day one
- possibly more files and more initial process overhead
```

### Set E: Multi-host challenge

Likely traits:

```text
- treat dud-sh as a koan/kata from the start
- define versioned conformance profiles such as dsh0/dsh1
- explicitly encourage reference implementations
- tests designed for many hosts
- may risk abstracting too early
```

The researcher does not need to use these exact sets, but should produce at least three coherent alternatives.

---

## 10. Blind-spot checklist

Before finalizing the report, the researcher should audit coverage against these lenses. For each lens, state either “covered” or add missing questions.

### Portability

```text
POSIX sh
printf behavior
chmod behavior
shell builtins vs external utilities
host OS assumptions
filesystem/executable-bit assumptions
line endings
locale
running i386 Linux ELF
```

### Bootstrap graph

```text
first artifact
what produces what
what must already exist
when generated executables become dependencies
how to avoid circular dependencies
how patch-elf enables later stages
```

### Language design

```text
tokenization
quoting
comments
redirection
positional args
set -e
command dispatch
future expansion
invalid scripts
exit status
```

### Binary correctness

```text
ELF fields
i386 instruction encodings
Linux syscall ABI
endianness
patching offsets
generated executable invariants
marker/gadget byte patterns
relative jump discipline
```

### Conformance

```text
test oracle
byte-for-byte output
exit statuses
invalid-script behavior
stderr non-requirement
host implementation compatibility
optional native-exec tests
```

### Repo hygiene

```text
write whitelist
generated artifacts
.tmp/.bin usage
branch safety
commits
PRs
nested AGENTS.md behavior
```

### Documentation

```text
linear reading path
first-time explanations
out-of-line docs
provenance comments
learner-friendly byte docs
source comment rules
```

### Legal / provenance

```text
license
source citation rules
external code-copying prohibition
acceptable references
what to do when sources disagree
```

### Agent behavior

```text
what to inspect before edits
when to ask
when to browse
what to report after edits
what never to change silently
how to treat main branch
```

### Future scope

```text
exec
fd redirection
$0 / $# / shift
pipelines
dud-asm
dud-cc
multi-host implementations
versioned profiles
```

---

## 11. What the researcher should not do

Do not write `AGENTS.md`.

Do not collapse to one answer immediately. Provide multiple coherent proposed answer sets first.

Do not assume `dud-sh` should grow into a general shell.

Do not optimize for conventional assembler design too early.

Do not ignore the current `patch-elf` / `patch-elf-modular` bootstrap report.

Do not recommend dependencies casually.

Do not recommend GNU-only tools for runtime/bootstrap source.

Do not copy code from external sources.

Do not treat exact shell error messages as conformance requirements.

Do not assume all hosts can run i386 Linux ELF without stating that assumption.

Do not assume the later `dud-asm` design should drive the first `dud-sh` milestone.

---

## 12. Research/source guidance

When making factual claims about standards, encodings, executable formats, syscall numbers, licenses, or portability, use current and authoritative sources where possible.

Prefer:

```text
official specifications
POSIX documentation
processor/vendor manuals
Linux man pages
ELF/System V ABI materials
license texts from authoritative license sources
```

Accept with caution:

```text
OSDev wiki
well-maintained project docs
historical bootstrapping project writeups
```

Discourage:

```text
Stack Overflow as primary authority
random code snippets
uncited blog claims
generated code from other systems
```

The report should cite sources for external facts. If sources disagree, describe the disagreement and recommend a conservative rule.

---

## 13. Deliverable expected from the researcher

Produce a report, not a repo patch.

The report should let the owner pick one of several coherent futures for the initial `AGENTS.md`.

At the end, include a compact “decision ballot” the owner can answer, for example:

```text
Pick one:
[ ] A: portability-first
[ ] B: velocity-first
[ ] C: tiny-kernel-first
[ ] D: literate-conformance-first
[ ] custom mix: __________

Must-decide items:
1. hex or octal in source
2. .sh or .dsh for shared scripts
3. generated artifacts under .bin/ or local cwd
4. exec mentioned now or deferred
5. root-only AGENTS.md or nested AGENTS.md files now
```

Also include any additional high-impact questions the researcher thinks are missing from this prompt.
