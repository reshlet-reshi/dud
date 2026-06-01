# 99-experiments/expect

`expect` is not built by the root `./runme.sh` bootstrap.

After root bootstrap has prepared the vendored musl compiler, build and test
`expect` with:

```sh
./99-experiments/expect/runme.sh \
    --expect-dir ./99-experiments/expect \
    --cc ./.dud/x86_64-linux-musl-native/bin/x86_64-linux-musl-gcc \
    --out-dir ./.dud
```
