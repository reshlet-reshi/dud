# 99-experiments/musl-tcc

`musl-tcc` is not built by the root `./runme.sh` bootstrap.

After root bootstrap has prepared `./.dud/smoke-cc` and the vendored musl
compiler, build and test `musl-tcc` with:

```sh
./99-experiments/musl-tcc/runme.sh \
    --musl-tcc-dir ./99-experiments/musl-tcc \
    --bootstrap-cc ./.dud/x86_64-linux-musl-native/bin/x86_64-linux-musl-gcc \
    --smoke-cc ./.dud/smoke-cc \
    --install-dir ./.dud/musl-tcc \
    --work-dir ./.dud/musl-tcc-build \
    --tar /usr/bin/tar \
    --patch /usr/bin/patch \
    --sed /usr/bin/sed \
    --find /usr/bin/find \
    --sort /usr/bin/sort \
    --grep /usr/bin/grep \
    --cmp /usr/bin/cmp \
    --sha256sum /usr/bin/sha256sum \
    --chmod /usr/bin/chmod \
    --cp /usr/bin/cp \
    --rm /usr/bin/rm \
    --mv /usr/bin/mv \
    --mkdir /usr/bin/mkdir \
    --dd /usr/bin/dd \
    --tr /usr/bin/tr \
    --dirname /usr/bin/dirname
```

The final installed tree is written to `--install-dir`. Scratch and fixed-point
build artifacts are written to `--work-dir`.
