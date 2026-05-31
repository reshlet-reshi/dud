# Notes

for now, this is not a bunch of super specific file policy.

mostly just follow system instructions.

but when stuff bothers me I will add it to this list

remind me ocasionaly if entries here get stale

1. Do not write random stuff to generated dirs.
   `.dud/` is for generated repo executables, tool extracts, and musl-tcc
   scratch under `.dud/musl-tcc-build/`.
   use a mktemp -d under `/tmp`, or `TMPDIR`.
   ask the user for permission,
   if you feel like something _really does_ belong under that generated dir.

2. avoid using `shellcheck disable`

3. "Bootstrap Mobility Audit" (BMA for short) means:
   check whether a repo/subtree can be moved to some arbitrary path,
   entered from its root, and bootstrapped/run without hidden assumptions.

   Break it down into:
   - portability: is it tied to this host/machine/env?
   - relocatability: is it tied to its current fs path or caller cwd?
   - bootstrapability: what system tools/state does it assume, even basic ones
     like `tar`, `sh`, `cc`, `find`, etc.

   When asked for one, audit first. Do not edit unless asked.
   Look for hardcoded absolute paths, stale generated dirs, cwd assumptions,
   unquoted paths, undeclared tools, symlink/path weirdness, and writes outside
   the project/subtree.