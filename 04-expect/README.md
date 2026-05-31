# 04-expect

`expect` is not built by the root `./runme.sh` bootstrap.

After root bootstrap has prepared `./.dud/musl-cc`, build and test `expect`
with:

```sh
./04-expect/runme.sh \
    --expect-dir ./04-expect \
    --cc ./.dud/musl-cc \
    --out-dir ./.dud
```
