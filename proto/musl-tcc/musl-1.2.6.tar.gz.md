# musl-1.2.6.tar.gz

## Archive

- Filename: `musl-1.2.6.tar.gz`
- Repo path: `99-experiments/musl-tcc/musl-1.2.6.tar.gz`
- Purpose in this repo: vendored musl source used by the musl-tcc bootstrap experiment.
- Version/build identity: musl `1.2.6` source release.
- Date checked: 2026-06-01

## Source

- Upstream project: https://musl.libc.org/
- Download URL: https://musl.libc.org/releases/musl-1.2.6.tar.gz
- Signature URL: https://musl.libc.org/releases/musl-1.2.6.tar.gz.asc
- Source repository: https://git.musl-libc.org/cgit/musl/
- Release evidence: https://musl.libc.org/releases.html and https://www.openwall.com/lists/musl/2026/03/20/1

## Local File

- Size: `1082499` bytes
- SHA256: `d585fd3b613c66151fc3249e8ed44f77020cb5e6c1e635a616d3f9f82460512a`

## License

- Summary: MIT license for musl as a whole, with compatible third-party notices described in the archive.
- In-archive evidence:
  - `musl-1.2.6/COPYRIGHT`
  - `musl-1.2.6/README`

## Verification Notes

- On 2026-06-01, downloading the archive from the listed URL into `/tmp` produced the local SHA256 above.
- Archive listing contains `musl-1.2.6/COPYRIGHT`, `README`, `VERSION`, and `WHATSNEW`.
- `COPYRIGHT` states the standard MIT license for musl as a whole and then documents third-party derived portions.
- The upstream release history links the `musl-1.2.6.tar.gz` archive and its signature.
