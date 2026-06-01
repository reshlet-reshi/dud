#!/bin/sh
set -eu

# Keep sort/archive input order independent of the caller's terminal locale.
LC_ALL=C
export LC_ALL

usage() {
    printf '%s\n' \
        'usage: proto/musl-tcc/build-from-seed.sh --musl-tcc-dir DIR --seed-cc CC --out-dir DIR --work-dir DIR --tar TAR --patch PATCH --sed SED --find FIND --sort SORT --grep GREP --cmp CMP --cp CP --rm RM --mv MV --mkdir MKDIR --dd DD --tr TR --dirname DIRNAME' \
        >&2
}

usage_error() {
    printf '%s\n' "$1" >&2
    usage
    exit 2
}

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

require_command_path() {
    require_command_path_label=$1
    require_command_path_value=$2

    if ! command -v "$require_command_path_value" >/dev/null 2>&1; then
        printf 'missing executable %s: %s\n' \
            "$require_command_path_label" \
            "$require_command_path_value" >&2
        exit 1
    fi

    unset require_command_path_label require_command_path_value
}

absolute_path() {
    absolute_path_value=$1

    case "$absolute_path_value" in
        /*)
            printf '%s\n' "$absolute_path_value"
            ;;
        */*)
            absolute_path_dir=${absolute_path_value%/*}
            absolute_path_base=${absolute_path_value##*/}
            absolute_path_dir=$(
                CDPATH=
                cd "$absolute_path_dir" &&
                    pwd
            )
            printf '%s/%s\n' "$absolute_path_dir" "$absolute_path_base"
            unset absolute_path_dir absolute_path_base
            ;;
        *)
            command -v "$absolute_path_value"
            ;;
    esac

    unset absolute_path_value
}

absolute_dir() {
    absolute_dir_value=$1
    absolute_dir_result=$(
        CDPATH=
        cd "$absolute_dir_value" &&
            pwd
    )
    printf '%s\n' "$absolute_dir_result"
    unset absolute_dir_value absolute_dir_result
}

musl_tcc_dir=
seed_cc=
build=
work_dir=
tar=
patch=
sed=
find=
sort=
grep=
cmp=
cp=
rm=
mv=
mkdir=
dd=
tr=
dirname=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --musl-tcc-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --musl-tcc-dir'
            musl_tcc_dir=$2
            shift 2
            ;;
        --seed-cc)
            [ "$#" -ge 2 ] || usage_error 'missing value for --seed-cc'
            seed_cc=$2
            shift 2
            ;;
        --out-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --out-dir'
            build=$2
            shift 2
            ;;
        --work-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --work-dir'
            work_dir=$2
            shift 2
            ;;
        --tar)
            [ "$#" -ge 2 ] || usage_error 'missing value for --tar'
            tar=$2
            shift 2
            ;;
        --patch)
            [ "$#" -ge 2 ] || usage_error 'missing value for --patch'
            patch=$2
            shift 2
            ;;
        --sed)
            [ "$#" -ge 2 ] || usage_error 'missing value for --sed'
            sed=$2
            shift 2
            ;;
        --find)
            [ "$#" -ge 2 ] || usage_error 'missing value for --find'
            find=$2
            shift 2
            ;;
        --sort)
            [ "$#" -ge 2 ] || usage_error 'missing value for --sort'
            sort=$2
            shift 2
            ;;
        --grep)
            [ "$#" -ge 2 ] || usage_error 'missing value for --grep'
            grep=$2
            shift 2
            ;;
        --cmp)
            [ "$#" -ge 2 ] || usage_error 'missing value for --cmp'
            cmp=$2
            shift 2
            ;;
        --cp)
            [ "$#" -ge 2 ] || usage_error 'missing value for --cp'
            cp=$2
            shift 2
            ;;
        --rm)
            [ "$#" -ge 2 ] || usage_error 'missing value for --rm'
            rm=$2
            shift 2
            ;;
        --mv)
            [ "$#" -ge 2 ] || usage_error 'missing value for --mv'
            mv=$2
            shift 2
            ;;
        --mkdir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --mkdir'
            mkdir=$2
            shift 2
            ;;
        --dd)
            [ "$#" -ge 2 ] || usage_error 'missing value for --dd'
            dd=$2
            shift 2
            ;;
        --tr)
            [ "$#" -ge 2 ] || usage_error 'missing value for --tr'
            tr=$2
            shift 2
            ;;
        --dirname)
            [ "$#" -ge 2 ] || usage_error 'missing value for --dirname'
            dirname=$2
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage_error "unknown argument: $1"
            ;;
    esac
done

[ -n "$musl_tcc_dir" ] || usage_error 'missing required --musl-tcc-dir'
[ -n "$seed_cc" ] || usage_error 'missing required --seed-cc'
[ -n "$build" ] || usage_error 'missing required --out-dir'
[ -n "$work_dir" ] || usage_error 'missing required --work-dir'
[ -n "$tar" ] || usage_error 'missing required --tar'
[ -n "$patch" ] || usage_error 'missing required --patch'
[ -n "$sed" ] || usage_error 'missing required --sed'
[ -n "$find" ] || usage_error 'missing required --find'
[ -n "$sort" ] || usage_error 'missing required --sort'
[ -n "$grep" ] || usage_error 'missing required --grep'
[ -n "$cmp" ] || usage_error 'missing required --cmp'
[ -n "$cp" ] || usage_error 'missing required --cp'
[ -n "$rm" ] || usage_error 'missing required --rm'
[ -n "$mv" ] || usage_error 'missing required --mv'
[ -n "$mkdir" ] || usage_error 'missing required --mkdir'
[ -n "$dd" ] || usage_error 'missing required --dd'
[ -n "$tr" ] || usage_error 'missing required --tr'
[ -n "$dirname" ] || usage_error 'missing required --dirname'

if [ ! -d "$musl_tcc_dir" ]; then
    fail "missing musl-tcc directory: $musl_tcc_dir"
fi
musl_tcc_dir=$(absolute_dir "$musl_tcc_dir")

require_command_path 'seed C compiler' "$seed_cc"
require_command_path tar "$tar"
require_command_path patch "$patch"
require_command_path sed "$sed"
require_command_path find "$find"
require_command_path sort "$sort"
require_command_path grep "$grep"
require_command_path cmp "$cmp"
require_command_path cp "$cp"
require_command_path rm "$rm"
require_command_path mv "$mv"
require_command_path mkdir "$mkdir"
require_command_path dd "$dd"
require_command_path tr "$tr"
require_command_path dirname "$dirname"

seed_cc=$(absolute_path "$seed_cc")
tar=$(absolute_path "$tar")
patch=$(absolute_path "$patch")
sed=$(absolute_path "$sed")
find=$(absolute_path "$find")
sort=$(absolute_path "$sort")
grep=$(absolute_path "$grep")
cmp=$(absolute_path "$cmp")
cp=$(absolute_path "$cp")
rm=$(absolute_path "$rm")
mv=$(absolute_path "$mv")
mkdir=$(absolute_path "$mkdir")
dd=$(absolute_path "$dd")
tr=$(absolute_path "$tr")
dirname=$(absolute_path "$dirname")

tcc_tarball=$musl_tcc_dir/tcc-0.9.27.tar.bz2
musl_tarball=$musl_tcc_dir/musl-1.2.6.tar.gz
patch_dir=$musl_tcc_dir/patches
test_dir=$musl_tcc_dir/test

for required_file in \
    "$tcc_tarball" \
    "$musl_tarball" \
    "$patch_dir/tcc-0.9.27-tccelf.patch" \
    "$patch_dir/tcc-0.9.27-self-lib-path.patch" \
    "$patch_dir/tcc-0.9.27-static-only.patch" \
    "$patch_dir/tcc-0.9.27-no-complex.patch" \
    "$patch_dir/tcc-0.9.27-hex-long-double.patch" \
    "$patch_dir/musl-1.2.6-tcc-array-static.patch" \
    "$patch_dir/musl-1.2.6-tcc-no-plt.patch" \
    "$patch_dir/musl-1.2.6-tcc-va-list.patch" \
    "$musl_tcc_dir/stdarg.h" \
    "$musl_tcc_dir/syscall_arch.h" \
    "$musl_tcc_dir/tcc-syscall-x86_64.s" \
    "$test_dir/tcc0-start.c" \
    "$test_dir/tcc0-func-start.c" \
    "$test_dir/tcc0-func-foo.c" \
    "$test_dir/tcc0-data-start.c" \
    "$test_dir/tcc0-data-data.c" \
    "$test_dir/tcc1-smoke.c" \
    "$test_dir/tcc1-ldbl-min.c"
do
    if [ ! -f "$required_file" ]; then
        fail "missing musl-tcc input: $required_file"
    fi
done

"$rm" -rf "$work_dir" "$build"
"$mkdir" -p "$work_dir" "$build"
work_dir=$(absolute_dir "$work_dir")
build=$(absolute_dir "$build")

# unpack tcc src
"$tar" -xjf "$tcc_tarball" -C "$work_dir"
tcc_src=$work_dir/tcc-0.9.27

# empty config.h
: > "$tcc_src/config.h"

# SEE proto/musl-tcc/patches/tcc-0.9.27-tccelf.patch.md
"$patch" -s -d "$tcc_src" -p0 < "$patch_dir/tcc-0.9.27-tccelf.patch"

# SEE proto/musl-tcc/patches/tcc-0.9.27-self-lib-path.patch.md
"$patch" -s -d "$tcc_src" -p0 < "$patch_dir/tcc-0.9.27-self-lib-path.patch"

# SEE proto/musl-tcc/patches/tcc-0.9.27-static-only.patch.md
"$patch" -s -d "$tcc_src" -p0 < "$patch_dir/tcc-0.9.27-static-only.patch"

# SEE proto/musl-tcc/patches/tcc-0.9.27-no-complex.patch.md
"$patch" -s -d "$tcc_src" -p0 < "$patch_dir/tcc-0.9.27-no-complex.patch"

# SEE proto/musl-tcc/patches/tcc-0.9.27-hex-long-double.patch.md
"$patch" -s -d "$tcc_src" -p0 < "$patch_dir/tcc-0.9.27-hex-long-double.patch"

# tcc0
tcc0=$build/tcc0
(
    cd "$tcc_src"
    "$seed_cc" -g3 -O0 -w \
        -static \
        -I . \
        -o "$tcc0" \
        '-DTCC_TARGET_X86_64=1' \
        '-DCONFIG_TCCBOOT=1' \
        '-DCONFIG_TCCDIR=""' \
        '-DCONFIG_TCC_CRTPREFIX=""' \
        '-DCONFIG_TCC_LIBPATHS=""' \
        '-DCONFIG_TCC_SYSINCLUDEPATHS=""' \
        '-DCONFIG_TCC_STATIC=1' \
        '-DTCC_VERSION="0.9.27"' \
        '-DONE_SOURCE=1' \
        tcc.c
)

# smoke test tcc0
"$tcc0" -static -nostdlib \
    "$test_dir/tcc0-start.c" \
    -o "$work_dir/start"
"$work_dir/start"
"$tcc0" -static -nostdlib \
    "$test_dir/tcc0-func-start.c" \
    "$test_dir/tcc0-func-foo.c" \
    -o "$work_dir/tcc0-func"
"$work_dir/tcc0-func"
"$tcc0" \
    -static \
    -nostdlib \
    "$test_dir/tcc0-data-start.c" \
    "$test_dir/tcc0-data-data.c" \
    -o "$work_dir/tcc0-data"
"$work_dir/tcc0-data"

# libtcc1.a
(
    cd "$tcc_src"
    "$tcc0" -c lib/libtcc1.c -o "$build/libtcc1.o"
    "$tcc0" -c lib/alloca86_64.S -o "$build/alloca86_64.o"
    "$tcc0" -c lib/alloca86_64-bt.S -o "$build/alloca86_64-bt.o"
    "$tcc0" -c lib/va_list.c -o "$build/va_list.o"
)
"$tcc0" -ar rcs "$build/libtcc1.a" \
    "$build/libtcc1.o" \
    "$build/alloca86_64.o" \
    "$build/alloca86_64-bt.o" \
    "$build/va_list.o"
"$rm" "$build/libtcc1.o"
"$rm" "$build/alloca86_64.o"
"$rm" "$build/alloca86_64-bt.o"
"$rm" "$build/va_list.o"

# unpack musl
"$tar" -xzf "$musl_tarball" -C "$work_dir"
musl_src=$work_dir/musl-1.2.6
musl_obj=$build/musl-obj
musl_lib=$build/lib

# SEE proto/musl-tcc/patches/musl-1.2.6-tcc-array-static.patch.md
"$patch" -s -d "$musl_src" -p0 < "$patch_dir/musl-1.2.6-tcc-array-static.patch"

# SEE proto/musl-tcc/patches/musl-1.2.6-tcc-no-plt.patch.md
"$patch" -s -d "$musl_src" -p0 < "$patch_dir/musl-1.2.6-tcc-no-plt.patch"

# SEE proto/musl-tcc/patches/musl-1.2.6-tcc-va-list.patch.md
"$patch" -s -d "$musl_src" -p0 < "$patch_dir/musl-1.2.6-tcc-va-list.patch"

# SEE proto/musl-tcc/stdarg.h.md
"$cp" "$musl_tcc_dir/stdarg.h" "$musl_src/include/stdarg.h"

# SEE proto/musl-tcc/syscall_arch.h.md
"$cp" "$musl_tcc_dir/syscall_arch.h" "$musl_src/arch/x86_64/syscall_arch.h"

# Create destinations for installed headers and generated musl internals.
"$mkdir" -p \
    "$build/include/bits" \
    "$musl_obj/include/bits" \
    "$musl_obj/src/internal"

# From musl's Makefile rule for obj/include/bits/alltypes.h.
"$sed" \
    -f "$musl_src/tools/mkalltypes.sed" \
    "$musl_src/arch/x86_64/bits/alltypes.h.in" \
    "$musl_src/include/alltypes.h.in" \
    >"$musl_obj/include/bits/alltypes.h"

# From musl's Makefile rule for obj/include/bits/syscall.h.
"$cp" "$musl_src/arch/x86_64/bits/syscall.h.in" \
    "$musl_obj/include/bits/syscall.h"
"$sed" -n -e 's/__NR_/SYS_/p' \
    <"$musl_src/arch/x86_64/bits/syscall.h.in" \
    >>"$musl_obj/include/bits/syscall.h"

# This build uses the vendored musl-1.2.6 tarball, not a git checkout.
printf '%s\n' '#define VERSION "1.2.6"' \
    >"$musl_obj/src/internal/version.h"

# Install musl headers: generic include tree, arch bits, and generated bits.
(
    cd "$musl_src/include"
    "$find" . -type f | "$sort" | while IFS= read -r header; do
        "$mkdir" -p "$build/include/$("$dirname" "$header")"
        "$cp" "$header" "$build/include/$header"
    done
)
"$cp" "$musl_src"/arch/generic/bits/*.h "$build/include/bits"
"$cp" "$musl_src"/arch/x86_64/bits/*.h "$build/include/bits"
"$cp" "$musl_obj/include/bits/alltypes.h" "$build/include/bits/alltypes.h"
"$cp" "$musl_obj/include/bits/syscall.h" "$build/include/bits/syscall.h"

# hygiene
"$rm" "$build/include/alltypes.h.in"

# Compile musl sources with tcc0 using musl's Makefile CFLAGS_ALL shape.
tcc0_musl_cc() {
    "$tcc0" \
        -std=c99 \
        -ffreestanding \
        -nostdinc \
        -D_XOPEN_SOURCE=700 \
        -I "$musl_src/arch/x86_64" \
        -I "$musl_src/arch/generic" \
        -I "$musl_obj/src/internal" \
        -I "$musl_src/src/include" \
        -I "$musl_src/src/internal" \
        -I "$musl_obj/include" \
        -I "$musl_src/include" \
        -Os \
        -pipe \
        "$@"
}

# SEE proto/musl-tcc/musl_source_pipeline.md
musl_base_srcs=$work_dir/musl-base-srcs
musl_arch_srcs=$work_dir/musl-arch-srcs
musl_replaced_objs=$work_dir/musl-replaced-objs
musl_libc_srcs=$work_dir/musl-libc-srcs
musl_libc_objs=$work_dir/musl-libc-objs

# SEE proto/musl-tcc/musl_base_srcs.md
"$find" "$musl_src/src" \
    -mindepth 2 \
    -maxdepth 2 \
    -type f \
    -name '*.c' \
    ! -path "$musl_src/src/complex/*" \
    >"$musl_base_srcs"
"$find" "$musl_src/src/malloc/mallocng" \
    -maxdepth 1 \
    -type f \
    -name '*.c' \
    >>"$musl_base_srcs"
"$sort" "$musl_base_srcs" >"$musl_base_srcs.sorted"
"$mv" "$musl_base_srcs.sorted" "$musl_base_srcs"

# SEE proto/musl-tcc/musl_arch_srcs.md
"$find" "$musl_src/src" \
    -path "$musl_src/src/*/x86_64/*" \
    -type f \
    \( -name '*.c' -o -name '*.s' -o -name '*.S' \) \
    ! -path "$musl_src/src/fenv/x86_64/fenv.s" \
    ! -path "$musl_src/src/math/x86_64/*" \
    ! -path "$musl_src/src/string/x86_64/*" \
    >"$musl_arch_srcs"
"$sort" "$musl_arch_srcs" >"$musl_arch_srcs.sorted"
"$mv" "$musl_arch_srcs.sorted" "$musl_arch_srcs"

# SEE proto/musl-tcc/musl_replaced_objs.md
"$sed" \
    -e "s#^$musl_src/##" \
    -e 's#\.[csS]$#.o#' \
    -e 's#/x86_64/#/#' \
    -e 's#^#obj/#' \
    "$musl_arch_srcs" \
    | "$sort" \
    >"$musl_replaced_objs"

# SEE proto/musl-tcc/musl_libc_srcs.md
: > "$musl_libc_srcs"
while IFS= read -r src_file; do
    rel=${src_file#"$musl_src"/}
    obj=obj/${rel%.*}.o
    if ! "$grep" -F -x "$obj" "$musl_replaced_objs" >/dev/null 2>&1; then
        printf '%s\n' "$rel" >>"$musl_libc_srcs"
    fi
done <"$musl_base_srcs"
"$sed" "s#^$musl_src/##" "$musl_arch_srcs" >>"$musl_libc_srcs"
"$sort" "$musl_libc_srcs" >"$musl_libc_srcs.sorted"
"$mv" "$musl_libc_srcs.sorted" "$musl_libc_srcs"

# SEE proto/musl-tcc/musl_libc_objs.md
: > "$musl_libc_objs"
while IFS= read -r rel; do
    obj=$musl_obj/${rel%.*}.o
    "$mkdir" -p "$("$dirname" "$obj")"
    (cd "$musl_src"; tcc0_musl_cc -c "$rel" -o "$obj")
    printf '%s\n' "$obj" >>"$musl_libc_objs"
done <"$musl_libc_srcs"

# Add generated syscall helper object beside musl internal objects.
"$mkdir" -p "$musl_obj/src/internal"

# SEE proto/musl-tcc/tcc-syscall-x86_64.s.md
"$cp" "$musl_tcc_dir/tcc-syscall-x86_64.s" \
    "$musl_obj/src/internal/tcc-syscall-x86_64.s"
(
    cd "$musl_obj/src/internal"
    "$tcc0" -c tcc-syscall-x86_64.s -o tcc-syscall-x86_64.o
)
printf '%s\n' "$musl_obj/src/internal/tcc-syscall-x86_64.o" \
    >>"$musl_libc_objs"

# SEE proto/musl-tcc/musl_libc_a.md
"$mkdir" -p "$musl_lib"
(
    set --
    while IFS= read -r obj; do
        set -- "$@" "$obj"
    done <"$musl_libc_objs"
    "$tcc0" -ar rcs "$musl_lib/libc.a" "$@"
)

# SEE proto/musl-tcc/musl_libc_a_noindex.md
ar_first_name=$("$dd" if="$musl_lib/libc.a" bs=1 skip=8 count=16 2>/dev/null)
ar_first_name=$(printf '%s\n' "$ar_first_name" | "$tr" -d ' ')
if [ "$ar_first_name" = "/" ]; then
    ar_index_size=$("$dd" if="$musl_lib/libc.a" bs=1 skip=56 count=10 2>/dev/null)
    ar_index_size=$(printf '%s\n' "$ar_index_size" | "$tr" -cd '0-9')
    ar_index_skip=$((8 + 60 + ar_index_size + ar_index_size % 2))
    printf '%s\n' '!<arch>' >"$musl_lib/libc.a.noindex"
    "$dd" \
        if="$musl_lib/libc.a" \
        bs=1 \
        skip="$ar_index_skip" \
        >>"$musl_lib/libc.a.noindex" \
        2>/dev/null
    "$mv" "$musl_lib/libc.a.noindex" "$musl_lib/libc.a"
fi

# SEE proto/musl-tcc/musl_crt_objs.md
"$mkdir" -p "$musl_obj/crt/x86_64"
(
    cd "$musl_src"
    tcc0_musl_cc -DCRT -c crt/crt1.c -o "$musl_obj/crt/crt1.o"
    tcc0_musl_cc -DCRT -c crt/x86_64/crti.s \
        -o "$musl_obj/crt/x86_64/crti.o"
    tcc0_musl_cc -DCRT -c crt/x86_64/crtn.s \
        -o "$musl_obj/crt/x86_64/crtn.o"
)
"$cp" "$musl_obj/crt/crt1.o" "$musl_lib/crt1.o"
"$cp" "$musl_obj/crt/x86_64/crti.o" "$musl_lib/crti.o"
"$cp" "$musl_obj/crt/x86_64/crtn.o" "$musl_lib/crtn.o"

# hygiene
"$rm" -rf "$musl_obj"

# Mirrors musl's EMPTY_LIBS: valid empty archives for compatibility -l flags.
for lib in m rt pthread crypt util xnet resolv dl; do
    printf '%s\n' '!<arch>' >"$musl_lib/lib$lib.a"
done

# Build TCC with a supplied compiler and output path from inside TCC's source
# tree, keeping source basenames out of the final binary strings.
build_musl_tcc() {
    build_musl_tcc_cc=$1
    build_musl_tcc_out=$2

    (
        cd "$tcc_src"
        "$build_musl_tcc_cc" \
            -static \
            -nostdlib \
            -I . \
            -I "$build/include" \
            -o "$build_musl_tcc_out" \
            '-DTCC_TARGET_X86_64=1' \
            '-DTCC_MUSL=1' \
            '-DCONFIG_TCCDIR="{B}"' \
            '-DCONFIG_TCC_CRTPREFIX="{B}/lib"' \
            '-DCONFIG_TCC_LIBPATHS="{B}/lib:{B}"' \
            '-DCONFIG_TCC_SYSINCLUDEPATHS="{B}/include"' \
            '-DCONFIG_TCC_STATIC=1' \
            '-DTCC_VERSION="0.9.27"' \
            '-DONE_SOURCE=1' \
            "$musl_lib/crt1.o" \
            "$musl_lib/crti.o" \
            tcc.c \
            "$musl_lib/libc.a" \
            "$build/libtcc1.a" \
            "$musl_lib/crtn.o"
    )

    unset build_musl_tcc_cc build_musl_tcc_out
}

# tcc1
tcc1=$build/tcc1
build_musl_tcc "$tcc0" "$tcc1"

# smoke test tcc1
"$tcc1" -static "$test_dir/tcc1-smoke.c" -o "$work_dir/tcc1-smoke"
"$work_dir/tcc1-smoke" >/dev/null
"$tcc1" -static "$test_dir/tcc1-ldbl-min.c" \
    -o "$work_dir/tcc1-ldbl-min"
"$work_dir/tcc1-ldbl-min" >/dev/null

# Rebuild with tcc1 and require a byte-identical fixed point.
tcc2=$work_dir/tcc2
build_musl_tcc "$tcc1" "$tcc2"
"$cmp" "$tcc1" "$tcc2"

# Install the fixed-point compiler under its final user-facing name.
"$mv" "$tcc1" "$build/tcc"

# remove old tcc0
"$rm" "$tcc0"
