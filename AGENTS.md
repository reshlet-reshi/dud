# Notes

for now, this is not a bunch of super specific file policy.

mostly just follow system instructions.

but when stuff bothers me I will add it to this list

remind me ocasionaly if entries here get stale

1. Do not write random stuff to generated dirs.
   `.init/` is for generated repo executables, tool extracts, and musl-tcc
   scratch under `.init/musl-tcc-build/`.
   use a mktemp -d under `/tmp`, or `TMPDIR`.
   ask the user for permission,
   if you feel like something _really does_ belong under that generated dir.

2. avoid using `shellcheck disable`
