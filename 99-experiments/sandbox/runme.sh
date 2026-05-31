#!/bin/sh
set -eu

usage() {
    printf '%s\n' \
        'usage: 99-experiments/sandbox/runme.sh --sandbox-dir DIR --cc CC --out-dir DIR --bwrap BWRAP (--asm-script SCRIPT | --fasm FASM | --nasm NASM | --as AS --objcopy OBJCOPY)' >&2
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

write_prefixed_source() {
    write_prefixed_source_prefix=$1
    write_prefixed_source_src=$2
    write_prefixed_source_out=$3

    {
        printf '%s\n' "$write_prefixed_source_prefix"
        cat "$write_prefixed_source_src"
    } >"$write_prefixed_source_out"

    unset write_prefixed_source_prefix write_prefixed_source_src
    unset write_prefixed_source_out
}

assemble_target() {
    assemble_target_src=$1
    assemble_target_out=$2
    assemble_target_name=${assemble_target_src##*/}
    assemble_target_name=${assemble_target_name%.asm}
    assemble_target_tmp=$tmp_dir/$assemble_target_name.provider.asm

    case "$asm_provider" in
        asm-script)
            "$asm_script" "$assemble_target_src" "$assemble_target_out"
            ;;
        fasm)
            write_prefixed_source 'use64' \
                "$assemble_target_src" \
                "$assemble_target_tmp"
            assemble_target_log=$tmp_dir/$assemble_target_name.fasm.log
            if ! "$fasm" "$assemble_target_tmp" "$assemble_target_out" \
                >"$assemble_target_log" 2>&1; then
                cat "$assemble_target_log" >&2
                return 1
            fi
            unset assemble_target_log
            ;;
        nasm)
            write_prefixed_source 'BITS 64' \
                "$assemble_target_src" \
                "$assemble_target_tmp"
            "$nasm" -f bin -o "$assemble_target_out" "$assemble_target_tmp"
            ;;
        as)
            assemble_target_obj=$tmp_dir/$assemble_target_name.o
            {
                printf '%s\n' \
                    '.intel_syntax noprefix' \
                    '.code64' \
                    '.text' \
                    '.global _start' \
                    '_start:'
                cat "$assemble_target_src"
            } >"$assemble_target_tmp"
            "$as_path" -o "$assemble_target_obj" "$assemble_target_tmp"
            "$objcopy" -O binary -j .text \
                "$assemble_target_obj" \
                "$assemble_target_out"
            unset assemble_target_obj
            ;;
        *)
            fail "unknown assembler provider: $asm_provider"
            ;;
    esac

    unset assemble_target_src assemble_target_out assemble_target_name
    unset assemble_target_tmp
}

build_target() {
    build_target_src=$1
    build_target_name=${build_target_src##*/}
    build_target_name=${build_target_name%.asm}
    build_target_tmp=$tmp_dir/$build_target_name.bin
    build_target_out=$target_dir/$build_target_name.bin

    assemble_target "$build_target_src" "$build_target_tmp"
    if [ ! -s "$build_target_tmp" ]; then
        fail "assembler produced empty output: $build_target_src"
    fi

    cp "$build_target_tmp" "$build_target_out"
    chmod 644 "$build_target_out"

    unset build_target_src build_target_name build_target_tmp build_target_out
}

sandbox_dir=
cc=
out_dir=
bwrap=
asm_script=
fasm=
nasm=
as_path=
objcopy=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --sandbox-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --sandbox-dir'
            sandbox_dir=$2
            shift 2
            ;;
        --cc)
            [ "$#" -ge 2 ] || usage_error 'missing value for --cc'
            cc=$2
            shift 2
            ;;
        --out-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --out-dir'
            out_dir=$2
            shift 2
            ;;
        --bwrap)
            [ "$#" -ge 2 ] || usage_error 'missing value for --bwrap'
            bwrap=$2
            shift 2
            ;;
        --asm-script)
            [ "$#" -ge 2 ] || usage_error 'missing value for --asm-script'
            asm_script=$2
            shift 2
            ;;
        --fasm)
            [ "$#" -ge 2 ] || usage_error 'missing value for --fasm'
            fasm=$2
            shift 2
            ;;
        --nasm)
            [ "$#" -ge 2 ] || usage_error 'missing value for --nasm'
            nasm=$2
            shift 2
            ;;
        --as)
            [ "$#" -ge 2 ] || usage_error 'missing value for --as'
            as_path=$2
            shift 2
            ;;
        --objcopy)
            [ "$#" -ge 2 ] || usage_error 'missing value for --objcopy'
            objcopy=$2
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

[ -n "$sandbox_dir" ] || usage_error 'missing required --sandbox-dir'
[ -n "$cc" ] || usage_error 'missing required --cc'
[ -n "$out_dir" ] || usage_error 'missing required --out-dir'
[ -n "$bwrap" ] || usage_error 'missing required --bwrap'

provider_count=0
asm_provider=
if [ -n "$asm_script" ]; then
    provider_count=$((provider_count + 1))
    asm_provider=asm-script
fi
if [ -n "$fasm" ]; then
    provider_count=$((provider_count + 1))
    asm_provider=fasm
fi
if [ -n "$nasm" ]; then
    provider_count=$((provider_count + 1))
    asm_provider=nasm
fi
if [ -n "$as_path" ] || [ -n "$objcopy" ]; then
    [ -n "$as_path" ] || usage_error '--objcopy requires --as'
    [ -n "$objcopy" ] || usage_error '--as requires --objcopy'
    provider_count=$((provider_count + 1))
    asm_provider=as
fi

[ "$provider_count" -eq 1 ] ||
    usage_error 'choose exactly one assembly provider'

if [ ! -d "$sandbox_dir" ]; then
    fail "missing sandbox directory: $sandbox_dir"
fi
require_command_path 'C compiler' "$cc"
require_command_path bwrap "$bwrap"
case "$asm_provider" in
    asm-script) require_command_path 'assembler script' "$asm_script" ;;
    fasm) require_command_path fasm "$fasm" ;;
    nasm) require_command_path nasm "$nasm" ;;
    as)
        require_command_path as "$as_path"
        require_command_path objcopy "$objcopy"
        ;;
esac

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dud-sandbox.XXXXXX")
cleanup_tmp() { rm -rf "$tmp_dir"; }
trap cleanup_tmp EXIT HUP INT TERM

target_dir=$out_dir/targets
mkdir -p "$target_dir"

loader_tmp=$tmp_dir/loader
"$cc" \
    -static \
    -std=c11 \
    -Wfatal-errors \
    "$sandbox_dir/loader/loader.c" \
    "$sandbox_dir/loader/seccomp.c" \
    "$sandbox_dir/loader/jump_x86_64.S" \
    -o "$loader_tmp"
cp "$loader_tmp" "$out_dir/loader"
chmod 755 "$out_dir/loader"

found_targets=0
for target_src in "$sandbox_dir"/targets/*.asm; do
    if [ ! -f "$target_src" ]; then
        continue
    fi
    found_targets=1
    build_target "$target_src"
done

[ "$found_targets" -eq 1 ] ||
    fail "no target sources found under: $sandbox_dir/targets"

"$sandbox_dir/test/main.sh" \
    --runner "$sandbox_dir/scripts/run-sandbox.sh" \
    --loader "$out_dir/loader" \
    --bwrap "$bwrap" \
    --target-dir "$target_dir"
