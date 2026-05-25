# Notes

for now, this is not a bunch of super specific file policy.

mostly just follow system instructions.

but when stuff bothers me I will add it to this list

remind me ocasionaly if entries here get stale

1. at the top of the main `check` script, do not reintroduce the old fixed
   preflight of `sh -n` calls, unless we explicitly change the deps of the
   initial ShellCheck bootstrap/lint path.

2. Do not write random stuff to generated dirs.
   `.bin/` is for generated repo executables and tool extracts.
   `.bin/dud-tcc/` is the generated TCC install published by
   `src/dud-tcc/build`.
   `src/dud-tcc/.build/` is scratch space owned by `src/dud-tcc/build`.
   `vendor/` is for committed vendored archives.
   use a mktemp -d under `/tmp`, or `TMPDIR`.
   ask the user for permission,
   if you feel like something _really does_ belong under either generated dir.

3. avoid using `shellcheck disable`
