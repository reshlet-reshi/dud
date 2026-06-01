#!/bin/sh
set -eu

# Make tool ordering bytewise and independent of the caller's terminal locale.
LC_ALL=C
export LC_ALL

usage() {
    printf '%s\n' \
        'usage: 99-experiments/musl-tcc/runme.sh --musl-tcc-dir DIR --bootstrap-cc CC --install-dir DIR --work-dir DIR --tar TAR --patch PATCH --sed SED --find FIND --sort SORT --grep GREP --cmp CMP --sha256sum SHA256SUM --chmod CHMOD --cp CP --rm RM --mv MV --mkdir MKDIR --dd DD --tr TR --dirname DIRNAME' \
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

absolute_dir_path() {
    absolute_dir_path_value=$1

    case "$absolute_dir_path_value" in
        /*)
            printf '%s\n' "$absolute_dir_path_value"
            ;;
        */*)
            absolute_dir_path_parent=${absolute_dir_path_value%/*}
            absolute_dir_path_base=${absolute_dir_path_value##*/}
            absolute_dir_path_parent=$(
                CDPATH=
                cd "$absolute_dir_path_parent" &&
                    pwd
            )
            printf '%s/%s\n' "$absolute_dir_path_parent" "$absolute_dir_path_base"
            unset absolute_dir_path_parent absolute_dir_path_base
            ;;
        *)
            printf '%s/%s\n' "$(pwd)" "$absolute_dir_path_value"
            ;;
    esac

    unset absolute_dir_path_value
}

parent_dir() {
    parent_dir_path=$1
    parent_dir_parent=${parent_dir_path%/*}
    if [ "$parent_dir_parent" = "$parent_dir_path" ]; then
        parent_dir_parent=.
    fi
    printf '%s\n' "$parent_dir_parent"
    unset parent_dir_path parent_dir_parent
}

canonical_tar() {
    canonical_tar_tree=$1
    canonical_tar_out=$2

    "$tar" \
        --sort=name \
        --mtime='@0' \
        --owner=0 \
        --group=0 \
        --numeric-owner \
        --pax-option=delete=atime,delete=ctime \
        -cf "$canonical_tar_out" \
        -C "$canonical_tar_tree" .

    unset canonical_tar_tree canonical_tar_out
}

# Keep the canonical tar and installed tree independent of the caller's umask.
normalize_install_tree() {
    normalize_install_tree_dir=$1

    "$find" "$normalize_install_tree_dir" -type d -exec "$chmod" 755 {} +
    "$find" "$normalize_install_tree_dir" -type f -exec "$chmod" 644 {} +
    "$chmod" 755 "$normalize_install_tree_dir/tcc"

    unset normalize_install_tree_dir
}

musl_tcc_dir=
bootstrap_cc=
install_dir=
work_dir=
tar=
patch=
sed=
find=
sort=
grep=
cmp=
sha256sum=
chmod=
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
        --bootstrap-cc)
            [ "$#" -ge 2 ] || usage_error 'missing value for --bootstrap-cc'
            bootstrap_cc=$2
            shift 2
            ;;
        --install-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --install-dir'
            install_dir=$2
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
        --sha256sum)
            [ "$#" -ge 2 ] || usage_error 'missing value for --sha256sum'
            sha256sum=$2
            shift 2
            ;;
        --chmod)
            [ "$#" -ge 2 ] || usage_error 'missing value for --chmod'
            chmod=$2
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
[ -n "$bootstrap_cc" ] || usage_error 'missing required --bootstrap-cc'
[ -n "$install_dir" ] || usage_error 'missing required --install-dir'
[ -n "$work_dir" ] || usage_error 'missing required --work-dir'
[ -n "$tar" ] || usage_error 'missing required --tar'
[ -n "$patch" ] || usage_error 'missing required --patch'
[ -n "$sed" ] || usage_error 'missing required --sed'
[ -n "$find" ] || usage_error 'missing required --find'
[ -n "$sort" ] || usage_error 'missing required --sort'
[ -n "$grep" ] || usage_error 'missing required --grep'
[ -n "$cmp" ] || usage_error 'missing required --cmp'
[ -n "$sha256sum" ] || usage_error 'missing required --sha256sum'
[ -n "$chmod" ] || usage_error 'missing required --chmod'
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

if [ ! -f "$musl_tcc_dir/.stamp" ]; then
    fail "missing musl-tcc stamp: $musl_tcc_dir/.stamp"
fi
if [ ! -x "$musl_tcc_dir/build-from-seed.sh" ]; then
    fail "missing executable build helper: $musl_tcc_dir/build-from-seed.sh"
fi
if [ ! -f "$musl_tcc_dir/test/tcc1-smoke.c" ]; then
    fail "missing tcc smoke source: $musl_tcc_dir/test/tcc1-smoke.c"
fi

require_command_path 'bootstrap C compiler' "$bootstrap_cc"
require_command_path tar "$tar"
require_command_path patch "$patch"
require_command_path sed "$sed"
require_command_path find "$find"
require_command_path sort "$sort"
require_command_path grep "$grep"
require_command_path cmp "$cmp"
require_command_path sha256sum "$sha256sum"
require_command_path chmod "$chmod"
require_command_path cp "$cp"
require_command_path rm "$rm"
require_command_path mv "$mv"
require_command_path mkdir "$mkdir"
require_command_path dd "$dd"
require_command_path tr "$tr"
require_command_path dirname "$dirname"

bootstrap_cc=$(absolute_path "$bootstrap_cc")
tar=$(absolute_path "$tar")
patch=$(absolute_path "$patch")
sed=$(absolute_path "$sed")
find=$(absolute_path "$find")
sort=$(absolute_path "$sort")
grep=$(absolute_path "$grep")
cmp=$(absolute_path "$cmp")
sha256sum=$(absolute_path "$sha256sum")
chmod=$(absolute_path "$chmod")
cp=$(absolute_path "$cp")
rm=$(absolute_path "$rm")
mv=$(absolute_path "$mv")
mkdir=$(absolute_path "$mkdir")
dd=$(absolute_path "$dd")
tr=$(absolute_path "$tr")
dirname=$(absolute_path "$dirname")

install_parent=$(parent_dir "$install_dir")
"$mkdir" -p "$install_parent"
install_dir=$(absolute_dir_path "$install_dir")
"$mkdir" -p "$work_dir"
work_dir=$(absolute_dir "$work_dir")

case "$install_dir" in
    "$work_dir" | "$work_dir"/*)
        fail '--install-dir must not be inside --work-dir'
        ;;
esac
case "$work_dir" in
    "$install_dir" | "$install_dir"/*)
        fail '--work-dir must not be inside --install-dir'
        ;;
esac

tcc_stamp=$musl_tcc_dir/.stamp
tcc=$install_dir/tcc

if [ -d "$install_dir" ] &&
    [ -x "$tcc" ] &&
    [ ! "$tcc_stamp" -nt "$install_dir" ]
then
    exit 0
fi

"$rm" -rf "$work_dir"
"$mkdir" -p "$work_dir"

expected_canonical_sha256=9bce8e8d61d4df02587f479e053111e9e6b888eb744f9007324a908ad8ab7d32
first_build=$work_dir/musl-tcc-seed
second_build=$work_dir/musl-tcc-reseed

"$musl_tcc_dir/build-from-seed.sh" \
    --musl-tcc-dir "$musl_tcc_dir" \
    --seed-cc "$bootstrap_cc" \
    --out-dir "$first_build" \
    --work-dir "$work_dir/seed" \
    --tar "$tar" \
    --patch "$patch" \
    --sed "$sed" \
    --find "$find" \
    --sort "$sort" \
    --grep "$grep" \
    --cmp "$cmp" \
    --cp "$cp" \
    --rm "$rm" \
    --mv "$mv" \
    --mkdir "$mkdir" \
    --dd "$dd" \
    --tr "$tr" \
    --dirname "$dirname"
"$musl_tcc_dir/build-from-seed.sh" \
    --musl-tcc-dir "$musl_tcc_dir" \
    --seed-cc "$first_build/tcc" \
    --out-dir "$second_build" \
    --work-dir "$work_dir/reseed" \
    --tar "$tar" \
    --patch "$patch" \
    --sed "$sed" \
    --find "$find" \
    --sort "$sort" \
    --grep "$grep" \
    --cmp "$cmp" \
    --cp "$cp" \
    --rm "$rm" \
    --mv "$mv" \
    --mkdir "$mkdir" \
    --dd "$dd" \
    --tr "$tr" \
    --dirname "$dirname"

normalize_install_tree "$first_build"
normalize_install_tree "$second_build"

canonical_tar "$first_build" "$work_dir/seed.tar"
canonical_tar "$second_build" "$work_dir/reseed.tar"
"$cmp" "$work_dir/seed.tar" "$work_dir/reseed.tar"
canonical_sha256=$("$sha256sum" "$work_dir/seed.tar")
canonical_sha256=${canonical_sha256%% *}
if [ "$canonical_sha256" != "$expected_canonical_sha256" ]; then
    printf '%s\n' 'canonical tar sha256 mismatch' >&2
    printf 'expected %s\n' "$expected_canonical_sha256" >&2
    printf 'actual   %s\n' "$canonical_sha256" >&2
    exit 1
fi

install_tmp=$work_dir/install-tmp
"$rm" -rf "$install_tmp"
"$mkdir" -p "$install_tmp"
"$cp" -R "$first_build"/. "$install_tmp"
normalize_install_tree "$install_tmp"
"$rm" -rf "$install_dir"
"$mv" "$install_tmp" "$install_dir"

"$tcc" -static "$musl_tcc_dir/test/tcc1-smoke.c" \
    -o "$work_dir/tcc1-smoke"
"$work_dir/tcc1-smoke" >/dev/null
