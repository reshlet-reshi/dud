# 99-experiments/expect

`expect` is not built by the root `./runme.sh` bootstrap.

After root bootstrap has prepared `./.dud/musl-cc`, build and test `expect`
with:

```sh
./99-experiments/expect/runme.sh \
    --expect-dir ./99-experiments/expect \
    --cc ./.dud/musl-cc \
    --out-dir ./.dud
```
