# Capability Policy

Default:

```text
--cap-drop ALL
```

For hostile code, capabilities should almost never be added back.

Avoid exposing:

```text
CAP_SYS_ADMIN
CAP_NET_ADMIN
CAP_SYS_PTRACE
CAP_SYS_MODULE
CAP_SYS_RAWIO
CAP_MKNOD
CAP_DAC_OVERRIDE
CAP_DAC_READ_SEARCH
CAP_CHOWN
CAP_SETUID
CAP_SETGID
CAP_SETPCAP
CAP_SYS_CHROOT
CAP_SYS_RESOURCE
```

Preferred pattern:

```text
if a capability is needed, use it during bwrap/loader setup only
create the required object
drop the capability
then jump to hostile code without it
```

Do not give the target `CAP_SYS_ADMIN`.
