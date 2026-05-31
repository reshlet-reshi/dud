# Strict Baseline `bwrap` Shape

Use explicit namespace flags rather than `--unshare-all`.

strict mode should fail closed if an isolation feature is unavailable.

```sh
bwrap \
  --unshare-user \
  --unshare-ipc \
  --unshare-pid \
  --unshare-net \
  --unshare-uts \
  --unshare-cgroup \
  --disable-userns \
  --assert-userns-disabled \
  --uid 65534 \
  --gid 65534 \
  --hostname x \
  --die-with-parent \
  --new-session \
  --as-pid-1 \
  --cap-drop ALL \
  --clearenv \
  --size "$ROOTFS_SIZE" --tmpfs / \
  --perms 0555 --file "$LOADER_FD" /init \
  --perms 0444 --file "$TARGET_FD" /target \
  --remount-ro / \
  --chdir / \
  --argv0 init \
  -- \
  /init /target \
  </dev/null >/dev/null 2>/dev/null
```

## Important properties

```text
--unshare-user
  create a private user namespace

--unshare-ipc
  no shared SysV/POSIX IPC with host

--unshare-pid
  private PID namespace

--unshare-net
  private network namespace; no host networking

--unshare-uts
  private hostname/domain namespace

--unshare-cgroup
  private cgroup namespace; fail closed if unavailable

--disable-userns
  target cannot create further user namespaces

--assert-userns-disabled
  fail if nested user namespaces were not actually disabled

--uid 65534 --gid 65534
  run as nobody-like user inside sandbox, not uid 0

--hostname x
  avoid leaking host identity

--die-with-parent
  sandbox dies if supervisor dies

--new-session
  reduce terminal/session coupling

--as-pid-1
  trusted loader becomes PID 1

--cap-drop ALL
  no capabilities exposed to the payload phase

--clearenv
  no inherited environment

--size ... --tmpfs /
  empty in-memory root with bounded size

--file FD /init
  copy trusted loader into sandbox; do not bind-mount host path

--file FD /target
  copy hostile target bytes into sandbox

--remount-ro /
  root filesystem read-only after setup

--chdir /
  known safe cwd

stdio redirection
  no stdin/stdout/stderr channel
```

Do **not** add these in the baseline:

```text
--proc /proc
--dev /dev
--bind
--ro-bind /
--share-net
host /tmp
host /home
DBus sockets
Wayland/X11 sockets
SSH agent sockets
Docker/Podman sockets
```
