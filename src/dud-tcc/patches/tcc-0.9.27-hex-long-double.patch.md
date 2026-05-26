# src/dud-tcc/patches/tcc-0.9.27-hex-long-double.patch

This note is the evidence trail for
`src/dud-tcc/patches/tcc-0.9.27-hex-long-double.patch`.

## What The Patch Does

The patch changes TCC 0.9.27's hexadecimal and binary floating literal parser
to keep an intermediate `long double` value when the literal has an `L` suffix.

The original code computed the value through `double`:

```c
d = (double)bn[1] * 4294967296.0 + (double)bn[0];
d = ldexp(d, exp_val - frac_bits);
tokc.ld = (long double)d;
```

The patched code uses `ldexpl` for the exponent step and only narrows to
`double` for the existing float/double token paths.

## Why This Exists

Going through `double` underflows values that are valid 80-bit long doubles,
including `0x1p-16382L` and `0x1p-16445L`. That means source-level hex
long-double constants can become zero before TCC stores them in `tokc.ld`.

The patch fixes that exponent-range bug for `L` suffix literals. It is not a
complete rewrite of TCC's hex-float precision model; the parser still only
accumulates the existing two-word `bn` value.

This also fixes decimal `LDBL_MIN` and `LDBL_TRUE_MIN` in the final compiler
indirectly. TCC parses decimal long-double literals with `strtold`, and the
bootstrap `strtold` comes from the musl libc built by this compiler. Musl's
`scalbnl.c` contains hexadecimal long-double constants in the underflow path;
when TCC compiled those as zero, `strtold` near the bottom of the 80-bit range
returned zero. Fixing TCC's hex long-double parser lets musl's `scalbnl` build
correctly, which makes `strtold` and then decimal long-double constants work.

## Expected Result

The final bootstrap compiler should compile `0x1p-16382L` to `LDBL_MIN` and
`0x1p-16445L` to `LDBL_TRUE_MIN`, rather than zero.
