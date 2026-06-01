#!/bin/sh
set -eu

usage() {
    printf '%s\n' \
        'usage: proto/ctok/test/main.sh --ctok CTOK --ctok-dir DIR --expect EXPECT --test-dir DIR --coverage yes|no [coverage tool paths]' \
        '' \
        'coverage tool paths, required with --coverage yes:' \
        '  --coverage-cc CC --gcov GCOV --awk AWK --sed SED --grep GREP --cut CUT --tr TR --wc WC' \
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

coverage_awk() {
    "$awk" "$@"
}

coverage_sed() {
    "$sed" "$@"
}

coverage_grep() {
    "$grep" "$@"
}

coverage_cut() {
    "$cut" "$@"
}

coverage_tr() {
    "$tr" "$@"
}

coverage_wc() {
    "$wc" "$@"
}

ctok=
ctok_dir=
expect=
test_dir=
coverage=
coverage_cc=
gcov=
awk=
sed=
grep=
cut=
tr=
wc=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --ctok)
            [ "$#" -ge 2 ] || usage_error 'missing value for --ctok'
            ctok=$2
            shift 2
            ;;
        --ctok-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --ctok-dir'
            ctok_dir=$2
            shift 2
            ;;
        --expect)
            [ "$#" -ge 2 ] || usage_error 'missing value for --expect'
            expect=$2
            shift 2
            ;;
        --test-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --test-dir'
            test_dir=$2
            shift 2
            ;;
        --coverage)
            [ "$#" -ge 2 ] || usage_error 'missing value for --coverage'
            coverage=$2
            shift 2
            ;;
        --coverage-cc)
            [ "$#" -ge 2 ] || usage_error 'missing value for --coverage-cc'
            coverage_cc=$2
            shift 2
            ;;
        --gcov)
            [ "$#" -ge 2 ] || usage_error 'missing value for --gcov'
            gcov=$2
            shift 2
            ;;
        --awk)
            [ "$#" -ge 2 ] || usage_error 'missing value for --awk'
            awk=$2
            shift 2
            ;;
        --sed)
            [ "$#" -ge 2 ] || usage_error 'missing value for --sed'
            sed=$2
            shift 2
            ;;
        --grep)
            [ "$#" -ge 2 ] || usage_error 'missing value for --grep'
            grep=$2
            shift 2
            ;;
        --cut)
            [ "$#" -ge 2 ] || usage_error 'missing value for --cut'
            cut=$2
            shift 2
            ;;
        --tr)
            [ "$#" -ge 2 ] || usage_error 'missing value for --tr'
            tr=$2
            shift 2
            ;;
        --wc)
            [ "$#" -ge 2 ] || usage_error 'missing value for --wc'
            wc=$2
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

[ -n "$ctok" ] || usage_error 'missing required --ctok'
[ -n "$ctok_dir" ] || usage_error 'missing required --ctok-dir'
[ -n "$expect" ] || usage_error 'missing required --expect'
[ -n "$test_dir" ] || usage_error 'missing required --test-dir'
[ -n "$coverage" ] || usage_error 'missing required --coverage'

case $coverage in
    yes | no)
        ;;
    *)
        usage_error 'expected --coverage yes or --coverage no'
        ;;
esac

if [ "$coverage" = yes ]; then
    [ -n "$coverage_cc" ] || usage_error 'missing required --coverage-cc'
    [ -n "$gcov" ] || usage_error 'missing required --gcov'
    [ -n "$awk" ] || usage_error 'missing required --awk'
    [ -n "$sed" ] || usage_error 'missing required --sed'
    [ -n "$grep" ] || usage_error 'missing required --grep'
    [ -n "$cut" ] || usage_error 'missing required --cut'
    [ -n "$tr" ] || usage_error 'missing required --tr'
    [ -n "$wc" ] || usage_error 'missing required --wc'
fi

if [ ! -d "$ctok_dir" ]; then
    fail "missing ctok directory: $ctok_dir"
fi
if [ ! -d "$test_dir" ]; then
    fail "missing ctok test directory: $test_dir"
fi

require_command_path ctok "$ctok"
require_command_path expect "$expect"
ctok=$(absolute_path "$ctok")
expect=$(absolute_path "$expect")
ctok_dir=$(absolute_dir "$ctok_dir")
test_dir=$(absolute_dir "$test_dir")

if [ "$coverage" = yes ]; then
    require_command_path 'coverage C compiler' "$coverage_cc"
    require_command_path gcov "$gcov"
    require_command_path awk "$awk"
    require_command_path sed "$sed"
    require_command_path grep "$grep"
    require_command_path cut "$cut"
    require_command_path tr "$tr"
    require_command_path wc "$wc"

    coverage_cc=$(absolute_path "$coverage_cc")
    gcov=$(absolute_path "$gcov")
    awk=$(absolute_path "$awk")
    sed=$(absolute_path "$sed")
    grep=$(absolute_path "$grep")
    cut=$(absolute_path "$cut")
    tr=$(absolute_path "$tr")
    wc=$(absolute_path "$wc")
fi

if [ ! -f "$ctok_dir/main.c" ]; then
    fail "missing ctok source: $ctok_dir/main.c"
fi

test_tmp=$(mktemp -d "${TMPDIR:-/tmp}/dud-test-ctok.XXXXXX")

cleanup_test_tmp() {
    rm -rf "$test_tmp"
}

trap cleanup_test_tmp EXIT HUP INT TERM

expect_status_output() {
    expected_status=$1
    expected_output=$2
    label=$3
    shift 3

    set +e
    actual_output=$("$@" 2>&1)
    actual_status=$?
    set -e

    if [ "$actual_status" -ne "$expected_status" ]
    then
        printf '%s: expected exit %s, got %s: %s\n' \
            "$label" \
            "$expected_status" \
            "$actual_status" \
            "$*" \
            >&2
        exit 1
    fi

    "$expect" output "$expected_output" "$actual_output" "$label"
}

case_i=0
ctok_under_test=
ctok_label=

expect_ctok_case() {
    label=$1
    input=$2
    expected=$3

    case_i=$((case_i + 1))
    input_path=$test_tmp/ctok-case-$case_i.c

    printf '%b' "$input" >"$input_path"

    expect_status_output \
        0 \
        "$expected" \
        "$ctok_label: $label" \
        "$ctok_under_test" \
        "$input_path"
}

run_ctok_suite() {
    ctok_under_test=$1
    ctok_label=$2
    case_i=0

    expect_status_output \
        1 \
        'wrong number of arguments, only expected a file path' \
        "$ctok_label: no arguments" \
        "$ctok_under_test"

    missing_path=$test_tmp/no-such-file
    expect_status_output \
        1 \
        "Failed to open file '$missing_path'." \
        "$ctok_label: missing file" \
        "$ctok_under_test" \
        "$missing_path"

    expect_ctok_case 'empty file' '' ''

    expected=$(
        cat <<'EOF'
raw_identifier "a" 1:1
unknown "\r\n" 1:2
raw_identifier "b" 2:1
unknown "\r" 2:2
raw_identifier "c" 3:1
unknown "\x00\x20\t\f\v\n" 3:2
EOF
    )
    expect_ctok_case \
        'decode and whitespace scrub' \
        '\357\273\277a\r\nb\rc\0 \t\f\v\n' \
        "$expected"

    expected=$(
        cat <<'EOF'
hash "??=" 1:1
unknown "\x20" 1:4
unknown "??/" 1:5
raw_identifier "x" 1:8
unknown "\x20" 1:9
l_brace "??<" 1:10
unknown "\x20" 1:13
r_brace "??>" 1:14
unknown "\x20" 1:17
l_square "??(" 1:18
unknown "\x20" 1:21
r_square "??)" 1:22
unknown "\x20" 1:25
caret "??'" 1:26
unknown "\x20" 1:29
pipe "??!" 1:30
unknown "\x20" 1:33
tilde "??-" 1:34
unknown "\x20" 1:37
question "?" 1:38
question "?" 1:39
raw_identifier "x" 1:40
unknown "\n" 1:41
EOF
    )
    expect_ctok_case \
        'trigraphs' \
        "??= ??/x ??< ??> ??( ??) ??' ??! ??- ??x\n" \
        "$expected"

    expected=$(
        cat <<'EOF'
raw_identifier "a" 1:1
unknown "\\\n\x20" 1:2
raw_identifier "b" 2:2
unknown "\\\x20\t\n\x20" 2:3
raw_identifier "c\\\n" 3:2
EOF
    )
    expect_ctok_case \
        'escaped line breaks' \
        'a\\\n b\\ \t\n c\\\n' \
        "$expected"

    expected=$(
        cat <<'EOF'
comment "//\x20line\x20comment" 1:1
unknown "\n" 1:16
comment "/*\x20ok\x20*/" 2:1
unknown "\n" 2:9
unknown "/**\x20unterminated\n/\n" 3:1
EOF
    )
    expect_ctok_case \
        'comments' \
        '// line comment\n/* ok */\n/** unterminated\n/\n' \
        "$expected"

    expected=$(
        cat <<'EOF'
string_literal "\"s\\\"x\"" 1:1
unknown "\x20" 1:7
unknown "\"missing" 1:8
unknown "\n" 1:16
char_constant "'c'" 2:1
unknown "\x20" 2:4
unknown "''" 2:5
unknown "\x20" 2:7
unknown "'missing" 2:8
unknown "\n" 2:16
wide_string_literal "L\"w\"" 3:1
unknown "\x20" 3:5
wide_char_constant "L'w'" 3:6
unknown "\x20" 3:10
utf16_string_literal "u\"u\"" 3:11
unknown "\x20" 3:15
utf16_char_constant "u'u'" 3:16
unknown "\x20" 3:20
utf32_string_literal "U\"U\"" 3:21
unknown "\x20" 3:25
utf32_char_constant "U'U'" 3:26
unknown "\x20" 3:30
utf8_string_literal "u8\"u8\"" 3:31
unknown "\n" 3:37
unknown "\"eof" 4:1
EOF
    )
    expect_ctok_case \
        'literals' \
        '"s\\"x" "missing\n\047c\047 \047\047 \047missing\nL"w" L\047w\047 u"u" u\047u\047 U"U" U\047U\047 u8"u8"\n"eof' \
        "$expected"

    expected=$(
        cat <<'EOF'
numeric_constant ".5" 1:1
unknown "\x20" 1:3
numeric_constant "1e+" 1:4
unknown "\x20" 1:7
numeric_constant "2E-" 1:8
unknown "\x20" 1:11
numeric_constant "3p+" 1:12
unknown "\x20" 1:15
numeric_constant "4P-" 1:16
unknown "\x20" 1:19
numeric_constant "5.6" 1:20
unknown "\x20" 1:23
numeric_constant "7" 1:24
raw_identifier "$" 1:25
unknown "\x20" 1:26
numeric_constant "8\\u00E9" 1:27
unknown "\x20" 1:34
numeric_constant "9\\u0380" 1:35
unknown "\x20" 1:42
numeric_constant "0x1p+" 1:43
unknown "\x20" 1:48
period "." 1:49
unknown "\x20" 1:50
period "." 1:51
period "." 1:52
unknown "\x20" 1:53
ellipsis "..." 1:54
unknown "\x20" 1:57
raw_identifier "a" 1:58
period "." 1:59
raw_identifier "b" 1:60
unknown "\x20" 1:61
raw_identifier "_" 1:62
unknown "\x20" 1:63
raw_identifier "$x" 1:64
unknown "\x20" 1:66
raw_identifier "abc$" 1:67
unknown "\x20" 1:71
raw_identifier "def\\u00e9" 1:72
unknown "\x20" 1:81
raw_identifier "ghi\\u0300" 1:82
unknown "\x20" 1:91
raw_identifier "\\u00E9" 1:92
unknown "\x20" 1:98
unknown "\\u0030" 1:99
unknown "\x20" 1:105
unknown "\\uD800" 1:106
unknown "\x20" 1:112
unknown "\\U00110001" 1:113
unknown "\x20" 1:123
raw_identifier "\\u{00E9}" 1:124
unknown "\x20" 1:132
unknown "\\" 1:133
raw_identifier "u" 1:134
l_brace "{" 1:135
numeric_constant "00G0" 1:136
r_brace "}" 1:140
unknown "\x20" 1:141
unknown "\\" 1:142
raw_identifier "u" 1:143
l_brace "{" 1:144
raw_identifier "FFFFFFFFF" 1:145
r_brace "}" 1:154
unknown "\x20" 1:155
unknown "\\" 1:156
raw_identifier "u123" 1:157
unknown "\x20" 1:161
unknown "\\" 1:162
raw_identifier "u" 1:163
unknown "\x20" 1:164
unknown "\\u0000" 1:165
unknown "\x20" 1:171
unknown "\\UFFFFFFFF" 1:172
raw_identifier "F" 1:182
unknown "\x20" 1:183
unknown "\\u2000" 1:184
unknown "\x20" 1:190
unknown "\\u0300" 1:191
unknown "\x20" 1:197
unknown "\\" 1:198
raw_identifier "z" 1:199
unknown "\n" 1:200
EOF
    )
    input=$(
        cat <<'EOF'
.5 1e+ 2E- 3p+ 4P- 5.6 7$ 8\\u00E9 9\\u0380 0x1p+ . .. ... a.b _ $x abc$ def\\u00e9 ghi\\u0300 \\u00E9 \\u0030 \\uD800 \\U00110001 \\u{00E9} \\u{00G0} \\u{FFFFFFFFF} \\u123 \\u \\u0000 \\UFFFFFFFFF \\u2000 \\u0300 \\z\n
EOF
    )
    expect_ctok_case \
        'identifiers numbers and ucns' \
        "$input" \
        "$expected"

    expected=$(
        cat <<'EOF'
hashhash "%:%:" 1:1
unknown "\x20" 1:5
greatergreaterequal ">>=" 1:6
unknown "\x20" 1:9
lesslessequal "<<=" 1:10
unknown "\x20" 1:13
ellipsis "..." 1:14
unknown "\x20" 1:17
pipeequal "|=" 1:18
unknown "\x20" 1:20
pipepipe "||" 1:21
unknown "\x20" 1:23
caretequal "^=" 1:24
unknown "\x20" 1:26
equalequal "==" 1:27
unknown "\x20" 1:29
coloncolon "::" 1:30
unknown "\x20" 1:32
r_square ":>" 1:33
unknown "\x20" 1:35
minusequal "-=" 1:36
unknown "\x20" 1:38
minusminus "--" 1:39
unknown "\x20" 1:41
arrow "->" 1:42
unknown "\x20" 1:44
plusequal "+=" 1:45
unknown "\x20" 1:47
plusplus "++" 1:48
unknown "\x20" 1:50
starequal "*=" 1:51
unknown "\x20" 1:53
ampequal "&=" 1:54
unknown "\x20" 1:56
ampamp "&&" 1:57
unknown "\x20" 1:59
hashhash "##" 1:60
unknown "\x20" 1:62
exclaimequal "!=" 1:63
unknown "\x20" 1:65
greaterequal ">=" 1:66
unknown "\x20" 1:68
greatergreater ">>" 1:69
unknown "\x20" 1:71
lessequal "<=" 1:72
unknown "\x20" 1:74
l_square "<:" 1:75
unknown "\x20" 1:77
l_brace "<%" 1:78
unknown "\x20" 1:80
lessless "<<" 1:81
unknown "\x20" 1:83
r_brace "%>" 1:84
unknown "\x20" 1:86
percentequal "%=" 1:87
unknown "\x20" 1:89
hash "%:" 1:90
unknown "\x20" 1:92
slashequal "/=" 1:93
unknown "\x20" 1:95
tilde "~" 1:96
unknown "\x20" 1:97
r_brace "}" 1:98
unknown "\x20" 1:99
l_brace "{" 1:100
unknown "\x20" 1:101
r_square "]" 1:102
unknown "\x20" 1:103
l_square "[" 1:104
unknown "\x20" 1:105
question "?" 1:106
unknown "\x20" 1:107
semi ";" 1:108
unknown "\x20" 1:109
comma "," 1:110
unknown "\x20" 1:111
r_paren ")" 1:112
unknown "\x20" 1:113
l_paren "(" 1:114
unknown "\x20" 1:115
pipe "|" 1:116
unknown "\x20" 1:117
caret "^" 1:118
unknown "\x20" 1:119
equal "=" 1:120
unknown "\x20" 1:121
colon ":" 1:122
unknown "\x20" 1:123
minus "-" 1:124
unknown "\x20" 1:125
plus "+" 1:126
unknown "\x20" 1:127
star "*" 1:128
unknown "\x20" 1:129
amp "&" 1:130
unknown "\x20" 1:131
hash "#" 1:132
unknown "\x20" 1:133
exclaim "!" 1:134
unknown "\x20" 1:135
greater ">" 1:136
unknown "\x20" 1:137
less "<" 1:138
unknown "\x20" 1:139
percent "%" 1:140
unknown "\x20" 1:141
period "." 1:142
unknown "\x20" 1:143
slash "/" 1:144
unknown "\x20" 1:145
unknown "@" 1:146
unknown "\x20" 1:147
unknown "`" 1:148
unknown "\n" 1:149
EOF
    )
    expect_ctok_case \
        'punctuation' \
        '%:%: >>= <<= ... |= || ^= == :: :> -= -- -> += ++ *= &= && ## != >= >> <= <: <% << %> %= %: /= ~ } { ] [ ? ; , ) ( | ^ = : - + * & # ! > < % . / @ `\n' \
        "$expected"

    expected=$(
        cat <<'EOF'
unknown "\x80" 1:1
unknown "\x20" 1:2
unknown "\xF8" 1:3
unknown "\x20" 1:4
unknown "\xC0" 1:5
unknown "\x80" 1:6
unknown "\x20" 1:7
unknown "\xE0" 1:8
unknown "\x80" 1:9
unknown "\x80" 1:10
unknown "\x20" 1:11
unknown "\xF0" 1:12
unknown "\x80" 1:13
unknown "\x80" 1:14
unknown "\x80" 1:15
unknown "\x20" 1:16
unknown "\xED" 1:17
unknown "\xA0" 1:18
unknown "\x80" 1:19
unknown "\x20" 1:20
unknown "\xF4" 1:21
unknown "\x90" 1:22
unknown "\x80" 1:23
unknown "\x80" 1:24
unknown "\x20" 1:25
unknown "\xC2" 1:26
raw_identifier "A" 1:27
unknown "\x20" 1:28
unknown "\xE0" 1:29
unknown "\x9F" 1:30
unknown "\xBF" 1:31
unknown "\x20" 1:32
unknown "\xF0" 1:33
unknown "\x8F" 1:34
unknown "\xBF" 1:35
unknown "\xBF" 1:36
EOF
    )
    expect_ctok_case \
        'invalid utf8 body cases' \
        '\200 \370 \300\200 \340\200\200 \360\200\200\200 \355\240\200 \364\220\200\200 \302A \340\237\277 \360\217\277\277' \
        "$expected"

    expected=$(
        cat <<'EOF'
unknown "\xE2" 1:1
unknown "\x82" 1:2
EOF
    )
    expect_ctok_case \
        'invalid utf8 truncated eof' \
        '\342\202' \
        "$expected"
}

trim_source_line() {
    coverage_sed -n "${1}p" "$ctok_dir/main.c" |
        coverage_sed 's/^[	 ]*//; s/[	 ]*$//'
}

write_coverage_allowlist() {
    cat >"$1" <<'EOF'
60|return 0;|Byte_span_len null begin guard; no CLI path can pass a null span.
64|return 0;|Byte_span_len reversed span guard; no CLI path can pass an inverted span.
1011|continue;|Defensive empty punctuation entry guard; puncts has no empty entries.
1219|return invalid;|Lex_ucn non-backslash guard; callers only enter this helper after seeing backslash.
1761|return 0;|Len_leading_line_break empty range guard; printed tokens always have positive byte length.
1883|printf(|fseek SEEK_END hard failure path; normal temp files do not trigger it.
1887|return 1;|fseek SEEK_END hard failure path; normal temp files do not trigger it.
1893|printf(|ftell hard failure path; normal temp files do not trigger it.
1897|return 1;|ftell hard failure path; normal temp files do not trigger it.
1904|printf(|fseek SEEK_SET hard failure path; normal temp files do not trigger it.
1908|return 1;|fseek SEEK_SET hard failure path; normal temp files do not trigger it.
1916|printf(|calloc failure path; normal-sized temp files do not trigger it portably.
1922|return 1;|calloc failure path; normal-sized temp files do not trigger it portably.
1935|printf(|short fread path; normal temp files do not trigger it portably.
1942|return 1;|short fread path; normal temp files do not trigger it portably.
EOF
}

validate_coverage() {
    cov_tmp=$1
    gcov_file=$cov_tmp/main.c.gcov
    allowlist=$test_tmp/ctok-coverage-allowlist
    allow_lines=$test_tmp/ctok-coverage-allow-lines
    uncovered=$test_tmp/ctok-coverage-uncovered

    (
        cd "$cov_tmp"
        "$gcov" -o "$cov_tmp/ctok-main.gcno" \
            "$ctok_dir/main.c" \
            >/dev/null
    )

    coverage_awk -F: '$1 ~ /#####/ { gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2 }' \
        "$gcov_file" \
        >"$uncovered"

    write_coverage_allowlist "$allowlist"
    coverage_cut -d '|' -f 1 "$allowlist" >"$allow_lines"

    while IFS='|' read -r line snippet reason
    do
        source_line=$(trim_source_line "$line")

        if [ "$source_line" != "$snippet" ]
        then
            printf 'ctok coverage allowlist stale at line %s\n' "$line" >&2
            printf '  expected snippet: %s\n' "$snippet" >&2
            printf '  actual snippet:   %s\n' "$source_line" >&2
            printf '  reason: %s\n' "$reason" >&2
            exit 1
        fi

        if ! coverage_grep -qx "$line" "$uncovered"
        then
            printf 'ctok coverage allowlist stale: line %s is now covered\n' \
                "$line" \
                >&2
            printf '  snippet: %s\n' "$snippet" >&2
            printf '  reason: %s\n' "$reason" >&2
            exit 1
        fi
    done <"$allowlist"

    while IFS= read -r line
    do
        if ! coverage_grep -qx "$line" "$allow_lines"
        then
            source_line=$(trim_source_line "$line")
            printf 'ctok coverage missed unallowlisted line %s: %s\n' \
                "$line" \
                "$source_line" \
                >&2
            exit 1
        fi
    done <"$uncovered"

    raw_uncovered_count=$(coverage_wc -l <"$uncovered" | coverage_tr -d ' ')
    printf 'ctok coverage: adjusted line coverage 100%% '
    printf '(%s raw uncovered lines allowlisted)\n' "$raw_uncovered_count"
    printf 'ctok coverage allowlist:\n'
    coverage_awk -F '|' '
        {
            lines[NR] = $1
            snippets[NR] = $2
            reasons[NR] = $3

            if (length($1) > line_width)
                line_width = length($1)

            if (length($2) > snippet_width)
                snippet_width = length($2)
        }
        END {
            for (i = 1; i <= NR; ++i) {
                printf "  %*s | %-*s | %s\n",
                    line_width,
                    lines[i],
                    snippet_width,
                    snippets[i],
                    reasons[i]
            }
        }
    ' "$allowlist"
}

run_coverage_report_self_tests() {
    "$test_dir/coverage-report-test.sh" \
        --ctok-dir "$ctok_dir" \
        --expect "$expect" \
        --test-dir "$test_dir" \
        --awk "$awk" \
        --sed "$sed"
}

print_coverage_details() {
    "$test_dir/coverage-report.sh" report \
        --cov-tmp "$1" \
        --ctok-dir "$ctok_dir" \
        --test-tmp "$test_tmp" \
        --gcov "$gcov" \
        --awk "$awk" \
        --sed "$sed"
}

build_coverage_ctok() {
    cov_tmp=$test_tmp/coverage
    mkdir "$cov_tmp"

    (
        cd "$cov_tmp"
        "$coverage_cc" \
            -std=c11 \
            -Wall \
            -Wextra \
            -Wpedantic \
            -Wmissing-prototypes \
            -Wstrict-prototypes \
            -Wold-style-definition \
            -fprofile-arcs \
            -ftest-coverage \
            -fcondition-coverage \
            -fpath-coverage \
            "$ctok_dir/main.c" \
            -o "$cov_tmp/ctok"
    )

    printf '%s\n' "$cov_tmp/ctok"
}

run_ctok_suite "$ctok" 'ctok'

if [ "$coverage" = yes ]; then
    run_coverage_report_self_tests
    coverage_ctok=$(build_coverage_ctok)
    run_ctok_suite "$coverage_ctok" 'coverage ctok'
    validate_coverage "$test_tmp/coverage"
    print_coverage_details "$test_tmp/coverage"
fi
