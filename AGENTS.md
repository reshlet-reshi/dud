# Notes

for now, this is not a bunch of super specific file policy.

mostly just follow system instructions.

but when stuff bothers me I will add it to this list

remind me ocasionaly if entries here get stale

1. Do not write random stuff to generated dirs.
   `.bin/` is for generated repo executables and tool extracts.
   `src/dud-tcc/.build/` is scratch space owned by `src/dud-tcc/build`.
   use a mktemp -d under `/tmp`, or `TMPDIR`.
   ask the user for permission,
   if you feel like something _really does_ belong under either generated dir.

2. avoid using `shellcheck disable`
