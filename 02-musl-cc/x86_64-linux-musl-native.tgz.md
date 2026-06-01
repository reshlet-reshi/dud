# x86_64-linux-musl-native.tgz

## Archive

- Filename: `x86_64-linux-musl-native.tgz`
- Repo path: `02-musl-cc/x86_64-linux-musl-native.tgz`
- Purpose in this repo: vendored native musl GCC toolchain used by `02-musl-cc/runme.sh`.
- Version/build identity: musl.cc `x86_64-linux-musl-native` toolchain, published 2021-11-23, GCC `11.2.1`.
- Date checked: 2026-06-01

## Source

- Upstream project/distribution: https://musl.cc/
- Download URL: https://musl.cc/x86_64-linux-musl-native.tgz
- Source/build evidence: https://musl.cc/ describes these as static musl-based toolchains built using modified musl-cross-make style scripts and lists the component versions.
- Component sources referenced upstream include:
  - musl: https://git.musl-libc.org/cgit/musl/
  - GCC: https://ftp.gnu.org/gnu/gcc/
  - binutils: https://ftp.gnu.org/gnu/binutils/
  - Linux: https://www.kernel.org/

## Local File

- Size: `89080066` bytes
- SHA256: `eb1db6f0f3c2bdbdbfb993d7ef7e2eeef82ac1259f6a6e1757c33a97dbcef3ad`

## License

- Summary: composite binary toolchain; no single SPDX license applies to the archive as a whole.
- Major components have their own licenses, including GNU licenses for GCC/binutils-related components, MIT for musl, and the relevant upstream terms for Linux headers, GMP, MPFR, and MPC.
- In-archive evidence:
  - No top-level license manifest was found in the archive.
  - The archive includes GNU manpage license files under `x86_64-linux-musl-native/share/man/man7/`, including `gpl.7` and `gfdl.7`.

## Verification Notes

- On 2026-06-01, downloading the archive from the listed URL into `/tmp` produced the local SHA256 above.
- Archive listing contains `x86_64-linux-musl-native/bin/x86_64-linux-musl-gcc` and GCC `11.2.1` paths.
- musl.cc lists `x86_64-linux-musl-native.tgz` with size `89080066` bytes and the matching publication date.
- This sidecar records provenance for the binary distribution, not a reproducibility claim for rebuilding it from source.
